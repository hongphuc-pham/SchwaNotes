import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vocabnote/application/repositories.dart';
import 'package:vocabnote/domain/entities/word_list.dart';
import 'package:vocabnote/domain/repositories/word_query.dart';
import 'package:vocabnote/domain/repositories/word_repository.dart';

part 'list_controller.g.dart';

/// Every list with its word and due counts, A-Z (F-042). Tags are not lists:
/// they have [tagSummaries].
///
/// Used by the lists grid (M4) and, from M2, by the filter chips row - the
/// user's lists appear as chips after the four fixed ones.
///
/// Converts the repository's `Result` into Riverpod's `AsyncValue`, which is
/// the presentation layer's own success-or-failure type.
@riverpod
Stream<List<WordListSummary>> listSummaries(Ref ref) =>
    _summaries(ref, ListKind.list);

/// Every tag with its word and due counts, A-Z.
@riverpod
Stream<List<WordListSummary>> tagSummaries(Ref ref) =>
    _summaries(ref, ListKind.tag);

int _byName(WordListSummary a, WordListSummary b) =>
    a.list.name.toLowerCase().compareTo(b.list.name.toLowerCase());

Stream<List<WordListSummary>> _summaries(Ref ref, ListKind kind) {
  return ref
      .watch(listRepositoryProvider)
      .watchLists()
      .map(
        (result) => result.fold(
          (lists) =>
              lists.where((s) => s.list.kind == kind).toList()..sort(_byName),
          (failure) => throw failure,
        ),
      );
}

/// Which lists a given word belongs to - drives the selected chips on the
/// add/edit form.
@riverpod
Stream<List<String>> listIdsForWord(Ref ref, String wordId) {
  return ref
      .watch(listRepositoryProvider)
      .watchListIdsForWord(wordId)
      .map((result) => result.fold((ids) => ids, (failure) => throw failure));
}

/// One list, watched by id - the detail screen's title and colour.
@riverpod
Stream<WordList?> listById(Ref ref, String listId) {
  return ref
      .watch(listRepositoryProvider)
      .watchList(listId)
      .map((result) => result.fold((list) => list, (failure) => throw failure));
}

/// The words in one list.
///
/// A family rather than the global `wordListProvider`: the detail screen must
/// not disturb the filter the user left on the words tab, and going back should
/// find that tab exactly as it was.
@riverpod
Stream<List<WordListEntry>> wordsInList(Ref ref, String listId) {
  return ref
      .watch(wordRepositoryProvider)
      .watchWords(WordQuery(filter: WordFilter.inList, listId: listId))
      .map(
        (result) => result.fold((words) => words, (failure) => throw failure),
      );
}
