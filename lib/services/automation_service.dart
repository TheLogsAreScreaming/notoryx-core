import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../connector/meshcore_connector.dart';
import '../connector/meshcore_protocol.dart';
import '../models/automation_rule.dart';
import '../models/bot_settings.dart';
import '../models/channel.dart';
import '../models/channel_message.dart';
import '../models/message.dart';
import '../storage/prefs_manager.dart';
import 'notification_service.dart';

/// Why an action did or didn't run, for the recent-runs list.
enum AutomationOutcome {
  done,
  notConnected,
  noTarget,
  webOff,
  webFailed,
  noFreeSlot,
  failed,
}

/// One rule run, shown on the automation screen.
class AutomationRun {
  const AutomationRun({
    required this.at,
    required this.rule,
    required this.action,
    required this.outcome,
  });

  final DateTime at;
  final String rule;
  final AutomationAction action;
  final AutomationOutcome outcome;

  bool get ok => outcome == AutomationOutcome.done;
}

typedef WebhookPost = Future<int> Function(Uri url, String jsonBody);

/// Runs the user's automation rules while the app is open.
class AutomationService extends ChangeNotifier {
  AutomationService(
    this.connector, {
    DateTime Function()? clock,
    Future<void> Function(String title, String body)? notify,
    Future<void> Function()? playSound,
    WebhookPost? post,
    Duration tick = const Duration(seconds: 30),
  }) : _clock = clock ?? DateTime.now,
       _notify = notify ?? _postNotification,
       _playSound = playSound ?? _systemSound,
       _post = post ?? _httpPost {
    _load();
    _directSub = connector.receivedDirectMessages.listen(_onDirect);
    _channelSub = connector.radioChannelMessages.listen(_onChannel);
    if (tick > Duration.zero) {
      _timer = Timer.periodic(tick, (_) => run());
    }
  }

  static const _key = 'automation_rules_v1';
  static const _webKey = 'automation_webhooks_allowed_v1';

  /// Messages older than this when they arrive (synced backlog) are ignored.
  static const messageMaxAge = Duration(minutes: 10);
  static const webhookTimeout = Duration(seconds: 10);
  static const maxRuns = 30;

  final MeshCoreConnector connector;
  final DateTime Function() _clock;
  final Future<void> Function(String title, String body) _notify;
  final Future<void> Function() _playSound;
  final WebhookPost _post;
  final AutomationEngine _engine = AutomationEngine();
  final List<AutomationRule> _rules = [];
  final List<AutomationMessage> _inbox = [];
  final List<AutomationRun> _runs = [];
  StreamSubscription<Message>? _directSub;
  StreamSubscription<ChannelMessage>? _channelSub;
  Timer? _timer;
  bool _webAllowed = false;
  bool _running = false;
  bool _disposed = false;

  static Future<void> _postNotification(String title, String body) =>
      NotificationService().showAutomation(title: title, body: body);

  static Future<void> _systemSound() => SystemSound.play(SystemSoundType.alert);

  static Future<int> _httpPost(Uri url, String body) async {
    final response = await http
        .post(url, headers: {'content-type': 'application/json'}, body: body)
        .timeout(webhookTimeout);
    return response.statusCode;
  }

  List<AutomationRule> get rules => List.unmodifiable(_rules);

  /// Newest first.
  List<AutomationRun> get runs => List.unmodifiable(_runs.reversed);

  /// Whether webhook actions may reach the internet. Off by default.
  bool get webhooksAllowed => _webAllowed;

  Future<void> setWebhooksAllowed(bool allowed) async {
    _webAllowed = allowed;
    _changed();
    try {
      await PrefsManager.instance.setBool(_webKey, allowed);
    } on StateError {
      // Storage not ready; the choice holds until the app closes.
    }
  }

  /// Adds [rule], or replaces the one with its id.
  Future<void> save(AutomationRule rule) async {
    final at = _rules.indexWhere((r) => r.id == rule.id);
    if (at < 0) {
      _rules.add(rule);
    } else {
      _rules[at] = rule;
    }
    await _persist();
  }

  Future<void> delete(String id) async {
    _rules.removeWhere((r) => r.id == id);
    await _persist();
  }

  bool _fresh(DateTime sent) =>
      _clock().difference(sent).abs() <= messageMaxAge;

  bool _countable(String text) =>
      text.trim().isNotEmpty &&
      !text.startsWith(botPrefix) &&
      Message.parseReaction(text) == null;

  void _onDirect(Message m) {
    if (m.isOutgoing || m.isCli || !_fresh(m.timestamp)) return;
    if (m.senderKeyHex == connector.selfPublicKeyHex || !_countable(m.text)) {
      return;
    }
    final contact = connector.getContactByPubKeyHex(m.senderKeyHex);
    _queue(
      AutomationMessage(
        text: m.text,
        senderKey: m.senderKeyHex,
        senderName: contact?.name ?? '',
      ),
    );
  }

  void _onChannel(ChannelMessage m) {
    if (m.isOutgoing || m.viaMqtt || !_fresh(m.timestamp)) return;
    if (!_countable(m.text)) return;
    String? key;
    for (final c in connector.contacts) {
      if (c.type == advTypeChat && c.name == m.senderName) key = c.publicKeyHex;
    }
    _queue(
      AutomationMessage(
        text: m.text,
        senderKey: key,
        senderName: m.senderName,
        channelIndex: m.channelIndex,
      ),
    );
  }

  void _queue(AutomationMessage m) {
    if (!_rules.any(
      (r) =>
          r.enabled &&
          r.conditions.any(
            (c) => c.trigger == AutomationTrigger.messageReceived,
          ),
    )) {
      return;
    }
    _inbox.add(m);
    unawaited(run());
  }

  /// One evaluation pass.
  @visibleForTesting
  Future<void> run() async {
    if (_running || _disposed) return;
    _running = true;
    try {
      final messages = List.of(_inbox);
      _inbox.clear();
      final now = _clock();
      final fired = _engine.evaluate(
        _rules,
        AutomationSnapshot(
          now: now,
          batteryPercent: connector.isConnected
              ? connector.batteryPercent
              : null,
          latitude: connector.isConnected ? connector.selfLatitude : null,
          longitude: connector.isConnected ? connector.selfLongitude : null,
          nodeLastSeen: {
            for (final c in connector.contacts) c.publicKeyHex: c.lastSeen,
          },
          messages: messages,
        ),
      );
      for (final firing in fired) {
        for (final step in firing.rule.steps) {
          AutomationOutcome outcome;
          try {
            outcome = await _act(firing, step, now);
          } catch (e) {
            debugPrint('Automation "${firing.rule.name}" failed: $e');
            outcome = step.needsInternet
                ? AutomationOutcome.webFailed
                : AutomationOutcome.failed;
          }
          _log(firing.rule.name, step.action, outcome, now);
        }
      }
    } finally {
      _running = false;
    }
  }

  void _log(
    String rule,
    AutomationAction action,
    AutomationOutcome outcome,
    DateTime at,
  ) {
    _runs.add(
      AutomationRun(at: at, rule: rule, action: action, outcome: outcome),
    );
    if (_runs.length > maxRuns) _runs.removeAt(0);
    _changed();
  }

  String _fill(AutomationFiring firing, String template, DateTime now) =>
      fillAutomationText(
        template,
        rule: firing.rule.name,
        time:
            '${now.hour.toString().padLeft(2, '0')}:'
            '${now.minute.toString().padLeft(2, '0')}',
        battery: connector.batteryPercent,
        message: firing.message,
      );

  Future<AutomationOutcome> _act(
    AutomationFiring firing,
    AutomationStep step,
    DateTime now,
  ) async {
    final text = _fill(firing, step.text.trim(), now);
    switch (step.action) {
      case AutomationAction.notify:
        await _notify(firing.rule.name, text);
        return AutomationOutcome.done;
      case AutomationAction.playSound:
        await _playSound();
        return AutomationOutcome.done;
      case AutomationAction.webhook:
        return _webhook(firing, step, text, now);
      case AutomationAction.joinChannel:
        return _join(step.text);
      case AutomationAction.send:
        return _send(step.target, text);
    }
  }

  Future<AutomationOutcome> _send(String? target, String text) async {
    if (target == null || text.isEmpty) return AutomationOutcome.noTarget;
    if (!connector.isConnected) return AutomationOutcome.notConnected;
    final body = '$botPrefix$text';
    final id = target.substring(target.indexOf(':') + 1);
    if (target.startsWith('message:')) {
      final contact = connector.getContactByPubKeyHex(id);
      if (contact == null) return AutomationOutcome.noTarget;
      await connector.sendMessage(contact, body);
      return AutomationOutcome.done;
    }
    final index = int.tryParse(id);
    for (final channel in connector.channels) {
      if (channel.index == index) {
        await connector.sendChannelMessage(channel, body);
        return AutomationOutcome.done;
      }
    }
    return AutomationOutcome.noTarget;
  }

  /// Joins hashtag channel [name] in the first free slot, unless the radio
  /// already has it.
  Future<AutomationOutcome> _join(String name) async {
    final tag = name.trim();
    if (tag.replaceFirst('#', '').isEmpty) return AutomationOutcome.noTarget;
    if (!connector.isConnected) return AutomationOutcome.notConnected;
    final hashtag = tag.startsWith('#') ? tag : '#$tag';
    final psk = Channel.derivePskFromHashtag(hashtag);
    final hex = Channel.formatPskHex(psk);
    if (connector.channels.any((c) => Channel.formatPskHex(c.psk) == hex)) {
      return AutomationOutcome.done;
    }
    final used = {
      for (final c in connector.channels)
        if (!c.isEmpty) c.index,
    };
    for (var i = 0; i < connector.maxChannels; i++) {
      if (!used.contains(i)) {
        await connector.setChannel(i, hashtag, psk);
        return AutomationOutcome.done;
      }
    }
    return AutomationOutcome.noFreeSlot;
  }

  Future<AutomationOutcome> _webhook(
    AutomationFiring firing,
    AutomationStep step,
    String text,
    DateTime now,
  ) async {
    if (!_webAllowed) return AutomationOutcome.webOff;
    final url = Uri.tryParse(step.target ?? '');
    if (url == null || !(url.isScheme('https') || url.isScheme('http'))) {
      return AutomationOutcome.noTarget;
    }
    final status = await _post(
      url,
      jsonEncode({
        'rule': firing.rule.name,
        'time': now.toUtc().toIso8601String(),
        'battery': connector.batteryPercent,
        'node': firing.message?.senderName,
        'text': text.isEmpty ? firing.message?.text : text,
      }),
    );
    return status >= 200 && status < 300
        ? AutomationOutcome.done
        : AutomationOutcome.webFailed;
  }

  void _load() {
    try {
      _webAllowed = PrefsManager.instance.getBool(_webKey) ?? false;
      final raw = PrefsManager.instance.getString(_key);
      if (raw == null) return;
      for (final item in jsonDecode(raw) as List<dynamic>) {
        _rules.add(AutomationRule.fromJson(item as Map<String, dynamic>));
      }
    } on StateError {
      // Storage not ready (tests, early startup).
    } on FormatException catch (e) {
      debugPrint('Automation rules unreadable: $e');
    }
  }

  Future<void> _persist() async {
    _changed();
    try {
      await PrefsManager.instance.setString(
        _key,
        jsonEncode(_rules.map((r) => r.toJson()).toList()),
      );
    } on StateError {
      // Storage not ready; rules stay in memory.
    }
  }

  void _changed() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    unawaited(_directSub?.cancel());
    unawaited(_channelSub?.cancel());
    super.dispose();
  }
}
