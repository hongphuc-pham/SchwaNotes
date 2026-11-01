import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Riverpod 3 moved `Override` out of the main barrel file.
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/app.dart';
import 'package:vocabnote/application/practice/game_contracts.dart';
import 'package:vocabnote/core/router/app_router.dart';
import 'package:vocabnote/core/router/routes.dart';
import 'package:vocabnote/data/composition_root.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/db/database_provider.dart';
import 'package:vocabnote/domain/entities/practice_session.dart';
import 'package:vocabnote/domain/repositories/practice_repository.dart';
import 'package:vocabnote/presentation/practice/games/flashcard/flashcard_game.dart';

import '../unit/data/db_fixtures.dart';

/// Fails whatever the runner asks of it, so starting a session throws.
class _BrokenPractice implements PracticeRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('the practice repository is broken');
}

/// The run screen's chrome (`docs/UI-UX.md` §4.7).
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

  /// Opens a quick test on the run screen and lets its session start.
  Future<void> openRun(
    WidgetTester tester, {
    PracticeRepository? practice,
  }) async {
    container = ProviderContainer(
      overrides: <Override>[
        appDatabaseProvider.overrideWithValue(db),
        ...repositoryOverrides(db, practiceRepository: practice),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const VocabNoteApp(),
      ),
    );
    await tester.pumpAndSettle();

    container
        .read(appRouterProvider)
        .go(
          Routes.practiceRunOf(FlashcardGame.gameId),
          extra: GameConfig(
            gameId: FlashcardGame.gameId,
            mode: PracticeMode.quickTest,
            selection: CardSelection.random,
            limit: 4,
            seed: 1,
          ),
        );
    // The session starts from inside the fake clock and nothing awaits it,
    // so it is given real time to finish before anything is asserted.
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('a session that cannot start says so, and offers another go', (
    tester,
  ) async {
    // Nothing awaits the start, so a throw used to leave the screen spinning
    // for ever with nothing to read and nothing to do (M7).
    await openRun(tester, practice: _BrokenPractice());

    expect(find.text("This session couldn't start"), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('the grades stay clear of the gesture bar', (tester) async {
    // Found on the emulator: at 200% text the grade buttons grew down into
    // the home indicator, because the body ignored the bottom inset.
    const inset = FakeViewPadding(bottom: 90);
    tester.view.padding = inset;
    tester.view.viewPadding = inset;
    addTearDown(tester.view.reset);
    await openRun(tester);

    final ratio = tester.view.devicePixelRatio;
    final screenBottom = tester.view.physicalSize.height / ratio;
    final safeBottom = screenBottom - inset.bottom / ratio;

    // The front's controls hold the same edge the grades do.
    final show = find.byKey(const ValueKey<String>('flashcard-show-answer'));
    expect(tester.getRect(show).bottom, lessThanOrEqualTo(safeBottom));

    await tester.tap(show);
    await tester.pumpAndSettle();

    final good = tester.getRect(
      find.byKey(const ValueKey<String>('grade-good')),
    );
    expect(good.bottom, lessThanOrEqualTo(safeBottom));
  });
}
