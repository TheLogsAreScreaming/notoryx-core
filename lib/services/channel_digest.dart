/// Groups notifications from busy channels into one summary.
///
/// A channel is busy once it has alerted [busyAfter] times within [window].
/// From then on its messages are held, and one summary per channel ("12 new
/// messages") goes out [every]. A message that mentions you, an SOS or
/// check-in, or anything naming an emergency is never held. Direct messages
/// don't go through here at all.
class ChannelDigest {
  ChannelDigest({
    this.busyAfter = 5,
    this.window = const Duration(minutes: 10),
    this.every = const Duration(minutes: 15),
  });

  final int busyAfter;
  final Duration window;
  final Duration every;

  final Map<String, List<DateTime>> _alerts = {};
  final Map<String, _Held> _held = {};

  /// Whether a message on [channel] at [now] should alert right away.
  /// False means it was held for the next summary. [urgent] messages always
  /// alert and don't count towards "busy".
  bool offer(String channel, DateTime now, {bool urgent = false}) {
    if (urgent) return true;
    final recent = (_alerts[channel] ??= [])
      ..removeWhere((t) => now.difference(t) >= window);
    if (recent.length < busyAfter && !_held.containsKey(channel)) {
      recent.add(now);
      return true;
    }
    final held = _held[channel] ??= _Held(now);
    held.count++;
    return false;
  }

  /// Summaries that are due at [now]: channel → held message count. Each
  /// is reported once; a channel that went quiet stops being busy.
  Map<String, int> takeDue(DateTime now) {
    final due = <String, int>{};
    _held.removeWhere((channel, held) {
      if (now.difference(held.since) < every) return false;
      due[channel] = held.count;
      _alerts.remove(channel);
      return true;
    });
    return due;
  }

  /// When the next summary is due, or null when nothing is held.
  DateTime? get nextDue {
    DateTime? next;
    for (final h in _held.values) {
      final at = h.since.add(every);
      if (next == null || at.isBefore(next)) next = at;
    }
    return next;
  }
}

class _Held {
  _Held(this.since);
  final DateTime since;
  int count = 0;
}
