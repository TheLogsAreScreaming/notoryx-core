import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'coverage_hex_service.dart';

/// Sends that settled in one coverage cell on one day.
@immutable
class GapTally {
  const GapTally({required this.delivered, required this.failed});

  final int delivered;
  final int failed;

  int get total => delivered + failed;

  /// Share of sends that failed, 0 to 1.
  double get failRate => total == 0 ? 0 : failed / total;

  GapTally operator +(GapTally o) =>
      GapTally(delivered: delivered + o.delivered, failed: failed + o.failed);
}

/// Where your own direct messages got through and where they didn't, on the
/// coverage hexagon grid, from your normal use. Only the cell (about 0.9 km
/// across) and the day are kept, never coordinates, and nothing leaves the
/// phone.
class SendGapLog extends ChangeNotifier {
  SendGapLog({
    required Stream<bool> outcomes,
    required this.indexer,
    required Future<({double lat, double lon})?> Function() position,
    SharedPreferences? prefs,
    DateTime Function()? clock,
  }) : _position = position,
       _prefs = prefs,
       _now = clock ?? DateTime.now {
    _sub = outcomes.listen((ok) => unawaited(record(ok)));
  }

  final CellIndexer indexer;
  final Future<({double lat, double lon})?> Function() _position;
  final SharedPreferences? _prefs;
  final DateTime Function() _now;
  StreamSubscription<bool>? _sub;

  static const keep = Duration(days: 30);
  static const maxEntries = 3000;
  static const _prefsKey = 'send_gap_log_v1';

  /// cell -> day (yyyy-mm-dd, UTC) -> tally.
  final Map<String, Map<String, GapTally>> _cells = {};

  /// Totals per cell over the kept days.
  Map<String, GapTally> get cells => {
    for (final e in _cells.entries)
      e.key: e.value.values.fold(
        const GapTally(delivered: 0, failed: 0),
        (a, b) => a + b,
      ),
  };

  /// Cells with at least [minSends] sends, worst first.
  List<MapEntry<String, GapTally>> worst({int minSends = 2}) =>
      cells.entries.where((e) => e.value.total >= minSends).toList()
        ..sort((a, b) {
          final r = b.value.failRate.compareTo(a.value.failRate);
          return r != 0 ? r : b.value.total.compareTo(a.value.total);
        });

  static String _day(DateTime t) {
    final u = t.toUtc();
    return '${u.year.toString().padLeft(4, '0')}-'
        '${u.month.toString().padLeft(2, '0')}-'
        '${u.day.toString().padLeft(2, '0')}';
  }

  /// Credits one settled send to the cell the phone is in now. Skipped
  /// when no position is known.
  @visibleForTesting
  Future<void> record(bool delivered) async {
    final pos = await _position();
    if (pos == null || (pos.lat == 0 && pos.lon == 0)) return;
    final String cell;
    try {
      cell = indexer.cellOf(pos.lat, pos.lon);
    } catch (_) {
      return;
    }
    final days = _cells.putIfAbsent(cell, () => {});
    final day = _day(_now());
    days[day] =
        (days[day] ?? const GapTally(delivered: 0, failed: 0)) +
        GapTally(delivered: delivered ? 1 : 0, failed: delivered ? 0 : 1);
    _prune();
    notifyListeners();
    await _save();
  }

  void _prune() {
    final oldest = _day(_now().subtract(keep));
    for (final days in _cells.values) {
      days.removeWhere((day, _) => day.compareTo(oldest) < 0);
    }
    _cells.removeWhere((_, days) => days.isEmpty);
    var entries = _cells.values.fold(0, (n, d) => n + d.length);
    while (entries > maxEntries && _cells.isNotEmpty) {
      // Drop the oldest day anywhere.
      String? cell, day;
      for (final c in _cells.entries) {
        for (final d in c.value.keys) {
          if (day == null || d.compareTo(day) < 0) {
            cell = c.key;
            day = d;
          }
        }
      }
      _cells[cell]!.remove(day);
      if (_cells[cell]!.isEmpty) _cells.remove(cell);
      entries--;
    }
  }

  Future<void> load() async {
    final raw = _prefs?.getString(_prefsKey);
    if (raw == null) return;
    try {
      final json = jsonDecode(raw);
      if (json is! Map) return;
      for (final c in json.entries) {
        final days = c.value;
        if (c.key is! String || days is! Map) continue;
        for (final d in days.entries) {
          final v = d.value;
          if (d.key is! String || v is! List || v.length != 2) continue;
          final ok = v[0], bad = v[1];
          if (ok is! int || bad is! int) continue;
          _cells.putIfAbsent(c.key as String, () => {})[d.key as String] =
              GapTally(delivered: ok, failed: bad);
        }
      }
      _prune();
      notifyListeners();
    } catch (_) {
      // A damaged entry only loses the gap history.
    }
  }

  Future<void> _save() async {
    await _prefs?.setString(
      _prefsKey,
      jsonEncode({
        for (final c in _cells.entries)
          c.key: {
            for (final d in c.value.entries)
              d.key: [d.value.delivered, d.value.failed],
          },
      }),
    );
  }

  Future<void> clear() async {
    _cells.clear();
    notifyListeners();
    await _prefs?.remove(_prefsKey);
  }

  @override
  void dispose() {
    unawaited(_sub?.cancel());
    super.dispose();
  }
}
