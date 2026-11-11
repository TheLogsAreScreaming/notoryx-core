import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/regional_preset.dart';
import '../services/regional_preset_service.dart';
import '../l10n/l10n.dart';

/// "Your area's mesh uses…" with Review and Not now, shown when the radio
/// doesn't match the local mesh's published settings.
class RegionalPresetBanner extends StatelessWidget {
  const RegionalPresetBanner({super.key});

  @override
  Widget build(BuildContext context) {
    // Hidden where the service isn't provided (tests, previews).
    final service = context.watch<RegionalPresetService?>();
    final preset = service?.active;
    if (service == null || preset == null || !service.shouldOffer) {
      return const SizedBox.shrink();
    }
    final scheme = Theme.of(context).colorScheme;
    return Card(
      key: const ValueKey('regional-preset-banner'),
      color: scheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.settings_input_antenna,
                  color: scheme.onTertiaryContainer,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    context.l10n.rp_title(preset.name),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: scheme.onTertiaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              preset.fromMap
                  ? (preset.nodeCount == null
                        ? context.l10n.rp_mostNodes(preset.summary)
                        : context.l10n.rp_mostNodesCount(
                            preset.nodeCount!,
                            preset.summary,
                          ))
                  : context.l10n.rp_localMesh(preset.summary),
              style: TextStyle(color: scheme.onTertiaryContainer),
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Wrap(
                spacing: 4,
                children: [
                  TextButton(
                    onPressed: service.dismiss,
                    child: Text(context.l10n.rp_notNow),
                  ),
                  FilledButton.tonal(
                    onPressed: () => reviewRegionalPreset(context, preset),
                    child: Text(context.l10n.rp_review),
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

/// Shows exactly what will change, then applies [preset] to the radio.
Future<void> reviewRegionalPreset(
  BuildContext context,
  RegionalPreset preset,
) async {
  final service = context.read<RegionalPresetService>();
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final changes = service.active == preset
      ? service.differences
      : preset.differences(service.radio);
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(context.l10n.rp_useTitle(preset.name)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (changes.isEmpty)
              Text(context.l10n.rp_already)
            else
              for (final c in changes)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• $c'),
                ),
            if (preset.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(preset.notes),
            ],
            const SizedBox(height: 8),
            Text(
              [
                if (preset.fromMap) context.l10n.rp_fromMap,
                context.l10n.rp_updated(preset.updated),
                preset.pathHashBytes == null
                    ? context.l10n.rp_powerHash
                    : context.l10n.rp_powerOnly,
              ].join(' '),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(context.l10n.common_cancel),
        ),
        FilledButton(
          onPressed: changes.isEmpty
              ? null
              : () => Navigator.pop(context, true),
          child: Text(context.l10n.rp_apply),
        ),
      ],
    ),
  );
  if (ok != true) return;
  try {
    await service.apply(preset);
    messenger.showSnackBar(SnackBar(content: Text(l10n.rp_setTo(preset.name))));
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.rp_failed('$e'))));
  }
}

/// Settings row: which area's settings to follow, and when the list was
/// last checked.
class RegionalPresetTile extends StatelessWidget {
  const RegionalPresetTile({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<RegionalPresetService?>();
    if (service == null) return const SizedBox.shrink();
    final active = service.active;
    final auto = service.selection == RegionalPresetService.auto;
    final subtitle = active == null
        ? (auto ? context.l10n.rp_noArea : context.l10n.rp_noLonger)
        : '${auto ? context.l10n.rp_autoPrefix : ''}${active.name} • ${active.summary}';
    return ListTile(
      key: const ValueKey('regional-preset-tile'),
      leading: Icon(Icons.public),
      title: Text(context.l10n.rp_tileTitle),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _choose(context, service),
    );
  }

  Future<void> _choose(
    BuildContext context,
    RegionalPresetService service,
  ) async {
    final picked = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(context.l10n.rp_tileTitle),
        children: [
          RadioGroup<String>(
            groupValue: service.selection,
            onChanged: (v) => Navigator.pop(context, v),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  value: RegionalPresetService.auto,
                  title: Text(context.l10n.rp_automatic),
                  subtitle: Text(context.l10n.rp_autoSub),
                ),
                for (final p in service.presets)
                  RadioListTile<String>(
                    value: p.id,
                    title: Text(p.name),
                    subtitle: Text(
                      p.fromMap
                          ? '${p.summary} · ${context.l10n.rp_mapSuffix}'
                          : p.summary,
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: Text(
              service.lastChecked == null
                  ? context.l10n.rp_savedList
                  : context.l10n.rp_checked(
                      TimeOfDay.fromDateTime(
                        service.lastChecked!,
                      ).format(context),
                    ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
    if (picked == null) return;
    await service.select(picked);
    final preset = service.active;
    if (preset != null && service.differences.isNotEmpty && context.mounted) {
      await reviewRegionalPreset(context, preset);
    }
  }
}
