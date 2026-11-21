import 'dart:math' as math;

/// Metres per degree of latitude (and of longitude at the equator).
const double _metresPerDegree = 111320;

/// A square of a fixed-size grid laid over the map, [size] metres a side.
/// Rows follow latitude; each row's columns are sized for that row's
/// latitude, so squares stay roughly square away from the equator.
class GridSquare {
  const GridSquare(this.row, this.col, this.size);

  /// The square holding [lat], [lon] on a grid of [size]-metre squares.
  factory GridSquare.at(double lat, double lon, int size) {
    final row = (lat * _metresPerDegree / size).floor();
    final col = (lon * _metresPerDegree * _cos(row, size) / size).floor();
    return GridSquare(row, col, size);
  }

  final int row;
  final int col;
  final int size;

  /// The square's corners: south-west and north-east, in degrees.
  ({double south, double west, double north, double east}) get bounds {
    final c = _cos(row, size);
    return (
      south: row * size / _metresPerDegree,
      north: (row + 1) * size / _metresPerDegree,
      west: col * size / (_metresPerDegree * c),
      east: (col + 1) * size / (_metresPerDegree * c),
    );
  }

  /// The square's centre, in degrees.
  ({double lat, double lon}) get centre {
    final b = bounds;
    return (lat: (b.south + b.north) / 2, lon: (b.west + b.east) / 2);
  }

  /// A stable id, for maps and sets.
  String get id => '$size:$row:$col';

  @override
  bool operator ==(Object other) =>
      other is GridSquare &&
      other.row == row &&
      other.col == col &&
      other.size == size;

  @override
  int get hashCode => Object.hash(row, col, size);

  /// The cosine of the latitude at the middle of [row], never below a small
  /// floor so squares near the poles stay finite.
  static double _cos(int row, int size) {
    final lat = (row + 0.5) * size / _metresPerDegree;
    return math.max(0.01, math.cos(lat * math.pi / 180));
  }
}

/// Distance in metres between two points (haversine).
double metresBetween(double lat1, double lon1, double lat2, double lon2) {
  const r = 6371000.0;
  final dLat = (lat2 - lat1) * math.pi / 180;
  final dLon = (lon2 - lon1) * math.pi / 180;
  final a =
      math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(lat1 * math.pi / 180) *
          math.cos(lat2 * math.pi / 180) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2);
  return 2 * r * math.asin(math.min(1, math.sqrt(a)));
}
