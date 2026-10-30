/// The dependency-injection seam between `application/` and `data/`.
///
/// `docs/ARCHITECTURE.md` §1 is explicit that application "depends on
/// interfaces only", and `docs/RULES.md` §20 forbids the import that would
/// otherwise be needed. So every repository is declared **here**, typed against
/// its `domain/` interface, with no default implementation.
///
/// `bootstrap.dart` - a composition root, and the only place wiring is supposed
/// to cross layers - overrides each one with the concrete `data/` class. Tests
/// override them with fakes or an in-memory database.
///
/// Reading one without an override throws immediately, with a message saying
/// so, rather than silently constructing a second database somewhere
/// unexpected. `test/architecture/layer_boundaries_test.dart` is what keeps
/// this file honest.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vocabnote/domain/repositories/backup_files.dart';
import 'package:vocabnote/domain/repositories/diagnostics_source.dart';
import 'package:vocabnote/domain/repositories/dictionary_repository.dart';
import 'package:vocabnote/domain/repositories/error_log.dart';
import 'package:vocabnote/domain/repositories/link_opener.dart';
import 'package:vocabnote/domain/repositories/list_repository.dart';
import 'package:vocabnote/domain/repositories/practice_repository.dart';
import 'package:vocabnote/domain/repositories/reminder_service.dart';
import 'package:vocabnote/domain/repositories/settings_repository.dart';
import 'package:vocabnote/domain/repositories/speech_service.dart';
import 'package:vocabnote/domain/repositories/user_data_repository.dart';
import 'package:vocabnote/domain/repositories/word_import_repository.dart';
import 'package:vocabnote/domain/repositories/word_repository.dart';

part 'repositories.g.dart';

/// Words, notes and highlights.
@Riverpod(keepAlive: true)
WordRepository wordRepository(Ref ref) => throw UnimplementedError(
  'wordRepositoryProvider must be overridden in bootstrap() or in a test.',
);

/// Lists (decks) and membership.
@Riverpod(keepAlive: true)
ListRepository listRepository(Ref ref) => throw UnimplementedError(
  'listRepositoryProvider must be overridden in bootstrap() or in a test.',
);

/// Study cards, sessions and answers.
@Riverpod(keepAlive: true)
PracticeRepository practiceRepository(Ref ref) => throw UnimplementedError(
  'practiceRepositoryProvider must be overridden in bootstrap() or in a test.',
);

/// The settings row and `app_meta`.
@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) => throw UnimplementedError(
  'settingsRepositoryProvider must be overridden in bootstrap() or in a test.',
);

/// The device speech engine (ADR-003).
///
/// Declared here like a repository even though it is a device service rather
/// than a store, because it is the same kind of seam: ADR-003 promises that a
/// future `RemoteAudioService` can replace it without a screen changing, and
/// that only holds while nothing above `data/` names a speech plugin.
@Riverpod(keepAlive: true)
SpeechService speechService(Ref ref) => throw UnimplementedError(
  'speechServiceProvider must be overridden in bootstrap() or in a test.',
);

/// The daily reminder (F-066).
///
/// A device service behind an interface, like [speechService], so nothing
/// above `data/` names a notification plugin.
@Riverpod(keepAlive: true)
ReminderService reminderService(Ref ref) => throw UnimplementedError(
  'reminderServiceProvider must be overridden in bootstrap() or in a test.',
);

/// Backing up, bringing a backup in, and removing everything (F-073, F-074).
@Riverpod(keepAlive: true)
UserDataRepository userDataRepository(Ref ref) => throw UnimplementedError(
  'userDataRepositoryProvider must be overridden in bootstrap() or in a '
  'test.',
);

/// Bringing words in from a CSV deck (F-010).
@Riverpod(keepAlive: true)
WordImportRepository wordImportRepository(Ref ref) => throw UnimplementedError(
  'wordImportRepositoryProvider must be overridden in bootstrap() or in a '
  'test.',
);

/// The OS share sheet and file picker (F-073, F-074).
///
/// A device service behind an interface, like [speechService], so nothing
/// above `data/` names a plugin.
@Riverpod(keepAlive: true)
BackupFiles backupFiles(Ref ref) => throw UnimplementedError(
  'backupFilesProvider must be overridden in bootstrap() or in a test.',
);

/// The on-device record of uncaught errors (F-079).
@Riverpod(keepAlive: true)
ErrorLog errorLog(Ref ref) => throw UnimplementedError(
  'errorLogProvider must be overridden in bootstrap() or in a test.',
);

/// The three facts a feedback email carries (F-072).
@Riverpod(keepAlive: true)
DiagnosticsSource diagnosticsSource(Ref ref) => throw UnimplementedError(
  'diagnosticsSourceProvider must be overridden in bootstrap() or in a '
  'test.',
);

/// Opening a link in another app - the browser, the mail app.
@Riverpod(keepAlive: true)
LinkOpener linkOpener(Ref ref) => throw UnimplementedError(
  'linkOpenerProvider must be overridden in bootstrap() or in a test.',
);

/// Dictionary look-up: cache, then API, then the bundled offline asset.
@Riverpod(keepAlive: true)
DictionaryRepository dictionaryRepository(Ref ref) => throw UnimplementedError(
  'dictionaryRepositoryProvider must be overridden in bootstrap() or in a '
  'test.',
);
