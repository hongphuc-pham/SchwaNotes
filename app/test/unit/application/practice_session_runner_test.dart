import 'package:flutter_riverpod/flutter_riverpod.dart' hide AsyncResult;
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/application/practice/game_contracts.dart';
import 'package:vocabnote/application/practice/practice_session_controller.dart';
import 'package:vocabnote/application/practice/scheduler/review_schedule.dart';
import 'package:vocabnote/data/composition_root.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/db/database_provider.dart';
import 'package:vocabnote/domain/entities/practice_session.dart';
import 'package:vocabnote/domain/entities/study_card.dart';
import 'package:vocabnote/domain/repositories/practice_repository.dart';

import '../data/db_fixtures.dart';
import 'dummy_game.dart';

/// The session runner (`docs/GAMES.md` §3), against a real database.
///
/// The criterion this file exists for is 🔴 **A4: a quick test must provably
/// not change `study_cards`.** A schedule is built over weeks; damaging it with
/// a casual five-card test would be the worst bug this app could have, and it
/// would be invisible — the user would simply find their reviews wrong later.
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
    // Container first, or teardown deadlocks.
    container.dispose();
    await db.close();
  });

  PracticeSessionRunner runner() =>
      container.read(practiceSessionRunnerProvider.notifier);

  GameConfig configFor(
    PracticeMode mode, {
    int limit = 10,
    CardSelection selection = CardSelection.random,
  }) => GameConfig(
    gameId: DummyGame.gameId,
    mode: mode,
    selection: selection,
    limit: limit,
    seed: 1,
  );

  /// Seeds [count] words, each with a study card in [box] due yesterday.
  ///
  /// `seedWord` creates the study card itself, so this only has to say when it
  /// is due and which box it is in.
  Future<void> seedDue(int count, {int box = 3}) async {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    for (var i = 0; i < count; i++) {
      await seedWord(
        db,
        id: 'w$i',
        headword: 'word$i',
        dueAt: yesterday,
        box: box,
      );
    }
  }

  /// Every scheduling column, as a comparable snapshot.
  Future<List<String>> scheduleSnapshot() async {
    final rows = await db.select(db.studyCards).get()
      ..sort((a, b) => a.wordId.compareTo(b.wordId));
    return <String>[
      for (final row in rows)
        <Object?>[
          row.wordId,
          row.box,
          row.dueAt,
          row.intervalDays,
          row.easeFactor,
          row.repetitions,
          row.lapses,
          row.lastReviewedAt,
          row.lastResult,
          row.suspended,
        ].join('|'),
    ];
  }

  /// Answers every round of a running session.
  Future<void> playThrough(ReviewOutcome result) async {
    final game = DummyGame();
    var guard = 0;
    while (container.read(practiceSessionRunnerProvider)?.current != null) {
      await runner().answer(
        game,
        GameAnswer(result: result, elapsed: const Duration(seconds: 1)),
      );
      if (++guard > 200) fail('session did not end');
    }
  }

  group('🔴 A4 — a quick test does not change study_cards', () {
    test(
      'every scheduling column is identical after a full quick test',
      () async {
        await seedDue(5);
        final before = await scheduleSnapshot();

        final started = await runner().start(
          config: configFor(PracticeMode.quickTest),
          game: DummyGame(),
        );
        expect(started, isTrue);
        await playThrough(ReviewOutcome.good);

        expect(
          await scheduleSnapshot(),
          before,
          reason: 'a quick test must leave the schedule byte-identical',
        );
      },
    );

    test(
      'not even a wrong answer moves the schedule in a quick test',
      () async {
        await seedDue(5);
        final before = await scheduleSnapshot();

        await runner().start(
          config: configFor(PracticeMode.quickTest),
          game: DummyGame(),
        );
        await playThrough(ReviewOutcome.again);

        expect(await scheduleSnapshot(), before);
      },
    );

    test(
      'the answers are still recorded, because stats are not scheduling',
      () async {
        // F-062: "Does not change the review schedule; it records stats only."
        await seedDue(3);
        await runner().start(
          config: configFor(PracticeMode.quickTest),
          game: DummyGame(),
        );
        await playThrough(ReviewOutcome.good);

        final answers = await db.select(db.practiceAnswers).get();
        expect(answers, isNotEmpty);
      },
    );

    test(
      'the session row records that it does not affect scheduling',
      () async {
        await seedDue(3);
        await runner().start(
          config: configFor(PracticeMode.quickTest),
          game: DummyGame(),
        );

        final sessions = await db.select(db.practiceSessions).get();
        expect(sessions.single.affectsScheduling, isFalse);
      },
    );
  });

  group('A2 — daily review does move the schedule', () {
    test(
      'a good answer advances the box and pushes the due date out',
      () async {
        await seedDue(1);
        final before = (await db.select(db.studyCards).get()).single;

        await runner().start(
          config: configFor(PracticeMode.daily, selection: CardSelection.due),
          game: DummyGame(),
        );
        await playThrough(ReviewOutcome.good);

        final after = (await db.select(db.studyCards).get()).single;
        expect(after.box, before.box + 1);
        // `greaterThan` needs `<`, which DateTime does not define.
        expect(after.dueAt.isAfter(before.dueAt), isTrue);
        expect(after.repetitions, before.repetitions + 1);
      },
    );

    test('the session row records that it does affect scheduling', () async {
      await seedDue(2);
      await runner().start(
        config: configFor(PracticeMode.daily, selection: CardSelection.due),
        game: DummyGame(),
      );

      final sessions = await db.select(db.practiceSessions).get();
      expect(sessions.single.affectsScheduling, isTrue);
    });

    test("the user's own schedule is the one applied", () async {
      // The pace the user chose has to reach the database, not just the
      // scheduler's unit tests.
      await seedDue(1, box: 2);
      const custom = ReviewSchedule(<int>[0, 3, 6, 12, 20, 40, 90]);

      await runner().start(
        config: configFor(PracticeMode.daily, selection: CardSelection.due),
        game: DummyGame(),
        schedule: custom,
      );
      await playThrough(ReviewOutcome.good);

      // box 2 + good -> box 3, which this table says is 12 days.
      expect((await db.select(db.studyCards).get()).single.intervalDays, 12);
    });
  });

  group('an answer is recorded once, however fast the taps', () {
    test('a second answer while the first is saving is ignored', () async {
      // A double tap, or a swipe followed by a tap, reaches the runner twice
      // before the round has moved on. Both calls read the same round: two
      // answer rows, the card counted as missed twice so the score drops, and
      // the second call spending the repeat budget and dropping the repeat.
      await seedDue(3);
      await runner().start(
        config: configFor(PracticeMode.quickTest),
        game: DummyGame(),
      );
      final game = DummyGame();
      const again = GameAnswer(
        result: ReviewOutcome.again,
        elapsed: Duration(seconds: 1),
      );

      await Future.wait(<Future<void>>[
        runner().answer(game, again),
        runner().answer(game, again),
      ]);

      expect(await db.select(db.practiceAnswers).get(), hasLength(1));
      final state = container.read(practiceSessionRunnerProvider)!;
      expect(state.index, 1);
      expect(state.rounds, hasLength(4), reason: 'three cards plus a repeat');
    });

    test('answering resumes normally once the save has finished', () async {
      await seedDue(2);
      await runner().start(
        config: configFor(PracticeMode.quickTest),
        game: DummyGame(),
      );

      await playThrough(ReviewOutcome.good);

      expect(await db.select(db.practiceAnswers).get(), hasLength(2));
    });
  });

  group('one runner, two sessions', () {
    test('nothing missed last session carries into the next', () async {
      // "Practise again" starts the next session on the same runner. A card
      // missed last time must not appear in this summary, or lower its score.
      await seedDue(2);
      await runner().start(
        config: configFor(PracticeMode.quickTest),
        game: DummyGame(),
        againRepeats: 0,
      );
      await playThrough(ReviewOutcome.again);

      await runner().start(
        config: configFor(PracticeMode.quickTest),
        game: DummyGame(),
        againRepeats: 0,
      );
      await playThrough(ReviewOutcome.good);

      final summary = container.read(practiceSessionRunnerProvider)!.summary!;
      expect(summary.missed, isEmpty);
      expect(summary.correctRounds, summary.totalRounds);
    });
  });

  group('where an answer is recorded', () {
    test('at its position in the session, repeats included', () async {
      // A repeat is built by the game as a one-card session, so its own index
      // is 0. Recording that put every repeat at position 0 - ahead of the
      // round it repeats, in `answersForSession`'s order.
      await seedDue(2);
      await runner().start(
        config: configFor(PracticeMode.quickTest),
        game: DummyGame(),
      );
      await playThrough(ReviewOutcome.again);

      final positions = [
        for (final answer in await db.select(db.practiceAnswers).get())
          answer.roundIndex,
      ]..sort();
      expect(positions, <int>[
        0,
        1,
        2,
        3,
      ], reason: 'two cards, one repeat each');
    });
  });

  group('in-session repeats', () {
    test('an again card is asked again later in the same sitting', () async {
      await seedDue(3);

      await runner().start(
        config: configFor(PracticeMode.quickTest),
        game: DummyGame(),
      );
      final planned = container
          .read(practiceSessionRunnerProvider)!
          .rounds
          .length;
      await playThrough(ReviewOutcome.again);

      final summary = container.read(practiceSessionRunnerProvider)!.summary!;
      expect(
        summary.totalRounds,
        greaterThan(planned),
        reason: 'each failed card came back once',
      );
    });

    test('repeats are capped, so a hard card cannot make it endless', () async {
      // Two extra attempts, not the default one, so the cap is doing visible
      // work: without it, answering `again` for ever would never end.
      await seedDue(2);

      await runner().start(
        config: configFor(PracticeMode.quickTest),
        game: DummyGame(),
        againRepeats: 2,
      );
      await playThrough(ReviewOutcome.again);

      final summary = container.read(practiceSessionRunnerProvider)!.summary!;
      // Two cards, two extra attempts each.
      expect(summary.totalRounds, 6);
    });

    test('zero repeats disables it entirely', () async {
      await seedDue(3);

      await runner().start(
        config: configFor(PracticeMode.quickTest),
        game: DummyGame(),
        againRepeats: 0,
      );
      await playThrough(ReviewOutcome.again);

      expect(
        container.read(practiceSessionRunnerProvider)!.summary!.totalRounds,
        3,
      );
    });

    test(
      'a repeat writes nothing, so the schedule is still untouched',
      () async {
        // The feature is session-local by construction. Worth asserting: a
        // repeat that scheduled would multiply a lapse.
        await seedDue(2);
        final before = await scheduleSnapshot();

        await runner().start(
          config: configFor(PracticeMode.quickTest),
          game: DummyGame(),
          againRepeats: 2,
        );
        await playThrough(ReviewOutcome.again);

        expect(await scheduleSnapshot(), before);
      },
    );
  });

  group('the summary', () {
    test('counts what was right and lists what was not', () async {
      await seedDue(3);
      await runner().start(
        config: configFor(PracticeMode.quickTest),
        game: DummyGame(),
        againRepeats: 0,
      );
      await playThrough(ReviewOutcome.again);

      final summary = container.read(practiceSessionRunnerProvider)!.summary!;
      expect(summary.totalRounds, 3);
      expect(summary.correctRounds, 0);
      expect(summary.missed, hasLength(3));
    });

    test(
      'a word failed twice is one word worth another look, not two',
      () async {
        await seedDue(1);
        await runner().start(
          config: configFor(PracticeMode.quickTest),
          game: DummyGame(),
        );
        await playThrough(ReviewOutcome.again);

        final summary = container.read(practiceSessionRunnerProvider)!.summary!;
        expect(summary.missed, hasLength(1));
      },
    );
  });

  group('starting', () {
    test('says no when there is nothing to practise', () async {
      // The hub decides what to say: "no cards due" and "no words at all" need
      // different answers, so the runner only reports that it could not start.
      expect(
        await runner().start(
          config: configFor(PracticeMode.quickTest),
          game: DummyGame(),
        ),
        isFalse,
      );
    });

    test('a full-list quick test runs every word', () async {
      await seedDue(40);

      await runner().start(
        config: configFor(
          PracticeMode.quickTest,
          limit: PracticeRepository.everyCard,
        ),
        game: DummyGame(),
      );

      expect(container.read(practiceSessionRunnerProvider)!.rounds.length, 40);
    });
  });

  group('the interval label (UI-UX §4.7)', () {
    test('shows the nominal interval, not a jittered one', () async {
      // Found on a device: reading the label off `apply().dueAt` applied the
      // ±10% jitter and then truncated, so a 2-day interval displayed as "1d"
      // and *Good* and *Easy* both read the same. It also changed on every
      // rebuild.
      await seedDue(1, box: 0);
      await runner().start(
        config: configFor(PracticeMode.daily, selection: CardSelection.due),
        game: DummyGame(),
      );

      // box 0 -> good lands in box 1 (1 day), easy in box 2 (2 days).
      expect(runner().intervalLabelFor(ReviewOutcome.good), '1d');
      expect(runner().intervalLabelFor(ReviewOutcome.easy), '2d');
    });

    test('a lapse reads as the full relearn interval', () async {
      // Was "9m", because ten minutes minus 10% jitter rounds down.
      // `seedDue` defaults to box 3 - a mature card, which is the case that
      // matters: a lapse from box 3 must still say ten minutes.
      await seedDue(1);
      await runner().start(
        config: configFor(PracticeMode.daily, selection: CardSelection.due),
        game: DummyGame(),
      );

      expect(runner().intervalLabelFor(ReviewOutcome.again), '10m');
    });

    test('is stable across repeated reads', () async {
      await seedDue(1, box: 2);
      await runner().start(
        config: configFor(PracticeMode.daily, selection: CardSelection.due),
        game: DummyGame(),
      );

      final labels = <String?>{
        for (var i = 0; i < 10; i++)
          runner().intervalLabelFor(ReviewOutcome.good),
      };
      expect(labels, hasLength(1), reason: 'a jittered label flickers');
    });

    test("follows the user's own schedule", () async {
      await seedDue(1, box: 2);
      await runner().start(
        config: configFor(PracticeMode.daily, selection: CardSelection.due),
        game: DummyGame(),
        schedule: const ReviewSchedule(<int>[0, 3, 6, 12, 20, 40, 90]),
      );

      // box 2 + good -> box 3, which this table says is 12 days.
      expect(runner().intervalLabelFor(ReviewOutcome.good), '12d');
    });

    test('is absent in a quick test, where nothing is scheduled', () async {
      await seedDue(2);
      await runner().start(
        config: configFor(PracticeMode.quickTest),
        game: DummyGame(),
      );

      for (final outcome in ReviewOutcome.values) {
        expect(
          runner().intervalLabelFor(outcome),
          isNull,
          reason: outcome.name,
        );
      }
    });
  });
}
