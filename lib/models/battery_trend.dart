import '../utils/battery_utils.dart';

/// One battery voltage reading from a repeater.
class BatterySample {
  const BatterySample(this.at, this.millivolts);

  final DateTime at;
  final int millivolts;

  Map<String, int> toJson() => {
    'at': at.millisecondsSinceEpoch,
    'mv': millivolts,
  };

  static BatterySample? fromJson(Object? json) {
    if (json is! Map) return null;
    final at = json['at'], mv = json['mv'];
    if (at is! int || mv is! int || mv <= 0 || mv > 20000) return null;
    return BatterySample(DateTime.fromMillisecondsSinceEpoch(at), mv);
  }
}

/// How worried to be about a repeater's battery, most worrying first.
enum BatteryWatchStatus {
  /// At or below [BatteryTrend.lowPercent].
  low,

  /// Falling fast enough to reach empty within [BatteryTrend.fallingDays].
  falling,

  /// Had readings before, but none for [BatteryTrend.quietAfter].
  quiet,

  /// Readings look fine.
  ok,

  /// Not enough readings to say.
  unknown,
}

/// What a repeater's battery history says: the latest level, which way
/// it's heading, and whether that needs attention.
class BatteryTrend {
  const BatteryTrend({
    required this.status,
    this.latest,
    this.percent,
    this.millivoltsPerDay,
    this.daysToEmpty,
  });

  static const lowPercent = 20;
  static const fallingDays = 7;
  static const quietAfter = Duration(days: 3);

  /// The window the slope is fitted over. A week smooths out the daily
  /// up-and-down of solar repeaters.
  static const slopeWindow = Duration(days: 7);

  /// The fit needs readings at least this far apart, or one evening's dip
  /// would look like a dying battery.
  static const minSpan = Duration(hours: 12);

  final BatteryWatchStatus status;
  final BatterySample? latest;
  final int? percent;

  /// The fitted change in millivolts per day; null without enough data.
  final double? millivoltsPerDay;

  /// Days until the battery reaches its chemistry's empty voltage, when
  /// it is falling; null otherwise.
  final double? daysToEmpty;

  static const empty = BatteryTrend(status: BatteryWatchStatus.unknown);
}

/// Works out the [BatteryTrend] for [samples] (any order) at [now].
BatteryTrend analyzeBattery(
  List<BatterySample> samples, {
  required String chemistry,
  required DateTime now,
}) {
  if (samples.isEmpty) return BatteryTrend.empty;
  final sorted = [...samples]..sort((a, b) => a.at.compareTo(b.at));
  final latest = sorted.last;
  final percent = estimateBatteryPercentFromMillivolts(
    latest.millivolts,
    chemistry,
  );

  final recent = sorted
      .where((s) => latest.at.difference(s.at) <= BatteryTrend.slopeWindow)
      .toList();
  double? slope;
  if (recent.length >= 3 &&
      latest.at.difference(recent.first.at) >= BatteryTrend.minSpan) {
    slope = _slopePerDay(recent);
  }

  double? daysToEmpty;
  if (slope != null && slope < 0) {
    final emptyMv = batteryVoltageRange(chemistry).minMv;
    final left = latest.millivolts - emptyMv;
    daysToEmpty = left <= 0 ? 0 : left / -slope;
  }

  final BatteryWatchStatus status;
  if (now.difference(latest.at) >= BatteryTrend.quietAfter) {
    status = BatteryWatchStatus.quiet;
  } else if (percent <= BatteryTrend.lowPercent) {
    status = BatteryWatchStatus.low;
  } else if (daysToEmpty != null && daysToEmpty <= BatteryTrend.fallingDays) {
    status = BatteryWatchStatus.falling;
  } else {
    status = BatteryWatchStatus.ok;
  }
  return BatteryTrend(
    status: status,
    latest: latest,
    percent: percent,
    millivoltsPerDay: slope,
    daysToEmpty: daysToEmpty,
  );
}

/// Least-squares slope of millivolts against time, in millivolts per day.
double? _slopePerDay(List<BatterySample> samples) {
  final t0 = samples.first.at.millisecondsSinceEpoch;
  const msPerDay = 86400000.0;
  final xs = [
    for (final s in samples) (s.at.millisecondsSinceEpoch - t0) / msPerDay,
  ];
  final ys = [for (final s in samples) s.millivolts.toDouble()];
  final n = xs.length;
  final mx = xs.reduce((a, b) => a + b) / n;
  final my = ys.reduce((a, b) => a + b) / n;
  var num = 0.0, den = 0.0;
  for (var i = 0; i < n; i++) {
    num += (xs[i] - mx) * (ys[i] - my);
    den += (xs[i] - mx) * (xs[i] - mx);
  }
  if (den == 0) return null;
  return num / den;
}
