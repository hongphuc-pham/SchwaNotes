import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/data/import/csv_reader.dart';
import 'package:vocabnote/data/import/word_csv_parser.dart';
import 'package:vocabnote/domain/entities/word_import.dart';

/// The CSV deck reader (F-010): liberal in what it accepts, because the files
/// come from Excel, Google Sheets, Anki and hand-typed notes.
void main() {
  Uint8List utf8Bytes(String text) => Uint8List.fromList(utf8.encode(text));

  group('CsvReader', () {
    List<List<String>> read(String text) => CsvReader.read(utf8Bytes(text));

    test('splits plain comma rows', () {
      expect(read('a,b,c\nd,e,f'), <List<String>>[
        <String>['a', 'b', 'c'],
        <String>['d', 'e', 'f'],
      ]);
    });

    test('accepts CRLF, LF and a lone CR alike', () {
      expect(read('a,b\r\nc,d\re,f\n'), <List<String>>[
        <String>['a', 'b'],
        <String>['c', 'd'],
        <String>['e', 'f'],
      ]);
    });

    test('quoted fields keep commas, newlines and doubled quotes', () {
      expect(read('"one, two","say ""hi""","line\nbreak"'), <List<String>>[
        <String>['one, two', 'say "hi"', 'line\nbreak'],
      ]);
    });

    test('strips the byte-order mark Excel writes', () {
      final bytes = Uint8List.fromList(<int>[
        0xEF,
        0xBB,
        0xBF,
        ...utf8.encode('cough,kɒf'),
      ]);
      expect(CsvReader.read(bytes), <List<String>>[
        <String>['cough', 'kɒf'],
      ]);
    });

    test('detects a semicolon file, as Excel writes in many locales', () {
      expect(read('cough;kɒf;ho, khạc\nthrough;θruː;qua'), <List<String>>[
        <String>['cough', 'kɒf', 'ho, khạc'],
        <String>['through', 'θruː', 'qua'],
      ]);
    });

    test('detects a tab-separated file', () {
      expect(read('cough\tkɒf\tho'), <List<String>>[
        <String>['cough', 'kɒf', 'ho'],
      ]);
    });

    test('a comma inside quotes does not decide the delimiter', () {
      expect(read('"a, b, c";x;y'), <List<String>>[
        <String>['a, b, c', 'x', 'y'],
      ]);
    });

    test('blank lines are dropped, wherever they are', () {
      expect(read('\n\na,b\n\n  \nc,d\n\n'), <List<String>>[
        <String>['a', 'b'],
        <String>['c', 'd'],
      ]);
    });

    test('UTF-16 is refused rather than read as garbage', () {
      final utf16 = Uint8List.fromList(<int>[0xFF, 0xFE, 0x61, 0x00]);
      expect(() => CsvReader.read(utf16), throwsFormatException);
    });

    test('invalid UTF-8 is refused', () {
      expect(
        () => CsvReader.read(Uint8List.fromList(<int>[0x61, 0xC3, 0x28])),
        throwsFormatException,
      );
    });
  });

  group('WordCsvParser', () {
    WordCsvParse parse(String text) =>
        WordCsvParser.parse(CsvReader.read(utf8Bytes(text)));

    test('maps front, ipa, back, category, tags', () {
      final row = parse('cough,/kɒf/,ho,Health,body;verbs').rows.single;

      expect(row.line, 1);
      expect(row.headword, 'cough');
      expect(row.ipa, 'kɒf');
      expect(row.meaning, 'ho');
      expect(row.listNames, <String>['Health', 'body', 'verbs']);
    });

    test('square brackets around the IPA are stripped too', () {
      expect(parse('cough,[kɒf]').rows.single.ipa, 'kɒf');
    });

    test('short rows are fine: only the word is required', () {
      final row = parse('cough').rows.single;
      expect(row.ipa, isNull);
      expect(row.meaning, isNull);
      expect(row.listNames, isEmpty);
    });

    test('blank cells are null, not empty strings', () {
      final row = parse('cough, , ,  ,').rows.single;
      expect(row.ipa, isNull);
      expect(row.meaning, isNull);
      expect(row.listNames, isEmpty);
    });

    test('tags split on | as well as ;', () {
      expect(parse('a,,,,x | y').rows.single.listNames, <String>['x', 'y']);
    });

    test('columns after the fifth are more tags', () {
      // An unquoted `x;y` in a semicolon file arrives as two columns.
      expect(parse('a;;;Cat;x;y').rows.single.listNames, <String>[
        'Cat',
        'x',
        'y',
      ]);
    });

    test('a list named twice, in any case, is kept once', () {
      expect(parse('a,,,Food,food;FOOD;Drink').rows.single.listNames, <String>[
        'Food',
        'Drink',
      ]);
    });

    test('a row without a word is skipped and counted', () {
      final result = parse(',kɒf,ho\ncough,kɒf,ho\n  ,,,');

      expect(result.rows.map((r) => r.headword), <String>['cough']);
      expect(result.rows.single.line, 2);
      expect(result.skipped, 2);
    });

    test('everything is trimmed', () {
      final row = parse('  cough  ,  kɒf , ho ').rows.single;
      expect(row.headword, 'cough');
      expect(row.ipa, 'kɒf');
      expect(row.meaning, 'ho');
    });
  });

  group('WordCsvParser.readFile', () {
    test('a file over the size limit is refused before it is read', () {
      final big = Uint8List(WordImportLimits.maxBytes + 1);
      expect(WordCsvParser.readFile(big).problem, WordImportProblem.tooLarge);
    });

    test('too many rows is refused', () {
      final text = List<String>.filled(
        WordImportLimits.maxRows + 1,
        'word',
      ).join('\n');
      expect(
        WordCsvParser.readFile(utf8Bytes(text)).problem,
        WordImportProblem.tooManyRows,
      );
    });

    test('a file with no words is refused', () {
      expect(
        WordCsvParser.readFile(utf8Bytes(',,\n\n,x')).problem,
        WordImportProblem.noWords,
      );
    });

    test('a file that is not text is refused', () {
      expect(
        WordCsvParser.readFile(Uint8List.fromList(<int>[0xFF, 0xFE, 0, 0]))
            .problem,
        WordImportProblem.notText,
      );
    });

    test('a good file has no problem', () {
      final parsed = WordCsvParser.readFile(utf8Bytes('cough,kɒf,ho'));
      expect(parsed.problem, isNull);
      expect(parsed.rows, hasLength(1));
    });
  });
}
