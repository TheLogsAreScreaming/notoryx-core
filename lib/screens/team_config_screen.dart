import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../build_flavor.dart';
import '../connector/meshcore_connector.dart';
import '../connector/meshcore_protocol.dart';
import '../models/team_config.dart';
import '../models/waypoint.dart';
import '../services/waypoint_store.dart';
import '../widgets/qr_code_display.dart';
import '../widgets/qr_scanner_widget.dart';

/// The most text a phone camera reliably reads from one QR code.
const _maxQrLength = 1800;

const _secretWarning =
    'This includes channel keys. Anyone with this file or QR code and the '
    'passphrase can read those channels. Tell people the passphrase in '
    'person or some other way, never alongside the file.';

/// Shares radio settings, channels, waypoints and routes with a team.
class TeamConfigScreen extends StatelessWidget {
  const TeamConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Team setup'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Share'),
              Tab(text: 'Receive'),
            ],
          ),
        ),
        body: const TabBarView(children: [_ShareTab(), _ReceiveTab()]),
      ),
    );
  }
}

class _ShareTab extends StatefulWidget {
  const _ShareTab();

  @override
  State<_ShareTab> createState() => _ShareTabState();
}

class _ShareTabState extends State<_ShareTab> {
  final _pass = TextEditingController();
  var _radio = true, _channels = true, _places = true, _busy = false;
  String? _sealed;
  String? _error;

  Future<void> _create() async {
    final radio = context.read<MeshCoreConnector>();
    final store = context.read<WaypointStore?>();
    final freq = radio.currentFreqHz, bw = radio.currentBwHz;
    final sf = radio.currentSf, cr = radio.currentCr;
    final config = TeamConfig(
      radio: _radio && freq != null && bw != null && sf != null && cr != null
          ? TeamRadioSettings(
              freq: freq,
              bandwidth: bw,
              spreadingFactor: sf,
              codingRate: cr,
              txPower: radio.currentTxPower,
            )
          : null,
      channels: _channels
          ? [
              for (final c in radio.channels)
                if (c.name.isNotEmpty && c.index != 0)
                  TeamChannel(c.name, c.psk),
            ]
          : const [],
      waypoints: _places ? (store?.waypoints ?? const []) : const [],
      routes: _places ? (store?.routes ?? const []) : const [],
    );
    setState(() {
      _busy = true;
      _error = null;
      _sealed = null;
    });
    try {
      final sealed = await sealTeamConfig(config, _pass.text);
      if (mounted) setState(() => _sealed = sealed);
    } on FormatException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _shareFile() async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/team-setup.notoryx');
    await file.writeAsString(_sealed!);
    await SharePlus.instance.share(
      ShareParams(subject: 'Team setup', files: [XFile(file.path)]),
    );
  }

  @override
  void dispose() {
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sealed = _sealed;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Radio settings'),
          value: _radio,
          onChanged: (v) => setState(() => _radio = v!),
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Channels and their keys'),
          subtitle: const Text('Not the public channel'),
          value: _channels,
          onChanged: (v) => setState(() => _channels = v!),
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Waypoints and routes'),
          value: _places,
          onChanged: (v) => setState(() => _places = v!),
        ),
        TextField(
          controller: _pass,
          obscureText: true,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            labelText: 'Passphrase (at least 12 characters)',
          ),
        ),
        const SizedBox(height: 8),
        const Text(_secretWarning),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: !_busy && _pass.text.length >= minTeamPassphrase
              ? _create
              : null,
          child: const Text('Create'),
        ),
        if (_error case final e?) Text(e),
        if (sealed != null) ...[
          const SizedBox(height: 16),
          if (sealed.length <= _maxQrLength)
            Center(child: QrCodeDisplay(data: sealed, size: 280))
          else
            const Text('Too much for a QR code. Share it as a file instead.'),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _shareFile,
            icon: const Icon(Icons.ios_share),
            label: const Text('Share as a file'),
          ),
        ],
      ],
    );
  }
}

class _ReceiveTab extends StatefulWidget {
  const _ReceiveTab();

  @override
  State<_ReceiveTab> createState() => _ReceiveTabState();
}

class _ReceiveTabState extends State<_ReceiveTab> {
  final _pass = TextEditingController();
  String? _sealed;
  TeamConfig? _config;
  String? _message;
  var _busy = false;
  var _applyRadio = false, _applyChannels = true, _applyPlaces = true;

  Future<void> _pickFile() async {
    final file = await openFile();
    if (file == null) return;
    final text = await file.readAsString();
    if (mounted) _received(text);
  }

  Future<void> _scan() async {
    final text = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (route) => Scaffold(
          appBar: AppBar(title: const Text('Scan team setup')),
          body: QrScannerWidget(
            onScanned: (data) => Navigator.of(route).pop(data),
          ),
        ),
      ),
    );
    if (text != null && mounted) _received(text);
  }

  void _received(String text) => setState(() {
    _sealed = text;
    _config = null;
    _message = null;
  });

  Future<void> _open() async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final config = await openTeamConfig(_sealed!, _pass.text);
      if (mounted) setState(() => _config = config);
    } on FormatException catch (e) {
      if (mounted) setState(() => _message = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _message = 'Wrong passphrase, or the file is damaged.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _apply() async {
    final config = _config!;
    final connector = context.read<MeshCoreConnector>();
    final store = context.read<WaypointStore?>();
    setState(() => _busy = true);
    final done = <String>[];
    try {
      if (_applyPlaces && store != null) {
        final added = await store.addImport(
          GpxImport(config.waypoints, config.routes),
        );
        done.add('${added.waypoints} waypoints, ${added.routes} routes');
      }
      if (_applyChannels && connector.isConnected) {
        final plan = planChannelSlots(
          connector.channels,
          config.channels,
          connector.maxChannels,
        );
        for (final entry in plan.entries) {
          await connector.setChannel(
            entry.key,
            entry.value.name,
            entry.value.psk,
          );
        }
        final left = config.channels.length - plan.length;
        done.add(
          '${plan.length} channels added'
          '${left > 0 ? ', $left already there or no room' : ''}',
        );
      }
      // Last: changing the radio's settings can drop the link.
      final radio = config.radio;
      if (_applyRadio && radio != null && connector.isConnected) {
        await connector.sendFrame(
          buildSetRadioParamsFrame(
            radio.freq,
            radio.bandwidth,
            radio.spreadingFactor,
            radio.codingRate,
          ),
        );
        if (radio.txPower case final power?) {
          await connector.sendFrame(buildSetRadioTxPowerFrame(power));
        }
        await connector.refreshDeviceInfo();
        done.add('radio settings changed');
      }
      if (mounted) setState(() => _message = 'Done: ${done.join('; ')}.');
    } catch (e) {
      if (mounted) {
        setState(() => _message = 'Stopped part way (${done.join('; ')}): $e');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = _config;
    final connected = context.watch<MeshCoreConnector>().isConnected;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Wrap(
          spacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.file_open_outlined),
              label: const Text('Open a file'),
            ),
            if (!kLiteBuild)
              OutlinedButton.icon(
                onPressed: _scan,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan a QR code'),
              ),
          ],
        ),
        if (_sealed != null && config == null) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _pass,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Passphrase'),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _busy ? null : _open,
            child: const Text('Open'),
          ),
        ],
        if (config != null) ...[
          const SizedBox(height: 12),
          if (config.channels.isNotEmpty)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Channels: ${config.channels.map((c) => c.name).join(', ')}',
              ),
              value: _applyChannels,
              onChanged: (v) => setState(() => _applyChannels = v!),
            ),
          if (config.waypoints.isNotEmpty || config.routes.isNotEmpty)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                '${config.waypoints.length} waypoints, '
                '${config.routes.length} routes',
              ),
              value: _applyPlaces,
              onChanged: (v) => setState(() => _applyPlaces = v!),
            ),
          if (config.radio case final r?)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Radio settings: ${r.freq}, ${r.bandwidth}, '
                'SF${r.spreadingFactor}, CR${r.codingRate}',
              ),
              subtitle: const Text(
                'Off by default. Check these are legal where you are. A '
                'different frequency takes you off your current mesh.',
              ),
              value: _applyRadio,
              onChanged: (v) => setState(() => _applyRadio = v!),
            ),
          if (!connected)
            const Text('Connect a radio to add channels or change settings.'),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _busy ? null : _apply,
            child: const Text('Apply'),
          ),
        ],
        if (_message case final m?)
          Padding(padding: const EdgeInsets.only(top: 12), child: Text(m)),
      ],
    );
  }
}
