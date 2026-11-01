import 'package:drift/drift.dart' show Value;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/domain/entities/word_list.dart';

import 'generated/schema.dart';
import 'generated/schema_v3.dart' as v3;

/// v3 → v4: tags, as a kind of row in `word_lists`.
///
/// The same promise as the migrations before it: the upgrade adopts the
/// existing database in place. Every list a user already has stays a list.
void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  const created = 1757462400000; // 2025-09-10, epoch ms.

  Future<AppDatabase> migratedFromV3() async {
    final schema = await verifier.schemaAt(3);

    final old = v3.DatabaseAtV3(schema.newConnection());
    await old
        .into(old.words)
        .insert(
          v3.WordsCompanion.insert(
            id: 'w1',
            headword: 'cough',
            headwordNormalized: 'cough',
            source: const Value('manual'),
            createdAt: created,
            updatedAt: created,
          ),
        );
    await old
        .into(old.wordLists)
        .insert(
          v3.WordListsCompanion.insert(
            id: 'l1',
            name: 'Health',
            colorToken: 'yellow',
            sortOrder: 4,
            createdAt: created,
            updatedAt: created,
          ),
        );
    await old
        .into(old.wordListItems)
        .insert(
          v3.WordListItemsCompanion.insert(
            listId: 'l1',
            wordId: 'w1',
            addedAt: created,
          ),
        );
    await old.close();

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 4);
    return db;
  }

  test('every list the user had stays a list, intact', () async {
    final db = await migratedFromV3();
    addTearDown(db.close);

    final list = await db.listsDao.getById('l1');
    expect(list!.name, 'Health');
    expect(list.sortOrder, 4);
    expect(list.kind, ListKind.list);
  });

  test('the words stay in their lists', () async {
    final db = await migratedFromV3();
    addTearDown(db.close);

    expect(await db.listsDao.watchListIdsForWord('w1').first, <String>['l1']);
  });
}
