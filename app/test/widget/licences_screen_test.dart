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

import '../unit/application/fake_links.dart';
import '../unit/application/fake_reminder_service.dart';
import '../unit/application/fake_speech_service.dart';

/// Data sources & licences (F-075) and the privacy note (F-076).
///
/// RULES §14: any bundled or displayed third-party content carries in-app
/// attribution and its licence. This screen is where that obligation is met,
/// so each source is held to being named, licensed and linked.
void main() {
  late AppDatabase db;
  late FakeLinkOpener links;
  late ProviderContainer container;

  /// F-076, word for word.
  const privacy =
      'Schwa Notes has no account and no analytics. Your words never leave '
      'your phone unless you export them. Looking up a word sends only that '
      'word to freedictionaryapi.com.';

  setUp(() async {
    db = AppDatabase.memory();
    await db.customSelect('SELECT 1').get();
    links = FakeLinkOpener();
  });

  tearDown(() => db.close());

  Finder settingsList() => find
      .descendant(of: find.byType(ListView), matching: find.byType(Scrollable))
      .first;

  Future<void> openSettings(
    WidgetTester tester, {
    String? feedbackAddress,
  }) async {
    container = ProviderContainer(
      overrides: <Override>[
        appDatabaseProvider.overrideWithValue(db),
        feedbackAddressProvider.overrideWithValue(feedbackAddress),
        ...repositoryOverrides(
          db,
          speechService: FakeSpeechService(),
          reminderService: FakeReminderService(),
          linkOpener: links,
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
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
  }

  /// Scrolls the frontmost list to [finder].
  Future<void> scrollTo(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(finder, 200, scrollable: settingsList());
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
  }

  Future<void> openLicences(
    WidgetTester tester, {
    String? feedbackAddress,
  }) async {
    await openSettings(tester, feedbackAddress: feedbackAddress);
    final row = find.text('Data sources & licences');
    await scrollTo(tester, row);
    await tester.tap(row);
    await tester.pumpAndSettle();
  }

  /// Loading an asset is real async; let it land.
  Future<void> settleAsync(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pumpAndSettle();
    }
  }

  Future<void> tapLink(WidgetTester tester, String label) async {
    final link = find.text(label);
    await scrollTo(tester, link);
    await tester.tap(link);
    await tester.pumpAndSettle();
  }

  testWidgets('starts with the privacy note, word for word', (tester) async {
    await openLicences(tester);

    expect(find.text(privacy), findsOneWidget);
  });

  // DATA-SOURCES §7: the email point describes a build with a feedback
  // address. v1.0 has none (GitHub Issues only), and the note must not claim
  // a feature the app does not have.
  group('the feedback point', () {
    const emailPoint =
        'Feedback is written in your own email app. You see what it includes '
        'before it opens, and nothing else is attached unless you choose to '
        'add the error log.';
    const lastPoint =
        'Your words, IPA, highlights, notes and practice history stay on this '
        'phone, and leave it only in a backup you export.';

    testWidgets('is absent when the build has no feedback address', (
      tester,
    ) async {
      await openLicences(tester);

      // The note's last point is built and on screen, so the absence of the
      // one before it means something.
      expect(find.text(lastPoint), findsOneWidget);
      expect(find.text(emailPoint), findsNothing);
    });

    testWidgets('is there when the build has one', (tester) async {
      await openLicences(tester, feedbackAddress: 'feedback@example.com');

      expect(find.text(emailPoint), findsOneWidget);
      expect(find.text(lastPoint), findsOneWidget);
    });
  });

  testWidgets('names every source with its licence', (tester) async {
    await openLicences(tester);

    for (final text in <String>[
      'Wiktionary',
      'FreeDictionaryAPI.com',
      'CC BY-SA 4.0',
      'CMU Pronouncing Dictionary',
      'Inter',
      'Charis SIL',
      'SIL Open Font License 1.1',
    ]) {
      final named = find.textContaining(text);
      await scrollTo(tester, named.first);
      expect(named, findsWidgets, reason: text);
    }
  });

  testWidgets('links back to each source (CC BY-SA 4.0: attribute, link)', (
    tester,
  ) async {
    await openLicences(tester);

    await tapLink(tester, 'Wiktionary');
    await tapLink(tester, 'FreeDictionaryAPI.com');
    await tapLink(tester, 'CC BY-SA 4.0 licence');
    await tapLink(tester, 'CMU Pronouncing Dictionary');

    expect(links.opened.map((uri) => uri.host), <String>[
      'en.wiktionary.org',
      'freedictionaryapi.com',
      'creativecommons.org',
      'github.com',
    ]);
    expect(links.opened[2].path, '/licenses/by-sa/4.0/');
  });

  testWidgets('each font licence can be read in full', (tester) async {
    await openLicences(tester);

    // Through its own row, not `.first`: the rows are below the fold, and
    // `.first` of a finder that matches nothing yet throws while scrolling.
    final view = find.descendant(
      of: find.widgetWithText(OverflowBar, 'Inter'),
      matching: find.text('View licence'),
    );
    await scrollTo(tester, view);
    await tester.tap(view);
    await settleAsync(tester);

    expect(find.textContaining('OPEN FONT LICENSE'), findsOneWidget);
  });

  testWidgets("All package licences opens Flutter's licence page", (
    tester,
  ) async {
    await openLicences(tester);

    await tapLink(tester, 'All package licences');

    expect(find.byType(LicensePage), findsOneWidget);
  });

  testWidgets('Settings → About → Privacy opens the same note', (tester) async {
    await openSettings(tester);

    final row = find.text('Privacy');
    await scrollTo(tester, row);
    await tester.tap(row);
    await tester.pumpAndSettle();

    expect(find.text(privacy), findsOneWidget);
  });
}
