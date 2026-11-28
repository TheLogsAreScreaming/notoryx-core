import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../services/bookmark_service.dart';
import '../helpers/snack_bar_builder.dart';

/// The Bookmark / Remove bookmark row of a message's long-press sheet.
/// Hidden where the app provides no [BookmarkService] (some tests).
Widget bookmarkSheetTile(
  BuildContext screenContext,
  BuildContext sheetContext, {
  required BookmarkSource source,
  required String sourceId,
  required String sourceName,
  required String messageId,
  required String senderName,
  required String text,
  required DateTime timestamp,
  required bool isOutgoing,
}) {
  final BookmarkService service;
  try {
    service = screenContext.read<BookmarkService>();
  } on ProviderNotFoundException {
    return const SizedBox.shrink();
  }
  final saved = service.isBookmarked(source, sourceId, messageId);
  final l10n = screenContext.l10n;
  return ListTile(
    key: const ValueKey('message-bookmark'),
    leading: Icon(
      saved ? Icons.bookmark_remove_outlined : Icons.bookmark_add_outlined,
    ),
    title: Text(saved ? l10n.bookmarks_remove : l10n.bookmarks_add),
    onTap: () async {
      Navigator.pop(sheetContext);
      final added = await service.toggle(
        source: source,
        sourceId: sourceId,
        sourceName: sourceName,
        messageId: messageId,
        senderName: senderName,
        text: text,
        timestamp: timestamp,
        isOutgoing: isOutgoing,
      );
      if (!screenContext.mounted) return;
      showDismissibleSnackBar(
        screenContext,
        content: Text(added ? l10n.bookmarks_added : l10n.bookmarks_removed),
        duration: const Duration(seconds: 2),
      );
    },
  );
}
