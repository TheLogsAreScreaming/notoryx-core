import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/models/battery_trend.dart';

final t0 = DateTime(2026, 11, 1, 12);

List<BatterySample> series(
  List<int> mvs, {
  Duration step = const Duration(hours: 6),
}) => [for (final (i, mv) in mvs.indexed) BatterySample(t0.add(step * i), mv)];

BatteryTrend run(List<BatterySample> s) =>
    analyzeBattery(s, chemistry: 'nmc', now: s.last.at);

void main() {
  test('a steady fall over a day of readings is a good trend', () {
    final t = run(series([4000, 3950, 3900, 3850, 3800]));
    expect(t.confidence, TrendConfidence.good);
    expect(t.sampleCount, 5);
    expect(t.span, const Duration(hours: 24));
    expect(t.fit, closeTo(1, 0.001));
    expect(t.status, BatteryWatchStatus.falling);
    expect(t.maybeFalling, isFalse);
  });

  test('three readings that point down are only "maybe falling"', () {
    final t = run(series([4000, 3850, 3700], step: const Duration(hours: 8)));
    expect(t.confidence, TrendConfidence.low);
    expect(t.status, BatteryWatchStatus.ok);
    expect(t.maybeFalling, isTrue);
  });

  test('scattered solar swings are not called a trend', () {
    // Charging by day, draining by night, ending a little lower.
    final t = run(series([4100, 3700, 4150, 3650, 4050, 3600, 4000, 3550]));
    expect(t.fit, lessThan(BatteryTrend.goodFit));
    expect(t.confidence, TrendConfidence.low);
    expect(t.status, isNot(BatteryWatchStatus.falling));
  });

  test('gaps between readings are reported, not filled in', () {
    final s = [
      BatterySample(t0, 4000),
      BatterySample(t0.add(const Duration(hours: 6)), 3990),
      BatterySample(t0.add(const Duration(days: 3)), 3980),
      BatterySample(t0.add(const Duration(days: 3, hours: 6)), 3975),
      BatterySample(t0.add(const Duration(days: 3, hours: 12)), 3970),
    ];
    final t = run(s);
    expect(t.longestGap, const Duration(days: 2, hours: 18));
    expect(t.sampleCount, 5, reason: 'only real readings are counted');
  });

  test('identical readings are a flat, certain line', () {
    final t = run(series([3900, 3900, 3900, 3900, 3900]));
    expect(t.millivoltsPerDay, 0);
    expect(t.fit, 1);
    expect(t.status, BatteryWatchStatus.ok);
  });
}
