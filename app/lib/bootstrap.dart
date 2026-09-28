import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Riverpod 3 moved `Override` out of the main barrel file.
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:vocabnote/app.dart';
import 'package:vocabnote/application/settings/app_info.dart';
import 'package:vocabnote/core/utils/bundled_licences.dart';
import 'package:vocabnote/data/composition_root.dart';
import 'package:vocabnote/data/db/database_opener.dart';
import 'package:vocabnote/data/db/database_provider.dart';
import 'package:vocabnote/data/diagnostics/file_error_log.dart';
import 'package:vocabnote/domain/repositories/error_log.dart';
import 'package:vocabnote/presentation/common/recovery_screen.dart';

/// Starts the app (`docs/ARCHITECTURE.md` section 6).
///
/// The sequence, in order:
///
/// 1. `WidgetsFlutterBinding.ensureInitialized()`
/// 2. resolve the database path
/// 3. back the database up if a migration is pending
/// 4. open Drift and run the `stepByStep` migration
/// 5. on migration failure, restore the backup, keep the old schema, and show a
///    non-destructive recovery screen with *Export my data* - **never** delete
///    the database
/// 6. load settings, build the theme, `runApp`
///
/// Steps 2-5 live in [DatabaseOpener], where they can be tested against a
/// temporary directory rather than a real device.
Future<void> bootstrap() async {
  // Uncaught errors are written to a local rolling log the user can attach from
  // Settings -> Help & feedback. There is no crash reporter and never will be
  // (`docs/RULES.md` section 1), so this zone is the only safety net.
  await runZonedGuarded(() async {
    // 1. Bindings must exist before any platform channel call.
    WidgetsFlutterBinding.ensureInitialized();

    // Opened before anything else that can fail, so an error while opening
    // the database is kept too (F-079).
    _errorLog = await FileErrorLog.open();

    // The fonts' licence texts, for Flutter's licence page (F-075). Lazy:
    // nothing is read until that page asks.
    BundledLicences.register();

    // Framework errors: build, layout, paint.
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      logUncaught(details.exception, details.stack ?? StackTrace.empty);
    };
    // Errors that escape the zone - platform-channel callbacks among them.
    // Flutter's error-handling docs name this pair; the zone below stays as
    // a third net. True: handled, so release builds do not also crash.
    WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
      logUncaught(error, stack);
      return true;
    };

    // 2-5.
    final opened = await DatabaseOpener().open();

    // Started, never awaited (F-092). It is a platform-channel call that was
    // 4.9s of a 5.2s cold start on the emulator at M7, and nothing before the
    // first frame needs it. About, the licences page, the look-up's User-Agent
    // and a backup's manifest each wait for it only when they need it.
    final version = resolveAppVersion();

    final database = opened.valueOrNull?.database;

    // Two single-row reads, awaited: the router's first location depends on
    // them, and deciding now is what keeps the words tab from flashing up
    // before onboarding (F-077).
    final onboarding = database != null && await resolveOnboarding(database);

    // Housekeeping, started but not awaited: the 30-day purge must not delay
    // the first frame (F-092).
    if (database != null) unawaited(purgeExpiredWords(database));

    // 6.
    opened.fold(
      (result) => runApp(
        ProviderScope(
          overrides: <Override>[
            appDatabaseProvider.overrideWithValue(result.database),
            showOnboardingProvider.overrideWithValue(onboarding),
            // The one place data implementations are named. Everything above
            // this line depends on domain interfaces only.
            ...repositoryOverrides(
              result.database,
              appVersion: version,
              errorLog: _errorLog,
            ),
          ],
          child: const VocabNoteApp(),
        ),
      ),
      (failure) {
        logUncaught(failure, StackTrace.current);
        // Deliberately not the normal app. Without a database there is nothing
        // to show, and offering a "reset" here is precisely the behaviour
        // docs/DATABASE.md section 3.8 forbids.
        // *Export my data* reads the file raw and read-only: Drift is exactly
        // what refused it, and the file itself is never written to.
        runApp(
          RecoveryApp(
            failure: failure,
            onExport: () => exportForRecovery(appVersion: version),
          ),
        );
      },
    );
  }, logUncaught);
}

/// Where uncaught errors are kept. Keeps nothing until `bootstrap` opens the
/// real log, which it does first.
ErrorLog _errorLog = const DiscardingErrorLog();

/// Records an uncaught error in the on-device log (F-079).
///
/// Nothing is ever transmitted: there is no backend to transmit to. The log
/// leaves the phone only inside a feedback email the user has read first.
void logUncaught(Object error, StackTrace stackTrace) {
  assert(() {
    debugPrint('Uncaught error: $error\n$stackTrace');
    return true;
  }(), 'debugPrint always returns true');
  _errorLog.record(error, stackTrace);
}
