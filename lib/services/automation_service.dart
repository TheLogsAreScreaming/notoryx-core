import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../connector/meshcore_connector.dart';
import '../models/automation_rule.dart';
import '../models/bot_settings.dart';
import '../storage/prefs_manager.dart';
import 'notification_service.dart';

/// Runs the user's automation rules while the app is open.
class AutomationService extends ChangeNotifier {
  AutomationService(
    this.connector, {
    DateTime Function()? clock,
    Future<void> Function(String title, String body)? notify,
    Duration tick = const Duration(seconds: 30),
  }) : _clock = clock ?? DateTime.now,
       _notify = notify ?? _postNotification {
    _load();
    if (tick > Duration.zero) {
      _timer = Timer.periodic(tick, (_) => run());
    }
  }

  static const _key = 'automation_rules_v1';

  final MeshCoreConnector connector;
  final DateTime Function() _clock;
  final Future<void> Function(String title, String body) _notify;
  final AutomationEngine _engine = AutomationEngine();
  final List<AutomationRule> _rules = [];
  Timer? _timer;

  static Future<void> _postNotification(String title, String body) =>
      NotificationService().showAutomation(title: title, body: body);

  List<AutomationRule> get rules => List.unmodifiable(_rules);

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

  /// One evaluation pass.
  @visibleForTesting
  Future<void> run() async {
    final now = _clock();
    final fired = _engine.evaluate(
      _rules,
      AutomationSnapshot(
        now: now,
        batteryPercent: connector.isConnected ? connector.batteryPercent : null,
        latitude: connector.isConnected ? connector.selfLatitude : null,
        longitude: connector.isConnected ? connector.selfLongitude : null,
        nodeLastSeen: {
          for (final c in connector.contacts) c.publicKeyHex: c.lastSeen,
        },
      ),
    );
    for (final rule in fired) {
      try {
        await _act(rule);
      } catch (e) {
        debugPrint('Automation "${rule.name}" failed: $e');
      }
    }
  }

  Future<void> _act(AutomationRule rule) async {
    if (rule.action == AutomationAction.notify) {
      await _notify(rule.name, rule.text);
      return;
    }
    final target = rule.target;
    if (target == null || !connector.isConnected || rule.text.trim().isEmpty) {
      return;
    }
    final text = '$botPrefix${rule.text.trim()}';
    final id = target.substring(target.indexOf(':') + 1);
    if (target.startsWith('message:')) {
      final contact = connector.getContactByPubKeyHex(id);
      if (contact != null) await connector.sendMessage(contact, text);
      return;
    }
    final index = int.tryParse(id);
    for (final channel in connector.channels) {
      if (channel.index == index) {
        await connector.sendChannelMessage(channel, text);
      }
    }
  }

  void _load() {
    try {
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
    notifyListeners();
    try {
      await PrefsManager.instance.setString(
        _key,
        jsonEncode(_rules.map((r) => r.toJson()).toList()),
      );
    } on StateError {
      // Storage not ready; rules stay in memory.
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
