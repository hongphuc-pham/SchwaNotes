// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The filter, sort and search state of the words screen.
///
/// Held here rather than in the widget so it survives navigating to a word and
/// back - a user who filtered to "No IPA yet", fixed one word and returned
/// expects the filter to still be on.

@ProviderFor(WordListQuery)
final wordListQueryProvider = WordListQueryProvider._();

/// The filter, sort and search state of the words screen.
///
/// Held here rather than in the widget so it survives navigating to a word and
/// back - a user who filtered to "No IPA yet", fixed one word and returned
/// expects the filter to still be on.
final class WordListQueryProvider
    extends $NotifierProvider<WordListQuery, WordQuery> {
  /// The filter, sort and search state of the words screen.
  ///
  /// Held here rather than in the widget so it survives navigating to a word and
  /// back - a user who filtered to "No IPA yet", fixed one word and returned
  /// expects the filter to still be on.
  WordListQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wordListQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wordListQueryHash();

  @$internal
  @override
  WordListQuery create() => WordListQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WordQuery value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WordQuery>(value),
    );
  }
}

String _$wordListQueryHash() => r'98c97b00762d917669efa7fd9181decae4a08e5f';

/// The filter, sort and search state of the words screen.
///
/// Held here rather than in the widget so it survives navigating to a word and
/// back - a user who filtered to "No IPA yet", fixed one word and returned
/// expects the filter to still be on.

abstract class _$WordListQuery extends $Notifier<WordQuery> {
  WordQuery build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<WordQuery, WordQuery>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WordQuery, WordQuery>,
              WordQuery,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The words currently shown on the list screen.
///
/// Converts the repository's [Result] into Riverpod's `AsyncValue`, which is
/// the presentation layer's own success-or-failure type. The conversion
/// happens here, at the application boundary, so no bare exception ever
/// crosses out of `data/` (`docs/RULES.md` §24).

@ProviderFor(wordList)
final wordListProvider = WordListProvider._();

/// The words currently shown on the list screen.
///
/// Converts the repository's [Result] into Riverpod's `AsyncValue`, which is
/// the presentation layer's own success-or-failure type. The conversion
/// happens here, at the application boundary, so no bare exception ever
/// crosses out of `data/` (`docs/RULES.md` §24).

final class WordListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WordListEntry>>,
          List<WordListEntry>,
          Stream<List<WordListEntry>>
        >
    with
        $FutureModifier<List<WordListEntry>>,
        $StreamProvider<List<WordListEntry>> {
  /// The words currently shown on the list screen.
  ///
  /// Converts the repository's [Result] into Riverpod's `AsyncValue`, which is
  /// the presentation layer's own success-or-failure type. The conversion
  /// happens here, at the application boundary, so no bare exception ever
  /// crosses out of `data/` (`docs/RULES.md` §24).
  WordListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wordListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wordListHash();

  @$internal
  @override
  $StreamProviderElement<List<WordListEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<WordListEntry>> create(Ref ref) {
    return wordList(ref);
  }
}

String _$wordListHash() => r'45fde492cf66beaed7e2ea0197087a578b0e5728';

/// The few words the home overview shows. Never filtered: the words screen's
/// filter belongs to the words screen.

@ProviderFor(recentWords)
final recentWordsProvider = RecentWordsProvider._();

/// The few words the home overview shows. Never filtered: the words screen's
/// filter belongs to the words screen.

final class RecentWordsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WordListEntry>>,
          List<WordListEntry>,
          Stream<List<WordListEntry>>
        >
    with
        $FutureModifier<List<WordListEntry>>,
        $StreamProvider<List<WordListEntry>> {
  /// The few words the home overview shows. Never filtered: the words screen's
  /// filter belongs to the words screen.
  RecentWordsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentWordsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentWordsHash();

  @$internal
  @override
  $StreamProviderElement<List<WordListEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<WordListEntry>> create(Ref ref) {
    return recentWords(ref);
  }
}

String _$recentWordsHash() => r'a24cabf624dd458c96263874d066039377ceab21';

/// How many live words there are.
///
/// Separate from [wordList] because it must not change when a filter does -
/// the empty state has to distinguish "no words yet" from "no words match".

@ProviderFor(totalWordCount)
final totalWordCountProvider = TotalWordCountProvider._();

/// How many live words there are.
///
/// Separate from [wordList] because it must not change when a filter does -
/// the empty state has to distinguish "no words yet" from "no words match".

final class TotalWordCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  /// How many live words there are.
  ///
  /// Separate from [wordList] because it must not change when a filter does -
  /// the empty state has to distinguish "no words yet" from "no words match".
  TotalWordCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'totalWordCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$totalWordCountHash();

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    return totalWordCount(ref);
  }
}

String _$totalWordCountHash() => r'4b6d4ae12883f4682dff789cefccc965e00bc033';
