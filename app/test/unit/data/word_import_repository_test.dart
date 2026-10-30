import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/import/word_import_repository_impl.dart';
import 'package:vocabnote/domain/entities/app_settings.dart';
import 'package:vocabnote/domain/entities/word_import.dart';

import 'db_fixtures.dart';

/// Importing a CSV deck into the library (F-010).
///
/// The rule the file defends: **an import never overwrites.** A word that is
/// already there only has its empty fields filled in.
void main() {
  late AppDatabase db;
  late WordImportRepositoryImpl repo;

  setUp(() {
    db = AppDatabase.memory();
    repo = WordImportRepositoryImpl(db, now: () => testNow);
  });

  tearDown(() => db.close());

  Future<WordImportPreview> preview(String csv) async =>
      (await repo.preview(Uint8List.fromList(utf8.encode(csv)))).valueOrNull!;

  Future<WordImportReport> import(
    String csv, {
    TtsLocale accent = TtsLocale.enGb,
  }) async =>
      (await repo.import(await preview(csv), accent: accent)).valueOrNull!;

  Future<WordRow> word(String normalized) async =>
      (await db.wordsDao.findByNormalized(normalized))!;

  Future<Map<String, Set<String>>> membership() async {
    final lists = await db.select(db.wordLists).get();
    final items = await db.select(db.wordListItems).get();
    final words = await db.select(db.words).get();
    String nameOf(String id) => lists.singleWhere((l) => l.id == id).name;
    String headwordOf(String id) =>
        words.singleWhere((w) => w.id == id).headword;
    return <String, Set<String>>{
      for (final list in lists) list.name: <String>{},
      for (final item in items) nameOf(item.listId): <String>{},
    }..forEach((name, set) {
      for (final item in items) {
        if (nameOf(item.listId) == name) set.add(headwordOf(item.wordId));
      }
    });
  }

  group('new words', () {
    test('every column lands where it belongs', () async {
      final report = await import('cough,/kɒf/,ho,Health,verbs');

      final row = await word('cough');
      expect(row.headword, 'cough');
      expect(row.ipaUk, 'kɒf');
      expect(row.ipaUs, isNull);
      expect(row.definition, 'ho');
      expect(report.added, 1);
      expect(report.listsCreated, 2);
      expect(await membership(), <String, Set<String>>{
        'Health': <String>{'cough'},
        'verbs': <String>{'cough'},
      });
    });

    test('the IPA goes in the field for the American accent', () async {
      await import('cough,kɔːf', accent: TtsLocale.enUs);

      final row = await word('cough');
      expect(row.ipaUs, 'kɔːf');
      expect(row.ipaUk, isNull);
    });

    test('every new word is due for review straight away', () async {
      await import('cough\nthrough');

      final cards = await db.select(db.studyCards).get();
      expect(cards, hasLength(2));
      expect(cards.map((c) => c.dueAt), everyElement(testNow));
      expect(cards.map((c) => c.box), everyElement(0));
    });

    test('an existing list is reused, whatever its case', () async {
      await seedList(db, id: 'l1', name: 'Health');

      final report = await import('cough,,,health');

      expect(report.listsCreated, 0);
      expect((await db.select(db.wordLists).get()).single.id, 'l1');
      expect(await membership(), <String, Set<String>>{
        'Health': <String>{'cough'},
      });
    });

    test('a word twice in the file is one word, first value first', () async {
      final report = await import('cough,,ho\nCough,kɒf,khác,Health');

      final row = await word('cough');
      expect(row.headword, 'cough');
      expect(row.definition, 'ho');
      expect(row.ipaUk, 'kɒf');
      expect(report.added, 1);
      expect(await db.select(db.words).get(), hasLength(1));
      expect(await membership(), <String, Set<String>>{
        'Health': <String>{'cough'},
      });
    });
  });

  group('words already in the library are never overwritten', () {
    test('only the empty fields are filled', () async {
      await seedWord(db, id: 'w1', headword: 'cough', definition: 'my own');

      final report = await import('cough,kɒf,from the file');

      final row = await word('cough');
      expect(row.id, 'w1');
      expect(row.definition, 'my own');
      expect(row.ipaUk, 'kɒf');
      expect(report.filled, 1);
      expect(report.added, 0);
    });

    test('a complete word is left exactly as it was', () async {
      await seedWord(
        db,
        id: 'w1',
        headword: 'cough',
        ipaUk: 'kɒf',
        definition: 'mine',
        updatedAt: DateTime.utc(2020),
      );

      final report = await import('cough,kaf,theirs');

      final row = await word('cough');
      expect(row.ipaUk, 'kɒf');
      expect(row.definition, 'mine');
      expect(row.updatedAt, DateTime.utc(2020));
      expect(report.unchanged, 1);
    });

    test('an existing word still joins the lists the file names', () async {
      await seedWord(db, id: 'w1', headword: 'cough', ipaUk: 'kɒf');

      await import('cough,,,Health');

      expect(await membership(), <String, Set<String>>{
        'Health': <String>{'cough'},
      });
    });

    test(
      'importing the same file twice changes nothing the second time',
      () async {
        const csv = 'cough,kɒf,ho,Health,a;b\nthrough,θruː,qua,Health';
        await import(csv);
        final before = await membership();

        final report = await import(csv);

        expect(report.added, 0);
        expect(report.filled, 0);
        expect(report.unchanged, 2);
        expect(report.listsCreated, 0);
        expect(await db.select(db.words).get(), hasLength(2));
        expect(await membership(), before);
      },
    );
  });

  group('preview', () {
    test('counts new and existing words and names new lists', () async {
      await seedWord(db, id: 'w1', headword: 'cough');
      await seedList(db, id: 'l1', name: 'Health');

      final result = await preview(
        'cough,,,health\nthrough,,,Travel,health\n,orphan\nTHROUGH',
      );

      expect(result.problem, isNull);
      expect(result.newWords, 1);
      expect(result.existingWords, 1);
      expect(result.skippedLines, 1);
      expect(result.newListNames, <String>['Travel']);
    });

    test('writes nothing', () async {
      await preview('cough,kɒf,ho,Health');

      expect(await db.select(db.words).get(), isEmpty);
      expect(await db.select(db.wordLists).get(), isEmpty);
    });

    test('a refused file says why', () async {
      expect((await preview(',,\n')).problem, WordImportProblem.noWords);
    });
  });

  test('a failure part-way leaves the library untouched', () async {
    // Any write failing must roll back every write before it.
    await db.customStatement(
      "CREATE TRIGGER boom BEFORE INSERT ON words WHEN NEW.headword = 'boom' "
      "BEGIN SELECT RAISE(ABORT, 'boom'); END",
    );

    final result = await repo.import(
      await preview('cough,kɒf,ho,Health\nboom'),
      accent: TtsLocale.enGb,
    );

    expect(result.isErr, isTrue);
    expect(await db.select(db.words).get(), isEmpty);
    expect(await db.select(db.wordLists).get(), isEmpty);
    expect(await db.select(db.studyCards).get(), isEmpty);
  });
}
