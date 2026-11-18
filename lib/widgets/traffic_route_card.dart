import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/l10n.dart';
import '../models/traffic_route.dart';
import '../theme/mesh_theme.dart';

String trafficKindLabel(AppLocalizations l10n, TrafficKind kind) =>
    switch (kind) {
      TrafficKind.advert => l10n.traffic_kindAdvert,
      TrafficKind.direct => l10n.traffic_kindDirect,
      TrafficKind.channel => l10n.traffic_kindChannel,
      TrafficKind.ack => l10n.traffic_kindAck,
      TrafficKind.trace => l10n.traffic_kindTrace,
      TrafficKind.path => l10n.traffic_kindPath,
    };

/// Frosted card under the map in Traffic mode: the latest packet's route,
/// its type and signal, the hops not on the map, and the colour legend.
class TrafficRouteCard extends StatefulWidget {
  const TrafficRouteCard({
    super.key,
    required this.route,
    required this.dark,
    this.onTap,
  });

  /// Null until the first packet is heard.
  final TrafficRoute? route;
  final bool dark;
  final VoidCallback? onTap;

  @override
  State<TrafficRouteCard> createState() => _TrafficRouteCardState();
}

class _TrafficRouteCardState extends State<TrafficRouteCard> {
  // Keeps the "Ns" age current.
  late final Timer _clock = Timer.periodic(
    const Duration(seconds: 1),
    (_) => setState(() {}),
  );

  @override
  void dispose() {
    _clock.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final route = widget.route;
    final scheme = Theme.of(context).colorScheme;
    final primary = widget.dark ? MapPalette.textPrimary : scheme.onSurface;
    final secondary = widget.dark
        ? MapPalette.textSecondary
        : scheme.onSurfaceVariant;
    final panel = widget.dark
        ? MapPalette.panelDark.withValues(alpha: 0.72)
        : scheme.surfaceContainerLow.withValues(alpha: 0.78);
    final body = Theme.of(context).textTheme.bodySmall!;

    final lines = <Widget>[];
    if (route == null) {
      lines.add(
        Text(l10n.traffic_listening, style: body.copyWith(color: secondary)),
      );
    } else {
      final color = trafficKindColor(route.kind);
      final heard = route.heardFrom;
      final snr = route.snr.toStringAsFixed(route.snr % 1 == 0 ? 0 : 2);
      final age = DateTime.now().difference(route.receivedAt).inSeconds;
      final missing = route.notOnMap;
      final path = route.pathHops.map((h) => h.label).join(' → ');
      lines
        ..add(
          SingleChildScrollView(
            key: const ValueKey('traffic-route-path'),
            scrollDirection: Axis.horizontal,
            child: Text(
              path.isEmpty ? l10n.traffic_unknownSender : path,
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: primary,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        )
        ..add(const SizedBox(height: MeshSpace.xs))
        ..add(
          Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(MeshRadii.xs),
                  border: Border.all(color: color.withValues(alpha: 0.6)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: MeshSpace.sm,
                    vertical: 2,
                  ),
                  child: Text(
                    trafficKindLabel(l10n, route.kind),
                    style: body.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: MeshSpace.sm),
              Expanded(
                child: Text(
                  heard == null
                      ? l10n.traffic_heardDirect(snr)
                      : l10n.traffic_heardFrom(heard.label, snr),
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: body.copyWith(color: secondary),
                ),
              ),
            ],
          ),
        )
        ..add(const SizedBox(height: MeshSpace.xs))
        ..add(
          Text(
            [
              route.isFlood
                  ? l10n.traffic_flood(route.hopCount)
                  : l10n.traffic_direct,
              '${route.rssi} dBm',
              'SNR $snr',
              if (missing.isNotEmpty)
                l10n.traffic_notOnMapCount(missing.length),
              l10n.traffic_ageSeconds(age),
            ].join(' · '),
            style: body.copyWith(color: secondary),
          ),
        );
      if (missing.isNotEmpty) {
        lines.add(
          Text(
            l10n.traffic_notOnMapList(missing.map((h) => h.label).join(', ')),
            maxLines: 2,
            overflow: TextOverflow.fade,
            style: body.copyWith(color: secondary),
          ),
        );
      }
    }

    return Semantics(
      container: true,
      button: widget.onTap != null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(MeshRadii.lg),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Material(
            color: panel,
            child: InkWell(
              onTap: widget.onTap,
              child: Container(
                padding: const EdgeInsets.all(MeshSpace.md),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(MeshRadii.lg),
                  border: Border.all(color: MapPalette.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...lines,
                    const SizedBox(height: MeshSpace.sm),
                    _Legend(color: secondary, style: body),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.style});

  final Color color;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      spacing: MeshSpace.md,
      runSpacing: MeshSpace.xs,
      children: [
        for (final kind in TrafficKind.values)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 4,
                decoration: BoxDecoration(
                  color: trafficKindColor(kind),
                  borderRadius: BorderRadius.circular(MeshRadii.pill),
                ),
              ),
              const SizedBox(width: MeshSpace.xs),
              Text(
                trafficKindLabel(l10n, kind),
                style: style.copyWith(color: color),
              ),
            ],
          ),
      ],
    );
  }
}
