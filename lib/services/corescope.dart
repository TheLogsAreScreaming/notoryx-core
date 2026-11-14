import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../storage/prefs_manager.dart';

/// One observer that heard a packet, from a CoreScope analyzer.
class ObserverHit {
  final String name;
  final double? snr;
  final int? rssi;
  final int hops;
  final DateTime? time;
  const ObserverHit({
    required this.name,
    this.snr,
    this.rssi,
    required this.hops,
    this.time,
  });
}

/// Who heard a packet: each observer once, keeping its best SNR.
List<ObserverHit> parseTraces(Map<String, dynamic> json) {
  final byName = <String, ObserverHit>{};
  for (final t in json['traces'] as List? ?? const []) {
    if (t is! Map) continue;
    final id = t['observer'] as String? ?? '?';
    final named = (t['observer_name'] as String?)?.trim();
    final name = named != null && named.isNotEmpty
        ? named
        : id.substring(0, id.length < 8 ? id.length : 8);
    var hops = 0;
    final path = t['path_json'];
    if (path is String && path.isNotEmpty) {
      try {
        hops = (jsonDecode(path) as List).length;
      } catch (_) {}
    }
    final hit = ObserverHit(
      name: name,
      snr: (t['snr'] as num?)?.toDouble(),
      rssi: (t['rssi'] as num?)?.toInt(),
      hops: hops,
      time: DateTime.tryParse(t['time'] as String? ?? ''),
    );
    final known = byName[name];
    if (known == null || (hit.snr ?? -99) > (known.snr ?? -99)) {
      byName[name] = hit;
    }
  }
  return byName.values.toList()
    ..sort((a, b) => (b.snr ?? -99).compareTo(a.snr ?? -99));
}

/// A hashtag channel an analyzer has seen in use.
class ActiveChannel {
  final String name;
  final int messages;
  final DateTime? lastActivity;
  const ActiveChannel(this.name, this.messages, this.lastActivity);
}

/// CoreScope's `/api/channels`: the hashtag channels in use, most recently
/// active first. Only `#` names are kept: those are the ones anyone can
/// join by name.
List<ActiveChannel> parseActiveChannels(Map<String, dynamic> json) {
  final out = <ActiveChannel>[];
  for (final c in json['channels'] as List? ?? const []) {
    if (c is! Map) continue;
    final name = (c['name'] as String? ?? '').trim();
    if (!name.startsWith('#') || name.length < 2) continue;
    out.add(
      ActiveChannel(
        name,
        (c['messageCount'] as num?)?.toInt() ?? 0,
        DateTime.tryParse(c['lastActivity'] as String? ?? ''),
      ),
    );
  }
  out.sort((a, b) {
    final at = a.lastActivity, bt = b.lastActivity;
    if (at == null || bt == null) return at == null ? 1 : -1;
    return bt.compareTo(at);
  });
  return out;
}

/// A repeater ID resolved online: its best-guess name, and whether more
/// than one known repeater shares the ID.
class OnlineHop {
  final String name;
  final bool ambiguous;

  /// Every repeater the server knows with this ID that has a position.
  final List<({String name, LatLng at})> candidates;

  const OnlineHop(this.name, this.ambiguous, [this.candidates = const []]);

  /// Farther than this from you, a repeater can't be one you heard.
  static const rangeMetres = 150000.0;

  /// This answer as seen from [near]: the nearest candidate within range,
  /// or null when none is. The analyzer may be on another continent, so a
  /// short ID's best-guess name is often someone else's repeater. Without
  /// a position, or when the server sent no candidates, it's unchanged.
  OnlineHop? from(LatLng? near) {
    if (near == null || candidates.isEmpty) return this;
    ({String name, LatLng at})? best;
    var bestMetres = rangeMetres;
    for (final c in candidates) {
      final m = const Distance()(near, c.at);
      if (m <= bestMetres) {
        best = c;
        bestMetres = m;
      }
    }
    return best == null ? null : OnlineHop(best.name, false);
  }
}

/// CoreScope's `resolve-hops` answer, by upper-case ID.
Map<String, OnlineHop> parseResolvedHops(Map<String, dynamic> json) {
  final out = <String, OnlineHop>{};
  final resolved = json['resolved'];
  if (resolved is! Map) return out;
  resolved.forEach((id, v) {
    if (v is Map && v['name'] is String && (v['name'] as String).isNotEmpty) {
      out[(id as String).toUpperCase()] =
          OnlineHop((v['name'] as String).trim(), v['ambiguous'] == true, [
            for (final c in v['candidates'] as List? ?? const [])
              if (c case {
                'name': final String name,
                'lat': final num lat,
                'lon': final num lon,
              } when name.trim().isNotEmpty)
                (name: name.trim(), at: LatLng(lat.toDouble(), lon.toDouble())),
          ]);
    }
  });
  return out;
}

/// An online MeshCore analyzer running CoreScope, for checking which
/// observers heard a message and naming repeater IDs this radio doesn't
/// know. Lookups send a packet hash or repeater IDs to that server and
/// nothing else. Hop lookup is off until you turn it on.
class AnalyzerService extends ChangeNotifier {
  AnalyzerService({http.Client Function()? client})
    : _client = client ?? http.Client.new;

  final http.Client Function() _client;

  static const defaultUrl = 'https://analyzer.on8ar.eu';
  static const _urlKey = 'notoryx_analyzer_url_v1';
  static const _hopKey = 'notoryx_analyzer_hop_lookup_v1';

  String _url = defaultUrl;
  bool _hopLookup = false;
  final Map<String, OnlineHop?> _hops = {};
  final Set<String> _pending = {};
  Timer? _batch;
  bool _disposed = false;

  String get url => _url;
  bool get hopLookup => _hopLookup;

  void load() {
    final prefs = PrefsManager.instance;
    _url = prefs.getString(_urlKey) ?? defaultUrl;
    _hopLookup = prefs.getBool(_hopKey) ?? false;
  }

  static bool isValidUrl(String url) {
    final u = Uri.tryParse(url.trim());
    return u != null && u.scheme == 'https' && u.host.isNotEmpty;
  }

  Future<void> setUrl(String url) async {
    _url = url.trim().replaceAll(RegExp(r'/+$'), '');
    _hops.clear();
    _notify();
    await PrefsManager.instance.setString(_urlKey, _url);
  }

  Future<void> setHopLookup(bool on) async {
    _hopLookup = on;
    _notify();
    await PrefsManager.instance.setBool(_hopKey, on);
  }

  Uri _api(String path, [Map<String, String>? query]) =>
      Uri.parse('$_url$path').replace(queryParameters: query);

  Future<Map<String, dynamic>?> _get(Uri uri) async {
    final client = _client();
    try {
      final res = await client
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 404) return const {};
      if (res.statusCode != 200) return null;
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    } finally {
      client.close();
    }
  }

  /// Observers that heard the packet with [hash]: empty when none has, null
  /// when the analyzer couldn't be reached.
  Future<List<ObserverHit>?> observersOf(String hash) async {
    final json = await _get(_api('/api/traces/${hash.toLowerCase()}'));
    return json == null ? null : parseTraces(json);
  }

  /// The hashtag channels the analyzer has seen in use, or null when it
  /// couldn't be reached.
  Future<List<ActiveChannel>?> activeChannels() async {
    final json = await _get(_api('/api/channels'));
    return json == null ? null : parseActiveChannels(json);
  }

  /// The online name for repeater [id] when hop lookup is on: the cached
  /// answer now, and a batched lookup in the background the first time.
  /// With [near] (your radio's position), only a repeater within range of
  /// it is named.
  OnlineHop? hopName(String id, {LatLng? near}) {
    if (!_hopLookup || id.isEmpty) return null;
    final key = id.toUpperCase();
    if (_hops.containsKey(key)) return _hops[key]?.from(near);
    if (_pending.add(key)) {
      _batch ??= Timer(const Duration(milliseconds: 400), _resolvePending);
    }
    return null;
  }

  Future<void> _resolvePending() async {
    _batch = null;
    final ids = _pending.toList();
    _pending.clear();
    if (ids.isEmpty || _disposed) return;
    final json = await _get(_api('/api/resolve-hops', {'hops': ids.join(',')}));
    if (json == null) return; // unreachable: try again next time it's asked
    final found = parseResolvedHops(json);
    for (final id in ids) {
      _hops[id] = found[id];
    }
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _batch?.cancel();
    super.dispose();
  }
}
