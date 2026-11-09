import 'dart:convert';

/// One line of a report form. Labels stay in English on purpose: these are
/// standard forms, and whoever receives one reads the same wording.
class ReportField {
  const ReportField(this.code, this.label, this.hint);

  /// Short tag sent over the air, to fit the radio's message size.
  final String code;
  final String label;
  final String hint;
}

/// The report forms the app can send.
enum FieldReportKind {
  salute('SALUTE', [
    ReportField('S', 'Size', 'How many'),
    ReportField('A', 'Activity', 'What they are doing'),
    ReportField('L', 'Location', 'Where'),
    ReportField('U', 'Unit', 'Who, markings, clothing'),
    ReportField('T', 'Time', 'When seen'),
    ReportField('E', 'Equipment', 'What they have'),
  ]),
  nineLine('9LINE', [
    ReportField('1', 'Line 1: Location', 'Pickup site location'),
    ReportField('2', 'Line 2: Radio', 'Frequency and call sign'),
    ReportField('3', 'Line 3: Patients by precedence', 'e.g. 1 urgent'),
    ReportField('4', 'Line 4: Special equipment', 'e.g. none, hoist'),
    ReportField('5', 'Line 5: Patients by type', 'e.g. 1 litter, 2 walking'),
    ReportField('6', 'Line 6: Site security', 'e.g. no danger'),
    ReportField('7', 'Line 7: Site marking', 'e.g. smoke, panels'),
    ReportField('8', 'Line 8: Patient status', 'e.g. civilian'),
    ReportField('9', 'Line 9: Terrain and obstacles', 'e.g. flat, wires'),
  ]);

  const FieldReportKind(this.tag, this.fields);

  /// The first word of the report on the air.
  final String tag;
  final List<ReportField> fields;

  /// The field that takes the sender's position.
  String get locationCode => this == salute ? 'L' : '1';

  /// The field that takes the current time, if the form has one.
  String? get timeCode => this == salute ? 'T' : null;
}

/// [values] (by field code) as messages of at most [maxBytes] each. Blank
/// fields are left out and fields are kept whole where they fit.
List<String> encodeFieldReport(
  FieldReportKind kind,
  Map<String, String> values,
  int maxBytes,
) {
  // Room for " (9/9)" on every part.
  final limit = maxBytes - 6;
  int size(String s) => utf8.encode(s).length;
  final parts = <String>[];
  var current = kind.tag;
  for (final field in kind.fields) {
    final value = (values[field.code] ?? '').trim();
    if (value.isEmpty) continue;
    var piece = '${field.code}:$value';
    while (piece.isNotEmpty) {
      if (size('$current $piece') <= limit) {
        current = '$current $piece';
        piece = '';
        continue;
      }
      if (size(piece) + size(kind.tag) + 1 <= limit && current != kind.tag) {
        parts.add(current);
        current = kind.tag;
        continue;
      }
      // Too long for a message of its own: take what fits.
      final room = limit - size(current) - 1;
      final head = _takeBytes(piece, room);
      if (head.isEmpty) {
        parts.add(current);
        current = kind.tag;
        continue;
      }
      parts.add('$current $head');
      current = kind.tag;
      piece = piece.substring(head.length);
    }
  }
  if (current != kind.tag) parts.add(current);
  if (parts.length < 2) return parts;
  return [
    for (var i = 0; i < parts.length; i++)
      '${parts[i]} (${i + 1}/${parts.length})',
  ];
}

/// The longest start of [text] within [bytes], not cutting a character.
String _takeBytes(String text, int bytes) {
  if (bytes <= 0) return '';
  var used = 0;
  final out = StringBuffer();
  for (final rune in text.runes) {
    final char = String.fromCharCode(rune);
    used += utf8.encode(char).length;
    if (used > bytes) break;
    out.write(char);
  }
  return out.toString();
}
