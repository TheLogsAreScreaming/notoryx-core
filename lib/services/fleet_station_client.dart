import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/fleet.dart';

/// A repeater as a station lists it.
typedef StationRepeater = ({int id, String publicKeyHex, String name});

/// Reads a NOTORYX Ops station's fleet over its read-only HTTP API.
///
/// Only `GET /api/fleet` and `GET /api/fleet/{id}/history` are used; no
/// request carries a body, so no password can be sent.
class FleetStationClient {
  FleetStationClient(this.base, {http.Client? client})
    : _client = client ?? http.Client();

  static const defaultPort = 8484;
  static const _timeout = Duration(seconds: 10);

  final Uri base;
  final http.Client _client;

  /// Reads `host`, `host:port` or a full `http(s)://` address. Null when it
  /// isn't one.
  static Uri? parseAddress(String text) {
    var t = text.trim();
    if (t.isEmpty) return null;
    if (!t.contains('://')) t = 'http://$t';
    final uri = Uri.tryParse(t);
    if (uri == null || uri.host.isEmpty) return null;
    if (uri.scheme != 'http' && uri.scheme != 'https') return null;
    return Uri(
      scheme: uri.scheme,
      host: uri.host,
      port: uri.hasPort ? uri.port : defaultPort,
    );
  }

  Future<Object?> _get(String path, [Map<String, String>? query]) async {
    final res = await _client
        .get(base.replace(path: path, queryParameters: query))
        .timeout(_timeout);
    if (res.statusCode != 200) {
      throw FleetStationException(res.statusCode);
    }
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  Future<List<StationRepeater>> fleet() async {
    final data = await _get('/api/fleet');
    if (data is! List) throw const FleetStationException(0);
    return [
      for (final r in data)
        if (r case {
          'id': final int id,
          'public_key': final String key,
          'name': final String name,
        } when FleetRepeater.isValidKey(key))
          (id: id, publicKeyHex: key.toLowerCase(), name: name),
    ];
  }

  Future<List<FleetSample>> history(int id, {int days = 7}) async {
    final data = await _get('/api/fleet/$id/history', {'days': '$days'});
    if (data is! List) throw const FleetStationException(0);
    return [for (final row in data) ?sampleFromStation(row)];
  }

  void close() => _client.close();
}

/// One station history row as a [FleetSample], or null.
FleetSample? sampleFromStation(Object? row) {
  if (row is! Map) return null;
  final at = row['polled_at'];
  if (at is! num) return null;
  int? i(Object? v) => v is num ? v.toInt() : null;
  final snr = row['last_snr'];
  final nb = row['neighbours'];
  final error = row['error'];
  final fw = row['firmware'];
  return FleetSample(
    at: DateTime.fromMillisecondsSinceEpoch((at * 1000).round()),
    ok: row['ok'] == 1 || row['ok'] == true,
    source: FleetSource.station,
    error: error is String ? 'station' : null,
    batteryMv: i(row['battery_mv']),
    noiseFloor: i(row['noise_floor']),
    lastRssi: i(row['last_rssi']),
    lastSnr: snr is num ? snr.toDouble() : null,
    uptimeSecs: i(row['uptime_s']),
    firmware: fw is String ? fw : null,
    neighbours: nb is List ? nb.length : null,
  );
}

class FleetStationException implements Exception {
  const FleetStationException(this.statusCode);
  final int statusCode;

  @override
  String toString() => 'FleetStationException($statusCode)';
}
