import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../helpers/streak_geometry.dart';
import '../models/traffic_route.dart';
import '../services/traffic_controller.dart';
import '../theme/mesh_theme.dart';

/// A map layer that draws each packet as a streak: a bright head with a
/// fading tail runs from the sender through each repeater to the receiver,
/// the line it passed stays faintly behind it, the line ahead is dotted, and
/// rings pulse at the origin and when the packet reaches us. Copies of one
/// packet that came by other routes are drawn as branches.
class TrafficMapLayer extends StatefulWidget {
  const TrafficMapLayer({super.key, required this.controller});

  final TrafficController controller;

  @override
  State<TrafficMapLayer> createState() => _TrafficMapLayerState();
}

class _TrafficMapLayerState extends State<TrafficMapLayer>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker((_) => _onTick());

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTraffic);
    _onTraffic();
  }

  @override
  void didUpdateWidget(TrafficMapLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTraffic);
      widget.controller.addListener(_onTraffic);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTraffic);
    _ticker.dispose();
    super.dispose();
  }

  void _onTraffic() {
    if (!widget.controller.queue.isIdle && !_ticker.isActive) _ticker.start();
  }

  void _onTick() {
    final c = widget.controller;
    c.queue.tick(c.now(), reduceMotion: c.reduceMotion);
    if (c.queue.isIdle) _ticker.stop();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);
    final routes = widget.controller.queue.active;
    if (routes.isEmpty) return const SizedBox.shrink();
    return IgnorePointer(
      child: MobileLayerTransformer(
        child: CustomPaint(
          size: Size.infinite,
          painter: _TrafficPainter(
            routes: routes,
            now: widget.controller.now(),
            project: camera.getOffsetFromOrigin,
            labelStyle: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              fontFamily: MeshFonts.mono,
            ),
          ),
        ),
      ),
    );
  }
}

class _TrafficPainter extends CustomPainter {
  _TrafficPainter({
    required this.routes,
    required this.now,
    required this.project,
    required this.labelStyle,
  });

  final List<ActiveTrafficRoute> routes;
  final DateTime now;
  final Offset Function(LatLng) project;
  final TextStyle labelStyle;

  static const _pulse = Duration(milliseconds: 1100);

  @override
  void paint(Canvas canvas, Size size) {
    _labelled.clear();
    for (final r in routes) {
      _paintRoute(canvas, r);
    }
  }

  /// Labels already drawn this frame: branches of one packet share hops.
  final Set<Offset> _labelled = {};

  void _paintRoute(Canvas canvas, ActiveTrafficRoute r) {
    final hops = r.route.mappedHops;
    final points = [for (final h in hops) project(h.point!)];
    if (points.length < 2) return;
    final color = trafficKindColor(r.route.kind);
    final alpha = r.opacity(now);
    if (alpha <= 0) return;
    final line = StreakLine(points);
    final total = line.length;
    final head = total * r.travelFraction(now);
    final travelling = head < total && r.travel > Duration.zero;
    final tail = streakTailLength(total);

    Paint stroke(double a, double width) => Paint()
      ..color = color.withValues(alpha: a * alpha)
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // The line already passed, faint once the streak has gone by, and
    // solid when the whole route is shown (arrived, or reduce motion).
    final behind = line.slice(0, travelling ? head - tail : total);
    _polyline(canvas, behind, travelling ? stroke(0.4, 2) : stroke(0.8, 2.6));

    // The line still ahead, dotted.
    if (travelling) {
      final ahead = line.slice(head, total);
      for (var i = 0; i + 1 < ahead.length; i++) {
        _dotted(canvas, ahead[i], ahead[i + 1], stroke(0.4, 1.6));
      }
      // The tail brightens and thickens towards the head.
      const steps = 10;
      for (var k = 0; k < steps; k++) {
        final f = (k + 1) / steps;
        final a = head - tail + tail * k / steps;
        final b = head - tail + tail * f;
        _polyline(
          canvas,
          line.slice(a, b),
          stroke(0.15 + 0.85 * f, 1.5 + 2.5 * f),
        );
      }
      final at = line.pointAt(head);
      canvas.drawCircle(
        at,
        10,
        Paint()
          ..color = color.withValues(alpha: 0.55 * alpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
      );
      canvas.drawCircle(at, 4.5, Paint()..color = color);
      canvas.drawCircle(
        at,
        2,
        Paint()..color = Colors.white.withValues(alpha: alpha),
      );
    }

    final elapsed = now.difference(r.startedAt);
    _ring(canvas, points.first, color, elapsed, alpha);
    final arrived = elapsed - r.travel;
    if (hops.last.role == TrafficHopRole.self && arrived >= Duration.zero) {
      _ring(canvas, points.last, color, arrived, alpha);
    }

    for (var i = 0; i < hops.length; i++) {
      if (hops[i].role == TrafficHopRole.self) continue;
      if (!_labelled.add(points[i])) continue;
      _label(canvas, points[i], hops[i], alpha);
    }
  }

  void _polyline(Canvas canvas, List<Offset> pts, Paint paint) {
    if (pts.length < 2) return;
    final path = ui.Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final p in pts.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, paint);
  }

  void _dotted(Canvas canvas, Offset a, Offset b, Paint paint) {
    final d = b - a;
    final length = d.distance;
    if (length == 0) return;
    final step = d / length;
    const on = 3.0;
    const gap = 5.0;
    for (var t = 0.0; t < length; t += on + gap) {
      canvas.drawLine(a + step * t, a + step * min(t + on, length), paint);
    }
  }

  void _ring(
    Canvas canvas,
    Offset at,
    Color color,
    Duration since,
    double alpha,
  ) {
    if (since >= _pulse) return;
    final f = since.inMicroseconds / _pulse.inMicroseconds;
    canvas.drawCircle(
      at,
      8 + 22 * f,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = color.withValues(alpha: (1 - f) * 0.8 * alpha),
    );
  }

  void _label(Canvas canvas, Offset at, TrafficHop hop, double alpha) {
    final text = hop.label.length > 12
        ? '${hop.label.substring(0, 11)}…'
        : hop.label;
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: labelStyle.copyWith(
          color: labelStyle.color!.withValues(alpha: alpha),
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    final origin = at + const Offset(10, -20);
    final box = RRect.fromRectAndRadius(
      (origin & tp.size).inflate(3),
      const Radius.circular(4),
    );
    canvas.drawRRect(
      box,
      Paint()..color = MapPalette.panelDark.withValues(alpha: 0.8 * alpha),
    );
    tp.paint(canvas, origin);
  }

  @override
  bool shouldRepaint(_TrafficPainter old) => true;
}
