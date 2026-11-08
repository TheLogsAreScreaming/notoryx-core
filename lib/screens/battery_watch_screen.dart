import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../connector/meshcore_connector.dart';
import '../helpers/snack_bar_builder.dart';
import '../l10n/l10n.dart';
import '../models/battery_trend.dart';
import '../connector/meshcore_protocol.dart';
import '../services/app_settings_service.dart';
import '../services/battery_check_service.dart';
import '../services/repeater_battery_history.dart';
import '../theme/mesh_theme.dart';
import '../widgets/battery_watch_widgets.dart';
import '../widgets/ember_backdrop.dart';
import '../widgets/tactical_glass_panel.dart';

/// Every repeater with battery readings, the most worrying first.
class BatteryWatchScreen extends StatelessWidget {
  const BatteryWatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final history = context.watch<RepeaterBatteryHistory?>();
    final connector = context.watch<MeshCoreConnector>();
    final settings = context.watch<AppSettingsService>();
    final checks = context.watch<BatteryCheckService?>();
    final names = {
      for (final c in connector.allContactsUnfiltered) c.publicKeyHex: c.name,
    };
    final rows =
        <({String key, String name, BatteryTrend trend})>[
          for (final key in {...?history?.repeaterKeys, ...?checks?.watched})
            (
              key: key,
              name: names[key] ?? l10n.batteryWatch_unknownRepeater,
              trend: analyzeBattery(
                history?.samplesFor(key) ?? const [],
                chemistry: settings.batteryChemistryForRepeater(key),
                now: history?.now ?? DateTime.now(),
              ),
            ),
        ]..sort((a, b) {
          final byStatus = a.trend.status.index.compareTo(b.trend.status.index);
          return byStatus != 0
              ? byStatus
              : a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });

    return EmberBackdrop(
      scene: EmberScene.more,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          foregroundColor: MeshPalette.ink,
          title: Text(l10n.batteryWatch_title),
        ),
        body: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.all(MeshSpace.lg),
            children: [
              Text(
                l10n.batteryWatch_note,
                style: TextStyle(color: MeshPalette.ink2, fontSize: 13),
              ),
              const SizedBox(height: MeshSpace.lg),
              if (checks != null) ...[
                _AutoCheckPanel(checks: checks),
                const SizedBox(height: MeshSpace.lg),
              ],
              if (rows.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.battery_unknown,
                        size: 40,
                        color: MeshPalette.ink3,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.batteryWatch_empty,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: MeshPalette.ink2),
                      ),
                    ],
                  ),
                ),
              for (final row in rows)
                Padding(
                  padding: const EdgeInsets.only(bottom: MeshSpace.md),
                  child: _RepeaterBatteryRow(
                    key: ValueKey('battery-${row.key}'),
                    repeaterKey: row.key,
                    name: row.name,
                    trend: row.trend,
                    samples: history?.samplesFor(row.key) ?? const [],
                    now: history?.now ?? DateTime.now(),
                    checks: checks,
                    onClear: () {
                      history?.clear(row.key);
                      showDismissibleSnackBar(
                        context,
                        content: Text(l10n.batteryWatch_cleared),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RepeaterBatteryRow extends StatelessWidget {
  const _RepeaterBatteryRow({
    super.key,
    required this.repeaterKey,
    required this.name,
    required this.trend,
    required this.samples,
    required this.now,
    required this.onClear,
    this.checks,
  });

  final BatteryCheckService? checks;

  final String repeaterKey;
  final String name;
  final BatteryTrend trend;
  final List<BatterySample> samples;
  final DateTime now;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final latest = trend.latest;
    return TacticalGlassPanel(
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: MeshPalette.ink,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    if (latest != null && trend.percent != null)
                      Text(
                        '${trend.percent}% · '
                        '${(latest.millivolts / 1000).toStringAsFixed(2)} V',
                        style: TextStyle(color: MeshPalette.ink2, fontSize: 13),
                      ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: MeshPalette.ink3),
                onSelected: (_) => onClear(),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'clear',
                    child: Text(l10n.batteryWatch_clear),
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BatteryStatusChip(status: trend.status),
                const SizedBox(height: 8),
                BatteryHistoryChart(
                  samples: samples,
                  now: now,
                  height: 64,
                  color: batteryStatusColor(trend.status),
                ),
                const SizedBox(height: 6),
                for (final line in batteryTrendLines(context, trend))
                  Text(
                    line,
                    style: TextStyle(color: MeshPalette.ink2, fontSize: 13),
                  ),
                if (checks case final checks?) ...[
                  if (checks.failuresFor(repeaterKey) > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        l10n.batteryWatch_noReply(
                          checks.failuresFor(repeaterKey),
                        ),
                        style: TextStyle(color: MeshPalette.warn, fontSize: 13),
                      ),
                    ),
                  SwitchListTile(
                    key: ValueKey('auto-$repeaterKey'),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(l10n.batteryWatch_auto),
                    value: checks.isWatched(repeaterKey),
                    onChanged: (on) => checks.setWatched(repeaterKey, on),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The interval and budget for automatic checks, and adding a repeater.
class _AutoCheckPanel extends StatelessWidget {
  const _AutoCheckPanel({required this.checks});

  final BatteryCheckService checks;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TacticalGlassPanel(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.batteryWatch_autoHint,
            style: TextStyle(color: MeshPalette.ink2, fontSize: 13),
          ),
          Row(
            children: [
              Expanded(child: Text(l10n.batteryWatch_interval)),
              DropdownButton<int>(
                key: const ValueKey('battery-interval'),
                value: checks.intervalHours,
                underline: const SizedBox.shrink(),
                onChanged: (h) {
                  if (h != null) checks.setIntervalHours(h);
                },
                items: [
                  for (final h in BatteryCheckBudget.intervals)
                    DropdownMenuItem(
                      value: h,
                      child: Text(l10n.batteryWatch_hours(h)),
                    ),
                ],
              ),
            ],
          ),
          Text(
            l10n.batteryWatch_budget,
            style: TextStyle(color: MeshPalette.ink3, fontSize: 12),
          ),
          if (checks.isChecking)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                l10n.batteryWatch_checking,
                style: TextStyle(color: MeshPalette.ink2, fontSize: 13),
              ),
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            key: const ValueKey('battery-add'),
            icon: const Icon(Icons.add),
            label: Text(l10n.batteryWatch_add),
            onPressed: () => _pickRepeater(context),
          ),
        ],
      ),
    );
  }

  Future<void> _pickRepeater(BuildContext context) async {
    final l10n = context.l10n;
    final repeaters =
        context
            .read<MeshCoreConnector>()
            .allContactsUnfiltered
            .where(
              (c) =>
                  c.type == advTypeRepeater &&
                  !checks.isWatched(c.publicKeyHex),
            )
            .toList()
          ..sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );
    final key = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.7,
          ),
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: Text(
                  l10n.batteryWatch_pick,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              if (repeaters.isEmpty)
                ListTile(title: Text(l10n.batteryWatch_noRepeaters)),
              for (final r in repeaters)
                ListTile(
                  leading: const Icon(Icons.cell_tower_rounded),
                  title: Text(r.name),
                  onTap: () => Navigator.pop(context, r.publicKeyHex),
                ),
            ],
          ),
        ),
      ),
    );
    if (key != null) await checks.setWatched(key, true);
  }
}
