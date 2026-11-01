import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/data/backup/backup_codec.dart';
import 'package:vocabnote/data/backup/backup_importer.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/domain/entities/backup.dart';
import 'package:vocabnote/domain/entities/word_list.dart';

import 'backup_support.dart';
import 'db_fixtures.dart';

/// Merging a backup into the words already on this phone (F-074, the
/// default; `docs/DATABASE.md` §5).
///
/// The rule the whole file defends: **a merge only adds and updates.** It
/// never deletes or hides a word the user has, and where both sides have the
/// same thing, the newer one wins.
void main() {
  late AppDatabase phone;
  late AppDatabase other;

  final earlier = testNow;
  final later = testNow.add(const Duration(days: 1));

  setUp(() {
    phone = AppDatabase.memory();
    other = AppDatabase.memory();
  });

  tearDown(() async {
    await phone.close();
    await other.close();
  });

  Future<ImportReport> merge([DecodedBackup? backup]) async =>
      await BackupImporter(phone).merge(backup ?? await backupOf(other));

  Future<BackupRow> wordOn(AppDatabase db, String id) async =>
      (await rowsOf(db, 'words')).singleWhere((w) => w['id'] == id);

  Future<void> seedLibrary(AppDatabase db) async {
    await seedWord(db, id: 'w1', headword: 'church', ipaUk: 'ˈtʃɜːtʃ');
    await seedNote(db, id: 'n1', wordId: 'w1', body: 'rounded lips');
    await seedHighlight(db, id: 'h1', wordId: 'w1', end: 3);
    await seedList(db, id: 'l1', name: 'IELTS');
    await seedMembership(db, listId: 'l1', wordId: 'w1');
    await seedSession(db, id: 's1');
    await seedAnswer(db, id: 'a1', sessionId: 's1', wordId: 'w1');
  }

  group('adding', () {
    test(
      'brings in what this phone lacks, with all that hangs off it',
      () async {
        await seedLibrary(other);

        final report = await merge();

        expect(report.wordsAdded, 1);
        expect(report.wordsUpdated, 0);
        expect(report.wordsSkipped, 0);
        expect(report.notesAdded, 1);
        expect(report.highlightsAdded, 1);
        expect(report.listsAdded, 1);
        for (final table in <String>[
          'words',
          'word_notes',
          'ipa_highlights',
          'word_lists',
          'word_list_items',
          'study_cards',
          'practice_sessions',
          'practice_answers',
        ]) {
          expect(await rowsOf(phone, table), hasLength(1), reason: table);
        }
      },
    );

    test('search finds what a merge brought in', () async {
      await seedLibrary(other);

      await merge();

      final hits = await phone
          .customSelect(
            "SELECT word_id FROM words_fts WHERE words_fts MATCH 'rounded'",
          )
          .get();
      expect(hits.map((r) => r.data['word_id']), <String>['w1']);
    });
  });

  group('the same word on both sides', () {
    test('newer in the backup: the backup wins', () async {
      await seedWord(
        phone,
        id: 'w1',
        headword: 'cough',
        definition: 'old',
        updatedAt: earlier,
      );
      await seedWord(
        other,
        id: 'w1',
        headword: 'cough',
        definition: 'new',
        updatedAt: later,
      );

      final report = await merge();

      expect(report.wordsUpdated, 1);
      expect((await wordOn(phone, 'w1'))['definition'], 'new');
    });

    test('newer on this phone: this phone wins', () async {
      await seedWord(
        phone,
        id: 'w1',
        headword: 'cough',
        definition: 'mine',
        updatedAt: later,
      );
      await seedWord(
        other,
        id: 'w1',
        headword: 'cough',
        definition: 'theirs',
        updatedAt: earlier,
      );

      final report = await merge();

      expect(report.wordsSkipped, 1);
      expect((await wordOn(phone, 'w1'))['definition'], 'mine');
    });

    test('typed on both phones: matched by headword, never doubled', () async {
      // Different ids, same word: the ids are uuids from two installs.
      await seedWord(phone, id: 'mine', headword: 'Cough', updatedAt: earlier);
      await seedWord(
        other,
        id: 'theirs',
        headword: 'cough',
        definition: 'from the backup',
        updatedAt: later,
      );
      await seedNote(other, id: 'n9', wordId: 'theirs', body: 'soft f');

      final report = await merge();

      final words = await rowsOf(phone, 'words');
      expect(words.map((w) => w['id']), <String>['mine']);
      expect(words.single['definition'], 'from the backup');
      expect(report.wordsUpdated, 1);
      expect(
        (await rowsOf(phone, 'word_notes')).single['word_id'],
        'mine',
        reason: "the backup's note follows the word to this phone's id",
      );
    });
  });

  group('never deletes or hides', () {
    test('a word the backup lacks, or has deleted, stays', () async {
      await seedWord(phone, id: 'keep', headword: 'keep');
      await seedWord(phone, id: 'w2', headword: 'shared', updatedAt: earlier);
      await seedWord(other, id: 'w2', headword: 'shared', updatedAt: later);
      await seedWord(other, id: 'w3', headword: 'gone');
      await other.customStatement(
        'UPDATE words SET deleted_at = ? WHERE id IN (?, ?)',
        <Object>[ms(later), 'w2', 'w3'],
      );

      final report = await merge();

      final words = await rowsOf(phone, 'words');
      expect(
        words.map((w) => w['id']),
        unorderedEquals(<String>['keep', 'w2']),
      );
      expect(words.every((w) => w['deleted_at'] == null), isTrue);
      expect(report.wordsSkipped, 2);
    });

    test('a word deleted here comes back when the backup has it, '
        'newer', () async {
      await seedWord(phone, id: 'w1', headword: 'back', updatedAt: earlier);
      await phone.customStatement(
        'UPDATE words SET deleted_at = ? WHERE id = ?',
        <Object>[ms(earlier), 'w1'],
      );
      await seedWord(other, id: 'w1', headword: 'back', updatedAt: later);

      final report = await merge();

      expect((await wordOn(phone, 'w1'))['deleted_at'], isNull);
      expect(report.wordsUpdated, 1);
    });
  });

  group('highlights', () {
    test('arrive only on the IPA they were drawn on', () async {
      // This phone's newer word has a different transcription: the backup's
      // highlight would land on the wrong sounds.
      await seedWord(
        phone,
        id: 'w1',
        headword: 'church',
        ipaUk: 'tʃɝtʃ',
        updatedAt: later,
      );
      await seedWord(
        other,
        id: 'w1',
        headword: 'church',
        ipaUk: 'ˈtʃɜːtʃ',
        updatedAt: earlier,
      );
      await seedHighlight(other, id: 'h1', wordId: 'w1', end: 3);

      final report = await merge();

      expect(report.highlightsAdded, 0);
      expect(await rowsOf(phone, 'ipa_highlights'), isEmpty);
    });

    test('that run past the end of their word are not brought in', () async {
      await seedWord(other, id: 'w1', headword: 'cough', ipaUk: 'kɒf');
      final backup = await backupOf(other);
      backup.tables['ipa_highlights'] = <BackupRow>[
        <String, Object?>{
          'id': 'h1',
          'word_id': 'w1',
          'target': 'ipa_uk',
          'start_grapheme': 1,
          'end_grapheme': 9,
          'color_token': 'amber',
          'created_at': ms(testNow),
        },
      ];

      final report = await merge(backup);

      expect(await rowsOf(phone, 'ipa_highlights'), isEmpty);
      expect(report.rejected, 1);
    });
  });

  group('lists', () {
    test('of the same name are one list; new ones go after this '
        "phone's", () async {
      await seedList(phone, id: 'mine', name: 'IELTS');
      await seedList(phone, id: 'work', name: 'Work', sortOrder: 1);
      await seedWord(other, id: 'w1', headword: 'cough');
      await seedList(other, id: 'theirs', name: ' ielts ');
      await seedList(other, id: 'travel', name: 'Travel');
      await seedMembership(other, listId: 'theirs', wordId: 'w1');

      final report = await merge();

      final lists = await rowsOf(phone, 'word_lists');
      expect(lists.map((l) => l['id']), <String>['mine', 'work', 'travel']);
      expect(lists.last['sort_order'], 2);
      expect(report.listsAdded, 1);
      expect(
        (await rowsOf(phone, 'word_list_items')).single['list_id'],
        'mine',
      );
    });

    test('a tag and a list of one name stay two things', () async {
      await seedList(phone, id: 'list', name: 'Verbs');
      await seedWord(other, id: 'w1', headword: 'cough');
      await seedList(other, id: 'tag', name: 'verbs', kind: ListKind.tag);
      await seedMembership(other, listId: 'tag', wordId: 'w1');

      await merge();

      final lists = await rowsOf(phone, 'word_lists');
      expect(lists.map((l) => l['id']), <String>['list', 'tag']);
      expect(lists.last['kind'], 'tag');
      expect((await rowsOf(phone, 'word_list_items')).single['list_id'], 'tag');
    });

    test(
      'a list made a tag since, on the other phone, arrives a tag',
      () async {
        await seedList(phone, id: 'same', name: 'body');
        await seedList(
          other,
          id: 'same',
          name: 'body',
          kind: ListKind.tag,
          createdAt: testNow.add(const Duration(days: 1)),
        );

        await merge();

        expect((await rowsOf(phone, 'word_lists')).single['kind'], 'tag');
      },
    );
  });

  group('study cards', () {
    Future<void> reviewed(
      AppDatabase db, {
      required int box,
      required DateTime at,
    }) => db.customStatement(
      'UPDATE study_cards SET box = ?, last_reviewed_at = ? '
      "WHERE word_id = 'w1'",
      <Object>[box, ms(at)],
    );

    Future<int> boxOnPhone() async =>
        (await rowsOf(phone, 'study_cards')).single['box']! as int;

    test('the one reviewed most recently wins', () async {
      await seedWord(phone, id: 'w1', headword: 'cough');
      await seedWord(other, id: 'w1', headword: 'cough');
      await reviewed(phone, box: 1, at: earlier);
      await reviewed(other, box: 4, at: later);

      await merge();

      expect(await boxOnPhone(), 4);
    });

    test("this phone's more recent review is kept", () async {
      await seedWord(phone, id: 'w1', headword: 'cough');
      await seedWord(other, id: 'w1', headword: 'cough');
      await reviewed(phone, box: 2, at: later);
      await reviewed(other, box: 5, at: earlier);

      await merge();

      expect(await boxOnPhone(), 2);
    });
  });

  group('settings', () {
    Future<BackupRow> settingsOn(AppDatabase db) async =>
        (await rowsOf(db, 'settings')).single;

    test('a phone with settings of its own keeps them', () async {
      await phone.customStatement('UPDATE settings SET daily_goal = 50');
      await other.customStatement(
        "UPDATE settings SET daily_goal = 10, theme_mode = 'dark'",
      );

      await merge();

      final settings = await settingsOn(phone);
      expect(settings['daily_goal'], 50);
      expect(settings['theme_mode'], 'system');
    });

    test("a phone still on the defaults takes the backup's - "
        'but never its reminder', () async {
      // A new phone: nothing chosen yet, so nothing to overwrite. The
      // reminder needs this phone's permission, asked only by its switch.
      await other.customStatement(
        "UPDATE settings SET daily_goal = 10, theme_mode = 'dark', "
        'reminder_enabled = 1, reminder_time_minutes = 480',
      );

      await merge();

      final settings = await settingsOn(phone);
      expect(settings['daily_goal'], 10);
      expect(settings['theme_mode'], 'dark');
      expect(settings['reminder_enabled'], 0);
      expect(settings['reminder_time_minutes'], 480);
    });
  });

  test(
    'merging the same backup twice changes nothing the second time',
    () async {
      await seedLibrary(other);
      await merge();
      final before = await snapshot(phone);

      final again = await merge();

      expect(again.wordsAdded, 0);
      expect(again.wordsUpdated, 0);
      expect(again.notesAdded, 0);
      expect(again.highlightsAdded, 0);
      expect(again.listsAdded, 0);
      expect(await snapshot(phone), before);
    },
  );

  test('rows that cannot be used are counted; the rest still arrive', () async {
    await seedWord(other, id: 'w1', headword: 'cough');
    final backup = await backupOf(other);
    backup.tables['words']!.add(<String, Object?>{'id': 'w2'});
    backup.tables['word_notes'] = <BackupRow>[
      <String, Object?>{
        'id': 'orphan',
        'word_id': 'nowhere',
        'body': 'no word to hang on',
        'created_at': 1,
        'updated_at': 1,
      },
    ];
    backup.tables['recordings'] = <BackupRow>[
      <String, Object?>{'id': 'r1'},
    ];

    final report = await merge(backup);

    expect((await rowsOf(phone, 'words')).map((w) => w['id']), <String>['w1']);
    expect(await rowsOf(phone, 'word_notes'), isEmpty);
    expect(report.rejected, 2);
  });

  test('a failure part-way leaves this phone exactly as it was', () async {
    await seedWord(phone, id: 'w0', headword: 'mine');
    await seedLibrary(other);
    final before = await snapshot(phone);
    await failInsertsInto(phone, 'word_lists');

    await expectLater(merge(), throwsA(anything));

    expect(await snapshot(phone), before);
  });
}
