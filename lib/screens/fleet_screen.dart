import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../connector/meshcore_connector.dart';
import '../helpers/snack_bar_builder.dart';
import '../l10n/app_localizations.dart';
import '../l10n/l10n.dart';
import '../models/firmware_release.dart';
import '../models/fleet.dart';
import '../services/fleet_controller.dart';
import '../services/fleet_station_client.dart';
import '../services/fleet_store.dart';
import '../theme/mesh_theme.dart';
import '../widgets/time_series_chart.dart';
import 'fleet_bulk_settings_screen.dart';

/// Repeaters the user owns: health at a glance, staggered polls, trends,
/// bulk settings and an optional station sync.
class FleetScreen extends StatelessWidget {
  const FleetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final store = context.watch<FleetStore?>();
    final fleet = context.watch<FleetController?>();
    final connector = context.watch<MeshCoreConnector>();
    if (store == null || fleet == null) {
      return Scaffold(appBar: AppBar(title: Text(l10n.fleet_title)));
    }
    final repeaters = store.repeaters;
    final now = DateTime.now();
    final newest = newestFirmwareOf(
      repeaters.map((r) => store.healthFor(r.publicKeyHex).firmware),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.fleet_title),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: l10n.fleet_syncStation,
            icon: const Icon(Icons.sync),
            onPressed: fleet.busy ? null : () => _showSync(context),
          ),
          IconButton(
            tooltip: l10n.fleet_bulkTitle,
            icon: const Icon(Icons.tune),
            onPressed: fleet.busy || repeaters.isEmpty
                ? null
                : () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const FleetBulkSettingsScreen(),
                    ),
                  ),
          ),
          IconButton(
            tooltip: l10n.fleet_addRepeater,
            icon: const Icon(Icons.add),
            onPressed: () => _showAdd(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _PollBar(
            fleet: fleet,
            count: repeaters.length,
            connected: connector.isConnected,
            nameOf: (k) => store.byKey(k)?.name ?? k.substring(0, 8),
          ),
          const SizedBox(height: 12),
          if (repeaters.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                l10n.fleet_empty,
                textAlign: TextAlign.center,
                style: TextStyle(color: MeshPalette.ink3),
              ),
            ),
          for (final r in repeaters)
            FleetHealthCard(
              repeater: r,
              health: store.healthFor(r.publicKeyHex),
              newestFirmware: newest,
              now: now,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      FleetRepeaterScreen(repeaterKey: r.publicKeyHex),
                ),
              ),
            ),
        ],
      ),
    );
  }

  static Future<void> _showAdd(BuildContext context) => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _AddRepeaterSheet(),
  );

  static Future<void> _showSync(BuildContext context) =>
      showDialog(context: context, builder: (_) => const _StationSyncDialog());
}

class _PollBar extends StatelessWidget {
  const _PollBar({
    required this.fleet,
    required this.count,
    required this.connected,
    required this.nameOf,
  });

  final FleetController fleet;
  final int count;
  final bool connected;
  final String Function(String key) nameOf;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (fleet.busy) {
      final current = fleet.current;
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                current == null
                    ? l10n.fleet_waiting
                    : l10n.fleet_asking(nameOf(current)),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: fleet.total == 0 ? null : fleet.done / fleet.total,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.fleet_progress(fleet.done, fleet.total),
                      style: TextStyle(color: MeshPalette.ink3, fontSize: 12),
                    ),
                  ),
                  TextButton(
                    onPressed: fleet.stop,
                    child: Text(l10n.fleet_stop),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: connected && count > 0
              ? () => unawaited(fleet.pollAll())
              : null,
          icon: const Icon(Icons.radar),
          label: Text(l10n.fleet_pollAll),
        ),
        const SizedBox(height: 4),
        Text(
          connected
              ? l10n.fleet_pollHint(FleetController.minStagger.inSeconds)
              : l10n.fleet_needsRadio,
          textAlign: TextAlign.center,
          style: TextStyle(color: MeshPalette.ink3, fontSize: 12),
        ),
      ],
    );
  }
}

String fleetStatusLabel(AppLocalizations l10n, FleetStatus s) => switch (s) {
  FleetStatus.healthy => l10n.fleet_statusHealthy,
  FleetStatus.lowBattery => l10n.fleet_statusLowBattery,
  FleetStatus.quiet => l10n.fleet_statusQuiet,
  FleetStatus.firmwareBehind => l10n.fleet_statusFirmwareBehind,
  FleetStatus.unknown => l10n.fleet_statusUnknown,
};

String fleetErrorLabel(AppLocalizations l10n, String code) => switch (code) {
  'no_contact' => l10n.fleet_errorNoContact,
  'login' => l10n.fleet_errorLogin,
  'timeout' => l10n.fleet_errorTimeout,
  _ => l10n.fleet_errorOther,
};

String fleetAgo(AppLocalizations l10n, DateTime at, DateTime now) {
  final d = now.difference(at);
  if (d.inMinutes < 1) return l10n.fleet_agoNow;
  if (d.inHours < 1) return l10n.fleet_agoMinutes(d.inMinutes);
  if (d.inDays < 1) return l10n.fleet_agoHours(d.inHours);
  return l10n.fleet_agoDays(d.inDays);
}

String _uptime(AppLocalizations l10n, int secs) {
  final d = Duration(seconds: secs);
  if (d.inDays > 0) return l10n.fleet_uptimeDays(d.inDays, d.inHours % 24);
  return l10n.fleet_uptimeHours(d.inHours, d.inMinutes % 60);
}

class _StatusPill extends StatelessWidget {
  const _StatusPill(this.status);

  final FleetStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (status) {
      FleetStatus.healthy => (MeshPalette.signal, Icons.check_circle),
      FleetStatus.lowBattery => (MeshPalette.warn, Icons.battery_alert),
      FleetStatus.quiet => (MeshPalette.alert, Icons.portable_wifi_off),
      FleetStatus.firmwareBehind => (MeshPalette.warn, Icons.system_update),
      FleetStatus.unknown => (MeshPalette.ink3, Icons.help_outline),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            fleetStatusLabel(context.l10n, status),
            style: TextStyle(fontSize: 12, color: color),
          ),
        ],
      ),
    );
  }
}

/// A repeater's latest health: battery, noise, SNR, uptime, firmware,
/// neighbours, last heard and a status pill.
class FleetHealthCard extends StatelessWidget {
  const FleetHealthCard({
    super.key,
    required this.repeater,
    required this.health,
    required this.now,
    this.newestFirmware,
    this.onTap,
  });

  final FleetRepeater repeater;
  final FleetHealth health;
  final DateTime now;
  final FirmwareVersion? newestFirmware;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final status = fleetStatusFor(
      health,
      now: now,
      newestFirmware: newestFirmware,
    );
    final dash = l10n.common_notAvailable;
    final mv = health.batteryMv;
    final last = health.lastPoll;
    final metrics = <(IconData, String, String)>[
      (
        Icons.battery_std,
        l10n.fleet_battery,
        mv == null
            ? dash
            : l10n.common_voltageValue((mv / 1000).toStringAsFixed(2)),
      ),
      (
        Icons.graphic_eq,
        l10n.fleet_noiseFloor,
        health.noiseFloor == null ? dash : l10n.fleet_dbm(health.noiseFloor!),
      ),
      (
        Icons.signal_cellular_alt,
        l10n.fleet_lastSnr,
        health.lastSnr == null
            ? dash
            : l10n.fleet_db(health.lastSnr!.toStringAsFixed(1)),
      ),
      (
        Icons.timer_outlined,
        l10n.fleet_uptime,
        health.uptimeSecs == null ? dash : _uptime(l10n, health.uptimeSecs!),
      ),
      (Icons.memory, l10n.fleet_firmware, health.firmware ?? dash),
      (
        Icons.hub_outlined,
        l10n.fleet_neighbours,
        health.neighbours?.toString() ?? dash,
      ),
      (
        Icons.hearing,
        l10n.fleet_lastHeard,
        health.lastHeard == null
            ? dash
            : fleetAgo(l10n, health.lastHeard!, now),
      ),
    ];
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.cell_tower, color: MeshPalette.accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      repeater.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _StatusPill(status),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                runSpacing: 6,
                children: [
                  for (final (icon, label, value) in metrics)
                    Semantics(
                      label: '$label: $value',
                      excludeSemantics: true,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 16, color: MeshPalette.ink3),
                          const SizedBox(width: 4),
                          Text(value),
                        ],
                      ),
                    ),
                ],
              ),
              if (last != null && !last.ok && last.error != null) ...[
                const SizedBox(height: 6),
                Text(
                  l10n.fleet_lastPollFailed(
                    fleetErrorLabel(l10n, last.error!),
                    fleetAgo(l10n, last.at, now),
                  ),
                  style: TextStyle(color: MeshPalette.alert, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// One repeater: trends, poll now, password and removal.
class FleetRepeaterScreen extends StatefulWidget {
  const FleetRepeaterScreen({super.key, required this.repeaterKey});

  final String repeaterKey;

  @override
  State<FleetRepeaterScreen> createState() => _FleetRepeaterScreenState();
}

class _FleetRepeaterScreenState extends State<FleetRepeaterScreen> {
  int _days = 7;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final store = context.watch<FleetStore?>();
    final fleet = context.watch<FleetController?>();
    final connector = context.watch<MeshCoreConnector>();
    final rep = store?.byKey(widget.repeaterKey);
    if (store == null || fleet == null || rep == null) {
      return Scaffold(appBar: AppBar(title: Text(l10n.fleet_title)));
    }
    final now = DateTime.now();
    final start = now.subtract(Duration(days: _days));
    final samples = store
        .historyFor(rep.publicKeyHex)
        .where((s) => s.ok && s.at.isAfter(start))
        .toList();
    final battery = [
      for (final s in samples)
        if (s.batteryMv case final mv? when mv > 0)
          (at: s.at, value: mv / 1000),
    ];
    final noise = [
      for (final s in samples)
        if (s.noiseFloor case final nf?) (at: s.at, value: nf.toDouble()),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(rep.name), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FleetHealthCard(
            repeater: rep,
            health: store.healthFor(rep.publicKeyHex),
            now: now,
          ),
          SelectableText(
            rep.publicKeyHex,
            style: TextStyle(fontSize: 11, color: MeshPalette.ink3),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              FilledButton.tonalIcon(
                onPressed: fleet.busy || !connector.isConnected
                    ? null
                    : () => unawaited(fleet.pollOne(rep.publicKeyHex)),
                icon: const Icon(Icons.refresh),
                label: Text(l10n.fleet_pollNow),
              ),
              OutlinedButton.icon(
                onPressed: () => _setPassword(context, fleet, rep),
                icon: const Icon(Icons.key),
                label: Text(l10n.fleet_password),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SegmentedButton<int>(
            segments: [
              for (final d in const [1, 7, 30, 90])
                ButtonSegment(value: d, label: Text(l10n.fleet_days(d))),
            ],
            selected: {_days},
            onSelectionChanged: (v) => setState(() => _days = v.first),
          ),
          const SizedBox(height: 16),
          Text(l10n.fleet_batteryTrend, style: MeshTheme.accentLabel()),
          const SizedBox(height: 6),
          _chartOrEmpty(
            l10n,
            TimeSeriesChart(
              points: battery,
              start: start,
              end: now,
              minSpan: 0.2,
              threshold: FleetThresholds.lowBatteryMv / 1000,
              format: (v) => v.toStringAsFixed(2),
              semanticsLabel: l10n.fleet_batteryTrend,
            ),
            battery.isEmpty,
          ),
          const SizedBox(height: 16),
          Text(l10n.fleet_noiseTrend, style: MeshTheme.accentLabel()),
          const SizedBox(height: 6),
          _chartOrEmpty(
            l10n,
            TimeSeriesChart(
              points: noise,
              start: start,
              end: now,
              minSpan: 5,
              format: (v) => v.toStringAsFixed(0),
              color: MeshPalette.secondary,
              semanticsLabel: l10n.fleet_noiseTrend,
            ),
            noise.isEmpty,
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: MeshPalette.alert),
            onPressed: () => _remove(context, fleet, rep),
            icon: const Icon(Icons.delete_outline),
            label: Text(l10n.fleet_remove),
          ),
        ],
      ),
    );
  }

  Widget _chartOrEmpty(AppLocalizations l10n, Widget chart, bool empty) => empty
      ? Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            l10n.fleet_noHistory,
            style: TextStyle(color: MeshPalette.ink3),
          ),
        )
      : chart;

  Future<void> _setPassword(
    BuildContext context,
    FleetController fleet,
    FleetRepeater rep,
  ) async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => const _PasswordDialog(),
    );
    if (result == null) return;
    if (result.isEmpty) {
      await fleet.passwords.delete(rep.publicKeyHex);
    } else {
      await fleet.passwords.write(rep.publicKeyHex, result);
    }
    if (!context.mounted) return;
    showDismissibleSnackBar(
      context,
      content: Text(context.l10n.fleet_passwordSaved),
    );
  }

  Future<void> _remove(
    BuildContext context,
    FleetController fleet,
    FleetRepeater rep,
  ) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.fleet_removeTitle),
        content: Text(l10n.fleet_removeBody(rep.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.common_cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.common_remove),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await fleet.passwords.delete(rep.publicKeyHex);
    fleet.store.remove(rep.publicKeyHex);
    if (context.mounted) Navigator.of(context).pop();
  }
}

class _PasswordDialog extends StatefulWidget {
  const _PasswordDialog();

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  final _controller = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.fleet_password),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            obscureText: _obscure,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n.login_password,
              suffixIcon: IconButton(
                tooltip: l10n.a11y_showHide,
                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.fleet_passwordHint,
            style: TextStyle(fontSize: 12, color: MeshPalette.ink3),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, ''),
          child: Text(l10n.common_clear),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.common_cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: Text(l10n.common_save),
        ),
      ],
    );
  }
}

class _AddRepeaterSheet extends StatefulWidget {
  const _AddRepeaterSheet();

  @override
  State<_AddRepeaterSheet> createState() => _AddRepeaterSheetState();
}

class _AddRepeaterSheetState extends State<_AddRepeaterSheet> {
  final _key = TextEditingController();
  final _name = TextEditingController();
  final _search = TextEditingController();
  final _password = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _key.dispose();
    _name.dispose();
    _search.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _add(String key, String name) async {
    final fleet = context.read<FleetController?>();
    if (fleet == null) return;
    final normal = FleetRepeater.normalizeKey(key);
    if (normal == null) {
      setState(() => _error = context.l10n.fleet_badKey);
      return;
    }
    if (!fleet.store.add(normal, name)) {
      setState(() => _error = context.l10n.fleet_alreadyListed);
      return;
    }
    if (_password.text.isNotEmpty) {
      await fleet.passwords.write(normal, _password.text);
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final store = context.watch<FleetStore?>();
    final connector = context.watch<MeshCoreConnector>();
    final listed = store?.contains ?? (_) => false;
    final total = pickableRepeaters(
      connector.allContactsUnfiltered,
      listed: listed,
    ).length;
    final heard = pickableRepeaters(
      connector.allContactsUnfiltered,
      listed: listed,
      query: _search.text,
    );
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.75,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.fleet_addRepeater,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: InputDecoration(
                labelText: l10n.fleet_passwordOptional,
                helperText: l10n.fleet_passwordHint,
                helperMaxLines: 3,
              ),
            ),
            const SizedBox(height: 12),
            Text(l10n.fleet_heardRepeaters, style: MeshTheme.accentLabel()),
            TextField(
              controller: _search,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: l10n.contacts_searchRepeaters(total, ''),
              ),
              onChanged: (_) => setState(() {}),
            ),
            Expanded(
              child: heard.isEmpty
                  ? Center(
                      child: Text(
                        l10n.fleet_noHeard,
                        style: TextStyle(color: MeshPalette.ink3),
                      ),
                    )
                  : ListView(
                      children: [
                        for (final c in heard)
                          ListTile(
                            leading: const Icon(Icons.cell_tower),
                            title: Text(c.name),
                            subtitle: Text(c.shortPubKeyHex),
                            trailing: const Icon(Icons.add),
                            onTap: () => _add(c.publicKeyHex, c.name),
                          ),
                      ],
                    ),
            ),
            const Divider(),
            Text(l10n.fleet_pasteKey, style: MeshTheme.accentLabel()),
            TextField(
              controller: _key,
              decoration: InputDecoration(
                labelText: l10n.fleet_publicKey,
                errorText: _error,
              ),
            ),
            TextField(
              controller: _name,
              decoration: InputDecoration(labelText: l10n.fleet_name),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => _add(_key.text, _name.text),
              child: Text(l10n.common_add),
            ),
          ],
        ),
      ),
    );
  }
}

class _StationSyncDialog extends StatefulWidget {
  const _StationSyncDialog();

  @override
  State<_StationSyncDialog> createState() => _StationSyncDialogState();
}

class _StationSyncDialogState extends State<_StationSyncDialog> {
  late final TextEditingController _address;
  bool _running = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _address = TextEditingController(
      text: context.read<FleetStore?>()?.station ?? '',
    );
  }

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  Future<void> _sync() async {
    final l10n = context.l10n;
    final fleet = context.read<FleetController?>();
    final uri = FleetStationClient.parseAddress(_address.text);
    if (fleet == null) return;
    if (uri == null) {
      setState(() => _message = l10n.fleet_badAddress);
      return;
    }
    setState(() {
      _running = true;
      _message = null;
    });
    final client = FleetStationClient(uri);
    try {
      final added = await fleet.syncFromStation(client);
      fleet.store.station = _address.text;
      if (mounted) setState(() => _message = l10n.fleet_syncDone(added));
    } on FleetStationException catch (e) {
      if (mounted) {
        setState(
          () => _message = e.statusCode == 401 || e.statusCode == 403
              ? l10n.fleet_syncSignIn
              : l10n.fleet_syncFailed,
        );
      }
    } catch (_) {
      if (mounted) setState(() => _message = l10n.fleet_syncFailed);
    } finally {
      client.close();
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.fleet_syncStation),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _address,
            enabled: !_running,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              labelText: l10n.fleet_stationAddress,
              hintText: '192.168.1.20:${FleetStationClient.defaultPort}',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.fleet_syncHint,
            style: TextStyle(fontSize: 12, color: MeshPalette.ink3),
          ),
          if (_running) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ],
          if (_message != null) ...[
            const SizedBox(height: 12),
            Text(_message!),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.common_close),
        ),
        FilledButton(
          onPressed: _running ? null : _sync,
          child: Text(l10n.fleet_sync),
        ),
      ],
    );
  }
}
