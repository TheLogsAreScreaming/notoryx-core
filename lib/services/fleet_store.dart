import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/fleet.dart';
import '../utils/app_logger.dart';

/// The user's repeaters and their poll history, kept on this phone.
///
/// Passwords are not kept here; see [FleetPasswordStore].
class FleetStore extends ChangeNotifier {
  FleetStore(this.prefs, {DateTime Function()? clock})
    : _now = clock ?? DateTime.now {
    _load();
  }

  final SharedPreferences prefs;
  final DateTime Function() _now;

  static const keep = Duration(days: 90);
  static const maxSamplesPerRepeater = 2000;
  static const maxRepeaters = 64;
  static const _listKey = 'fleet_repeaters_v1';
  static const _historyKey = 'fleet_history_v1';
  static const _stationKey = 'fleet_station_v1';

  final List<FleetRepeater> _repeaters = [];
  final Map<String, List<FleetSample>> _history = {};
  String _station = '';
  Timer? _saveTimer;

  List<FleetRepeater> get repeaters => List.unmodifiable(_repeaters);

  /// The station address last synced from, or empty.
  String get station => _station;

  bool contains(String key) =>
      _repeaters.any((r) => r.publicKeyHex == key.toLowerCase());

  FleetRepeater? byKey(String key) {
    key = key.toLowerCase();
    for (final r in _repeaters) {
      if (r.publicKeyHex == key) return r;
    }
    return null;
  }

  /// Polls of [key], oldest first.
  List<FleetSample> historyFor(String key) =>
      List.unmodifiable(_history[key.toLowerCase()] ?? const []);

  FleetHealth healthFor(String key, {DateTime? advertAt}) =>
      FleetHealth.from(historyFor(key), advertAt: advertAt);

  void _load() {
    try {
      final list = jsonDecode(prefs.getString(_listKey) ?? '[]');
      if (list is List) {
        for (final j in list) {
          final r = FleetRepeater.fromJson(j);
          if (r != null && !contains(r.publicKeyHex)) _repeaters.add(r);
        }
      }
      final hist = jsonDecode(prefs.getString(_historyKey) ?? '{}');
      if (hist is Map) {
        for (final MapEntry(:key, :value) in hist.entries) {
          if (key is! String || value is! List) continue;
          final samples = [for (final s in value) ?FleetSample.fromJson(s)];
          if (samples.isNotEmpty) _history[key] = samples;
        }
      }
      _station = prefs.getString(_stationKey) ?? '';
      _trim();
    } catch (e) {
      appLogger.error('Cannot load fleet: $e');
    }
  }

  /// Adds a repeater; false when it is already listed, the key is not a
  /// full key, or the list is full.
  bool add(String key, String name, {int? stationId}) {
    final normal = FleetRepeater.normalizeKey(key);
    if (normal == null || contains(normal)) return false;
    if (_repeaters.length >= maxRepeaters) return false;
    _repeaters.add(
      FleetRepeater(
        publicKeyHex: normal,
        name: name.trim().isEmpty ? normal.substring(0, 8) : name.trim(),
        addedAt: _now(),
        stationId: stationId,
      ),
    );
    _changed(now: true);
    return true;
  }

  void rename(String key, String name) {
    final i = _repeaters.indexWhere((r) => r.publicKeyHex == key);
    if (i < 0 || name.trim().isEmpty) return;
    _repeaters[i] = _repeaters[i].copyWith(name: name.trim());
    _changed(now: true);
  }

  void setStationId(String key, int id) {
    final i = _repeaters.indexWhere((r) => r.publicKeyHex == key);
    if (i < 0) return;
    _repeaters[i] = _repeaters[i].copyWith(stationId: id);
    _changed();
  }

  void remove(String key) {
    _repeaters.removeWhere((r) => r.publicKeyHex == key);
    _history.remove(key);
    _changed(now: true);
  }

  void record(String key, FleetSample sample) {
    key = key.toLowerCase();
    if (!contains(key)) return;
    _history.putIfAbsent(key, () => []).add(sample);
    _history[key]!.sort((a, b) => a.at.compareTo(b.at));
    _trim();
    _changed();
  }

  /// Merges samples from a station, skipping any at a time already kept.
  /// Returns how many were new.
  int mergeStation(String key, List<FleetSample> samples) {
    key = key.toLowerCase();
    if (!contains(key) || samples.isEmpty) return 0;
    final list = _history.putIfAbsent(key, () => []);
    final seen = {
      for (final s in list)
        if (s.source == FleetSource.station) s.at.millisecondsSinceEpoch,
    };
    final cutoff = _now().subtract(keep);
    var added = 0;
    for (final s in samples) {
      if (s.at.isBefore(cutoff)) continue;
      if (seen.add(s.at.millisecondsSinceEpoch)) {
        list.add(s);
        added++;
      }
    }
    if (added == 0) return 0;
    list.sort((a, b) => a.at.compareTo(b.at));
    _trim();
    _changed();
    return added;
  }

  set station(String value) {
    _station = value.trim();
    unawaited(prefs.setString(_stationKey, _station));
    notifyListeners();
  }

  void _trim() {
    final cutoff = _now().subtract(keep);
    _history.removeWhere((key, list) {
      if (!contains(key)) return true;
      list.removeWhere((s) => s.at.isBefore(cutoff));
      if (list.length > maxSamplesPerRepeater) {
        list.removeRange(0, list.length - maxSamplesPerRepeater);
      }
      return list.isEmpty;
    });
  }

  void _changed({bool now = false}) {
    notifyListeners();
    _saveTimer?.cancel();
    if (now) {
      unawaited(flush());
    } else {
      _saveTimer = Timer(const Duration(seconds: 5), () => unawaited(flush()));
    }
  }

  Future<void> flush() async {
    _saveTimer?.cancel();
    _saveTimer = null;
    try {
      await prefs.setString(
        _listKey,
        jsonEncode([for (final r in _repeaters) r.toJson()]),
      );
      await prefs.setString(
        _historyKey,
        jsonEncode({
          for (final MapEntry(:key, :value) in _history.entries)
            key: [for (final s in value) s.toJson()],
        }),
      );
    } catch (e) {
      appLogger.error('Cannot save fleet: $e');
    }
  }

  @override
  void dispose() {
    if (_saveTimer != null) unawaited(flush());
    super.dispose();
  }
}

/// Admin passwords for fleet repeaters. They stay on this phone and are
/// never sent anywhere but to the repeater itself, over the radio.
abstract class FleetPasswordStore {
  Future<String?> read(String key);
  Future<void> write(String key, String password);
  Future<void> delete(String key);

  /// The OS keychain / keystore, or memory on web where there is none.
  factory FleetPasswordStore.platform() =>
      kIsWeb ? MemoryFleetPasswordStore() : SecureFleetPasswordStore();
}

class SecureFleetPasswordStore implements FleetPasswordStore {
  SecureFleetPasswordStore({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            // The data protection keychain needs keychain-access-groups,
            // which ad-hoc signed macOS builds can't carry.
            mOptions: MacOsOptions(usesDataProtectionKeychain: false),
          );

  final FlutterSecureStorage _storage;

  static String _k(String key) => 'fleet_pw_${key.toLowerCase()}';

  @override
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: _k(key));
    } on Object catch (e) {
      debugPrint('Fleet password unreadable: ${e.runtimeType}');
      return null;
    }
  }

  @override
  Future<void> write(String key, String password) =>
      _storage.write(key: _k(key), value: password);

  @override
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: _k(key));
    } on Object catch (e) {
      debugPrint('Fleet password delete failed: ${e.runtimeType}');
    }
  }
}

class MemoryFleetPasswordStore implements FleetPasswordStore {
  final Map<String, String> _values = {};

  @override
  Future<String?> read(String key) async => _values[key.toLowerCase()];

  @override
  Future<void> write(String key, String password) async =>
      _values[key.toLowerCase()] = password;

  @override
  Future<void> delete(String key) async => _values.remove(key.toLowerCase());
}
