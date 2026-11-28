import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/snack_bar_builder.dart';
import '../l10n/l10n.dart';
import '../services/tak_feed_service.dart';
import '../widgets/adaptive_app_bar_title.dart';
import '../widgets/mesh_ui.dart';

/// Share with TAK: sends node positions to ATAK, iTAK or WinTAK.
class TakFeedScreen extends StatefulWidget {
  const TakFeedScreen({super.key});

  @override
  State<TakFeedScreen> createState() => _TakFeedScreenState();
}

class _TakFeedScreenState extends State<TakFeedScreen> {
  late final TextEditingController _host;
  late final TextEditingController _port;

  @override
  void initState() {
    super.initState();
    final feed = context.read<TakFeedService>();
    _host = TextEditingController(text: feed.host);
    _port = TextEditingController(text: '${feed.port}');
  }

  @override
  void dispose() {
    _host.dispose();
    _port.dispose();
    super.dispose();
  }

  Future<void> _toggle(TakFeedService feed, bool on) async {
    final l10n = context.l10n;
    if (on) {
      if (!await _saveTarget(feed)) return;
      if (!mounted) return;
      final ok = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.tak_consentTitle),
          content: Text(l10n.tak_consentBody('${feed.host}:${feed.port}')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.common_cancel),
            ),
            FilledButton(
              key: const ValueKey('tak-consent-ok'),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.tak_consentAgree),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }
    await feed.setEnabled(on);
  }

  Future<bool> _saveTarget(TakFeedService feed) async {
    final saved = await feed.setTarget(
      _host.text,
      int.tryParse(_port.text.trim()) ?? 0,
    );
    if (!saved && mounted) {
      showDismissibleSnackBar(
        context,
        content: Text(context.l10n.tak_badTarget),
      );
    }
    return saved;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final feed = context.watch<TakFeedService>();
    final supported = TakFeedService.supported;
    final sentAt = feed.lastSentAt;
    return Scaffold(
      appBar: AppBar(title: AdaptiveAppBarTitle(l10n.tak_title)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(l10n.tak_intro),
            ),
            MeshCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: SwitchListTile(
                key: const ValueKey('tak-enabled'),
                title: Text(l10n.tak_enable),
                subtitle: Text(
                  !supported
                      ? l10n.tak_unsupported
                      : feed.lastError != null
                      ? l10n.tak_error(feed.lastError!)
                      : sentAt != null
                      ? l10n.tak_lastSent(
                          feed.lastSentCount,
                          MaterialLocalizations.of(
                            context,
                          ).formatTimeOfDay(TimeOfDay.fromDateTime(sentAt)),
                        )
                      : l10n.tak_off,
                ),
                value: feed.enabled,
                onChanged: supported
                    ? (v) => unawaited(_toggle(feed, v))
                    : null,
              ),
            ),
            SectionHeader(l10n.tak_target),
            MeshCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    key: const ValueKey('tak-host'),
                    controller: _host,
                    enabled: !feed.enabled,
                    keyboardType: TextInputType.url,
                    decoration: InputDecoration(labelText: l10n.tak_host),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    key: const ValueKey('tak-port'),
                    controller: _port,
                    enabled: !feed.enabled,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: l10n.tak_port),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.tak_targetHint,
                    style: Theme.of(context).textTheme.bodySmall,
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
