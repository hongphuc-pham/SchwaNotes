import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:vocabnote/data/import/csv_reader.dart';
import 'package:vocabnote/domain/entities/word_import.dart';
import 'package:vocabnote/domain/value_objects/ipa.dart';

/// Rows read from a deck file, before the library is consulted.
@immutable
class WordCsvParse {
  /// Creates the result.
  const new({
    this.rows = const <WordImportRow>[],
    this.skipped = 0,
    this.problem,
  });

  /// Every row with a word in it.
  final List<WordImportRow> rows;

  /// Rows with nothing in the first column.
  final int skipped;

  /// Why the file cannot be used, or null.
  final WordImportProblem? problem;
}

/// Turns CSV rows into words: `front, ipa, back, category, tags`, no header.
abstract final class WordCsvParser {
  static final RegExp _tagSplit = RegExp('[;|]');

  /// Reads a whole file, holding it to [WordImportLimits].
  static WordCsvParse readFile(Uint8List bytes) {
    if (bytes.length > WordImportLimits.maxBytes) {
      return const WordCsvParse(problem: WordImportProblem.tooLarge);
    }
    final List<List<String>> cells;
    try {
      cells = CsvReader.read(bytes);
    } on FormatException {
      return const WordCsvParse(problem: WordImportProblem.notText);
    }
    final parsed = parse(cells);
    if (parsed.rows.length > WordImportLimits.maxRows) {
      return const WordCsvParse(problem: WordImportProblem.tooManyRows);
    }
    if (parsed.rows.isEmpty) {
      return const WordCsvParse(problem: WordImportProblem.noWords);
    }
    return parsed;
  }

  /// Maps rows of cells to words. Rows without a word are counted, not kept.
  static WordCsvParse parse(List<List<String>> cells) {
    final rows = <WordImportRow>[];
    var skipped = 0;
    for (var i = 0; i < cells.length; i++) {
      final row = cells[i];
      String? cell(int index) {
        if (index >= row.length) return null;
        final value = row[index].trim();
        return value.isEmpty ? null : value;
      }

      final headword = cell(0);
      if (headword == null) {
        skipped++;
        continue;
      }

      final tags = <String>[
        for (var c = 4; c < row.length; c++)
          for (final tag in row[c].split(_tagSplit))
            if (tag.trim().isNotEmpty) tag.trim(),
      ];
      final seen = <String>{};
      rows.add(
        WordImportRow(
          line: i + 1,
          headword: headword,
          ipa: switch (cell(1)) {
            final String raw => Ipa.tryParse(raw)?.value,
            null => null,
          },
          meaning: cell(2),
          category: cell(3),
          tagNames: <String>[
            for (final name in tags)
              if (seen.add(name.toLowerCase())) name,
          ],
        ),
      );
    }
    return WordCsvParse(rows: rows, skipped: skipped);
  }
}
