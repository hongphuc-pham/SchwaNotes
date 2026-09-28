import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/data/backup/backup_codec.dart';
import 'package:vocabnote/data/backup/backup_tables.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/repositories/user_data_repository_impl.dart';
import 'package:vocabnote/domain/entities/backup.dart';

import 'db_fixtures.dart';

/// Writing a backup (F-073, `docs/DATABASE.md` §5).
///
/// Against a real in-memory database and a real temporary folder: the thing
/// under test is exactly what lands in the file.
void main() {
  late AppDatabase db;
  late Directory folder;
  var clock = DateTime(2026, 9, 11, 14, 5);

  setUp(() async {
    db = AppDatabase.memory();
    folder = await Directory.systemTemp.createTemp('vnb_export_');
    clock = DateTime(2026, 9, 11, 14, 5);
  });

  tearDown(() async {
    await db.close();
    await folder.delete(recursive: true);
  });

  UserDataRepositoryImpl repository() => UserDataRepositoryImpl(
    db,
    appVersion: '1.2.3',
    exportDirectory: () async => folder,
    now: () => clock,
  );

  Future<ExportedBackup> export() async =>
      (await repository().exportBackup()).fold<ExportedBackup>(
        (backup) => backup,
        (failure) => fail('export failed: $failure'),
      );

  Future<DecodedBackup> exportAndRead() async {
    final backup = await export();
    final bytes = await File(backup.path).readAsBytes();
    return BackupCodec.decode(bytes).fold<DecodedBackup>(
      (decoded) => decoded,
      (failure) => fail('unreadable: $failure'),
    );
  }

  Future<void> seedLibrary() async {
    await seedWord(db, id: 'w1', headword: 'church', ipaUk: 'ˈtʃɜːtʃ');
    await seedWord(db, id: 'w2', headword: 'cough', isFavourite: true);
    await seedNote(db, id: 'n1', wordId: 'w1', body: 'lips round');
    await seedHighlight(db, id: 'h1', wordId: 'w1', end: 3, label: 'tʃ');
    await seedList(db, id: 'l1', name: 'IELTS');
    await seedMembership(db, listId: 'l1', wordId: 'w1');
    await seedSession(db, id: 's1');
    await seedAnswer(db, id: 'a1', sessionId: 's1', wordId: 'w2');
  }

  test('names the file after the moment it was made', () async {
    final backup = await export();

    expect(backup.fileName, 'schwanotes-backup-20260911-1405.vnb');
    expect(File(backup.path).existsSync(), isTrue);
    expect(File(backup.path).parent.path, folder.path);
  });

  test('carries every user table, and settings', () async {
    await seedLibrary();

    final backup = await exportAndRead();

    expect(backup.tables.keys, unorderedEquals(backupTableNames));
    expect(backup.manifest.counts, <String, int>{
      'words': 2,
      'word_notes': 1,
      'ipa_highlights': 1,
      'word_lists': 1,
      'word_list_items': 1,
      'study_cards': 2,
      'practice_sessions': 1,
      'practice_answers': 1,
      'settings': 1,
    });
  });

  test('writes each value as the database stores it', () async {
    // SQL column names and SQLite values: the file format *is* the schema
    // DATABASE.md §2 documents, not a second vocabulary.
    await seedLibrary();

    final backup = await exportAndRead();
    final church = backup.tables['words']!.firstWhere((w) => w['id'] == 'w1');
    final cough = backup.tables['words']!.firstWhere((w) => w['id'] == 'w2');

    expect(church['headword_normalized'], 'church');
    expect(church['ipa_uk'], 'ˈtʃɜːtʃ');
    expect(church['source'], 'manual');
    expect(church['created_at'], testNow.millisecondsSinceEpoch);
    expect(church['is_favourite'], 0);
    expect(cough['is_favourite'], 1);
    expect(church['deleted_at'], isNull);

    final highlight = backup.tables['ipa_highlights']!.single;
    expect(highlight['color_token'], 'amber');
    expect(highlight['target'], 'ipa_uk');
    expect(highlight['end_grapheme'], 3);
  });

  test('keeps a deleted word, with the moment it was deleted', () async {
    // Replace restores it within its 30 days, exactly as it was.
    await seedWord(db, id: 'w1', headword: 'gone');
    await db.customStatement('UPDATE words SET deleted_at = 1757557800000');

    final backup = await exportAndRead();

    expect(backup.tables['words']!.single['deleted_at'], 1757557800000);
  });

  test('leaves out app_meta and the search index', () async {
    // install_id is local-only by promise (DATA-SOURCES §7); the rest of
    // app_meta describes this install; words_fts is derived.
    await seedLibrary();

    final backup = await exportAndRead();

    expect(backup.tables.keys, isNot(contains('app_meta')));
    expect(backup.tables.keys, isNot(contains('words_fts')));
  });

  test('an empty library still makes a valid backup', () async {
    final backup = await exportAndRead();

    expect(backup.manifest.wordCount, 0);
    expect(backup.tables['settings'], hasLength(1));
  });

  test('the manifest names this build, its schema and the moment', () async {
    final backup = await exportAndRead();

    expect(backup.manifest.appVersion, '1.2.3');
    expect(backup.manifest.schemaVersion, AppDatabase.latestSchemaVersion);
    expect(backup.manifest.formatVersion, BackupCodec.formatVersion);
    expect(backup.manifest.exportedAt, clock.toUtc());
  });

  test('only the newest export is left in the export folder', () async {
    // Each is a full copy of the user's words; a pile of them in a cache
    // folder helps nobody.
    await export();
    clock = clock.add(const Duration(minutes: 1));
    final newest = await export();

    final left = folder.listSync().whereType<File>().map((f) => f.path);
    expect(left, <String>[newest.path]);
  });
}
