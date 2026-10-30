/// Bringing words in from a CSV file (F-010).
///
/// The file has **no header**, and its columns are, in order:
/// `front, ipa, back, category, tags`. `back` is the meaning in the user's own
/// language and goes into `definition`. `category` and each tag become lists.
library;

import 'package:meta/meta.dart';

/// One usable line of the file.
@immutable
class WordImportRow {
  /// Creates a row.
  const new({
    required this.line,
    required this.headword,
    this.ipa,
    this.meaning,
    this.listNames = const <String>[],
  });

  /// The 1-based line the row started on, for the preview.
  final int line;

  /// The `front` column, trimmed. Never empty.
  final String headword;

  /// The `ipa` column without slashes, or null when blank.
  final String? ipa;

  /// The `back` column, or null when blank.
  final String? meaning;

  /// The category first, then each tag; trimmed, no blanks, no repeats
  /// (compared case-insensitively, keeping the first spelling).
  final List<String> listNames;
}

/// Why a file cannot be imported at all. Nothing is written for any of these.
enum WordImportProblem {
  /// Not UTF-8 text: a spreadsheet saved as UTF-16 "Unicode text", or not a
  /// text file at all.
  notText,

  /// Bigger than [WordImportLimits.maxBytes].
  tooLarge,

  /// More rows than [WordImportLimits.maxRows].
  tooManyRows,

  /// No line with a word in its first column.
  noWords,
}

/// The ceilings an import is held to.
abstract final class WordImportLimits {
  /// 2 MB is tens of thousands of words, far above any real deck.
  static const int maxBytes = 2 * 1024 * 1024;

  /// Rows with a word in them.
  static const int maxRows = 5000;

  /// How many rows the preview shows.
  static const int previewRows = 5;
}

/// What a file holds, read and checked against the library. Nothing has been
/// written.
@immutable
class WordImportPreview {
  /// Creates a preview.
  const new({
    this.rows = const <WordImportRow>[],
    this.skippedLines = 0,
    this.newWords = 0,
    this.existingWords = 0,
    this.newListNames = const <String>[],
    this.problem,
  });

  /// A file that cannot be imported, and why.
  const new refused(WordImportProblem this.problem)
    : rows = const <WordImportRow>[],
      skippedLines = 0,
      newWords = 0,
      existingWords = 0,
      newListNames = const <String>[];

  /// Every usable row, in file order.
  final List<WordImportRow> rows;

  /// Non-blank lines without a word in the first column.
  final int skippedLines;

  /// Rows whose word is not in the library yet (repeats in the file count
  /// once).
  final int newWords;

  /// Rows whose word already is. They are only filled in, never overwritten.
  final int existingWords;

  /// Lists that do not exist yet and will be created.
  final List<String> newListNames;

  /// Set when the file cannot be imported; everything else is then empty.
  final WordImportProblem? problem;
}

/// What an import came to.
@immutable
class WordImportReport {
  /// Creates a report.
  const new({
    this.added = 0,
    this.filled = 0,
    this.unchanged = 0,
    this.skipped = 0,
    this.listsCreated = 0,
  });

  /// New words.
  final int added;

  /// Words that were already there and had an empty field filled in.
  final int filled;

  /// Words that were already there with nothing to fill.
  final int unchanged;

  /// Lines with no word in the first column.
  final int skipped;

  /// Lists created for categories and tags.
  final int listsCreated;
}
