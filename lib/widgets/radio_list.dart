import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../connector/meshcore_connector.dart';
import '../connector/radio_manager.dart';
import '../l10n/l10n.dart';
import '../theme/mesh_theme.dart';
import 'connect_ui.dart';

/// A radio's name for lists: its own name when connected, else the saved
/// radio's name, else "Radio 2" and so on.
String radioLabel(
  BuildContext context,
  RadioManager radios,
  MeshCoreConnector r,
) {
  if (r.isConnected) return r.deviceDisplayName;
  final saved = r.savedRadio?.name.trim();
  if (saved != null && saved.isNotEmpty) return saved;
  return context.l10n.radios_number(radios.numberOf(r));
}

String _status(BuildContext context, MeshCoreConnector r) {
  final l10n = context.l10n;
  return switch (r.state) {
    MeshCoreConnectionState.connected => l10n.connections_statusConnected,
    MeshCoreConnectionState.connecting => l10n.connections_statusConnecting,
    MeshCoreConnectionState.disconnecting =>
      l10n.connections_statusDisconnecting,
    MeshCoreConnectionState.scanning => l10n.connections_statusScanning,
    _ => l10n.connections_statusNotConnected,
  };
}

/// Every radio, which one is in use, and adding or removing radios. Shown on
/// the Connections screen.
class RadioListSection extends StatelessWidget {
  const RadioListSection({super.key});

  @override
  Widget build(BuildContext context) {
    final radios = context.watch<RadioManager>();
    final l10n = context.l10n;
    return ListenableBuilder(
      listenable: Listenable.merge(radios.radios),
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ConsoleKicker(l10n.radios_title),
          ConsolePanel(
            padding: const EdgeInsets.fromLTRB(6, 8, 6, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final radio in radios.radios)
                  RadioTile(radios: radios, radio: radio),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: Text(
                    radios.hasMultiple
                        ? l10n.radios_switchNote
                        : l10n.radios_hint,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                if (radios.canAdd)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                    child: OutlinedButton.icon(
                      key: const ValueKey('add-radio'),
                      onPressed: () => radios.setActive(radios.add()),
                      icon: const Icon(Icons.add_rounded),
                      label: Text(l10n.radios_add),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One radio: status, name, and what can be done with it.
class RadioTile extends StatelessWidget {
  const RadioTile({super.key, required this.radios, required this.radio});

  final RadioManager radios;
  final MeshCoreConnector radio;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final active = radios.active == radio;
    final connected = radio.isConnected;
    final saved = radio.savedRadio;
    final busy =
        radio.state == MeshCoreConnectionState.connecting ||
        radio.state == MeshCoreConnectionState.disconnecting;
    final name = radioLabel(context, radios, radio);
    final status = _status(context, radio);
    final color = connected ? MeshPalette.signal : MeshPalette.ink3;
    return ListTile(
      key: ValueKey('radio-${radio.slot}'),
      leading: Icon(
        connected
            ? Icons.settings_input_antenna_rounded
            : Icons.portable_wifi_off_rounded,
        color: color,
        semanticLabel: status,
      ),
      title: Text(name, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(active ? '$status · ${l10n.radios_active}' : status),
      selected: active,
      onTap: active ? null : () => radios.setActive(radio),
      trailing: PopupMenuButton<String>(
        tooltip: name,
        onSelected: (choice) => switch (choice) {
          'use' => radios.setActive(radio),
          'reconnect' => unawaited(radio.reconnectSavedRadio()),
          'remove' => unawaited(_confirmRemove(context, name)),
          _ => null,
        },
        itemBuilder: (_) => [
          if (!active)
            PopupMenuItem(value: 'use', child: Text(l10n.radios_switch)),
          if (!connected && !busy && saved != null)
            PopupMenuItem(
              value: 'reconnect',
              child: Text(l10n.connections_reconnectTo(saved.name)),
            ),
          if (radio != radios.primary)
            PopupMenuItem(value: 'remove', child: Text(l10n.common_remove)),
        ],
      ),
    );
  }

  Future<void> _confirmRemove(BuildContext context, String name) async {
    final l10n = context.l10n;
    final go = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(l10n.radios_removeTitle(name)),
        content: Text(l10n.radios_removeBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: Text(l10n.common_cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: Text(l10n.common_remove),
          ),
        ],
      ),
    );
    if (go == true) await radios.remove(radio);
  }
}

/// A top-bar button for switching radios. Hidden with only one radio.
class RadioSwitcherButton extends StatelessWidget {
  const RadioSwitcherButton({super.key});

  @override
  Widget build(BuildContext context) {
    final RadioManager radios;
    try {
      radios = context.watch<RadioManager>();
    } on ProviderNotFoundException {
      return const SizedBox.shrink();
    }
    if (!radios.hasMultiple) return const SizedBox.shrink();
    return IconButton(
      key: const ValueKey('radio-switcher'),
      tooltip: context.l10n.radios_switcher,
      icon: Badge(
        label: Text('${radios.numberOf(radios.active)}'),
        child: const Icon(Icons.swap_horiz_rounded),
      ),
      onPressed: () => showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (sheet) => ChangeNotifierProvider.value(
          value: radios,
          child: SafeArea(
            child: ListenableBuilder(
              listenable: Listenable.merge(radios.radios),
              builder: (context, _) => ListView(
                shrinkWrap: true,
                children: [
                  for (final radio in radios.radios)
                    RadioTile(radios: radios, radio: radio),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
