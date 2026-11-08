import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// An icon-only button with no tooltip is announced as just "button".
void main() {
  test('every IconButton in lib has a tooltip', () {
    final missing = <String>[];
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart') && !f.path.contains('l10n'));
    final start = RegExp(r'(?<![\w.])IconButton(\.\w+)?\(');
    for (final file in files) {
      final s = file.readAsStringSync();
      for (final m in start.allMatches(s)) {
        if (m.group(1) == '.styleFrom') continue;
        var depth = 1, i = m.end;
        while (depth > 0 && i < s.length) {
          final c = s[i++];
          if ('([{'.contains(c)) depth++;
          if (')]}'.contains(c)) depth--;
        }
        if (!s.substring(m.end, i).contains('tooltip:')) {
          final line = '\n'.allMatches(s.substring(0, m.start)).length + 1;
          missing.add('${file.path}:$line');
        }
      }
    }
    expect(missing, isEmpty);
  });
}
