import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../connector/meshcore_connector.dart';
import '../helpers/snack_bar_builder.dart';
import '../l10n/l10n.dart';
import '../services/sentinel_service.dart';
import '../theme/mesh_theme.dart';

/// Community moderation: the opt-in switch, the advisory ban list's status,
/// whether the user's own node is flagged, and appeals.
class SentinelScreen extends StatelessWidget {
  const SentinelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sentinel = context.watch<SentinelService>();
    final connector = context.watch<MeshCoreConnector>();
    final selfKey = connector.selfPublicKey == null
        ? null
        : connector.selfPublicKeyHex;
    final selfName = connector.selfName;
    final ownBan =
        (selfKey == null || selfKey.isEmpty
            ? null
            : sentinel.banForKey(selfKey)) ??
        (selfName == null ? null : sentinel.banForName(selfName));
    final synced = sentinel.syncedAt;
    final ml = MaterialLocalizations.of(context);
    String when(DateTime t) {
      final local = t.toLocal();
      return '${ml.formatShortDate(local)} '
          '${ml.formatTimeOfDay(TimeOfDay.fromDateTime(local))}';
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.sentinel_title)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(l10n.sentinel_intro),
          ),
          SwitchListTile(
            key: const ValueKey('sentinel-enabled'),
            secondary: const Icon(Icons.shield_outlined),
            title: Text(l10n.sentinel_enable),
            subtitle: Text(l10n.sentinel_enableSub),
            value: sentinel.enabled,
            onChanged: (v) => unawaited(sentinel.setEnabled(v)),
          ),
          if (sentinel.enabled) ...[
            SwitchListTile(
              key: const ValueKey('sentinel-hide'),
              secondary: const Icon(Icons.visibility_off_outlined),
              title: Text(l10n.sentinel_hide),
              subtitle: Text(l10n.sentinel_hideSub),
              value: sentinel.hideFlagged,
              onChanged: (v) => unawaited(sentinel.setHideFlagged(v)),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.list_alt_outlined),
              title: Text(l10n.sentinel_flaggedCount(sentinel.flaggedCount)),
              subtitle: Text(
                [
                  synced == null
                      ? l10n.sentinel_neverSynced
                      : l10n.sentinel_synced(when(synced)),
                  if (sentinel.queuedCount > 0)
                    l10n.sentinel_queued(sentinel.queuedCount),
                ].join('\n'),
              ),
              trailing: sentinel.syncing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : TextButton(
                      key: const ValueKey('sentinel-refresh'),
                      onPressed: () => unawaited(sentinel.refresh(force: true)),
                      child: Text(l10n.sentinel_refresh),
                    ),
            ),
            const Divider(),
            ListTile(
              leading: Icon(
                ownBan == null ? Icons.verified_outlined : Icons.flag,
                color: ownBan == null ? MeshPalette.signal : MeshPalette.warn,
              ),
              title: Text(l10n.sentinel_yourNode),
              subtitle: Text(
                selfKey == null && selfName == null
                    ? l10n.sentinel_yourNodeUnknown
                    : ownBan == null
                    ? l10n.sentinel_yourNodeClear
                    : ownBan.appealPending
                    ? '${l10n.sentinel_yourNodeFlagged(ownBan.caseRef)}\n'
                          '${l10n.sentinel_appealPending}'
                    : l10n.sentinel_yourNodeFlagged(ownBan.caseRef),
              ),
              trailing: ownBan != null && !ownBan.appealPending
                  ? FilledButton(
                      key: const ValueKey('sentinel-appeal-own'),
                      onPressed: () => unawaited(
                        showSentinelAppealDialog(
                          context,
                          caseRef: ownBan.caseRef,
                        ),
                      ),
                      child: Text(l10n.sentinel_appeal),
                    )
                  : null,
            ),
            ListTile(
              key: const ValueKey('sentinel-appeal-other'),
              leading: const Icon(Icons.gavel_outlined),
              title: Text(l10n.sentinel_appealOther),
              onTap: () => unawaited(showSentinelAppealDialog(context)),
            ),
            if (sentinel.sentReports.isNotEmpty) ...[
              const Divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Semantics(
                  header: true,
                  child: Text(
                    l10n.sentinel_yourReports,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ),
              for (final r in sentinel.sentReports)
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.flag_outlined),
                  title: Text(r.nodeName ?? r.caseRef),
                  subtitle: Text('${r.caseRef} · ${when(r.at)}'),
                ),
            ],
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              l10n.sentinel_sends,
              style: TextStyle(color: MeshPalette.ink3, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

/// Asks for an appeal statement and sends it.
Future<void> showSentinelAppealDialog(
  BuildContext context, {
  String? caseRef,
}) async {
  final l10n = context.l10n;
  final sentinel = context.read<SentinelService>();
  final caseCtl = TextEditingController(text: caseRef ?? '');
  final statementCtl = TextEditingController();
  final contactCtl = TextEditingController();
  final caseRe = RegExp(r'^SNT-\d{1,10}$', caseSensitive: false);
  try {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) {
          final valid =
              caseRe.hasMatch(caseCtl.text.trim()) &&
              statementCtl.text.trim().length >= 3;
          return AlertDialog(
            title: Text(l10n.sentinel_appeal),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    key: const ValueKey('sentinel-appeal-case'),
                    controller: caseCtl,
                    readOnly: caseRef != null,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: l10n.sentinel_caseRef,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  TextField(
                    key: const ValueKey('sentinel-appeal-statement'),
                    controller: statementCtl,
                    maxLength: 2000,
                    minLines: 2,
                    maxLines: 6,
                    decoration: InputDecoration(
                      labelText: l10n.sentinel_statement,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  TextField(
                    key: const ValueKey('sentinel-appeal-contact'),
                    controller: contactCtl,
                    maxLength: 200,
                    decoration: InputDecoration(
                      labelText: l10n.sentinel_contact,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(l10n.common_cancel),
              ),
              FilledButton(
                key: const ValueKey('sentinel-appeal-send'),
                onPressed: valid
                    ? () => Navigator.pop(dialogContext, true)
                    : null,
                child: Text(l10n.sentinel_appealSend),
              ),
            ],
          );
        },
      ),
    );
    if (ok != true) return;
    final outcome = await sentinel.appeal(
      caseRef: caseCtl.text,
      statement: statementCtl.text,
      contact: contactCtl.text,
    );
    if (!context.mounted) return;
    showDismissibleSnackBar(
      context,
      content: Text(switch (outcome) {
        SentinelAppealOutcome.received => l10n.sentinel_appealReceived,
        SentinelAppealOutcome.unknownCase => l10n.sentinel_appealUnknown,
        SentinelAppealOutcome.notAppealable => l10n.sentinel_appealNotOpen,
        SentinelAppealOutcome.tooMany => l10n.sentinel_appealTooMany,
        SentinelAppealOutcome.failed => l10n.sentinel_failed,
      }),
    );
  } finally {
    caseCtl.dispose();
    statementCtl.dispose();
    contactCtl.dispose();
  }
}
