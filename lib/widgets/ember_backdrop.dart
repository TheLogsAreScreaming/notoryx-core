import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/mesh_theme.dart';

/// Which main screen the backdrop sits behind; each places its glows a
/// little differently so moving between tabs doesn't look like a repeat.
enum EmberScene { home, chats, nodes, more }

/// The frosted-ember ground: the theme's background, a warm glow from the
/// accent colour, a second softer glow, and faint topographic contours.
/// Glass panels in front of it pick these up through their translucency.
///
/// Painted once and cached; it only repaints when the size or theme
/// changes.
class EmberBackdrop extends StatelessWidget {
  const EmberBackdrop({
    super.key,
    required this.child,
    this.scene = EmberScene.home,
  });

  final Widget child;
  final EmberScene scene;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    // The second glow is the theme's own second and third hue, so each tab
    // reads as two colors, not one accent on grey.
    final second = switch (scene) {
      EmberScene.chats => MeshPalette.secondary,
      EmberScene.nodes => MeshPalette.tertiary,
      EmberScene.home => MeshPalette.secondary,
      EmberScene.more => MeshPalette.tertiary,
    };
    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: CustomPaint(
            painter: EmberPainter(
              scene: scene,
              ground: MeshPalette.bg,
              glow: MeshPalette.accent,
              second: second,
              contour: MeshPalette.ink,
              dark: dark,
              // Pink Overload's glossy glints; no other theme has them.
              sparkle:
                  identical(
                    MeshPalette.current,
                    BastionTheme.pinkOverload.palette,
                  )
                  ? [MeshPalette.magenta, Colors.white, MeshPalette.tertiary]
                  : null,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// Paints the [EmberBackdrop]. Positions are laid out on a 390 x 844 phone
/// and scaled to the real size.
class EmberPainter extends CustomPainter {
  EmberPainter({
    required this.scene,
    required this.ground,
    required this.glow,
    required this.second,
    required this.contour,
    required this.dark,
    this.sparkle,
  });

  final EmberScene scene;
  final Color ground;
  final Color glow;
  final Color second;
  final Color contour;
  final bool dark;

  /// Colors for small four-point glints scattered over the ground, or null
  /// for none. They are fixed per scene and never move.
  final List<Color>? sparkle;

  static const _w = 390.0;
  static const _h = 844.0;

  /// (centre x, centre y, radius, strength) for the two glows, in phone
  /// units.
  List<(double, double, double, double)> get _glows => switch (scene) {
    EmberScene.home => [(90, 70, 250, 0.64), (370, 560, 240, 0.48)],
    EmberScene.chats => [(360, 60, 260, 0.60), (0, 660, 240, 0.44)],
    EmberScene.nodes => [(160, 0, 250, 0.60), (400, 720, 240, 0.42)],
    EmberScene.more => [(320, 40, 250, 0.60), (20, 600, 240, 0.44)],
  };

  /// Contour bands as y offsets of the first line; each band has three.
  List<double> get _bands => switch (scene) {
    EmberScene.home => [120, 520],
    EmberScene.chats => [300, 700],
    EmberScene.nodes => [240, 640],
    EmberScene.more => [180, 600],
  };

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = ground);
    final sx = size.width / _w;
    final sy = size.height / _h;
    // A wide window stretches the layout; size glows by the shorter axis
    // so they stay round.
    final s = sx < sy ? sx : sy;
    final fade = dark ? 1.0 : 0.7;

    for (final (i, (cx, cy, r, strength)) in _glows.indexed) {
      final colour = i == 0 ? glow : second;
      final centre = Offset(cx * sx, cy * sy);
      final radius = r * s * 1.15;
      canvas.drawCircle(
        centre,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              colour.withValues(alpha: strength * fade),
              colour.withValues(alpha: 0),
            ],
            stops: const [0, 0.7],
          ).createShader(Rect.fromCircle(center: centre, radius: radius)),
      );
    }

    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = contour.withValues(alpha: dark ? 0.08 : 0.07);
    for (final top in _bands) {
      for (var k = 0; k < 3; k++) {
        final y = top + k * 45;
        final path = Path()
          ..moveTo(-20 * sx, y * sy)
          ..cubicTo(
            (80 + k * 10) * sx,
            (y - 60) * sy,
            (180 + k * 10) * sx,
            (y + 60) * sy,
            (300 + k * 5) * sx,
            (y - 10) * sy,
          )
          ..cubicTo(
            360 * sx,
            (y - 25) * sy,
            420 * sx,
            (y + 20) * sy,
            440 * sx,
            (y + 20) * sy,
          );
        canvas.drawPath(path, line);
      }
    }

    final glints = sparkle;
    if (glints != null && glints.isNotEmpty) {
      _paintSparkle(canvas, size, glints);
    }
  }

  /// A fixed scatter of glints: the same seed per scene gives the same
  /// picture every time, so nothing flickers between frames or screens.
  void _paintSparkle(Canvas canvas, Size size, List<Color> colors) {
    final rnd = math.Random(17 + scene.index * 101);
    final count = (size.width * size.height / 9000).clamp(18, 60).round();
    // Big glints stay in the side margins so none sits under text; the
    // rest of the ground only gets tiny, faint dots.
    const gutter = 22.0;
    for (var i = 0; i < count; i++) {
      final big = rnd.nextDouble() < 0.35;
      final x = big
          ? (rnd.nextBool()
                ? rnd.nextDouble() * gutter
                : size.width - rnd.nextDouble() * gutter)
          : rnd.nextDouble() * size.width;
      final centre = Offset(x, rnd.nextDouble() * size.height);
      final r = big ? 5 + rnd.nextDouble() * 5 : 1.2 + rnd.nextDouble() * 1.2;
      final colour = colors[i % colors.length];
      final alpha = big ? 0.6 : 0.25 + rnd.nextDouble() * 0.2;
      final paint = Paint()..color = colour.withValues(alpha: alpha);
      if (r < 3) {
        canvas.drawCircle(centre, r * 0.6, paint);
        continue;
      }
      // Four-point star with pinched sides.
      final w = r * 0.18;
      final path = Path()
        ..moveTo(centre.dx, centre.dy - r)
        ..quadraticBezierTo(
          centre.dx + w,
          centre.dy - w,
          centre.dx + r,
          centre.dy,
        )
        ..quadraticBezierTo(
          centre.dx + w,
          centre.dy + w,
          centre.dx,
          centre.dy + r,
        )
        ..quadraticBezierTo(
          centre.dx - w,
          centre.dy + w,
          centre.dx - r,
          centre.dy,
        )
        ..quadraticBezierTo(
          centre.dx - w,
          centre.dy - w,
          centre.dx,
          centre.dy - r,
        )
        ..close();
      if (big) {
        // A soft halo so the larger glints read as shine, not confetti.
        canvas.drawCircle(
          centre,
          r * 0.9,
          Paint()
            ..color = colour.withValues(alpha: 0.16)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        );
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(EmberPainter old) =>
      old.scene != scene ||
      old.ground != ground ||
      old.glow != glow ||
      old.second != second ||
      old.contour != contour ||
      old.dark != dark ||
      !_sameColors(old.sparkle, sparkle);

  static bool _sameColors(List<Color>? a, List<Color>? b) {
    if (a == null || b == null) return a == b;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
