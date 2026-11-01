import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Riverpod 3 moved `Override` out of the main barrel file.
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:vocabnote/app.dart';
import 'package:vocabnote/application/settings/app_info.dart';
import 'package:vocabnote/core/utils/external_links.dart';
import 'package:vocabnote/data/composition_root.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/db/database_provider.dart';
import 'package:vocabnote/data/diagnostics/file_error_log.dart';

import '../unit/application/fake_links.dart';
import '../unit/application/fake_reminder_service.dart';
import '../unit/application/fake_speech_service.dart';

/// Help & feedback (F-072, `docs/UI-UX.md` §4.11). Always in Settings
/// (RULES §4).
///
/// The promise under test: **no data leaves without an explicit tap**, and
/// the user sees exactly what the email carries before anything opens.
void main() {
  late AppDatabase db;
  late Directory folder;
  late FileErrorLog errorLog;
  late FakeLinkOpener links;
  late ProviderContainer container;

  const address = 'feedback@example.com';

  setUp(() async {
    db = AppDatabase.memory();
    await db.customSelect('SELECT 1').get();
    folder = await Directory.systemTemp.createTemp('vnb_help_');
    errorLog = FileErrorLog(File(p.join(folder.path, 'errors.log')));
    links = FakeLinkOpener();
  });

  tearDown(() async {
    await db.close();
    await folder.delete(recursive: true);
  });

  Future<void> openHelp(WidgetTester tester, {String? feedback}) async {
    container = ProviderContainer(
      overrides: <Override>[
        appDatabaseProvider.overrideWithValue(db),
        feedbackAddressProvider.overrideWithValue(feedback),
        ...repositoryOverrides(
          db,
          speechService: FakeSpeechService(),
          reminderService: FakeReminderService(),
          errorLog: errorLog,
          linkOpener: links,
          diagnostics: FakeDiagnostics(),
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

    final row = find.text('Help & feedback');
    await tester.scrollUntilVisible(
      row,
      200,
      scrollable: find
          .descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.ensureVisible(row);
    await tester.pumpAndSettle();
    await tester.tap(row);
    await tester.pumpAndSettle();
  }

  /// Reads the error log and the diagnostics are real async; let them land.
  Future<void> settleAsync(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pumpAndSettle();
    }
  }

  /// The help list's own scroll view: the first Scrollable in it. Not the
  /// last - the search field has a horizontal one of its own.
  Finder helpList() => find
      .descendant(of: find.byType(ListView), matching: find.byType(Scrollable))
      .first;

  /// Scrolls the help list down to [finder] and taps it.
  Future<void> tapInList(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(finder, 200, scrollable: helpList());
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await settleAsync(tester);
  }

  Future<void> search(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField).first, text);
    await tester.pumpAndSettle();
  }

  String bodyOf(Uri uri) =>
      Uri.decodeComponent(uri.toString().split('body=').last);

  group('the FAQ', () {
    testWidgets('someone searching for bulk import finds how', (tester) async {
      await openHelp(tester);

      await search(tester, 'csv');

      expect(find.text('How do I import many words at once?'), findsOneWidget);
    });

    testWidgets('holds thirteen answers', (tester) async {
      await openHelp(tester);

      expect(find.text('13 answers'), findsOneWidget);
      expect(find.text('Where are my words kept?'), findsOneWidget);
    });

    testWidgets('narrows as you type, in questions and answers', (
      tester,
    ) async {
      await openHelp(tester);

      await search(tester, 'backup');

      expect(find.text('4 answers'), findsOneWidget);
      expect(find.text('Where are my words kept?'), findsOneWidget);
      expect(find.text('What is IPA?'), findsNothing);
    });

    testWidgets('says plainly when nothing matches, and can be cleared', (
      tester,
    ) async {
      await openHelp(tester);

      await search(tester, 'zebra');
      expect(find.text('No answers mention “zebra”.'), findsOneWidget);

      await tester.tap(find.text('Clear search'));
      await tester.pumpAndSettle();
      expect(find.text('13 answers'), findsOneWidget);
    });
  });

  group('feedback', () {
    testWidgets('is not offered until an address is set', (tester) async {
      // FEEDBACK_EMAIL is set at M8; until then GitHub is the way in.
      await openHelp(tester);
      // Scrolled to the row that would sit just below it: the list builds
      // only what is on screen, so absence means nothing until then.
      final github = find.text('Report a problem on GitHub');
      await tester.scrollUntilVisible(github, 200, scrollable: helpList());

      expect(github, findsOneWidget);
      expect(find.text('Send feedback'), findsNothing);
    });

    testWidgets('shows exactly what is sent, and opens nothing until asked', (
      tester,
    ) async {
      await openHelp(tester, feedback: address);

      await tapInList(tester, find.text('Send feedback'));

      expect(find.textContaining('App version: 1.2.3 (45)'), findsOneWidget);
      expect(find.textContaining('Android 17'), findsOneWidget);
      expect(find.textContaining('Google Pixel 9 Pro'), findsOneWidget);
      expect(find.text('Nothing else is included.'), findsOneWidget);
      expect(links.opened, isEmpty, reason: 'no data leaves without a tap');

      await tester.tap(find.text('Open email'));
      await settleAsync(tester);

      final sent = links.opened.single;
      expect(sent.scheme, 'mailto');
      expect(sent.path, address);
      expect(sent.toString(), isNot(contains('+')));
      expect(bodyOf(sent), contains('Google Pixel 9 Pro'));
    });

    testWidgets('attaches the error log only when ticked', (tester) async {
      errorLog.record(StateError('the thing that broke'), StackTrace.empty);
      await openHelp(tester, feedback: address);

      await tapInList(tester, find.text('Send feedback'));
      final tick = find.widgetWithText(
        CheckboxListTile,
        'Include the error log',
      );
      expect(tester.widget<CheckboxListTile>(tick).value, isFalse);
      expect(find.textContaining('the thing that broke'), findsNothing);

      await tester.tap(tick);
      await tester.pumpAndSettle();
      expect(
        find.textContaining('the thing that broke'),
        findsOneWidget,
        reason: 'what is attached is shown before it is sent',
      );

      await tester.tap(find.text('Open email'));
      await settleAsync(tester);
      expect(bodyOf(links.opened.single), contains('the thing that broke'));
    });

    testWidgets('with no mail app, says where to write instead', (
      tester,
    ) async {
      links.succeed = false;
      await openHelp(tester, feedback: address);

      await tapInList(tester, find.text('Send feedback'));
      await tester.tap(find.text('Open email'));
      await settleAsync(tester);

      expect(find.textContaining(address), findsOneWidget);
    });
  });

  testWidgets('Report a problem on GitHub opens Issues', (tester) async {
    await openHelp(tester);

    await tapInList(tester, find.text('Report a problem on GitHub'));

    expect(links.opened, <Uri>[ProjectLinks.issues]);
  });

  group('the error log', () {
    testWidgets('can be read and cleared', (tester) async {
      errorLog.record(StateError('the thing that broke'), StackTrace.empty);
      await openHelp(tester);

      await tapInList(tester, find.text('View error log'));
      expect(find.textContaining('the thing that broke'), findsOneWidget);

      await tester.tap(find.text('Clear log'));
      await settleAsync(tester);

      expect(find.textContaining('Nothing has gone wrong'), findsOneWidget);
      expect((await tester.runAsync(errorLog.read))!.valueOrNull, isEmpty);
    });
  });
}
