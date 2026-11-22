import 'dart:convert';

import '../models/wardrive.dart';

/// File formats a drive can be exported in.
enum WardriveFormat {
  gpx('gpx', 'application/gpx+xml'),
  kml('kml', 'application/vnd.google-earth.kml+xml'),
  csv('csv', 'text/csv'),
  geojson('geojson', 'application/geo+json');

  const WardriveFormat(this.extension, this.mimeType);

  final String extension;
  final String mimeType;
}

/// [session] as text in [format]. [nameOf] names a repeater from its key
/// prefix (falls back to the prefix).
String exportWardrive(
  WardriveSession session,
  WardriveFormat format, {
  String Function(String prefix)? nameOf,
}) {
  final name = nameOf ?? (p) => p.toUpperCase();
  return switch (format) {
    WardriveFormat.gpx => _gpx(session, name),
    WardriveFormat.kml => _kml(session, name),
    WardriveFormat.csv => _csv(session),
    WardriveFormat.geojson => _geojson(session),
  };
}

String _xml(String s) => s
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&apos;');

String _db(double? v) => v == null ? '—' : '${v.toStringAsFixed(1)} dB';

/// A one-line description of a point: its kind and who answered.
String _describe(WardrivePing p, String Function(String) name) {
  final who = [
    for (final r in p.replies)
      '${name(r.prefix)} (there ${_db(r.snrThere)}, here ${_db(r.snrHere)})',
  ];
  final head = p.kind.name;
  if (p.kind == WardriveKind.skipped) return head;
  return who.isEmpty ? '$head: no answer' : '$head: ${who.join('; ')}';
}

String _gpx(WardriveSession s, String Function(String) name) {
  final b = StringBuffer()
    ..writeln('<?xml version="1.0" encoding="UTF-8"?>')
    ..writeln(
      '<gpx version="1.1" creator="NOTORYX Core" '
      'xmlns="http://www.topografix.com/GPX/1/1">',
    )
    ..writeln(
      '  <metadata><time>${s.startedAt.toUtc().toIso8601String()}'
      '</time></metadata>',
    );
  for (final p in s.pings) {
    b
      ..writeln('  <wpt lat="${p.latitude}" lon="${p.longitude}">')
      ..writeln('    <time>${p.at.toUtc().toIso8601String()}</time>')
      ..writeln('    <name>${_xml(p.kind.name)}</name>')
      ..writeln('    <desc>${_xml(_describe(p, name))}</desc>')
      ..writeln('  </wpt>');
  }
  b
    ..writeln('  <trk><name>Wardrive</name><trkseg>')
    ..writeAll([
      for (final p in s.pings)
        '    <trkpt lat="${p.latitude}" lon="${p.longitude}">'
            '<time>${p.at.toUtc().toIso8601String()}</time></trkpt>\n',
    ])
    ..writeln('  </trkseg></trk>')
    ..writeln('</gpx>');
  return b.toString();
}

/// KML colours are aabbggrr.
const _kmlStyles = {
  'heard': 'ff22aa44',
  'unheard': 'ff3344dd',
  'passive': 'ffdd8833',
  'skipped': 'ff1199ee',
};

String _kmlStyle(WardrivePing p) => switch (p.kind) {
  WardriveKind.skipped => 'skipped',
  WardriveKind.passive => 'passive',
  _ => p.heard ? 'heard' : 'unheard',
};

String _kml(WardriveSession s, String Function(String) name) {
  final b = StringBuffer()
    ..writeln('<?xml version="1.0" encoding="UTF-8"?>')
    ..writeln('<kml xmlns="http://www.opengis.net/kml/2.2"><Document>')
    ..writeln(
      '  <name>Wardrive ${s.startedAt.toUtc().toIso8601String()}</name>',
    );
  for (final e in _kmlStyles.entries) {
    b.writeln(
      '  <Style id="${e.key}"><IconStyle><color>${e.value}</color>'
      '<scale>0.8</scale></IconStyle></Style>',
    );
  }
  for (final p in s.pings) {
    b
      ..writeln('  <Placemark>')
      ..writeln('    <name>${_xml(p.kind.name)}</name>')
      ..writeln('    <description>${_xml(_describe(p, name))}</description>')
      ..writeln(
        '    <TimeStamp><when>${p.at.toUtc().toIso8601String()}</when></TimeStamp>',
      )
      ..writeln('    <styleUrl>#${_kmlStyle(p)}</styleUrl>')
      ..writeln(
        '    <Point><coordinates>${p.longitude},${p.latitude}'
        '</coordinates></Point>',
      )
      ..writeln('  </Placemark>');
  }
  b.writeln('</Document></kml>');
  return b.toString();
}

/// Quotes a CSV text cell, and stops a spreadsheet reading it as a formula.
String _cell(String s) {
  final safe = RegExp(r'^[=+\-@]').hasMatch(s) ? "'$s" : s;
  return '"${safe.replaceAll('"', '""')}"';
}

String _csv(WardriveSession s) {
  final b = StringBuffer(
    'time_utc,latitude,longitude,kind,accuracy_m,noise_dbm,'
    'repeater,snr_there_db,snr_here_db,rssi_here_dbm\n',
  );
  String n(num? v) => v == null ? '' : '$v';
  for (final p in s.pings) {
    final head =
        '${p.at.toUtc().toIso8601String()},${p.latitude},${p.longitude},'
        '${p.kind.name},${n(p.accuracy)},${n(p.noiseFloor)}';
    if (p.replies.isEmpty) {
      b.writeln('$head,,,,');
      continue;
    }
    for (final r in p.replies) {
      b.writeln(
        '$head,${_cell(r.prefix)},${n(r.snrThere)},${n(r.snrHere)},'
        '${n(r.rssiHere)}',
      );
    }
  }
  return b.toString();
}

/// Marks a GeoJSON file as a drive this app can read back.
const _marker = 'notoryx_wardrive';

String _geojson(WardriveSession s) {
  final features = [
    for (final p in s.pings)
      {
        'type': 'Feature',
        'geometry': {
          'type': 'Point',
          'coordinates': [p.longitude, p.latitude],
        },
        'properties': p.toJson()
          ..remove('lat')
          ..remove('lon'),
      },
  ];
  return const JsonEncoder.withIndent(' ').convert({
    'type': 'FeatureCollection',
    _marker: 1,
    'id': s.id,
    'startedAt': s.startedAt.toIso8601String(),
    if (s.endedAt != null) 'endedAt': s.endedAt!.toIso8601String(),
    if (s.noise.isNotEmpty) 'noise': [for (final x in s.noise) x.toJson()],
    'features': features,
  });
}

/// Reads a drive back from a GeoJSON file this app exported. Null when the
/// text isn't one (wrong format, or no points).
WardriveSession? importWardrive(String text) {
  try {
    final data = jsonDecode(text);
    if (data is! Map || data[_marker] == null) return null;
    final pings = <WardrivePing>[];
    for (final f in data['features'] as List? ?? const []) {
      if (f is! Map) continue;
      final geometry = f['geometry'];
      final props = f['properties'];
      if (geometry is! Map || props is! Map) continue;
      final coords = geometry['coordinates'];
      if (coords is! List || coords.length < 2) continue;
      pings.add(
        WardrivePing.fromJson({
          ...Map<String, dynamic>.from(props),
          'lon': coords[0],
          'lat': coords[1],
        }),
      );
    }
    if (pings.isEmpty) return null;
    pings.sort((a, b) => a.at.compareTo(b.at));
    return WardriveSession(
      id: data['id'] as String? ?? '${pings.first.at.microsecondsSinceEpoch}',
      startedAt:
          DateTime.tryParse(data['startedAt'] as String? ?? '') ??
          pings.first.at,
      endedAt:
          DateTime.tryParse(data['endedAt'] as String? ?? '') ?? pings.last.at,
      pings: pings,
      noise: [
        for (final n in data['noise'] as List? ?? const [])
          NoiseSample.fromJson(Map<String, dynamic>.from(n as Map)),
      ],
    );
  } on Object {
    return null;
  }
}
