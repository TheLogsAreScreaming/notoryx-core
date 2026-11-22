import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/models/wardrive.dart';
import 'package:meshcore_open/utils/wardrive_export.dart';

final _drive = WardriveSession(
  id: 'd1',
  startedAt: DateTime.utc(2026, 11, 21, 12),
  endedAt: DateTime.utc(2026, 11, 21, 13),
  noise: [NoiseSample(DateTime.utc(2026, 11, 21, 12, 1), -110)],
  pings: [
    WardrivePing(
      at: DateTime.utc(2026, 11, 21, 12, 1),
      latitude: 41.328,
      longitude: -73.094,
      accuracy: 4,
      noiseFloor: -110,
      replies: const [
        WardriveReply(prefix: 'aa11', snrThere: 2, snrHere: 6, rssiHere: -90),
      ],
    ),
    WardrivePing(
      at: DateTime.utc(2026, 11, 21, 12, 2),
      latitude: 41.33,
      longitude: -73.09,
      kind: WardriveKind.passive,
      replies: const [WardriveReply(prefix: '=cmd', snrHere: -3)],
    ),
    WardrivePing(
      at: DateTime.utc(2026, 11, 21, 12, 3),
      latitude: 41.34,
      longitude: -73.09,
      kind: WardriveKind.skipped,
    ),
  ],
);

void main() {
  test('GeoJSON round-trips everything', () {
    final text = exportWardrive(_drive, WardriveFormat.geojson);
    final back = importWardrive(text)!;
    expect(back.id, 'd1');
    expect(back.startedAt, _drive.startedAt);
    expect(back.noise.single.dbm, -110);
    expect(back.pings, hasLength(3));
    expect(back.pings.first.replies.single.snrThere, 2);
    expect(back.pings.first.accuracy, 4);
    expect(back.pings[1].kind, WardriveKind.passive);
    expect(back.pings[2].kind, WardriveKind.skipped);
    final geo = jsonDecode(text) as Map<String, dynamic>;
    expect(geo['type'], 'FeatureCollection');
    expect((geo['features'] as List).first['geometry']['coordinates'], [
      -73.094,
      41.328,
    ]);
  });

  test('other files are turned away on import', () {
    expect(importWardrive('not json'), isNull);
    expect(
      importWardrive('{"type":"FeatureCollection","features":[]}'),
      isNull,
    );
    expect(importWardrive(exportWardrive(_drive, WardriveFormat.gpx)), isNull);
  });

  test('CSV: one row per repeater, formulas defused', () {
    final csv = exportWardrive(_drive, WardriveFormat.csv).trim().split('\n');
    expect(csv.first, startsWith('time_utc,latitude,longitude,kind'));
    expect(csv, hasLength(4));
    expect(csv[1], contains('"aa11",2.0,6.0,-90'));
    expect(csv[2], contains('"\'=cmd"'));
    expect(csv[3], contains(',skipped,'));
  });

  test('GPX and KML are well formed and name repeaters', () {
    final gpx = exportWardrive(
      _drive,
      WardriveFormat.gpx,
      nameOf: (p) => p == 'aa11' ? 'Hill <A>' : p,
    );
    expect(gpx, contains('<wpt lat="41.328" lon="-73.094">'));
    expect(gpx, contains('Hill &lt;A&gt;'));
    expect(gpx.trim(), endsWith('</gpx>'));
    final kml = exportWardrive(_drive, WardriveFormat.kml);
    expect(kml, contains('<coordinates>-73.094,41.328</coordinates>'));
    expect(kml, contains('<styleUrl>#skipped</styleUrl>'));
    expect(kml.trim(), endsWith('</Document></kml>'));
  });
}
