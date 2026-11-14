import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../connector/meshcore_connector.dart';
import '../l10n/app_localizations.dart';
import '../l10n/l10n.dart';
import '../models/app_settings.dart';
import '../models/contact.dart';
import '../models/field_intel.dart';
import '../models/waypoint.dart';
import '../services/app_settings_service.dart';
import '../widgets/node_sheet.dart';

/// "1.2 km north-east" in words, or why there's no distance.
String mapListWhere(
  AppLocalizations l10n,
  double? km,
  double? bearing, {
  required bool imperial,
}) => km == null || bearing == null
    ? l10n.ml_noOwnPosition
    : l10n.ml_distanceDir(
        distanceLabel(km, imperial),
        compassPoint(bearing).toLowerCase(),
      );

/// The map in words: located nodes and waypoints, nearest first, each
/// with how far, which way, how fresh and how messages reach it.
class MapListScreen extends StatelessWidget {
  const MapListScreen({super.key, this.waypoints = const []});

  final List<Waypoint> waypoints;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final connector = context.watch<MeshCoreConnector>();
    final imperial =
        context.watch<AppSettingsService>().settings.unitSystem ==
        UnitSystem.imperial;
    final lat = connector.selfLatitude, lon = connector.selfLongitude;
    final hasSelf = lat != null && lon != null && (lat != 0 || lon != 0);
    final located = [
      for (final c in connector.allContactsUnfiltered)
        if (c.hasLocation) c,
    ];
    final nodes = hasSelf
        ? [
            for (final d in byDistance(located, lat, lon))
              (contact: d.contact, km: d.km, bearing: d.bearing),
          ]
        : [
            for (final c in located..sort((a, b) => a.name.compareTo(b.name)))
              (contact: c, km: null as double?, bearing: null as double?),
          ];
    final points = [
      for (final w in waypoints)
        (
          waypoint: w,
          km: hasSelf ? distanceKm(lat, lon, w.lat, w.lon) : null,
          bearing: hasSelf ? bearingDeg(lat, lon, w.lat, w.lon) : null,
        ),
    ];
    if (hasSelf) points.sort((a, b) => a.km!.compareTo(b.km!));

    Widget header(String text, int count) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Semantics(
        header: true,
        child: Text(
          '$text ($count)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );

    String nodeLine(Contact c, double? km, double? bearing) => [
      mapListWhere(l10n, km, bearing, imperial: imperial),
      l10n.ml_heard(agoLabel(l10n, c.lastSeen)),
      hopLabel(l10n, hopBand(c)),
    ].join(' • ');

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ml_title)),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(l10n.ml_intro),
          ),
          header(l10n.ml_nodes, nodes.length),
          if (nodes.isEmpty) ListTile(title: Text(l10n.ml_none)),
          for (final n in nodes)
            ListTile(
              title: Text(n.contact.name),
              subtitle: Text(nodeLine(n.contact, n.km, n.bearing)),
              onTap: () => showNodeSheet(context, n.contact),
            ),
          header(l10n.ml_waypoints, points.length),
          if (points.isEmpty) ListTile(title: Text(l10n.ml_none)),
          for (final p in points)
            ListTile(
              title: Text(p.waypoint.name),
              subtitle: Text(
                mapListWhere(l10n, p.km, p.bearing, imperial: imperial),
              ),
            ),
        ],
      ),
    );
  }
}
