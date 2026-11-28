import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';

import '../connector/meshcore_connector.dart';
import '../l10n/l10n.dart';
import '../models/contact.dart';
import '../models/message.dart';
import '../theme/mesh_theme.dart';
import '../utils/disconnect_navigation_mixin.dart';
import '../utils/emoji_utils.dart';
import '../utils/main_tab_navigation.dart';
import '../widgets/app_bar.dart';
import '../widgets/ember_backdrop.dart';
import '../widgets/glass_node_card.dart';
import '../widgets/node_avatar.dart';
import '../widgets/quick_switch_bar.dart';
import '../widgets/sync_progress_overlay.dart';
import 'channels_screen.dart';
import 'chat_screen.dart';

class ConversationsTabScreen extends StatefulWidget {
  final bool hideBackButton;

  const ConversationsTabScreen({super.key, this.hideBackButton = false});

  @override
  State<ConversationsTabScreen> createState() => _ConversationsTabScreenState();
}

class _ConversationsTabScreenState extends State<ConversationsTabScreen>
    with DisconnectNavigationMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _searchOpen = false;
  String _searchText = '';

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MeshCoreConnector>(
      builder: (context, connector, _) {
        if (!checkConnectionAndNavigate(connector)) {
          return const SizedBox.shrink();
        }

        final contacts = List<Contact>.from(connector.contacts)
          ..sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));

        final filtered = _searchText.isEmpty
            ? contacts
            : contacts.where((c) {
                return c.name.toLowerCase().contains(_searchText.toLowerCase());
              }).toList();

        final firstUnreadIndex = filtered.indexWhere(
          (c) => connector.getUnreadCountForContact(c) > 0,
        );

        final totalChannelUnread = connector.channels.fold<int>(
          0,
          (sum, ch) => sum + connector.getUnreadCountForChannel(ch),
        );

        final isTab = widget.hideBackButton;
        final l10n = context.l10n;

        return PopScope(
          canPop: !isTab || !connector.isConnected,
          child: EmberBackdrop(
            scene: EmberScene.chats,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                scrolledUnderElevation: 0,
                title: _searchOpen
                    ? TextField(
                        controller: _searchController,
                        autofocus: true,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          hintText: l10n.messages_searchHint,
                          border: InputBorder.none,
                        ),
                        onChanged: (v) => setState(() => _searchText = v),
                      )
                    : AppBarTitle(l10n.nav_chats),
                centerTitle: true,
                automaticallyImplyLeading: !isTab,
                bottom: const SyncProgressAppBarBottom(),
                actions: [
                  if (_searchOpen)
                    IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: l10n.messages_closeSearch,
                      onPressed: () => setState(() {
                        _searchOpen = false;
                        _searchController.clear();
                        _searchText = '';
                      }),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.search),
                      tooltip: l10n.messages_search,
                      onPressed: () => setState(() => _searchOpen = true),
                    ),
                ],
              ),
              body: Column(
                children: [
                  Expanded(
                    child: filtered.isEmpty && _searchText.isNotEmpty
                        ? _EmptySearch(message: l10n.messages_noMatches)
                        : filtered.isEmpty
                        ? _EmptyState(
                            message: l10n.messages_empty,
                            hint: l10n.messages_emptyHint,
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.only(bottom: 88),
                            itemCount: filtered.length + 1,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return _ChannelsEntry(
                                  unreadCount: totalChannelUnread,
                                );
                              }
                              final contact = filtered[index - 1];
                              final unread = connector.getUnreadCountForContact(
                                contact,
                              );
                              final messages = connector.getMessages(contact);
                              final lastMsg = messages.isNotEmpty
                                  ? messages.last
                                  : null;
                              return _ConversationTile(
                                contact: contact,
                                unreadCount: unread,
                                lastMessage: lastMsg,
                                onTap: () =>
                                    _openChat(context, connector, contact),
                              );
                            },
                          ),
                  ),
                  if (isTab) QuickSwitchBar(current: MainTab.chats),
                ],
              ),
              floatingActionButton: firstUnreadIndex >= 0
                  ? FloatingActionButton.small(
                      tooltip: l10n.chats_jumpToUnread,
                      onPressed: () => _scrollToFirstUnread(firstUnreadIndex),
                      child: const Icon(Icons.mark_chat_unread_outlined),
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }

  void _scrollToFirstUnread(int contactIndex) {
    // +1 for the channels entry at index 0; each tile is ~72px tall
    const tileHeight = 72.0;
    final offset = (contactIndex + 1) * tileHeight;
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _openChat(
    BuildContext context,
    MeshCoreConnector connector,
    Contact contact,
  ) {
    final unread = connector.getUnreadCountForContactKey(contact.publicKeyHex);
    connector.markContactRead(contact.publicKeyHex);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ChatScreen(contact: contact, initialUnreadCount: unread),
      ),
    );
  }
}

class _ChannelsEntry extends StatelessWidget {
  final int unreadCount;

  const _ChannelsEntry({required this.unreadCount});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: GlassNodeCard(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChannelsScreen()),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 16, 14),
            child: Row(
              children: [
                Icon(
                  Icons.forum_outlined,
                  size: 22,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.messages_filterChannels,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                if (unreadCount > 0) ...[
                  const SizedBox(width: 8),
                  Semantics(
                    label: l10n.messages_unreadCount(unreadCount),
                    child: Badge(label: Text('$unreadCount')),
                  ),
                  const SizedBox(width: 8),
                ],
                Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Contact contact;
  final int unreadCount;
  final Message? lastMessage;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.contact,
    required this.unreadCount,
    this.lastMessage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final hasUnread = unreadCount > 0;

    final timeLabel = lastMessage != null
        ? _formatTime(context, lastMessage!.timestamp)
        : '';

    final String previewText;
    if (lastMessage == null) {
      previewText = '';
    } else if (lastMessage!.isOutgoing) {
      previewText = l10n.messages_you(lastMessage!.text);
    } else {
      previewText = lastMessage!.text;
    }

    final emoji = firstEmoji(contact.name);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: GlassNodeCard(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 12, 10),
            child: Row(
              children: [
                SizedBox(
                  width: 42,
                  height: 42,
                  child: NodeAvatar(
                    nodeKey: contact.publicKeyHex,
                    name: contact.name,
                    size: 42,
                    icon: Icons.person_outline_rounded,
                    fallback: emoji != null
                        ? Text(emoji, style: const TextStyle(fontSize: 20))
                        : Icon(
                            Icons.person_outline_rounded,
                            size: 22,
                            color: MeshPalette.ink3,
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        contact.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: hasUnread
                              ? FontWeight.w700
                              : FontWeight.w500,
                          fontSize: 15,
                          color: scheme.onSurface,
                        ),
                      ),
                      if (previewText.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          previewText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: hasUnread
                                ? scheme.onSurface
                                : MeshPalette.ink3,
                            fontWeight: hasUnread
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (timeLabel.isNotEmpty)
                      Text(
                        timeLabel,
                        style: TextStyle(fontSize: 12, color: MeshPalette.ink3),
                      ),
                    if (hasUnread) ...[
                      const SizedBox(height: 4),
                      Semantics(
                        label: l10n.messages_unreadCount(unreadCount),
                        child: Badge(label: Text('$unreadCount')),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(BuildContext context, DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDay = DateTime(time.year, time.month, time.day);
    final diffDays = today.difference(msgDay).inDays;
    final locale = Localizations.localeOf(context).toString();

    if (diffDays == 0) {
      return DateFormat.Hm(locale).format(time);
    }
    if (diffDays == 1) {
      return context.l10n.messages_yesterday;
    }
    return DateFormat.Md(locale).format(time);
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  final String hint;

  const _EmptyState({required this.message, required this.hint});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              hint,
              style: TextStyle(fontSize: 14, color: scheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  final String message;

  const _EmptySearch({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: TextStyle(
          fontSize: 15,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
