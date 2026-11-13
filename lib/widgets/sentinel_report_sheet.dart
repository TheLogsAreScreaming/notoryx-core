import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/snack_bar_builder.dart';
import '../l10n/app_localizations.dart';
import '../l10n/l10n.dart';
import '../models/channel_message.dart';
import '../services/sentinel_service.dart';
import '../theme/mesh_theme.dart';
import 'mesh_ui.dart';

String sentinelReasonLabel(AppLocalizations l10n, SentinelReason r) =>
    switch (r) {
      SentinelReason.spam => l10n.sentinel_reasonSpam,
      SentinelReason.flooding => l10n.sentinel_reasonFlooding,
      SentinelReason.abuse => l10n.sentinel_reasonAbuse,
      SentinelReason.impersonation => l10n.sentinel_reasonImpersonation,
      SentinelReason.other => l10n.sentinel_reasonOther,
    };

/// Asks to turn community moderation on. Returns whether it is on now.
Future<bool> ensureSentinelEnabled(BuildContext context) async {
  final sentinel = context.read<SentinelService>();
  if (sentinel.enabled) return true;
  final l10n = context.l10n;
  final ok = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.sentinel_offPrompt),
      content: Text('${l10n.sentinel_intro}\n\n${l10n.sentinel_enableSub}'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(l10n.common_cancel),
        ),
        FilledButton(
          key: const ValueKey('sentinel-turn-on'),
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(l10n.sentinel_turnOn),
        ),
      ],
    ),
  );
  if (ok != true) return false;
  await sentinel.setEnabled(true);
  return true;
}

/// Reports a node to NOTORYX moderators. [nodeId] is a public key in hex,
/// or [sentinelNameId] for a channel sender.
Future<void> showSentinelReportSheet(
  BuildContext context, {
  required String nodeId,
  required String nodeName,
  String? messageExcerpt,
}) async {
  if (!await ensureSentinelEnabled(context)) return;
  if (!context.mounted) return;
  final outcome = await showMeshSheet<SentinelReportOutcome>(
    context,
    builder: (_) => _ReportSheet(
      nodeId: nodeId,
      nodeName: nodeName,
      messageExcerpt: messageExcerpt,
    ),
  );
  if (outcome == null || !context.mounted) return;
  final l10n = context.l10n;
  showDismissibleSnackBar(
    context,
    content: Text(switch (outcome) {
      SentinelReportSent(:final caseRef) => l10n.sentinel_sent(caseRef),
      SentinelReportQueued() => l10n.sentinel_queuedOne,
      SentinelReportRejected(:final message) => l10n.sentinel_rejected(message),
    }),
  );
}

class _ReportSheet extends StatefulWidget {
  const _ReportSheet({
    required this.nodeId,
    required this.nodeName,
    this.messageExcerpt,
  });

  final String nodeId;
  final String nodeName;
  final String? messageExcerpt;

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  SentinelReason _reason = SentinelReason.spam;
  final _note = TextEditingController();
  bool _includeMessage = true;
  bool _sending = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() => _sending = true);
    final excerpt = widget.messageExcerpt;
    final outcome = await context.read<SentinelService>().report(
      nodeId: widget.nodeId,
      nodeName: widget.nodeName,
      reason: _reason,
      note: _note.text,
      messageExcerpt: _includeMessage ? excerpt : null,
    );
    if (!mounted) return;
    Navigator.pop(context, outcome);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final excerpt = widget.messageExcerpt?.trim();
    final hasExcerpt = excerpt != null && excerpt.isNotEmpty;
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BottomSheetHeader(
              title: l10n.sentinel_reportTitle(widget.nodeName),
              subtitle: l10n.sentinel_title,
            ),
            RadioGroup<SentinelReason>(
              groupValue: _reason,
              onChanged: (r) {
                if (r != null && !_sending) setState(() => _reason = r);
              },
              child: Column(
                children: [
                  for (final r in SentinelReason.values)
                    RadioListTile<SentinelReason>(
                      key: ValueKey('sentinel-reason-${r.name}'),
                      value: r,
                      dense: true,
                      title: Text(sentinelReasonLabel(l10n, r)),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                key: const ValueKey('sentinel-note'),
                controller: _note,
                enabled: !_sending,
                maxLength: SentinelService.maxNote,
                maxLines: 3,
                minLines: 1,
                decoration: InputDecoration(labelText: l10n.sentinel_note),
              ),
            ),
            if (hasExcerpt)
              CheckboxListTile(
                key: const ValueKey('sentinel-include-message'),
                value: _includeMessage,
                onChanged: _sending
                    ? null
                    : (v) => setState(() => _includeMessage = v ?? false),
                title: Text(l10n.sentinel_includeMessage),
                subtitle: Text(
                  excerpt,
                  maxLines: 3,
                  overflow: TextOverflow.fade,
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(
                l10n.sentinel_sends,
                style: TextStyle(color: MeshPalette.ink3, fontSize: 12),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: FilledButton.icon(
                key: const ValueKey('sentinel-send-report'),
                onPressed: _sending ? null : () => unawaited(_send()),
                icon: _sending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.flag_outlined),
                label: Text(l10n.sentinel_send),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A small "Flagged" label for a node on the moderators' ban list.
class SentinelFlagChip extends StatelessWidget {
  const SentinelFlagChip({super.key, required this.ban});

  final SentinelBan ban;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final color = MeshPalette.warn;
    return Tooltip(
      message: l10n.sentinel_flaggedHint(ban.caseRef),
      child: Semantics(
        label: l10n.sentinel_flaggedHint(ban.caseRef),
        excludeSemantics: true,
        child: Container(
          margin: const EdgeInsetsDirectional.only(start: 6),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          decoration: BoxDecoration(
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.flag, size: 11, color: color),
              const SizedBox(width: 3),
              Text(
                l10n.sentinel_flagged,
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The moderation service if this widget tree has one (tests often don't).
SentinelService? maybeSentinel(BuildContext context, {bool listen = true}) {
  try {
    return Provider.of<SentinelService>(context, listen: listen);
  } on ProviderNotFoundException {
    return null;
  }
}

/// Shows [SentinelFlagChip] when the node is on the ban list, else nothing.
class SentinelFlag extends StatelessWidget {
  /// A node known by its public key.
  const SentinelFlag.forKey(String this.publicKeyHex, {super.key})
    : name = null;

  /// A channel sender known only by name.
  const SentinelFlag.forName(String this.name, {super.key})
    : publicKeyHex = null;

  final String? publicKeyHex;
  final String? name;

  @override
  Widget build(BuildContext context) {
    final sentinel = maybeSentinel(context);
    if (sentinel == null) return const SizedBox.shrink();
    final key = publicKeyHex;
    final ban = key != null
        ? sentinel.banForKey(key)
        : sentinel.banForName(name ?? '');
    return ban == null ? const SizedBox.shrink() : SentinelFlagChip(ban: ban);
  }
}

/// Whether [m] is hidden because the user chose to hide flagged senders.
bool sentinelHides(SentinelService? sentinel, ChannelMessage m) =>
    sentinel != null &&
    sentinel.hideFlagged &&
    !m.isOutgoing &&
    sentinel.banForName(m.senderName) != null;
