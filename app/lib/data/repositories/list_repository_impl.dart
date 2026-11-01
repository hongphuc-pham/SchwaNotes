import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';
import 'package:vocabnote/core/failure.dart';
import 'package:vocabnote/core/result.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/repositories/mappers.dart';
import 'package:vocabnote/domain/entities/word_list.dart';
import 'package:vocabnote/domain/repositories/list_repository.dart';
import 'package:vocabnote/domain/value_objects/ipa_color_token.dart';

/// Drift-backed [ListRepository].
class ListRepositoryImpl implements ListRepository {
  /// Creates the repository over the given database.
  new(this._db, {this._uuid = const Uuid(), DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final Uuid _uuid;
  final DateTime Function() _now;

  AppFailure _dbFailure(String operation) =>
      DatabaseFailure(operation: operation);

  @override
  ResultStream<List<WordListSummary>> watchLists() => _db.listsDao
      .watchListsWithCounts()
      .map(
        (rows) => rows
            .map(
              (row) => WordListSummary(
                list: row.list.toEntity(),
                wordCount: row.wordCount,
                dueCount: row.dueCount,
              ),
            )
            .toList(),
      )
      .guarded(onError: (_, _) => _dbFailure('watch lists'));

  @override
  ResultStream<WordList?> watchList(String id) => _db.listsDao
      .watchById(id)
      .map((row) => row?.toEntity())
      .guarded(onError: (_, _) => _dbFailure('watch list'));

  @override
  AsyncResult<WordList> createList({
    required String name,
    required IpaColorToken color,
    ListKind kind = ListKind.list,
  }) => Results.guard(() async {
    final now = _now();
    // Appended to the end of the current order rather than inserted at
    // the top, so creating a list never reshuffles the grid the user has
    // already arranged.
    final existing = await _db.listsDao.watchLists().first;
    final list = WordList(
      id: _uuid.v4(),
      name: name.trim(),
      color: color,
      sortOrder: existing.length,
      createdAt: now,
      updatedAt: now,
      kind: kind,
    );
    await _db.listsDao.insertList(list.toCompanion());
    return list;
  }, onError: (_, _) => _dbFailure('create list'));

  @override
  AsyncResult<void> makeTag(String listId) => makeTags(<String>[listId]);

  @override
  AsyncResult<void> makeTags(List<String> listIds) => Results.guard(
    () => _db.transaction(() async {
      for (final id in listIds) {
        await _makeTag(id);
      }
    }),
    onError: (_, _) => _dbFailure('make tags'),
  );

  Future<void> _makeTag(String listId) async {
    final list = await _db.listsDao.getById(listId);
    if (list == null) return;
    final name = list.name.trim().toLowerCase();
    for (final other in await _db.listsDao.allLists()) {
      if (other.kind == ListKind.tag &&
          other.name.trim().toLowerCase() == name) {
        await _db.listsDao.mergeInto(
          fromId: listId,
          intoId: other.id,
          addedAt: _now(),
        );
        return;
      }
    }
    await _db.listsDao.patchList(
      listId,
      WordListsCompanion(
        kind: const Value(ListKind.tag),
        updatedAt: Value(_now()),
      ),
    );
  }

  @override
  AsyncResult<WordList> updateList(WordList list) => Results.guard(() async {
    final updated = list.copyWith(updatedAt: _now());
    await _db.listsDao.patchList(updated.id, updated.toCompanion());
    return updated;
  }, onError: (_, _) => _dbFailure('update list'));

  @override
  AsyncResult<void> deleteList(String id) => Results.guard(
    // Removes the list and its membership rows. The words themselves are
    // untouched - asserted by lists_dao_test.dart.
    () => _db.listsDao.deleteList(id),
    onError: (_, _) => _dbFailure('delete list'),
  );

  @override
  AsyncResult<void> reorder(List<String> orderedIds) => Results.guard(
    () => _db.listsDao.reorder(orderedIds),
    onError: (_, _) => _dbFailure('reorder lists'),
  );

  @override
  AsyncResult<void> addWordToList({
    required String listId,
    required String wordId,
  }) => Results.guard(
    () => _db.listsDao.addWord(listId: listId, wordId: wordId, addedAt: _now()),
    onError: (_, _) => _dbFailure('add word to list'),
  );

  @override
  AsyncResult<void> removeWordFromList({
    required String listId,
    required String wordId,
  }) => Results.guard(
    () => _db.listsDao.removeWord(listId: listId, wordId: wordId),
    onError: (_, _) => _dbFailure('remove word from list'),
  );

  @override
  AsyncResult<void> setListsForWord({
    required String wordId,
    required List<String> listIds,
  }) => Results.guard(
    () => _db.listsDao.setListsForWord(
      wordId: wordId,
      listIds: listIds,
      addedAt: _now(),
    ),
    onError: (_, _) => _dbFailure('set lists for word'),
  );

  @override
  ResultStream<List<String>> watchListIdsForWord(String wordId) => _db.listsDao
      .watchListIdsForWord(wordId)
      .guarded(onError: (_, _) => _dbFailure('watch word lists'));
}
