import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

/// When a zone alerts.
enum ZoneAlertOn {
  enter,
  leave,
  both;

  bool get onEnter => this != leave;
  bool get onLeave => this != enter;

  static ZoneAlertOn parse(Object? v) => ZoneAlertOn.values.firstWhere(
    (e) => e.name == v,
    orElse: () => ZoneAlertOn.both,
  );
}

/// Whose positions are watched.
enum WatchScope {
  /// Starred contacts only.
  favorites,

  /// Every chat node with a position.
  everyone;

  static WatchScope parse(Object? v) => WatchScope.values.firstWhere(
    (e) => e.name == v,
    orElse: () => WatchScope.favorites,
  );
}

/// A circle on the map that alerts when someone crosses its edge.
@immutable
class Zone {
  const Zone({
    required this.id,
    required this.name,
    required this.lat,
    required this.lon,
    required this.radiusMeters,
    this.alertOn = ZoneAlertOn.both,
  });

  final String id;
  final String name;
  final double lat;
  final double lon;
  final double radiusMeters;
  final ZoneAlertOn alertOn;

  LatLng get center => LatLng(lat, lon);

  /// Smallest and largest radius the screen offers.
  static const minRadius = 50.0;
  static const maxRadius = 10000.0;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'lat': lat,
    'lon': lon,
    'r': radiusMeters,
    'on': alertOn.name,
  };

  static Zone? fromJson(Object? j) {
    if (j is! Map) return null;
    final id = j['id'], name = j['name'], lat = j['lat'], lon = j['lon'];
    final r = j['r'];
    if (id is! String || name is! String) return null;
    if (lat is! num || lon is! num || r is! num) return null;
    if (lat.abs() > 90 || lon.abs() > 180 || r <= 0) return null;
    return Zone(
      id: id,
      name: name,
      lat: lat.toDouble(),
      lon: lon.toDouble(),
      radiusMeters: r.toDouble().clamp(minRadius, maxRadius),
      alertOn: ZoneAlertOn.parse(j['on']),
    );
  }
}

/// Someone whose position is being watched.
@immutable
class WatchedPosition {
  const WatchedPosition({
    required this.key,
    required this.name,
    required this.lat,
    required this.lon,
  });

  /// Stable id: a contact's public key hex, or [selfKey].
  final String key;
  final String name;
  final double lat;
  final double lon;

  static const selfKey = 'self';
}

enum PositionAlertKind { enteredZone, leftZone, offTrail }

/// Something worth a notification.
@immutable
class PositionAlert {
  const PositionAlert({
    required this.kind,
    required this.key,
    required this.name,
    this.zone,
    this.meters,
  });

  final PositionAlertKind kind;
  final String key;
  final String name;

  /// The zone, for zone alerts.
  final Zone? zone;

  /// How far off the trail, for [PositionAlertKind.offTrail].
  final double? meters;
}

const _earthRadius = 6371008.8;

double _rad(double deg) => deg * math.pi / 180;

/// Great-circle distance between two points, in metres.
double metersBetween(double lat1, double lon1, double lat2, double lon2) {
  final dLat = _rad(lat2 - lat1), dLon = _rad(lon2 - lon1);
  final a =
      math.pow(math.sin(dLat / 2), 2) +
      math.cos(_rad(lat1)) *
          math.cos(_rad(lat2)) *
          math.pow(math.sin(dLon / 2), 2);
  return 2 * _earthRadius * math.asin(math.min(1, math.sqrt(a)));
}

/// Shortest distance from ([lat], [lon]) to the line through [trail], in
/// metres. Each segment is flattened around the point, which is accurate
/// to well under a metre at trail scales. Null for an empty trail.
double? metersFromTrail(double lat, double lon, List<LatLng> trail) {
  if (trail.isEmpty) return null;
  if (trail.length == 1) {
    return metersBetween(lat, lon, trail[0].latitude, trail[0].longitude);
  }
  final k = math.cos(_rad(lat));
  // Local metres east/north of the point.
  ({double x, double y}) local(LatLng p) => (
    x: _rad(p.longitude - lon) * k * _earthRadius,
    y: _rad(p.latitude - lat) * _earthRadius,
  );
  var best = double.infinity;
  var a = local(trail[0]);
  for (var i = 1; i < trail.length; i++) {
    final b = local(trail[i]);
    final dx = b.x - a.x, dy = b.y - a.y;
    final len2 = dx * dx + dy * dy;
    var t = len2 == 0 ? 0.0 : -(a.x * dx + a.y * dy) / len2;
    t = t.clamp(0.0, 1.0);
    final px = a.x + t * dx, py = a.y + t * dy;
    best = math.min(best, math.sqrt(px * px + py * py));
    a = b;
  }
  return best;
}

/// Turns a stream of positions into zone and off-trail alerts.
///
/// The first position seen for someone only records where they are, so
/// opening the app inside a zone doesn't alert. Each edge has a little
/// slack, so a position wobbling on a boundary alerts once: leaving a
/// zone needs [zoneSlack] of its radius (at least 15 m) beyond the edge,
/// and coming back on trail needs to be within [backOnTrail] of the limit.
class PositionWatcher {
  PositionWatcher({this.zoneSlack = 0.1, this.backOnTrail = 0.7});

  final double zoneSlack;
  final double backOnTrail;

  final Map<String, Set<String>> _inside = {};
  final Map<String, bool> _offTrail = {};

  /// Forgets everyone; the next position for each only records.
  void reset() {
    _inside.clear();
    _offTrail.clear();
  }

  /// Forgets what's known about [zoneId], e.g. after it's moved or deleted.
  void forgetZone(String zoneId) {
    for (final s in _inside.values) {
      s.remove(zoneId);
    }
  }

  /// Forgets on/off-trail state, e.g. after the trail changes.
  void forgetTrail() => _offTrail.clear();

  List<PositionAlert> observe(
    Iterable<WatchedPosition> positions, {
    required List<Zone> zones,
    List<LatLng> trail = const [],
    double offTrailMeters = 100,
  }) {
    final alerts = <PositionAlert>[];
    for (final p in positions) {
      final known = _inside[p.key];
      final inside = <String>{};
      for (final z in zones) {
        final d = metersBetween(p.lat, p.lon, z.lat, z.lon);
        final wasIn = known?.contains(z.id) ?? false;
        final slack = math.max(15.0, z.radiusMeters * zoneSlack);
        final isIn = wasIn ? d <= z.radiusMeters + slack : d <= z.radiusMeters;
        if (isIn) inside.add(z.id);
        if (known == null || isIn == wasIn) continue;
        if (isIn && z.alertOn.onEnter) {
          alerts.add(
            PositionAlert(
              kind: PositionAlertKind.enteredZone,
              key: p.key,
              name: p.name,
              zone: z,
            ),
          );
        } else if (!isIn && z.alertOn.onLeave) {
          alerts.add(
            PositionAlert(
              kind: PositionAlertKind.leftZone,
              key: p.key,
              name: p.name,
              zone: z,
            ),
          );
        }
      }
      _inside[p.key] = inside;

      final d = metersFromTrail(p.lat, p.lon, trail);
      if (d == null) {
        _offTrail.remove(p.key);
        continue;
      }
      final was = _offTrail[p.key];
      final off = (was ?? false)
          ? d > offTrailMeters * backOnTrail
          : d > offTrailMeters;
      _offTrail[p.key] = off;
      if (was == false && off) {
        alerts.add(
          PositionAlert(
            kind: PositionAlertKind.offTrail,
            key: p.key,
            name: p.name,
            meters: d,
          ),
        );
      }
    }
    return alerts;
  }
}

/// A short distance for alerts and sliders: "120 m", "1.2 km", or in
/// imperial "390 ft", "1.1 mi".
String formatShortDistance(double meters, {bool imperial = false}) {
  if (imperial) {
    final feet = meters * 3.28084;
    if (feet < 1000) return '${feet.round()} ft';
    final miles = meters / 1609.344;
    return '${miles.toStringAsFixed(miles < 10 ? 1 : 0)} mi';
  }
  if (meters < 1000) return '${meters.round()} m';
  final km = meters / 1000;
  return '${km.toStringAsFixed(km < 10 ? 1 : 0)} km';
}
