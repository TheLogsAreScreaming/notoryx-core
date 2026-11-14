import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../connector/meshcore_connector.dart';
import '../l10n/l10n.dart';
import '../models/firmware_release.dart';
import 'encrypted_backup_screen.dart';

/// Explains how to update the radio's firmware with the official web
/// flasher. The app never flashes firmware itself, and only goes online
/// when the person asks it to check for the latest release.
class FirmwareUpdateScreen extends StatefulWidget {
  const FirmwareUpdateScreen({super.key, this.fetchReleases});

  /// Returns the releases JSON; replaced in tests.
  final Future<Object?> Function()? fetchReleases;

  @override
  State<FirmwareUpdateScreen> createState() => _FirmwareUpdateScreenState();
}

class _FirmwareUpdateScreenState extends State<FirmwareUpdateScreen> {
  bool _checking = false;
  FirmwareVersion? _latest;
  bool _checkFailed = false;

  Future<Object?> _defaultFetch() async {
    final res = await http
        .get(
          Uri.parse(meshCoreReleasesApi),
          headers: const {'Accept': 'application/vnd.github+json'},
        )
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
    return jsonDecode(res.body);
  }

  Future<void> _check() async {
    setState(() {
      _checking = true;
      _checkFailed = false;
    });
    try {
      final json = await (widget.fetchReleases ?? _defaultFetch)();
      final latest = latestCompanionRelease(json);
      if (!mounted) return;
      setState(() {
        _latest = latest;
        _checkFailed = latest == null;
      });
    } catch (_) {
      if (mounted) setState(() => _checkFailed = true);
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _openFlasher() async {
    final ok = await launchUrl(
      Uri.parse(meshCoreFlasherUrl),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && mounted) await _copyLink();
  }

  Future<void> _copyLink() async {
    await Clipboard.setData(const ClipboardData(text: meshCoreFlasherUrl));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.fw_linkCopied)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final connector = context.watch<MeshCoreConnector>();
    final textTheme = Theme.of(context).textTheme;
    final current = FirmwareVersion.parse(connector.firmwareVersionString);
    final latest = _latest;
    String? verdict;
    if (latest != null && current != null) {
      verdict = current < latest
          ? l10n.fw_updateAvailable(latest.toString())
          : l10n.fw_upToDate;
    }
    return Scaffold(
      appBar: AppBar(title: Text(l10n.fw_title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.memory_outlined),
              title: Text(
                connector.firmwareVersionString ?? l10n.fw_unknownVersion,
              ),
              subtitle: Text(
                [
                  ?connector.manufacturerName,
                  ?verdict,
                  if (_checkFailed) l10n.fw_checkFailed,
                ].join('\n'),
              ),
              isThreeLine: verdict != null || _checkFailed,
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: _checking ? null : _check,
              icon: _checking
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_sync_outlined),
              label: Text(l10n.fw_checkLatest),
            ),
          ),
          Text(l10n.fw_checkPrivacy, style: textTheme.bodySmall),
          const SizedBox(height: 16),
          Text(l10n.fw_stepsTitle, style: textTheme.titleMedium),
          const SizedBox(height: 8),
          _Step(
            n: 1,
            text: l10n.fw_step1,
            action: OutlinedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const EncryptedBackupScreen(),
                ),
              ),
              child: Text(l10n.fw_backup),
            ),
          ),
          _Step(
            n: 2,
            text: l10n.fw_step2,
            action: Wrap(
              spacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: _openFlasher,
                  icon: const Icon(Icons.open_in_new),
                  label: Text(l10n.fw_openFlasher),
                ),
                TextButton(onPressed: _copyLink, child: Text(l10n.fw_copyLink)),
              ],
            ),
          ),
          _Step(n: 3, text: l10n.fw_step3),
          _Step(n: 4, text: l10n.fw_step4),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.warning_amber_outlined),
              title: Text(l10n.fw_cautionTitle),
              subtitle: Text(l10n.fw_caution),
            ),
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.n, required this.text, this.action});

  final int n;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(radius: 12, child: Text('$n')),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text),
              if (action != null) ...[const SizedBox(height: 6), action!],
            ],
          ),
        ),
      ],
    ),
  );
}
