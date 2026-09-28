import 'package:flutter/material.dart';
// Riverpod 3 ships its own AsyncResult; ours is the Result-based one.
import 'package:flutter_riverpod/flutter_riverpod.dart' hide AsyncResult;
// Riverpod 3 moved `Override` out of the main barrel file.
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/app.dart';
import 'package:vocabnote/application/practice/scheduler/review_schedule.dart';
import 'package:vocabnote/application/repositories.dart';
import 'package:vocabnote/application/settings/app_info.dart';
import 'package:vocabnote/core/failure.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/result.dart';
import 'package:vocabnote/core/theme/app_theme.dart';
import 'package:vocabnote/data/composition_root.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/db/database_provider.dart';
import 'package:vocabnote/domain/entities/backup.dart';
import 'package:vocabnote/domain/repositories/error_log.dart';
import 'package:vocabnote/presentation/common/recovery_screen.dart';
import 'package:vocabnote/presentation/common/typed_confirm_dialog.dart';
import 'package:vocabnote/presentation/settings/error_log_sheet.dart';
import 'package:vocabnote/presentation/settings/import_preview_sheet.dart';
import 'package:vocabnote/presentation/settings/interval_editor_sheet.dart';
import 'package:vocabnote/presentation/settings/privacy_note.dart';

import '../unit/application/fake_backup_files.dart';
import '../unit/application/fake_links.dart';
import '../unit/application/fake_reminder_service.dart';
import '../unit/application/fake_speech_service.dart';

/// Every screen M6 added, at 200% text on a 320dp phone (`docs/UI-UX.md` §6,
/// A15).
///
/// The size that found ten defects a 427dp pass missed. Each screen is
/// scrolled from top to bottom; a layout that overflows reports an exception,
/// which fails the test. Sheets and dialogs with a text field are checked
/// with the keyboard up, the way they are met on a device.
void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUpAll(() => EditableText.debugDeterministicCursor = true);
  tearDownAll(() => EditableText.debugDeterministicCursor = false);

  setUp(() async {
    db = AppDatabase.memory();
    await db.customSelect('SELECT 1').get();
  });

  tearDown(() => db.close());

  /// 960×2142 at 3× is a 320×714dp phone; text at twice its size.
  void stressSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(960, 2142);
    tester.view.devicePixelRatio = 3;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }

  Future<void> launch(
    WidgetTester tester, {
    bool onboarding = false,
    String? feedback,
  }) async {
    stressSize(tester);
    container = ProviderContainer(
      overrides: <Override>[
        appDatabaseProvider.overrideWithValue(db),
        showOnboardingProvider.overrideWithValue(onboarding),
        feedbackAddressProvider.overrideWithValue(feedback),
        ...repositoryOverrides(
          db,
          speechService: FakeSpeechService(),
          reminderService: FakeReminderService(),
          backupFiles: FakeBackupFiles(),
          linkOpener: FakeLinkOpener(),
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
  }

  /// The frontmost list's own scroll view.
  Finder frontList() => find
      .descendant(
        of: find.byType(ListView).last,
        matching: find.byType(Scrollable),
      )
      .first;

  /// Scrolls the frontmost list from top to bottom, a screen at a time,
  /// checking nothing has overflowed at each stop.
  Future<void> scrollThrough(WidgetTester tester, String screen) async {
    expect(tester.takeException(), isNull, reason: '$screen, at the top');
    for (var stop = 0; stop < 40; stop++) {
      final position = tester.state<ScrollableState>(frontList()).position;
      if (position.pixels >= position.maxScrollExtent) break;
      await tester.drag(frontList(), const Offset(0, -400));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '$screen, stop $stop');
    }
  }

  Future<void> openSettings(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
  }

  Future<void> openFromSettings(WidgetTester tester, String row) async {
    await openSettings(tester);
    final target = find.text(row);
    await tester.scrollUntilVisible(target, 300, scrollable: frontList());
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  Future<void> expectReachable(WidgetTester tester, Finder button) async {
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    expect(button.hitTestable(), findsOneWidget);
  }

  group('screens, top to bottom', () {
    testWidgets('Settings', (tester) async {
      await launch(tester);
      await openSettings(tester);

      await scrollThrough(tester, 'Settings');
    });

    testWidgets('Backup & restore', (tester) async {
      await launch(tester);
      await openFromSettings(tester, 'Backup & restore');

      await scrollThrough(tester, 'Backup & restore');
      await expectReachable(tester, find.text('Import backup'));
    });

    testWidgets('How to use, from the empty words list', (tester) async {
      await launch(tester);
      final guide = find.text('See how it works');
      await tester.ensureVisible(guide);
      await tester.pumpAndSettle();
      await tester.tap(guide);
      await tester.pumpAndSettle();

      await scrollThrough(tester, 'How to use');
    });

    testWidgets('Help & feedback, and the feedback preview', (tester) async {
      await launch(tester, feedback: 'feedback@example.com');
      await openFromSettings(tester, 'Help & feedback');

      await scrollThrough(tester, 'Help & feedback');

      // Back up to it: at this size two rows fill the screen, so from the
      // bottom of the list the row above them is not even built.
      final send = find.text('Send feedback');
      await tester.scrollUntilVisible(send, -300, scrollable: frontList());
      await tester.ensureVisible(send);
      await tester.pumpAndSettle();
      await tester.tap(send);
      for (var i = 0; i < 5; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull, reason: 'feedback preview');
      await expectReachable(tester, find.text('Open email'));
    });

    testWidgets('Data sources & licences', (tester) async {
      await launch(tester);
      await openFromSettings(tester, 'Data sources & licences');

      await scrollThrough(tester, 'Data sources & licences');
    });

    testWidgets('onboarding: every slide, then its guide', (tester) async {
      await launch(tester, onboarding: true);

      for (var slide = 1; slide <= 3; slide++) {
        expect(tester.takeException(), isNull, reason: 'slide $slide');
        final next = find.text(slide < 3 ? 'Next' : 'See how it works');
        await expectReachable(tester, next);
        await tester.tap(next);
        await tester.pumpAndSettle();
      }

      await scrollThrough(tester, 'onboarding guide');
      await expectReachable(tester, find.text('Start using Schwa Notes'));
    });

    testWidgets('the recovery screen', (tester) async {
      stressSize(tester);
      await tester.pumpWidget(
        RecoveryApp(
          failure: const SchemaTooNewFailure(
            onDiskVersion: 99,
            supportedVersion: 2,
          ),
          onExport: () async => true,
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      await expectReachable(
        tester,
        find.widgetWithText(FilledButton, 'Export my data'),
      );
    });
  });

  group('sheets and dialogs', () {
    /// Opens [show] at the stress size inside a bare app. One with a text
    /// field is checked with the [keyboard] up - brought up after it opens,
    /// as on a device; one without cannot have it up.
    Future<void> open(
      WidgetTester tester,
      Future<Object?> Function(BuildContext context) show, {
      List<Override> overrides = const <Override>[],
      bool keyboard = false,
    }) async {
      stressSize(tester);
      await tester.pumpWidget(
        ProviderScope(
          overrides: overrides,
          child: MaterialApp(
            theme: AppTheme.light(),
            localizationsDelegates: AppL10n.localizationsDelegates,
            supportedLocales: AppL10n.supportedLocales,
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () => show(context),
                    child: const Text('open'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      if (keyboard) {
        tester.view.viewInsets = const FakeViewPadding(bottom: 1200);
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull, reason: 'no overflow');
    }

    testWidgets('the interval editor', (tester) async {
      await open(
        tester,
        (context) => IntervalEditorSheet.show(context, ReviewSchedule.standard),
        keyboard: true,
      );

      await expectReachable(tester, find.widgetWithText(FilledButton, 'Save'));
    });

    testWidgets('the import preview', (tester) async {
      await open(
        tester,
        (context) => ImportPreviewSheet.show(
          context,
          BackupManifest(
            appVersion: '1.0.0',
            schemaVersion: 2,
            formatVersion: 1,
            exportedAt: DateTime.utc(2026, 9, 11),
            counts: const <String, int>{'words': 240, 'word_lists': 3},
          ),
        ),
      );

      await expectReachable(tester, find.text('Replace everything'));
      await expectReachable(tester, find.text('Continue'));
    });

    testWidgets('the typed confirmation', (tester) async {
      await open(
        tester,
        (context) => showTypedConfirmation(
          context,
          title: 'Delete all data?',
          body:
              'Everything on this phone goes, including the copies kept '
              'from earlier restores. Without a backup, it cannot be '
              'brought back.',
          word: 'delete',
          action: 'Delete everything',
        ),
        keyboard: true,
      );

      await expectReachable(tester, find.byType(TextField));
      await expectReachable(tester, find.text('Delete everything'));
    });

    testWidgets('the privacy sheet', (tester) async {
      await open(tester, PrivacyNote.show);

      await expectReachable(
        tester,
        find.textContaining('leave it only in a backup you export'),
      );
    });

    testWidgets('the error log, with a long log', (tester) async {
      await open(
        tester,
        ErrorLogSheet.show,
        overrides: <Override>[errorLogProvider.overrideWithValue(_LongLog())],
      );
      for (var i = 0; i < 3; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pumpAndSettle();
      }

      expect(tester.takeException(), isNull);
      await expectReachable(tester, find.text('Clear log'));
    });
  });
}

/// A log with forty long entries: the sheet must scroll to its button.
class _LongLog implements ErrorLog {
  @override
  void record(Object error, StackTrace stackTrace) {}

  static String _entry(int i) =>
      '[2026-09-11T03:00:00.000Z] StateError: Bad state: something '
      'that went wrong in a way with a long message number $i\n'
      '  #0      somewhere (package:vocabnote/x.dart:$i)';

  @override
  AsyncResult<String> read() async => Ok<String, AppFailure>(
    <String>[for (var i = 0; i < 40; i++) _entry(i)].join('\n'),
  );

  @override
  AsyncResult<void> clear() async => const Ok<void, AppFailure>(null);
}
