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
import 'package:vocabnote/presentation/overview/overview_charts.dart';
import 'package:vocabnote/presentation/words/word_filter_bar.dart';
import 'package:vocabnote/presentation/words/word_tile.dart';

import '../unit/data/db_fixtures.dart';

/// The home screen against a real (in-memory) database.
void main() {
  late AppDatabase db;
  late ProviderContainer container;

  Future<void> pumpApp(WidgetTester tester) async {
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
  }

  Future<void> tapWhenVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  setUp(() async {
    db = AppDatabase.memory();
    await db.customSelect('SELECT 1').get();
  });

  tearDown(() => db.close());

  Future<void> seedWords(int count) async {
    final now = DateTime.now();
    for (var i = 0; i < count; i++) {
      await seedWord(
        db,
        id: 'w$i',
        headword: 'word$i',
        createdAt: now.subtract(Duration(minutes: i)),
      );
    }
  }

  testWidgets('shows only a few words, and the way to the rest', (
    tester,
  ) async {
    await seedWords(8);
    await pumpApp(tester);

    expect(find.byType(WordTile, skipOffstage: false), findsNWidgets(5));
    expect(find.text('word0', skipOffstage: false), findsOneWidget);
    expect(
      find.text('word7', skipOffstage: false),
      findsNothing,
      reason: 'the oldest is not one of the recent few',
    );

    await tapWhenVisible(tester, find.text('See all words'));

    expect(find.text('All words'), findsOneWidget);
    expect(find.byType(WordFilterBar), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget, reason: 'tabs stay');
  });

  testWidgets('the total is the headline, with what is new this week', (
    tester,
  ) async {
    await seedWords(3);
    await seedWord(
      db,
      id: 'old',
      headword: 'old',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      // Not due, or the due count would read 4 as well.
      dueAt: DateTime.now().add(const Duration(days: 30)),
    );
    await pumpApp(tester);

    expect(find.text('4'), findsOneWidget);
    expect(find.text('words'), findsOneWidget);
    expect(find.text('3 new this week'), findsOneWidget);
  });

  testWidgets('says nothing it cannot back up before any practice', (
    tester,
  ) async {
    await seedWords(1);
    await pumpApp(tester);

    expect(find.text('Days in a row'), findsNothing, reason: 'RULES 6');
    expect(find.text('Remembered'), findsNothing);
    expect(
      find.text('Practise and your days fill in here.', skipOffstage: false),
      findsOneWidget,
    );
    expect(find.byType(ActivityChart, skipOffstage: false), findsOneWidget);
  });

  testWidgets('practice shows up in the numbers', (tester) async {
    await seedWords(1);
    await seedSession(db, id: 's1');
    final now = DateTime.now();
    await seedAnswer(
      db,
      id: 'a1',
      sessionId: 's1',
      wordId: 'w0',
      answeredAt: now,
    );
    await pumpApp(tester);

    expect(find.text('Days in a row'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
    expect(
      find.text('1 answer · Busiest day: 1', skipOffstage: false),
      findsOneWidget,
    );
  });

  testWidgets('the legend carries the counts, so no colour has to', (
    tester,
  ) async {
    await seedWord(db, id: 'a', headword: 'a');
    await seedWord(db, id: 'b', headword: 'b', box: 5);
    await pumpApp(tester);

    expect(find.text('New 1', skipOffstage: false), findsOneWidget);
    expect(find.text('Learning 0', skipOffstage: false), findsOneWidget);
    expect(find.text('Strong 1', skipOffstage: false), findsOneWidget);
  });

  testWidgets('the stage bar is actually drawn, wider for more words', (
    tester,
  ) async {
    // Found on the emulator: every segment laid out zero pixels tall, so the
    // bar was a blank gap above a legend that read perfectly.
    await seedWord(db, id: 'a', headword: 'a');
    await seedWord(db, id: 'b', headword: 'b', box: 5);
    await seedWord(db, id: 'c', headword: 'c', box: 5);
    await seedWord(db, id: 'd', headword: 'd', box: 5);
    await pumpApp(tester);

    final segments = find.descendant(
      of: find.byType(StageChart, skipOffstage: false),
      matching: find.byType(ColoredBox, skipOffstage: false),
      skipOffstage: false,
    );
    final sizes = segments.evaluate().map(
      (e) => (e.renderObject! as RenderBox).size,
    );

    expect(sizes, hasLength(2), reason: 'a stage with no words draws nothing');
    expect(sizes.every((size) => size.height > 0), isTrue);
    expect(sizes.last.width, greaterThan(sizes.first.width * 2));
  });

  testWidgets('a day with no answers still shows as a hairline', (
    tester,
  ) async {
    await seedWords(1);
    await seedSession(db, id: 's1');
    await seedAnswer(
      db,
      id: 'a1',
      sessionId: 's1',
      wordId: 'w0',
      answeredAt: DateTime.now(),
    );
    await pumpApp(tester);

    final bars = find.descendant(
      of: find.byType(ActivityChart, skipOffstage: false),
      matching: find.byType(DecoratedBox, skipOffstage: false),
      skipOffstage: false,
    );
    final heights = bars
        .evaluate()
        .map((e) => (e.renderObject! as RenderBox).size.height)
        .toList();

    expect(heights, hasLength(14));
    expect(heights.every((height) => height > 0), isTrue);
    expect(heights.first, lessThan(heights.last), reason: 'today is the peak');
  });

  testWidgets('the biggest lists lead, and only lists with words', (
    tester,
  ) async {
    await seedWords(3);
    await seedList(db, id: 'small', name: 'Small');
    await seedList(db, id: 'big', name: 'Big');
    await seedList(db, id: 'empty', name: 'Empty');
    await seedList(db, id: 'tag', name: 'noun', kind: ListKind.tag);
    await seedMembership(db, listId: 'small', wordId: 'w0');
    await seedMembership(db, listId: 'big', wordId: 'w1');
    await seedMembership(db, listId: 'big', wordId: 'w2');
    await seedMembership(db, listId: 'tag', wordId: 'w2');
    await pumpApp(tester);

    final chart = find.byType(TopListsChart, skipOffstage: false);
    final names = tester
        .widgetList<Text>(
          find.descendant(
            of: chart,
            matching: find.byType(Text, skipOffstage: false),
            skipOffstage: false,
          ),
        )
        .map((t) => t.data)
        .where((d) => d != null && int.tryParse(d) == null)
        .toList();
    expect(names, <String>['Big', 'Small'], reason: 'no empty list, no tag');
  });

  testWidgets('search opens the list, ready to type', (tester) async {
    await seedWords(2);
    await pumpApp(tester);

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.focusNode!.hasFocus, isTrue);
  });

  testWidgets('Due now goes to practice', (tester) async {
    await seedWords(1);
    await pumpApp(tester);

    await tester.tap(find.text('Due now'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Practice'), findsOneWidget);
  });

  testWidgets('at 200% text on 320dp nothing overflows', (tester) async {
    await seedWords(6);
    await seedList(db, id: 'l1', name: 'A list with quite a long name indeed');
    await seedMembership(db, listId: 'l1', wordId: 'w0');
    await seedSession(db, id: 's1');
    await seedAnswer(
      db,
      id: 'a1',
      sessionId: 's1',
      wordId: 'w0',
      answeredAt: DateTime.now(),
    );
    tester.view.physicalSize = const Size(960, 2142);
    tester.view.devicePixelRatio = 3;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await pumpApp(tester);

    expect(tester.takeException(), isNull, reason: 'no overflow');
  });
}
