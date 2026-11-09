import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/models/field_report.dart';

void main() {
  test('a short report is one message with blanks left out', () {
    expect(
      encodeFieldReport(FieldReportKind.salute, {
        'S': '3',
        'A': ' moving north ',
        'U': '',
      }, 150),
      ['SALUTE S:3 A:moving north'],
    );
  });

  test('an empty form sends nothing', () {
    expect(encodeFieldReport(FieldReportKind.nineLine, {'1': '  '}, 150), []);
  });

  test('a long report splits on fields, numbered, within the limit', () {
    final values = {for (var i = 1; i <= 9; i++) '$i': 'x' * 40};
    final parts = encodeFieldReport(FieldReportKind.nineLine, values, 120);
    expect(parts.length, greaterThan(1));
    expect(parts.first, endsWith('(1/${parts.length})'));
    for (final part in parts) {
      expect(utf8.encode(part).length, lessThanOrEqualTo(120));
      expect(part, startsWith('9LINE '));
    }
    expect(parts.join(), contains('9:${'x' * 40}'));
  });

  test('one huge field is cut without losing or splitting characters', () {
    final text = 'é' * 200;
    final parts = encodeFieldReport(FieldReportKind.salute, {'A': text}, 100);
    for (final part in parts) {
      expect(utf8.encode(part).length, lessThanOrEqualTo(100));
      expect(part, isNot(contains('�')));
    }
    final joined = parts.join();
    expect('é'.allMatches(joined).length, 200);
  });
}
