// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_actions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Changes one setting at a time.
///
/// Each change is a transform of the stored row, applied atomically by
/// `SettingsRepository.update`, so a slider released while a switch flips
/// cannot write back a stale copy of the other. Every screen watching
/// `appSettingsProvider` sees the result at once - nothing needs a restart.

@ProviderFor(SettingsActions)
final settingsActionsProvider = SettingsActionsProvider._();

/// Changes one setting at a time.
///
/// Each change is a transform of the stored row, applied atomically by
/// `SettingsRepository.update`, so a slider released while a switch flips
/// cannot write back a stale copy of the other. Every screen watching
/// `appSettingsProvider` sees the result at once - nothing needs a restart.
final class SettingsActionsProvider
    extends $NotifierProvider<SettingsActions, void> {
  /// Changes one setting at a time.
  ///
  /// Each change is a transform of the stored row, applied atomically by
  /// `SettingsRepository.update`, so a slider released while a switch flips
  /// cannot write back a stale copy of the other. Every screen watching
  /// `appSettingsProvider` sees the result at once - nothing needs a restart.
  SettingsActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsActionsHash();

  @$internal
  @override
  SettingsActions create() => SettingsActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$settingsActionsHash() => r'74fff2df89558fbf5af53cbedb92587951d7b053';

/// Changes one setting at a time.
///
/// Each change is a transform of the stored row, applied atomically by
/// `SettingsRepository.update`, so a slider released while a switch flips
/// cannot write back a stale copy of the other. Every screen watching
/// `appSettingsProvider` sees the result at once - nothing needs a restart.

abstract class _$SettingsActions extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
