import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../connector/meshcore_connector.dart';
import '../connector/meshcore_protocol.dart';
import '../l10n/l10n.dart';
import '../models/channel_message.dart';
import '../screens/channel_chat_screen.dart';
import '../screens/chat_screen.dart';
import '../storage/draft_store.dart';
import 'mesh_ui.dart';

/// Picks a conversation for [text] and opens it with the text in the message
/// box, so it can be checked before it goes out over the air.
Future<void> showForwardSheet(BuildContext context, String text) {
  final body = ChannelMessage.parseReplyMention(text)?.actualMessage ?? text;
  final navigator = Navigator.of(context);
  final radio = context.read<MeshCoreConnector>();

  Future<void> open(String key, Widget screen) async {
    final existing = DraftStore.load(key);
    await DraftStore.save(key, existing == null ? body : '$existing\n$body');
    navigator.pop();
    await navigator.push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  final self = radio.selfPublicKeyHex;
  final contacts = radio.contacts.where((c) => c.type == advTypeChat).toList()
    ..sort((a, b) => a.name.compareTo(b.name));
  return showMeshSheet<void>(
    context,
    builder: (sheet) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BottomSheetHeader(title: sheet.l10n.forward_title),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final channel in radio.channels)
                  if (channel.name.isNotEmpty)
                    ListTile(
                      leading: const Icon(Icons.tag),
                      title: Text(channel.name),
                      onTap: () => open(
                        DraftStore.channelKey(self, channel.index),
                        ChannelChatScreen(channel: channel),
                      ),
                    ),
                for (final contact in contacts)
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: Text(contact.name),
                    onTap: () => open(
                      DraftStore.contactKey(self, contact.publicKeyHex),
                      ChatScreen(contact: contact),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
