import 'dart:math';
import 'dart:ui';

/// Distance along a polyline, for drawing a streak that moves along it at
/// an even speed however long each leg is.
class StreakLine {
  StreakLine(this.points) : _cum = _cumulative(points);

  final List<Offset> points;
  final List<double> _cum;

  /// Total length in the points' units.
  double get length => _cum.isEmpty ? 0 : _cum.last;

  static List<double> _cumulative(List<Offset> points) {
    final out = <double>[];
    var total = 0.0;
    for (var i = 0; i < points.length; i++) {
      if (i > 0) total += (points[i] - points[i - 1]).distance;
      out.add(total);
    }
    return out;
  }

  /// The point [d] along the line, clamped to its ends.
  Offset pointAt(double d) {
    if (points.isEmpty) return Offset.zero;
    if (d <= 0 || points.length == 1) return points.first;
    for (var i = 1; i < points.length; i++) {
      if (_cum[i] >= d) {
        final seg = _cum[i] - _cum[i - 1];
        final f = seg > 0 ? (d - _cum[i - 1]) / seg : 0.0;
        return Offset.lerp(points[i - 1], points[i], f)!;
      }
    }
    return points.last;
  }

  /// The part of the line from [a] to [b], with the corners in between.
  /// Empty when [b] is not past [a].
  List<Offset> slice(double a, double b) {
    final from = max(0.0, a);
    final to = min(length, b);
    if (points.length < 2 || to <= from) return const [];
    final out = [pointAt(from)];
    for (var i = 1; i < points.length - 1; i++) {
      if (_cum[i] > from && _cum[i] < to) out.add(points[i]);
    }
    out.add(pointAt(to));
    return out;
  }
}

/// How long a streak's bright tail is on screen: about a third of the
/// route, but never shorter than [minTail] or longer than [maxTail].
double streakTailLength(
  double routeLength, {
  double minTail = 40,
  double maxTail = 160,
}) => (routeLength * 0.35).clamp(min(minTail, routeLength), maxTail);
