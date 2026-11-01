import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vocabnote/application/repositories.dart';
import 'package:vocabnote/core/result.dart';
import 'package:vocabnote/domain/repositories/word_query.dart';
import 'package:vocabnote/domain/repositories/word_repository.dart';

part 'word_list_controller.g.dart';

/// How long typing pauses before a search actually runs.
///
/// Long enough that "cough" is one query rather than five, short enough that
/// the list feels live. The F-041 budget is 100ms *per query*; this is the gap
/// before one starts.
const Duration kSearchDebounce = Duration(milliseconds: 250);

/// How many words the home overview shows.
const int kRecentWordCount = 5;

/// The filter, sort and search state of the words screen.
///
/// Held here rather than in the widget so it survives navigating to a word and
/// back - a user who filtered to "No IPA yet", fixed one word and returned
/// expects the filter to still be on.
@riverpod
class WordListQuery extends _$WordListQuery {
  Timer? _debounce;

  @override
  WordQuery build() {
    ref.onDispose(() => _debounce?.cancel());
    return const WordQuery();
  }

  /// Selects a filter chip.
  void setFilter(WordFilter filter, {String? listId}) {
    state = state.copyWith(filter: filter, listId: listId);
  }

  /// Changes the sort order.
  void setSort(WordSort sort) => state = state.copyWith(sort: sort);

  /// Updates the search term after [kSearchDebounce] of quiet.
  ///
  /// The field itself updates immediately - the widget owns the text. Only the
  /// query waits, so a fast typist runs one search rather than one per key.
  void setSearchTerm(String term) {
    _debounce?.cancel();

    // Clearing is instant: the user wants their list back, not in 250ms.
    if (term.trim().isEmpty) {
      state = state.copyWith(clearSearch: true);
      return;
    }

    _debounce = Timer(kSearchDebounce, () {
      state = state.copyWith(searchTerm: term);
    });
  }

  /// Applies a search term with no debounce - used by tests and by submitting
  /// the field.
  void setSearchTermNow(String term) {
    _debounce?.cancel();
    state = term.trim().isEmpty
        ? state.copyWith(clearSearch: true)
        : state.copyWith(searchTerm: term);
  }

  /// Clears the search and returns to the unfiltered list.
  void reset() {
    _debounce?.cancel();
    state = const WordQuery();
  }
}

/// The words currently shown on the list screen.
///
/// Converts the repository's [Result] into Riverpod's `AsyncValue`, which is
/// the presentation layer's own success-or-failure type. The conversion
/// happens here, at the application boundary, so no bare exception ever
/// crosses out of `data/` (`docs/RULES.md` §24).
@riverpod
Stream<List<WordListEntry>> wordList(Ref ref) {
  final query = ref.watch(wordListQueryProvider);
  return ref
      .watch(wordRepositoryProvider)
      .watchWords(query)
      .map(
        (result) => result.fold(
          (entries) => entries,
          // Rethrown inside Riverpod's own error capture, which surfaces it as
          // AsyncValue.error for the widget to render.
          (failure) => throw failure,
        ),
      );
}

/// The few words the home overview shows. Never filtered: the words screen's
/// filter belongs to the words screen.
@riverpod
Stream<List<WordListEntry>> recentWords(Ref ref) {
  return ref
      .watch(wordRepositoryProvider)
      .watchWords(const WordQuery(limit: kRecentWordCount))
      .map(
        (result) =>
            result.fold((entries) => entries, (failure) => throw failure),
      );
}

/// How many live words there are.
///
/// Separate from [wordList] because it must not change when a filter does -
/// the empty state has to distinguish "no words yet" from "no words match".
@riverpod
Stream<int> totalWordCount(Ref ref) {
  return ref
      .watch(wordRepositoryProvider)
      .watchWordCount()
      .map(
        (result) => result.fold((count) => count, (failure) => throw failure),
      );
}
