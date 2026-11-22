import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../connector/meshcore_connector.dart';
import '../l10n/l10n.dart';
import '../models/wardrive.dart';
import '../services/map_tile_cache_service.dart';
import '../services/phone_location.dart' show backgroundFixNotice;
import '../services/wardrive_service.dart';
import '../theme/mesh_theme.dart';
import '../widgets/ember_backdrop.dart';
import '../widgets/instrument.dart';
import '../widgets/mesh_ui.dart';
import '../widgets/tactical_glass_panel.dart';
import 'wardrive_settings_sheet.dart';

/// Wardrive: ping from where you are and map which repeaters hear you. Green
/// markers were heard (brighter for a better link), red ones weren't, blue
/// ones are traffic heard on its own, and amber rings are pings skipped
/// because the spot was already covered.
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

  void _showPing(WardrivePing ping) {
    final l10n = context.l10n;
    final c = context.read<MeshCoreConnector>();
    showMeshSheet<void>(
      context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BottomSheetHeader(
              title: TimeOfDay.fromDateTime(ping.at.toLocal()).format(context),
              subtitle:
                  '${ping.latitude.toStringAsFixed(4)}, '
                  '${ping.longitude.toStringAsFixed(4)}',
            ),
            if (ping.kind == WardriveKind.skipped)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l10n.wardrive_kindSkipped),
              )
            else if (!ping.heard)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l10n.wardrive_noReplies),
              ),
            if (ping.kind == WardriveKind.passive)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                child: Text(l10n.wardrive_kindPassive),
              ),
            for (final r in ping.replies)
              InstrumentRow(
                title: _name(c, r.prefix),
                subtitle: _replyText(r),
                trailing: r.link == null ? null : SignalReadout(r.link!),
                divider: false,
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
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName:
                                MapTileCacheService.userAgentPackageName,
                          ),
                          MarkerLayer(
                            markers: [
                              for (final p in pings)
                                Marker(
                                  point: LatLng(p.latitude, p.longitude),
                                  width: 22,
                                  height: 22,
                                  child: Semantics(
                                    button: true,
                                    label: context.l10n.a11y_wardrivePing,
                                    child: GestureDetector(
                                      onTap: () => _showPing(p),
                                      child: _PingDot(ping: p),
                                    ),
                                  ),
                                ),
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

/// A point on the map: green when heard (shaded by the link), red when not,
/// a smaller blue dot for traffic heard on its own, and a hollow amber ring
/// for a ping skipped because the spot was already covered.
class _PingDot extends StatelessWidget {
  const _PingDot({required this.ping});

  final WardrivePing ping;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (ping.kind == WardriveKind.skipped) {
      return Semantics(
        label: l10n.wardrive_kindSkipped,
        button: true,
        child: Container(
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: MeshPalette.warn, width: 3),
          ),
        ),
      );
    }
    final snr = ping.bestSnr;
    final passive = ping.kind == WardriveKind.passive;
    final color = passive
        ? MeshPalette.secondary
        : snr == null
        ? MeshPalette.alert
        : MeshTheme.snrColor(snr, blocked: false);
    return Semantics(
      label: passive
          ? l10n.wardrive_kindPassive
          : snr == null
          ? l10n.wardrive_noReplies
          : 'SNR ${snr.toStringAsFixed(1)} dB',
      button: true,
      child: Container(
        margin: EdgeInsets.all(passive ? 5 : 0),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.85),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: passive ? 1.5 : 2),
        ),
      ),
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
