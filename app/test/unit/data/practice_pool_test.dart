import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/repositories/practice_repository_impl.dart';
import 'package:vocabnote/domain/entities/practice_session.dart';
import 'package:vocabnote/domain/repositories/practice_repository.dart';

import 'db_fixtures.dart';

/// The card pools (`docs/GAMES.md` §1 and §4), against a real database.
///
/// Every other 30-cap test goes through `GameConfig`, which clamps first — so
/// these are the only tests proving the query clamps on its own. GAMES §4 asks
/// for both, so that neither layer is the only thing between a user and a
/// 500-card session.
void main() {
  late AppDatabase db;
  late PracticeRepositoryImpl repository;

  // A day after the fixtures' timestamps, so every seeded card is due.
  final now = testNow.add(const Duration(days: 1));

  setUp(() {
    db = AppDatabase.memory();
    repository = PracticeRepositoryImpl(db, now: () => now);
  });

  tearDown(() => db.close());

  /// The word ids of a pool, in the order the pool returned them.
  Future<List<String>> pool({
    CardSelection selection = CardSelection.random,
    PracticeMode mode = PracticeMode.quickTest,
    int limit = 10,
    CardSourceKind source = CardSourceKind.all,
    String? sourceId,
    int? seed,
  }) async {
    final result = await repository.loadPool(
      selection: selection,
      mode: mode,
      limit: limit,
      source: source,
      sourceId: sourceId,
      seed: seed,
    );
    final cards = result.valueOrNull;
    if (cards == null) fail('loadPool failed: $result');
    return cards.map((card) => card.word.id).toList();
  }

  Future<void> patchCard(String wordId, StudyCardsCompanion patch) =>
      (db.update(
        db.studyCards,
      )..where((c) => c.wordId.equals(wordId))).write(patch);

  // M8, found on the emulator: "Daily review (2 due)" over a four-card round.
  // The count took its "now" once, when it started watching; a card added
  // afterwards - due at once - was never counted. Real time here, because the
  // defect was about the clock.
  group('the due count', () {
    test('counts a card added after it started watching', () async {
      final counts = <int>[];
      final subscription = db.practiceDao.watchDueCount().listen(counts.add);
      addTearDown(subscription.cancel);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(counts, isNotEmpty, reason: 'the stream answered at all');
      expect(counts.last, 0);

      await seedWord(db, id: 'late', headword: 'late', dueAt: DateTime.now());
      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(counts.last, 1);
    });
  });

  group('the 30 cap holds at the query, not only in GameConfig', () {
    setUp(() => seedManyWords(db, 500));

    for (final selection in CardSelection.values) {
      test(
        'a quick test by ${selection.name} asking for 500 gets 30',
        () async {
          expect(
            await pool(selection: selection, limit: 500, seed: 1),
            hasLength(PracticeRepository.quickTestMaxCards),
          );
        },
      );
    }

    test('a daily review is capped by the goal, not by 30', () async {
      expect(
        await pool(
          selection: CardSelection.due,
          mode: PracticeMode.daily,
          limit: 50,
        ),
        hasLength(50),
      );
    });
  });

  group('a stored seed replays the same quick test (F-062)', () {
    setUp(() => seedManyWords(db, 500));

    test('the same seed picks the same cards, in the same order', () async {
      final first = await pool(limit: 30, seed: 42);
      expect(await pool(limit: 30, seed: 42), first);
    });

    test(
      'a different seed picks a different sample, not a reordering',
      () async {
        // 30 of 500: two seeds agreeing on every card would mean the seed only
        // shuffles, and the sample itself is still unrepeatable.
        final one = (await pool(limit: 30, seed: 1)).toSet();
        final two = (await pool(limit: 30, seed: 2)).toSet();
        expect(one, isNot(two));
      },
    );
  });

  group('sources', () {
    setUp(() async {
      await seedWord(db, id: 'fav', headword: 'fav', isFavourite: true);
      await seedWord(db, id: 'plain', headword: 'plain');
      await seedWord(db, id: 'member', headword: 'member');
      await seedWord(
        db,
        id: 'archived',
        headword: 'archived',
        isFavourite: true,
        isArchived: true,
      );
      await seedWord(db, id: 'deleted', headword: 'deleted', isFavourite: true);
      await (db.update(db.words)..where((w) => w.id.equals('deleted'))).write(
        WordsCompanion(deletedAt: Value(testNow)),
      );
      await seedList(db, id: 'travel', name: 'Travel');
      await seedMembership(db, listId: 'travel', wordId: 'member');
      await seedMembership(db, listId: 'travel', wordId: 'archived');
    });

    for (final selection in CardSelection.values) {
      group(selection.name, () {
        test('all words means every live word', () async {
          expect(
            await pool(selection: selection, seed: 1),
            unorderedEquals(<String>['fav', 'plain', 'member']),
          );
        });

        test('favourites means starred, live words only', () async {
          expect(
            await pool(
              selection: selection,
              source: CardSourceKind.favourites,
              seed: 1,
            ),
            <String>['fav'],
          );
        });

        test('a list means its live members only', () async {
          expect(
            await pool(
              selection: selection,
              source: CardSourceKind.list,
              sourceId: 'travel',
              seed: 1,
            ),
            <String>['member'],
          );
        });
      });
    }

    test('a list source with no list id is empty, not the library', () async {
      expect(await pool(source: CardSourceKind.list, seed: 1), isEmpty);
    });
  });

  group('daily review: due, then random (F-061)', () {
    test('only due, unsuspended cards, soonest first', () async {
      await seedWord(
        db,
        id: 'later',
        headword: 'later',
        dueAt: now.subtract(const Duration(hours: 1)),
      );
      await seedWord(
        db,
        id: 'sooner',
        headword: 'sooner',
        dueAt: now.subtract(const Duration(days: 3)),
      );
      await seedWord(
        db,
        id: 'future',
        headword: 'future',
        dueAt: now.add(const Duration(hours: 1)),
      );
      await seedWord(
        db,
        id: 'suspended',
        headword: 'suspended',
        dueAt: now.subtract(const Duration(days: 9)),
      );
      await patchCard(
        'suspended',
        const StudyCardsCompanion(suspended: Value(true)),
      );

      expect(
        await pool(
          selection: CardSelection.due,
          mode: PracticeMode.daily,
          limit: 20,
        ),
        <String>['sooner', 'later'],
      );
    });

    test(
      'cards due at the same moment do not always come in one order',
      () async {
        for (var i = 0; i < 20; i++) {
          await seedWord(db, id: 'w$i', headword: 'word$i', dueAt: testNow);
        }

        final orders = <String>{
          for (var i = 0; i < 5; i++)
            (await pool(
              selection: CardSelection.due,
              mode: PracticeMode.daily,
              limit: 20,
            )).join(','),
        };

        // Without a tiebreak a batch of words added together is practised in
        // the same order every day. Five identical orders of twenty tied cards
        // by chance is 1 in (20!)^4.
        expect(orders.length, greaterThan(1));
      },
    );

    test('a seed does not reorder a daily review', () async {
      final expected = <String>[for (var i = 0; i < 10; i++) 'w$i'];
      for (var i = 0; i < 10; i++) {
        await seedWord(
          db,
          id: 'w$i',
          headword: 'word$i',
          dueAt: testNow.add(Duration(minutes: i)),
        );
      }

      expect(
        await pool(
          selection: CardSelection.due,
          mode: PracticeMode.daily,
          limit: 20,
          seed: 7,
        ),
        expected,
      );
    });
  });

  test("a card carries its own highlights, and no other word's", () async {
    // The back of a flashcard shows the user's highlights (UI-UX §4.7), and a
    // running game may not query, so they travel with the pool.
    await seedWord(db, id: 'a', headword: 'a', ipaUk: 'kɒf');
    await seedWord(db, id: 'b', headword: 'b', ipaUk: 'bɪt');
    await seedHighlight(db, id: 'h1', wordId: 'a');
    await seedHighlight(db, id: 'h2', wordId: 'a', start: 2, end: 3);
    await seedHighlight(db, id: 'h3', wordId: 'b');

    final result = await repository.loadPool(
      selection: CardSelection.newest,
      mode: PracticeMode.quickTest,
      limit: 10,
    );
    final byId = {for (final card in result.valueOrNull!) card.word.id: card};

    expect(byId['a']!.highlights, hasLength(2));
    expect(byId['b']!.highlights, hasLength(1));
  });

  test('weakest: lowest box first, then most lapses', () async {
    await seedWord(db, id: 'box2', headword: 'box2', box: 2);
    await seedWord(db, id: 'box0-one-lapse', headword: 'a');
    await seedWord(db, id: 'box0-four-lapses', headword: 'b');
    await seedWord(db, id: 'box1', headword: 'box1', box: 1);
    await patchCard(
      'box0-one-lapse',
      const StudyCardsCompanion(lapses: Value(1)),
    );
    await patchCard(
      'box0-four-lapses',
      const StudyCardsCompanion(lapses: Value(4)),
    );

    expect(await pool(selection: CardSelection.weakest), <String>[
      'box0-four-lapses',
      'box0-one-lapse',
      'box1',
      'box2',
    ]);
  });

  test('newest: most recently added first', () async {
    await seedWord(db, id: 'old', headword: 'old', createdAt: testNow);
    await seedWord(
      db,
      id: 'new',
      headword: 'new',
      createdAt: testNow.add(const Duration(hours: 2)),
    );
    await seedWord(
      db,
      id: 'mid',
      headword: 'mid',
      createdAt: testNow.add(const Duration(hours: 1)),
    );

    expect(await pool(selection: CardSelection.newest), <String>[
      'new',
      'mid',
      'old',
    ]);
  });
}
