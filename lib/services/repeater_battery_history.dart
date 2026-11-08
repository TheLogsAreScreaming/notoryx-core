import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/battery_trend.dart';
import '../utils/app_logger.dart';

/// A month of battery readings per repeater, kept for each connected radio
/// separately. Readings come from Status and Telemetry replies the user
/// already asked for; this never sends anything over the air.
class RepeaterBatteryHistory extends ChangeNotifier {
  RepeaterBatteryHistory(this.prefs, {DateTime Function()? clock})
    : _now = clock ?? DateTime.now;

  final SharedPreferences prefs;
  final DateTime Function() _now;

  static const keep = Duration(days: 30);
  static const maxSamplesPerRepeater = 400;
  static const maxRepeaters = 128;

  /// Readings closer together than this replace each other, so polling a
  /// repeater over and over doesn't crowd out the rest of the month.
  static const mergeWithin = Duration(minutes: 10);

  final Map<String, List<BatterySample>> _samples = {};
  String _scope = '';
  Timer? _saveTimer;
  Future<void> _writes = Future.value();
  bool _disposed = false;

  String get scope => _scope;
  DateTime get now => _now();

  static bool _keyValid(String key) => RegExp(r'^[0-9a-f]{64}$').hasMatch(key);
  static String _prefsKey(String scope) => 'repeater_battery_history_v1_$scope';

  /// Repeater keys that have at least one reading.
  Iterable<String> get repeaterKeys => _samples.keys;

  /// The readings for [repeaterKey], oldest first.
  List<BatterySample> samplesFor(String repeaterKey) =>
      List.unmodifiable(_samples[repeaterKey.toLowerCase()] ?? const []);

  /// Switches to the history of the radio with public key [key].
  void setScope(String key) {
    key = key.toLowerCase();
    if (!_keyValid(key)) key = '';
    if (_scope == key) return;
    unawaited(flush());
    _samples.clear();
    _scope = key;
    if (key.isNotEmpty) _load();
    notifyListeners();
  }

  void _load() {
    try {
      final raw = prefs.getString(_prefsKey(_scope));
      if (raw == null) return;
      final data = jsonDecode(raw);
      if (data is! Map) return;
      for (final entry in data.entries) {
        final repeater = entry.key;
        if (repeater is! String || !_keyValid(repeater)) continue;
        if (entry.value is! List) continue;
        final list = <BatterySample>[
          for (final item in entry.value as List) ?BatterySample.fromJson(item),
        ];
        if (list.isNotEmpty) _samples[repeater] = list;
      }
      _trim();
    } catch (e) {
      appLogger.error('Cannot load repeater battery history: $e');
    }
  }

  /// Adds a reading of [millivolts] for [repeaterKey], taken at [at] or now.
  void record(String repeaterKey, int millivolts, {DateTime? at}) {
    repeaterKey = repeaterKey.toLowerCase();
    if (_disposed || _scope.isEmpty || !_keyValid(repeaterKey)) return;
    if (millivolts <= 0 || millivolts > 20000) return;
    final time = at ?? now;
    if (time.isAfter(now.add(const Duration(minutes: 1)))) return;
    final list = _samples.putIfAbsent(repeaterKey, () => []);
    final sample = BatterySample(time, millivolts);
    if (list.isNotEmpty && time.difference(list.last.at).abs() < mergeWithin) {
      list[list.length - 1] = sample;
    } else {
      list.add(sample);
      list.sort((a, b) => a.at.compareTo(b.at));
    }
    _trim();
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(seconds: 1), () => unawaited(flush()));
    notifyListeners();
  }

  /// Forgets every reading for [repeaterKey].
  void clear(String repeaterKey) {
    if (_samples.remove(repeaterKey.toLowerCase()) == null) return;
    unawaited(flush());
    notifyListeners();
  }

  void _trim() {
    final cutoff = now.subtract(keep);
    for (final list in _samples.values) {
      list.removeWhere((s) => s.at.isBefore(cutoff));
      if (list.length > maxSamplesPerRepeater) {
        list.removeRange(0, list.length - maxSamplesPerRepeater);
      }
    }
    _samples.removeWhere((_, list) => list.isEmpty);
    if (_samples.length <= maxRepeaters) return;
    final byNewest = _samples.keys.toList()
      ..sort((a, b) => _samples[b]!.last.at.compareTo(_samples[a]!.last.at));
    for (final key in byNewest.skip(maxRepeaters)) {
      _samples.remove(key);
    }
  }

  /// Writes the current radio's history to storage.
  Future<void> flush() {
    _saveTimer?.cancel();
    if (_scope.isEmpty) return _writes;
    final key = _prefsKey(_scope);
    final data = jsonEncode(
      _samples.map(
        (repeater, list) =>
            MapEntry(repeater, [for (final s in list) s.toJson()]),
      ),
    );
    _writes = _writes
        .then((_) async {
          if (!await prefs.setString(key, data)) {
            throw StateError('write failed');
          }
        })
        .catchError((Object e) {
          appLogger.error('Cannot save repeater battery history: $e');
        });
    return _writes;
  }

  @override
  void dispose() {
    unawaited(flush());
    _disposed = true;
    super.dispose();
  }
}
