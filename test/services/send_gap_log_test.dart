import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/services/coverage_hex_service.dart';
import 'package:meshcore_open/services/send_gap_log.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// One cell per whole degree, so tests don't need the H3 library.
class _GridIndexer implements CellIndexer {
  @override
  String cellOf(double lat, double lon) => '${lat.floor()}:${lon.floor()}';
  @override
  ({double lat, double lon}) centerOf(String cell) => (lat: 0, lon: 0);
  @override
  List<({double lat, double lon})> boundaryOf(String cell) => const [];
}

void main() {
  late StreamController<bool> outcomes;
  late SharedPreferences prefs;
  ({double lat, double lon})? here;
  var now = DateTime.utc(2026, 11, 23, 12);

  SendGapLog make() => SendGapLog(
    outcomes: outcomes.stream,
    indexer: _GridIndexer(),
    position: () async => here,
    prefs: prefs,
    clock: () => now,
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    outcomes = StreamController<bool>.broadcast();
    here = (lat: 40.5, lon: -75.5);
    now = DateTime.utc(2026, 11, 23, 12);
  });

  tearDown(() => outcomes.close());

  test('sends are tallied per cell and worst cells come first', () async {
    final log = make();
    await log.record(false);
    await log.record(false);
    await log.record(true);
    here = (lat: 41.5, lon: -75.5);
    await log.record(true);
    await log.record(true);

    expect(log.cells['40:-76']!.failed, 2);
    expect(log.cells['40:-76']!.total, 3);
    final worst = log.worst();
    expect(worst.first.key, '40:-76');
    expect(worst.last.value.failRate, 0);
    log.dispose();
  });

  test('outcomes from the connector stream are recorded', () async {
    final log = make();
    outcomes.add(false);
    await pumpEventQueue();
    expect(log.cells.values.single.failed, 1);
    log.dispose();
  });

  test('no position, or 0,0, records nothing', () async {
    final log = make();
    here = null;
    await log.record(false);
    here = (lat: 0, lon: 0);
    await log.record(false);
    expect(log.cells, isEmpty);
    log.dispose();
  });

  test('kept across restarts, only cells stored, old days dropped', () async {
    final log = make();
    await log.record(false);
    log.dispose();
    final saved = prefs.getString('send_gap_log_v1')!;
    expect(saved, isNot(contains('40.5')), reason: 'no coordinates stored');

    final again = make();
    await again.load();
    expect(again.cells['40:-76']!.failed, 1);

    now = now.add(const Duration(days: 31));
    await again.record(true);
    expect(again.cells.keys, ['40:-76']);
    expect(again.cells['40:-76']!.failed, 0, reason: 'old day pruned');
    again.dispose();
  });

  test('clear forgets everything', () async {
    final log = make();
    await log.record(false);
    await log.clear();
    expect(log.cells, isEmpty);
    expect(prefs.getString('send_gap_log_v1'), isNull);
    log.dispose();
  });
}
