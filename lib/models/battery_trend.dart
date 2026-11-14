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

/// How much to trust a fitted trend.
enum TrendConfidence {
  /// Too few readings, too short a span, or too scattered to call a trend.
  low,

  /// Enough readings over enough time, and they line up.
  good,
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
    this.sampleCount = 0,
    this.span = Duration.zero,
    this.fit,
    this.confidence = TrendConfidence.low,
    this.longestGap,
  });

  static const lowPercent = 20;

  /// A trend needs this many readings in [slopeWindow]...
  static const goodSamples = 5;

  /// ...spread over at least this long...
  static const goodSpan = Duration(days: 1);

  /// ...and a line through them that explains this much of the change (R²).
  static const goodFit = 0.5;
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

  /// Readings the slope was fitted to, and the time they span.
  final int sampleCount;
  final Duration span;

  /// R² of the fit, 0 to 1; null without a fit. Solar repeaters swing
  /// daily, so a low value means the line says little.
  final double? fit;

  /// Whether the slope is backed by enough readings to act on. "Falling"
  /// is only declared with [TrendConfidence.good].
  final TrendConfidence confidence;

  /// The longest stretch with no reading inside the window; missing
  /// readings are gaps, never treated as values.
  final Duration? longestGap;

  /// The slope says falling within [fallingDays], but there's too little
  /// data to be sure.
  bool get maybeFalling =>
      confidence == TrendConfidence.low &&
      daysToEmpty != null &&
      daysToEmpty! <= fallingDays;

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
  double? fit;
  final span = latest.at.difference(recent.first.at);
  if (recent.length >= 3 && span >= BatteryTrend.minSpan) {
    final line = _fitPerDay(recent);
    slope = line?.slope;
    fit = line?.r2;
  }
  final confidence =
      slope != null &&
          recent.length >= BatteryTrend.goodSamples &&
          span >= BatteryTrend.goodSpan &&
          (fit ?? 0) >= BatteryTrend.goodFit
      ? TrendConfidence.good
      : TrendConfidence.low;
  Duration? longestGap;
  for (var i = 1; i < recent.length; i++) {
    final gap = recent[i].at.difference(recent[i - 1].at);
    if (longestGap == null || gap > longestGap) longestGap = gap;
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
  } else if (daysToEmpty != null &&
      daysToEmpty <= BatteryTrend.fallingDays &&
      confidence == TrendConfidence.good) {
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
    sampleCount: recent.length,
    span: span,
    fit: fit,
    confidence: confidence,
    longestGap: longestGap,
  );
}

/// Least-squares line of millivolts against time: slope in millivolts per
/// day, and R², how much of the change the line explains.
({double slope, double r2})? _fitPerDay(List<BatterySample> samples) {
  final t0 = samples.first.at.millisecondsSinceEpoch;
  const msPerDay = 86400000.0;
  final xs = [
    for (final s in samples) (s.at.millisecondsSinceEpoch - t0) / msPerDay,
  ];
  final ys = [for (final s in samples) s.millivolts.toDouble()];
  final n = xs.length;
  final mx = xs.reduce((a, b) => a + b) / n;
  final my = ys.reduce((a, b) => a + b) / n;
  var num = 0.0, den = 0.0, total = 0.0;
  for (var i = 0; i < n; i++) {
    num += (xs[i] - mx) * (ys[i] - my);
    den += (xs[i] - mx) * (xs[i] - mx);
    total += (ys[i] - my) * (ys[i] - my);
  }
  if (den == 0) return null;
  final slope = num / den;
  var residual = 0.0;
  for (var i = 0; i < n; i++) {
    final e = ys[i] - (my + slope * (xs[i] - mx));
    residual += e * e;
  }
  // A flat line through identical readings explains everything there is.
  final r2 = total == 0 ? 1.0 : (1 - residual / total).clamp(0.0, 1.0);
  return (slope: slope, r2: r2);
}
