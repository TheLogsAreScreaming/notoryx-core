import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../connector/meshcore_connector.dart';
import '../l10n/l10n.dart';
import '../models/fleet.dart';
import '../services/fleet_controller.dart';
import '../theme/mesh_theme.dart';
import 'fleet_screen.dart';

/// Changes one allow-listed setting on several repeaters: read the current
/// values, show what would change, and send only after the user confirms.
class FleetBulkSettingsScreen extends StatefulWidget {
  const FleetBulkSettingsScreen({super.key});

  @override
  State<FleetBulkSettingsScreen> createState() =>
      _FleetBulkSettingsScreenState();
}

class _FleetBulkSettingsScreenState extends State<FleetBulkSettingsScreen> {
  String _setting = fleetBulkSettings.keys.first;
  final _value = TextEditingController();
  final Set<String> _selected = {};
  List<FleetSettingDiff>? _diff;
  Map<String, String>? _results;

  @override
  void initState() {
    super.initState();
    final store = context.read<FleetController?>()?.store;
    _selected.addAll(store?.repeaters.map((r) => r.publicKeyHex) ?? const []);
  }

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  bool get _valueValid => isAllowedBulkSetting(_setting, _value.text);

  void _reset() => setState(() {
    _diff = null;
    _results = null;
  });

  Future<void> _preview(FleetController fleet) async {
    _reset();
    final diff = await fleet.preview(
      _selected.toList(),
      _setting,
      _value.text.trim(),
    );
    if (mounted) setState(() => _diff = diff);
  }

  Future<void> _apply(FleetController fleet) async {
    final l10n = context.l10n;
    final rows = _diff?.where((d) => d.changes).toList() ?? const [];
    if (rows.isEmpty) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.fleet_bulkConfirmTitle),
        content: Text(
          l10n.fleet_bulkConfirmBody(_setting, _value.text.trim(), rows.length),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.common_cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.fleet_bulkSend),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final results = await fleet.apply(rows, _setting);
    if (mounted) setState(() => _results = results);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fleet = context.watch<FleetController?>();
    final connected = context.watch<MeshCoreConnector>().isConnected;
    if (fleet == null) return const Scaffold();
    final repeaters = fleet.store.repeaters;
    final diff = _diff;
    final changes = diff?.where((d) => d.changes).length ?? 0;
    final canRead =
        connected && !fleet.busy && _valueValid && _selected.isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.fleet_bulkTitle), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.fleet_bulkIntro,
            style: TextStyle(color: MeshPalette.ink3, fontSize: 13),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _setting,
            decoration: InputDecoration(labelText: l10n.fleet_bulkSetting),
            items: [
              for (final k in fleetBulkSettings.keys)
                DropdownMenuItem(value: k, child: Text(k)),
            ],
            onChanged: fleet.busy
                ? null
                : (v) {
                    if (v == null) return;
                    _reset();
                    setState(() => _setting = v);
                  },
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _value,
            enabled: !fleet.busy,
            decoration: InputDecoration(
              labelText: l10n.fleet_bulkValue,
              errorText: _value.text.isEmpty || _valueValid
                  ? null
                  : l10n.fleet_bulkBadValue,
            ),
            onChanged: (_) => _reset(),
          ),
          const SizedBox(height: 12),
          Text(l10n.fleet_bulkRepeaters, style: MeshTheme.accentLabel()),
          for (final r in repeaters)
            CheckboxListTile(
              value: _selected.contains(r.publicKeyHex),
              title: Text(r.name),
              contentPadding: EdgeInsets.zero,
              onChanged: fleet.busy
                  ? null
                  : (v) {
                      _reset();
                      setState(() {
                        if (v == true) {
                          _selected.add(r.publicKeyHex);
                        } else {
                          _selected.remove(r.publicKeyHex);
                        }
                      });
                    },
            ),
          const SizedBox(height: 8),
          if (fleet.busy) ...[
            LinearProgressIndicator(
              value: fleet.total == 0 ? null : fleet.done / fleet.total,
            ),
            const SizedBox(height: 4),
            Text(l10n.fleet_progress(fleet.done, fleet.total)),
            TextButton(onPressed: fleet.stop, child: Text(l10n.fleet_stop)),
          ] else
            OutlinedButton.icon(
              onPressed: canRead ? () => _preview(fleet) : null,
              icon: const Icon(Icons.download),
              label: Text(l10n.fleet_bulkRead),
            ),
          if (diff != null) ...[
            const SizedBox(height: 16),
            Text(l10n.fleet_bulkPreview, style: MeshTheme.accentLabel()),
            for (final d in diff)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  d.error != null
                      ? Icons.error_outline
                      : d.changes
                      ? Icons.edit
                      : Icons.check,
                  color: d.error != null
                      ? MeshPalette.alert
                      : d.changes
                      ? MeshPalette.warn
                      : MeshPalette.signal,
                ),
                title: Text(d.repeater.name),
                subtitle: Text(
                  d.error != null
                      ? fleetErrorLabel(l10n, d.error!)
                      : d.changes
                      ? l10n.fleet_bulkChange(d.current ?? '?', d.target)
                      : l10n.fleet_bulkSame(d.target),
                ),
                trailing: switch (_results?[d.repeater.publicKeyHex]) {
                  final r? => SizedBox(
                    width: 120,
                    child: Text(
                      r,
                      textAlign: TextAlign.end,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  null => null,
                },
              ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: changes == 0 || fleet.busy || _results != null
                  ? null
                  : () => _apply(fleet),
              icon: const Icon(Icons.send),
              label: Text(l10n.fleet_bulkApply(changes)),
            ),
          ],
        ],
      ),
    );
  }
}
