import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Riverpod 3 moved `Override` out of the main barrel file.
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/app.dart';
import 'package:vocabnote/application/practice/scheduler/review_schedule.dart';
import 'package:vocabnote/application/settings/app_info.dart';
import 'package:vocabnote/data/composition_root.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/db/database_provider.dart';
import 'package:vocabnote/domain/entities/app_settings.dart';

import '../unit/application/fake_links.dart';
import '../unit/application/fake_reminder_service.dart';
import '../unit/application/fake_speech_service.dart';

/// The settings screen (F-070, `docs/UI-UX.md` §4.9), including the daily
/// reminder (F-066).
void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late FakeReminderService reminders;
  late FakeSpeechService speech;
  late FakeLinkOpener links;

  setUp(() async {
    db = AppDatabase.memory();
    await db.customSelect('SELECT 1').get();
    reminders = FakeReminderService();
    speech = FakeSpeechService();
    links = FakeLinkOpener();
  });

  tearDown(() => db.close());

  Future<void> launch(
    WidgetTester tester, {
    FutureOr<String>? appVersion,
    Uri? supportLink,
    bool noSupportPage = false,
  }) async {
    container = ProviderContainer(
      overrides: <Override>[
        appDatabaseProvider.overrideWithValue(db),
        if (noSupportPage)
          supportLinkProvider.overrideWithValue(null)
        else if (supportLink != null)
          supportLinkProvider.overrideWithValue(supportLink),
        ...repositoryOverrides(
          db,
          appVersion: appVersion,
          reminderService: reminders,
          speechService: speech,
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
  }

  Future<void> openSettings(
    WidgetTester tester, {
    FutureOr<String>? appVersion,
    Uri? supportLink,
    bool noSupportPage = false,
  }) async {
    await launch(
      tester,
      appVersion: appVersion,
      supportLink: supportLink,
      noSupportPage: noSupportPage,
    );
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
  }

  /// Writes are fired and not awaited; `pumpAndSettle` alone would return
  /// before the settings row changed.
  Future<void> settleAsync(WidgetTester tester) async {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();
  }

  /// Scrolls the settings list down until [finder] is on screen.
  ///
  /// Downwards only, so a run of these also proves the order of what it finds.
  Future<void> scrollTo(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: find
          .descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
  }

  Future<Map<String, Object?>> settingsRow(WidgetTester tester) async {
    final row = await tester.runAsync(
      () => db.customSelect('SELECT * FROM settings').getSingle(),
    );
    return row!.data;
  }

  Finder reminderSwitch() =>
      find.widgetWithText(SwitchListTile, 'Daily reminder');

  bool reminderOn(WidgetTester tester) =>
      tester.widget<SwitchListTile>(reminderSwitch()).value;

  group('the screen (UI-UX 4.9)', () {
    testWidgets('has every section, in order', (tester) async {
      await openSettings(tester);

      for (final heading in <String>[
        'Appearance',
        'Pronunciation',
        'Practice',
        'Your data',
        'Help',
        'About',
      ]) {
        await scrollTo(tester, find.text(heading));
        expect(find.text(heading), findsOneWidget);
      }
    });

    // F-092: the version is a platform-channel call that took 4.9s of a cold
    // start on the emulator, so nothing may wait for it - not the first frame,
    // and not this screen.
    testWidgets(
      'About does not wait for the version, and shows it once known',
      (tester) async {
        final version = Completer<String>();
        await openSettings(tester, appVersion: version.future);
        await scrollTo(tester, find.text('Version'));
        // The tile is built and on screen, so this absence means something.
        expect(find.text('1.2.3'), findsNothing);

        version.complete('1.2.3');
        await tester.pumpAndSettle();
        expect(find.text('1.2.3'), findsOneWidget);
      },
    );

    // M8: a gentle tip link, and only once there is a page to go to.
    testWidgets('Buy me a coffee is absent while there is no Ko-fi page', (
      tester,
    ) async {
      // The shipped build has a page, so "no page" is forced here.
      await openSettings(tester, noSupportPage: true);
      await scrollTo(tester, find.text('Privacy'));
      // Drag past the end, so the whole bottom of the list is built and on
      // screen and the absence below Privacy means something.
      await tester.drag(
        find
            .descendant(
              of: find.byType(ListView),
              matching: find.byType(Scrollable),
            )
            .first,
        const Offset(0, -800),
      );
      await tester.pumpAndSettle();

      expect(find.text('Privacy'), findsOneWidget);
      expect(find.text('Buy me a coffee'), findsNothing);
    });

    testWidgets('with a page, it says a tip unlocks nothing and opens it', (
      tester,
    ) async {
      final page = Uri.parse('https://ko-fi.com/example');
      await openSettings(tester, supportLink: page);

      final row = find.text('Buy me a coffee');
      await scrollTo(tester, row);
      expect(find.textContaining('unlocks nothing'), findsOneWidget);

      await tester.tap(row);
      await tester.pumpAndSettle();
      expect(links.opened, <Uri>[page]);
    });

    testWidgets('always offers How to use and Help & feedback (RULES §4)', (
      tester,
    ) async {
      await openSettings(tester);

      await scrollTo(tester, find.text('Help & feedback'));
      expect(find.text('How to use'), findsOneWidget);

      await tester.tap(find.text('Help & feedback'));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Help & feedback'),
        ),
        findsOneWidget,
      );
    });
  });

  group('appearance', () {
    testWidgets('choosing Dark turns the app dark at once', (tester) async {
      await openSettings(tester);

      await tester.tap(find.text('Theme'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dark'));
      await settleAsync(tester);

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.dark);
      expect((await settingsRow(tester))['theme_mode'], 'dark');
    });

    testWidgets('a saved theme is the one the app starts in', (tester) async {
      await db.customStatement("UPDATE settings SET theme_mode = 'light'");
      await launch(tester);

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.light);
    });
  });

  group('pronunciation', () {
    testWidgets('Test voice speaks in the saved voice, speed and pitch', (
      tester,
    ) async {
      await db.customStatement(
        "UPDATE settings SET tts_locale = 'en-US', tts_rate = 0.35, "
        'tts_pitch = 1.3',
      );
      await openSettings(tester);

      await scrollTo(tester, find.text('Test voice'));
      await tester.tap(find.text('Test voice'));
      await settleAsync(tester);

      expect(speech.spoken, hasLength(1));
      final said = speech.spoken.single;
      expect(said.text, 'pronunciation');
      expect(said.locale, TtsLocale.enUs);
      expect(said.rate, 0.35);
      expect(said.pitch, 1.3);
    });

    testWidgets('a device with no voice is told so, not left silent', (
      tester,
    ) async {
      speech.fail = true;
      await openSettings(tester);

      await scrollTo(tester, find.text('Test voice'));
      await tester.tap(find.text('Test voice'));
      await settleAsync(tester);

      expect(
        find.text('This device has no speech voice available.'),
        findsOneWidget,
      );
    });
  });

  group('practice', () {
    testWidgets('the daily goal is chosen from a list and remembered', (
      tester,
    ) async {
      await openSettings(tester);

      await scrollTo(tester, find.text('Daily goal'));
      expect(find.text('20 words a day'), findsOneWidget);
      await tester.tap(find.text('Daily goal'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('30 words a day'));
      await settleAsync(tester);

      expect((await settingsRow(tester))['daily_goal'], 30);
    });

    testWidgets('picking a pace rewrites the whole table', (tester) async {
      await openSettings(tester);

      await scrollTo(tester, find.text('Review pace'));
      await tester.tap(find.text('Review pace'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Gentle'));
      await settleAsync(tester);

      final stored = ReviewSchedule.fromStoredJson(
        (await settingsRow(tester))['review_schedule']! as String,
      );
      expect(stored, ReviewSchedule.forPace(IntervalPace.gentle));
    });

    testWidgets('the interval editor refuses a box that never comes back', (
      tester,
    ) async {
      await openSettings(tester);

      await scrollTo(tester, find.text('Days between reviews'));
      await tester.tap(find.text('Days between reviews'));
      await tester.pumpAndSettle();

      final box2 = find.widgetWithText(TextField, 'Box 2');
      await tester.enterText(box2, '0');
      await tester.pump();

      expect(
        find.text('Box 2 needs at least 1 day, or its words never come back.'),
        findsOneWidget,
      );
      final save = find.widgetWithText(FilledButton, 'Save');
      expect(tester.widget<FilledButton>(save).onPressed, isNull);

      await tester.enterText(box2, '3');
      await tester.pump();
      // Six fields fill a short screen; the sheet scrolls to its buttons.
      await tester.ensureVisible(save);
      await tester.pumpAndSettle();
      await tester.tap(save);
      await settleAsync(tester);

      expect(
        (await settingsRow(tester))['review_schedule'],
        '[0,1,3,4,7,15,30]',
      );
      // An edited table is no longer a preset, and the screen says so.
      await scrollTo(tester, find.text('Review pace'));
      expect(find.text('Your own'), findsOneWidget);
    });
  });

  group('your data', () {
    testWidgets('dictionary look-up can be switched off', (tester) async {
      await openSettings(tester);

      final lookup = find.widgetWithText(SwitchListTile, 'Dictionary look-up');
      await scrollTo(tester, lookup);
      await tester.tap(lookup);
      await settleAsync(tester);

      expect((await settingsRow(tester))['lookup_enabled'], 0);
    });
  });

  group('daily reminder (F-066)', () {
    Future<void> tapReminder(WidgetTester tester) async {
      await scrollTo(tester, reminderSwitch());
      await tester.tap(reminderSwitch());
      await settleAsync(tester);
    }

    testWidgets('launching the app asks nothing of the OS', (tester) async {
      // F-066: "asks permission only when enabled". RULES §6: no forced
      // notifications. Opening the app - even opening Settings - is not asking.
      await openSettings(tester);

      expect(reminders.permissionRequests, 0);
      expect(reminders.scheduled, isEmpty);
    });

    testWidgets('the reminder is off until switched on', (tester) async {
      await openSettings(tester);
      await scrollTo(tester, reminderSwitch());

      expect(find.text('Off'), findsOneWidget);
      expect(reminderOn(tester), isFalse);
    });

    testWidgets('switching it on asks, then says when it will come', (
      tester,
    ) async {
      await openSettings(tester);

      await tapReminder(tester);

      expect(reminders.permissionRequests, 1);
      expect(reminderOn(tester), isTrue);
      expect(find.text('Every day at 7:00 PM'), findsOneWidget);
      expect(find.text('Time'), findsOneWidget, reason: 'the time can change');
    });

    testWidgets('a refusal says how to allow it, and stays off', (
      tester,
    ) async {
      reminders.grant = false;
      await openSettings(tester);

      await tapReminder(tester);

      expect(reminderOn(tester), isFalse);
      expect(
        find.text(
          'Notifications are off for Schwa Notes. You can allow them in your '
          "phone's settings.",
        ),
        findsOneWidget,
      );
    });

    testWidgets('switching it off cancels it', (tester) async {
      await openSettings(tester);
      await tapReminder(tester);

      await tapReminder(tester);

      expect(reminders.cancels, 1);
      expect(reminderOn(tester), isFalse);
    });

    testWidgets('a reminder that is on is scheduled again at launch', (
      tester,
    ) async {
      // The schedule repeats on UTC; setting it again from local time at each
      // launch is what keeps a daylight saving change from lasting.
      await db.customStatement(
        'UPDATE settings SET reminder_enabled = 1, reminder_time_minutes = 480',
      );
      await launch(tester);
      await settleAsync(tester);

      expect(reminders.scheduled, <int>[480]);
      expect(reminders.permissionRequests, 0, reason: 'resync never asks');
    });
  });
}
