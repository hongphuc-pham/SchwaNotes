// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'practice_session_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Runs one practice session.

@ProviderFor(PracticeSessionRunner)
final practiceSessionRunnerProvider = PracticeSessionRunnerProvider._();

/// Runs one practice session.
final class PracticeSessionRunnerProvider
    extends $NotifierProvider<PracticeSessionRunner, PracticeSessionState?> {
  /// Runs one practice session.
  PracticeSessionRunnerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'practiceSessionRunnerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$practiceSessionRunnerHash();

  @$internal
  @override
  PracticeSessionRunner create() => PracticeSessionRunner();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PracticeSessionState? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PracticeSessionState?>(value),
    );
  }
}

String _$practiceSessionRunnerHash() =>
    r'66406b2efe59fe2a4019aef184f85baa032d2b8a';

/// Runs one practice session.

abstract class _$PracticeSessionRunner
    extends $Notifier<PracticeSessionState?> {
  PracticeSessionState? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PracticeSessionState?, PracticeSessionState?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PracticeSessionState?, PracticeSessionState?>,
              PracticeSessionState?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
