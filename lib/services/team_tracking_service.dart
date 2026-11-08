import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../connector/meshcore_connector.dart';
import '../models/channel.dart';

/// The rules for when to post a position, kept apart for tests.
class TeamTrackingPolicy {
  const TeamTrackingPolicy();

  /// Allowed intervals in minutes; the floor is 10.
  static const intervals = [10, 15, 30, 60];

  /// Tracking turns itself off after this long, trip or not.
  static const maxRun = Duration(hours: 12);

  /// Moving less than this since the last post doesn't need a new one...
  static const minMoveMetres = 25.0;

  /// ...unless this many intervals have passed, so the team knows you're
  /// still there.
  static const heartbeatIntervals = 3;

  /// Whether to post now.
  bool shouldPost({
    required DateTime now,
    required DateTime? lastPostAt,
    required ({double lat, double lon})? lastPosition,
    required ({double lat, double lon}) position,
    required Duration interval,
  }) {
    if (lastPostAt == null || lastPosition == null) return true;
    final since = now.difference(lastPostAt);
    if (since < interval) return false;
    if (since >= interval * heartbeatIntervals) return true;
    return distanceMetres(lastPosition, position) >= minMoveMetres;
  }
}

double distanceMetres(
  ({double lat, double lon}) a,
  ({double lat, double lon}) b,
) {
  const r = 6371000.0;
  double rad(double d) => d * math.pi / 180;
  final dLat = rad(b.lat - a.lat), dLon = rad(b.lon - a.lon);
  final h =
      math.pow(math.sin(dLat / 2), 2) +
      math.cos(rad(a.lat)) *
          math.cos(rad(b.lat)) *
          math.pow(math.sin(dLon / 2), 2);
  return 2 * r * math.asin(math.min(1, math.sqrt(h)));
}

/// The marker text teammates' maps already understand, flagged `t` for a
/// tracked position so each person's posts draw as one trail.
String trackingMarkerText(String name, double lat, double lon) =>
    'm:${lat.toStringAsFixed(5)},${lon.toStringAsFixed(5)}|'
    '${name.replaceAll('|', '/')}|t';

/// Shares this radio's position to a private channel on a timer during a
/// trip. Opt-in for each trip, never on a public or hashtag channel, at
/// most every 10 minutes, and off when the trip ends or after 12 hours.
class TeamTrackingService extends ChangeNotifier {
  TeamTrackingService({
    required this.connector,
    required this.trip,
    required this.tripActive,
    required this.prefs,
    this.policy = const TeamTrackingPolicy(),
    DateTime Function()? clock,
    Duration tick = const Duration(minutes: 1),
  }) : _now = clock ?? DateTime.now {
    final saved = prefs.getInt(_intervalKey);
    if (saved != null && TeamTrackingPolicy.intervals.contains(saved)) {
      _minutes = saved;
    }
    trip.addListener(_tripChanged);
    _timer = Timer.periodic(tick, (_) => unawaited(tickNow()));
  }

  final MeshCoreConnector connector;

  /// Notifies when the trip changes (the Field Ops service).
  final Listenable trip;

  /// Whether a trip is active now.
  final bool Function() tripActive;
  final SharedPreferences prefs;
  final TeamTrackingPolicy policy;
  final DateTime Function() _now;
  Timer? _timer;

  static const _intervalKey = 'team_tracking_minutes';

  bool _enabled = false;
  int? _channelIndex;
  int _minutes = 15;
  DateTime? _startedAt;
  DateTime? _lastPostAt;
  ({double lat, double lon})? _lastPosition;

  bool get enabled => _enabled;
  int? get channelIndex => _channelIndex;
  int get minutes => _minutes;
  DateTime? get lastPostAt => _lastPostAt;

  /// Channels tracking may use: private ones only.
  List<Channel> get eligibleChannels => [
    for (final c in connector.channels)
      if (!c.isEmpty && c.isPrivateChannel) c,
  ];

  /// Turns tracking on for the current trip, posting to [channelIndex].
  /// Does nothing without an active trip or with a channel that isn't
  /// private.
  Future<void> start(int channelIndex) async {
    if (!tripActive()) return;
    if (!eligibleChannels.any((c) => c.index == channelIndex)) return;
    _enabled = true;
    _channelIndex = channelIndex;
    _startedAt = _now();
    _lastPostAt = null;
    _lastPosition = null;
    notifyListeners();
    await tickNow();
  }

  /// Chooses the channel for the next [start], without starting.
  void selectChannel(int channelIndex) {
    if (_enabled) return;
    if (!eligibleChannels.any((c) => c.index == channelIndex)) return;
    _channelIndex = channelIndex;
    notifyListeners();
  }

  void stop() {
    if (!_enabled) return;
    _enabled = false;
    _startedAt = null;
    notifyListeners();
  }

  Future<void> setMinutes(int minutes) async {
    if (!TeamTrackingPolicy.intervals.contains(minutes)) return;
    _minutes = minutes;
    notifyListeners();
    await prefs.setInt(_intervalKey, minutes);
  }

  void _tripChanged() {
    if (_enabled && !tripActive()) stop();
  }

  /// Posts if a post is due.
  @visibleForTesting
  Future<void> tickNow() async {
    if (!_enabled) return;
    final now = _now();
    if (!tripActive() ||
        (_startedAt != null &&
            now.difference(_startedAt!) >= TeamTrackingPolicy.maxRun)) {
      stop();
      return;
    }
    if (!connector.isConnected) return;
    final lat = connector.selfLatitude, lon = connector.selfLongitude;
    if (lat == null || lon == null || (lat == 0 && lon == 0)) return;
    final channel = eligibleChannels
        .where((c) => c.index == _channelIndex)
        .firstOrNull;
    if (channel == null) {
      stop();
      return;
    }
    final position = (lat: lat, lon: lon);
    if (!policy.shouldPost(
      now: now,
      lastPostAt: _lastPostAt,
      lastPosition: _lastPosition,
      position: position,
      interval: Duration(minutes: _minutes),
    )) {
      return;
    }
    _lastPostAt = now;
    _lastPosition = position;
    notifyListeners();
    await connector.sendChannelMessage(
      channel,
      trackingMarkerText(connector.selfName ?? 'NOTORYX', lat, lon),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    trip.removeListener(_tripChanged);
    super.dispose();
  }
}
