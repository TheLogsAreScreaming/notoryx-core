import 'dart:collection';

/// Remembers which received messages have already raised a notification, so
/// one message that reaches the app twice alerts once.
///
/// The same message can arrive again when the sender retries after a lost
/// ACK, when the radio's queue is read again after a reconnect, or when a
/// channel post is heard through two repeaters. A message is identified by
/// who sent it, where, the sender's own timestamp and its text, so the same
/// words sent again later still alert. The chat itself is not affected.
class NotificationDeduper {
  /// Creates a deduper that remembers up to [capacity] messages for
  /// [window]. [clock] is for tests.
  NotificationDeduper({
    this.window = const Duration(hours: 1),
    this.capacity = 512,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  /// How long a message is remembered after its first notification.
  final Duration window;

  /// The most messages remembered at once; the oldest is dropped first.
  final int capacity;

  final DateTime Function() _clock;

  // Insertion order is first-seen order, so the oldest entry is first.
  final LinkedHashMap<String, DateTime> _seen = LinkedHashMap();

  /// Whether [key] has not raised a notification within [window]. Records
  /// it, so the next call with the same key returns false.
  bool firstSighting(String key) {
    final now = _clock();
    while (_seen.isNotEmpty && now.difference(_seen.values.first) > window) {
      _seen.remove(_seen.keys.first);
    }
    if (_seen.containsKey(key)) return false;
    _seen[key] = now;
    if (_seen.length > capacity) _seen.remove(_seen.keys.first);
    return true;
  }

  /// Forgets every message, for example when notifications are reset.
  void clear() => _seen.clear();

  /// The key for a direct or room message from [senderKeyHex] on [radio].
  static String directKey({
    required String radio,
    required String senderKeyHex,
    required DateTime sentAt,
    required String text,
  }) => 'dm|$radio|$senderKeyHex|${sentAt.millisecondsSinceEpoch}|$text';

  /// The key for a post by [senderName] in channel [channelIndex] on
  /// [radio].
  static String channelKey({
    required String radio,
    required int channelIndex,
    required String senderName,
    required DateTime sentAt,
    required String text,
  }) =>
      'ch|$radio|$channelIndex|$senderName|'
      '${sentAt.millisecondsSinceEpoch}|$text';
}
