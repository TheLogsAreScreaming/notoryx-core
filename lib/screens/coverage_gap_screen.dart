import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../services/map_tile_cache_service.dart';
import '../services/send_gap_log.dart';
import '../theme/mesh_theme.dart';
import '../widgets/ember_backdrop.dart';
import '../widgets/instrument.dart';
import '../widgets/mesh_ui.dart';

/// Where your own direct messages failed, on the coverage hexagons, from
/// the last 30 days of normal use. Local only.
class CoverageGapScreen extends StatelessWidget {
  const CoverageGapScreen({super.key});

  /// Cells need this many sends before they're coloured as a gap.
  static const minSends = 2;

  static Color colorFor(GapTally t) {
    if (t.total < minSends) return MeshPalette.ink3;
    if (t.failRate >= 0.5) return MeshPalette.alert;
    if (t.failRate >= 0.2) return MeshPalette.warn;
    return MeshPalette.signal;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final log = context.watch<SendGapLog?>();
    final cells = log?.cells ?? const <String, GapTally>{};
    final worst = log?.worst(minSends: minSends) ?? const [];
    final gaps = worst.where((e) => e.value.failRate >= 0.5).toList();

    return EmberBackdrop(
      scene: EmberScene.more,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          title: Text(l10n.gapFinder_title),
          actions: [
            if (cells.isNotEmpty)
              IconButton(
                tooltip: l10n.gapFinder_clear,
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: () => _confirmClear(context, log!),
              ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            MeshSpace.lg,
            MeshSpace.sm,
            MeshSpace.lg,
            MeshSpace.xxl,
          ),
          children: [
            Text(
              l10n.gapFinder_hint,
              style: TextStyle(color: MeshPalette.ink3, fontSize: 13),
            ),
            const SizedBox(height: MeshSpace.md),
            if (cells.isEmpty || log == null)
              MeshCard(
                margin: EdgeInsets.zero,
                child: Text(
                  l10n.gapFinder_empty,
                  key: const ValueKey('gap-empty'),
                ),
              )
            else ...[
              _GapMap(log: log, cells: cells),
              const SizedBox(height: MeshSpace.sm),
              Wrap(
                spacing: MeshSpace.md,
                runSpacing: 4,
                children: [
                  _legend(MeshPalette.alert, l10n.gapFinder_legendGap),
                  _legend(MeshPalette.warn, l10n.gapFinder_legendPatchy),
                  _legend(MeshPalette.signal, l10n.gapFinder_legendGood),
                  _legend(MeshPalette.ink3, l10n.gapFinder_legendFew),
                ],
              ),
              InstrumentLabel(l10n.gapFinder_worst),
              MeshCard(
                margin: EdgeInsets.zero,
                child: worst.isEmpty
                    ? Text(l10n.gapFinder_notEnough)
                    : Column(
                        children: [
                          for (final e in worst.take(8))
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                children: [
                                  Icon(
                                    e.value.failRate >= 0.5
                                        ? Icons.signal_cellular_off_rounded
                                        : Icons.signal_cellular_alt_rounded,
                                    size: 18,
                                    color: colorFor(e.value),
                                  ),
                                  const SizedBox(width: MeshSpace.sm),
                                  Expanded(
                                    child: Text(
                                      l10n.gapFinder_cellLine(
                                        e.value.failed,
                                        e.value.total,
                                        (e.value.failRate * 100).round(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
              ),
              const SizedBox(height: MeshSpace.sm),
              Text(
                l10n.gapFinder_summary(gaps.length, cells.length),
                style: TextStyle(color: MeshPalette.ink3, fontSize: 12.5),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _legend(Color color, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.35),
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 12)),
    ],
  );

  Future<void> _confirmClear(BuildContext context, SendGapLog log) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(l10n.gapFinder_clear),
        content: Text(l10n.gapFinder_clearBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(d, false),
            child: Text(MaterialLocalizations.of(d).cancelButtonLabel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(d, true),
            child: Text(l10n.gapFinder_clear),
          ),
        ],
      ),
    );
    if (ok == true) await log.clear();
  }
}

class _GapMap extends StatelessWidget {
  const _GapMap({required this.log, required this.cells});

  final SendGapLog log;
  final Map<String, GapTally> cells;

  @override
  Widget build(BuildContext context) {
    final worst = log.worst(minSends: 1);
    final c = log.indexer.centerOf(
      worst.isEmpty ? cells.keys.first : worst.first.key,
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(MeshRadii.lg),
      child: SizedBox(
        height: 320,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(c.lat, c.lon),
            initialZoom: 12,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: MapTileCacheService.userAgentPackageName,
            ),
            PolygonLayer(
              polygons: [
                for (final e in cells.entries)
                  Polygon(
                    points: [
                      for (final p in log.indexer.boundaryOf(e.key))
                        LatLng(p.lat, p.lon),
                    ],
                    color: CoverageGapScreen.colorFor(
                      e.value,
                    ).withValues(alpha: 0.35),
                    borderColor: CoverageGapScreen.colorFor(e.value),
                    borderStrokeWidth: 1,
                  ),
              ],
            ),
            const SimpleAttributionWidget(source: Text('OpenStreetMap')),
          ],
        ),
      ),
    );
  }
}
