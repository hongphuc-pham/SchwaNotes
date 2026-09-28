import 'dart:async';
import 'dart:io';

// Riverpod 3 moved `Override` out of the main barrel file.
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:vocabnote/application/repositories.dart';
import 'package:vocabnote/application/settings/app_info.dart';
import 'package:vocabnote/data/backup/platform_backup_files.dart';
import 'package:vocabnote/data/backup/recovery_export.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/db/database_opener.dart';
import 'package:vocabnote/data/db/tables/app_meta.dart';
import 'package:vocabnote/data/diagnostics/file_error_log.dart';
import 'package:vocabnote/data/diagnostics/platform_diagnostics.dart';
import 'package:vocabnote/data/dictionary/dictionary_cache.dart';
import 'package:vocabnote/data/dictionary/free_dictionary_client.dart';
import 'package:vocabnote/data/dictionary/offline_ipa_source.dart';
import 'package:vocabnote/data/links/url_launcher_link_opener.dart';
import 'package:vocabnote/data/notifications/local_notifications_reminder_service.dart';
import 'package:vocabnote/data/repositories/dictionary_repository_impl.dart';
import 'package:vocabnote/data/repositories/list_repository_impl.dart';
import 'package:vocabnote/data/repositories/practice_repository_impl.dart';
import 'package:vocabnote/data/repositories/settings_repository_impl.dart';
import 'package:vocabnote/data/repositories/user_data_repository_impl.dart';
import 'package:vocabnote/data/repositories/word_repository_impl.dart';
import 'package:vocabnote/data/speech/flutter_tts_service.dart';
import 'package:vocabnote/domain/repositories/backup_files.dart';
import 'package:vocabnote/domain/repositories/diagnostics_source.dart';
import 'package:vocabnote/domain/repositories/error_log.dart';
import 'package:vocabnote/domain/repositories/link_opener.dart';
import 'package:vocabnote/domain/repositories/practice_repository.dart';
import 'package:vocabnote/domain/repositories/reminder_service.dart';
import 'package:vocabnote/domain/repositories/speech_service.dart';

/// Wires `data/` implementations into the `application/` DI seam.
///
/// The one place concrete classes are named. `application/repositories.dart`
/// declares each provider against its `domain/` interface and throws by
/// default; this supplies the real thing.
///
/// Kept in `data/` rather than in `bootstrap.dart` so tests can build the same
/// overrides against an in-memory database with one call, instead of
/// duplicating this list and drifting from it.
///
/// [speechService] is injectable because a widget test has no audio device and
/// Riverpod 3 refuses a second override of the same provider in one container -
/// so a test cannot simply layer its fake on top of this list.
///
/// [reminderService] is injectable for the same reason: a test records what
/// would have been asked of the OS instead of asking it.
///
/// [backupFiles] and [exportDirectory] likewise: a test has no share sheet
/// and no `path_provider`, so it records the share and names a temporary
/// folder.
///
/// [appVersion] may still be on its way - `bootstrap` does not wait for it
/// (F-092) - so everything here that needs it waits for it itself.
List<Override> repositoryOverrides(
  AppDatabase database, {
  FutureOr<String>? appVersion,
  SpeechService? speechService,
  ReminderService? reminderService,
  BackupFiles? backupFiles,
  Future<Directory> Function()? exportDirectory,
  Future<Directory> Function()? safetyDirectory,
  Future<Directory> Function()? libraryDirectory,
  ErrorLog? errorLog,
  LinkOpener? linkOpener,
  DiagnosticsSource? diagnostics,
  // Injectable like the services above, so a test can make practice fail and
  // see what the run screen does about it.
  PracticeRepository? practiceRepository,
}) {
  final offline = OfflineIpaSource();
  // One cache, shared: *Delete all data* must clear the very instance the
  // dictionary look-up writes through.
  final dictionaryCache = DictionaryCache();
  final version = Future<String>.value(appVersion ?? '0.0.0');
  final client = FreeDictionaryClient(
    // Descriptive, as community APIs expect (docs/DATA-SOURCES.md §1).
    userAgent: version.then(
      (v) => 'SchwaNotes/$v (github.com/hongphuc-pham/SchwaNotes)',
    ),
  );

  return <Override>[
    appVersionProvider.overrideWith((ref) => version),
    wordRepositoryProvider.overrideWithValue(WordRepositoryImpl(database)),
    listRepositoryProvider.overrideWithValue(ListRepositoryImpl(database)),
    practiceRepositoryProvider.overrideWithValue(
      practiceRepository ?? PracticeRepositoryImpl(database),
    ),
    settingsRepositoryProvider.overrideWithValue(
      SettingsRepositoryImpl(database),
    ),
    // Constructed eagerly but inert: nothing reaches a platform channel until
    // the first call, so widget tests that build these overrides do not need a
    // speech engine to exist.
    speechServiceProvider.overrideWithValue(
      speechService ?? FlutterTtsService(),
    ),
    // Inert in the same way: nothing is initialised until the user switches
    // the reminder on.
    reminderServiceProvider.overrideWithValue(
      reminderService ?? LocalNotificationsReminderService(),
    ),
    userDataRepositoryProvider.overrideWithValue(
      UserDataRepositoryImpl(
        database,
        appVersion: version,
        exportDirectory: exportDirectory,
        safetyDirectory: safetyDirectory,
        libraryDirectory: libraryDirectory,
        dictionaryCache: dictionaryCache,
      ),
    ),
    // bootstrap opens the real log before the database; a test that does not
    // ask for one keeps nothing.
    errorLogProvider.overrideWithValue(errorLog ?? const DiscardingErrorLog()),
    // Inert until a tap in Help: nothing is read or opened before then.
    linkOpenerProvider.overrideWithValue(
      linkOpener ?? const UrlLauncherLinkOpener(),
    ),
    diagnosticsSourceProvider.overrideWithValue(
      diagnostics ?? const PlatformDiagnostics(),
    ),
    // Inert like the two above: the share sheet opens only on Export.
    backupFilesProvider.overrideWithValue(
      backupFiles ?? const PlatformBackupFiles(),
    ),
    dictionaryRepositoryProvider.overrideWithValue(
      DictionaryRepositoryImpl(
        client: client,
        cache: dictionaryCache,
        offline: offline,
      ),
    ),
  ];
}

/// Removes words the user deleted more than 30 days ago.
///
/// The only hard delete of user content in the app, and only after the
/// retention window `docs/RULES.md` §10 allows. Run once per launch and
/// deliberately **not awaited** by `bootstrap`: a purge is housekeeping, and
/// making the user wait for it would eat into the 2s cold-start budget (F-092).
///
/// Failures are swallowed. Not purging is harmless - it happens again next
/// launch - whereas surfacing "could not delete your deleted words" would be a
/// confusing thing to greet someone with.
Future<void> purgeExpiredWords(AppDatabase database) async {
  try {
    await WordRepositoryImpl(database).purgeExpired();
  } on Object {
    // Deliberately ignored. See the doc comment.
  }
}

/// Whether this launch should open on onboarding (F-077).
///
/// Only when it has never been finished **and** there are no words. The
/// second half is for the user upgrading from a build without onboarding:
/// every install before M6 was seeded with `onboarding_completed = false`, and
/// greeting someone with five hundred words as new would be absurd. They are
/// marked done silently, so it stays that way.
///
/// Any failure answers false: an app that opens on its words is always
/// usable, while one stuck opening on onboarding might not be.
Future<bool> resolveOnboarding(AppDatabase database) async {
  try {
    final meta = database.metaDao;
    if (await meta.getBool(AppMetaKeys.onboardingCompleted)) return false;
    final anyWord = await database
        .customSelect('SELECT EXISTS (SELECT 1 FROM words) AS any_word')
        .getSingle();
    if (anyWord.read<int>('any_word') == 1) {
      await meta.setBool(AppMetaKeys.onboardingCompleted, value: true);
      return false;
    }
    return true;
  } on Object {
    return false;
  }
}

/// *Export my data* on the recovery screen (DATABASE §3.6, §3.10).
///
/// The database Drift refused, read raw and read-only into the same `.vnb`
/// as any other backup, then offered to the share sheet. True when the sheet
/// opened; false for anything else, which the screen reports - without ever
/// having written to the database.
Future<bool> exportForRecovery({required FutureOr<String> appVersion}) async {
  try {
    final location = await DatabaseOpener().resolveLocation();
    final temporary = await getTemporaryDirectory();
    final exported = await exportUnopenableDatabase(
      database: location.file,
      appVersion: await appVersion,
      exportDirectory: Directory(p.join(temporary.path, 'vocabnote', 'export')),
    );
    final backup = exported.valueOrNull;
    if (backup == null) return false;
    return (await const PlatformBackupFiles().share(backup)).isOk;
  } on Object {
    return false;
  }
}

/// Reads the app version for the dictionary `User-Agent`.
///
/// Falls back rather than failing: a look-up must not depend on a platform
/// channel answering.
Future<String> resolveAppVersion() async {
  try {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  } on Object {
    return '0.0.0';
  }
}
