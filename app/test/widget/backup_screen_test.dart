import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Riverpod 3 moved `Override` out of the main barrel file.
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/app.dart';
import 'package:vocabnote/data/backup/backup_codec.dart';
import 'package:vocabnote/data/composition_root.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/db/database_provider.dart';

import '../unit/application/fake_backup_files.dart';
import '../unit/application/fake_reminder_service.dart';
import '../unit/application/fake_speech_service.dart';
import '../unit/data/backup_support.dart';
import '../unit/data/db_fixtures.dart';

/// Backup & restore (F-073, `docs/UI-UX.md` §4.9).
void main() {
  late AppDatabase db;
  late Directory folder;
  late Directory safety;
  late FakeBackupFiles files;
  late ProviderContainer container;

  setUp(() async {
    db = AppDatabase.memory();
    await db.customSelect('SELECT 1').get();
    folder = await Directory.systemTemp.createTemp('vnb_screen_');
    safety = await Directory.systemTemp.createTemp('vnb_screen_safety_');
    files = FakeBackupFiles();
  });

  tearDown(() async {
    await db.close();
    await folder.delete(recursive: true);
    await safety.delete(recursive: true);
  });

  Future<void> openBackup(WidgetTester tester) async {
    container = ProviderContainer(
      overrides: <Override>[
        appDatabaseProvider.overrideWithValue(db),
        ...repositoryOverrides(
          db,
          speechService: FakeSpeechService(),
          reminderService: FakeReminderService(),
          backupFiles: files,
          exportDirectory: () async => folder,
          safetyDirectory: () async => safety,
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

    final row = find.text('Backup & restore');
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
    // scrollUntilVisible stops once the row is built, which can still be
    // below the 600px test surface; a tap there silently misses.
    await tester.ensureVisible(row);
    await tester.pumpAndSettle();
    await tester.tap(row);
    await tester.pumpAndSettle();
  }

  /// Pumps until [done], letting real time pass between frames.
  ///
  /// Exporting encodes on another isolate, lists a folder and writes a real
  /// file. Each of those completes in real time, and each completion then
  /// needs a frame in the test's fake time before the next step can start -
  /// so one long wait is not enough, and a fixed number of short ones is a
  /// guess. Capped, so a genuinely stuck export fails rather than hangs.
  Future<void> settleUntil(WidgetTester tester, bool Function() done) async {
    for (var i = 0; i < 50 && !done(); i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  bool showing(Finder finder) => finder.evaluate().isNotEmpty;

  testWidgets('says plainly when there has never been a backup', (
    tester,
  ) async {
    await openBackup(tester);

    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Backup & restore'),
      ),
      findsOneWidget,
    );
    expect(find.text("You haven't made a backup yet."), findsOneWidget);
  });

  testWidgets('Export hands a .vnb to the share sheet and remembers it', (
    tester,
  ) async {
    await openBackup(tester);

    await tester.tap(find.text('Export backup'));
    await settleUntil(
      tester,
      () => showing(find.textContaining('Last backup:')),
    );

    expect(files.shared, hasLength(1));
    expect(files.shared.single.path, endsWith('.vnb'));
    expect(find.textContaining('Last backup:'), findsOneWidget);
    expect(find.text("You haven't made a backup yet."), findsNothing);
  });

  testWidgets('a share sheet that fails says so, and nothing is recorded', (
    tester,
  ) async {
    files.fail = true;
    await openBackup(tester);
    final failed = find.text(
      "Couldn't make the backup just now. Your words are safe - please "
      'try again.',
    );

    await tester.tap(find.text('Export backup'));
    await settleUntil(tester, () => showing(failed));

    expect(failed, findsOneWidget);
    expect(find.text("You haven't made a backup yet."), findsOneWidget);
  });

  group('importing (F-074)', () {
    /// A real `.vnb` made on another "phone": two words and a list.
    Future<Uint8List> otherPhonesBackup() async {
      final other = AppDatabase.memory();
      addTearDown(other.close);
      await seedWord(other, id: 'b1', headword: 'cough');
      await seedWord(other, id: 'b2', headword: 'church');
      await seedList(other, id: 'l1', name: 'IELTS');
      final tables = await snapshot(other);
      return BackupCodec.encode(
        BackupCodec.manifestFor(
          appVersion: '1.0.0',
          schemaVersion: AppDatabase.latestSchemaVersion,
          exportedAt: testNow,
          tables: tables,
        ),
        tables,
      );
    }

    Future<void> tapImport(WidgetTester tester) async {
      final button = find.text('Import backup');
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
    }

    Future<List<Object?>> wordIds(WidgetTester tester) async {
      final rows = await tester.runAsync(
        () => db.customSelect('SELECT id FROM words ORDER BY rowid').get(),
      );
      return <Object?>[for (final row in rows!) row.data['id']];
    }

    Future<void> tapText(WidgetTester tester, String text) async {
      final target = find.text(text);
      await tester.ensureVisible(target);
      await tester.pumpAndSettle();
      await tester.tap(target);
      await tester.pumpAndSettle();
    }

    final preview = find.text('Bring in this backup?');
    final report = find.text('Your backup is in');

    testWidgets('a picker closed without choosing changes nothing', (
      tester,
    ) async {
      await openBackup(tester);

      await tapImport(tester);
      await settleUntil(tester, () => files.picks == 1);

      expect(preview, findsNothing);
      expect(await wordIds(tester), isEmpty);
    });

    testWidgets('a file that is not a backup is named as such', (tester) async {
      files.picked = Uint8List.fromList(<int>[1, 2, 3, 4, 5]);
      await openBackup(tester);
      final notOurs = find.text(
        "That file isn't a Schwa Notes backup. Backups end in .vnb.",
      );

      await tapImport(tester);
      await settleUntil(tester, () => showing(notOurs));

      expect(notOurs, findsOneWidget);
      expect(preview, findsNothing);
    });

    testWidgets('merge: the preview says what is inside, then it arrives', (
      tester,
    ) async {
      files.picked = await otherPhonesBackup();
      await openBackup(tester);

      await tapImport(tester);
      await settleUntil(tester, () => showing(preview));

      expect(find.textContaining('2 words'), findsOneWidget);
      expect(find.textContaining('1 list'), findsOneWidget);

      // Merge is the default; nothing to choose.
      await tapText(tester, 'Continue');
      await settleUntil(tester, () => showing(report));

      expect(find.text('2 words added'), findsOneWidget);
      await tapText(tester, 'Done');
      expect(await wordIds(tester), <Object?>['b1', 'b2']);
    });

    testWidgets('replace needs its word typed, keeps a copy, and says so', (
      tester,
    ) async {
      await seedWord(db, id: 'mine', headword: 'mine');
      files.picked = await otherPhonesBackup();
      await openBackup(tester);

      await tapImport(tester);
      await settleUntil(tester, () => showing(preview));
      await tapText(tester, 'Replace everything');
      await tapText(tester, 'Continue');

      expect(find.text('Replace everything on this phone?'), findsOneWidget);
      final replace = find.widgetWithText(FilledButton, 'Replace');
      expect(
        tester.widget<FilledButton>(replace).onPressed,
        isNull,
        reason: 'RULES §11: a typed confirmation, not one tap',
      );
      await tester.enterText(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextField),
        ),
        'replace',
      );
      await tester.pump();
      await tester.tap(replace);
      await settleUntil(tester, () => showing(report));

      expect(find.text('2 words restored'), findsOneWidget);
      expect(
        find.text('A copy of what was here before is kept on this phone.'),
        findsOneWidget,
      );
      expect(await wordIds(tester), <Object?>['b1', 'b2']);
      expect(safety.listSync().whereType<File>(), hasLength(1));
    });

    testWidgets('backing out of the typed confirmation changes nothing', (
      tester,
    ) async {
      await seedWord(db, id: 'mine', headword: 'mine');
      files.picked = await otherPhonesBackup();
      await openBackup(tester);

      await tapImport(tester);
      await settleUntil(tester, () => showing(preview));
      await tapText(tester, 'Replace everything');
      await tapText(tester, 'Continue');
      await tapText(tester, 'Cancel');

      expect(report, findsNothing);
      expect(await wordIds(tester), <Object?>['mine']);
      expect(safety.listSync(), isEmpty);
    });
  });
}
