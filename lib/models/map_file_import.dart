import 'dart:convert';

import 'package:xml/xml.dart';

import 'waypoint.dart';

/// Reads waypoints and routes from GPX, KML or GeoJSON text, telling the
/// formats apart by their content. Throws [FormatException] when the text
/// is none of them.
GpxImport parseMapFile(String text, {String Function()? newId}) {
  final trimmed = text.trimLeft();
  if (trimmed.startsWith('{')) return parseGeoJson(text, newId: newId);
  if (RegExp(r'<kml[\s>]', caseSensitive: false).hasMatch(trimmed)) {
    return parseKml(text, newId: newId);
  }
  return parseGpx(text, newId: newId);
}

String Function() _ids(String prefix, String Function()? newId) {
  var counter = 0;
  return newId ??
      () => '$prefix-${DateTime.now().microsecondsSinceEpoch}-${counter++}';
}

String _nameOr(String? name, String fallback) =>
    (name != null && name.trim().isNotEmpty) ? name.trim() : fallback;

/// Reads KML placemarks: points become waypoints, and lines and polygon
/// outlines become routes, thinned to [maxRoutePoints].
GpxImport parseKml(String text, {String Function()? newId}) {
  final id = _ids('kml', newId);
  final XmlDocument doc;
  try {
    doc = XmlDocument.parse(text);
  } on XmlException catch (e) {
    throw FormatException('Not a KML file: ${e.message}');
  }
  if (doc.rootElement.localName.toLowerCase() != 'kml') {
    throw const FormatException('Not a KML file');
  }

  Waypoint? coord(String raw, String name, {String note = ''}) {
    final parts = raw.trim().split(',');
    if (parts.length < 2) return null;
    final lon = double.tryParse(parts[0]);
    final lat = double.tryParse(parts[1]);
    if (lat == null || lon == null || !validPosition(lat, lon)) return null;
    final ele = parts.length > 2 ? double.tryParse(parts[2]) : null;
    return Waypoint(
      id: id(),
      name: name,
      lat: lat,
      lon: lon,
      ele: ele,
      note: note,
    );
  }

  List<String> coordList(XmlElement e) {
    final c = e.findAllElements('coordinates', namespace: '*').firstOrNull;
    if (c == null) return const [];
    return c.innerText
        .trim()
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .toList();
  }

  final waypoints = <Waypoint>[];
  final routes = <WaypointRoute>[];
  var p = 0, r = 0;
  for (final mark in doc.findAllElements('Placemark', namespace: '*')) {
    final name = mark
        .findElements('name', namespace: '*')
        .firstOrNull
        ?.innerText;
    final note =
        mark
            .findElements('description', namespace: '*')
            .firstOrNull
            ?.innerText
            .trim() ??
        '';
    for (final point in mark.findAllElements('Point', namespace: '*')) {
      final c = coordList(point);
      if (c.isEmpty) continue;
      final w = coord(c.first, _nameOr(name, 'Waypoint ${++p}'), note: note);
      if (w != null) waypoints.add(w);
    }
    final lines = [
      ...mark.findAllElements('LineString', namespace: '*'),
      for (final poly in mark.findAllElements('Polygon', namespace: '*'))
        ...poly.findAllElements('outerBoundaryIs', namespace: '*'),
    ];
    for (final line in lines) {
      final pts = [
        for (final (i, c) in thin(coordList(line), maxRoutePoints).indexed)
          ?coord(c, '${i + 1}'),
      ];
      if (pts.length < 2) continue;
      routes.add(
        WaypointRoute(
          id: id(),
          name: _nameOr(name, 'Route ${++r}'),
          points: pts,
        ),
      );
    }
  }
  return GpxImport(waypoints, routes);
}

/// Reads GeoJSON points, lines and polygon outlines (a FeatureCollection,
/// a Feature or a bare geometry). Names come from the `name` or `title`
/// property.
GpxImport parseGeoJson(String text, {String Function()? newId}) {
  final id = _ids('geojson', newId);
  final Object? root;
  try {
    root = jsonDecode(text);
  } on FormatException catch (e) {
    throw FormatException('Not a GeoJSON file: ${e.message}');
  }
  if (root is! Map) throw const FormatException('Not a GeoJSON file');

  final waypoints = <Waypoint>[];
  final routes = <WaypointRoute>[];
  var p = 0, r = 0;

  Waypoint? point(Object? c, String name, {String note = ''}) {
    if (c is! List || c.length < 2) return null;
    final lon = c[0], lat = c[1];
    if (lon is! num || lat is! num) return null;
    if (!validPosition(lat.toDouble(), lon.toDouble())) return null;
    final ele = c.length > 2 && c[2] is num ? (c[2] as num).toDouble() : null;
    return Waypoint(
      id: id(),
      name: name,
      lat: lat.toDouble(),
      lon: lon.toDouble(),
      ele: ele,
      note: note,
    );
  }

  void line(Object? coords, String? name) {
    if (coords is! List) return;
    final pts = [
      for (final (i, c) in thin(coords, maxRoutePoints).indexed)
        ?point(c, '${i + 1}'),
    ];
    if (pts.length < 2) return;
    routes.add(
      WaypointRoute(id: id(), name: _nameOr(name, 'Route ${++r}'), points: pts),
    );
  }

  void geometry(Object? g, String? name, String note) {
    if (g is! Map) return;
    final coords = g['coordinates'];
    switch (g['type']) {
      case 'Point':
        final w = point(coords, _nameOr(name, 'Waypoint ${++p}'), note: note);
        if (w != null) waypoints.add(w);
      case 'MultiPoint':
        if (coords is List) {
          for (final c in coords) {
            final w = point(c, _nameOr(name, 'Waypoint ${++p}'), note: note);
            if (w != null) waypoints.add(w);
          }
        }
      case 'LineString':
        line(coords, name);
      case 'MultiLineString':
        if (coords is List) {
          for (final c in coords) {
            line(c, name);
          }
        }
      case 'Polygon':
        if (coords is List && coords.isNotEmpty) line(coords.first, name);
      case 'MultiPolygon':
        if (coords is List) {
          for (final poly in coords) {
            if (poly is List && poly.isNotEmpty) line(poly.first, name);
          }
        }
      case 'GeometryCollection':
        final list = g['geometries'];
        if (list is List) {
          for (final sub in list) {
            geometry(sub, name, note);
          }
        }
    }
  }

  void feature(Object? f) {
    if (f is! Map) return;
    final props = f['properties'];
    String? name;
    var note = '';
    if (props is Map) {
      final n = props['name'] ?? props['title'];
      if (n is String) name = n;
      final d = props['description'] ?? props['desc'];
      if (d is String) note = d.trim();
    }
    geometry(f['geometry'], name, note);
  }

  switch (root['type']) {
    case 'FeatureCollection':
      final features = root['features'];
      if (features is List) features.forEach(feature);
    case 'Feature':
      feature(root);
    case String _:
      geometry(root, null, '');
    default:
      throw const FormatException('Not a GeoJSON file');
  }
  return GpxImport(waypoints, routes);
}
