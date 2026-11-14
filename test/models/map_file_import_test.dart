import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/models/map_file_import.dart';

void main() {
  var n = 0;
  String id() => 'id${n++}';

  test('reads KML points, lines and polygon outlines', () {
    const kml = '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2"><Document>
  <Placemark><name>Trailhead</name><description>Parking</description>
    <Point><coordinates>-122.5,37.8,12</coordinates></Point></Placemark>
  <Placemark><name>Ridge route</name>
    <LineString><coordinates>-122.5,37.8 -122.49,37.81 -122.48,37.82</coordinates></LineString></Placemark>
  <Placemark><name>Search area</name><Polygon><outerBoundaryIs><LinearRing>
    <coordinates>-122.5,37.8 -122.4,37.8 -122.4,37.9 -122.5,37.8</coordinates>
  </LinearRing></outerBoundaryIs></Polygon></Placemark>
  <Placemark><name>Bad</name><Point><coordinates>500,95</coordinates></Point></Placemark>
</Document></kml>''';
    final r = parseMapFile(kml, newId: id);
    expect(r.waypoints.map((w) => w.name), ['Trailhead']);
    final w = r.waypoints.single;
    expect([w.lat, w.lon, w.ele, w.note], [37.8, -122.5, 12, 'Parking']);
    expect(r.routes.map((x) => x.name), ['Ridge route', 'Search area']);
    expect(r.routes.first.points, hasLength(3));
  });

  test('reads a GeoJSON FeatureCollection', () {
    const json = '''{"type":"FeatureCollection","features":[
      {"type":"Feature","properties":{"name":"Camp"},
       "geometry":{"type":"Point","coordinates":[8.5,47.3,410]}},
      {"type":"Feature","properties":{"title":"Path"},
       "geometry":{"type":"LineString","coordinates":[[8.5,47.3],[8.6,47.4]]}},
      {"type":"Feature","properties":{},
       "geometry":{"type":"MultiPoint","coordinates":[[8.7,47.5],[999,0]]}}
    ]}''';
    final r = parseMapFile(json, newId: id);
    expect(r.waypoints.map((w) => w.name), ['Camp', 'Waypoint 2']);
    expect(r.waypoints.first.ele, 410);
    expect(r.routes.single.name, 'Path');
  });

  test('reads a bare GeoJSON geometry', () {
    final r = parseMapFile(
      '{"type":"Polygon","coordinates":[[[1,1],[2,1],[2,2],[1,1]]]}',
      newId: id,
    );
    expect(r.routes.single.points, hasLength(4));
  });

  test('still reads GPX', () {
    const gpx =
        '<?xml version="1.0"?><gpx version="1.1" creator="t" '
        'xmlns="http://www.topografix.com/GPX/1/1">'
        '<wpt lat="1" lon="2"><name>A</name></wpt></gpx>';
    expect(parseMapFile(gpx, newId: id).waypoints.single.name, 'A');
  });

  test('rejects text that is none of the formats', () {
    expect(() => parseMapFile('{"hello":1}'), throwsFormatException);
    expect(() => parseMapFile('{not json'), throwsFormatException);
    expect(() => parseMapFile('<kml><broken'), throwsFormatException);
  });
}
