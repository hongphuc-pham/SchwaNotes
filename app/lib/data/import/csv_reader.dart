import 'dart:convert';
import 'dart:typed_data';

/// A small, tolerant CSV reader (RFC 4180, read liberally).
///
/// Written here rather than taken from pub: what is needed is about this
/// long, and the parts a package would not do are the parts that matter -
/// Excel's byte-order mark, its semicolon files, refusing UTF-16 instead of
/// returning garbage, and never turning `007` into a number.
abstract final class CsvReader {
  static const List<String> _delimiters = <String>[',', ';', '\t'];

  /// Decodes [bytes] as UTF-8 and splits them into rows of fields.
  ///
  /// Accepts CR, LF or CRLF line ends, quoted fields with `""` escapes and
  /// embedded line breaks, and a comma, semicolon or tab delimiter (whichever
  /// the first line uses most, outside quotes). Blank lines are dropped.
  ///
  /// Throws [FormatException] for anything that is not UTF-8 text.
  static List<List<String>> read(Uint8List bytes) {
    var start = 0;
    if (bytes.length >= 3 &&
        bytes[0] == 0xEF &&
        bytes[1] == 0xBB &&
        bytes[2] == 0xBF) {
      start = 3;
    } else if (bytes.length >= 2 &&
        ((bytes[0] == 0xFF && bytes[1] == 0xFE) ||
            (bytes[0] == 0xFE && bytes[1] == 0xFF))) {
      throw const FormatException('UTF-16 text');
    }
    final text = utf8.decode(Uint8List.sublistView(bytes, start));
    // UTF-16 without a byte-order mark decodes as UTF-8, full of NULs.
    if (text.contains('\u0000')) throw const FormatException('binary data');
    return _split(text, _sniff(text));
  }

  /// The delimiter the first non-blank line uses most, outside quotes.
  static String _sniff(String text) {
    final counts = <String, int>{for (final d in _delimiters) d: 0};
    var quoted = false;
    var seenText = false;
    for (var i = 0; i < text.length; i++) {
      final char = text[i];
      if (char == '"') {
        quoted = !quoted;
      } else if (!quoted && (char == '\n' || char == '\r')) {
        if (seenText) break;
      } else if (!quoted && counts.containsKey(char)) {
        counts[char] = counts[char]! + 1;
        seenText = true;
      } else if (char.trim().isNotEmpty) {
        seenText = true;
      }
    }
    var best = ',';
    for (final d in _delimiters) {
      if (counts[d]! > counts[best]!) best = d;
    }
    return best;
  }

  static List<List<String>> _split(String text, String delimiter) {
    final rows = <List<String>>[];
    var row = <String>[];
    final field = StringBuffer();
    var quoted = false;

    void endField() {
      row.add(field.toString());
      field.clear();
    }

    void endRow() {
      endField();
      if (row.any((cell) => cell.trim().isNotEmpty) || row.length > 1) {
        rows.add(row);
      }
      row = <String>[];
    }

    for (var i = 0; i < text.length; i++) {
      final char = text[i];
      if (quoted) {
        if (char == '"') {
          if (i + 1 < text.length && text[i + 1] == '"') {
            field.write('"');
            i++;
          } else {
            quoted = false;
          }
        } else {
          field.write(char);
        }
      } else if (char == '"') {
        quoted = true;
      } else if (char == delimiter) {
        endField();
      } else if (char == '\r' || char == '\n') {
        if (char == '\r' && i + 1 < text.length && text[i + 1] == '\n') i++;
        endRow();
      } else {
        field.write(char);
      }
    }
    if (field.isNotEmpty || row.isNotEmpty) endRow();
    return rows;
  }
}
