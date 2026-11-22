import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../connector/meshcore_connector.dart';
import '../l10n/l10n.dart';
import '../models/wardrive.dart';
import '../models/wardrive_coverage.dart';
import '../models/wardrive_grid.dart';
import '../services/map_tile_cache_service.dart';
import '../services/phone_location.dart' show backgroundFixNotice;
import '../services/wardrive_service.dart';
import '../theme/mesh_theme.dart';
import '../widgets/ember_backdrop.dart';
import '../widgets/instrument.dart';
import '../widgets/mesh_ui.dart';
import '../widgets/tactical_glass_panel.dart';
import 'wardrive_settings_sheet.dart';

/// Wardrive: ping from where you are and map which repeaters hear you. The
/// map is coloured in squares: green where a repeater heard you and you
/// heard it, teal where only a repeater heard you, blue for traffic heard on
/// its own, red where nothing answered, and an amber outline where pings
/// were skipped because the ground was covered. Tap a square for its
/// repeaters; pick a repeater to see only its coverage.
class WardriveScreen extends StatefulWidget {
  const WardriveScreen({super.key});

  @override
  State<WardriveScreen> createState() => _WardriveScreenState();
}

class _WardriveScreenState extends State<WardriveScreen> {
  /// A past session being looked at; null shows the live one.
  WardriveSession? _viewing;
  final _map = MapController();
  late final WardriveService _service;

  /// Whether the live map keeps you centred. Panning the map turns it off;
  /// the recentre button turns it back on.
  bool _follow = true;
  bool _mapReady = false;
  ({double lat, double lon})? _followed;

  /// Coverage square size in metres: 100 or 300.
  int _gridSize = WardriveService.coverSquareMetres;

  /// Whether the map shows every saved drive, not just this one.
  bool _allDrives = false;

  /// A repeater prefix: only its coverage is shown.
  String? _onlyRepeater;

  /// The square last tapped, outlined with lines to its repeaters.
  GridSquare? _selected;

  @override
  void initState() {
    super.initState();
    _service = context.read<WardriveService>();
    _service.addListener(_onService);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The screen-off GPS notification speaks the app's language.
    final l10n = context.l10n;
    backgroundFixNotice = (
      title: l10n.wardrive_notifTitle,
      text: l10n.wardrive_notifText,
    );
  }

  @override
  void dispose() {
    _service.removeListener(_onService);
    _map.dispose();
    super.dispose();
  }

  /// Keeps the live map on your position as it moves.
  void _onService() {
    if (_viewing != null || !_follow || !_mapReady) return;
    final here = _service.position;
    if (here == null || here == _followed) return;
    _followed = here;
    _map.move(LatLng(here.lat, here.lon), _map.camera.zoom);
  }

  void _recentre() {
    setState(() => _follow = true);
    _followed = null;
    _onService();
  }

  String _name(MeshCoreConnector c, String prefix) {
    for (final contact in c.allContactsUnfiltered) {
      if (contact.publicKeyHex.toLowerCase().startsWith(prefix)) {
        return contact.name;
      }
    }
    return prefix.toUpperCase();
  }

  /// Where the repeater with [prefix] is, when the radio knows.
  ({double lat, double lon})? _positionOf(MeshCoreConnector c, String prefix) {
    for (final contact in c.allContactsUnfiltered) {
      if (!contact.publicKeyHex.toLowerCase().startsWith(prefix)) continue;
      final lat = contact.latitude, lon = contact.longitude;
      if (lat == null || lon == null || (lat == 0 && lon == 0)) return null;
      return (lat: lat, lon: lon);
    }
    return null;
  }

  void _showSquare(SquareSummary sq) {
    final l10n = context.l10n;
    final c = context.read<MeshCoreConnector>();
    final last = sq.last;
    showMeshSheet<void>(
      context,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BottomSheetHeader(
              title: l10n.wardrive_squareTitle,
              subtitle: [
                l10n.wardrive_squareSummary(
                  sq.pings,
                  sq.heardPings,
                  sq.passivePoints,
                ),
                if (last != null)
                  l10n.wardrive_squareLast(
                    TimeOfDay.fromDateTime(last.toLocal()).format(context),
                  ),
              ].join(' · '),
            ),
            if (sq.status == SquareStatus.skipped)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l10n.wardrive_kindSkipped),
              )
            else if (sq.repeaters.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l10n.wardrive_squareNoRepeaters),
              ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final r in sq.ranked)
                    InstrumentRow(
                      title: _name(c, r.prefix),
                      subtitle: _replyText(
                        WardriveReply(
                          prefix: r.prefix,
                          snrThere: r.bestThere,
                          snrHere: r.bestHere,
                        ),
                      ),
                      trailing: TextButton(
                        onPressed: () {
                          Navigator.of(sheet).pop();
                          setState(() => _onlyRepeater = r.prefix);
                        },
                        child: Text(l10n.wardrive_showOnly),
                      ),
                      divider: false,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showRepeaterStats(Iterable<WardrivePing> pings) {
    final l10n = context.l10n;
    final c = context.read<MeshCoreConnector>();
    final stats = repeaterStats(
      pings,
      _gridSize,
      positionOf: (prefix) => _positionOf(c, prefix),
    );
    String db(double? v) => v == null ? '—' : v.toStringAsFixed(1);
    showMeshSheet<void>(
      context,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BottomSheetHeader(title: l10n.wardrive_repeaterStats),
            if (stats.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l10n.wardrive_noRepeatersHeard),
              ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final st in stats)
                    ListTile(
                      key: ValueKey('wardrive-stats-${st.prefix}'),
                      leading: const Icon(Icons.cell_tower),
                      title: Text(_name(c, st.prefix)),
                      subtitle: Text(
                        [
                          l10n.wardrive_statsLine(
                            st.squares,
                            db(st.link.best),
                            db(st.link.average),
                          ),
                          if (st.farthestKm != null)
                            l10n.wardrive_farthest(
                              st.farthestKm!.toStringAsFixed(1),
                            ),
                        ].join(' · '),
                      ),
                      onTap: () {
                        Navigator.of(sheet).pop();
                        setState(() => _onlyRepeater = st.prefix);
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  String _replyText(WardriveReply r) {
    final l10n = context.l10n;
    final there = r.snrThere, here = r.snrHere;
    if (there != null && here != null) {
      return l10n.wardrive_replyDetail(
        there.toStringAsFixed(1),
        here.toStringAsFixed(1),
      );
    }
    if (there != null) {
      return l10n.wardrive_replyThere(there.toStringAsFixed(1));
    }
    if (here != null) {
      return l10n.wardrive_replyHere(here.toStringAsFixed(1));
    }
    return l10n.wardrive_replyRelayed;
  }

  void _showHistory(WardriveService service) {
    final l10n = context.l10n;
    showMeshSheet<void>(
      context,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BottomSheetHeader(title: l10n.wardrive_history),
            if (service.sessions.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l10n.wardrive_noSessions),
              ),
            for (final s in service.sessions)
              ListTile(
                key: ValueKey('wardrive-session-${s.id}'),
                leading: const Icon(Icons.route_outlined),
                title: Text(
                  MaterialLocalizations.of(
                    context,
                  ).formatMediumDate(s.startedAt.toLocal()),
                ),
                subtitle: Text(
                  l10n.wardrive_sessionSummary(s.sentCount, s.heardCount),
                ),
                trailing: IconButton(
                  tooltip: l10n.wardrive_delete,
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    unawaited(service.deleteSession(s.id));
                    Navigator.of(sheet).pop();
                  },
                ),
                onTap: () {
                  Navigator.of(sheet).pop();
                  setState(() {
                    _viewing = s;
                    _follow = false;
                  });
                  if (s.pings.isNotEmpty) {
                    _map.move(
                      LatLng(s.pings.last.latitude, s.pings.last.longitude),
                      13,
                    );
                  }
                },
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final service = context.watch<WardriveService>();
    final connector = context.watch<MeshCoreConnector>();
    final session = _viewing ?? service.active;
    final pings = session?.pings ?? const <WardrivePing>[];
    final mapped = _allDrives
        ? [
            for (final s in service.sessions) ...s.pings,
            if (service.active != null) ...service.active!.pings,
          ]
        : pings;
    final coverage = buildCoverage(
      mapped,
      _gridSize,
      onlyRepeater: _onlyRepeater,
    );
    final selected = _selected == null ? null : coverage[_selected];
    final here = _viewing == null ? service.position : null;
    final center = here != null
        ? LatLng(here.lat, here.lon)
        : pings.isNotEmpty
        ? LatLng(pings.last.latitude, pings.last.longitude)
        : const LatLng(39.8, -98.6);
    final status = _viewing != null
        ? null
        : service.pinging
        ? l10n.wardrive_pinging
        : switch (service.wait) {
            WardriveWait.noPosition => l10n.wardrive_waitPosition,
            WardriveWait.noRadio => l10n.wardrive_waitRadio,
            WardriveWait.noChannel => l10n.wardrive_waitChannel,
            WardriveWait.noTraceTarget => l10n.wardrive_waitTraceTarget,
            WardriveWait.notMoved => l10n.wardrive_waitMove,
            WardriveWait.covered => l10n.wardrive_waitCovered,
            WardriveWait.none => null,
          };
    final settings = service.settings;
    final accuracy = service.accuracy;
    final noise = service.noiseFloor;
    final liveLine = _viewing != null || !service.running
        ? null
        : [
            accuracy == null
                ? l10n.wardrive_noGps
                : l10n.wardrive_gpsAccuracy(accuracy.round()),
            if (noise != null) l10n.wardrive_noise(noise),
            if (settings.passive) l10n.wardrive_passiveOn,
          ].join(' · ');
    final explainer = switch (settings.mode) {
      WardriveMode.discovery => l10n.wardrive_explainer,
      WardriveMode.trace => l10n.wardrive_explainTrace,
      WardriveMode.channel => l10n.wardrive_explainChannel,
      WardriveMode.hybrid => l10n.wardrive_explainHybrid,
    };

    return EmberBackdrop(
      scene: EmberScene.more,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          title: Text(l10n.wardrive_title),
          actions: [
            IconButton(
              key: const ValueKey('wardrive-repeater-stats'),
              tooltip: l10n.wardrive_repeaterStats,
              icon: const Icon(Icons.cell_tower),
              onPressed: () => _showRepeaterStats(mapped),
            ),
            IconButton(
              key: const ValueKey('wardrive-settings'),
              tooltip: l10n.wardrive_settings,
              icon: const Icon(Icons.tune),
              onPressed: () => showWardriveSettings(context),
            ),
            IconButton(
              key: const ValueKey('wardrive-history'),
              tooltip: l10n.wardrive_history,
              icon: const Icon(Icons.history),
              onPressed: () => _showHistory(service),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: MeshSpace.lg),
              child: TacticalGlassPanel(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: ReadoutStrip([
                  Readout('${session?.sentCount ?? 0}', l10n.wardrive_pings),
                  Readout(
                    '${session?.heardCount ?? 0}',
                    l10n.wardrive_heard,
                    color: MeshPalette.signal,
                  ),
                  Readout(
                    '${session?.repeaterCount ?? 0}',
                    l10n.wardrive_repeaters,
                  ),
                  Readout(
                    '${session?.skippedCount ?? 0}',
                    l10n.wardrive_skipped,
                  ),
                ]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                MeshSpace.lg,
                MeshSpace.sm,
                MeshSpace.lg,
                MeshSpace.sm,
              ),
              child: _viewing != null
                  ? InstrumentButton(
                      key: const ValueKey('wardrive-back-live'),
                      label: l10n.wardrive_backToLive,
                      icon: Icons.my_location,
                      onPressed: () {
                        setState(() => _viewing = null);
                        _recentre();
                      },
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: SegmentedButton<WardriveMode>(
                            key: const ValueKey('wardrive-mode'),
                            showSelectedIcon: false,
                            style: const ButtonStyle(
                              visualDensity: VisualDensity.compact,
                            ),
                            segments: [
                              ButtonSegment(
                                value: WardriveMode.discovery,
                                label: Text(l10n.wardrive_modeDiscovery),
                              ),
                              ButtonSegment(
                                value: WardriveMode.trace,
                                label: Text(l10n.wardrive_modeTrace),
                              ),
                              ButtonSegment(
                                value: WardriveMode.channel,
                                label: Text(l10n.wardrive_modeChannel),
                              ),
                              ButtonSegment(
                                value: WardriveMode.hybrid,
                                label: Text(l10n.wardrive_modeHybrid),
                              ),
                            ],
                            selected: {settings.mode},
                            onSelectionChanged: (v) => service.update(
                              settings.copyWith(mode: v.first),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            if (_viewing == null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  MeshSpace.lg,
                  0,
                  MeshSpace.lg,
                  MeshSpace.sm,
                ),
                child: Row(
                  children: [
                    if (service.running) ...[
                      Expanded(
                        child: InstrumentButton(
                          key: const ValueKey('wardrive-ping-now'),
                          label: l10n.wardrive_pingNow,
                          icon: Icons.podcasts,
                          onPressed: service.pinging
                              ? null
                              : () => unawaited(service.pingNow()),
                        ),
                      ),
                      const SizedBox(width: MeshSpace.sm),
                    ],
                    Expanded(
                      child: InstrumentButton(
                        key: const ValueKey('wardrive-toggle'),
                        label: service.running
                            ? l10n.wardrive_stop
                            : l10n.wardrive_start,
                        icon: service.running
                            ? Icons.stop_rounded
                            : Icons.play_arrow_rounded,
                        danger: service.running,
                        onPressed: service.running
                            ? () => unawaited(service.stop())
                            : connector.isConnected
                            ? () => unawaited(service.start())
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            if (liveLine != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  liveLine,
                  key: const ValueKey('wardrive-live-line'),
                  style: TextStyle(color: MeshPalette.ink3, fontSize: 12),
                ),
              ),
            if (status != null)
              Padding(
                padding: const EdgeInsets.only(bottom: MeshSpace.sm),
                child: Text(
                  status,
                  style: TextStyle(color: MeshPalette.ink3, fontSize: 13),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  MeshSpace.lg,
                  0,
                  MeshSpace.lg,
                  MeshSpace.lg,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(glassRadius),
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: _map,
                        options: MapOptions(
                          initialCenter: center,
                          initialZoom: 15,
                          onMapReady: () {
                            _mapReady = true;
                            _onService();
                          },
                          onPositionChanged: (_, hasGesture) {
                            if (hasGesture && _follow) {
                              setState(() => _follow = false);
                            }
                          },
                          onTap: (_, point) {
                            final square = GridSquare.at(
                              point.latitude,
                              point.longitude,
                              _gridSize,
                            );
                            final summary = coverage[square];
                            setState(() => _selected = summary?.square);
                            if (summary != null) _showSquare(summary);
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName:
                                MapTileCacheService.userAgentPackageName,
                          ),
                          PolygonLayer(
                            polygons: [
                              for (final sq in coverage.values)
                                _squarePolygon(
                                  sq,
                                  selected: sq.square == _selected,
                                  byLink: _onlyRepeater != null,
                                ),
                            ],
                          ),
                          if (selected != null)
                            PolylineLayer(
                              polylines: [
                                for (final r in selected.repeaters.values)
                                  if (_positionOf(connector, r.prefix)
                                      case final at?)
                                    Polyline(
                                      points: [
                                        LatLng(
                                          selected.square.centre.lat,
                                          selected.square.centre.lon,
                                        ),
                                        LatLng(at.lat, at.lon),
                                      ],
                                      strokeWidth: 3,
                                      color: r.best == null
                                          ? MeshPalette.tertiary
                                          : MeshTheme.snrColor(
                                              r.best!,
                                              blocked: false,
                                            ),
                                    ),
                              ],
                            ),
                          MarkerLayer(
                            markers: [
                              if (here != null)
                                Marker(
                                  point: LatLng(here.lat, here.lon),
                                  width: 18,
                                  height: 18,
                                  child: const _HereDot(),
                                ),
                            ],
                          ),
                        ],
                      ),
                      Positioned(
                        left: MeshSpace.sm,
                        top: MeshSpace.sm,
                        right: MeshSpace.sm,
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            ActionChip(
                              key: const ValueKey('wardrive-grid-size'),
                              avatar: const Icon(Icons.grid_on, size: 16),
                              label: Text(l10n.wardrive_squareSize(_gridSize)),
                              onPressed: () => setState(() {
                                _gridSize = _gridSize == 300 ? 100 : 300;
                                _selected = null;
                              }),
                            ),
                            ActionChip(
                              key: const ValueKey('wardrive-all-drives'),
                              avatar: Icon(
                                _allDrives ? Icons.layers : Icons.route,
                                size: 16,
                              ),
                              label: Text(
                                _allDrives
                                    ? l10n.wardrive_allDrives
                                    : l10n.wardrive_thisDrive,
                              ),
                              onPressed: () => setState(() {
                                _allDrives = !_allDrives;
                                _selected = null;
                              }),
                            ),
                            if (_onlyRepeater != null)
                              InputChip(
                                key: const ValueKey('wardrive-only-repeater'),
                                avatar: const Icon(Icons.cell_tower, size: 16),
                                label: Text(
                                  l10n.wardrive_showingOnly(
                                    _name(connector, _onlyRepeater!),
                                  ),
                                ),
                                onDeleted: () => setState(() {
                                  _onlyRepeater = null;
                                  _selected = null;
                                }),
                                deleteButtonTooltipMessage:
                                    l10n.wardrive_clearFilter,
                              ),
                          ],
                        ),
                      ),
                      if (_viewing == null && !_follow && here != null)
                        Positioned(
                          right: MeshSpace.sm,
                          bottom: MeshSpace.sm,
                          child: FloatingActionButton.small(
                            key: const ValueKey('wardrive-recentre'),
                            tooltip: l10n.wardrive_recentre,
                            onPressed: _recentre,
                            child: const Icon(Icons.my_location),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                MeshSpace.lg,
                0,
                MeshSpace.lg,
                MeshSpace.sm,
              ),
              child: _Legend(byLink: _onlyRepeater != null),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                MeshSpace.lg,
                0,
                MeshSpace.lg,
                MeshSpace.lg,
              ),
              child: Text(
                explainer,
                style: TextStyle(color: MeshPalette.ink3, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The colour a square of [status] is filled with.
Color _statusColor(SquareStatus status) => switch (status) {
  SquareStatus.bothWays => MeshPalette.signal,
  SquareStatus.repeaterOnly => MeshPalette.tertiary,
  SquareStatus.passive => MeshPalette.secondary,
  SquareStatus.noAnswer => MeshPalette.alert,
  SquareStatus.skipped => MeshPalette.warn,
};

/// One coverage square. Normally coloured by [SquareStatus]; with [byLink]
/// (one repeater shown) by that repeater's best link instead. Skipped
/// squares are outlined only.
Polygon _squarePolygon(
  SquareSummary sq, {
  required bool selected,
  required bool byLink,
}) {
  final b = sq.square.bounds;
  final status = sq.status;
  final best = sq.best;
  final color = byLink && best != null
      ? MeshTheme.snrColor(best, blocked: false)
      : _statusColor(status);
  final outlineOnly = status == SquareStatus.skipped;
  return Polygon(
    points: [
      LatLng(b.south, b.west),
      LatLng(b.north, b.west),
      LatLng(b.north, b.east),
      LatLng(b.south, b.east),
    ],
    color: outlineOnly ? Colors.transparent : color.withValues(alpha: 0.45),
    borderColor: selected ? Colors.white : color,
    borderStrokeWidth: selected ? 3 : (outlineOnly ? 2 : 1),
  );
}

/// What the square colours mean.
class _Legend extends StatelessWidget {
  const _Legend({required this.byLink});

  /// One repeater is shown, so squares are shaded by its link instead.
  final bool byLink;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final entries = [
      (SquareStatus.bothWays, l10n.wardrive_legendBothWays),
      (SquareStatus.repeaterOnly, l10n.wardrive_legendRepeaterOnly),
      (SquareStatus.passive, l10n.wardrive_legendPassive),
      (SquareStatus.noAnswer, l10n.wardrive_legendNoAnswer),
      (SquareStatus.skipped, l10n.wardrive_legendSkipped),
    ];
    return Wrap(
      spacing: 10,
      runSpacing: 4,
      children: [
        for (final (status, label) in entries)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: status == SquareStatus.skipped
                      ? null
                      : _statusColor(status).withValues(alpha: 0.7),
                  border: Border.all(color: _statusColor(status), width: 2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(color: MeshPalette.ink3, fontSize: 12),
              ),
            ],
          ),
      ],
    );
  }
}

/// Where you are now on the live map.
class _HereDot extends StatelessWidget {
  const _HereDot();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.wardrive_youAreHere,
      child: Container(
        decoration: BoxDecoration(
          color: MeshPalette.signal,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
        ),
      ),
    );
  }
}
