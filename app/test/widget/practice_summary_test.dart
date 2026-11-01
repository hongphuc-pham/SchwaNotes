import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Riverpod 3 moved `Override` out of the main barrel file.
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/app.dart';
import 'package:vocabnote/application/practice/game_contracts.dart';
import 'package:vocabnote/application/practice/practice_session_controller.dart';
import 'package:vocabnote/core/router/app_router.dart';
import 'package:vocabnote/core/router/routes.dart';
import 'package:vocabnote/data/composition_root.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/db/database_provider.dart';
import 'package:vocabnote/domain/entities/practice_session.dart';
import 'package:vocabnote/domain/entities/study_card.dart';
import 'package:vocabnote/domain/repositories/practice_repository.dart';
import 'package:vocabnote/presentation/practice/games/flashcard/flashcard_game.dart';
import 'package:vocabnote/presentation/practice/practice_run_screen.dart';

import '../unit/data/db_fixtures.dart';

/// The session summary (`docs/UI-UX.md` §4.8, F-064).
///
/// Untested until M5's audit against UI-UX: the screen had only ever been
/// looked at on a device, which is how *Practise again* went missing.
void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUpAll(() => EditableText.debugDeterministicCursor = true);
  tearDownAll(() => EditableText.debugDeterministicCursor = false);

  setUp(() async {
    db = AppDatabase.memory();
    await db.customSelect('SELECT 1').get();
    for (var i = 0; i < 4; i++) {
      await seedWord(db, id: 'w$i', headword: 'word$i');
    }
  });

  tearDown(() => db.close());

  GameConfig quickTest() => GameConfig(
    gameId: FlashcardGame.gameId,
    mode: PracticeMode.quickTest,
    selection: CardSelection.random,
    limit: 4,
    seed: 1,
  );

  GameConfig daily() => GameConfig(
    gameId: FlashcardGame.gameId,
    mode: PracticeMode.daily,
    selection: CardSelection.due,
    limit: 20,
  );

  /// A container over the test database.
  ///
  /// The runner is auto-disposed, so it is held open as the run screen would
  /// hold it - otherwise a session is gone before its summary opens.
  void openContainer() {
    container = ProviderContainer(
      overrides: <Override>[
        appDatabaseProvider.overrideWithValue(db),
        ...repositoryOverrides(db),
      ],
    );
    addTearDown(container.dispose);
    final keepAlive = container.listen(
      practiceSessionRunnerProvider,
      (_, _) {},
    );
    addTearDown(keepAlive.close);
  }

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const VocabNoteApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Plays a whole session through the runner, then opens its summary.
  ///
  /// The session is played on real async (`pumpAndSettle` does not wait for a
  /// database write) and **before the app is pumped**. Played after, a daily
  /// review's writes to `study_cards` wake the mounted screens' watch queries
  /// inside the fake clock, where they never run - and the next write waits
  /// behind them for ever, with no error and no timeout.
  Future<void> finishSession(
    WidgetTester tester,
    GameConfig config,
    List<ReviewOutcome> answers,
  ) async {
    openContainer();
    await tester.runAsync(() async {
      final runner = container.read(practiceSessionRunnerProvider.notifier);
      const game = FlashcardGame();
      await runner.start(config: config, game: game, againRepeats: 0);
      for (final result in answers) {
        await runner.answer(
          game,
          GameAnswer(result: result, elapsed: const Duration(seconds: 2)),
        );
      }
    });
    await pumpApp(tester);

    final summary = container.read(practiceSessionRunnerProvider)!.summary!;
    container
        .read(appRouterProvider)
        .go(Routes.practiceSummaryOf(summary.sessionId));
    await tester.pumpAndSettle();
  }

  /// Taps *Practise again* and returns the config the run screen received.
  ///
  /// The run screen starts the next session as it opens. That work is fired
  /// from inside the fake clock and nothing awaits it, so it is given real time
  /// to finish - as `settleAsync` does in the other screen tests. Left pending,
  /// it holds a query open and closing the database at teardown never returns.
  Future<GameConfig> practiseAgain(WidgetTester tester) async {
    await tester.tap(find.text('Practise again'));
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();
    return tester
        .widget<PracticeRunScreen>(find.byType(PracticeRunScreen))
        .config!;
  }

  testWidgets('shows the score and the words worth another look', (
    tester,
  ) async {
    await finishSession(tester, quickTest(), <ReviewOutcome>[
      ReviewOutcome.again,
      ReviewOutcome.good,
      ReviewOutcome.good,
      ReviewOutcome.good,
    ]);

    expect(find.text('Nice work - 3 of 4'), findsOneWidget);
    expect(find.text('Worth another look'), findsOneWidget);
    expect(find.byType(ActionChip), findsOneWidget);
  });

  testWidgets('a clean session lists nothing to look at again', (tester) async {
    await finishSession(
      tester,
      quickTest(),
      List<ReviewOutcome>.filled(4, ReviewOutcome.good),
    );

    expect(find.text('Nice work - 4 of 4'), findsOneWidget);
    expect(find.text('Worth another look'), findsNothing);
  });

  testWidgets('a skipped card is reported apart from the score', (
    tester,
  ) async {
    await finishSession(tester, quickTest(), <ReviewOutcome>[
      ReviewOutcome.good,
      ReviewOutcome.skipped,
      ReviewOutcome.good,
      ReviewOutcome.skipped,
    ]);

    expect(find.text('Nice work - 2 of 2'), findsOneWidget);
    expect(find.text('2 cards skipped'), findsOneWidget);
  });

  testWidgets('no skips, no line about skips', (tester) async {
    await finishSession(
      tester,
      quickTest(),
      List<ReviewOutcome>.filled(4, ReviewOutcome.good),
    );

    expect(find.textContaining('skipped'), findsNothing);
  });

  testWidgets('skipping everything is not praised with a score of nothing', (
    tester,
  ) async {
    await finishSession(
      tester,
      quickTest(),
      List<ReviewOutcome>.filled(4, ReviewOutcome.skipped),
    );

    expect(find.text('Nothing graded this time'), findsOneWidget);
    expect(find.textContaining('Nice work'), findsNothing);
    expect(find.text('4 cards skipped'), findsOneWidget);
  });

  group('Practise again (UI-UX §4.8)', () {
    testWidgets('after a quick test: the same choices, a fresh sample', (
      tester,
    ) async {
      final played = quickTest();
      await finishSession(
        tester,
        played,
        List<ReviewOutcome>.filled(4, ReviewOutcome.good),
      );

      final config = await practiseAgain(tester);

      expect(config.mode, PracticeMode.quickTest);
      expect(config.selection, CardSelection.random);
      expect(config.source, CardSourceKind.all);
      expect(config.limit, 4);
      expect(config.seed, isNotNull);
      expect(
        config.seed,
        isNot(played.seed),
        reason: 'again means more practice, not a replay of the same words',
      );
    });

    testWidgets("after a daily review: today's review again", (tester) async {
      await finishSession(
        tester,
        daily(),
        List<ReviewOutcome>.filled(4, ReviewOutcome.good),
      );

      final config = await practiseAgain(tester);

      expect(config.mode, PracticeMode.daily);
      expect(config.selection, CardSelection.due);
      expect(config.limit, 20);
    });
  });

  testWidgets('with no session in memory it says so, and offers no replay', (
    tester,
  ) async {
    // Reached by URL, or after the runner was disposed: there are no choices
    // to repeat, so the only way on is Done.
    openContainer();
    await pumpApp(tester);
    container.read(appRouterProvider).go(Routes.practiceSummaryOf('gone'));
    await tester.pumpAndSettle();

    expect(find.text('That session has finished'), findsOneWidget);
    expect(find.text('Practise again'), findsNothing);
  });
}
