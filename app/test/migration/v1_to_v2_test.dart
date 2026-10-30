import 'package:drift/drift.dart' show Value;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/domain/repositories/word_query.dart';

import 'generated/schema.dart';
import 'generated/schema_v1.dart' as v1;

/// v1 → v2: the user's own repetition schedule, the in-session repeat cap, and
/// the index the least-known sort has always needed.
///
/// **This is the promise the app cannot break** (`README.md` in this folder):
/// installing a new version adopts the existing database in place. There is no
/// backend to restore from, so a wiped or mangled database is a permanently
/// lost user. The migration is purely additive, and this file exists to prove
/// it rather than assert it.
void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  /// Seeds a real v1 database with one of everything, then migrates it.
  ///
  /// Seeding and migrating use separate connections from the same schema, per
  /// the README — reusing one database instance does not exercise the upgrade
  /// path.
  Future<AppDatabase> migratedFromV1() async {
    final schema = await verifier.schemaAt(1);

    final old = v1.DatabaseAtV1(schema.newConnection());
    const created = 1757462400000; // 2025-09-10, epoch ms.

    await old
        .into(old.words)
        .insert(
          v1.WordsCompanion.insert(
            id: 'w1',
            headword: 'cough',
            headwordNormalized: 'cough',
            source: const Value('manual'),
            ipaUk: const Value('kɒf'),
            definition: const Value('To expel air from the lungs'),
            // The generated v1 types booleans as int, which is honest: that is
            // what SQLite holds.
            isFavourite: const Value(1),
            createdAt: created,
            updatedAt: created,
          ),
        );
    await old
        .into(old.studyCards)
        .insert(
          v1.StudyCardsCompanion.insert(
            wordId: 'w1',
            dueAt: created,
            box: const Value(4),
            intervalDays: const Value(7),
            easeFactor: const Value(2.7),
            repetitions: const Value(9),
            lapses: const Value(3),
            lastReviewedAt: const Value(created),
            lastResult: const Value('good'),
          ),
        );
    await old
        .into(old.settings)
        .insert(
          v1.SettingsCompanion.insert(
            id: const Value(1),
            themeMode: const Value('dark'),
            ttsRate: const Value(0.7),
            dailyGoal: const Value(35),
            promptSide: const Value('ipa_first'),
          ),
        );
    await old.close();

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 2);
    return db;
  }

  Future<Map<String, Object?>> v2Settings(AppDatabase db) async =>
      (await db.customSelect('SELECT * FROM settings WHERE id = 1').getSingle())
          .data;

  test('every v1 row survives with every field intact', () async {
    final db = await migratedFromV1();
    addTearDown(db.close);

    final word = await db.wordsDao.getById('w1');
    expect(word, isNotNull);
    expect(word!.headword, 'cough');
    expect(word.ipaUk, 'kɒf');
    expect(word.definition, 'To expel air from the lungs');
    expect(word.isFavourite, isTrue);

    // The scheduling columns matter most: this is the data a user builds over
    // weeks and cannot recreate.
    final card = await db.practiceDao.getCard('w1');
    expect(card, isNotNull);
    expect(card!.box, 4);
    expect(card.intervalDays, 7);
    expect(card.easeFactor, 2.7);
    expect(card.repetitions, 9);
    expect(card.lapses, 3);
  });

  test('the settings the user had chosen are untouched', () async {
    final db = await migratedFromV1();
    addTearDown(db.close);

    // Read raw: the DAO is today's code and asks for columns a later
    // version added, which a database stopped at v2 does not have yet.
    final settings = await v2Settings(db);
    expect(settings['theme_mode'], 'dark');
    expect(settings['tts_rate'], 0.7);
    expect(settings['daily_goal'], 35);
    expect(settings['prompt_side'], 'ipa_first');
  });

  test('the new columns arrive with the documented defaults', () async {
    // An upgrading user must not have their behaviour change. The default
    // schedule **is** the `docs/GAMES.md` §5 table, so someone who never opens
    // Settings notices nothing at all.
    final db = await migratedFromV1();
    addTearDown(db.close);

    final settings = await v2Settings(db);
    expect(settings['review_schedule'], '[0,1,2,4,7,15,30]');
    expect(settings['again_repeats'], 1);
  });

  test('the new index exists and is usable', () async {
    final db = await migratedFromV1();
    addTearDown(db.close);

    final indexes = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'index' "
          "AND name = 'idx_cards_box_lapses'",
        )
        .get();
    expect(indexes, hasLength(1));

    // And SQLite actually plans to use it for the least-known sort, which is
    // the entire reason it was added.
    final plan = await db
        .customSelect(
          'EXPLAIN QUERY PLAN '
          'SELECT word_id FROM study_cards ORDER BY box ASC, lapses DESC',
        )
        .get();
    expect(
      plan.map((row) => row.data.values.join(' ')).join(' '),
      contains('idx_cards_box_lapses'),
    );
  });

  test('the search index can be rebuilt after migrating', () async {
    // The subtle failure a migration can cause: the base tables survive but
    // the derived index does not, and search silently returns nothing.
    //
    // Deliberately *not* asserting that search works straight after the
    // migration. A word seeded directly into a v1 database is never indexed,
    // because `drift_dev schema dump` does not capture the `words_fts_after_*`
    // triggers - the v1 snapshot has only the three `notes_fts_*` ones, while
    // a fresh install has all six. That is a gap in the test harness rather
    // than a production bug: a real upgrading database was created by the app
    // and already has its triggers.
    //
    // What *is* worth proving is that the app's own recovery path still works
    // on a migrated database, since `words_fts` is derived and rebuilding it
    // is the supported fix.
    final db = await migratedFromV1();
    addTearDown(db.close);

    await db.rebuildFtsIndex();

    final results = await db.wordsDao.getWords(
      const WordQuery(searchTerm: 'cough'),
    );
    expect(results.map((row) => row.id), contains('w1'));
  });
}
