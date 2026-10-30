// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_import_actions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The write side of a CSV import.

@ProviderFor(WordImportActions)
final wordImportActionsProvider = WordImportActionsProvider._();

/// The write side of a CSV import.
final class WordImportActionsProvider
    extends $NotifierProvider<WordImportActions, void> {
  /// The write side of a CSV import.
  WordImportActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wordImportActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wordImportActionsHash();

  @$internal
  @override
  WordImportActions create() => WordImportActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$wordImportActionsHash() => r'9e61e6ee81f808914d7b32f1bd06037faba58f18';

/// The write side of a CSV import.

abstract class _$WordImportActions extends $Notifier<void> {
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
