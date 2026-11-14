/// How a channel alerts you about new messages.
enum ChannelNotifyMode {
  /// Every message notifies.
  all,

  /// Only messages that mention this radio's name notify. Others still
  /// arrive and count as unread.
  mentionsOnly,

  /// Nothing from the channel notifies.
  muted,
}

/// Whether [text] mentions [selfName] using the `@[name]` form that
/// MeshCore apps insert. Matching ignores case and surrounding spaces.
bool mentionsName(String text, String? selfName) {
  final name = selfName?.trim().toLowerCase();
  if (name == null || name.isEmpty) return false;
  final pattern = RegExp(r'@\[([^\]]+)\]');
  for (final match in pattern.allMatches(text)) {
    if (match.group(1)!.trim().toLowerCase() == name) return true;
  }
  return false;
}

/// Whether a received channel message should raise a notification in
/// [mode]. An unknown own name never hides a mention-only message's alert
/// silently: it is treated as not mentioned.
bool shouldNotifyForChannelMode(
  ChannelNotifyMode mode, {
  required String text,
  required String? selfName,
}) {
  switch (mode) {
    case ChannelNotifyMode.all:
      return true;
    case ChannelNotifyMode.muted:
      return false;
    case ChannelNotifyMode.mentionsOnly:
      return mentionsName(text, selfName);
  }
}
