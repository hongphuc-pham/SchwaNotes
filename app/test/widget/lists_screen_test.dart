import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Riverpod 3 moved `Override` out of the main barrel file.
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/app.dart';
import 'package:vocabnote/data/composition_root.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/db/database_provider.dart';
import 'package:vocabnote/domain/entities/word_list.dart';
import 'package:vocabnote/presentation/common/empty_state.dart';

import '../unit/application/fake_speech_service.dart';
import '../unit/data/db_fixtures.dart';

/// The Lists tab against a real (in-memory) database (F-042, UI-UX §4.5).
///
/// Drives the real app through the real router, so what is asserted here is
/// what a user would see.
void main() {
  late AppDatabase db;
  late ProviderContainer container;

  Future<void> pumpLists(WidgetTester tester) async {
    container = ProviderContainer(
      overrides: <Override>[
        appDatabaseProvider.overrideWithValue(db),
        ...repositoryOverrides(db, speechService: FakeSpeechService()),
      ],
    );
    // Container before database, or teardown deadlocks.
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const VocabNoteApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lists'));
    await tester.pumpAndSettle();
  }

  setUpAll(() {
    // The name field autofocuses, and a blinking text cursor is an animation
    // that never ends - so `pumpAndSettle` waits for it until it times out,
    // and the failure is a hang with no message. This freezes the cursor.
    //
    // Strongly suspected to be the same thing that has made the word editor
    // screen untestable since M2 (PROGRESS §6): it autofocuses too.
    EditableText.debugDeterministicCursor = true;
  });

  tearDownAll(() {
    EditableText.debugDeterministicCursor = false;
  });

  /// Lets real async work finish, then rebuilds.
  ///
  /// The screen fires its writes and does not await them, so `pumpAndSettle`
  /// alone returns before the database has been touched - it drives frames,
  /// and nothing has scheduled a frame to wait for. `runAsync` steps outside
  /// the fake clock so the write can actually complete.
  Future<void> settleAsync(WidgetTester tester) async {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();
  }

  setUp(() async {
    db = AppDatabase.memory();
    await db.customSelect('SELECT 1').get();
  });

  tearDown(() => db.close());

  testWidgets('at 200% text on 320dp a card holds its name and counts', (
    tester,
  ) async {
    // Found on the emulator: two fixed-shape columns left a card 146dp wide,
    // so "Travel" broke into "Tra / vel" beside the actions button and the
    // word count spilled 67px out of the card.
    await seedList(db, id: 'l1', name: 'Travel phrases');
    await seedWord(db, id: 'w1', headword: 'passport');
    await seedMembership(db, listId: 'l1', wordId: 'w1');
    tester.view.physicalSize = const Size(960, 2142);
    tester.view.devicePixelRatio = 3;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await pumpLists(tester);

    expect(tester.takeException(), isNull, reason: 'no overflow');
    expect(find.text('Travel phrases'), findsOneWidget);
    expect(find.textContaining('1 word'), findsOneWidget);
  });

  group('empty state', () {
    testWidgets('says what a list is for, not just that there are none', (
      tester,
    ) async {
      await pumpLists(tester);

      expect(find.text('No lists yet'), findsOneWidget);
      expect(find.text('New list'), findsWidgets);
    });

    testWidgets('at 200% text on 320dp its action is not under the FAB', (
      tester,
    ) async {
      // Found on the emulator: the empty state's New list sat half under the
      // floating New list. The FAB stays - the words screen keeps its FAB on
      // an empty screen deliberately - so the empty state makes room for it.
      tester.view.physicalSize = const Size(960, 2142);
      tester.view.devicePixelRatio = 3;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpLists(tester);

      // Scrolled to the end, as far as the action can travel.
      await tester.drag(
        find.descendant(
          of: find.byType(EmptyState),
          matching: find.byType(Scrollable),
        ),
        const Offset(0, -2000),
      );
      await tester.pumpAndSettle();

      final action = tester.getRect(
        find.widgetWithText(FilledButton, 'New list'),
      );
      final fab = tester.getRect(find.byType(FloatingActionButton));
      expect(action.overlaps(fab), isFalse);
    });
  });

  group('creating', () {
    testWidgets('a new list appears in the grid', (tester) async {
      await pumpLists(tester);

      await tester.tap(find.widgetWithText(FloatingActionButton, 'New list'));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget, reason: 'sheet opened');
      await tester.enterText(find.byType(TextField), 'IELTS speaking');
      await tester.pumpAndSettle();
      expect(find.text('IELTS speaking'), findsWidgets, reason: 'text typed');
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await settleAsync(tester);
      expect(find.byType(TextField), findsNothing, reason: 'sheet closed');

      // Split deliberately: if the row exists but the card does not, the bug
      // is in the grid, not in the write.
      final rows = await db.select(db.wordLists).get();
      expect(rows.map((r) => r.name), <String>['IELTS speaking']);
      expect(find.text('IELTS speaking'), findsOneWidget);
      expect(find.text('No words'), findsOneWidget);
    });

    testWidgets('a blank name is refused rather than saved', (tester) async {
      // "" is a plausible thing to submit by accident, and a nameless card is
      // unusable once it is in the grid.
      await pumpLists(tester);

      await tester.tap(find.widgetWithText(FloatingActionButton, 'New list'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '   ');
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await settleAsync(tester);

      expect(find.text('Give the list a name.'), findsOneWidget);
      expect(
        find.byType(TextField),
        findsOneWidget,
        reason: 'sheet stays open',
      );
    });
  });

  group('a populated grid', () {
    setUp(() async {
      await seedWord(db, id: 'w1', headword: 'cough');
      await seedWord(db, id: 'w2', headword: 'through');
    });

    testWidgets('a card counts the words in its list', (tester) async {
      await pumpLists(tester);
      await tester.tap(find.widgetWithText(FloatingActionButton, 'New list'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Vowels');
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await settleAsync(tester);

      // A one-shot select, never `watchLists().first`: awaiting a Drift
      // *watch* stream inside testWidgets wedges forever, because it
      // delivers on a real timer that the fake clock never advances. The
      // failure is a hang with no error message.
      final list = (await db.select(db.wordLists).get()).single;
      await db.listsDao.addWord(
        listId: list.id,
        wordId: 'w1',
        addedAt: DateTime.utc(2026, 9, 10),
      );
      await settleAsync(tester);

      expect(find.text('1 word · 1 due'), findsOneWidget);
    });

    testWidgets('deleting says plainly that the words survive', (tester) async {
      // F-042's hard rule is that deleting a list keeps the words. The user
      // cannot tell that from the outside, so the dialog has to say it.
      await pumpLists(tester);
      await tester.tap(find.widgetWithText(FloatingActionButton, 'New list'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Doomed');
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await settleAsync(tester);

      await tester.tap(find.byTooltip('Actions for Doomed'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete list'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('every word in it stays'),
        findsOneWidget,
        reason: 'the dialog must promise the words are safe',
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Delete list'));
      await settleAsync(tester);

      expect(find.text('Doomed'), findsNothing);
      expect(await db.wordsDao.getById('w1'), isNotNull);
      expect(await db.wordsDao.getById('w2'), isNotNull);
    });

    testWidgets('the actions button is reachable without a long-press', (
      tester,
    ) async {
      // UI-UX §1: no action may live only behind a gesture.
      await pumpLists(tester);
      await tester.tap(find.widgetWithText(FloatingActionButton, 'New list'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Reachable');
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await settleAsync(tester);

      await tester.tap(find.byTooltip('Actions for Reachable'));
      await tester.pumpAndSettle();

      expect(find.text('Rename or recolour'), findsOneWidget);
      expect(find.text('Delete list'), findsOneWidget);
    });
  });

  group('list detail (A5)', () {
    setUp(() async {
      await seedWord(db, id: 'w1', headword: 'cough', ipaUk: 'kɒf');
      await seedWord(db, id: 'w2', headword: 'through');
      await seedList(db, id: 'l1', name: 'IELTS');
      await seedMembership(db, listId: 'l1', wordId: 'w1');
    });

    testWidgets('shows only the words in that list', (tester) async {
      await pumpLists(tester);

      await tester.tap(find.text('IELTS'));
      await settleAsync(tester);

      expect(find.text('cough'), findsOneWidget);
      expect(find.text('through'), findsNothing, reason: 'not in this list');
    });

    testWidgets('at 200% on 320dp the list name keeps the app bar', (
      tester,
    ) async {
      // Found on the emulator: the text action took the whole bar and the
      // list's name vanished. It becomes an icon, with the same tooltip.
      tester.view.physicalSize = const Size(960, 2142);
      tester.view.devicePixelRatio = 3;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpLists(tester);

      await tester.tap(find.text('IELTS'));
      await settleAsync(tester);

      final title = find.descendant(
        of: find.byType(AppBar),
        matching: find.text('IELTS'),
      );
      // Five test-font glyphs at 28px: squeezed, it would be narrower.
      expect(tester.getSize(title).width, greaterThanOrEqualTo(140));
      expect(find.byTooltip('Practise this list'), findsOneWidget);
    });

    testWidgets('offers Practise this list', (tester) async {
      await pumpLists(tester);

      await tester.tap(find.text('IELTS'));
      await settleAsync(tester);

      expect(find.text('Practise this list'), findsOneWidget);
    });

    testWidgets('Practise this list opens a test of that list', (tester) async {
      // Found by the owner: the button pushed the Practice tab's own route,
      // which left a blank page and a tab bar that no longer switched. The
      // test beside this one only ever checked that the button existed.
      await pumpLists(tester);
      await tester.tap(find.text('IELTS'));
      await settleAsync(tester);

      await tester.tap(find.text('Practise this list'));
      await tester.pumpAndSettle();

      expect(find.text('Start'), findsOneWidget, reason: 'the test sheet');
      expect(
        find.text('IELTS · 1 word'),
        findsOneWidget,
        reason: 'with this list already chosen',
      );

      await tester.ensureVisible(find.text('Start'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start'));
      for (var i = 0; i < 6; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(find.text('cough'), findsOneWidget, reason: 'in the list');
      expect(find.text('through'), findsNothing, reason: 'not in the list');
    });

    testWidgets('leaving the sheet leaves the tabs working', (tester) async {
      await pumpLists(tester);
      await tester.tap(find.text('IELTS'));
      await settleAsync(tester);
      await tester.tap(find.text('Practise this list'));
      await tester.pumpAndSettle();

      Navigator.of(tester.element(find.text('Start'))).pop();
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'IELTS'), findsOneWidget);

      await tester.pageBack();
      await settleAsync(tester);
      await tester.tap(find.text('Practice'));
      await settleAsync(tester);

      expect(find.widgetWithText(AppBar, 'Practice'), findsOneWidget);
    });

    testWidgets('a list with no words has nothing to practise', (tester) async {
      await seedList(db, id: 'l2', name: 'Empty', sortOrder: 1);
      await pumpLists(tester);
      await tester.tap(find.text('Empty'));
      await settleAsync(tester);

      final button = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Practise this list'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('an empty list says so rather than looking broken', (
      tester,
    ) async {
      await seedList(db, id: 'l2', name: 'Empty', sortOrder: 1);
      await pumpLists(tester);

      await tester.tap(find.text('Empty'));
      await settleAsync(tester);

      expect(find.text('Nothing in this list yet'), findsOneWidget);
    });

    testWidgets('opening a list leaves the words tab filter alone', (
      tester,
    ) async {
      // The detail screen reads a family provider, not the words tab's global
      // query. If it shared that query, coming back would find the tab
      // silently filtered to one list.
      await pumpLists(tester);
      await tester.tap(find.text('IELTS'));
      await settleAsync(tester);
      await tester.pageBack();
      await settleAsync(tester);

      await tester.tap(find.text('Words'));
      await settleAsync(tester);

      expect(find.text('cough'), findsOneWidget);
      expect(find.text('through'), findsOneWidget, reason: 'still unfiltered');
    });
  });

  group('order', () {
    testWidgets('lists read A-Z, not in the order they were made', (
      tester,
    ) async {
      await seedList(db, id: 'l1', name: 'verbs');
      await seedList(db, id: 'l2', name: 'Animals', sortOrder: 1);
      await seedList(db, id: 'l3', name: 'Food', sortOrder: 2);
      await pumpLists(tester);

      final y = <String, double>{
        for (final name in <String>['verbs', 'Animals', 'Food'])
          name: tester.getTopLeft(find.text(name)).dy,
      };
      expect(y['Animals'], lessThan(y['Food']!));
      expect(y['Food'], lessThan(y['verbs']!));
    });
  });

  group('tags', () {
    setUp(() async {
      await seedWord(db, id: 'w1', headword: 'cough');
      await seedList(db, id: 'l1', name: 'Health');
      await seedList(db, id: 't1', name: 'verbs', kind: ListKind.tag);
      await seedMembership(db, listId: 't1', wordId: 'w1');
    });

    testWidgets('sit under the lists, and open their words', (tester) async {
      await pumpLists(tester);

      expect(find.text('Tags'), findsOneWidget);
      await tester.tap(find.text('#verbs, 1'));
      await settleAsync(tester);

      expect(find.text('cough'), findsOneWidget);
    });

    testWidgets('are not offered for selecting', (tester) async {
      await pumpLists(tester);

      await tester.tap(find.byTooltip('Select lists'));
      await tester.pumpAndSettle();

      expect(find.text('#verbs, 1'), findsNothing);
    });

    testWidgets('alone do not count as an empty tab', (tester) async {
      await db.listsDao.deleteList('l1');
      await pumpLists(tester);

      expect(find.text('No lists yet'), findsNothing);
      expect(find.text('#verbs, 1'), findsOneWidget);
    });
  });

  group('selecting', () {
    setUp(() async {
      await seedWord(db, id: 'w1', headword: 'cough');
      await seedList(db, id: 'l1', name: 'Health');
      await seedList(db, id: 'l2', name: 'noun', sortOrder: 1);
      await seedList(db, id: 'l3', name: 'verb', sortOrder: 2);
      await seedMembership(db, listId: 'l2', wordId: 'w1');
    });

    Future<ListKind> kindOf(String id) async =>
        (await db.listsDao.getById(id))!.kind;

    Future<void> selectTwo(WidgetTester tester) async {
      await tester.longPress(find.text('noun'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('verb'));
      await tester.pumpAndSettle();
    }

    testWidgets('turns several lists into tags at once', (tester) async {
      await pumpLists(tester);
      await selectTwo(tester);
      expect(find.text('2 selected'), findsOneWidget);

      await tester.tap(find.text('Make tags'));
      await tester.pumpAndSettle();
      expect(find.text('Make these 2 lists tags?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Make tags'));
      await settleAsync(tester);

      expect(await kindOf('l2'), ListKind.tag);
      expect(await kindOf('l3'), ListKind.tag);
      expect(await kindOf('l1'), ListKind.list, reason: 'never ticked');
      expect(find.text('2 lists are now tags'), findsOneWidget);
      expect(find.text('2 selected'), findsNothing, reason: 'selection over');
      expect(find.text('#noun, 1'), findsOneWidget);
      expect(find.text('New list'), findsWidgets, reason: 'the FAB is back');
    });

    testWidgets('changes nothing when the dialog is cancelled', (tester) async {
      await pumpLists(tester);
      await selectTwo(tester);

      await tester.tap(find.text('Make tags'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await settleAsync(tester);

      expect(await kindOf('l2'), ListKind.list);
      expect(find.text('2 selected'), findsOneWidget, reason: 'still ticked');
    });

    testWidgets('can start from the visible button and take everything', (
      tester,
    ) async {
      // UI-UX section 1: no action may live only behind a gesture.
      await pumpLists(tester);

      await tester.tap(find.byTooltip('Select lists'));
      await tester.pumpAndSettle();
      expect(find.text('0 selected'), findsOneWidget);
      expect(find.text('Make tags'), findsNothing, reason: 'nothing to do yet');

      await tester.tap(find.byTooltip('Select all'));
      await tester.pumpAndSettle();
      expect(find.text('3 selected'), findsOneWidget);
    });

    testWidgets('a tap while selecting ticks rather than opens', (
      tester,
    ) async {
      await pumpLists(tester);
      await tester.tap(find.byTooltip('Select lists'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('noun'));
      await tester.pumpAndSettle();
      expect(find.text('1 selected'), findsOneWidget);
      expect(find.text('cough'), findsNothing, reason: 'the list did not open');

      await tester.tap(find.text('noun'));
      await tester.pumpAndSettle();
      expect(find.text('0 selected'), findsOneWidget);
    });

    testWidgets('Cancel selection brings the tab back', (tester) async {
      await pumpLists(tester);
      await selectTwo(tester);

      await tester.tap(find.byTooltip('Cancel selection'));
      await tester.pumpAndSettle();

      expect(find.text('Lists'), findsWidgets);
      expect(find.byType(Checkbox), findsNothing);
    });
  });
}
