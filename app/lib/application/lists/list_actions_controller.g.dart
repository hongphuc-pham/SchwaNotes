// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_actions_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The write side of lists.
///
/// `listSummariesProvider` in `list_controller.dart` is the read side; this is
/// deliberately separate, so a screen that only displays lists does not depend
/// on a notifier that can delete them.
///
/// Kept alive like `WordActions` and `WordNotes`: nothing here holds state, and
/// an action fired from a snackbar must still find its notifier alive after the
/// screen that started it has gone.

@ProviderFor(ListActions)
final listActionsProvider = ListActionsProvider._();

/// The write side of lists.
///
/// `listSummariesProvider` in `list_controller.dart` is the read side; this is
/// deliberately separate, so a screen that only displays lists does not depend
/// on a notifier that can delete them.
///
/// Kept alive like `WordActions` and `WordNotes`: nothing here holds state, and
/// an action fired from a snackbar must still find its notifier alive after the
/// screen that started it has gone.
final class ListActionsProvider extends $NotifierProvider<ListActions, void> {
  /// The write side of lists.
  ///
  /// `listSummariesProvider` in `list_controller.dart` is the read side; this is
  /// deliberately separate, so a screen that only displays lists does not depend
  /// on a notifier that can delete them.
  ///
  /// Kept alive like `WordActions` and `WordNotes`: nothing here holds state, and
  /// an action fired from a snackbar must still find its notifier alive after the
  /// screen that started it has gone.
  ListActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'listActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$listActionsHash();

  @$internal
  @override
  ListActions create() => ListActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$listActionsHash() => r'5d937019b5c5f833bfec3b6c25ec932eae66c69c';

/// The write side of lists.
///
/// `listSummariesProvider` in `list_controller.dart` is the read side; this is
/// deliberately separate, so a screen that only displays lists does not depend
/// on a notifier that can delete them.
///
/// Kept alive like `WordActions` and `WordNotes`: nothing here holds state, and
/// an action fired from a snackbar must still find its notifier alive after the
/// screen that started it has gone.

abstract class _$ListActions extends $Notifier<void> {
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
