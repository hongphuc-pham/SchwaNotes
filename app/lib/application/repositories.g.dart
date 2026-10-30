// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repositories.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Words, notes and highlights.

@ProviderFor(wordRepository)
final wordRepositoryProvider = WordRepositoryProvider._();

/// Words, notes and highlights.

final class WordRepositoryProvider
    extends $FunctionalProvider<WordRepository, WordRepository, WordRepository>
    with $Provider<WordRepository> {
  /// Words, notes and highlights.
  WordRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wordRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wordRepositoryHash();

  @$internal
  @override
  $ProviderElement<WordRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WordRepository create(Ref ref) {
    return wordRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WordRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WordRepository>(value),
    );
  }
}

String _$wordRepositoryHash() => r'e469268e63ae1d639c80a2a25cd34a1a165451be';

/// Lists (decks) and membership.

@ProviderFor(listRepository)
final listRepositoryProvider = ListRepositoryProvider._();

/// Lists (decks) and membership.

final class ListRepositoryProvider
    extends $FunctionalProvider<ListRepository, ListRepository, ListRepository>
    with $Provider<ListRepository> {
  /// Lists (decks) and membership.
  ListRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'listRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$listRepositoryHash();

  @$internal
  @override
  $ProviderElement<ListRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ListRepository create(Ref ref) {
    return listRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ListRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ListRepository>(value),
    );
  }
}

String _$listRepositoryHash() => r'4c1b1f11fd7e3aae14140425b0a2170d9aec382f';

/// Study cards, sessions and answers.

@ProviderFor(practiceRepository)
final practiceRepositoryProvider = PracticeRepositoryProvider._();

/// Study cards, sessions and answers.

final class PracticeRepositoryProvider
    extends
        $FunctionalProvider<
          PracticeRepository,
          PracticeRepository,
          PracticeRepository
        >
    with $Provider<PracticeRepository> {
  /// Study cards, sessions and answers.
  PracticeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'practiceRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$practiceRepositoryHash();

  @$internal
  @override
  $ProviderElement<PracticeRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PracticeRepository create(Ref ref) {
    return practiceRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PracticeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PracticeRepository>(value),
    );
  }
}

String _$practiceRepositoryHash() =>
    r'42eb5873017c5fdf19ecd2b91dd7383eb93d0fd8';

/// The settings row and `app_meta`.

@ProviderFor(settingsRepository)
final settingsRepositoryProvider = SettingsRepositoryProvider._();

/// The settings row and `app_meta`.

final class SettingsRepositoryProvider
    extends
        $FunctionalProvider<
          SettingsRepository,
          SettingsRepository,
          SettingsRepository
        >
    with $Provider<SettingsRepository> {
  /// The settings row and `app_meta`.
  SettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<SettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SettingsRepository create(Ref ref) {
    return settingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsRepository>(value),
    );
  }
}

String _$settingsRepositoryHash() =>
    r'fb266767dae061d3152a2cb58c226260e3b9e90c';

/// The device speech engine (ADR-003).
///
/// Declared here like a repository even though it is a device service rather
/// than a store, because it is the same kind of seam: ADR-003 promises that a
/// future `RemoteAudioService` can replace it without a screen changing, and
/// that only holds while nothing above `data/` names a speech plugin.

@ProviderFor(speechService)
final speechServiceProvider = SpeechServiceProvider._();

/// The device speech engine (ADR-003).
///
/// Declared here like a repository even though it is a device service rather
/// than a store, because it is the same kind of seam: ADR-003 promises that a
/// future `RemoteAudioService` can replace it without a screen changing, and
/// that only holds while nothing above `data/` names a speech plugin.

final class SpeechServiceProvider
    extends $FunctionalProvider<SpeechService, SpeechService, SpeechService>
    with $Provider<SpeechService> {
  /// The device speech engine (ADR-003).
  ///
  /// Declared here like a repository even though it is a device service rather
  /// than a store, because it is the same kind of seam: ADR-003 promises that a
  /// future `RemoteAudioService` can replace it without a screen changing, and
  /// that only holds while nothing above `data/` names a speech plugin.
  SpeechServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'speechServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$speechServiceHash();

  @$internal
  @override
  $ProviderElement<SpeechService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SpeechService create(Ref ref) {
    return speechService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SpeechService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SpeechService>(value),
    );
  }
}

String _$speechServiceHash() => r'29b12740eff03a583766bc282efa2bfad9165b99';

/// The daily reminder (F-066).
///
/// A device service behind an interface, like [speechService], so nothing
/// above `data/` names a notification plugin.

@ProviderFor(reminderService)
final reminderServiceProvider = ReminderServiceProvider._();

/// The daily reminder (F-066).
///
/// A device service behind an interface, like [speechService], so nothing
/// above `data/` names a notification plugin.

final class ReminderServiceProvider
    extends
        $FunctionalProvider<ReminderService, ReminderService, ReminderService>
    with $Provider<ReminderService> {
  /// The daily reminder (F-066).
  ///
  /// A device service behind an interface, like [speechService], so nothing
  /// above `data/` names a notification plugin.
  ReminderServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reminderServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reminderServiceHash();

  @$internal
  @override
  $ProviderElement<ReminderService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReminderService create(Ref ref) {
    return reminderService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReminderService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReminderService>(value),
    );
  }
}

String _$reminderServiceHash() => r'a9dcdc5e79dfc893f3abb8dd6d40adcc6bc56c76';

/// Backing up, bringing a backup in, and removing everything (F-073, F-074).

@ProviderFor(userDataRepository)
final userDataRepositoryProvider = UserDataRepositoryProvider._();

/// Backing up, bringing a backup in, and removing everything (F-073, F-074).

final class UserDataRepositoryProvider
    extends
        $FunctionalProvider<
          UserDataRepository,
          UserDataRepository,
          UserDataRepository
        >
    with $Provider<UserDataRepository> {
  /// Backing up, bringing a backup in, and removing everything (F-073, F-074).
  UserDataRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userDataRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userDataRepositoryHash();

  @$internal
  @override
  $ProviderElement<UserDataRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UserDataRepository create(Ref ref) {
    return userDataRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserDataRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserDataRepository>(value),
    );
  }
}

String _$userDataRepositoryHash() =>
    r'cccd1609f7f9311645c6dd415a7f7470fe3ac535';

/// Bringing words in from a CSV deck (F-010).

@ProviderFor(wordImportRepository)
final wordImportRepositoryProvider = WordImportRepositoryProvider._();

/// Bringing words in from a CSV deck (F-010).

final class WordImportRepositoryProvider
    extends
        $FunctionalProvider<
          WordImportRepository,
          WordImportRepository,
          WordImportRepository
        >
    with $Provider<WordImportRepository> {
  /// Bringing words in from a CSV deck (F-010).
  WordImportRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wordImportRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wordImportRepositoryHash();

  @$internal
  @override
  $ProviderElement<WordImportRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WordImportRepository create(Ref ref) {
    return wordImportRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WordImportRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WordImportRepository>(value),
    );
  }
}

String _$wordImportRepositoryHash() =>
    r'747b2fe6b31e99b78c6d1eb07d3f31d42a5ecd85';

/// The OS share sheet and file picker (F-073, F-074).
///
/// A device service behind an interface, like [speechService], so nothing
/// above `data/` names a plugin.

@ProviderFor(backupFiles)
final backupFilesProvider = BackupFilesProvider._();

/// The OS share sheet and file picker (F-073, F-074).
///
/// A device service behind an interface, like [speechService], so nothing
/// above `data/` names a plugin.

final class BackupFilesProvider
    extends $FunctionalProvider<BackupFiles, BackupFiles, BackupFiles>
    with $Provider<BackupFiles> {
  /// The OS share sheet and file picker (F-073, F-074).
  ///
  /// A device service behind an interface, like [speechService], so nothing
  /// above `data/` names a plugin.
  BackupFilesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupFilesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupFilesHash();

  @$internal
  @override
  $ProviderElement<BackupFiles> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BackupFiles create(Ref ref) {
    return backupFiles(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BackupFiles value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BackupFiles>(value),
    );
  }
}

String _$backupFilesHash() => r'c3a81e54bc850c5303aa82e0c8cc6b837c9d9023';

/// The on-device record of uncaught errors (F-079).

@ProviderFor(errorLog)
final errorLogProvider = ErrorLogProvider._();

/// The on-device record of uncaught errors (F-079).

final class ErrorLogProvider
    extends $FunctionalProvider<ErrorLog, ErrorLog, ErrorLog>
    with $Provider<ErrorLog> {
  /// The on-device record of uncaught errors (F-079).
  ErrorLogProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'errorLogProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$errorLogHash();

  @$internal
  @override
  $ProviderElement<ErrorLog> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ErrorLog create(Ref ref) {
    return errorLog(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ErrorLog value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ErrorLog>(value),
    );
  }
}

String _$errorLogHash() => r'0e0232b56aa68a4f0d9067dd68ef6eeda5907c0b';

/// The three facts a feedback email carries (F-072).

@ProviderFor(diagnosticsSource)
final diagnosticsSourceProvider = DiagnosticsSourceProvider._();

/// The three facts a feedback email carries (F-072).

final class DiagnosticsSourceProvider
    extends
        $FunctionalProvider<
          DiagnosticsSource,
          DiagnosticsSource,
          DiagnosticsSource
        >
    with $Provider<DiagnosticsSource> {
  /// The three facts a feedback email carries (F-072).
  DiagnosticsSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'diagnosticsSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$diagnosticsSourceHash();

  @$internal
  @override
  $ProviderElement<DiagnosticsSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DiagnosticsSource create(Ref ref) {
    return diagnosticsSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DiagnosticsSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DiagnosticsSource>(value),
    );
  }
}

String _$diagnosticsSourceHash() => r'6a4bb867f068d462630b79d95407b171a12d230a';

/// Opening a link in another app - the browser, the mail app.

@ProviderFor(linkOpener)
final linkOpenerProvider = LinkOpenerProvider._();

/// Opening a link in another app - the browser, the mail app.

final class LinkOpenerProvider
    extends $FunctionalProvider<LinkOpener, LinkOpener, LinkOpener>
    with $Provider<LinkOpener> {
  /// Opening a link in another app - the browser, the mail app.
  LinkOpenerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'linkOpenerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$linkOpenerHash();

  @$internal
  @override
  $ProviderElement<LinkOpener> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LinkOpener create(Ref ref) {
    return linkOpener(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LinkOpener value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LinkOpener>(value),
    );
  }
}

String _$linkOpenerHash() => r'5113201d104bb37825f8b3e63dc13313f75b14bc';

/// Dictionary look-up: cache, then API, then the bundled offline asset.

@ProviderFor(dictionaryRepository)
final dictionaryRepositoryProvider = DictionaryRepositoryProvider._();

/// Dictionary look-up: cache, then API, then the bundled offline asset.

final class DictionaryRepositoryProvider
    extends
        $FunctionalProvider<
          DictionaryRepository,
          DictionaryRepository,
          DictionaryRepository
        >
    with $Provider<DictionaryRepository> {
  /// Dictionary look-up: cache, then API, then the bundled offline asset.
  DictionaryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dictionaryRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dictionaryRepositoryHash();

  @$internal
  @override
  $ProviderElement<DictionaryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DictionaryRepository create(Ref ref) {
    return dictionaryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DictionaryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DictionaryRepository>(value),
    );
  }
}

String _$dictionaryRepositoryHash() =>
    r'dc7ce5d6d1f44aab7cd0895b7b324aa50dfa9ec1';
