import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../models/trail_graph.dart';
import '../models/trail_place.dart';
import '../l10n/app_localizations.dart';
import '../models/waypoint.dart';
import '../services/map_tile_cache_service.dart';
import '../services/trail_store.dart';
import '../services/waypoint_store.dart';
import '../theme/mesh_theme.dart';
import '../l10n/l10n.dart';

/// Plans walking routes offline over trails downloaded by area.
class TrailRoutingScreen extends StatefulWidget {
  /// Replaces the real store (tests).
  final TrailStore? store;
  const TrailRoutingScreen({super.key, this.store});

  @override
  State<TrailRoutingScreen> createState() => _TrailRoutingScreenState();
}

class _TrailRoutingScreenState extends State<TrailRoutingScreen> {
  late final TrailStore _store = widget.store ?? TrailStore();
  final _map = MapController();
  LatLng? _start;
  LatLng? _end;
  TrailRouteResult? _route;
  String? _message;
  var _busy = false;

  @override
  void initState() {
    super.initState();
    unawaited(
      _store.load().then((_) {
        if (mounted) setState(() {});
      }),
    );
  }

  @override
  void dispose() {
    if (widget.store == null) _store.dispose();
    super.dispose();
  }

  void _tap(LatLng point) {
    setState(() {
      _message = null;
      _route = null;
      if (_start == null || _end != null) {
        _start = point;
        _end = null;
      } else {
        _end = point;
      }
    });
    if (_end != null) unawaited(_plan());
  }

  Future<void> _plan() async {
    final a = _start!, b = _end!;
    final area = _store.areaFor(
      a.latitude,
      a.longitude,
      b.latitude,
      b.longitude,
    );
    if (area == null) {
      setState(() => _message = context.l10n.tr_needArea);
      return;
    }
    setState(() => _busy = true);
    try {
      final graph = await _store.graphFor(area);
      final route = graph.route(
        a.latitude,
        a.longitude,
        b.latitude,
        b.longitude,
      );
      if (!mounted) return;
      setState(() {
        _route = route;
        _message = switch (route.problem) {
          null => null,
          TrailRouteProblem.startTooFar => context.l10n.tr_startFar,
          TrailRouteProblem.endTooFar => context.l10n.tr_endFar,
          TrailRouteProblem.notConnected => context.l10n.tr_notJoined,
        };
      });
    } on FormatException {
      if (mounted) {
        setState(() => _message = context.l10n.tr_damaged);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  TrailBounds _visible() {
    final b = _map.camera.visibleBounds;
    return TrailBounds(
      south: b.south,
      west: b.west,
      north: b.north,
      east: b.east,
    );
  }

  Future<void> _download() async {
    final bounds = _visible();
    if (bounds.areaKm2 > maxTrailAreaKm2) {
      setState(
        () => _message = context.l10n.tr_zoomIn(
          maxTrailAreaKm2.round(),
          bounds.areaKm2.round(),
        ),
      );
      return;
    }
    final center = _map.camera.center;
    final name =
        '${center.latitude.toStringAsFixed(2)}, ${center.longitude.toStringAsFixed(2)}';
    setState(() {
      _busy = true;
      _message = context.l10n.tr_downloading;
    });
    try {
      final area = await _store.download(name, bounds);
      if (mounted) {
        setState(() => _message = context.l10n.tr_saved(_size(area.bytes)));
      }
    } on TrailDownloadException catch (e) {
      if (mounted) {
        setState(
          () => _message = switch (e.problem) {
            TrailDownloadProblem.tooLarge => context.l10n.tr_tooLarge,
            TrailDownloadProblem.storageFull => context.l10n.tr_full,
            TrailDownloadProblem.noTrails => context.l10n.tr_noTrails,
            TrailDownloadProblem.failed => context.l10n.tr_failed,
          },
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _size(int bytes) => bytes < 1024 * 1024
      ? '${(bytes / 1024).ceil()} KB'
      : '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';

  String _distance(double meters) => '${(meters / 1000).toStringAsFixed(1)} km';

  Future<void> _save() async {
    final route = _route;
    if (route == null || route.problem != null) return;
    final stamp = DateTime.now().microsecondsSinceEpoch;
    final store = context.read<WaypointStore>();
    final routeName = context.l10n.tr_routeName(_distance(route.meters));
    final points = thin(route.points, maxRoutePoints);
    await store.addImport(
      GpxImport(const [], [
        WaypointRoute(
          id: 'trail-$stamp',
          name: routeName,
          points: [
            for (final (i, p) in points.indexed)
              Waypoint(
                id: 'trail-$stamp-$i',
                name: '${i + 1}',
                lat: p.$1,
                lon: p.$2,
              ),
          ],
        ),
      ]),
    );
    if (mounted) setState(() => _message = context.l10n.tr_savedRoute);
  }

  Future<void> _search() async {
    final waypoints = context.read<WaypointStore>().waypoints;
    final places = [
      ...await _store.allPlaces(),
      for (final w in waypoints)
        TrailPlace(w.name, TrailPlaceKind.waypoint, w.lat, w.lon),
    ];
    if (!mounted) return;
    final picked = await showModalBottomSheet<TrailPlace>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _PlaceSearchSheet(places: places),
    );
    if (picked == null || !mounted) return;
    final point = LatLng(picked.lat, picked.lon);
    _map.move(point, 14);
    _tap(point);
  }

  void _showAreas() {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        builder: (sheet) => SafeArea(
          child: ListenableBuilder(
            listenable: _store,
            builder: (_, _) => ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  title: Text(context.l10n.tr_areas),
                  subtitle: Text(context.l10n.tr_used(_size(_store.usedBytes))),
                ),
                for (final area in _store.areas)
                  ListTile(
                    title: Text(area.name),
                    subtitle: Text(_size(area.bytes)),
                    trailing: IconButton(
                      tooltip: context.l10n.tr_deleteArea(area.name),
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => unawaited(_store.delete(area.id)),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tiles = context.read<MapTileCacheService>();
    final route = _route;
    final found = route != null && route.problem == null;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.tr_title),
        actions: [
          IconButton(
            tooltip: context.l10n.tr_search,
            icon: Icon(Icons.search),
            onPressed: _search,
          ),
          IconButton(
            tooltip: context.l10n.tr_areas,
            icon: const Icon(Icons.folder_outlined),
            onPressed: _showAreas,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: _map,
              options: MapOptions(
                initialCenter: const LatLng(39.5, -98.35),
                initialZoom: 3,
                interactionOptions: const InteractionOptions(
                  flags: ~InteractiveFlag.rotate,
                ),
                onTap: (_, p) => _tap(p),
              ),
              children: [
                tiles.buildTileLayer(context),
                PolygonLayer(
                  polygons: [
                    for (final a in _store.areas)
                      Polygon(
                        points: [
                          LatLng(a.bounds.south, a.bounds.west),
                          LatLng(a.bounds.north, a.bounds.west),
                          LatLng(a.bounds.north, a.bounds.east),
                          LatLng(a.bounds.south, a.bounds.east),
                        ],
                        color: Colors.transparent,
                        borderColor: MapPalette.selected,
                        borderStrokeWidth: 1.5,
                      ),
                  ],
                ),
                if (found)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: [
                          for (final p in route.points) LatLng(p.$1, p.$2),
                        ],
                        strokeWidth: 4,
                        color: MapPalette.online,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    if (_start case final p?)
                      Marker(
                        point: p,
                        width: 32,
                        height: 32,
                        child: Semantics(
                          label: context.l10n.tr_start,
                          child: Icon(Icons.trip_origin, size: 28),
                        ),
                      ),
                    if (_end case final p?)
                      Marker(
                        point: p,
                        width: 32,
                        height: 32,
                        child: Semantics(
                          label: context.l10n.tr_end,
                          child: const Icon(Icons.flag, size: 28),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    found
                        ? context.l10n.tr_route(_distance(route.meters))
                        : _start == null
                        ? context.l10n.tr_tapStart
                        : _end == null
                        ? context.l10n.tr_tapEnd
                        : '',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  if (_message case final m?)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(m),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _busy ? null : _download,
                          icon: Icon(Icons.download),
                          label: Text(context.l10n.tr_download),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: found && !_busy ? _save : null,
                          icon: Icon(Icons.save_outlined),
                          label: Text(context.l10n.tr_save),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.l10n.trail_safety,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceSearchSheet extends StatefulWidget {
  const _PlaceSearchSheet({required this.places});
  final List<TrailPlace> places;

  @override
  State<_PlaceSearchSheet> createState() => _PlaceSearchSheetState();
}

class _PlaceSearchSheetState extends State<_PlaceSearchSheet> {
  var _query = '';

  @override
  Widget build(BuildContext context) {
    final results = searchPlaces(widget.places, _query);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.7,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                key: const ValueKey('place-search'),
                autofocus: true,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  labelText: context.l10n.tr_searchLabel,
                  helperText: context.l10n.tr_searchHelp,
                  helperMaxLines: 3,
                ),
              ),
            ),
            if (_query.trim().isNotEmpty && results.isEmpty)
              Padding(
                padding: EdgeInsets.all(12),
                child: Text(context.l10n.tr_nothing),
              ),
            Expanded(
              child: ListView(
                children: [
                  for (final place in results)
                    ListTile(
                      title: Text(place.name),
                      subtitle: Text(placeKindLabel(context.l10n, place.kind)),
                      onTap: () => Navigator.of(context).pop(place),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The translated name for a kind of place.
String placeKindLabel(AppLocalizations l10n, TrailPlaceKind kind) =>
    switch (kind) {
      TrailPlaceKind.peak => l10n.place_peak,
      TrailPlaceKind.saddle => l10n.place_pass,
      TrailPlaceKind.spring => l10n.place_spring,
      TrailPlaceKind.hut => l10n.place_hut,
      TrailPlaceKind.campsite => l10n.place_campsite,
      TrailPlaceKind.viewpoint => l10n.place_viewpoint,
      TrailPlaceKind.shelter => l10n.place_shelter,
      TrailPlaceKind.trailhead => l10n.place_trailhead,
      TrailPlaceKind.town => l10n.place_town,
      TrailPlaceKind.locality => l10n.place_locality,
      TrailPlaceKind.waypoint => l10n.place_waypoint,
    };
