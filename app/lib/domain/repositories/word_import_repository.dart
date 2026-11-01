import 'dart:typed_data';

import 'package:vocabnote/core/result.dart';
import 'package:vocabnote/domain/entities/app_settings.dart';
import 'package:vocabnote/domain/entities/word_import.dart';

/// Reads a CSV deck and brings its words into the library (F-010).
abstract interface class WordImportRepository {
  /// Reads [bytes] and compares them with the library. Writes nothing.
  ///
  /// A file that cannot be used is an `Ok` whose `problem` says why; `Err` is
  /// kept for the database failing.
  AsyncResult<WordImportPreview> preview(Uint8List bytes);

  /// Writes [preview]'s rows in one transaction.
  ///
  /// A word already in the library is **never overwritten**: only its empty
  /// fields are filled. The IPA goes in the field for [accent].
  ///
  /// A row's category is its list. A row without one goes to [fallbackList],
  /// created if need be, unless its word is already in a list.
  AsyncResult<WordImportReport> import(
    WordImportPreview preview, {
    required TtsLocale accent,
    required String fallbackList,
  });
}
