import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../connector/meshcore_connector.dart';
import '../storage/draft_store.dart';
import '../storage/prefs_manager.dart';

/// A message written while no radio was connected.
class OutboxEntry {
  const OutboxEntry({
    required this.id,
    required this.radio,
    required this.target,
    required this.text,
    required this.at,
    this.sendAt,
  });

  factory OutboxEntry.fromJson(Map<String, dynamic> json) => OutboxEntry(
    id: json['id'] as String,
    radio: json['radio'] as String,
    target: json['target'] as String,
    text: json['text'] as String,
    at: DateTime.fromMillisecondsSinceEpoch(json['at'] as int),
    sendAt: json['sendAt'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(json['sendAt'] as int),
  );

  final String id;

  /// The radio it was written for. It only ever goes out from that one.
  final String radio;

  /// `message:<contact key>` or `channel:<index>`.
  final String target;
  final String text;
  final DateTime at;

  /// When the user asked for it to go out; null means as soon as possible.
  final DateTime? sendAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'radio': radio,
    'target': target,
    'text': text,
    'at': at.millisecondsSinceEpoch,
    if (sendAt != null) 'sendAt': sendAt!.millisecondsSinceEpoch,
  };
}

/// Holds messages written while disconnected and sends them, oldest first,
/// once the same radio is back and has finished syncing.
///
/// Anything older than [maxAge], or addressed to someone the radio no longer
/// has, goes back to that conversation's draft for the user to decide: an
/// old "on my way" must not go out by itself.
class OfflineOutbox extends ChangeNotifier {
  OfflineOutbox(
    this.connector, {
    DateTime Function()? clock,
    this.spacing = const Duration(seconds: 3),
  }) : _clock = clock ?? DateTime.now {
    _load();
    connector.addListener(check);
    check();
  }

  static const maxAge = Duration(hours: 24);
  static const _entriesKey = 'offline_outbox_v1';
  static const _radioKey = 'offline_outbox_last_radio';

  final MeshCoreConnector connector;
  final DateTime Function() _clock;

  /// Pause between sends, so a backlog doesn't flood the mesh.
  final Duration spacing;

  final List<OutboxEntry> _entries = [];
  String _lastRadio = '';
  var _seq = 0;
  var _flushing = false;
  Timer? _timer;

  /// What is waiting for [target], oldest first.
  List<OutboxEntry> entriesFor(String target) =>
      _entries.where((e) => e.target == target).toList(growable: false);

  /// Saves [text] to send later. False when no radio has ever been seen,
  /// because there is then no identity to send it from.
  Future<bool> add(String target, String text, {DateTime? sendAt}) async {
    if (_lastRadio.isEmpty) return false;
    final now = _clock();
    _entries.add(
      OutboxEntry(
        id: '${now.microsecondsSinceEpoch}-${_seq++}',
        radio: _lastRadio,
        target: target,
        text: text,
        at: now,
        sendAt: sendAt,
      ),
    );
    await _save();
    notifyListeners();
    check();
    return true;
  }

  Future<void> remove(String id) async {
    _entries.removeWhere((e) => e.id == id);
    await _save();
    notifyListeners();
  }

  /// Notes the current radio and sends what's waiting if it is ready.
  void check() {
    final self = connector.selfPublicKeyHex;
    if (self.isNotEmpty && self != _lastRadio) {
      _lastRadio = self;
      unawaited(_saveRadio());
    }
    _armTimer();
    if (_flushing || !_ready || !_entries.any((e) => _isDue(e, self))) return;
    _flushing = true;
    unawaited(
      flush()
          .catchError((Object e) => debugPrint('Outbox send failed: $e'))
          .whenComplete(() {
            _flushing = false;
            _armTimer();
          }),
    );
  }

  bool _isDue(OutboxEntry e, String radio) =>
      e.radio == radio && !(e.sendAt?.isAfter(_clock()) ?? false);

  /// Wakes [check] when the next scheduled message comes due.
  void _armTimer() {
    _timer?.cancel();
    _timer = null;
    final now = _clock();
    final times = _entries
        .map((e) => e.sendAt)
        .whereType<DateTime>()
        .where((t) => t.isAfter(now));
    if (times.isEmpty) return;
    final next = times.reduce((a, b) => a.isBefore(b) ? a : b);
    _timer = Timer(next.difference(now), check);
  }

  bool get _ready =>
      connector.isConnected &&
      connector.selfPublicKeyHex.isNotEmpty &&
      connector.hasLoadedChannels &&
      !connector.isLoadingContacts &&
      !connector.isSyncingChannels;

  /// Sends what's waiting for the connected radio, stopping if it drops.
  @visibleForTesting
  Future<void> flush() async {
    final self = connector.selfPublicKeyHex;
    final due = _entries.where((e) => _isDue(e, self)).toList();
    for (var i = 0; i < due.length; i++) {
      if (!_ready || connector.selfPublicKeyHex != self) return;
      final entry = due[i];
      // Removed first: a crash mid-send must not repeat it over the air.
      _entries.remove(entry);
      await _save();
      notifyListeners();
      final sent =
          _clock().difference(entry.sendAt ?? entry.at) <= maxAge &&
          await _send(entry);
      if (!sent) {
        await _toDraft(entry);
      } else if (i < due.length - 1 && spacing > Duration.zero) {
        await Future<void>.delayed(spacing);
      }
    }
  }

  Future<bool> _send(OutboxEntry entry) async {
    final split = entry.target.indexOf(':');
    final id = entry.target.substring(split + 1);
    if (entry.target.startsWith('message:')) {
      final contact = connector.getContactByPubKeyHex(id);
      if (contact == null) return false;
      await connector.sendMessage(contact, entry.text);
      return true;
    }
    final index = int.tryParse(id);
    for (final channel in connector.channels) {
      if (channel.index == index) {
        await connector.sendChannelMessage(channel, entry.text);
        return true;
      }
    }
    return false;
  }

  Future<void> _toDraft(OutboxEntry entry) async {
    final split = entry.target.indexOf(':');
    final id = entry.target.substring(split + 1);
    final String key;
    if (entry.target.startsWith('message:')) {
      key = DraftStore.contactKey(entry.radio, id);
    } else {
      final index = int.tryParse(id);
      if (index == null) return;
      key = DraftStore.channelKey(entry.radio, index);
    }
    final existing = DraftStore.load(key);
    await DraftStore.save(
      key,
      existing == null ? entry.text : '$existing\n${entry.text}',
    );
  }

  void _load() {
    try {
      final prefs = PrefsManager.instance;
      _lastRadio = prefs.getString(_radioKey) ?? '';
      final raw = prefs.getString(_entriesKey);
      if (raw == null) return;
      for (final item in jsonDecode(raw) as List<dynamic>) {
        _entries.add(OutboxEntry.fromJson(item as Map<String, dynamic>));
      }
    } on StateError {
      // Storage not ready (tests, early startup).
    } on FormatException catch (e) {
      debugPrint('Outbox unreadable: $e');
    }
  }

  Future<void> _save() async {
    try {
      await PrefsManager.instance.setString(
        _entriesKey,
        jsonEncode(_entries.map((e) => e.toJson()).toList()),
      );
    } on StateError {
      // Storage not ready; it stays in memory.
    }
  }

  Future<void> _saveRadio() async {
    try {
      await PrefsManager.instance.setString(_radioKey, _lastRadio);
    } on StateError {
      // Storage not ready; it's noted again next time.
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    connector.removeListener(check);
    super.dispose();
  }
}
