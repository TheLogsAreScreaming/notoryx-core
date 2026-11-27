import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/helpers/streak_geometry.dart';

void main() {
  // An L: 30 across, then 40 down.
  final line = StreakLine(const [Offset(0, 0), Offset(30, 0), Offset(30, 40)]);

  test('length adds up the legs', () {
    expect(line.length, 70);
    expect(StreakLine(const []).length, 0);
    expect(StreakLine(const [Offset(5, 5)]).length, 0);
  });

  test('points along the line move at an even speed across corners', () {
    expect(line.pointAt(0), Offset.zero);
    expect(line.pointAt(15), const Offset(15, 0));
    expect(line.pointAt(30), const Offset(30, 0));
    expect(line.pointAt(50), const Offset(30, 20));
    expect(line.pointAt(-5), Offset.zero);
    expect(line.pointAt(500), const Offset(30, 40));
  });

  test('a slice keeps the corner it spans', () {
    expect(line.slice(20, 40), const [
      Offset(20, 0),
      Offset(30, 0),
      Offset(30, 10),
    ]);
    expect(line.slice(5, 10), const [Offset(5, 0), Offset(10, 0)]);
    expect(line.slice(-10, 5), const [Offset(0, 0), Offset(5, 0)]);
    expect(line.slice(40, 40), isEmpty);
    expect(line.slice(50, 20), isEmpty);
  });

  test('tail is about a third of the route, within limits', () {
    expect(streakTailLength(300), closeTo(105, 1e-9));
    expect(streakTailLength(60), 40);
    expect(streakTailLength(20), 20);
    expect(streakTailLength(2000), 160);
  });
}
