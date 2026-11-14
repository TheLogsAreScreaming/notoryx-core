import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../storage/prefs_manager.dart';

/// Remembers which repeater won when several share a short path ID, so the
/// next time that ID shows up next to the same neighbour hop (with no
/// position to go on, or two candidates about equally close) the same
/// repeater is picked.
class HopTieMemory extends ChangeNotifier {
  HopTieMemory({SharedPreferences? prefs, DateTime Function()? clock})
    : _givenPrefs = prefs,
      _clock = clock ?? DateTime.now;

  /// The one the app uses.
  static final HopTieMemory shared = HopTieMemory();

  static const _key = 'notoryx_hop_ties_v1';
  static const defaultTtlDays = 30;
  static const maxTtlDays = 180;
  static const defaultMarginPercent = 5;
  static const maxMarginPercent = 20;

  final SharedPreferences? _givenPrefs;
  final DateTime Function() _clock;
  final _ties = <String, ({String winner, DateTime used})>{};
  int _ttlDays = defaultTtlDays;
  int _marginPercent = defaultMarginPercent;
  bool _loaded = false;

  SharedPreferences? get _prefs {
    if (_givenPrefs != null) return _givenPrefs;
    try {
      return PrefsManager.instance;
    } on StateError {
      return null;
    }
  }

  /// How long a remembered pick lasts without being used again.
  int get ttlDays {
    _load();
    return _ttlDays;
  }

  /// How close (in %) two candidates' distances must be for the
  /// remembered pick to decide between them. 0 means only exact ties.
  int get marginPercent {
    _load();
    return _marginPercent;
  }

  /// Remembered picks that haven't expired.
  int get count {
    _load();
    _dropExpired();
    return _ties.length;
  }

  set ttlDays(int days) {
    _load();
    _ttlDays = days.clamp(1, maxTtlDays);
    _save();
    notifyListeners();
  }

  set marginPercent(int percent) {
    _load();
    _marginPercent = percent.clamp(0, maxMarginPercent);
    _save();
    notifyListeners();
  }

  /// Whether distances [nearest] and [next] (metres) count as a tie.
  bool isTie(double nearest, double next) =>
      next - nearest <= nearest * marginPercent / 100;

  /// The public key (hex) remembered for short ID [hop] seen after
  /// [neighbour], or null.
  String? winner(String neighbour, String hop) {
    _load();
    final tie = _ties[_id(neighbour, hop)];
    if (tie == null) return null;
    if (_expired(tie.used)) {
      _ties.remove(_id(neighbour, hop));
      return null;
    }
    return tie.winner;
  }

  /// Notes that [winner] (public key hex) was picked for [hop] after
  /// [neighbour]. Safe to call while building widgets: it doesn't notify.
  void remember(String neighbour, String hop, String winner) {
    _load();
    final id = _id(neighbour, hop);
    final old = _ties[id];
    final now = _clock();
    _ties[id] = (winner: winner, used: now);
    // Saving on every redraw would be wasteful; a refreshed date only
    // matters once it's more than an hour newer.
    if (old == null ||
        old.winner != winner ||
        now.difference(old.used) > const Duration(hours: 1)) {
      _save();
    }
  }

  void forgetAll() {
    _load();
    _ties.clear();
    _save();
    notifyListeners();
  }

  static String _id(String neighbour, String hop) =>
      '${neighbour.toLowerCase()}>${hop.toLowerCase()}';

  bool _expired(DateTime used) =>
      _clock().difference(used) > Duration(days: _ttlDays);

  void _dropExpired() => _ties.removeWhere((_, t) => _expired(t.used));

  void _load() {
    if (_loaded) return;
    final raw = _prefs?.getString(_key);
    if (raw == null) {
      _loaded = _prefs != null;
      return;
    }
    _loaded = true;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      _ttlDays = (json['ttl'] as int? ?? defaultTtlDays).clamp(1, maxTtlDays);
      _marginPercent = (json['margin'] as int? ?? defaultMarginPercent).clamp(
        0,
        maxMarginPercent,
      );
      final ties = json['ties'] as Map<String, dynamic>? ?? const {};
      for (final MapEntry(:key, :value) in ties.entries) {
        final list = value as List<dynamic>;
        _ties[key] = (
          winner: list[0] as String,
          used: DateTime.fromMillisecondsSinceEpoch(list[1] as int),
        );
      }
    } on Object {
      _ties.clear();
    }
  }

  void _save() {
    final prefs = _prefs;
    if (prefs == null) return;
    _dropExpired();
    prefs.setString(
      _key,
      jsonEncode({
        'ttl': _ttlDays,
        'margin': _marginPercent,
        'ties': {
          for (final MapEntry(:key, :value) in _ties.entries)
            key: [value.winner, value.used.millisecondsSinceEpoch],
        },
      }),
    );
  }
}
