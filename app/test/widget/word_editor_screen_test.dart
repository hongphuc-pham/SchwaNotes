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
import 'package:vocabnote/domain/entities/word_list.dart';
import 'package:vocabnote/presentation/words/word_label_picker.dart';

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

    /// Opens the search for lists or tags from the word form.
    Future<void> openPicker(WidgetTester tester, String action) async {
      await scrollTo(tester, find.text(action));
      await tester.tap(find.text(action));
      await tester.pumpAndSettle();
    }

    Future<void> done(WidgetTester tester) async {
      await tester.tap(find.widgetWithText(FilledButton, 'Done'));
      await tester.pumpAndSettle();
    }

    testWidgets('the form shows only what is chosen, not every list', (
      tester,
    ) async {
      await openAddWord(tester);

      await scrollTo(tester, find.text('Add to a list'));

      expect(find.text('IELTS'), findsNothing);
      expect(find.text('Tricky'), findsNothing);
    });

    testWidgets('a word saved with a list chosen is in that list', (
      tester,
    ) async {
      await openAddWord(tester);

      await tester.enterText(find.byType(TextField).first, 'cough');
      await tester.pumpAndSettle();
      await openPicker(tester, 'Add to a list');
      await tester.tap(find.text('IELTS'));
      await tester.pumpAndSettle();
      await done(tester);
      await tester.tap(find.widgetWithText(TextButton, 'Save'));
      await settleAsync(tester);

      final members = await db.select(db.wordListItems).get();
      expect(members.map((m) => m.listId), <String>['l1']);
    });

    testWidgets('a word can go into two lists at once', (tester) async {
      await openAddWord(tester);

      await tester.enterText(find.byType(TextField).first, 'through');
      await tester.pumpAndSettle();
      await openPicker(tester, 'Add to a list');
      await tester.tap(find.text('IELTS'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tricky'));
      await tester.pumpAndSettle();
      await done(tester);
      await tester.tap(find.widgetWithText(TextButton, 'Save'));
      await settleAsync(tester);

      final members = await db.select(db.wordListItems).get();
      expect(members.map((m) => m.listId).toSet(), <String>{'l1', 'l2'});
    });

    testWidgets('searching narrows what is offered', (tester) async {
      await openAddWord(tester);
      await openPicker(tester, 'Add to a list');

      await tester.enterText(
        find.descendant(
          of: find.byType(WordLabelPicker),
          matching: find.byType(TextField),
        ),
        'tri',
      );
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(WordLabelPicker),
          matching: find.text('Tricky'),
        ),
        findsOneWidget,
      );
      expect(find.text('IELTS'), findsNothing);
    });

    testWidgets('a tag that does not exist can be created and chosen', (
      tester,
    ) async {
      await openAddWord(tester);

      await tester.enterText(find.byType(TextField).first, 'cough');
      await tester.pumpAndSettle();
      await openPicker(tester, 'Add a tag');
      await tester.enterText(
        find.descendant(
          of: find.byType(WordLabelPicker),
          matching: find.byType(TextField),
        ),
        'phrasal',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create tag "phrasal"'));
      await settleAsync(tester);
      await done(tester);

      expect(find.widgetWithText(InputChip, 'phrasal'), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'Save'));
      await settleAsync(tester);

      final tag = (await db.select(db.wordLists).get()).singleWhere(
        (row) => row.name == 'phrasal',
      );
      expect(tag.kind, ListKind.tag);
      final members = await db.select(db.wordListItems).get();
      expect(members.map((m) => m.listId), <String>[tag.id]);
    });

    testWidgets('a name that exists is not offered for creating', (
      tester,
    ) async {
      await seedList(db, id: 't1', name: 'tricky', kind: ListKind.tag);
      await openAddWord(tester);
      await openPicker(tester, 'Add a tag');

      await tester.enterText(
        find.descendant(
          of: find.byType(WordLabelPicker),
          matching: find.byType(TextField),
        ),
        'TRICKY',
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Create tag'), findsNothing);
    });
  });
}
