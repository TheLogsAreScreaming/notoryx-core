import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../services/rx_signal_stats_service.dart';
import '../theme/mesh_theme.dart';
import '../widgets/mesh_ui.dart';

class RxSignalStatsScreen extends StatelessWidget {
  const RxSignalStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.rxSignalStats_title),
        centerTitle: true,
      ),
      body: Consumer<RxSignalStatsService>(
        builder: (context, stats, _) {
          if (stats.count == 0) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.signal_cellular_off_outlined,
                    size: 48,
                    color: MeshPalette.ink3,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.rxSignalStats_empty,
                    style: TextStyle(
                      color: MeshPalette.ink2,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.rxSignalStats_emptyHint,
                    style: TextStyle(color: MeshPalette.ink3, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final rssiAvg = stats.rssiAvg!.round();
          final snrAvg = stats.snrAvg!;

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(
                  l10n.rxSignalStats_packets(stats.count),
                  style: TextStyle(
                    color: MeshPalette.ink3,
                    fontSize: 12,
                  ),
                ),
              ),
              MeshCard(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.all(4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _tile(
                      context,
                      'RSSI min',
                      '${stats.rssiMin} dBm',
                      Icons.arrow_downward_rounded,
                      MeshPalette.ink2,
                    ),
                    const Divider(height: 1),
                    _tile(
                      context,
                      'RSSI avg',
                      '$rssiAvg dBm',
                      Icons.graphic_eq_rounded,
                      MeshTheme.snrColor(snrAvg, blocked: false),
                    ),
                    const Divider(height: 1),
                    _tile(
                      context,
                      'RSSI max',
                      '${stats.rssiMax} dBm',
                      Icons.arrow_upward_rounded,
                      MeshPalette.signal,
                    ),
                  ],
                ),
              ),
              MeshCard(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.all(4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _tile(
                      context,
                      'SNR min',
                      '${stats.snrMin!.toStringAsFixed(1)} dB',
                      Icons.arrow_downward_rounded,
                      MeshPalette.ink2,
                    ),
                    const Divider(height: 1),
                    _tile(
                      context,
                      'SNR avg',
                      '${snrAvg.toStringAsFixed(1)} dB',
                      Icons.graphic_eq_rounded,
                      MeshTheme.snrColor(snrAvg, blocked: false),
                    ),
                    const Divider(height: 1),
                    _tile(
                      context,
                      'SNR max',
                      '${stats.snrMax!.toStringAsFixed(1)} dB',
                      Icons.arrow_upward_rounded,
                      MeshPalette.signal,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: MeshTheme.mono(
                fontSize: 13,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: MeshTheme.mono(fontSize: 13, color: scheme.onSurface),
          ),
        ],
      ),
    );
  }
}
