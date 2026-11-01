// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Every list with its word and due counts, A-Z (F-042). Tags are not lists:
/// they have [tagSummaries].
///
/// Used by the lists grid (M4) and, from M2, by the filter chips row - the
/// user's lists appear as chips after the four fixed ones.
///
/// Converts the repository's `Result` into Riverpod's `AsyncValue`, which is
/// the presentation layer's own success-or-failure type.

@ProviderFor(listSummaries)
final listSummariesProvider = ListSummariesProvider._();

/// Every list with its word and due counts, A-Z (F-042). Tags are not lists:
/// they have [tagSummaries].
///
/// Used by the lists grid (M4) and, from M2, by the filter chips row - the
/// user's lists appear as chips after the four fixed ones.
///
/// Converts the repository's `Result` into Riverpod's `AsyncValue`, which is
/// the presentation layer's own success-or-failure type.

final class ListSummariesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WordListSummary>>,
          List<WordListSummary>,
          Stream<List<WordListSummary>>
        >
    with
        $FutureModifier<List<WordListSummary>>,
        $StreamProvider<List<WordListSummary>> {
  /// Every list with its word and due counts, A-Z (F-042). Tags are not lists:
  /// they have [tagSummaries].
  ///
  /// Used by the lists grid (M4) and, from M2, by the filter chips row - the
  /// user's lists appear as chips after the four fixed ones.
  ///
  /// Converts the repository's `Result` into Riverpod's `AsyncValue`, which is
  /// the presentation layer's own success-or-failure type.
  ListSummariesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'listSummariesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$listSummariesHash();

  @$internal
  @override
  $StreamProviderElement<List<WordListSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<WordListSummary>> create(Ref ref) {
    return listSummaries(ref);
  }
}

String _$listSummariesHash() => r'dba4d76a2b83bab09f420edbef2aa5d5f45033b9';

/// Every tag with its word and due counts, A-Z.

@ProviderFor(tagSummaries)
final tagSummariesProvider = TagSummariesProvider._();

/// Every tag with its word and due counts, A-Z.

final class TagSummariesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WordListSummary>>,
          List<WordListSummary>,
          Stream<List<WordListSummary>>
        >
    with
        $FutureModifier<List<WordListSummary>>,
        $StreamProvider<List<WordListSummary>> {
  /// Every tag with its word and due counts, A-Z.
  TagSummariesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tagSummariesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tagSummariesHash();

  @$internal
  @override
  $StreamProviderElement<List<WordListSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<WordListSummary>> create(Ref ref) {
    return tagSummaries(ref);
  }
}

String _$tagSummariesHash() => r'499923d26794edbf9cb571b00264169eefefb858';

/// Which lists a given word belongs to - drives the selected chips on the
/// add/edit form.

@ProviderFor(listIdsForWord)
final listIdsForWordProvider = ListIdsForWordFamily._();

/// Which lists a given word belongs to - drives the selected chips on the
/// add/edit form.

final class ListIdsForWordProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          Stream<List<String>>
        >
    with $FutureModifier<List<String>>, $StreamProvider<List<String>> {
  /// Which lists a given word belongs to - drives the selected chips on the
  /// add/edit form.
  ListIdsForWordProvider._({
    required ListIdsForWordFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'listIdsForWordProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$listIdsForWordHash();

  @override
  String toString() {
    return r'listIdsForWordProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<String>> create(Ref ref) {
    final argument = this.argument as String;
    return listIdsForWord(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ListIdsForWordProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$listIdsForWordHash() => r'91fe5cbd37a9c9544914a7a60e58dc8d85deb854';

/// Which lists a given word belongs to - drives the selected chips on the
/// add/edit form.

final class ListIdsForWordFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<String>>, String> {
  ListIdsForWordFamily._()
    : super(
        retry: null,
        name: r'listIdsForWordProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Which lists a given word belongs to - drives the selected chips on the
  /// add/edit form.

  ListIdsForWordProvider call(String wordId) =>
      ListIdsForWordProvider._(argument: wordId, from: this);

  @override
  String toString() => r'listIdsForWordProvider';
}

/// One list, watched by id - the detail screen's title and colour.

@ProviderFor(listById)
final listByIdProvider = ListByIdFamily._();

/// One list, watched by id - the detail screen's title and colour.

final class ListByIdProvider
    extends
        $FunctionalProvider<AsyncValue<WordList?>, WordList?, Stream<WordList?>>
    with $FutureModifier<WordList?>, $StreamProvider<WordList?> {
  /// One list, watched by id - the detail screen's title and colour.
  ListByIdProvider._({
    required ListByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'listByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$listByIdHash();

  @override
  String toString() {
    return r'listByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<WordList?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<WordList?> create(Ref ref) {
    final argument = this.argument as String;
    return listById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ListByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$listByIdHash() => r'3d298492fee3e83c1a81df0fb862b64df5b731e3';

/// One list, watched by id - the detail screen's title and colour.

final class ListByIdFamily extends $Family
    with $FunctionalFamilyOverride<Stream<WordList?>, String> {
  ListByIdFamily._()
    : super(
        retry: null,
        name: r'listByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One list, watched by id - the detail screen's title and colour.

  ListByIdProvider call(String listId) =>
      ListByIdProvider._(argument: listId, from: this);

  @override
  String toString() => r'listByIdProvider';
}

/// The words in one list.
///
/// A family rather than the global `wordListProvider`: the detail screen must
/// not disturb the filter the user left on the words tab, and going back should
/// find that tab exactly as it was.

@ProviderFor(wordsInList)
final wordsInListProvider = WordsInListFamily._();

/// The words in one list.
///
/// A family rather than the global `wordListProvider`: the detail screen must
/// not disturb the filter the user left on the words tab, and going back should
/// find that tab exactly as it was.

final class WordsInListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WordListEntry>>,
          List<WordListEntry>,
          Stream<List<WordListEntry>>
        >
    with
        $FutureModifier<List<WordListEntry>>,
        $StreamProvider<List<WordListEntry>> {
  /// The words in one list.
  ///
  /// A family rather than the global `wordListProvider`: the detail screen must
  /// not disturb the filter the user left on the words tab, and going back should
  /// find that tab exactly as it was.
  WordsInListProvider._({
    required WordsInListFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'wordsInListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$wordsInListHash();

  @override
  String toString() {
    return r'wordsInListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<WordListEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<WordListEntry>> create(Ref ref) {
    final argument = this.argument as String;
    return wordsInList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WordsInListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$wordsInListHash() => r'24aa3cf9abd79dc3c56c9ae42db577c9e3ba89e6';

/// The words in one list.
///
/// A family rather than the global `wordListProvider`: the detail screen must
/// not disturb the filter the user left on the words tab, and going back should
/// find that tab exactly as it was.

final class WordsInListFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<WordListEntry>>, String> {
  WordsInListFamily._()
    : super(
        retry: null,
        name: r'wordsInListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The words in one list.
  ///
  /// A family rather than the global `wordListProvider`: the detail screen must
  /// not disturb the filter the user left on the words tab, and going back should
  /// find that tab exactly as it was.

  WordsInListProvider call(String listId) =>
      WordsInListProvider._(argument: listId, from: this);

  @override
  String toString() => r'wordsInListProvider';
}
