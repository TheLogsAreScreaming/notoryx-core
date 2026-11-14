import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../connector/meshcore_connector.dart';
import '../connector/meshcore_protocol.dart';
import '../storage/draft_store.dart';
import '../storage/prefs_manager.dart';
import '../storage/secure_prefs.dart';

/// A message written while no radio was connected.
class OutboxEntry {
  const OutboxEntry({
    required this.id,
    required this.radio,
    required this.target,
    required this.text,
    required this.at,
    this.sendAt,
    this.handoff = false,
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
    handoff: json['handoff'] == true,
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

  /// True once it has been handed to the radio and before the radio has
  /// taken it. If the app stops in that gap nobody knows whether it went,
  /// so it is never sent again by itself: it goes back to the draft.
  final bool handoff;

  OutboxEntry inHandoff() => OutboxEntry(
    id: id,
    radio: radio,
    target: target,
    text: text,
    at: at,
    sendAt: sendAt,
    handoff: true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'radio': radio,
    'target': target,
    'text': text,
    'at': at.millisecondsSinceEpoch,
    if (sendAt != null) 'sendAt': sendAt!.millisecondsSinceEpoch,
    if (handoff) 'handoff': true,
  };
}

/// Why a queued message went back to its draft instead of out.
enum OutboxReturnReason {
  /// Older than [OfflineOutbox.maxAge].
  stale,

  /// The contact or channel is no longer on the radio.
  missingTarget,

  /// Longer than the radio accepts.
  tooLong,

  /// The send failed or the app stopped while sending, so it may or may
  /// not have gone out. Check before sending it again.
  unknown,
}

/// A message that went back to its draft, and why.
class OutboxReturn {
  const OutboxReturn(this.entry, this.reason);
  final OutboxEntry entry;
  final OutboxReturnReason reason;
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
    unawaited(_recoverInterrupted());
  }

  static const maxAge = Duration(hours: 24);
  static const _entriesBase = 'offline_outbox_v1';
  static const _radioBase = 'offline_outbox_last_radio';

  /// Each radio keeps its own outbox, so several can run at once. The
  /// first radio (slot '') keeps the keys earlier builds used.
  String get _entriesKey => connector.slot.isEmpty
      ? _entriesBase
      : '${_entriesBase}_${connector.slot}';
  String get _radioKey =>
      connector.slot.isEmpty ? _radioBase : '${_radioBase}_${connector.slot}';

  final MeshCoreConnector connector;
  final DateTime Function() _clock;

  /// Pause between sends, so a backlog doesn't flood the mesh.
  final Duration spacing;

  final List<OutboxEntry> _entries = [];
  final List<OutboxReturn> _returned = [];
  String _lastRadio = '';
  var _seq = 0;
  var _flushing = false;
  Timer? _timer;

  /// What is waiting for [target], oldest first.
  List<OutboxEntry> entriesFor(String target) =>
      _entries.where((e) => e.target == target).toList(growable: false);

  /// Messages for [target] whose send may or may not have gone out, so the
  /// chat can say so next to the draft they went back to.
  List<OutboxReturn> uncertainFor(String target) => _returned
      .where(
        (r) =>
            r.entry.target == target && r.reason == OutboxReturnReason.unknown,
      )
      .toList(growable: false);

  /// Everything that went back to a draft since the app started.
  List<OutboxReturn> get returned => List.unmodifiable(_returned);

  /// Clears the notes for [target] once the user has seen them.
  void dismissReturned(String target) {
    final before = _returned.length;
    _returned.removeWhere((r) => r.entry.target == target);
    if (_returned.length != before) notifyListeners();
  }

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

  /// A message mid-handoff is never due: it may already be out.
  bool _isDue(OutboxEntry e, String radio) =>
      e.radio == radio &&
      !e.handoff &&
      !(e.sendAt?.isAfter(_clock()) ?? false);

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
  ///
  /// Each message stays saved until the radio has taken it. Just before
  /// the handoff it is saved as "handing off"; if the send throws, or the
  /// app stops before it finishes, nobody knows whether it went out, so it
  /// goes back to the draft with a note rather than being sent again.
  @visibleForTesting
  Future<void> flush() async {
    final self = connector.selfPublicKeyHex;
    final due = _entries.where((e) => _isDue(e, self)).toList();
    for (var i = 0; i < due.length; i++) {
      if (!_ready || connector.selfPublicKeyHex != self) return;
      final entry = due[i];
      if (!_entries.contains(entry)) continue; // removed meanwhile
      final problem = _problem(entry);
      if (problem != null) {
        await _return(entry, problem);
        continue;
      }
      final pending = entry.inHandoff();
      _replace(entry, pending);
      await _save();
      // Re-checked after the save: the link can drop during it.
      if (!_ready || connector.selfPublicKeyHex != self) {
        _replace(pending, entry);
        await _save();
        return;
      }
      try {
        await _send(pending);
      } catch (e) {
        debugPrint('Outbox send failed, returned to draft: $e');
        await _return(pending, OutboxReturnReason.unknown);
        continue;
      }
      _entries.remove(pending);
      await _save();
      notifyListeners();
      if (i < due.length - 1 && spacing > Duration.zero) {
        await Future<void>.delayed(spacing);
      }
    }
  }

  /// Why [entry] can't go out now, or null when it can.
  OutboxReturnReason? _problem(OutboxEntry entry) {
    if (_clock().difference(entry.sendAt ?? entry.at) > maxAge) {
      return OutboxReturnReason.stale;
    }
    final split = entry.target.indexOf(':');
    final id = entry.target.substring(split + 1);
    if (entry.target.startsWith('message:')) {
      final contact = connector.getContactByPubKeyHex(id);
      if (contact == null) return OutboxReturnReason.missingTarget;
      final bytes = utf8
          .encode(connector.prepareContactOutboundText(contact, entry.text))
          .length;
      if (bytes > maxContactMessageBytes()) return OutboxReturnReason.tooLong;
      return null;
    }
    final index = int.tryParse(id);
    if (!connector.channels.any((c) => c.index == index)) {
      return OutboxReturnReason.missingTarget;
    }
    final bytes = utf8
        .encode(connector.prepareChannelOutboundText(index!, entry.text))
        .length;
    if (bytes > maxChannelMessageBytes(connector.selfName)) {
      return OutboxReturnReason.tooLong;
    }
    return null;
  }

  Future<void> _send(OutboxEntry entry) async {
    final split = entry.target.indexOf(':');
    final id = entry.target.substring(split + 1);
    if (entry.target.startsWith('message:')) {
      final contact = connector.getContactByPubKeyHex(id);
      if (contact == null) throw StateError('Contact is gone');
      await connector.sendMessage(contact, entry.text);
      return;
    }
    final index = int.tryParse(id);
    final channel = connector.channels.where((c) => c.index == index);
    if (channel.isEmpty) throw StateError('Channel is gone');
    await connector.sendChannelMessage(channel.first, entry.text);
  }

  void _replace(OutboxEntry from, OutboxEntry to) {
    final at = _entries.indexOf(from);
    if (at >= 0) _entries[at] = to;
  }

  /// Takes [entry] out of the outbox and puts its text back in the draft.
  /// The draft is written first, so the text is never only in memory.
  Future<void> _return(OutboxEntry entry, OutboxReturnReason reason) async {
    await _toDraft(entry);
    _entries.remove(entry);
    _returned.add(OutboxReturn(entry, reason));
    await _save();
    notifyListeners();
  }

  /// Anything left "handing off" by a crash or force-quit goes back to
  /// its draft: it may already be out, so it must not go out again.
  Future<void> _recoverInterrupted() async {
    final stuck = _entries.where((e) => e.handoff).toList();
    for (final entry in stuck) {
      await _return(entry, OutboxReturnReason.unknown);
    }
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
      final raw = SecurePrefs.getString(_entriesKey);
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
      await SecurePrefs.setString(
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
