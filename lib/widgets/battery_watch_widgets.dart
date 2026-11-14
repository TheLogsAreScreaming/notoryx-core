import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../l10n/l10n.dart';
import '../models/battery_trend.dart';
import '../services/app_settings_service.dart';
import '../services/repeater_battery_history.dart';
import '../theme/mesh_theme.dart';
import 'contact_table_banner.dart' show lastHeardText;
import 'tactical_glass_panel.dart';

/// The short name of [status].
String batteryStatusLabel(AppLocalizations l10n, BatteryWatchStatus status) =>
    switch (status) {
      BatteryWatchStatus.low => l10n.batteryWatch_statusLow,
      BatteryWatchStatus.falling => l10n.batteryWatch_statusFalling,
      BatteryWatchStatus.quiet => l10n.batteryWatch_statusQuiet,
      BatteryWatchStatus.ok => l10n.batteryWatch_statusOk,
      BatteryWatchStatus.unknown => l10n.batteryWatch_statusUnknown,
    };

/// The colour of [status]. Each status also has its own icon, so colour is
/// never the only sign.
Color batteryStatusColor(BatteryWatchStatus status) => switch (status) {
  BatteryWatchStatus.low => MeshPalette.alert,
  BatteryWatchStatus.falling => MeshPalette.warn,
  BatteryWatchStatus.quiet => MeshPalette.ink3,
  BatteryWatchStatus.ok => MeshPalette.signal,
  BatteryWatchStatus.unknown => MeshPalette.ink3,
};

IconData batteryStatusIcon(BatteryWatchStatus status) => switch (status) {
  BatteryWatchStatus.low => Icons.battery_alert,
  BatteryWatchStatus.falling => Icons.trending_down,
  BatteryWatchStatus.quiet => Icons.schedule,
  BatteryWatchStatus.ok => Icons.battery_full,
  BatteryWatchStatus.unknown => Icons.battery_unknown,
};

/// The trend of [repeaterKey]'s battery from the stored history, using the
/// battery chemistry chosen for that repeater.
BatteryTrend batteryTrendFor(BuildContext context, String repeaterKey) {
  final history = context.watch<RepeaterBatteryHistory?>();
  if (history == null) return BatteryTrend.empty;
  final chemistry = context
      .read<AppSettingsService>()
      .batteryChemistryForRepeater(repeaterKey);
  return analyzeBattery(
    history.samplesFor(repeaterKey),
    chemistry: chemistry,
    now: history.now,
  );
}

/// The lines under a trend: how fast it's changing, when it might run out,
/// and when the last reading came in.
List<String> batteryTrendLines(BuildContext context, BatteryTrend trend) {
  final l10n = context.l10n;
  return [
    if (trend.millivoltsPerDay case final slope?)
      l10n.batteryWatch_trend(
        '${slope >= 0 ? '+' : '−'}${(slope.abs() / 1000).toStringAsFixed(2)}',
      ),
    if (trend.daysToEmpty case final days?
        when trend.status == BatteryWatchStatus.falling ||
            trend.status == BatteryWatchStatus.low)
      l10n.batteryWatch_emptyIn(days < 1 ? '<1' : days.round().toString()),
    if (trend.maybeFalling) l10n.batteryWatch_maybeFalling,
    // What the trend rests on, so a guess never reads like a measurement.
    if (trend.millivoltsPerDay != null)
      l10n.batteryWatch_basis(
        trend.sampleCount,
        (trend.span.inHours / 24).toStringAsFixed(1),
        trend.confidence == TrendConfidence.good
            ? l10n.batteryWatch_confGood
            : l10n.batteryWatch_confLow,
      ),
    if (trend.longestGap case final gap? when gap >= const Duration(days: 1))
      l10n.batteryWatch_gap((gap.inHours / 24).toStringAsFixed(1)),
    if (trend.latest case final latest?)
      l10n.batteryWatch_lastReading(lastHeardText(context, latest.at)),
  ];
}

/// A status chip: icon and label, tinted by status.
class BatteryStatusChip extends StatelessWidget {
  const BatteryStatusChip({super.key, required this.status});

  final BatteryWatchStatus status;

  @override
  Widget build(BuildContext context) {
    final color = batteryStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(MeshRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(batteryStatusIcon(status), size: 14, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              batteryStatusLabel(context.l10n, status),
              style: TextStyle(
                color: MeshPalette.ink,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A line chart of battery voltage over the kept month.
class BatteryHistoryChart extends StatelessWidget {
  const BatteryHistoryChart({
    super.key,
    required this.samples,
    required this.now,
    this.height = 96,
    this.color,
  });

  final List<BatterySample> samples;
  final DateTime now;
  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (samples.isEmpty) return SizedBox(height: height);
    final mvs = samples.map((s) => s.millivolts);
    final low = (mvs.reduce(math.min) / 1000).toStringAsFixed(2);
    final high = (mvs.reduce(math.max) / 1000).toStringAsFixed(2);
    return Semantics(
      container: true,
      label: context.l10n.batteryWatch_chartLabel(samples.length, low, high),
      child: ExcludeSemantics(
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(
            painter: _BatteryChartPainter(
              samples: samples,
              start: _chartStart(samples, now),
              end: now,
              labelStyle: DefaultTextStyle.of(
                context,
              ).style.copyWith(color: MeshPalette.ink3, fontSize: 10),
              line: color ?? MeshPalette.accent,
              grid: MeshPalette.line,
            ),
          ),
        ),
      ),
    );
  }
}

/// The chart starts at the first reading (at least a day back), so a
/// fortnight of readings fills the width instead of a third of it.
DateTime _chartStart(List<BatterySample> samples, DateTime now) {
  final first = samples.first.at;
  final oldest = now.subtract(RepeaterBatteryHistory.keep);
  final dayBack = now.subtract(const Duration(days: 1));
  if (first.isBefore(oldest)) return oldest;
  return first.isAfter(dayBack) ? dayBack : first;
}

class _BatteryChartPainter extends CustomPainter {
  _BatteryChartPainter({
    required this.samples,
    required this.start,
    required this.end,
    required this.line,
    required this.grid,
    required this.labelStyle,
  });

  final List<BatterySample> samples;
  final DateTime start;
  final DateTime end;
  final Color line;
  final Color grid;
  final TextStyle labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    var lo = samples.map((s) => s.millivolts).reduce(math.min);
    var hi = samples.map((s) => s.millivolts).reduce(math.max);
    // Keep at least 0.2 V of range so a steady battery reads as flat.
    if (hi - lo < 200) {
      final mid = (hi + lo) ~/ 2;
      lo = mid - 100;
      hi = mid + 100;
    }
    final span = end.difference(start).inMilliseconds.toDouble();
    const labelWidth = 34.0;
    final plot = Rect.fromLTWH(
      labelWidth,
      4,
      size.width - labelWidth,
      size.height - 8,
    );
    Offset at(BatterySample s) => Offset(
      plot.left +
          plot.width *
              (s.at.difference(start).inMilliseconds / span).clamp(0.0, 1.0),
      plot.bottom - plot.height * (s.millivolts - lo) / (hi - lo),
    );

    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (final (y, mv) in [(plot.top, hi), (plot.bottom, lo)]) {
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), gridPaint);
      final tp = TextPainter(
        text: TextSpan(text: (mv / 1000).toStringAsFixed(2), style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: labelWidth - 4);
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    final points = samples.map(at).toList();
    final paint = Paint()
      ..color = line
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    if (points.length == 1) {
      canvas.drawCircle(points.single, 3, paint..style = PaintingStyle.fill);
      return;
    }
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, paint);
    canvas.drawCircle(points.last, 3, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(_BatteryChartPainter old) =>
      old.samples != samples ||
      old.end != end ||
      old.line != line ||
      old.grid != grid ||
      old.labelStyle != labelStyle;
}

/// A repeater's battery history: status, chart and trend lines. Shows
/// nothing until the repeater has a reading.
class BatteryTrendCard extends StatelessWidget {
  const BatteryTrendCard({super.key, required this.repeaterKey});

  final String repeaterKey;

  @override
  Widget build(BuildContext context) {
    final history = context.watch<RepeaterBatteryHistory?>();
    if (history == null) return const SizedBox.shrink();
    final samples = history.samplesFor(repeaterKey);
    if (samples.isEmpty) return const SizedBox.shrink();
    final trend = batteryTrendFor(context, repeaterKey);
    final l10n = context.l10n;
    return TacticalGlassPanel(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.batteryWatch_history,
                  style: TextStyle(
                    color: MeshPalette.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              BatteryStatusChip(status: trend.status),
            ],
          ),
          const SizedBox(height: 8),
          BatteryHistoryChart(
            samples: samples,
            now: history.now,
            color: batteryStatusColor(trend.status),
          ),
          const SizedBox(height: 6),
          for (final line in [
            ...batteryTrendLines(context, trend),
            l10n.batteryWatch_readings(samples.length),
          ])
            Text(line, style: TextStyle(color: MeshPalette.ink2, fontSize: 13)),
        ],
      ),
    );
  }
}
