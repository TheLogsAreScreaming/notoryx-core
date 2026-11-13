import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../connector/meshcore_connector.dart';
import '../l10n/app_localizations.dart';
import '../l10n/l10n.dart';
import '../models/app_settings.dart';
import '../models/position_watch.dart';
import '../services/app_settings_service.dart';
import '../services/position_watch_service.dart';
import '../services/waypoint_store.dart';
import '../theme/mesh_theme.dart';
import '../widgets/ember_backdrop.dart';
import '../widgets/instrument.dart';
import '../widgets/mesh_ui.dart';

/// Notification title and body for [alert].
({String title, String body}) positionAlertText(
  AppLocalizations l10n,
  PositionAlert alert, {
  String? trailName,
  bool imperial = false,
}) => switch (alert.kind) {
  PositionAlertKind.enteredZone => (
    title: l10n.zones_alertEnteredTitle(alert.zone!.name),
    body: l10n.zones_alertEnteredBody(alert.name, alert.zone!.name),
  ),
  PositionAlertKind.leftZone => (
    title: l10n.zones_alertLeftTitle(alert.zone!.name),
    body: l10n.zones_alertLeftBody(alert.name, alert.zone!.name),
  ),
  PositionAlertKind.offTrail => (
    title: l10n.zones_alertOffTrailTitle,
    body: l10n.zones_alertOffTrailBody(
      alert.name,
      formatShortDistance(alert.meters ?? 0, imperial: imperial),
      trailName ?? l10n.zones_trail,
    ),
  ),
};

/// Slider stops for zone radius and off-trail limit, in metres.
const _radiusStops = <double>[
  50, 100, 200, 300, 500, 750, 1000, 1500, 2000, 3000, 5000, 10000, //
];
const _offTrailStops = <double>[25, 50, 75, 100, 150, 200, 300, 500, 1000];

int _nearest(List<double> stops, double v) {
  var best = 0;
  for (var i = 1; i < stops.length; i++) {
    if ((stops[i] - v).abs() < (stops[best] - v).abs()) best = i;
  }
  return best;
}

/// Tools > Zone & trail alerts.
class ZoneAlertsScreen extends StatelessWidget {
  const ZoneAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final watch = context.watch<PositionWatchService?>();
    final imperial = context.select<AppSettingsService, bool>(
      (s) => s.settings.unitSystem == UnitSystem.imperial,
    );
    String dist(double m) => formatShortDistance(m, imperial: imperial);

    return EmberBackdrop(
      scene: EmberScene.more,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          foregroundColor: MeshPalette.ink,
          title: Text(l10n.zones_title),
        ),
        floatingActionButton: watch == null
            ? null
            : FloatingActionButton.extended(
                key: const ValueKey('zones-add'),
                icon: const Icon(Icons.add_location_alt_outlined),
                label: Text(l10n.zones_add),
                onPressed: () => _editZone(context, watch, null),
              ),
        body: watch == null
            ? const SizedBox.shrink()
            : SafeArea(
                top: false,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    MeshSpace.lg,
                    MeshSpace.sm,
                    MeshSpace.lg,
                    96,
                  ),
                  children: [
                    MeshCard(
                      margin: EdgeInsets.zero,
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          SwitchListTile(
                            key: const ValueKey('zones-enabled'),
                            title: Text(l10n.zones_enabled),
                            subtitle: Text(l10n.zones_enabledHint),
                            value: watch.enabled,
                            onChanged: watch.setEnabled,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                            child: Row(
                              children: [
                                Text(
                                  l10n.zones_watch,
                                  style: TextStyle(color: MeshPalette.ink2),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: SegmentedButton<WatchScope>(
                                    segments: [
                                      ButtonSegment(
                                        value: WatchScope.favorites,
                                        icon: const Icon(Icons.star_outline),
                                        label: Text(l10n.zones_scopeFavorites),
                                      ),
                                      ButtonSegment(
                                        value: WatchScope.everyone,
                                        icon: const Icon(Icons.groups_outlined),
                                        label: Text(l10n.zones_scopeEveryone),
                                      ),
                                    ],
                                    selected: {watch.scope},
                                    onSelectionChanged: (v) =>
                                        watch.setScope(v.first),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SwitchListTile(
                            title: Text(l10n.zones_includeSelf),
                            value: watch.includeSelf,
                            onChanged: watch.setIncludeSelf,
                          ),
                        ],
                      ),
                    ),
                    InstrumentLabel(l10n.zones_zones),
                    if (watch.zones.isEmpty)
                      MeshCard(
                        margin: EdgeInsets.zero,
                        child: Text(
                          l10n.zones_none,
                          style: TextStyle(color: MeshPalette.ink2),
                        ),
                      )
                    else
                      MeshCard(
                        margin: EdgeInsets.zero,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          children: [
                            for (final z in watch.zones)
                              ListTile(
                                key: ValueKey('zone-${z.id}'),
                                leading: const Icon(Icons.radar),
                                title: Text(z.name),
                                subtitle: Text(
                                  '${dist(z.radiusMeters)} · '
                                  '${alertOnLabel(l10n, z.alertOn)}',
                                ),
                                trailing: IconButton(
                                  tooltip: l10n.zones_delete,
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => watch.deleteZone(z.id),
                                ),
                                onTap: () => _editZone(context, watch, z),
                              ),
                          ],
                        ),
                      ),
                    InstrumentLabel(l10n.zones_trail),
                    _TrailCard(watch: watch, dist: dist),
                  ],
                ),
              ),
      ),
    );
  }

  static String alertOnLabel(AppLocalizations l10n, ZoneAlertOn on) =>
      switch (on) {
        ZoneAlertOn.enter => l10n.zones_onEnter,
        ZoneAlertOn.leave => l10n.zones_onLeave,
        ZoneAlertOn.both => l10n.zones_onBoth,
      };

  Future<void> _editZone(
    BuildContext context,
    PositionWatchService watch,
    Zone? existing,
  ) async {
    final connector = context.read<MeshCoreConnector>();
    final waypoints = context.read<WaypointStore>().waypoints;
    final imperial =
        context.read<AppSettingsService>().settings.unitSystem ==
        UnitSystem.imperial;
    final l10n = context.l10n;

    // Where a zone can be centred.
    final centers = <_Center>[
      if (existing != null)
        (label: existing.name, lat: existing.lat, lon: existing.lon),
      if (connector.selfLatitude case final lat?)
        if (connector.selfLongitude case final lon?)
          if (!(lat == 0 && lon == 0))
            (label: l10n.zones_centerMyRadio, lat: lat, lon: lon),
      for (final w in waypoints)
        (label: l10n.zones_centerWaypoint(w.name), lat: w.lat, lon: w.lon),
    ];
    if (centers.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.zones_noCenter)));
      return;
    }

    final saved = await showDialog<Zone>(
      context: context,
      builder: (_) =>
          _ZoneDialog(existing: existing, centers: centers, imperial: imperial),
    );
    if (saved == null) return;
    final ok = await watch.saveZone(saved);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.zones_full(PositionWatchService.maxZones))),
      );
    }
  }
}

typedef _Center = ({String label, double lat, double lon});

/// Name, centre, radius and when to alert, for a new or edited zone.
class _ZoneDialog extends StatefulWidget {
  const _ZoneDialog({
    required this.existing,
    required this.centers,
    required this.imperial,
  });

  final Zone? existing;
  final List<_Center> centers;
  final bool imperial;

  @override
  State<_ZoneDialog> createState() => _ZoneDialogState();
}

class _ZoneDialogState extends State<_ZoneDialog> {
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  var _center = 0;
  late var _radius = _nearest(
    _radiusStops,
    widget.existing?.radiusMeters ?? 300,
  );
  late var _on = widget.existing?.alertOn ?? ZoneAlertOn.both;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    final c = widget.centers[_center];
    final n = _name.text.trim();
    Navigator.pop(
      context,
      Zone(
        id:
            widget.existing?.id ??
            DateTime.now().microsecondsSinceEpoch.toRadixString(36),
        name: n.isEmpty ? context.l10n.zones_defaultName : n,
        lat: c.lat,
        lon: c.lon,
        radiusMeters: _radiusStops[_radius],
        alertOn: _on,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(widget.existing == null ? l10n.zones_add : l10n.zones_edit),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              key: const ValueKey('zone-name'),
              controller: _name,
              autofocus: widget.existing == null,
              maxLength: 40,
              decoration: InputDecoration(labelText: l10n.zones_name),
            ),
            DropdownButtonFormField<int>(
              key: const ValueKey('zone-center'),
              initialValue: _center,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.zones_center),
              items: [
                for (var i = 0; i < widget.centers.length; i++)
                  DropdownMenuItem(
                    value: i,
                    child: Text(
                      widget.centers[i].label,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (v) => setState(() => _center = v ?? 0),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.zones_radius(
                formatShortDistance(
                  _radiusStops[_radius],
                  imperial: widget.imperial,
                ),
              ),
            ),
            Slider(
              value: _radius.toDouble(),
              max: (_radiusStops.length - 1).toDouble(),
              divisions: _radiusStops.length - 1,
              onChanged: (v) => setState(() => _radius = v.round()),
            ),
            Text(l10n.zones_alertOn),
            const SizedBox(height: 8),
            SegmentedButton<ZoneAlertOn>(
              segments: [
                for (final o in ZoneAlertOn.values)
                  ButtonSegment(
                    value: o,
                    label: Text(ZoneAlertsScreen.alertOnLabel(l10n, o)),
                  ),
              ],
              selected: {_on},
              onSelectionChanged: (v) => setState(() => _on = v.first),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.common_cancel),
        ),
        FilledButton(
          key: const ValueKey('zone-save'),
          onPressed: _save,
          child: Text(l10n.common_save),
        ),
      ],
    );
  }
}

class _TrailCard extends StatelessWidget {
  const _TrailCard({required this.watch, required this.dist});

  final PositionWatchService watch;
  final String Function(double meters) dist;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final options = watch.trails();
    final selected = options.any((t) => t.ref == watch.trailRef)
        ? watch.trailRef
        : null;
    final limit = _nearest(_offTrailStops, watch.offTrailMeters);
    return MeshCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.zones_trailHint,
            style: TextStyle(color: MeshPalette.ink2, fontSize: 13),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String?>(
            key: const ValueKey('zones-trail'),
            initialValue: selected,
            isExpanded: true,
            items: [
              DropdownMenuItem(value: null, child: Text(l10n.zones_trailNone)),
              for (final t in options)
                DropdownMenuItem(
                  value: t.ref,
                  child: Text(t.name, overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: watch.setTrail,
          ),
          if (selected != null) ...[
            const SizedBox(height: 12),
            Text(l10n.zones_offTrailLimit(dist(_offTrailStops[limit]))),
            Slider(
              value: limit.toDouble(),
              max: (_offTrailStops.length - 1).toDouble(),
              divisions: _offTrailStops.length - 1,
              onChanged: (v) => watch.setOffTrailMeters(
                _offTrailStops[math.max(0, v.round())],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
