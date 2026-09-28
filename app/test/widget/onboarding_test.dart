import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Riverpod 3 moved `Override` out of the main barrel file.
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/app.dart';
import 'package:vocabnote/application/settings/app_info.dart';
import 'package:vocabnote/data/composition_root.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/db/database_provider.dart';
import 'package:vocabnote/data/db/tables/app_meta.dart';

import '../unit/application/fake_reminder_service.dart';
import '../unit/application/fake_speech_service.dart';

/// First-run onboarding (F-077, `docs/UI-UX.md` §4.10): three slides and the
/// guide, skippable from every one, never shown again once finished.
void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() async {
    db = AppDatabase.memory();
    await db.customSelect('SELECT 1').get();
  });

  tearDown(() => db.close());

  Future<void> launch(WidgetTester tester) async {
    container = ProviderContainer(
      overrides: <Override>[
        appDatabaseProvider.overrideWithValue(db),
        // What bootstrap decides for a fresh install.
        showOnboardingProvider.overrideWithValue(true),
        ...repositoryOverrides(
          db,
          speechService: FakeSpeechService(),
          reminderService: FakeReminderService(),
        ),
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
  }

  /// The write that finishes onboarding is not awaited by the tap; let it
  /// land before looking.
  Future<void> settleAsync(WidgetTester tester) async {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();
  }

  Future<bool> finished(WidgetTester tester) async => (await tester.runAsync(
    () => db.metaDao.getBool(AppMetaKeys.onboardingCompleted),
  ))!;

  Future<void> next(WidgetTester tester) async {
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
  }

  final firstSlide = find.text("Note the words you're learning");
  final emptyWords = find.text('Your first word goes here');

  testWidgets('a first launch opens on the first slide, not the words', (
    tester,
  ) async {
    await launch(tester);

    expect(firstSlide, findsOneWidget);
    expect(emptyWords, findsNothing);
  });

  testWidgets('Skip is on every slide, and skipping marks it done', (
    tester,
  ) async {
    await launch(tester);

    for (var slide = 1; slide <= 3; slide++) {
      expect(find.text('Skip'), findsOneWidget, reason: 'slide $slide');
      if (slide < 3) await next(tester);
    }
    await tester.tap(find.text('Skip'));
    await settleAsync(tester);

    expect(emptyWords, findsOneWidget);
    expect(await finished(tester), isTrue);
  });

  testWidgets('three slides, then the guide, then into the app', (
    tester,
  ) async {
    await launch(tester);

    await next(tester);
    await next(tester);
    await tester.tap(find.text('See how it works'));
    await tester.pumpAndSettle();

    expect(find.text('Add a word'), findsOneWidget, reason: 'the guide');
    expect(await finished(tester), isFalse, reason: 'not until they leave');

    final start = find.text('Start using Schwa Notes');
    await tester.scrollUntilVisible(
      start,
      300,
      scrollable: find
          .descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(start);
    await settleAsync(tester);

    expect(emptyWords, findsOneWidget);
    expect(await finished(tester), isTrue);
  });

  testWidgets('Try it from the guide finishes onboarding and goes there', (
    tester,
  ) async {
    await launch(tester);
    await next(tester);
    await next(tester);
    await tester.tap(find.text('See how it works'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Try it').first);
    await settleAsync(tester);

    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Add word')),
      findsOneWidget,
    );
    expect(await finished(tester), isTrue);
  });

  testWidgets('the page is announced as its place in three', (tester) async {
    final semantics = tester.ensureSemantics();
    await launch(tester);

    expect(find.bySemanticsLabel('Page 1 of 3'), findsOneWidget);
    await next(tester);
    expect(find.bySemanticsLabel('Page 2 of 3'), findsOneWidget);

    semantics.dispose();
  });

  testWidgets('with animations off, Next jumps rather than slides', (
    tester,
  ) async {
    // UI-UX §2: all animation is skipped when the platform asks for it.
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await launch(tester);

    await tester.tap(find.text('Next'));
    await tester.pump();

    final pager = tester.widget<PageView>(find.byType(PageView));
    expect(pager.controller!.page, 1.0, reason: 'there after one frame');
  });
}
