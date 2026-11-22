import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter/foundation.dart';

import '../connector/meshcore_connector.dart';
import '../connector/meshcore_protocol.dart';
import '../models/channel.dart';
import '../models/radio_rx_packet.dart';
import '../models/wardrive.dart';
import '../models/wardrive_grid.dart';
import 'coverage_hex_service.dart' show PositionFix, geolocatorFixes;
import 'trace_pinger.dart';
import '../storage/prefs_manager.dart';

/// Why the last timed ping wasn't sent, for the screen to word.
enum WardriveWait {
  none,
  noRadio,
  noPosition,

  /// Channel mode, but the radio has no wardriving channel.
  noChannel,

  /// Trace mode, but no repeater is chosen.
  noTraceTarget,

  /// You haven't moved far enough since the last ping.
  notMoved,

  /// This square already has recent coverage.
  covered,
}

/// What a timed ping sends.
enum WardriveMode {
  /// Zero-hop discover requests: repeaters in range answer. The default.
  discovery,

  /// Zero-hop traces to one chosen repeater, measured both ways.
  trace,

  /// Messages to the wardriving channel. Repeaters that pass one on count,
  /// which shows you reach the wider mesh, but every ping is flooded.
  channel,

  /// Discovery and channel pings in turn.
  hybrid;

  static WardriveMode fromName(String? name) =>
      values.firstWhere((m) => m.name == name, orElse: () => discovery);
}

/// Wardrive settings, kept between drives.
@immutable
class WardriveSettings {
  const WardriveSettings({
    this.mode = WardriveMode.discovery,
    this.intervalSeconds = 30,
    this.waitForMove = true,
    this.skipCovered = true,
    this.skipDays = 14,
    this.passive = true,
    this.ignoreStrong = true,
    this.carRepeater,
    this.traceTarget,
    this.background = false,
    this.recordNoise = true,
  });

  final WardriveMode mode;
  final int intervalSeconds;

  /// Hold timed pings until you've moved [WardriveService.minMoveMetres].
  final bool waitForMove;

  /// Hold timed pings in squares heard from in the last [skipDays] days.
  final bool skipCovered;
  final int skipDays;

  /// Log traffic the radio hears, with your position. No airtime.
  final bool passive;

  /// Ignore repeaters heard at [WardriveService.strongRssi] or stronger:
  /// they're beside you (a repeater in your car), not coverage.
  final bool ignoreStrong;

  /// Key prefix (hex) of your own car repeater, always ignored.
  final String? carRepeater;

  /// Key prefix (hex, at least 4 bytes) of the repeater Trace mode pings.
  final String? traceTarget;

  /// Keep GPS running with the screen off (Android shows a notification).
  final bool background;

  /// Sample the radio's noise floor during a drive.
  final bool recordNoise;

  WardriveSettings copyWith({
    WardriveMode? mode,
    int? intervalSeconds,
    bool? waitForMove,
    bool? skipCovered,
    int? skipDays,
    bool? passive,
    bool? ignoreStrong,
    String? carRepeater,
    bool clearCarRepeater = false,
    String? traceTarget,
    bool clearTraceTarget = false,
    bool? background,
    bool? recordNoise,
  }) => WardriveSettings(
    mode: mode ?? this.mode,
    intervalSeconds: intervalSeconds ?? this.intervalSeconds,
    waitForMove: waitForMove ?? this.waitForMove,
    skipCovered: skipCovered ?? this.skipCovered,
    skipDays: skipDays ?? this.skipDays,
    passive: passive ?? this.passive,
    ignoreStrong: ignoreStrong ?? this.ignoreStrong,
    carRepeater: clearCarRepeater ? null : carRepeater ?? this.carRepeater,
    traceTarget: clearTraceTarget ? null : traceTarget ?? this.traceTarget,
    background: background ?? this.background,
    recordNoise: recordNoise ?? this.recordNoise,
  );

  Map<String, dynamic> toJson() => {
    'mode': mode.name,
    'interval': intervalSeconds,
    'waitForMove': waitForMove,
    'skipCovered': skipCovered,
    'skipDays': skipDays,
    'passive': passive,
    'ignoreStrong': ignoreStrong,
    if (carRepeater != null) 'carRepeater': carRepeater,
    if (traceTarget != null) 'traceTarget': traceTarget,
    'background': background,
    'recordNoise': recordNoise,
  };

  factory WardriveSettings.fromJson(Map<String, dynamic> j) {
    const d = WardriveSettings();
    return WardriveSettings(
      mode: WardriveMode.fromName(j['mode'] as String?),
      intervalSeconds: (j['interval'] as num?)?.toInt() ?? d.intervalSeconds,
      waitForMove: j['waitForMove'] as bool? ?? d.waitForMove,
      skipCovered: j['skipCovered'] as bool? ?? d.skipCovered,
      skipDays: ((j['skipDays'] as num?)?.toInt() ?? d.skipDays).clamp(1, 365),
      passive: j['passive'] as bool? ?? d.passive,
      ignoreStrong: j['ignoreStrong'] as bool? ?? d.ignoreStrong,
      carRepeater: j['carRepeater'] as String?,
      traceTarget: j['traceTarget'] as String?,
      background: j['background'] as bool? ?? d.background,
      recordNoise: j['recordNoise'] as bool? ?? d.recordNoise,
    );
  }
}

/// Drives a wardrive. Every [WardriveSettings.intervalSeconds] it sends a
/// ping from where you are, in the chosen [WardriveMode], and records which
/// repeaters answered and how well. Discovery and trace pings are zero-hop,
/// so they only use airtime where you are; channel pings are flooded and
/// are off unless you pick them. While a drive runs it can also log traffic
/// the radio hears anyway (passive), which costs no airtime at all.
///
/// Timed pings wait until you've moved, and skip squares that already have
/// recent coverage; a ping you ask for by hand always goes out.
///
/// The position comes from the phone's GPS while a session runs. The radio
/// only reports its own position when the app connects, so on its own it
/// would pin every ping to the spot you started from. Its position is the
/// fallback when the phone has no fix.
class WardriveService extends ChangeNotifier {
  WardriveService(
    this.connector, {
    this.listenWindow = const Duration(seconds: 6),
    DateTime Function()? clock,
    math.Random? random,
    Stream<PositionFix> Function()? fixes,
    Stream<PositionFix> Function()? backgroundFixes,
    TracePinger? tracePinger,
  }) : _now = clock ?? DateTime.now,
       _random = random ?? math.Random(),
       _fixes = fixes ?? geolocatorFixes,
       _backgroundFixes =
           backgroundFixes ??
           fixes ??
           (() => geolocatorFixes(background: true)),
       _tracer = tracePinger ?? TracePinger(connector);

  final MeshCoreConnector connector;
  final Duration listenWindow;
  final DateTime Function() _now;
  final math.Random _random;
  final Stream<PositionFix> Function() _fixes;
  final Stream<PositionFix> Function() _backgroundFixes;
  final TracePinger _tracer;

  /// A phone fix older than this is not trusted for a ping.
  static const fixMaxAge = Duration(minutes: 2);

  /// Timed pings wait until you've moved this far since the last one.
  static const minMoveMetres = 25.0;

  /// Size of the squares used to decide what's already covered.
  static const coverSquareMetres = 300;

  /// Repeaters heard this strongly are beside you, not coverage.
  static const strongRssi = -30;

  /// The channel channel-mode pings go to.
  static const channelName = '#wardriving';

  /// What a channel ping says. No position goes on the air.
  static const channelText = 'wardrive ping';

  static const _key = 'notoryx_wardrive_sessions_v1';
  static const _settingsKey = 'notoryx_wardrive_settings_v1';
  static const maxSessions = 20;
  static const maxPings = 2000;
  static const maxPassive = 3000;
  static const maxNoise = 2000;
  static const noiseEvery = Duration(seconds: 10);

  /// Ping intervals to choose from, in seconds. 20 s is the floor: a busy
  /// mesh shouldn't be pinged faster than that.
  static const intervals = [20, 30, 60, 120];

  List<WardriveSession> _sessions = const [];
  WardriveSession? _active;
  WardriveSettings _settings = const WardriveSettings();
  Timer? _timer;
  Timer? _noiseTimer;
  bool _pinging = false;
  WardriveWait _wait = WardriveWait.none;
  bool _disposed = false;
  StreamSubscription<PositionFix>? _fixSub;
  StreamSubscription<RadioRxPacket>? _rxSub;
  VoidCallback? _statsListener;
  PositionFix? _fix;
  DateTime? _fixAt;
  int? _noise;
  ({double lat, double lon})? _lastSent;
  ({double lat, double lon})? _lastSkipMark;
  bool _nextHybridIsChannel = false;
  final Set<String> _passiveSeen = {};
  Set<GridSquare> _covered = {};

  /// Finished sessions, newest first.
  List<WardriveSession> get sessions => _sessions;
  WardriveSession? get active => _active;
  WardriveSettings get settings => _settings;
  bool get running => _active != null;
  bool get pinging => _pinging;
  Duration get interval => Duration(seconds: _settings.intervalSeconds);
  WardriveWait get wait => _wait;

  /// The latest noise floor reading (dBm), when recording it.
  int? get noiseFloor => _noise;

  /// Accuracy (m) of the phone's current fix; null without one.
  double? get accuracy {
    final fix = _fix, at = _fixAt;
    if (fix == null || at == null || _now().difference(at) > fixMaxAge) {
      return null;
    }
    return fix.accuracyMeters;
  }

  /// Where you are now, for the map to follow: the phone's latest fix, or
  /// the radio's position. Null when neither is known.
  ({double lat, double lon})? get position {
    final fix = _fix, at = _fixAt;
    if (fix != null && at != null && _now().difference(at) <= fixMaxAge) {
      return (lat: fix.lat, lon: fix.lon);
    }
    final lat = connector.selfLatitude, lon = connector.selfLongitude;
    if (lat == null || lon == null || (lat == 0 && lon == 0)) return null;
    return (lat: lat, lon: lon);
  }

  /// The radio's wardriving channel, if it has one.
  Channel? get wardriveChannel {
    for (final c in connector.channels) {
      if (c.name.trim().toLowerCase() == channelName) return c;
    }
    return null;
  }

  void load() {
    try {
      final raw = PrefsManager.instance.getString(_key);
      if (raw != null) {
        _sessions = [
          for (final s in jsonDecode(raw) as List)
            WardriveSession.fromJson(Map<String, dynamic>.from(s as Map)),
        ];
      }
    } catch (_) {
      _sessions = const [];
    }
    try {
      final raw = PrefsManager.instance.getString(_settingsKey);
      if (raw != null) {
        _settings = WardriveSettings.fromJson(
          Map<String, dynamic>.from(jsonDecode(raw) as Map),
        );
      }
    } catch (_) {
      _settings = const WardriveSettings();
    }
  }

  void setInterval(int seconds) =>
      update(_settings.copyWith(intervalSeconds: seconds));

  /// Changes the settings. A running drive picks them up straight away.
  void update(WardriveSettings next) {
    final old = _settings;
    _settings = next.copyWith(
      intervalSeconds: math.max(intervals.first, next.intervalSeconds),
    );
    unawaited(
      PrefsManager.instance.setString(
        _settingsKey,
        jsonEncode(_settings.toJson()),
      ),
    );
    if (running) {
      if (old.intervalSeconds != _settings.intervalSeconds) _schedule();
      if (old.background != _settings.background) _watchPosition();
      if (old.passive != _settings.passive) _listenPassive();
      if (old.recordNoise != _settings.recordNoise) _recordNoise();
      if (old.skipDays != _settings.skipDays) _covered = _coveredSquares();
    }
    _notify();
  }

  /// Starts a session and sends the first ping straight away.
  Future<void> start() async {
    if (running) return;
    _active = WardriveSession(
      id: '${_now().microsecondsSinceEpoch}',
      startedAt: _now(),
    );
    _lastSent = null;
    _lastSkipMark = null;
    _passiveSeen.clear();
    _covered = _coveredSquares();
    _watchPosition();
    _listenPassive();
    _recordNoise();
    _schedule();
    _notify();
    await pingNow();
  }

  /// Ends the session and keeps it in the history (if it has any pings).
  Future<void> stop() async {
    final session = _active;
    if (session == null) return;
    _timer?.cancel();
    _timer = null;
    _stopWatchingPosition();
    _stopPassive();
    _stopNoise();
    _active = null;
    _wait = WardriveWait.none;
    if (session.pings.isNotEmpty) {
      _sessions = [
        session.copyWith(endedAt: _now()),
        ..._sessions,
      ].take(maxSessions).toList();
      await _save();
    }
    _notify();
  }

  Future<void> deleteSession(String id) async {
    _sessions = _sessions.where((s) => s.id != id).toList();
    await _save();
    _notify();
  }

  /// Squares heard from (by a sent ping) in the last [skipDays] days.
  Set<GridSquare> _coveredSquares() {
    final since = _now().subtract(Duration(days: _settings.skipDays));
    return {
      for (final s in _sessions)
        for (final p in s.pings)
          if (p.sent && p.heard && p.at.isAfter(since))
            GridSquare.at(p.latitude, p.longitude, coverSquareMetres),
    };
  }

  void _watchPosition() {
    _fixSub?.cancel();
    try {
      final source = _settings.background ? _backgroundFixes : _fixes;
      _fixSub = source().listen(
        (fix) {
          _fix = fix;
          _fixAt = _now();
          _notify();
        },
        // No permission or no GPS: the radio's position is used instead.
        onError: (Object _) {},
        cancelOnError: true,
      );
    } catch (_) {
      _fixSub = null;
    }
  }

  void _stopWatchingPosition() {
    unawaited(_fixSub?.cancel());
    _fixSub = null;
    _fix = null;
    _fixAt = null;
  }

  void _schedule() {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => unawaited(_timedPing()));
  }

  // ---- filters -------------------------------------------------------------

  /// Whether a repeater heard with [prefix] at [rssi] should be left out: your
  /// own car repeater, or anything so strong it must be beside you.
  bool _ignored(String prefix, int? rssi) {
    final car = _settings.carRepeater;
    if (car != null && WardriveReply(prefix: prefix).matches(car)) return true;
    if (_settings.ignoreStrong && rssi != null && rssi >= strongRssi) {
      return true;
    }
    return false;
  }

  // ---- passive -------------------------------------------------------------

  void _listenPassive() {
    _stopPassive();
    if (!_settings.passive) return;
    _rxSub = connector.rxPackets.listen(_onPassive);
  }

  void _stopPassive() {
    unawaited(_rxSub?.cancel());
    _rxSub = null;
  }

  void _onPassive(RadioRxPacket packet) {
    final session = _active;
    if (session == null || packet.fromSelf) return;
    final prefix = directlyHeardRepeater(packet.raw);
    if (prefix == null || _ignored(prefix, packet.rssi)) return;
    final here = position;
    if (here == null) return;
    // One point per repeater per 100 m square: enough to map it, without a
    // point for every packet on a busy mesh.
    final seenKey = '${GridSquare.at(here.lat, here.lon, 100).id}/$prefix';
    if (!_passiveSeen.add(seenKey)) return;
    final passiveCount = session.pings
        .where((p) => p.kind == WardriveKind.passive)
        .length;
    if (passiveCount >= maxPassive) return;
    _add(
      WardrivePing(
        at: _now(),
        latitude: here.lat,
        longitude: here.lon,
        kind: WardriveKind.passive,
        accuracy: accuracy,
        noiseFloor: _noise,
        replies: [
          WardriveReply(
            prefix: prefix,
            snrHere: packet.snr,
            rssiHere: packet.rssi,
          ),
        ],
      ),
    );
  }

  // ---- noise floor ---------------------------------------------------------

  void _recordNoise() {
    _stopNoise();
    if (!_settings.recordNoise) return;
    void sample() {
      final dbm = connector.radioStatsNotifier.value?.noiseFloorDbm;
      final session = _active;
      if (dbm == null || session == null) return;
      _noise = dbm;
      final noise = session.noise;
      if (noise.isNotEmpty &&
          _now().difference(noise.last.at) < const Duration(seconds: 5)) {
        return;
      }
      final next = [...noise, NoiseSample(_now(), dbm)];
      _active = session.copyWith(
        noise: next.length > maxNoise
            ? next.sublist(next.length - maxNoise)
            : next,
      );
      _notify();
    }

    _statsListener = sample;
    connector.radioStatsNotifier.addListener(sample);
    if (connector.isConnected) unawaited(connector.requestRadioStats());
    _noiseTimer = Timer.periodic(noiseEvery, (_) {
      if (connector.isConnected) unawaited(connector.requestRadioStats());
    });
  }

  void _stopNoise() {
    _noiseTimer?.cancel();
    _noiseTimer = null;
    final l = _statsListener;
    if (l != null) connector.radioStatsNotifier.removeListener(l);
    _statsListener = null;
    _noise = null;
  }

  // ---- pinging -------------------------------------------------------------

  /// Runs what the timer runs, for tests.
  @visibleForTesting
  Future<void> debugTimedPing() => _timedPing();

  /// A timed ping: held while you haven't moved, or the square is covered.
  Future<void> _timedPing() async {
    if (_active == null || _pinging) return;
    final here = position;
    if (here != null) {
      final last = _lastSent;
      if (_settings.waitForMove &&
          last != null &&
          metresBetween(last.lat, last.lon, here.lat, here.lon) <
              minMoveMetres) {
        _wait = WardriveWait.notMoved;
        _notify();
        return;
      }
      if (_settings.skipCovered &&
          _covered.contains(
            GridSquare.at(here.lat, here.lon, coverSquareMetres),
          )) {
        _markSkipped(here);
        _wait = WardriveWait.covered;
        _notify();
        return;
      }
    }
    await pingNow();
  }

  /// Leaves a "skipped" marker, at most one per [minMoveMetres] of travel.
  void _markSkipped(({double lat, double lon}) here) {
    final last = _lastSkipMark;
    if (last != null &&
        metresBetween(last.lat, last.lon, here.lat, here.lon) < minMoveMetres) {
      return;
    }
    _lastSkipMark = here;
    _add(
      WardrivePing(
        at: _now(),
        latitude: here.lat,
        longitude: here.lon,
        kind: WardriveKind.skipped,
        accuracy: accuracy,
      ),
    );
  }

  /// Sends one ping in the chosen mode from where you are, if it can. A ping
  /// asked for by hand always goes out; only timed ones are held back.
  Future<void> pingNow() async {
    if (_active == null || _pinging) return;
    if (!connector.isConnected) {
      _wait = WardriveWait.noRadio;
      _notify();
      return;
    }
    final here = position;
    if (here == null) {
      _wait = WardriveWait.noPosition;
      _notify();
      return;
    }
    final kind = _nextKind();
    if (kind == null) return; // _wait already says why
    _wait = WardriveWait.none;
    _pinging = true;
    _notify();
    final at = _now();
    final acc = accuracy;
    List<WardriveReply> replies;
    try {
      replies = switch (kind) {
        WardriveKind.trace => await _trace(),
        WardriveKind.channel => await _channel(),
        _ => await _discover(),
      };
    } catch (_) {
      // A failed send still records the spot, as unheard.
      replies = const [];
    } finally {
      _pinging = false;
    }
    if (_active == null || _disposed) return;
    _lastSent = here;
    final kept = [
      for (final r in replies)
        if (!_ignored(r.prefix, r.rssiHere)) r,
    ];
    if (kept.isNotEmpty) {
      _covered.add(GridSquare.at(here.lat, here.lon, coverSquareMetres));
    }
    _add(
      WardrivePing(
        at: at,
        latitude: here.lat,
        longitude: here.lon,
        replies: kept,
        kind: kind,
        accuracy: acc,
        noiseFloor: _noise,
      ),
    );
  }

  /// The kind of ping the mode calls for now, or null (with [_wait] set)
  /// when that mode can't ping.
  WardriveKind? _nextKind() {
    switch (_settings.mode) {
      case WardriveMode.discovery:
        return WardriveKind.discovery;
      case WardriveMode.trace:
        final target = _settings.traceTarget;
        if (target == null || target.length < 8) {
          _wait = WardriveWait.noTraceTarget;
          _notify();
          return null;
        }
        return WardriveKind.trace;
      case WardriveMode.channel:
        if (wardriveChannel == null) {
          _wait = WardriveWait.noChannel;
          _notify();
          return null;
        }
        return WardriveKind.channel;
      case WardriveMode.hybrid:
        final channel = _nextHybridIsChannel && wardriveChannel != null;
        _nextHybridIsChannel = !_nextHybridIsChannel;
        return channel ? WardriveKind.channel : WardriveKind.discovery;
    }
  }

  Future<List<WardriveReply>> _discover() async {
    final tag = _random.nextInt(0x7FFFFFFF);
    final replies = <String, WardriveReply>{};
    final sub = connector.receivedFrames.listen((frame) {
      final reply = parseDiscoverReply(frame, tag);
      if (reply != null) replies.putIfAbsent(reply.prefix, () => reply);
    });
    try {
      await connector.sendFrame(
        buildSendControlDataFrame(
          buildDiscoveryRequestPayload(tag, prefixOnly: true),
        ),
      );
      await Future<void>.delayed(listenWindow);
    } finally {
      await sub.cancel();
    }
    return replies.values.toList();
  }

  Future<List<WardriveReply>> _trace() async {
    final target = _settings.traceTarget!;
    final key = Uint8List.fromList([
      for (var i = 0; i + 1 < target.length && i < 8; i += 2)
        int.parse(target.substring(i, i + 2), radix: 16),
    ]);
    final result = await _tracer.ping(key, timeout: listenWindow);
    if (result == null) return const [];
    return [
      WardriveReply(
        prefix: target.substring(0, 8).toLowerCase(),
        snrThere: result.snrThere,
        snrHere: result.snrBack,
      ),
    ];
  }

  /// Posts to the wardriving channel and records the repeaters that pass it
  /// on: the first hop of each repeat the radio hears. How well we heard it
  /// is only known when that repeat came straight from the first hop.
  Future<List<WardriveReply>> _channel() async {
    final channel = wardriveChannel!;
    final hash = crypto.sha256.convert(channel.psk).bytes[0];
    final replies = <String, WardriveReply>{};
    final sub = connector.rxPackets.listen((packet) {
      if (!packet.fromSelf) return;
      final echo = channelEcho(packet.raw, hash);
      if (echo == null) return;
      final direct = echo.hops == 1;
      final existing = replies[echo.firstHop];
      if (existing != null && (existing.snrHere != null || !direct)) return;
      replies[echo.firstHop] = WardriveReply(
        prefix: echo.firstHop,
        snrHere: direct ? packet.snr : null,
        rssiHere: direct ? packet.rssi : null,
      );
    });
    try {
      await connector.sendChannelMessage(channel, channelText);
      await Future<void>.delayed(listenWindow);
    } finally {
      await sub.cancel();
    }
    return replies.values.toList();
  }

  void _add(WardrivePing ping) {
    final session = _active;
    if (session == null) return;
    final pings = [...session.pings, ping];
    _active = session.copyWith(
      pings: pings.length > maxPings + maxPassive
          ? pings.sublist(pings.length - maxPings - maxPassive)
          : pings,
    );
    _notify();
  }

  Future<void> _save() async {
    await PrefsManager.instance.setString(
      _key,
      jsonEncode([for (final s in _sessions) s.toJson()]),
    );
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _stopWatchingPosition();
    _stopPassive();
    _stopNoise();
    super.dispose();
  }
}
