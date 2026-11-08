import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../connector/meshcore_connector.dart';
import '../connector/meshcore_protocol.dart';
import '../helpers/cayenne_lpp.dart';
import '../models/battery_trend.dart';
import '../utils/app_logger.dart';
import 'repeater_battery_history.dart';

/// Why a battery alert was raised.
enum BatteryAlertKind { low, falling, silent }

/// One alert to show for a watched repeater.
@immutable
class BatteryAlert {
  const BatteryAlert({
    required this.repeaterKey,
    required this.kind,
    required this.trend,
    this.failures = 0,
  });

  final String repeaterKey;
  final BatteryAlertKind kind;
  final BatteryTrend trend;
  final int failures;
}

/// The airtime rules for automatic checks, kept apart so they can be tested.
class BatteryCheckBudget {
  const BatteryCheckBudget({
    this.minGap = const Duration(minutes: 2),
    this.maxPerHour = 6,
  });

  /// The shortest time between two checks, to any repeater.
  final Duration minGap;

  /// The most checks in any hour, across all repeaters.
  final int maxPerHour;

  /// Allowed check intervals; the floor is one hour.
  static const intervals = [1, 3, 6, 12, 24];

  /// The repeater to check now, or null. Picks the most overdue one among
  /// [watched], given when each was last tried and the recent [sent] times.
  String? next({
    required Iterable<String> watched,
    required Map<String, DateTime> lastTried,
    required List<DateTime> sent,
    required Duration interval,
    required DateTime now,
  }) {
    final recent = sent.where(
      (t) => now.difference(t) < const Duration(hours: 1),
    );
    if (recent.length >= maxPerHour) return null;
    if (recent.any((t) => now.difference(t) < minGap)) return null;
    String? best;
    DateTime? bestDue;
    for (final key in watched) {
      final last = lastTried[key];
      final due = last == null ? DateTime(0) : last.add(interval);
      if (due.isAfter(now)) continue;
      if (bestDue == null || due.isBefore(bestDue)) {
        best = key;
        bestDue = due;
      }
    }
    return best;
  }
}

/// Decides which alerts to raise, once per change of state.
class BatteryAlertLatch {
  final Map<String, BatteryAlertKind> _raised = {};

  /// Silent alerts need this many unanswered checks in a row.
  static const silentAfter = 3;

  Map<String, String> toJson() => _raised.map((k, v) => MapEntry(k, v.name));

  void load(Object? json) {
    _raised.clear();
    if (json is! Map) return;
    for (final e in json.entries) {
      final kind = BatteryAlertKind.values.where((k) => k.name == e.value);
      if (e.key is String && kind.isNotEmpty) {
        _raised[e.key as String] = kind.first;
      }
    }
  }

  void forget(String key) => _raised.remove(key);

  /// The alert to raise for [key] now, if any. Raises each kind once until
  /// the repeater recovers (looks fine again, or answers again).
  BatteryAlert? update(String key, BatteryTrend trend, int failures) {
    final BatteryAlertKind? kind;
    if (failures >= silentAfter) {
      kind = BatteryAlertKind.silent;
    } else if (trend.status == BatteryWatchStatus.low) {
      kind = BatteryAlertKind.low;
    } else if (trend.status == BatteryWatchStatus.falling) {
      kind = BatteryAlertKind.falling;
    } else {
      kind = null;
    }
    final previous = _raised[key];
    if (kind == null) {
      // Answering again clears "silent"; a healthy reading clears the rest.
      if (previous != null &&
          (previous == BatteryAlertKind.silent ||
              trend.status == BatteryWatchStatus.ok)) {
        _raised.remove(key);
      }
      return null;
    }
    if (previous == kind) return null;
    // Low outranks falling: don't announce "falling" after "low".
    if (previous == BatteryAlertKind.low && kind == BatteryAlertKind.falling) {
      return null;
    }
    _raised[key] = kind;
    return BatteryAlert(
      repeaterKey: key,
      kind: kind,
      trend: trend,
      failures: failures,
    );
  }
}

/// Asks watched repeaters for their battery on a timer while a radio is
/// connected, within [BatteryCheckBudget], and raises alerts when a battery
/// is low, falling fast, or the repeater stops answering. Off until the user
/// picks repeaters to watch. A repeater only answers a client that is logged
/// in to it, so a check can go unanswered for that reason alone.
class BatteryCheckService extends ChangeNotifier {
  BatteryCheckService({
    required this.connector,
    required this.history,
    required this.prefs,
    required this.chemistryFor,
    required this.alert,
    this.budget = const BatteryCheckBudget(),
    DateTime Function()? clock,
    Duration tick = const Duration(minutes: 1),
  }) : _now = clock ?? DateTime.now,
       _tick = tick;

  final MeshCoreConnector connector;
  final RepeaterBatteryHistory history;
  final SharedPreferences prefs;
  final String Function(String repeaterKey) chemistryFor;
  final Future<void> Function(BatteryAlert alert) alert;
  final BatteryCheckBudget budget;
  final DateTime Function() _now;
  final Duration _tick;

  final Set<String> _watched = {};
  final Map<String, DateTime> _lastTried = {};
  final Map<String, int> _failures = {};
  final List<DateTime> _sent = [];
  final _latch = BatteryAlertLatch();
  int _intervalHours = 6;
  String _scope = '';
  Timer? _timer;
  StreamSubscription<Uint8List>? _frames;
  _Pending? _pending;
  bool _disposed = false;

  Set<String> get watched => Set.unmodifiable(_watched);
  int get intervalHours => _intervalHours;
  int failuresFor(String key) => _failures[key] ?? 0;
  bool isWatched(String key) => _watched.contains(key.toLowerCase());
  bool get isChecking => _pending != null;
  DateTime? lastTried(String key) => _lastTried[key.toLowerCase()];

  static String _prefsKey(String scope) => 'battery_check_v1_$scope';

  void start() {
    _frames = connector.receivedFrames.listen(_onFrame);
    history.addListener(_evaluate);
    _timer = Timer.periodic(_tick, (_) => unawaited(checkDue()));
  }

  /// Switches to the watch list of the radio with public key [key].
  void setScope(String key) {
    key = key.toLowerCase();
    if (key == _scope) return;
    _scope = key;
    _watched.clear();
    _lastTried.clear();
    _failures.clear();
    _pending = null;
    _intervalHours = 6;
    _latch.load(null);
    if (key.isNotEmpty) _load();
    notifyListeners();
  }

  void _load() {
    try {
      final raw = prefs.getString(_prefsKey(_scope));
      if (raw == null) return;
      final data = jsonDecode(raw);
      if (data is! Map) return;
      final interval = data['interval'];
      if (interval is int && BatteryCheckBudget.intervals.contains(interval)) {
        _intervalHours = interval;
      }
      for (final k in (data['watched'] as List? ?? const [])) {
        if (k is String) _watched.add(k);
      }
      (data['last'] as Map? ?? const {}).forEach((k, v) {
        if (k is String && v is int) {
          _lastTried[k] = DateTime.fromMillisecondsSinceEpoch(v);
        }
      });
      (data['fails'] as Map? ?? const {}).forEach((k, v) {
        if (k is String && v is int) _failures[k] = v;
      });
      _latch.load(data['alerted']);
    } catch (e) {
      appLogger.warn('Cannot load battery check settings: $e');
    }
  }

  Future<void> _save() async {
    if (_scope.isEmpty) return;
    await prefs.setString(
      _prefsKey(_scope),
      jsonEncode({
        'interval': _intervalHours,
        'watched': _watched.toList(),
        'last': _lastTried.map((k, v) => MapEntry(k, v.millisecondsSinceEpoch)),
        'fails': _failures,
        'alerted': _latch.toJson(),
      }),
    );
  }

  Future<void> setWatched(String key, bool on) async {
    key = key.toLowerCase();
    if (on ? !_watched.add(key) : !_watched.remove(key)) return;
    if (!on) {
      _failures.remove(key);
      _latch.forget(key);
    }
    notifyListeners();
    await _save();
  }

  Future<void> setIntervalHours(int hours) async {
    if (!BatteryCheckBudget.intervals.contains(hours)) return;
    _intervalHours = hours;
    notifyListeners();
    await _save();
  }

  /// Sends one check if one is due and the budget allows it.
  @visibleForTesting
  Future<void> checkDue() async {
    if (_disposed || _pending != null || _scope.isEmpty) return;
    if (!connector.isConnected || _watched.isEmpty) return;
    final now = _now();
    _sent.removeWhere((t) => now.difference(t) >= const Duration(hours: 1));
    final key = budget.next(
      watched: _watched,
      lastTried: _lastTried,
      sent: _sent,
      interval: Duration(hours: _intervalHours),
      now: now,
    );
    if (key == null) return;
    final contact = connector.allContactsUnfiltered
        .where((c) => c.publicKeyHex == key)
        .firstOrNull;
    if (contact == null) return;
    _lastTried[key] = now;
    _sent.add(now);
    final pending = _Pending(key);
    _pending = pending;
    // No "sent" reply within 10 s means the radio didn't take it.
    pending.timer = Timer(
      const Duration(seconds: 10),
      () => _finish(pending, null),
    );
    notifyListeners();
    try {
      await connector.preparePathForContactSend(contact);
      await connector.sendFrame(
        buildSendBinaryReq(
          contact.publicKey,
          payload: buildTelemetryBinaryPayload(),
        ),
      );
    } catch (e) {
      appLogger.warn('Battery check for ${contact.name} failed: $e');
      _finish(pending, null);
    }
  }

  void _onFrame(Uint8List frame) {
    final pending = _pending;
    if (pending == null || frame.isEmpty) return;
    try {
      final reader = BufferReader(frame);
      final cmd = reader.readByte();
      if (cmd == respCodeSent && pending.tag == null) {
        reader.skipBytes(1);
        pending.tag = reader.readUInt32LE();
        final trip = reader.readUInt32LE();
        pending.timer?.cancel();
        pending.timer = Timer(
          Duration(milliseconds: trip) + const Duration(seconds: 5),
          () => _finish(pending, null),
        );
      } else if (cmd == pushCodeBinaryResponse && pending.tag != null) {
        reader.skipBytes(1);
        if (reader.readUInt32LE() != pending.tag) return;
        _finish(
          pending,
          batteryMillivoltsFromTelemetry(reader.readRemainingBytes()),
        );
      }
    } catch (e) {
      appLogger.warn('Battery check reply not understood: $e');
    }
  }

  void _finish(_Pending pending, int? millivolts) {
    if (!identical(_pending, pending)) return;
    pending.timer?.cancel();
    _pending = null;
    if (millivolts != null) {
      _failures.remove(pending.key);
      connector.updateRepeaterBatterySnapshot(
        pending.key,
        millivolts,
        source: 'telemetry',
      );
    } else {
      _failures[pending.key] = (_failures[pending.key] ?? 0) + 1;
    }
    _evaluate();
    notifyListeners();
    unawaited(_save());
  }

  void _evaluate() {
    if (_disposed) return;
    for (final key in _watched) {
      final trend = analyzeBattery(
        history.samplesFor(key),
        chemistry: chemistryFor(key),
        now: history.now,
      );
      final raised = _latch.update(key, trend, _failures[key] ?? 0);
      if (raised != null) {
        unawaited(_save());
        unawaited(alert(raised));
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _pending?.timer?.cancel();
    unawaited(_frames?.cancel());
    history.removeListener(_evaluate);
    super.dispose();
  }
}

class _Pending {
  _Pending(this.key);
  final String key;
  int? tag;
  Timer? timer;
}

/// The battery voltage in millivolts from a repeater's telemetry reply: the
/// voltage on LPP channel 1, which MeshCore uses for the node's own battery.
int? batteryMillivoltsFromTelemetry(Uint8List lpp) {
  for (final entry in CayenneLpp.parseByChannel(lpp)) {
    if (entry['channel'] != 1) continue;
    final values = entry['values'];
    if (values is! Map) continue;
    final voltage = values['voltage'];
    if (voltage is num && voltage > 0) return (voltage * 1000).round();
  }
  return null;
}
