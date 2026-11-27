import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../storage/prefs_manager.dart';
import 'corescope.dart';

/// One channel packet from a CoreScope analyzer's packet list.
@immutable
class CoreScopeChannelPacket {
  const CoreScopeChannelPacket({
    required this.hash,
    required this.raw,
    required this.firstSeen,
  });

  final String hash;
  final Uint8List raw;
  final DateTime? firstSeen;
}

/// The MeshCore payload type of an encrypted channel message (GRP_TXT).
const coreScopeGroupTextType = 5;

/// Channel packets in CoreScope's `/api/packets` answer, oldest first.
/// Entries without usable raw bytes, or of another payload type, are left
/// out.
List<CoreScopeChannelPacket> parseCoreScopeChannelPackets(
  Map<String, dynamic> json,
) {
  final out = <CoreScopeChannelPacket>[];
  for (final p in json['packets'] as List? ?? const []) {
    if (p is! Map) continue;
    final type = p['payload_type'];
    if (type is num && type.toInt() != coreScopeGroupTextType) continue;
    final hex = p['raw_hex'];
    final hash = p['hash'];
    if (hex is! String || hash is! String || hash.isEmpty) continue;
    final raw = _hexBytes(hex);
    if (raw == null || raw.length < 2) continue;
    out.add(
      CoreScopeChannelPacket(
        hash: hash.toLowerCase(),
        raw: raw,
        firstSeen: DateTime.tryParse(p['first_seen'] as String? ?? ''),
      ),
    );
  }
  out.sort((a, b) {
    final at = a.firstSeen, bt = b.firstSeen;
    if (at == null || bt == null) return at == null ? -1 : 1;
    return at.compareTo(bt);
  });
  return out;
}

Uint8List? _hexBytes(String hex) {
  final h = hex.trim();
  if (h.isEmpty || h.length.isOdd) return null;
  final out = Uint8List(h.length ~/ 2);
  for (var i = 0; i < out.length; i++) {
    final b = int.tryParse(h.substring(i * 2, i * 2 + 2), radix: 16);
    if (b == null) return null;
    out[i] = b;
  }
  return out;
}

/// Whether [region] is a usable region filter: empty (no filter) or
/// comma separated 3 to 4 letter codes such as `ORD` or `ORD,MDW`.
bool isValidCoreScopeRegion(String region) {
  final r = region.trim();
  if (r.isEmpty) return true;
  return r
      .split(',')
      .every((c) => RegExp(r'^[A-Za-z]{3,4}$').hasMatch(c.trim()));
}

/// Reads area channel messages from the CoreScope analyzer the user picked,
/// so messages this radio missed still show up in the channel views.
///
/// Read only: it only ever makes GET requests for channel packets, with the
/// packet type, a start time, the optional region, the sort order and a
/// page size. Nothing the radio hears is sent anywhere. Off by default, and
/// while off (or while the app is in the background) it makes no requests.
///
/// Packets are handed to [onPacket] as raw bytes and decrypted on the phone
/// with the user's own channel keys, so only joined channels show up.
class CoreScopeChatFeed extends ChangeNotifier {
  CoreScopeChatFeed({
    required this.analyzer,
    required this.onPacket,
    http.Client Function()? client,
    DateTime Function()? clock,
  }) : _client = client ?? http.Client.new,
       _clock = clock ?? DateTime.now;

  final AnalyzerService analyzer;

  /// Gets each new channel packet's raw bytes, oldest first.
  final void Function(Uint8List raw) onPacket;

  final http.Client Function() _client;
  final DateTime Function() _clock;

  static const _enabledKey = 'notoryx_corescope_chat_v1';
  static const _regionKey = 'notoryx_corescope_chat_region_v1';

  /// How far back the first fetch reads.
  static const backfill = Duration(hours: 6);
  static const pollEvery = Duration(seconds: 60);
  static const pageSize = 200;

  /// Pages read in one poll before waiting for the next.
  static const maxPagesPerPoll = 5;

  bool _enabled = false;
  String _region = '';
  bool _foreground = true;
  DateTime? _since;
  String _sinceUrl = '';
  final Set<String> _seen = {};
  final List<String> _seenOrder = [];
  Timer? _timer;
  bool _polling = false;
  bool _disposed = false;
  DateTime? _lastOk;
  bool _lastFailed = false;

  bool get enabled => _enabled;

  /// Comma separated region codes, or empty for the whole server.
  String get region => _region;

  /// When the last fetch worked, or null before one has.
  DateTime? get lastOk => _lastOk;

  /// Whether the last fetch failed (the analyzer couldn't be reached).
  bool get lastFailed => _lastFailed;

  void load() {
    final prefs = PrefsManager.instance;
    _enabled = prefs.getBool(_enabledKey) ?? false;
    _region = prefs.getString(_regionKey) ?? '';
    analyzer.addListener(_onAnalyzerChanged);
    _sinceUrl = analyzer.url;
    _reschedule();
  }

  Future<void> setEnabled(bool on) async {
    if (on == _enabled) return;
    _enabled = on;
    if (!on) _resetWindow();
    _reschedule();
    _notify();
    await PrefsManager.instance.setBool(_enabledKey, on);
  }

  Future<void> setRegion(String region) async {
    final r = region
        .split(',')
        .map((c) => c.trim().toUpperCase())
        .where((c) => c.isNotEmpty)
        .join(',');
    if (r == _region) return;
    _region = r;
    _resetWindow();
    _reschedule();
    _notify();
    await PrefsManager.instance.setString(_regionKey, r);
  }

  /// Polls only while the app is in front.
  set foreground(bool value) {
    if (value == _foreground) return;
    _foreground = value;
    _reschedule();
  }

  void _onAnalyzerChanged() {
    if (analyzer.url == _sinceUrl) return;
    _sinceUrl = analyzer.url;
    _resetWindow();
    _reschedule();
  }

  void _resetWindow() {
    _since = null;
    _seen.clear();
    _seenOrder.clear();
  }

  void _reschedule() {
    _timer?.cancel();
    _timer = null;
    if (_disposed || !_enabled || !_foreground) return;
    unawaited(pollNow());
    _timer = Timer.periodic(pollEvery, (_) => unawaited(pollNow()));
  }

  /// The request for the next page, from [since].
  @visibleForTesting
  Uri requestFor(DateTime since) {
    final base = analyzer.url.replaceAll(RegExp(r'/+$'), '');
    return Uri.parse('$base/api/packets').replace(
      queryParameters: {
        'type': '$coreScopeGroupTextType',
        'since': since.toUtc().toIso8601String(),
        'order': 'asc',
        'limit': '$pageSize',
        if (_region.isNotEmpty) 'region': _region,
      },
    );
  }

  /// Fetches packets since the last poll and hands new ones on.
  Future<void> pollNow() async {
    if (_polling || _disposed || !_enabled || !_foreground) return;
    if (!AnalyzerService.isValidUrl(analyzer.url)) return;
    _polling = true;
    try {
      for (var page = 0; page < maxPagesPerPoll; page++) {
        final since = _since ?? _clock().subtract(backfill);
        final json = await _get(requestFor(since));
        if (_disposed || !_enabled) return;
        if (json == null) {
          _lastFailed = true;
          _notify();
          return;
        }
        _lastFailed = false;
        _lastOk = _clock();
        final packets = parseCoreScopeChannelPackets(json);
        var newest = since;
        for (final p in packets) {
          final at = p.firstSeen;
          if (at != null && at.isAfter(newest)) newest = at;
          if (!_remember(p.hash)) continue;
          onPacket(p.raw);
        }
        _since = newest;
        _notify();
        final count = (json['packets'] as List?)?.length ?? 0;
        // A full page may have more behind it; a short one is caught up.
        if (count < pageSize || !newest.isAfter(since)) return;
      }
    } finally {
      _polling = false;
    }
  }

  bool _remember(String hash) {
    if (!_seen.add(hash)) return false;
    _seenOrder.add(hash);
    if (_seenOrder.length > 4000) _seen.remove(_seenOrder.removeAt(0));
    return true;
  }

  Future<Map<String, dynamic>?> _get(Uri uri) async {
    final client = _client();
    try {
      final res = await client
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) return null;
      final body = jsonDecode(res.body);
      return body is Map<String, dynamic> ? body : null;
    } catch (_) {
      return null;
    } finally {
      client.close();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    analyzer.removeListener(_onAnalyzerChanged);
    super.dispose();
  }
}
