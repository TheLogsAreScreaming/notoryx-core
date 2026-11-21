import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../connector/meshcore_connector.dart';
import '../connector/meshcore_protocol.dart';
import '../l10n/l10n.dart';
import '../services/wardrive_service.dart';
import '../widgets/mesh_ui.dart';

/// Opens the wardrive settings: when timed pings go out, what's ignored, and
/// what's recorded alongside them.
Future<void> showWardriveSettings(BuildContext context) => showMeshSheet<void>(
  context,
  builder: (_) => const _WardriveSettingsSheet(),
);

class _WardriveSettingsSheet extends StatelessWidget {
  const _WardriveSettingsSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final service = context.watch<WardriveService>();
    final s = service.settings;
    final connector = context.read<MeshCoreConnector>();

    String repeaterLabel(String? prefix) {
      if (prefix == null) return l10n.wardrive_none;
      for (final c in connector.allContactsUnfiltered) {
        if (c.publicKeyHex.toLowerCase().startsWith(prefix.toLowerCase())) {
          return c.name.isEmpty ? prefix.toUpperCase() : c.name;
        }
      }
      return prefix.toUpperCase();
    }

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BottomSheetHeader(title: l10n.wardrive_settings),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.wardrive_interval),
                  const SizedBox(height: 6),
                  SegmentedButton<int>(
                    key: const ValueKey('wardrive-interval'),
                    showSelectedIcon: false,
                    segments: [
                      for (final v in WardriveService.intervals)
                        ButtonSegment(value: v, label: Text('${v}s')),
                    ],
                    selected: {s.intervalSeconds},
                    onSelectionChanged: (v) => service.setInterval(v.first),
                  ),
                ],
              ),
            ),
            SwitchListTile(
              key: const ValueKey('wardrive-wait-move'),
              title: Text(l10n.wardrive_waitForMove),
              value: s.waitForMove,
              onChanged: (v) => service.update(s.copyWith(waitForMove: v)),
            ),
            SwitchListTile(
              key: const ValueKey('wardrive-skip-covered'),
              title: Text(l10n.wardrive_skipCovered),
              subtitle: Text(l10n.wardrive_skipDays(s.skipDays)),
              value: s.skipCovered,
              onChanged: (v) => service.update(s.copyWith(skipCovered: v)),
            ),
            if (s.skipCovered)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SegmentedButton<int>(
                  showSelectedIcon: false,
                  segments: [
                    for (final d in const [1, 7, 14, 30])
                      ButtonSegment(value: d, label: Text('${d}d')),
                  ],
                  selected: {
                    const [1, 7, 14, 30].contains(s.skipDays) ? s.skipDays : 14,
                  },
                  onSelectionChanged: (v) =>
                      service.update(s.copyWith(skipDays: v.first)),
                ),
              ),
            SwitchListTile(
              key: const ValueKey('wardrive-passive'),
              title: Text(l10n.wardrive_passive),
              subtitle: Text(l10n.wardrive_passiveHint),
              value: s.passive,
              onChanged: (v) => service.update(s.copyWith(passive: v)),
            ),
            ListTile(
              key: const ValueKey('wardrive-trace-target'),
              title: Text(l10n.wardrive_traceTarget),
              subtitle: Text(repeaterLabel(s.traceTarget)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final picked = await _pickRepeater(context, connector);
                if (picked == null) return;
                service.update(
                  picked.isEmpty
                      ? s.copyWith(clearTraceTarget: true)
                      : s.copyWith(traceTarget: picked),
                );
              },
            ),
            const Divider(),
            ListTile(
              key: const ValueKey('wardrive-car-repeater'),
              title: Text(l10n.wardrive_carRepeater),
              subtitle: Text(
                '${repeaterLabel(s.carRepeater)} · '
                '${l10n.wardrive_carRepeaterHint}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final picked = await _pickRepeater(context, connector);
                if (picked == null) return;
                service.update(
                  picked.isEmpty
                      ? s.copyWith(clearCarRepeater: true)
                      : s.copyWith(carRepeater: picked),
                );
              },
            ),
            SwitchListTile(
              key: const ValueKey('wardrive-ignore-strong'),
              title: Text(l10n.wardrive_ignoreStrong),
              value: s.ignoreStrong,
              onChanged: (v) => service.update(s.copyWith(ignoreStrong: v)),
            ),
            SwitchListTile(
              key: const ValueKey('wardrive-background'),
              title: Text(l10n.wardrive_background),
              subtitle: Text(l10n.wardrive_backgroundHint),
              value: s.background,
              onChanged: (v) => service.update(s.copyWith(background: v)),
            ),
            SwitchListTile(
              key: const ValueKey('wardrive-record-noise'),
              title: Text(l10n.wardrive_recordNoise),
              value: s.recordNoise,
              onChanged: (v) => service.update(s.copyWith(recordNoise: v)),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  /// A repeater from the radio's contacts: its key prefix, '' for none, or
  /// null when the picker was dismissed.
  Future<String?> _pickRepeater(
    BuildContext context,
    MeshCoreConnector connector,
  ) {
    final l10n = context.l10n;
    final repeaters = [
      for (final c in connector.allContactsUnfiltered)
        if (c.type == advTypeRepeater && c.publicKeyHex.length >= 16) c,
    ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return showMeshSheet<String>(
      context,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BottomSheetHeader(title: l10n.wardrive_pickRepeater),
            ListTile(
              leading: const Icon(Icons.block),
              title: Text(l10n.wardrive_none),
              onTap: () => Navigator.of(sheet).pop(''),
            ),
            if (repeaters.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l10n.wardrive_noRepeaters),
              ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final c in repeaters)
                    ListTile(
                      leading: const Icon(Icons.cell_tower),
                      title: Text(c.name.isEmpty ? c.publicKeyHex : c.name),
                      subtitle: Text(
                        c.publicKeyHex.substring(0, 8).toUpperCase(),
                      ),
                      onTap: () => Navigator.of(
                        sheet,
                      ).pop(c.publicKeyHex.substring(0, 16).toLowerCase()),
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
