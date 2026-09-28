import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/dictionary/dictionary_cache.dart';
import 'package:vocabnote/data/repositories/user_data_repository_impl.dart';

import 'backup_support.dart';
import 'db_fixtures.dart';

/// *Delete all data* (`docs/UI-UX.md` §4.9) and *Storage used*.
///
/// The library is not only rows: Replace's safety copies, exported backups,
/// the pre-migration copies bootstrap takes before an upgrade and the
/// dictionary cache are all copies of the user's words on disk. Deleting
/// "all data" and leaving those behind would be a promise broken quietly.
void main() {
  late AppDatabase db;
  late Directory support;
  late Directory library;
  late Directory exports;

  setUp(() async {
    db = AppDatabase.memory();
    support = await Directory.systemTemp.createTemp('vnb_support_');
    library = await Directory(p.join(support.path, 'vocabnote')).create();
    exports = await Directory.systemTemp.createTemp('vnb_exports_');
  });

  tearDown(() async {
    await db.close();
    await support.delete(recursive: true);
    await exports.delete(recursive: true);
  });

  UserDataRepositoryImpl repository() => UserDataRepositoryImpl(
    db,
    appVersion: '1.0.0',
    exportDirectory: () async => exports,
    libraryDirectory: () async => library,
    dictionaryCache: DictionaryCache(resolveDirectory: () async => support),
  );

  File fileIn(Directory folder, String name, [int bytes = 10]) =>
      File(p.join(folder.path, name))
        ..createSync(recursive: true)
        ..writeAsBytesSync(List<int>.filled(bytes, 7));

  group('delete all data', () {
    test('removes every row, and every copy of the library on disk', () async {
      await seedWord(db, id: 'w1', headword: 'cough');
      final live = fileIn(library, 'vocabnote.sqlite');
      final copies = <File>[
        fileIn(library, p.join('backups', 'schwanotes-before-replace-1.vnb')),
        fileIn(exports, 'schwanotes-backup-20260911-1405.vnb'),
        fileIn(library, 'vocabnote.pre-v1.bak'),
        fileIn(library, p.join('dictionary', 'cough.json')),
      ];

      final result = await repository().deleteAll();

      expect(result.isOk, isTrue, reason: '$result');
      expect(await rowsOf(db, 'words'), isEmpty);
      for (final copy in copies) {
        expect(copy.existsSync(), isFalse, reason: copy.path);
      }
      expect(
        live.existsSync(),
        isTrue,
        reason: 'the open database is emptied, never deleted',
      );
    });

    test('leaves no deleted word readable in the database file', () async {
      // Found on a device: deleted rows stay in the file - the FTS index
      // keeps a word's tokens until its segments merge, and a page keeps a
      // deleted row's bytes. A file on disk, because that is where it shows.
      // Opened beside setUp's database, on purpose.
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
      addTearDown(
        () => driftRuntimeOptions.dontWarnAboutMultipleDatabases = false,
      );
      final file = File(p.join(library.path, 'vocabnote.sqlite'));
      final onDisk = AppDatabase(NativeDatabase(file));
      try {
        await seedWord(onDisk, id: 'w1', headword: 'zyzzyva');
        await seedNote(onDisk, id: 'n1', wordId: 'w1', body: 'quokkas');

        final result = await UserDataRepositoryImpl(
          onDisk,
          appVersion: '1.0.0',
          exportDirectory: () async => exports,
          libraryDirectory: () async => library,
        ).deleteAll();

        expect(result.isOk, isTrue, reason: '$result');
      } finally {
        await onDisk.close();
      }
      // Latin-1 maps each byte to one character, so nothing is lost.
      final bytes = latin1.decode(file.readAsBytesSync());
      expect(bytes.contains('zyzzyva'), isFalse, reason: 'the headword');
      expect(bytes.contains('quokkas'), isFalse, reason: 'the note');
    });

    test('works on a phone that never made a copy of anything', () async {
      // No backups folder, no dictionary folder, no exports: nothing to
      // remove is not a failure.
      await seedWord(db, id: 'w1', headword: 'cough');

      final result = await repository().deleteAll();

      expect(result.isOk, isTrue, reason: '$result');
      expect(await rowsOf(db, 'words'), isEmpty);
    });
  });

  group('storage used', () {
    test('is everything the library keeps on disk', () async {
      fileIn(library, 'vocabnote.sqlite', 1000);
      fileIn(library, p.join('dictionary', 'cough.json'), 500);
      fileIn(library, p.join('backups', 'copy.vnb'), 250);

      final used = await repository().storageUsed();

      expect(used.valueOrNull, 1750);
    });

    test('is nothing when there is no folder yet', () async {
      await library.delete(recursive: true);

      expect((await repository().storageUsed()).valueOrNull, 0);
    });
  });
}
