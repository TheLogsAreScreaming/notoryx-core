import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../services/offline_outbox.dart';

String _when(BuildContext context, DateTime time) {
  final localizations = MaterialLocalizations.of(context);
  return '${localizations.formatShortDate(time)} '
      '${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(time))}';
}

/// Asks for a date and time to send at. Null if cancelled or in the past.
Future<DateTime?> pickSendTime(BuildContext context) async {
  final now = DateTime.now();
  final messenger = ScaffoldMessenger.maybeOf(context);
  final pastTime = context.l10n.schedule_pastTime;
  final date = await showDatePicker(
    context: context,
    initialDate: now,
    firstDate: now,
    lastDate: now.add(const Duration(days: 30)),
  );
  if (date == null || !context.mounted) return null;
  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))),
  );
  if (time == null) return null;
  final at = DateTime(date.year, date.month, date.day, time.hour, time.minute);
  if (!at.isAfter(DateTime.now())) {
    messenger?.showSnackBar(SnackBar(content: Text(pastTime)));
    return null;
  }
  return at;
}

/// Messages in [target] waiting for the radio or their time, each removable.
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
                          entry.sendAt == null
                              ? entry.text
                              : '${context.l10n.schedule_for(_when(context, entry.sendAt!))}\n${entry.text}',
                          maxLines: 3,
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
