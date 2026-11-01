import 'dart:async';

// `isNull`/`isNotNull` exist in both drift and matcher; matcher's win here.
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
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

import 'package:vocabnote/presentation/words/word_tile.dart';

import '../unit/data/db_fixtures.dart';

/// The words screen against a real (in-memory) database (F-040, F-041).
///
/// Drives the actual app - the real router, the real repositories, the real
/// FTS index - so what is asserted here is what a user would see. Only the
/// database is swapped, and only for an in-memory one with the same schema.
void main() {
  late AppDatabase db;
  late ProviderContainer container;

  Future<void> pumpApp(WidgetTester tester, {bool toList = true}) async {
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
    if (toList) {
      unawaited(container.read(appRouterProvider).push(Routes.wordsAll));
      await tester.pumpAndSettle();
    }
  }

  setUp(() async {
    db = AppDatabase.memory();
    await db.customSelect('SELECT 1').get();
  });

  tearDown(() => db.close());

  group('empty state', () {
    testWidgets('teaches the feature when there are no words', (tester) async {
      await pumpApp(tester, toList: false);

      expect(find.text('Your first word goes here'), findsOneWidget);
      expect(find.text('Add a word'), findsOneWidget);
      expect(find.text('See how it works'), findsOneWidget);
    });

    testWidgets('still offers the Add word button', (tester) async {
      await pumpApp(tester, toList: false);
      expect(
        find.widgetWithText(FloatingActionButton, 'Add word'),
        findsOneWidget,
      );
    });
  });

  group('listing words', () {
    setUp(() async {
      await seedWord(
        db,
        id: 'w1',
        headword: 'cough',
        ipaUk: 'kɒf',
        definition: 'to expel air from the lungs',
      );
      await seedWord(db, id: 'w2', headword: 'through', ipaUs: 'θɹu');
      await seedNote(db, id: 'n1', wordId: 'w1', body: 'mouth more open');
    });

    testWidgets('shows the headwords', (tester) async {
      await pumpApp(tester);

      expect(find.text('cough'), findsOneWidget);
      expect(find.text('through'), findsOneWidget);
    });

    testWidgets('shows the IPA with its slashes as fixed affixes', (
      tester,
    ) async {
      await pumpApp(tester);

      // The slashes are drawn by the UI, never stored - so the rendered text
      // has them and the database does not.
      final row = await db.wordsDao.getById('w1');
      expect(row!.ipaUk, 'kɒf', reason: 'stored without slashes');

      expect(find.textContaining('kɒf', findRichText: true), findsOneWidget);
    });

    testWidgets('shows a note count only where there are notes', (
      tester,
    ) async {
      await pumpApp(tester);

      // One word has a note, the other does not.
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('each word is a tonal card, not a flat row', (tester) async {
      // Replaces an assertion that the row was exactly 72dp tall. The
      // Phonetic Naturalist restyle made these cards, and `docs/UI-UX.md` §4.1
      // was rewritten to match - so the old number was the spec, not a bug.
      await pumpApp(tester);

      final card = tester.widget<Material>(
        find
            .ancestor(of: find.text('cough'), matching: find.byType(Material))
            .first,
      );
      final scheme = Theme.of(tester.element(find.text('cough'))).colorScheme;
      expect(
        card.color,
        scheme.surfaceContainer,
        reason: 'a card must separate from the page by tone',
      );
      expect(card.color, isNot(scheme.surface));
    });

    testWidgets('a card names which accent its transcription is', (
      tester,
    ) async {
      // `preferredIpa` silently falls back to US, so an unlabelled
      // transcription in the list could be either one.
      await pumpApp(tester);
      expect(find.text('UK'), findsOneWidget);
    });
  });

  group('filters', () {
    setUp(() async {
      await seedWord(db, id: 'w1', headword: 'cough', isFavourite: true);
      await seedWord(db, id: 'w2', headword: 'through');
      await seedWord(db, id: 'w3', headword: 'plough', ipaUs: 'plaʊ');
    });

    testWidgets('the All chip carries the live word count', (tester) async {
      await pumpApp(tester);

      final all = find.ancestor(
        of: find.text('All'),
        matching: find.byType(FilterChip),
      );
      expect(all, findsOneWidget);
      expect(
        find.descendant(of: all, matching: find.text('3')),
        findsOneWidget,
        reason: 'three words were seeded',
      );
    });

    testWidgets('a counted chip is still a button to a screen reader', (
      tester,
    ) async {
      // The count must not be bought by wrapping the chip in ExcludeSemantics:
      // that strips the tap action (UI-UX §6).
      final handle = tester.ensureSemantics();
      await pumpApp(tester);

      final node = tester.getSemantics(
        find
            .ancestor(of: find.text('All'), matching: find.byType(FilterChip))
            .first,
      );
      expect(node.label, contains('3 words'));
      expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
      handle.dispose();
    });

    testWidgets('offers the four fixed chips', (tester) async {
      await pumpApp(tester);

      for (final label in <String>[
        'All',
        'Favourites',
        'Due today',
        'No IPA yet',
      ]) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
    });

    testWidgets('each list gets its own chip, which filters to its words', (
      tester,
    ) async {
      // M4's A6: "the filter chips match the spec, including a chip per list".
      // The four fixed chips were tested; the one a user makes by creating a
      // list was not.
      await seedList(db, id: 'l1', name: 'Travel');
      await seedMembership(db, listId: 'l1', wordId: 'w2');
      await pumpApp(tester);

      // The chip row scrolls sideways; a list's chip follows the fixed four.
      await tester.scrollUntilVisible(
        find.text('Travel'),
        100,
        scrollable: find.byWidgetPredicate(
          (widget) =>
              widget is Scrollable &&
              widget.axisDirection == AxisDirection.right,
        ),
      );
      await tester.tap(find.text('Travel'));
      await tester.pumpAndSettle();

      expect(find.text('through'), findsOneWidget);
      expect(find.text('cough'), findsNothing, reason: 'not in the list');
      expect(find.text('plough'), findsNothing, reason: 'not in the list');
    });

    testWidgets('Favourites narrows to starred words', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.text('Favourites'));
      await tester.pumpAndSettle();

      expect(find.text('cough'), findsOneWidget);
      expect(find.text('through'), findsNothing);
    });

    testWidgets('No IPA yet finds words still to transcribe', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.text('No IPA yet'));
      await tester.pumpAndSettle();

      expect(find.text('cough'), findsOneWidget);
      expect(find.text('through'), findsOneWidget);
      // plough has a transcription, so it is done.
      expect(find.text('plough'), findsNothing);
    });

    testWidgets('a filter that matches nothing explains itself', (
      tester,
    ) async {
      await db.wordsDao.patchWord(
        'w1',
        const WordsCompanion(isFavourite: Value(false)),
      );
      await pumpApp(tester);

      await tester.tap(find.text('Favourites'));
      await tester.pumpAndSettle();

      expect(find.text('Nothing here yet'), findsOneWidget);
      expect(find.text('Clear filters'), findsOneWidget);
    });
  });

  group('search', () {
    setUp(() async {
      await seedWord(
        db,
        id: 'w1',
        headword: 'cough',
        definition: 'to expel air from the lungs',
      );
      await seedWord(db, id: 'w2', headword: 'through');
      await seedNote(db, id: 'n1', wordId: 'w2', body: 'tricky vowel');
    });

    /// Matches [word] only inside a list row.
    ///
    /// `find.text` alone would also match the search field, which now contains
    /// the same term.
    Finder inRow(String word) =>
        find.descendant(of: find.byType(WordTile), matching: find.text(word));

    testWidgets('finds a word by its headword', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'cough');
      // Past the debounce.
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(inRow('cough'), findsOneWidget);
      expect(inRow('through'), findsNothing);
    });

    testWidgets('finds a word by its definition', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'lungs');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(inRow('cough'), findsOneWidget);
      expect(inRow('through'), findsNothing);
    });

    testWidgets('finds a word by the text of a note', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'tricky');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(inRow('through'), findsOneWidget);
      expect(inRow('cough'), findsNothing);
    });

    testWidgets('a search with no matches offers a way back', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'zzzznothing');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(find.text('No matches'), findsOneWidget);
    });

    testWidgets('typing punctuation does not break the query', (tester) async {
      // A user must not be able to break search by typing an FTS5 operator.
      await pumpApp(tester);

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      for (final term in <String>['AND', '"', '*', 'a OR b']) {
        await tester.enterText(find.byType(TextField), term);
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'term: $term');
      }
    });
  });

  group('favourite toggle', () {
    testWidgets('stars a word from the list', (tester) async {
      await seedWord(db, id: 'w1', headword: 'cough');
      await pumpApp(tester);

      expect(find.byIcon(Icons.star_border), findsOneWidget);

      await tester.tap(find.byIcon(Icons.star_border));
      await tester.pumpAndSettle();

      final row = await db.wordsDao.getById('w1');
      expect(row!.isFavourite, isTrue);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });
  });

  group('soft delete with undo', () {
    testWidgets('deleting hides the word but keeps everything', (tester) async {
      await seedWord(db, id: 'w1', headword: 'cough');
      await seedNote(db, id: 'n1', wordId: 'w1', body: 'keep me');
      await pumpApp(tester);

      await tester.longPress(find.text('cough'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Deleted cough'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);

      // Flagged, not destroyed.
      final row = await db.wordsDao.getById('w1');
      expect(row!.deletedAt, isNotNull);
      expect(await db.select(db.wordNotes).get(), hasLength(1));
    });

    testWidgets('Undo brings it straight back', (tester) async {
      await seedWord(db, id: 'w1', headword: 'cough');
      await pumpApp(tester);

      await tester.longPress(find.text('cough'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      final row = await db.wordsDao.getById('w1');
      expect(row!.deletedAt, isNull);
      expect(find.text('cough'), findsOneWidget);
    });
  });
}
