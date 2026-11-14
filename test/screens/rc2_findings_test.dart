import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/screens/bastion_home_screen.dart';
import 'package:meshcore_open/screens/map_list_screen.dart';

void main() {
  group('joinHomeHints', () {
    test('shows a shared reason once', () {
      expect(
        joinHomeHints('Connect your radio first.', 'Connect your radio first.'),
        'Connect your radio first.',
      );
    });

    test('keeps two different hints', () {
      expect(
        joinHomeHints('Tap to check in.', 'Hold 2 seconds.'),
        'Tap to check in. Hold 2 seconds.',
      );
    });
  });

  group('midSentence', () {
    test('lowercases a sentence-start label', () {
      expect(midSentence('Just now'), 'just now');
    });

    test('leaves other labels alone', () {
      expect(midSentence('5m ago'), '5m ago');
      expect(midSentence('刚刚'), '刚刚');
      expect(midSentence(''), '');
    });
  });
}
