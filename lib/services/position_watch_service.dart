import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../connector/meshcore_connector.dart';
import '../connector/meshcore_protocol.dart';
import '../models/position_watch.dart';
import '../storage/secure_prefs.dart';
import '../utils/app_logger.dart';

/// A trail that can be watched: a saved waypoint route or a recorded track.
@immutable
class TrailOption {
  const TrailOption({
    required this.ref,
    required this.name,
    required this.points,
  });

  /// `route:<id>` or `track:<id>`.
  final String ref;
  final String name;
  final List<LatLng> points;
}

/// Zone alerts and off-trail alerts, from the positions your radio hears.
///
/// Watches your own radio and either your favourites or every chat node.
/// Positions come from adverts, so an alert is only as fresh as the last
/// advert heard. Settings and zones are kept on this device only.
class PositionWatchService extends ChangeNotifier {
  PositionWatchService(
    this.connector, {
    required this.prefs,
    required this.trails,
    required this.notify,
    required this.selfName,
    PositionWatcher? watcher,
  }) : _watcher = watcher ?? PositionWatcher() {
    _load();
    connector.addListener(_changed);
  }

  final MeshCoreConnector connector;
  final SharedPreferences prefs;

  /// Every trail that can be watched right now.
  final List<TrailOption> Function() trails;
  final Future<void> Function(PositionAlert alert) notify;

  /// Name used for your own radio in alerts.
  final String Function() selfName;
  final PositionWatcher _watcher;

  static const _key = 'position_watch_v1';
  static const maxZones = 50;
  static const defaultOffTrailMeters = 100.0;

  final List<Zone> _zones = [];
  bool _enabled = false;
  WatchScope _scope = WatchScope.favorites;
  bool _includeSelf = true;
  String? _trailRef;
  double _offTrailMeters = defaultOffTrailMeters;
  bool _connected = false;
  bool _synced = false;

  List<Zone> get zones => List.unmodifiable(_zones);

  /// Master switch; nothing alerts while off.
  bool get enabled => _enabled;
  WatchScope get scope => _scope;
  bool get includeSelf => _includeSelf;

  /// The watched trail's ref, or null for none.
  String? get trailRef => _trailRef;
  double get offTrailMeters => _offTrailMeters;

  /// The watched trail, or null when none is set or it was deleted.
  TrailOption? get trail {
    final ref = _trailRef;
    if (ref == null) return null;
    for (final t in trails()) {
      if (t.ref == ref) return t;
    }
    return null;
  }

  void _load() {
    try {
      final raw = SecurePrefs.isActive
          ? SecurePrefs.getString(_key)
          : prefs.getString(_key);
      if (raw == null) return;
      final j = jsonDecode(raw);
      if (j is! Map) return;
      _enabled = j['enabled'] == true;
      _scope = WatchScope.parse(j['scope']);
      _includeSelf = j['self'] != false;
      final trail = j['trail'];
      _trailRef = trail is String ? trail : null;
      final m = j['offTrail'];
      if (m is num && m > 0) _offTrailMeters = m.toDouble();
      for (final z in j['zones'] as List? ?? const []) {
        if (Zone.fromJson(z) case final zone?) _zones.add(zone);
      }
    } catch (e) {
      appLogger.warn('Cannot load zone alerts: $e');
    }
  }

  Future<void> _save() async {
    notifyListeners();
    final encoded = jsonEncode({
      'enabled': _enabled,
      'scope': _scope.name,
      'self': _includeSelf,
      'trail': _trailRef,
      'offTrail': _offTrailMeters,
      'zones': [for (final z in _zones) z.toJson()],
    });
    if (SecurePrefs.isActive) {
      await SecurePrefs.setString(_key, encoded);
    } else {
      await prefs.setString(_key, encoded);
    }
  }

  Future<void> setEnabled(bool on) async {
    _enabled = on;
    _watcher.reset();
    await _save();
    _changed();
  }

  Future<void> setScope(WatchScope scope) async {
    _scope = scope;
    await _save();
  }

  Future<void> setIncludeSelf(bool on) async {
    _includeSelf = on;
    await _save();
  }

  Future<void> setTrail(String? ref) async {
    _trailRef = ref;
    _watcher.forgetTrail();
    await _save();
    _changed();
  }

  Future<void> setOffTrailMeters(double meters) async {
    _offTrailMeters = meters;
    _watcher.forgetTrail();
    await _save();
  }

  /// Adds or replaces [zone] (same id). Returns false when full.
  Future<bool> saveZone(Zone zone) async {
    final i = _zones.indexWhere((z) => z.id == zone.id);
    if (i >= 0) {
      _zones[i] = zone;
    } else {
      if (_zones.length >= maxZones) return false;
      _zones.add(zone);
    }
    _watcher.forgetZone(zone.id);
    await _save();
    _changed();
    return true;
  }

  Future<void> deleteZone(String id) async {
    _zones.removeWhere((z) => z.id == id);
    _watcher.forgetZone(id);
    await _save();
  }

  /// Everyone being watched who has a position now.
  List<WatchedPosition> watchedPositions() {
    final out = <WatchedPosition>[];
    final lat = connector.selfLatitude, lon = connector.selfLongitude;
    if (_includeSelf && lat != null && lon != null && !(lat == 0 && lon == 0)) {
      out.add(
        WatchedPosition(
          key: WatchedPosition.selfKey,
          name: selfName(),
          lat: lat,
          lon: lon,
        ),
      );
    }
    for (final c in connector.contacts) {
      if (c.type != advTypeChat || !c.hasLocation) continue;
      if (_scope == WatchScope.favorites && !c.isFavorite) continue;
      out.add(
        WatchedPosition(
          key: c.publicKeyHex,
          name: c.name,
          lat: c.latitude!,
          lon: c.longitude!,
        ),
      );
    }
    return out;
  }

  void _changed() {
    final connected = connector.isConnected;
    if (connected != _connected) {
      _connected = connected;
      _synced = false;
      _watcher.reset();
    }
    if (!connected || !_enabled) return;
    if (_zones.isEmpty && _trailRef == null) return;
    // The first contact sync after connecting is only a baseline.
    if (!_synced && connector.isLoadingContacts) return;
    final alerts = _watcher.observe(
      watchedPositions(),
      zones: _zones,
      trail: trail?.points ?? const [],
      offTrailMeters: _offTrailMeters,
    );
    _synced = true;
    for (final a in alerts) {
      unawaited(notify(a));
    }
  }

  @override
  void dispose() {
    connector.removeListener(_changed);
    super.dispose();
  }
}
