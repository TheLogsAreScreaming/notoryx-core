import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../storage/prefs_manager.dart';

/// Where a bookmarked message came from.
enum BookmarkSource { contact, channel }

/// A saved copy of one message. It keeps its own text, so a bookmark
/// outlives the chat it came from (a deleted contact, a cleared channel or
/// auto-delete).
@immutable
class Bookmark {
  final BookmarkSource source;

  /// Contact public key (hex) or channel key (hex).
  final String sourceId;
  final String sourceName;
  final String messageId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final bool isOutgoing;
  final DateTime savedAt;

  const Bookmark({
    required this.source,
    required this.sourceId,
    required this.sourceName,
    required this.messageId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    required this.isOutgoing,
    required this.savedAt,
  });

  /// One bookmark per message per chat.
  String get id => idFor(source, sourceId, messageId);

  static String idFor(BookmarkSource source, String sourceId, String id) =>
      '${source.name}:$sourceId:$id';

  Map<String, Object?> toJson() => {
    'source': source.name,
    'sourceId': sourceId,
    'sourceName': sourceName,
    'messageId': messageId,
    'senderName': senderName,
    'text': text,
    'timestamp': timestamp.millisecondsSinceEpoch,
    'isOutgoing': isOutgoing,
    'savedAt': savedAt.millisecondsSinceEpoch,
  };

  /// Null for a record that can't be read, so one bad entry never loses the
  /// rest.
  static Bookmark? fromJson(Object? json) {
    if (json is! Map) return null;
    final source = BookmarkSource.values
        .where((s) => s.name == json['source'])
        .firstOrNull;
    final sourceId = json['sourceId'];
    final messageId = json['messageId'];
    final text = json['text'];
    final timestamp = json['timestamp'];
    if (source == null ||
        sourceId is! String ||
        messageId is! String ||
        text is! String ||
        timestamp is! int) {
      return null;
    }
    final savedAt = json['savedAt'];
    return Bookmark(
      source: source,
      sourceId: sourceId,
      sourceName: json['sourceName'] as String? ?? '',
      messageId: messageId,
      senderName: json['senderName'] as String? ?? '',
      text: text,
      timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp),
      isOutgoing: json['isOutgoing'] as bool? ?? false,
      savedAt: DateTime.fromMillisecondsSinceEpoch(
        savedAt is int ? savedAt : timestamp,
      ),
    );
  }
}

/// Saved ("bookmarked") messages from any chat, on this phone only.
///
/// Stored in app preferences, so encrypted backups include them.
class BookmarkService extends ChangeNotifier {
  BookmarkService({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  static const prefsKey = 'message_bookmarks_v1';

  /// Oldest bookmarks are dropped past this, so the list stays fast.
  static const maxBookmarks = 1000;

  final DateTime Function() _clock;
  final Map<String, Bookmark> _byId = {};

  /// All bookmarks, newest message first.
  List<Bookmark> get bookmarks =>
      _byId.values.toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  bool isBookmarked(BookmarkSource source, String sourceId, String messageId) =>
      _byId.containsKey(Bookmark.idFor(source, sourceId, messageId));

  void load() {
    _byId.clear();
    final raw = PrefsManager.instance.getString(prefsKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          for (final item in decoded) {
            final bookmark = Bookmark.fromJson(item);
            if (bookmark != null) _byId[bookmark.id] = bookmark;
          }
        }
      } on FormatException catch (e) {
        debugPrint('BookmarkService: unreadable bookmarks: $e');
      }
    }
    notifyListeners();
  }

  /// Saves a bookmark, or removes it when the message is already saved.
  /// Returns whether the message is bookmarked afterwards.
  Future<bool> toggle({
    required BookmarkSource source,
    required String sourceId,
    required String sourceName,
    required String messageId,
    required String senderName,
    required String text,
    required DateTime timestamp,
    required bool isOutgoing,
  }) async {
    final id = Bookmark.idFor(source, sourceId, messageId);
    final added = _byId.remove(id) == null;
    if (added) {
      _byId[id] = Bookmark(
        source: source,
        sourceId: sourceId,
        sourceName: sourceName,
        messageId: messageId,
        senderName: senderName,
        text: text,
        timestamp: timestamp,
        isOutgoing: isOutgoing,
        savedAt: _clock(),
      );
      _trim();
    }
    notifyListeners();
    await _save();
    return added;
  }

  Future<void> remove(Bookmark bookmark) async {
    if (_byId.remove(bookmark.id) == null) return;
    notifyListeners();
    await _save();
  }

  void _trim() {
    if (_byId.length <= maxBookmarks) return;
    final oldestFirst = _byId.values.toList()
      ..sort((a, b) => a.savedAt.compareTo(b.savedAt));
    for (final b in oldestFirst.take(_byId.length - maxBookmarks)) {
      _byId.remove(b.id);
    }
  }

  Future<void> _save() async {
    try {
      await PrefsManager.instance.setString(
        prefsKey,
        jsonEncode([for (final b in _byId.values) b.toJson()]),
      );
    } catch (e) {
      debugPrint('BookmarkService: save failed: $e');
    }
  }

  /// The bookmarks as Markdown, grouped by chat, for sharing or keeping.
  static String toMarkdown(List<Bookmark> bookmarks, {DateTime? now}) {
    final out = StringBuffer()
      ..writeln('# Bookmarked messages')
      ..writeln()
      ..writeln('Exported ${_stamp(now ?? DateTime.now())}');
    for (final source in BookmarkSource.values) {
      final groups = <String, List<Bookmark>>{};
      for (final b in bookmarks.where((b) => b.source == source)) {
        groups.putIfAbsent(b.sourceId, () => []).add(b);
      }
      if (groups.isEmpty) continue;
      out
        ..writeln()
        ..writeln(
          source == BookmarkSource.contact ? '## Direct' : '## Channels',
        );
      for (final group in groups.values) {
        group.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        out
          ..writeln()
          ..writeln('### ${_line(group.first.sourceName)}')
          ..writeln();
        for (final b in group) {
          out.writeln(
            '- ${_stamp(b.timestamp)} **${_line(b.senderName)}**: '
            '${_line(b.text)}',
          );
        }
      }
    }
    return out.toString();
  }

  static String _line(String s) => s.replaceAll(RegExp(r'\s+'), ' ').trim();

  static String _stamp(DateTime t) {
    final l = t.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${l.year}-${two(l.month)}-${two(l.day)} ${two(l.hour)}:${two(l.minute)}';
  }
}
