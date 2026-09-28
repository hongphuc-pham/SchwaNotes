import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Riverpod 3 moved `Override` out of the main barrel file.
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/app.dart';
import 'package:vocabnote/application/words/word_list_controller.dart';
import 'package:vocabnote/data/composition_root.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/db/database_provider.dart';

import '../unit/data/db_fixtures.dart';

/// The practice hub (`docs/UI-UX.md` §4.6, F-060).
void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUpAll(() {
    // The quick-test sheet has no text field, but the hub is reached through
    // the shell and the words tab does. Cheap insurance either way.
    EditableText.debugDeterministicCursor = true;
  });

  tearDownAll(() {
    EditableText.debugDeterministicCursor = false;
  });

  Future<void> openHub(
    WidgetTester tester, {
    List<Override> extra = const <Override>[],
  }) async {
    container = ProviderContainer(
      overrides: <Override>[
        appDatabaseProvider.overrideWithValue(db),
        ...repositoryOverrides(db),
        ...extra,
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
    await tester.tap(find.text('Practice'));
    await tester.pumpAndSettle();
  }

  setUp(() async {
    db = AppDatabase.memory();
    await db.customSelect('SELECT 1').get();
  });

  tearDown(() => db.close());

  group('with no words', () {
    testWidgets('says what to do rather than showing an empty screen', (
      tester,
    ) async {
      await openHub(tester);

      expect(find.text('Nothing to practise yet'), findsOneWidget);
      expect(find.text('Add word'), findsWidgets);
    });
  });

  group('when the library cannot be counted', () {
    testWidgets('says so, instead of "add your first word"', (tester) async {
      // The count used to be read as `.value ?? 0`, so a failed read looked
      // exactly like an empty library and told someone with 500 words to add
      // their first one (M7).
      await openHub(
        tester,
        extra: <Override>[
          totalWordCountProvider.overrideWith(
            (ref) => Stream<int>.error(StateError('no reading it')),
          ),
        ],
      );

      expect(find.text("Couldn't read your words"), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
      expect(find.text('Nothing to practise yet'), findsNothing);
    });
  });

  // M8, found on the emulator: the due count froze when the hub started
  // watching. A card that comes due later without a database write - the usual
  // way, ten minutes after *Again* - never showed, and Daily review stayed
  // disabled until the app restarted.
  group('the due count', () {
    testWidgets('catches up when the app comes back to the foreground', (
      tester,
    ) async {
      // Far enough ahead that opening the app - which takes real seconds in a
      // widget test - is over before the cards come due.
      final soon = DateTime.now().add(const Duration(seconds: 6));
      for (var i = 0; i < 4; i++) {
        await seedWord(db, id: 'w$i', headword: 'word$i', dueAt: soon);
      }

      await openHub(tester);
      expect(
        find.text('Daily review (0 due)'),
        findsOneWidget,
        reason: 'the premise: nothing is due yet when the hub first shows',
      );

      // Real time, outside the fake clock, until the cards really are due.
      final wait =
          soon.difference(DateTime.now()) + const Duration(milliseconds: 500);
      await tester.runAsync(() => Future<void>.delayed(wait));
      tester.binding
        ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
        ..handleAppLifecycleStateChanged(AppLifecycleState.hidden)
        ..handleAppLifecycleStateChanged(AppLifecycleState.paused)
        ..handleAppLifecycleStateChanged(AppLifecycleState.hidden)
        ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
        ..handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Daily review (4 due)'), findsOneWidget);
    });
  });

  group('below the minimum', () {
    setUp(() async {
      // The flashcard game needs four.
      for (var i = 0; i < 2; i++) {
        await seedWord(db, id: 'w$i', headword: 'word$i');
      }
    });

    testWidgets('the game still gets a card, saying how many more are needed', (
      tester,
    ) async {
      // F-060: a game the user cannot start yet needs a card saying why.
      // Hiding it would leave the user wondering whether practice exists.
      await openHub(tester);

      expect(find.text('Flashcards'), findsOneWidget);
      expect(find.textContaining('Add 2 more words'), findsOneWidget);
    });

    testWidgets('offers no way to start it', (tester) async {
      await openHub(tester);

      expect(find.text('Quick test'), findsNothing);
    });
  });

  group('with enough words', () {
    setUp(() async {
      for (var i = 0; i < 6; i++) {
        await seedWord(db, id: 'w$i', headword: 'word$i');
      }
    });

    testWidgets('offers the game', (tester) async {
      await openHub(tester);

      expect(find.text('Flashcards'), findsOneWidget);
      expect(find.text('Quick test'), findsOneWidget);
    });

    testWidgets('nothing due reads as an offer, never a scolding', (
      tester,
    ) async {
      // UI-UX §4.6: "encouraging copy, never a warning". The seeded cards are
      // due today, so this test pushes them into the future first.
      await db
          .update(db.studyCards)
          .write(
            StudyCardsCompanion(
              dueAt: Value(DateTime.now().add(const Duration(days: 3))),
            ),
          );
      await openHub(tester);

      expect(find.textContaining('Nothing due right now'), findsOneWidget);
      expect(find.textContaining('behind'), findsNothing);
      expect(find.textContaining('missed'), findsNothing);
    });

    testWidgets('the daily button is disabled when nothing is due', (
      tester,
    ) async {
      await db
          .update(db.studyCards)
          .write(
            StudyCardsCompanion(
              dueAt: Value(DateTime.now().add(const Duration(days: 3))),
            ),
          );
      await openHub(tester);

      final button = tester.widget<FilledButton>(
        find
            .ancestor(
              of: find.textContaining('Daily review'),
              matching: find.byType(FilledButton),
            )
            .first,
      );
      expect(button.onPressed, isNull);
    });

    testWidgets("the goal ring counts today's words and the run of days", (
      tester,
    ) async {
      // F-065, UI-UX §4.6: "12 of 20 today".
      await seedSession(db, id: 's1');
      final now = DateTime.now();
      for (var i = 0; i < 3; i++) {
        await seedAnswer(
          db,
          id: 'a$i',
          sessionId: 's1',
          wordId: 'w$i',
          answeredAt: now,
        );
      }
      await openHub(tester);

      expect(find.text('3 of 20 today'), findsOneWidget);
      expect(find.text('1 day in a row'), findsOneWidget);
    });

    testWidgets('with nothing practised yet it encourages, never warns', (
      tester,
    ) async {
      // RULES §6: no loss aversion. There is no streak to lose, and it says
      // so by not mentioning one.
      await openHub(tester);

      expect(find.text('0 of 20 today'), findsOneWidget);
      expect(find.text('Any card you practise today counts'), findsOneWidget);
      expect(find.textContaining('lost'), findsNothing);
      expect(find.textContaining('streak'), findsNothing);
    });

    testWidgets('the ring reads as one sentence to a screen reader', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await openHub(tester);

      expect(
        find.bySemanticsLabel(
          RegExp('0 of 20 today\nAny card you practise today counts'),
        ),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('the daily button counts what is actually due', (tester) async {
      await openHub(tester);
      expect(find.text('Daily review (6 due)'), findsOneWidget);
    });

    testWidgets('at 200% text on a 320dp phone the buttons stack, not wrap', (
      tester,
    ) async {
      // Found on the emulator: side by side, "Daily review (0 due)" wrapped
      // onto three lines and spilled out of its pill.
      tester.view.physicalSize = const Size(960, 2142);
      tester.view.devicePixelRatio = 3;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await openHub(tester);

      final daily = tester.getRect(
        find.ancestor(
          of: find.textContaining('Daily review'),
          matching: find.byType(FilledButton),
        ),
      );
      final quick = tester.getRect(
        find.ancestor(
          of: find.text('Quick test'),
          matching: find.byType(OutlinedButton),
        ),
      );
      expect(quick.top, greaterThan(daily.bottom - 0.5), reason: 'stacked');
      expect(quick.width, closeTo(daily.width, 0.5));
    });

    testWidgets('the quick-test sheet names the cap out loud', (tester) async {
      // The user picking "All" from a 5000-word library deserves to know they
      // are getting 30, rather than being silently trimmed.
      await openHub(tester);

      await tester.tap(find.text('Quick test'));
      await tester.pumpAndSettle();

      expect(find.text('All (max 30)'), findsOneWidget);
      expect(find.text('Start'), findsOneWidget);
    });

    testWidgets('the sheet offers every source and prompt side', (
      tester,
    ) async {
      await openHub(tester);
      await tester.tap(find.text('Quick test'));
      await tester.pumpAndSettle();

      for (final label in <String>[
        'All',
        'Favourites',
        'The word',
        'The sounds',
        'The meaning',
      ]) {
        expect(find.text(label), findsWidgets, reason: label);
      }
    });
  });
}
