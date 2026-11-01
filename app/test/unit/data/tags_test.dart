import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/data/backup/backup_sql.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/repositories/list_repository_impl.dart';
import 'package:vocabnote/domain/entities/word_list.dart';
import 'package:vocabnote/domain/value_objects/ipa_color_token.dart';

import 'db_fixtures.dart';

/// Tags: rows of `word_lists` that show on a word, not on the Lists tab.
void main() {
  late AppDatabase db;
  late ListRepositoryImpl repo;

  setUp(() {
    db = AppDatabase.memory();
    repo = ListRepositoryImpl(db, now: () => testNow);
  });

  tearDown(() => db.close());

  Future<WordList> create(String name, ListKind kind) async =>
      (await repo.createList(
        name: name,
        color: IpaColorToken.values.first,
        kind: kind,
      )).valueOrNull!;

  test('a new list is a list unless asked otherwise', () async {
    final result = await repo.createList(
      name: 'Health',
      color: IpaColorToken.values.first,
    );

    expect(result.valueOrNull!.kind, ListKind.list);
  });

  test('a tag keeps its kind once stored', () async {
    final tag = await create('tricky', ListKind.tag);

    expect((await db.listsDao.getById(tag.id))!.kind, ListKind.tag);
  });

  test('a list can be made a tag and keeps its words', () async {
    await seedWord(db, id: 'w1', headword: 'cough');
    final list = await create('body', ListKind.list);
    await db.listsDao.addWord(listId: list.id, wordId: 'w1', addedAt: testNow);

    await repo.makeTag(list.id);

    expect((await db.listsDao.getById(list.id))!.kind, ListKind.tag);
    expect(await db.listsDao.watchListIdsForWord('w1').first, <String>[
      list.id,
    ]);
  });

  test('making a tag of a name that exists merges the two', () async {
    await seedWord(db, id: 'w1', headword: 'cough');
    await seedWord(db, id: 'w2', headword: 'through');
    final list = await create('Body', ListKind.list);
    final tag = await create('body', ListKind.tag);
    await db.listsDao.addWord(listId: list.id, wordId: 'w1', addedAt: testNow);
    await db.listsDao.addWord(listId: list.id, wordId: 'w2', addedAt: testNow);
    await db.listsDao.addWord(listId: tag.id, wordId: 'w2', addedAt: testNow);

    await repo.makeTag(list.id);

    expect(await db.listsDao.getById(list.id), isNull);
    expect(await db.listsDao.watchListIdsForWord('w1').first, <String>[tag.id]);
    expect(await db.listsDao.watchListIdsForWord('w2').first, <String>[tag.id]);
    expect(await db.select(db.words).get(), hasLength(2));
  });

  test('several lists become tags together', () async {
    await seedWord(db, id: 'w1', headword: 'cough');
    final noun = await create('noun', ListKind.list);
    final verb = await create('verb', ListKind.list);
    final health = await create('Health', ListKind.list);
    await repo.addWordToList(listId: noun.id, wordId: 'w1');

    final result = await repo.makeTags(<String>[noun.id, verb.id]);

    expect(result.isOk, isTrue);
    expect((await db.listsDao.getById(noun.id))!.kind, ListKind.tag);
    expect((await db.listsDao.getById(verb.id))!.kind, ListKind.tag);
    expect((await db.listsDao.getById(health.id))!.kind, ListKind.list);
    expect(await db.select(db.wordListItems).get(), hasLength(1));
  });

  test('two selected lists that differ by case end as one tag', () async {
    await seedWord(db, id: 'w1', headword: 'cough');
    await seedWord(db, id: 'w2', headword: 'run');
    final upper = await create('Verbs', ListKind.list);
    final lower = await create('verbs', ListKind.list);
    await repo.addWordToList(listId: upper.id, wordId: 'w1');
    await repo.addWordToList(listId: lower.id, wordId: 'w2');

    await repo.makeTags(<String>[upper.id, lower.id]);

    final rows = await db.select(db.wordLists).get();
    expect(rows, hasLength(1));
    expect(rows.single.kind, ListKind.tag);
    expect(await db.select(db.wordListItems).get(), hasLength(2));
  });

  test('a backup from before tags restores its rows as lists', () async {
    // v3 files have no `kind` key; the column's default has to answer.
    await db.insertRow('word_lists', <String, Object?>{
      'id': 'old',
      'name': 'Health',
      'color_token': IpaColorToken.values.first.name,
      'sort_order': 0,
      'created_at': 1,
      'updated_at': 1,
    });

    expect((await db.listsDao.getById('old'))!.kind, ListKind.list);
  });

  test('a backup carries the kind, so a tag comes back a tag', () async {
    await db.insertRow('word_lists', <String, Object?>{
      'id': 't',
      'name': 'tricky',
      'color_token': IpaColorToken.values.first.name,
      'sort_order': 0,
      'created_at': 1,
      'updated_at': 1,
      'kind': 'tag',
    });

    expect((await db.listsDao.getById('t'))!.kind, ListKind.tag);
    final exported = await db
        .customSelect("SELECT kind FROM word_lists WHERE id = 't'")
        .getSingle();
    expect(exported.data['kind'], 'tag');
  });
}
