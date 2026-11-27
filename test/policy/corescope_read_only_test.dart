import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The missed chat feed only reads from CoreScope. Nothing the radio hears
/// may reach it: no radio packet streams, no uploads, no writes.
void main() {
  test('the CoreScope feed never sends radio data', () {
    final src = File(
      'lib/services/corescope_chat_feed.dart',
    ).readAsStringSync();
    for (final banned in [
      'rxPackets',
      'publish',
      '.post(',
      '.put(',
      '.patch(',
      '.delete(',
      '.send(',
      'meshcore_connector',
      'mqtt',
    ]) {
      expect(src.contains(banned), isFalse, reason: 'found "$banned"');
    }
  });
}
