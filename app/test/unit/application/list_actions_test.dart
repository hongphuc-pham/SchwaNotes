import 'package:flutter_riverpod/flutter_riverpod.dart' hide AsyncResult;
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/application/lists/list_actions_controller.dart';
import 'package:vocabnote/application/lists/list_controller.dart';
import 'package:vocabnote/data/composition_root.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/db/database_provider.dart';
import 'package:vocabnote/domain/entities/word_list.dart';
import 'package:vocabnote/domain/value_objects/ipa_color_token.dart';

import '../data/db_fixtures.dart';

/// The write side of lists (F-042), against a real in-memory database.
///
/// The criterion that carries real risk is A2: **deleting a list must never
/// delete its words.** Everything else here is ordinary CRUD; that one is the
/// difference between losing a deck and losing a vocabulary.
void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() async {
    db = AppDatabase.memory();
    await db.customSelect('SELECT 1').get();
    container = ProviderContainer(
      overrides: <Override>[
        appDatabaseProvider.overrideWithValue(db),
        ...repositoryOverrides(db),
      ],
    );
  });

  tearDown(() async {
    // Container first: closing the database before disposing it deadlocks
    // teardown (M3's log, and it costs an hour to rediscover).
    container.dispose();
    await db.close();
  });

  ListActions actions() => container.read(listActionsProvider.notifier);

  Future<WordList> makeList(String name) async {
    final result = await actions().create(
      name: name,
      color: IpaColorToken.teal,
    );
    // Pin the type parameter: inside a Future<WordList> function Dart
    // otherwise infers R as Future<WordList> and the fold returns a future
    // of a future.
    return result.fold<WordList>((list) => list, (failure) => throw failure);
  }

  Future<List<WordListSummary>> summaries() {
    // `read(provider.future)` on its own is not enough: it registers no
    // listener, so Riverpod auto-disposes the provider while the stream is
    // still loading and the future completes with "disposed during loading
    // state". A screen holds a subscription for as long as it is on screen;
    // the test has to do the same for as long as it is reading.
    final sub = container.listen(listSummariesProvider, (_, _) {});
    return container.read(listSummariesProvider.future).whenComplete(sub.close);
  }

  group('create', () {
    test('appends to the end of the order', () async {
      await makeList('First');
      await makeList('Second');
      final third = await makeList('Third');

      final all = await summaries();
      expect(all.map((s) => s.list.name), <String>['First', 'Second', 'Third']);
      expect(
        third.sortOrder,
        greaterThan(all.first.list.sortOrder),
        reason: 'a new list goes last, not first',
      );
    });

    test('starts with no words and no due cards', () async {
      await makeList('Empty');
      final all = await summaries();
      expect(all.single.wordCount, 0);
      expect(all.single.dueCount, 0);
    });
  });

  group('rename and recolour', () {
    test('rename changes the name and nothing else', () async {
      final list = await makeList('Typo');
      final renamed = await actions().rename(list, 'Fixed');

      final after = renamed.fold((l) => l, (f) => throw f);
      expect(after.name, 'Fixed');
      expect(after.color, list.color, reason: 'recolouring is a separate verb');
      expect(after.sortOrder, list.sortOrder);
      expect(after.id, list.id);
    });

    test('recolour changes the colour and nothing else', () async {
      final list = await makeList('Vowels');
      final result = await actions().recolour(list, IpaColorToken.violet);

      final after = result.fold((l) => l, (f) => throw f);
      expect(after.color, IpaColorToken.violet);
      expect(after.name, 'Vowels');
    });

    test('a recolour survives a re-read, so it was actually written', () async {
      final list = await makeList('Vowels');
      await actions().recolour(list, IpaColorToken.coral);

      final all = await summaries();
      expect(all.single.list.color, IpaColorToken.coral);
    });
  });

  group('delete', () {
    test('🔴 A2: deleting a list leaves every word alive', () async {
      final list = await makeList('IELTS');
      await seedWord(db, id: 'w1', headword: 'cough', ipaUk: 'kɒf');
      await seedWord(db, id: 'w2', headword: 'through');
      await actions().setListsForWord(wordId: 'w1', listIds: <String>[list.id]);
      await actions().setListsForWord(wordId: 'w2', listIds: <String>[list.id]);

      await actions().delete(list.id);

      // The words are still there, and still not deleted.
      final w1 = await db.wordsDao.getById('w1');
      final w2 = await db.wordsDao.getById('w2');
      expect(w1, isNotNull);
      expect(w2, isNotNull);
      expect(w1!.deletedAt, isNull, reason: 'not even soft-deleted');
      expect(w2!.deletedAt, isNull);
      // ...and the list is gone.
      expect(await summaries(), isEmpty);
    });

    test('deleting one list leaves a word in its other lists', () async {
      // The membership rows are per (list, word), so deleting one list must
      // not strip a word out of another.
      final keep = await makeList('Keep');
      final drop = await makeList('Drop');
      await seedWord(db, id: 'w1', headword: 'cough');
      await actions().setListsForWord(
        wordId: 'w1',
        listIds: <String>[keep.id, drop.id],
      );

      await actions().delete(drop.id);

      final all = await summaries();
      expect(all.single.list.id, keep.id);
      expect(all.single.wordCount, 1, reason: 'still in the list that stayed');
    });
  });

  group('order', () {
    test('lists read A-Z, whatever the case and the order made', () async {
      await makeList('verbs');
      await makeList('Animals');
      await makeList('Food');

      final all = await summaries();
      expect(all.map((s) => s.list.name), <String>['Animals', 'Food', 'verbs']);
    });
  });

  group('membership', () {
    test('a word can be in many lists at once', () async {
      final a = await makeList('A');
      final b = await makeList('B');
      await seedWord(db, id: 'w1', headword: 'cough');

      await actions().setListsForWord(
        wordId: 'w1',
        listIds: <String>[a.id, b.id],
      );

      final all = await summaries();
      expect(all.every((s) => s.wordCount == 1), isTrue);
    });

    test('setting the lists replaces rather than adds', () async {
      final a = await makeList('A');
      final b = await makeList('B');
      await seedWord(db, id: 'w1', headword: 'cough');

      await actions().setListsForWord(wordId: 'w1', listIds: <String>[a.id]);
      await actions().setListsForWord(wordId: 'w1', listIds: <String>[b.id]);

      final all = await summaries();
      final byName = <String, int>{
        for (final s in all) s.list.name: s.wordCount,
      };
      expect(byName['A'], 0, reason: 'moved out of A');
      expect(byName['B'], 1);
    });

    test('removing every list leaves the word alone in no list', () async {
      final a = await makeList('A');
      await seedWord(db, id: 'w1', headword: 'cough');
      await actions().setListsForWord(wordId: 'w1', listIds: <String>[a.id]);

      await actions().setListsForWord(wordId: 'w1', listIds: <String>[]);

      expect(await db.wordsDao.getById('w1'), isNotNull);
      expect((await summaries()).single.wordCount, 0);
    });
  });
}
