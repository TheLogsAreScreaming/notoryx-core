import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/models/wardrive.dart';
import 'package:meshcore_open/models/wardrive_coverage.dart';
import 'package:meshcore_open/models/wardrive_grid.dart';

final _t0 = DateTime.utc(2026, 11, 21, 12);

WardrivePing _ping(
  double lat,
  double lon, {
  List<WardriveReply> replies = const [],
  WardriveKind kind = WardriveKind.discovery,
  int minute = 0,
}) => WardrivePing(
  at: _t0.add(Duration(minutes: minute)),
  latitude: lat,
  longitude: lon,
  replies: replies,
  kind: kind,
);

const _both = WardriveReply(prefix: 'aa11', snrThere: 2, snrHere: 6);
const _oneWay = WardriveReply(prefix: 'bb22');
const _heard = WardriveReply(prefix: 'cc33', snrHere: -4, rssiHere: -100);

void main() {
  test('each square gets the best status of what happened in it', () {
    final cov = buildCoverage([
      _ping(41.3280, -73.0940, replies: [_both]),
      _ping(41.3280, -73.0940), // unheard, same square
      _ping(41.3400, -73.0940, replies: [_oneWay], kind: WardriveKind.channel),
      _ping(41.3500, -73.0940, replies: [_heard], kind: WardriveKind.passive),
      _ping(41.3600, -73.0940),
      _ping(41.3700, -73.0940, kind: WardriveKind.skipped),
    ], 300);
    SquareStatus at(double lat) =>
        cov[GridSquare.at(lat, -73.0940, 300)]!.status;
    expect(at(41.3280), SquareStatus.bothWays);
    expect(at(41.3400), SquareStatus.repeaterOnly);
    expect(at(41.3500), SquareStatus.passive);
    expect(at(41.3600), SquareStatus.noAnswer);
    expect(at(41.3700), SquareStatus.skipped);
    final first = cov[GridSquare.at(41.3280, -73.0940, 300)]!;
    expect(first.pings, 2);
    expect(first.heardPings, 1);
    expect(first.best, 2, reason: 'the weaker direction');
    expect(first.last, _t0);
  });

  test('a repeater heard by different prefix lengths counts once', () {
    final cov = buildCoverage([
      _ping(41.328, -73.094, replies: [_both]),
      _ping(
        41.328,
        -73.094,
        replies: [const WardriveReply(prefix: 'aa', snrHere: 9)],
        kind: WardriveKind.passive,
      ),
    ], 300);
    final sq = cov.values.single;
    expect(sq.repeaters, hasLength(1));
    final r = sq.repeaters.values.single;
    expect(r.count, 2);
    expect(r.bestHere, 9);
    expect(r.bestThere, 2);
  });

  test('showing one repeater keeps only its points', () {
    final cov = buildCoverage(
      [
        _ping(41.328, -73.094, replies: [_both, _oneWay]),
        _ping(41.340, -73.094, replies: [_oneWay]),
        _ping(41.350, -73.094),
      ],
      300,
      onlyRepeater: 'aa',
    );
    expect(cov, hasLength(1));
    expect(cov.values.single.repeaters.keys, ['aa11']);
  });

  test('smaller squares split what bigger ones merge', () {
    final pings = [
      _ping(41.3280, -73.0940, replies: [_both]),
      _ping(41.3290, -73.0940, replies: [_both]), // ~110 m north
    ];
    expect(buildCoverage(pings, 300), hasLength(1));
    expect(buildCoverage(pings, 100), hasLength(2));
  });

  test('repeater stats: squares, best and average, farthest', () {
    final stats = repeaterStats(
      [
        _ping(41.3280, -73.0940, replies: [_both]),
        _ping(
          41.3500,
          -73.0940,
          replies: [
            const WardriveReply(prefix: 'aa11', snrThere: 8, snrHere: 4),
          ],
        ),
        _ping(41.3500, -73.0940, replies: [_heard], kind: WardriveKind.passive),
        _ping(41.3700, -73.0940, kind: WardriveKind.skipped),
      ],
      300,
      positionOf: (p) => p == 'aa11' ? (lat: 41.3280, lon: -73.0940) : null,
    );
    expect(stats.map((s) => s.prefix), ['aa11', 'cc33']);
    final a = stats.first;
    expect(a.squares, 2);
    expect(a.link.best, 4);
    expect(a.link.average, 3);
    expect(a.farthestKm, closeTo(2.45, 0.05));
    expect(stats.last.farthestKm, isNull);
  });
}
