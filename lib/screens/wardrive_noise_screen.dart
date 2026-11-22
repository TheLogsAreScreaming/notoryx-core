import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../models/wardrive.dart';
import '../theme/mesh_theme.dart';
import '../widgets/mesh_ui.dart';

/// The radio's noise floor over a drive, with a marker for each ping: green
/// when a repeater heard it, red when nothing did. Tap a marker for its
/// repeaters. A quiet channel sits around −120 to −100 dBm; above −90 dBm
/// the band is busy or something nearby is noisy, and range drops.
class WardriveNoiseScreen extends StatelessWidget {
  const WardriveNoiseScreen({
    super.key,
    required this.session,
    required this.nameOf,
  });

  final WardriveSession session;
  final String Function(String prefix) nameOf;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final noise = session.noise;
    final pings = [
      for (final p in session.sentPings)
        if (_noiseAt(p) != null) p,
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.wardrive_noiseTitle)),
      body: noise.length < 2
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.wardrive_noiseEmpty,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(MeshSpace.lg),
              children: [
                Semantics(
                  label: _summary(context),
                  child: ExcludeSemantics(
                    child: SizedBox(
                      height: 260,
                      child: LayoutBuilder(
                        builder: (context, box) {
                          final size = Size(box.maxWidth, 260);
                          final chart = _Chart(noise, pings, _noiseAt);
                          return GestureDetector(
                            key: const ValueKey('wardrive-noise-chart'),
                            onTapUp: (d) {
                              final hit = chart.markerAt(d.localPosition, size);
                              if (hit != null) _showPing(context, hit);
                            },
                            child: CustomPaint(
                              size: size,
                              painter: _NoisePainter(chart),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _summary(context),
                  key: const ValueKey('wardrive-noise-summary'),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.wardrive_noiseHint,
                  style: TextStyle(color: MeshPalette.ink3, fontSize: 12),
                ),
              ],
            ),
    );
  }

  /// The noise floor when [p] went out: its own reading, or the nearest
  /// sample within a minute.
  int? _noiseAt(WardrivePing p) {
    if (p.noiseFloor != null) return p.noiseFloor;
    NoiseSample? best;
    for (final s in session.noise) {
      final d = s.at.difference(p.at).abs();
      if (d > const Duration(minutes: 1)) continue;
      if (best == null || d < best.at.difference(p.at).abs()) best = s;
    }
    return best?.dbm;
  }

  String _summary(BuildContext context) {
    final values = [for (final s in session.noise) s.dbm];
    final lo = values.reduce(math.min);
    final hi = values.reduce(math.max);
    final avg = values.reduce((a, b) => a + b) / values.length;
    return context.l10n.wardrive_noiseSummary(lo, hi, avg.round());
  }

  void _showPing(BuildContext context, WardrivePing p) {
    final l10n = context.l10n;
    showMeshSheet<void>(
      context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BottomSheetHeader(
              title: TimeOfDay.fromDateTime(p.at.toLocal()).format(context),
              subtitle: l10n.wardrive_noise(_noiseAt(p) ?? 0),
            ),
            if (p.replies.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l10n.wardrive_noReplies),
              ),
            for (final r in p.replies)
              ListTile(
                leading: const Icon(Icons.cell_tower),
                title: Text(nameOf(r.prefix)),
                subtitle: Text(
                  r.link == null
                      ? l10n.wardrive_replyRelayed
                      : 'SNR ${r.link!.toStringAsFixed(1)} dB',
                ),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

/// Where everything goes on the chart.
class _Chart {
  _Chart(this.noise, this.pings, this.noiseAt) {
    final values = [for (final s in noise) s.dbm];
    lo = (values.reduce(math.min) - 5).toDouble();
    hi = (values.reduce(math.max) + 5).toDouble();
    start = noise.first.at;
    end = noise.last.at;
    for (final p in pings) {
      if (p.at.isBefore(start)) start = p.at;
      if (p.at.isAfter(end)) end = p.at;
    }
  }

  final List<NoiseSample> noise;
  final List<WardrivePing> pings;
  final int? Function(WardrivePing) noiseAt;
  late final double lo;
  late final double hi;
  late DateTime start;
  late DateTime end;

  static const pad = 28.0;

  Offset point(DateTime at, num dbm, Size size) {
    final span = math.max(1, end.difference(start).inMilliseconds);
    final x =
        pad +
        (size.width - pad - 8) * at.difference(start).inMilliseconds / span;
    final y = 8 + (size.height - 24) * (hi - dbm) / math.max(1, hi - lo);
    return Offset(x, y);
  }

  /// The ping whose marker is under [pos], if any.
  WardrivePing? markerAt(Offset pos, Size size) {
    WardrivePing? hit;
    var best = 20.0;
    for (final p in pings) {
      final d = (point(p.at, noiseAt(p)!, size) - pos).distance;
      if (d < best) {
        best = d;
        hit = p;
      }
    }
    return hit;
  }
}

class _NoisePainter extends CustomPainter {
  _NoisePainter(this.chart);

  final _Chart chart;

  /// Quiet, busy, noisy.
  static Color _level(int dbm) => dbm < -100
      ? MeshPalette.signal
      : dbm < -90
      ? MeshPalette.warn
      : MeshPalette.alert;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = MeshPalette.line
      ..strokeWidth = 1;
    final label = TextStyle(color: MeshPalette.ink3, fontSize: 10);
    for (final dbm in [-120, -110, -100, -90, -80]) {
      if (dbm < chart.lo || dbm > chart.hi) continue;
      final y = chart.point(chart.start, dbm, size).dy;
      canvas.drawLine(Offset(_Chart.pad, y), Offset(size.width, y), grid);
      final tp = TextPainter(
        text: TextSpan(text: '$dbm', style: label),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }
    final line = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    for (var i = 1; i < chart.noise.length; i++) {
      final a = chart.noise[i - 1], b = chart.noise[i];
      line.color = _level(b.dbm);
      canvas.drawLine(
        chart.point(a.at, a.dbm, size),
        chart.point(b.at, b.dbm, size),
        line,
      );
    }
    for (final p in chart.pings) {
      final c = chart.point(p.at, chart.noiseAt(p)!, size);
      canvas.drawCircle(c, 6, Paint()..color = Colors.white);
      canvas.drawCircle(
        c,
        4.5,
        Paint()..color = p.heard ? MeshPalette.signal : MeshPalette.alert,
      );
    }
  }

  @override
  bool shouldRepaint(_NoisePainter old) =>
      old.chart.noise != chart.noise || old.chart.pings != chart.pings;
}
