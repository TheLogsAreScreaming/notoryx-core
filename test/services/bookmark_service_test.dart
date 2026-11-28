import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/services/bookmark_service.dart';
import 'package:meshcore_open/storage/prefs_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PrefsManager.reset();
    await PrefsManager.initialize();
  });

  Future<bool> save(
    BookmarkService s, {
    BookmarkSource source = BookmarkSource.channel,
    String sourceId = 'chan',
    String id = 'm1',
    String text = 'Meet at the north gate',
    int minute = 0,
  }) => s.toggle(
    source: source,
    sourceId: sourceId,
    sourceName: source == BookmarkSource.channel ? 'Public' : 'Ann',
    messageId: id,
    senderName: 'Ann',
    text: text,
    timestamp: DateTime(2026, 11, 27, 9, minute),
    isOutgoing: false,
  );

  test('toggle saves, survives a reload, and toggles off', () async {
    final s = BookmarkService();
    expect(await save(s), isTrue);
    expect(s.isBookmarked(BookmarkSource.channel, 'chan', 'm1'), isTrue);

    final reloaded = BookmarkService()..load();
    expect(reloaded.bookmarks.single.text, 'Meet at the north gate');

    expect(await save(reloaded), isFalse);
    expect(BookmarkService()..load(), isA<BookmarkService>());
    expect((BookmarkService()..load()).bookmarks, isEmpty);
  });

  test('the same message id in two chats is two bookmarks', () async {
    final s = BookmarkService();
    await save(s);
    await save(s, source: BookmarkSource.contact, sourceId: 'abcd');
    expect(s.bookmarks, hasLength(2));
  });

  test('newest message first, and Markdown groups by chat', () async {
    final s = BookmarkService();
    await save(s, id: 'a', text: 'first', minute: 1);
    await save(s, id: 'b', text: 'second', minute: 2);
    await save(
      s,
      source: BookmarkSource.contact,
      sourceId: 'k',
      id: 'c',
      text: 'direct one',
      minute: 3,
    );
    expect(s.bookmarks.map((b) => b.text), ['direct one', 'second', 'first']);
    final md = BookmarkService.toMarkdown(s.bookmarks, now: DateTime(2026));
    expect(md, contains('## Direct'));
    expect(md, contains('## Channels'));
    expect(md.indexOf('first'), lessThan(md.indexOf('second')));
  });

  test('a bad stored record is skipped, the rest load', () async {
    await PrefsManager.instance.setString(
      BookmarkService.prefsKey,
      jsonEncode([
        {'source': 'nope'},
        {
          'source': 'channel',
          'sourceId': 'c',
          'messageId': 'x',
          'text': 'kept',
          'timestamp': 0,
        },
      ]),
    );
    final s = BookmarkService()..load();
    expect(s.bookmarks.single.text, 'kept');
  });
}
