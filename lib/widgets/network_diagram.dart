import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/path_graph.dart';

/// One dot in the network diagram.
@immutable
class NetworkDot {
  const NetworkDot({
    required this.id,
    required this.center,
    required this.radius,
    required this.ring,
  });

  final String id;
  final Offset center;
  final double radius;

  /// Hops away from you; 0 is you.
  final int ring;
}

/// Where everything goes in a [NetworkDiagramPainter].
@immutable
class NetworkLayout {
  const NetworkLayout({
    required this.dots,
    required this.links,
    required this.rings,
    required this.center,
    required this.ringGap,
  });

  final Map<String, NetworkDot> dots;

  /// Links between two placed dots, busiest last so they draw on top.
  final List<PathLink> links;

  /// How many rings around you (not counting you).
  final int rings;
  final Offset center;
  final double ringGap;

  /// The dot under [p], allowing a finger-sized margin, or null.
  String? hit(Offset p, {double slop = 16}) {
    String? best;
    var bestD = double.infinity;
    for (final d in dots.values) {
      final dist = (d.center - p).distance;
      if (dist <= d.radius + slop && dist < bestD) {
        best = d.id;
        bestD = dist;
      }
    }
    return best;
  }
}

/// Places you in the middle and every repeater on a ring by how many hops
/// it usually is from you. Each ring after the first is ordered by the
/// average angle of the repeaters it links to on the ring inside, so links
/// cross less. Only the [maxNodes] busiest repeaters are drawn.
NetworkLayout layoutNetwork(PathGraph graph, Size size, {int maxNodes = 40}) {
  final keep = <String>{
    pathGraphSelf,
    ...graph.busiest.take(maxNodes).map((n) => n.id),
  };
  final columns = [
    for (final col in graph.columns()) [...col.where(keep.contains)],
  ]..removeWhere((c) => c.isEmpty);
  // columns()[0] is always you; keep it even if empty-filtered above.
  if (columns.isEmpty || columns.first.first != pathGraphSelf) {
    columns.insert(0, [pathGraphSelf]);
  }
  final rings = columns.length - 1;
  final center = Offset(size.width / 2, size.height / 2);
  final maxR = math.max(0.0, math.min(size.width, size.height) / 2 - 18);
  final gap = rings == 0 ? 0.0 : maxR / rings;
  final maxRelays = graph.busiest.isEmpty
      ? 1
      : math.max(1, graph.busiest.first.relays);

  // Neighbours in either direction, weighted by message count.
  final weights = <String, Map<String, int>>{};
  for (final l in graph.links) {
    if (!keep.contains(l.from) || !keep.contains(l.to)) continue;
    (weights[l.from] ??= {})[l.to] = (weights[l.from]?[l.to] ?? 0) + l.count;
    (weights[l.to] ??= {})[l.from] = (weights[l.to]?[l.from] ?? 0) + l.count;
  }

  final angle = <String, double>{pathGraphSelf: 0};
  final dots = <String, NetworkDot>{
    pathGraphSelf: NetworkDot(
      id: pathGraphSelf,
      center: center,
      radius: 11,
      ring: 0,
    ),
  };
  for (var ring = 1; ring <= rings; ring++) {
    final ids = [...columns[ring]];
    if (ring > 1) {
      double score(String id) {
        var sx = 0.0, sy = 0.0;
        for (final e in (weights[id] ?? const <String, int>{}).entries) {
          final a = angle[e.key];
          if (a == null) continue;
          sx += math.cos(a) * e.value;
          sy += math.sin(a) * e.value;
        }
        if (sx == 0 && sy == 0) return double.infinity;
        final a = math.atan2(sy, sx);
        return a < 0 ? a + 2 * math.pi : a;
      }

      final scores = {for (final id in ids) id: score(id)};
      ids.sort((a, b) => scores[a]!.compareTo(scores[b]!));
    }
    final r = gap * ring;
    for (var i = 0; i < ids.length; i++) {
      // Offset alternate rings by half a step so dots don't line up.
      final a =
          -math.pi / 2 +
          (i + (ring.isEven ? 0.5 : 0)) * 2 * math.pi / ids.length;
      final norm = a < 0 ? a + 2 * math.pi : a;
      angle[ids[i]] = norm;
      final relays = graph.nodes[ids[i]]?.relays ?? 0;
      dots[ids[i]] = NetworkDot(
        id: ids[i],
        center: center + Offset(math.cos(a) * r, math.sin(a) * r),
        radius: 4 + 6 * math.sqrt(relays / maxRelays),
        ring: ring,
      );
    }
  }

  final links = [
    for (final l in graph.links)
      if (dots.containsKey(l.from) && dots.containsKey(l.to)) l,
  ]..sort((a, b) => a.count.compareTo(b.count));

  return NetworkLayout(
    dots: dots,
    links: links,
    rings: rings,
    center: center,
    ringGap: gap,
  );
}

/// Draws a [NetworkLayout]: faint hop rings, links as lines as thick as
/// their traffic, and dots as big as how much each repeater relayed. Labels
/// go on you and the [labelCount] busiest repeaters.
class NetworkDiagramPainter extends CustomPainter {
  NetworkDiagramPainter({
    required this.layout,
    required this.labels,
    required this.nodeColor,
    required this.selfColor,
    required this.linkColor,
    required this.ringColor,
    required this.ambiguousColor,
    required this.ambiguous,
    required this.labelStyle,
    required this.labelBackground,
    this.labelCount = 12,
  });

  final NetworkLayout layout;

  /// Display name for each dot id.
  final Map<String, String> labels;
  final Color nodeColor;
  final Color selfColor;
  final Color linkColor;
  final Color ringColor;
  final Color ambiguousColor;
  final Set<String> ambiguous;
  final TextStyle labelStyle;
  final Color labelBackground;
  final int labelCount;

  @override
  void paint(Canvas canvas, Size size) {
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = ringColor;
    for (var i = 1; i <= layout.rings; i++) {
      canvas.drawCircle(layout.center, layout.ringGap * i, ringPaint);
    }

    final maxCount = layout.links.isEmpty
        ? 1
        : layout.links.map((l) => l.count).reduce(math.max);
    for (final l in layout.links) {
      final a = layout.dots[l.from]!.center, b = layout.dots[l.to]!.center;
      final t = l.count / maxCount;
      canvas.drawLine(
        a,
        b,
        Paint()
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 1 + 5 * t
          ..color = linkColor.withValues(alpha: 0.25 + 0.55 * t),
      );
    }

    for (final d in layout.dots.values) {
      final color = d.id == pathGraphSelf
          ? selfColor
          : ambiguous.contains(d.id)
          ? ambiguousColor
          : nodeColor;
      canvas.drawCircle(d.center, d.radius, Paint()..color = color);
      canvas.drawCircle(
        d.center,
        d.radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = labelBackground,
      );
    }

    final labelled = layout.dots.values.toList()
      ..sort((a, b) => b.radius.compareTo(a.radius));
    final show = {
      pathGraphSelf,
      ...labelled
          .where((d) => d.id != pathGraphSelf)
          .take(labelCount)
          .map((d) => d.id),
    };
    for (final id in show) {
      final d = layout.dots[id];
      if (d == null) continue;
      final tp = TextPainter(
        text: TextSpan(text: labels[id] ?? id, style: labelStyle),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '…',
      )..layout(maxWidth: 110);
      // Below the dot, nudged inside the canvas.
      var dx = d.center.dx - tp.width / 2;
      dx = dx.clamp(2.0, math.max(2.0, size.width - tp.width - 2));
      var dy = d.center.dy + d.radius + 2;
      if (dy + tp.height > size.height) {
        dy = d.center.dy - d.radius - tp.height - 2;
      }
      final rect = Rect.fromLTWH(dx - 3, dy - 1, tp.width + 6, tp.height + 2);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        Paint()..color = labelBackground,
      );
      tp.paint(canvas, Offset(dx, dy));
    }
  }

  @override
  bool shouldRepaint(NetworkDiagramPainter old) =>
      old.layout != layout ||
      old.nodeColor != nodeColor ||
      old.labelStyle != labelStyle ||
      old.labels != labels;
}
