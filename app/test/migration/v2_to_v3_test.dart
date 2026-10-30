import 'package:drift/drift.dart' show Value;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/repositories/mappers.dart';
import 'package:vocabnote/domain/entities/app_settings.dart';
import 'package:vocabnote/domain/entities/practice_session.dart';

import 'generated/schema.dart';
import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;

/// v2 → v3: the *Mix* prompt side — which faces it draws from, and in what
/// order.
///
/// The same promise as `v1_to_v2_test.dart`: the upgrade adopts the existing
/// database in place. Both new columns carry defaults; nothing else moves.
void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  const created = 1757462400000; // 2025-09-10, epoch ms.

  Future<AppDatabase> migratedFromV2() async {
    final schema = await verifier.schemaAt(2);

    final old = v2.DatabaseAtV2(schema.newConnection());
    await old
        .into(old.words)
        .insert(
          v2.WordsCompanion.insert(
            id: 'w1',
            headword: 'cough',
            headwordNormalized: 'cough',
            source: const Value('manual'),
            ipaUk: const Value('kɒf'),
            definition: const Value('ho'),
            createdAt: created,
            updatedAt: created,
          ),
        );
    await old
        .into(old.studyCards)
        .insert(
          v2.StudyCardsCompanion.insert(
            wordId: 'w1',
            dueAt: created,
            box: const Value(3),
            lapses: const Value(2),
          ),
        );
    await old
        .into(old.settings)
        .insert(
          v2.SettingsCompanion.insert(
            id: const Value(1),
            themeMode: const Value('dark'),
            promptSide: const Value('meaning_first'),
            reviewSchedule: const Value('[0,1,3,5,8,13,21]'),
            againRepeats: const Value(3),
          ),
        );
    await old.close();

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 3);
    return db;
  }

  test('every v2 row survives with every field intact', () async {
    final db = await migratedFromV2();
    addTearDown(db.close);

    final word = await db.wordsDao.getById('w1');
    expect(word!.headword, 'cough');
    expect(word.ipaUk, 'kɒf');
    expect(word.definition, 'ho');

    final card = await db.practiceDao.getCard('w1');
    expect(card!.box, 3);
    expect(card.lapses, 2);
  });

  test('the settings the user had chosen are untouched', () async {
    final db = await migratedFromV2();
    addTearDown(db.close);

    final settings = await db.settingsDao.getSettings();
    expect(settings.themeMode, ThemePreference.dark);
    expect(settings.promptSide, PromptSide.meaningFirst);
    expect(settings.reviewSchedule, '[0,1,3,5,8,13,21]');
    expect(settings.againRepeats, 3);
  });

  test('the mix columns arrive with the documented defaults', () async {
    final db = await migratedFromV2();
    addTearDown(db.close);

    final settings = (await db.settingsDao.getSettings()).toEntity();
    expect(settings.mixSides, PromptSide.defaultMixSides);
    expect(settings.mixOrder, MixOrder.random);
  });

  test('a user who skipped v2 goes straight from v1 to v3', () async {
    // DATABASE.md §3.5: `1 → n` end-to-end.
    final schema = await verifier.schemaAt(1);
    final old = v1.DatabaseAtV1(schema.newConnection());
    await old
        .into(old.words)
        .insert(
          v1.WordsCompanion.insert(
            id: 'w1',
            headword: 'cough',
            headwordNormalized: 'cough',
            source: const Value('manual'),
            createdAt: created,
            updatedAt: created,
          ),
        );
    await old
        .into(old.settings)
        .insert(
          v1.SettingsCompanion.insert(
            id: const Value(1),
            promptSide: const Value('ipa_first'),
          ),
        );
    await old.close();

    final db = AppDatabase(schema.newConnection());
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 3);

    expect((await db.wordsDao.getById('w1'))!.headword, 'cough');
    final settings = (await db.settingsDao.getSettings()).toEntity();
    expect(settings.promptSide, PromptSide.ipaFirst);
    expect(settings.againRepeats, 1);
    expect(settings.mixSides, PromptSide.defaultMixSides);
    expect(settings.mixOrder, MixOrder.random);
  });

  test('a corrupt mix_sides reads as the default, never as a broken mix', () {
    expect(PromptSide.decodeMix(''), PromptSide.defaultMixSides);
    expect(PromptSide.decodeMix('ipa_first'), PromptSide.defaultMixSides);
    expect(PromptSide.decodeMix('mix,word_first'), PromptSide.defaultMixSides);
    expect(PromptSide.decodeMix(' meaning_first , ipa_first '), <PromptSide>{
      PromptSide.ipaFirst,
      PromptSide.meaningFirst,
    });
    expect(
      PromptSide.decodeMix(PromptSide.encodeMix(PromptSide.mixableSides)),
      PromptSide.mixableSides,
    );
    expect(AppSettings.defaults.mixSides, PromptSide.defaultMixSides);
  });
}
