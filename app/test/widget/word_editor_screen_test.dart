import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Riverpod 3 moved `Override` out of the main barrel file.
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/app.dart';
import 'package:vocabnote/core/router/app_router.dart';
import 'package:vocabnote/core/router/routes.dart';
import 'package:vocabnote/data/composition_root.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/db/database_provider.dart';

import '../unit/data/db_fixtures.dart';

/// The add/edit word screen (F-001–F-003, F-042 membership).
///
/// **This screen had no widget test from M2 until M4.** `pumpAndSettle` timed
/// out on it and PROGRESS §6 recorded only that "something animates
/// indefinitely on open". The something is a **blinking text cursor**: the
/// headword field autofocuses, the caret animation never ends, and
/// `pumpAndSettle` waits for it until it gives up. `debugDeterministicCursor`
/// freezes the caret and the screen becomes ordinary to test.
///
/// Two milestones of untested code behind one line of test setup, which is
/// also why M3 shipped two bugs on this screen that 348 passing tests said
/// nothing about (PROGRESS §6).
void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUpAll(() {
    EditableText.debugDeterministicCursor = true;
  });

  tearDownAll(() {
    EditableText.debugDeterministicCursor = false;
  });

  Future<void> settleAsync(WidgetTester tester) async {
    // `pumpAndSettle` drives frames; a database write has no frame waiting on
    // it. Step outside the fake clock so the write can land.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();
  }

  /// Brings a widget into view. The form is a `ListView`, so anything below
  /// the fold has not been built yet and no finder can see it.
  Future<void> scrollTo(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      120,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
  }

  Future<void> openAddWord(WidgetTester tester) async {
    container = ProviderContainer(
      overrides: <Override>[
        appDatabaseProvider.overrideWithValue(db),
        ...repositoryOverrides(db),
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
    await tester.tap(find.widgetWithText(FloatingActionButton, 'Add word'));
    await tester.pumpAndSettle();
  }

  setUp(() async {
    db = AppDatabase.memory();
    await db.customSelect('SELECT 1').get();
  });

  tearDown(() => db.close());

  testWidgets('the screen settles at all, which it did not until M4', (
    tester,
  ) async {
    // The regression test for the bug this file exists because of. If the
    // caret animation comes back, this times out rather than failing, so the
    // assertion below is really just proof we got here.
    await openAddWord(tester);
    expect(find.byType(TextField), findsWidgets);
  });

  testWidgets('saving a word writes it', (tester) async {
    await openAddWord(tester);

    await tester.enterText(find.byType(TextField).first, 'cough');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await settleAsync(tester);

    final rows = await db.select(db.words).get();
    expect(rows.map((r) => r.headword), <String>['cough']);
  });

  // M8, found on the emulator: accepting a dictionary's "preposition" for
  // "about" lit none of the five chips, though that is the value that would
  // be saved - it looked as if the suggestion had not been taken.
  testWidgets('a part of speech outside the five still shows, selected', (
    tester,
  ) async {
    await seedWord(db, id: 'w1', headword: 'about');
    await db.customStatement(
      "UPDATE words SET part_of_speech = 'preposition' WHERE id = 'w1'",
    );
    container = ProviderContainer(
      overrides: <Override>[
        appDatabaseProvider.overrideWithValue(db),
        ...repositoryOverrides(db),
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
    unawaited(container.read(appRouterProvider).push(Routes.wordEditOf('w1')));
    // Editing an existing word reads it from the database, with a spinner
    // turning meanwhile - so pumpAndSettle never settles. Let the read land in
    // real time, then draw the loaded form.
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();
    }

    final preposition = find.widgetWithText(ChoiceChip, 'preposition');
    await scrollTo(tester, preposition);
    expect(tester.widget<ChoiceChip>(preposition).selected, isTrue);
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'other'))
          .selected,
      isFalse,
      reason: 'it is shown as what it is, not folded into "other"',
    );
  });

  group('list membership (F-042, A4)', () {
    setUp(() async {
      await seedList(db, id: 'l1', name: 'IELTS');
      await seedList(db, id: 'l2', name: 'Tricky');
    });

    testWidgets('offers a chip per list', (tester) async {
      await openAddWord(tester);

      await scrollTo(tester, find.widgetWithText(FilterChip, 'IELTS'));

      expect(find.widgetWithText(FilterChip, 'IELTS'), findsOneWidget);
      expect(find.widgetWithText(FilterChip, 'Tricky'), findsOneWidget);
    });

    testWidgets('a word saved with a list selected is in that list', (
      tester,
    ) async {
      await openAddWord(tester);

      await tester.enterText(find.byType(TextField).first, 'cough');
      await tester.pumpAndSettle();
      await scrollTo(tester, find.widgetWithText(FilterChip, 'IELTS'));
      await tester.tap(find.widgetWithText(FilterChip, 'IELTS'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Save'));
      await settleAsync(tester);

      final members = await db.select(db.wordListItems).get();
      expect(members.map((m) => m.listId), <String>['l1']);
    });

    testWidgets('a word can go into two lists at once', (tester) async {
      await openAddWord(tester);

      await tester.enterText(find.byType(TextField).first, 'through');
      await tester.pumpAndSettle();
      await scrollTo(tester, find.widgetWithText(FilterChip, 'IELTS'));
      await tester.tap(find.widgetWithText(FilterChip, 'IELTS'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilterChip, 'Tricky'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Save'));
      await settleAsync(tester);

      final members = await db.select(db.wordListItems).get();
      expect(members.map((m) => m.listId).toSet(), <String>{'l1', 'l2'});
    });
  });
}
