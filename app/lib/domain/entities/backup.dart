import 'package:meta/meta.dart';

/// What a `.vnb` backup says about itself: its `manifest.json`
/// (`docs/DATABASE.md` §5).
///
/// Every field has a default, because a reader must accept a sparse or newer
/// manifest and use what it recognises (RULES §12).
@immutable
class BackupManifest {
  /// Creates a manifest.
  const new({
    required this.appVersion,
    required this.schemaVersion,
    required this.formatVersion,
    this.exportedAt,
    this.counts = const <String, int>{},
  });

  /// The version of VocabNote that wrote the file, e.g. `1.0.0`.
  final String appVersion;

  /// The database schema version of the app that wrote it.
  final int schemaVersion;

  /// The version of the file format itself, bumped separately from the
  /// schema (RULES §12).
  final int formatVersion;

  /// When the backup was made, in UTC. Null if the file does not say.
  final DateTime? exportedAt;

  /// Rows per table, keyed by SQL table name.
  final Map<String, int> counts;

  /// How many words the backup holds, counting deleted ones.
  int get wordCount => counts['words'] ?? 0;
}

/// How a backup comes in (F-074).
enum ImportMode {
  /// The default: add what is new, update what is newer, remove nothing.
  merge,

  /// Everything here is replaced by the backup, after a safety copy.
  replace,
}

/// What an import did, for the report the user sees (F-074: "Reports
/// added / updated / skipped").
@immutable
class ImportReport {
  /// Creates a report.
  const new({
    this.wordsAdded = 0,
    this.wordsUpdated = 0,
    this.wordsSkipped = 0,
    this.notesAdded = 0,
    this.highlightsAdded = 0,
    this.listsAdded = 0,
    this.rejected = 0,
  });

  /// Words this phone did not have.
  final int wordsAdded;

  /// Words this phone had, where the backup's copy was newer.
  final int wordsUpdated;

  /// Words left as they were: already here and as new, or deleted in the
  /// backup.
  final int wordsSkipped;

  /// Notes brought in.
  final int notesAdded;

  /// Highlights brought in.
  final int highlightsAdded;

  /// Lists brought in.
  final int listsAdded;

  /// Rows that could not be used - the wrong shape, or pointing at something
  /// the backup does not contain. Counted so the report can say so, never a
  /// reason to refuse the rest.
  final int rejected;

  @override
  String toString() =>
      'ImportReport(words +$wordsAdded ~$wordsUpdated =$wordsSkipped, '
      'notes +$notesAdded, highlights +$highlightsAdded, '
      'lists +$listsAdded, rejected $rejected)';
}

/// A backup written to a file, ready to be handed on.
@immutable
class ExportedBackup {
  /// Creates the description of a written backup.
  const new({
    required this.path,
    required this.fileName,
    required this.manifest,
  });

  /// Where the file is.
  final String path;

  /// Its name, `schwanotes-backup-YYYYMMDD-HHmm.vnb`.
  final String fileName;

  /// What it says about itself.
  final BackupManifest manifest;
}
