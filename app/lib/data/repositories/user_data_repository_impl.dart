import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:vocabnote/core/failure.dart';
import 'package:vocabnote/core/result.dart';
import 'package:vocabnote/data/backup/backup_codec.dart';
import 'package:vocabnote/data/backup/backup_importer.dart';
import 'package:vocabnote/data/backup/backup_tables.dart';
import 'package:vocabnote/data/backup/export_writer.dart';
import 'package:vocabnote/data/backup/library_wipe.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/dictionary/dictionary_cache.dart';
import 'package:vocabnote/domain/entities/backup.dart';
import 'package:vocabnote/domain/repositories/user_data_repository.dart';

/// Drift-backed [UserDataRepository].
class UserDataRepositoryImpl implements UserDataRepository {
  /// Creates the repository.
  ///
  /// Every folder, the dictionary cache and the clock are injectable for
  /// tests. By default:
  ///
  /// * the **library** folder is `<app support>/vocabnote` - where
  ///   `DatabaseOpener` keeps the database and its pre-upgrade copies, and
  ///   where the dictionary cache and the safety copies live;
  /// * **safety copies** go to `<library>/backups`, which the OS does not
  ///   clear;
  /// * **exports** go to a folder in the OS temporary directory, which it
  ///   may - right for a file whose only job is to be handed to the share
  ///   sheet.
  ///
  /// The app version may still be on its way (F-092); an export waits for it.
  new(
    this._db, {
    required this._appVersion,
    Future<Directory> Function()? exportDirectory,
    Future<Directory> Function()? safetyDirectory,
    Future<Directory> Function()? libraryDirectory,
    this._dictionaryCache,
    DateTime Function()? now,
  }) : _exportDirectory = exportDirectory ?? _defaultExportDirectory,
       _customSafetyDirectory = safetyDirectory,
       _libraryDirectory = libraryDirectory ?? _defaultLibraryDirectory,
       _now = now ?? DateTime.now;

  final AppDatabase _db;
  final FutureOr<String> _appVersion;
  final Future<Directory> Function() _exportDirectory;

  /// Null means `<library>/backups`; see [_safetyFolder].
  final Future<Directory> Function()? _customSafetyDirectory;
  final Future<Directory> Function() _libraryDirectory;
  final DictionaryCache? _dictionaryCache;
  final DateTime Function() _now;

  /// How many safety copies are kept. Each is a full copy of the library; a
  /// few is a way back, a pile is clutter in private storage.
  static const int keptSafetyCopies = 3;

  static Future<Directory> _defaultExportDirectory() async => Directory(
    p.join((await getTemporaryDirectory()).path, 'vocabnote', 'export'),
  );

  /// Must match `DatabaseOpener`'s folder: the pre-upgrade copies it takes
  /// are found, and removed by *Delete all data*, here.
  static Future<Directory> _defaultLibraryDirectory() async => Directory(
    p.join((await getApplicationSupportDirectory()).path, 'vocabnote'),
  );

  Future<Directory> _safetyFolder() async {
    final custom = _customSafetyDirectory;
    if (custom != null) return await custom();
    return Directory(p.join((await _libraryDirectory()).path, 'backups'));
  }

  @override
  AsyncResult<ExportedBackup> exportBackup() => Results.guard(
    () async {
      final now = _now();
      final (:manifest, :bytes) = await _snapshot(now);
      return await writeExport(
        folder: await _exportDirectory(),
        bytes: bytes,
        manifest: manifest,
        now: now,
      );
    },
    onError: (error, stackTrace) => FileFailure(
      kind: FileFailureKind.io,
      cause: error,
      stackTrace: stackTrace,
    ),
  );

  @override
  AsyncResult<BackupManifest> previewBackup(Uint8List bytes) async =>
      (await _decodeOffTheUiThread(bytes)).map((backup) => backup.manifest);

  @override
  AsyncResult<ImportReport> importBackup(
    Uint8List bytes,
    ImportMode mode,
  ) async {
    // Refused before anything - even the safety copy - is touched.
    final decoded = await _decodeOffTheUiThread(bytes);
    return switch (decoded) {
      Err(:final failure) => Err<ImportReport, AppFailure>(failure),
      Ok(value: final backup) => await Results.guard(
        () => _import(backup, mode),
        onError: (error, stackTrace) => error is FileSystemException
            ? FileFailure(
                kind: FileFailureKind.io,
                cause: error,
                stackTrace: stackTrace,
              )
            : DatabaseFailure(
                operation: 'import backup',
                cause: error,
                stackTrace: stackTrace,
              ),
      ),
    };
  }

  Future<ImportReport> _import(DecodedBackup backup, ImportMode mode) async {
    final importer = BackupImporter(_db);
    switch (mode) {
      case ImportMode.merge:
        return await importer.merge(backup);
      case ImportMode.replace:
        // First, and fatal if it fails: a replace with no way back does not
        // happen (DATABASE.md §5 - "takes a backup first").
        await _writeSafetyCopy();
        return await importer.replace(backup);
    }
  }

  @override
  AsyncResult<void> deleteAll() => Results.guard(
    () async {
      await wipeLibrary(_db);
      // Then every other copy of the library. Each independently and
      // quietly: the rows are already gone, and one file that will not
      // delete must not keep the others.
      await _quietly(() => scrubFreedSpace(_db));
      await _quietly(() async {
        for (final copy in await _backupFilesIn(await _safetyFolder())) {
          await copy.delete();
        }
      });
      await _quietly(() async {
        for (final export in await _backupFilesIn(await _exportDirectory())) {
          await export.delete();
        }
      });
      await _quietly(() async {
        for (final copy in await _preUpgradeCopiesIn(
          await _libraryDirectory(),
        )) {
          await copy.delete();
        }
      });
      await _dictionaryCache?.clear();
    },
    onError: (error, stackTrace) => DatabaseFailure(
      operation: 'delete all data',
      cause: error,
      stackTrace: stackTrace,
    ),
  );

  @override
  AsyncResult<int> storageUsed() => Results.guard(
    () async {
      final folder = await _libraryDirectory();
      if (!folder.existsSync()) return 0;
      var total = 0;
      await for (final entity in folder.list(recursive: true)) {
        if (entity is File) total += await entity.length();
      }
      return total;
    },
    onError: (error, stackTrace) => FileFailure(
      kind: FileFailureKind.io,
      cause: error,
      stackTrace: stackTrace,
    ),
  );

  static Future<void> _quietly(Future<void> Function() step) async {
    try {
      await step();
    } on Object {
      // Deliberately swallowed. See deleteAll.
    }
  }

  /// The library as one moment, encoded.
  Future<({BackupManifest manifest, Uint8List bytes})> _snapshot(
    DateTime now,
  ) async {
    // One transaction, so the file is a single moment of the library - not
    // words from before a save and notes from after it.
    final tables = await _db.transaction(
      () => readBackupTables(
        (sql) async => <BackupRow>[
          for (final row in await _db.customSelect(sql).get()) row.data,
        ],
      ),
    );
    final manifest = BackupCodec.manifestFor(
      appVersion: await _appVersion,
      schemaVersion: AppDatabase.latestSchemaVersion,
      exportedAt: now,
      tables: tables,
    );
    return (
      manifest: manifest,
      bytes: await _encodeOffTheUiThread(manifest, tables),
    );
  }

  /// Writes the library as it is now to the safety folder, keeping only the
  /// newest [keptSafetyCopies].
  Future<void> _writeSafetyCopy() async {
    final now = _now();
    final (:bytes, manifest: _) = await _snapshot(now);

    final folder = await _safetyFolder();
    await folder.create(recursive: true);
    final stamp = DateFormat('yyyyMMdd-HHmmss').format(now.toLocal());
    await File(p.join(folder.path, 'schwanotes-before-replace-$stamp.vnb'))
        .writeAsBytes(bytes, flush: true);

    // Newest first: the name is the moment, so it sorts as time does.
    final copies = await _backupFilesIn(folder)
      ..sort((a, b) => b.path.compareTo(a.path));
    for (final old in copies.skip(keptSafetyCopies)) {
      await old.delete();
    }
  }

  static Future<List<File>> _backupFilesIn(Directory folder) async =>
      !folder.existsSync()
      ? <File>[]
      : <File>[
          await for (final entity in folder.list())
            if (entity is File && entity.path.endsWith('.vnb')) entity,
        ];

  /// `vocabnote.pre-v<n>.bak`, the copies `DatabaseOpener` takes before an
  /// upgrade (DATABASE.md §3.6).
  static Future<List<File>> _preUpgradeCopiesIn(Directory folder) async =>
      !folder.existsSync()
      ? <File>[]
      : <File>[
          await for (final entity in folder.list())
            if (entity is File &&
                p.basename(entity.path).startsWith('vocabnote.pre-v') &&
                entity.path.endsWith('.bak'))
              entity,
        ];

  /// Encodes on another isolate: 5,000 words is megabytes of JSON to encode
  /// and compress, and the export button must not freeze the screen.
  ///
  /// Static on purpose. A closure written inside an instance method can drag
  /// `this` - and with it the open database - into the isolate message, which
  /// cannot be sent.
  static Future<Uint8List> _encodeOffTheUiThread(
    BackupManifest manifest,
    BackupTables tables,
  ) => Isolate.run(() => BackupCodec.encode(manifest, tables));

  /// Decodes on another isolate, for the same reason as encoding.
  ///
  /// Only the problem crosses back on failure: the exception the codec
  /// caught is not guaranteed to be sendable between isolates.
  static Future<AppResult<DecodedBackup>> _decodeOffTheUiThread(
    Uint8List bytes,
  ) => Isolate.run(
    () => BackupCodec.decode(bytes).mapErr<AppFailure>(
      (failure) => failure is InvalidBackupFailure
          ? InvalidBackupFailure(problem: failure.problem)
          : const UnexpectedFailure(),
    ),
  );
}
