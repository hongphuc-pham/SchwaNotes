// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_info.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app's version as the platform reports it, e.g. `1.0.0`.
///
/// Started by `bootstrap` and **never waited for there**: it is a
/// platform-channel call, and on the emulator at M7 it was 4.9s of a 5.2s cold
/// start (F-092). Whatever shows it reads the value once it has arrived.
/// Supplied by the composition root, and declared here like the repositories
/// for the same reason: nothing above `data/` may name `package_info_plus`.

@ProviderFor(appVersion)
final appVersionProvider = AppVersionProvider._();

/// The app's version as the platform reports it, e.g. `1.0.0`.
///
/// Started by `bootstrap` and **never waited for there**: it is a
/// platform-channel call, and on the emulator at M7 it was 4.9s of a 5.2s cold
/// start (F-092). Whatever shows it reads the value once it has arrived.
/// Supplied by the composition root, and declared here like the repositories
/// for the same reason: nothing above `data/` may name `package_info_plus`.

final class AppVersionProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// The app's version as the platform reports it, e.g. `1.0.0`.
  ///
  /// Started by `bootstrap` and **never waited for there**: it is a
  /// platform-channel call, and on the emulator at M7 it was 4.9s of a 5.2s cold
  /// start (F-092). Whatever shows it reads the value once it has arrived.
  /// Supplied by the composition root, and declared here like the repositories
  /// for the same reason: nothing above `data/` may name `package_info_plus`.
  AppVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appVersionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appVersionHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return appVersion(ref);
  }
}

String _$appVersionHash() => r'b49af366e28e50b0453f9b27095d91083f0f0971';

/// Whether this launch opens on onboarding (F-077).
///
/// Decided once in `bootstrap`, before the first frame, so the router knows
/// its first location synchronously and the words tab never flashes up
/// before a redirect. False unless bootstrap says otherwise - so a test that
/// is not about onboarding starts where every other launch does.

@ProviderFor(showOnboarding)
final showOnboardingProvider = ShowOnboardingProvider._();

/// Whether this launch opens on onboarding (F-077).
///
/// Decided once in `bootstrap`, before the first frame, so the router knows
/// its first location synchronously and the words tab never flashes up
/// before a redirect. False unless bootstrap says otherwise - so a test that
/// is not about onboarding starts where every other launch does.

final class ShowOnboardingProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether this launch opens on onboarding (F-077).
  ///
  /// Decided once in `bootstrap`, before the first frame, so the router knows
  /// its first location synchronously and the words tab never flashes up
  /// before a redirect. False unless bootstrap says otherwise - so a test that
  /// is not about onboarding starts where every other launch does.
  ShowOnboardingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'showOnboardingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$showOnboardingHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return showOnboarding(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$showOnboardingHash() => r'74055113aa99f92afdf6ad091a0348e69a7b4edb';

/// Where *Send feedback* writes to, or null when this build has no address.
///
/// Set with `--dart-define=FEEDBACK_EMAIL=…` at release (M8). Until then Help
/// offers GitHub Issues only: an address baked into the app is public, and
/// it is the owner's to choose (`plan.md`, decided 11 Sep).

@ProviderFor(feedbackAddress)
final feedbackAddressProvider = FeedbackAddressProvider._();

/// Where *Send feedback* writes to, or null when this build has no address.
///
/// Set with `--dart-define=FEEDBACK_EMAIL=…` at release (M8). Until then Help
/// offers GitHub Issues only: an address baked into the app is public, and
/// it is the owner's to choose (`plan.md`, decided 11 Sep).

final class FeedbackAddressProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// Where *Send feedback* writes to, or null when this build has no address.
  ///
  /// Set with `--dart-define=FEEDBACK_EMAIL=…` at release (M8). Until then Help
  /// offers GitHub Issues only: an address baked into the app is public, and
  /// it is the owner's to choose (`plan.md`, decided 11 Sep).
  FeedbackAddressProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedbackAddressProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedbackAddressHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return feedbackAddress(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$feedbackAddressHash() => r'41dd36b0a2f884195f8fa357cf1938e6607f6558';

/// Where *Buy me a coffee* goes, or null when there is nowhere yet - which
/// hides the row. A provider rather than the constant itself so a test can
/// show the row without a real page.

@ProviderFor(supportLink)
final supportLinkProvider = SupportLinkProvider._();

/// Where *Buy me a coffee* goes, or null when there is nowhere yet - which
/// hides the row. A provider rather than the constant itself so a test can
/// show the row without a real page.

final class SupportLinkProvider extends $FunctionalProvider<Uri?, Uri?, Uri?>
    with $Provider<Uri?> {
  /// Where *Buy me a coffee* goes, or null when there is nowhere yet - which
  /// hides the row. A provider rather than the constant itself so a test can
  /// show the row without a real page.
  SupportLinkProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supportLinkProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supportLinkHash();

  @$internal
  @override
  $ProviderElement<Uri?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Uri? create(Ref ref) {
    return supportLink(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Uri? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Uri?>(value),
    );
  }
}

String _$supportLinkHash() => r'43b464cd2f7886f01be337b9fe30e274bc3e9cba';
