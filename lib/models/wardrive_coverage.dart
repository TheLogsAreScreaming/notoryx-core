import 'wardrive.dart';
import 'wardrive_grid.dart';

/// What a square of the coverage map shows, best first.
enum SquareStatus {
  /// A repeater heard a ping here and was heard back: both directions
  /// measured.
  bothWays,

  /// A repeater heard a ping here, but only one direction is known (a
  /// channel ping repeated further along).
  repeaterOnly,

  /// Only traffic heard on its own here; no ping got an answer.
  passive,

  /// Pings went out here and nothing answered.
  noAnswer,

  /// Only pings that were skipped because the ground was covered.
  skipped,
}

/// How one repeater did in one square (or overall).
class RepeaterLink {
  RepeaterLink(this.prefix);

  final String prefix;
  int count = 0;

  /// Best link: the weaker measured direction of the best reply.
  double? best;
  double? bestHere;
  double? bestThere;
  double _sum = 0;
  int _measured = 0;

  /// Average link over replies that measured one.
  double? get average => _measured == 0 ? null : _sum / _measured;

  void add(WardriveReply r) {
    count++;
    final link = r.link;
    if (link != null) {
      _sum += link;
      _measured++;
      if (best == null || link > best!) best = link;
    }
    final here = r.snrHere, there = r.snrThere;
    if (here != null && (bestHere == null || here > bestHere!)) {
      bestHere = here;
    }
    if (there != null && (bestThere == null || there > bestThere!)) {
      bestThere = there;
    }
  }
}

/// Everything recorded in one square.
class SquareSummary {
  SquareSummary(this.square);

  final GridSquare square;
  int pings = 0;
  int heardPings = 0;
  int passivePoints = 0;
  int skippedPoints = 0;
  bool _twoWay = false;
  DateTime? last;

  /// Repeaters seen here, by prefix.
  final Map<String, RepeaterLink> repeaters = {};

  SquareStatus get status {
    if (_twoWay) return SquareStatus.bothWays;
    if (heardPings > 0) return SquareStatus.repeaterOnly;
    if (passivePoints > 0) return SquareStatus.passive;
    if (pings > 0) return SquareStatus.noAnswer;
    return SquareStatus.skipped;
  }

  /// The best link of any repeater here.
  double? get best {
    double? b;
    for (final r in repeaters.values) {
      final v = r.best;
      if (v != null && (b == null || v > b)) b = v;
    }
    return b;
  }

  /// Repeaters here, best link first.
  List<RepeaterLink> get ranked =>
      repeaters.values.toList()
        ..sort((a, b) => (b.best ?? -99).compareTo(a.best ?? -99));

  void _add(WardrivePing p) {
    if (last == null || p.at.isAfter(last!)) last = p.at;
    switch (p.kind) {
      case WardriveKind.skipped:
        skippedPoints++;
        return;
      case WardriveKind.passive:
        passivePoints++;
      default:
        pings++;
        if (p.heard) heardPings++;
    }
    for (final r in p.replies) {
      if (p.sent && r.snrHere != null && r.snrThere != null) _twoWay = true;
      final key = repeaters.keys.firstWhere(
        r.matches,
        orElse: () => r.prefix.toLowerCase(),
      );
      repeaters.putIfAbsent(key, () => RepeaterLink(key)).add(r);
    }
  }
}

/// The coverage map: [pings] grouped into squares [size] metres a side.
/// With [onlyRepeater], only points that repeater answered (or was heard
/// in) count.
Map<GridSquare, SquareSummary> buildCoverage(
  Iterable<WardrivePing> pings,
  int size, {
  String? onlyRepeater,
}) {
  final squares = <GridSquare, SquareSummary>{};
  for (final p in pings) {
    var point = p;
    if (onlyRepeater != null) {
      final replies = [
        for (final r in p.replies)
          if (r.matches(onlyRepeater)) r,
      ];
      if (replies.isEmpty) continue;
      point = WardrivePing(
        at: p.at,
        latitude: p.latitude,
        longitude: p.longitude,
        replies: replies,
        kind: p.kind,
      );
    }
    final square = GridSquare.at(point.latitude, point.longitude, size);
    squares.putIfAbsent(square, () => SquareSummary(square))._add(point);
  }
  return squares;
}

/// One repeater across a drive (or all drives).
class RepeaterStats {
  RepeaterStats(this.prefix);

  final String prefix;
  final RepeaterLink link = RepeaterLink('');
  final Set<GridSquare> _squares = {};

  /// Farthest point (km) it answered or was heard at, when its position is
  /// known.
  double? farthestKm;

  int get squares => _squares.length;
}

/// Per-repeater stats for [pings], counting squares of [size] metres.
/// [positionOf] gives a repeater's position from its prefix, when known,
/// for the farthest distance. Most squares first.
List<RepeaterStats> repeaterStats(
  Iterable<WardrivePing> pings,
  int size, {
  ({double lat, double lon})? Function(String prefix)? positionOf,
}) {
  final byPrefix = <String, RepeaterStats>{};
  for (final p in pings) {
    if (p.kind == WardriveKind.skipped) continue;
    for (final r in p.replies) {
      final key = byPrefix.keys.firstWhere(
        r.matches,
        orElse: () => r.prefix.toLowerCase(),
      );
      final stats = byPrefix.putIfAbsent(key, () => RepeaterStats(key));
      stats.link.add(r);
      stats._squares.add(GridSquare.at(p.latitude, p.longitude, size));
      final at = positionOf?.call(key);
      if (at != null) {
        final km =
            metresBetween(at.lat, at.lon, p.latitude, p.longitude) / 1000;
        if (stats.farthestKm == null || km > stats.farthestKm!) {
          stats.farthestKm = km;
        }
      }
    }
  }
  return byPrefix.values.toList()..sort((a, b) {
    final bySquares = b.squares.compareTo(a.squares);
    return bySquares != 0
        ? bySquares
        : (b.link.best ?? -99).compareTo(a.link.best ?? -99);
  });
}
