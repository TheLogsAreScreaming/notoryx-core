import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../services/offline_outbox.dart';

/// Messages in [target] waiting for the radio, each removable.
class OutboxBanner extends StatelessWidget {
  const OutboxBanner({super.key, required this.target});

  /// `message:<contact key>` or `channel:<index>`.
  final String target;

  @override
  Widget build(BuildContext context) {
    final outbox = context.watch<OfflineOutbox?>();
    final entries = outbox?.entriesFor(target) ?? const <OutboxEntry>[];
    if (outbox == null || entries.isEmpty) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 4),
      color: scheme.surfaceContainerHigh,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: scheme.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  context.l10n.outbox_waiting(entries.length),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: scheme.primary,
                  ),
                ),
              ),
            ],
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 132),
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              children: [
                for (final entry in entries)
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.text,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                      ),
                      IconButton(
                        tooltip: context.l10n.common_delete,
                        icon: const Icon(Icons.close, size: 18),
                        constraints: const BoxConstraints(
                          minWidth: 44,
                          minHeight: 44,
                        ),
                        onPressed: () => outbox.remove(entry.id),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
