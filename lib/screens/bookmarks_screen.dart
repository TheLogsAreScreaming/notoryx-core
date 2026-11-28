import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/l10n.dart';
import '../services/bookmark_service.dart';
import '../widgets/adaptive_app_bar_title.dart';
import '../widgets/empty_state.dart';

/// Every bookmarked message, newest first, from direct chats and channels.
/// Swipe one away to remove it; Share sends them all as Markdown.
class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  BookmarkSource? _only;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final service = context.watch<BookmarkService>();
    final all = service.bookmarks;
    final shown = [
      for (final b in all)
        if (_only == null || b.source == _only) b,
    ];
    return Scaffold(
      appBar: AppBar(
        title: AdaptiveAppBarTitle(l10n.bookmarks_title),
        actions: [
          IconButton(
            key: const ValueKey('bookmarks-share'),
            tooltip: l10n.bookmarks_share,
            icon: const Icon(Icons.ios_share),
            onPressed: shown.isEmpty
                ? null
                : () => SharePlus.instance.share(
                    ShareParams(
                      text: BookmarkService.toMarkdown(shown),
                      subject: l10n.bookmarks_title,
                    ),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: Wrap(
                spacing: 8,
                children: [
                  for (final (value, label) in [
                    (null, l10n.bookmarks_filterAll),
                    (BookmarkSource.contact, l10n.bookmarks_filterDirect),
                    (BookmarkSource.channel, l10n.bookmarks_filterChannels),
                  ])
                    ChoiceChip(
                      label: Text(label),
                      selected: _only == value,
                      onSelected: (_) => setState(() => _only = value),
                    ),
                ],
              ),
            ),
            Expanded(
              child: shown.isEmpty
                  ? EmptyState(
                      icon: Icons.bookmark_border,
                      title: l10n.bookmarks_empty,
                      subtitle: l10n.bookmarks_emptyHint,
                    )
                  : ListView.separated(
                      itemCount: shown.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final b = shown[i];
                        return Dismissible(
                          key: ValueKey(b.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: AlignmentDirectional.centerEnd,
                            padding: const EdgeInsetsDirectional.only(end: 20),
                            color: Theme.of(context).colorScheme.errorContainer,
                            child: const Icon(Icons.bookmark_remove),
                          ),
                          onDismissed: (_) => service.remove(b),
                          child: ListTile(
                            leading: Icon(
                              b.source == BookmarkSource.contact
                                  ? Icons.person_outline
                                  : Icons.tag,
                            ),
                            title: Text(b.text),
                            subtitle: Text(
                              '${b.sourceName} · ${b.senderName} · '
                              '${MaterialLocalizations.of(context).formatShortDate(b.timestamp)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: IconButton(
                              tooltip: l10n.bookmarks_remove,
                              icon: const Icon(Icons.bookmark_remove_outlined),
                              onPressed: () => service.remove(b),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
