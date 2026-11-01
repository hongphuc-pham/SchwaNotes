import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
// The generated part file names the converter constants and the enum types
// directly, but cannot add imports of its own - so they are declared here.
import 'package:vocabnote/data/db/converters/converters.dart';
import 'package:vocabnote/data/db/daos/highlights_dao.dart';
import 'package:vocabnote/data/db/daos/lists_dao.dart';
import 'package:vocabnote/data/db/daos/meta_dao.dart';
import 'package:vocabnote/data/db/daos/notes_dao.dart';
import 'package:vocabnote/data/db/daos/practice_dao.dart';
import 'package:vocabnote/data/db/daos/settings_dao.dart';
import 'package:vocabnote/data/db/daos/words_dao.dart';
import 'package:vocabnote/data/db/schema_versions.dart';
import 'package:vocabnote/data/db/tables/app_meta.dart';
import 'package:vocabnote/data/db/tables/ipa_highlights.dart';
import 'package:vocabnote/data/db/tables/practice_answers.dart';
import 'package:vocabnote/data/db/tables/practice_sessions.dart';
import 'package:vocabnote/data/db/tables/settings.dart';
import 'package:vocabnote/data/db/tables/study_cards.dart';
import 'package:vocabnote/data/db/tables/word_list_items.dart';
import 'package:vocabnote/data/db/tables/word_lists.dart';
import 'package:vocabnote/data/db/tables/word_notes.dart';
import 'package:vocabnote/data/db/tables/words.dart';
// Imported for the generated part file, which names these types in its
// companion classes but cannot add imports of its own.
import 'package:vocabnote/domain/entities/app_settings.dart';
import 'package:vocabnote/domain/entities/ipa_highlight.dart';
import 'package:vocabnote/domain/entities/practice_session.dart';
import 'package:vocabnote/domain/entities/study_card.dart';
import 'package:vocabnote/domain/entities/word.dart';
import 'package:vocabnote/domain/entities/word_list.dart';
import 'package:vocabnote/domain/value_objects/ipa_color_token.dart';

part 'app_database.g.dart';

/// The application database (`docs/DATABASE.md`).
///
/// **The one non-negotiable in this project**: installing a new version must
/// adopt the existing file in place, without data loss. There is no backend to
/// restore from, so a wiped database is a permanently lost user.
///
/// That is why this class contains no `deleteDatabase`, no drop-and-recreate
/// and no "if migration fails, start fresh" - and why CI greps for those
/// patterns on every push.
@DriftDatabase(
  tables: <Type>[
    Words,
    WordNotes,
    IpaHighlights,
    WordLists,
    WordListItems,
    StudyCards,
    PracticeSessions,
    PracticeAnswers,
    AppMeta,
    Settings,
  ],
  include: <String>{'fts.drift'},
  daos: <Type>[
    WordsDao,
    NotesDao,
    HighlightsDao,
    ListsDao,
    PracticeDao,
    SettingsDao,
    MetaDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Opens the database over [executor].
  new(super.e);

  /// An in-memory database for tests.
  ///
  /// Foreign keys are enabled here exactly as they are in production, because
  /// a test suite that runs without them proves nothing about cascades.
  new memory() : super(DatabaseConnection(NativeDatabase.memory()));

  /// The schema version this build understands.
  ///
  /// Increments by exactly 1 per released schema change, and a number is never
  /// reused (`docs/DATABASE.md` section 3.1).
  ///
  /// A constant as well as an instance getter, so `DatabaseOpener` can compare
  /// it against the on-disk version without constructing a database just to
  /// ask - which would both waste an open handle and trip drift's
  /// "instantiated twice" warning.
  static const int latestSchemaVersion = 4;

  @override
  int get schemaVersion => latestSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedDefaults();
    },

    // Generated step-by-step migrations (`schema_versions.dart`). Each step is
    // written once, tested against an exported schema snapshot, and never
    // edited again.
    onUpgrade: stepByStep(
      // v2 (M5): the user's own repetition schedule, the in-session repeat
      // cap, and the index the least-known sort has always needed.
      //
      // Purely additive. Both columns carry non-null defaults, so an existing
      // row adopts them without a backfill - and the schedule's default *is*
      // the `docs/GAMES.md` §5 table, so an upgrading user's behaviour does
      // not change. Nothing is dropped, renamed or rebuilt (RULES §41).
      from1To2: (m, schema) async {
        await m.addColumn(schema.settings, schema.settings.reviewSchedule);
        await m.addColumn(schema.settings, schema.settings.againRepeats);
        await m.create(schema.idxCardsBoxLapses);
      },

      // v3: the *Mix* prompt side - which faces it draws from and in what
      // order. Purely additive: both columns carry non-null defaults, and
      // `prompt_side` keeps its value, so an upgrading user still sees the
      // face they chose. An older build reading `mix` falls back to the word.
      from2To3: (m, schema) async {
        await m.addColumn(schema.settings, schema.settings.mixSides);
        await m.addColumn(schema.settings, schema.settings.mixOrder);
      },

      // v4: tags, as a kind of row in `word_lists`. Purely additive: the
      // column defaults to `list`, so every existing row stays what it was.
      from3To4: (m, schema) async {
        await m.addColumn(schema.wordLists, schema.wordLists.kind);
      },
    ),

    beforeOpen: (details) async {
      // Must be set on every connection, and outside a transaction. Without
      // it SQLite parses every ON DELETE CASCADE and then ignores it.
      await customStatement('PRAGMA foreign_keys = ON');

      // Catches a schema that has drifted from what the generated code
      // expects - usually a migration step someone forgot to write.
      //
      // `docs/DATABASE.md` section 4 shows drift's own
      // `validateDatabaseSchema()` here, but that lives in `drift_dev`, a dev
      // dependency: calling it from `lib/` would ship the Dart analyzer inside
      // the app. The real check runs in `test/migration/`, where drift_dev is
      // available; this is the cheap runtime half of it.
      if (kDebugMode) {
        await _assertExpectedTablesExist();
      }
    },
  );

  /// Fails loudly in debug if a table the generated code expects is missing.
  ///
  /// Not a substitute for the full schema validation in `test/migration/` -
  /// it checks that tables exist, not that their columns match - but it turns
  /// a confusing "no such column" three screens later into an obvious error at
  /// startup.
  Future<void> _assertExpectedTablesExist() async {
    final rows = await customSelect(
      "SELECT name FROM sqlite_master WHERE type = 'table'",
    ).get();
    final present = rows.map((row) => row.read<String>('name')).toSet();

    final expected = <String>{
      for (final table in allTables) table.actualTableName,
      'words_fts',
    };
    final missing = expected.difference(present);

    assert(
      missing.isEmpty,
      'Database schema is missing: ${missing.join(', ')}. '
      'A migration step is probably missing.',
    );
  }

  /// Seeds a brand-new database.
  ///
  /// Only two things: the single `settings` row, and the `app_meta` keys.
  /// Deliberately **no** "All words" list - `All` is a filter chip
  /// (`docs/UI-UX.md` section 4.1), and a row would be renameable and
  /// deletable, which it must not be.
  Future<void> _seedDefaults() async {
    await batch((batch) {
      batch
        ..insert(
          settings,
          const SettingsCompanion(id: Value(1)),
          mode: InsertMode.insertOrIgnore,
        )
        ..insertAll(appMeta, <AppMetaCompanion>[
          AppMetaCompanion.insert(
            key: AppMetaKeys.schemaVersionMirror,
            value: Value('$schemaVersion'),
          ),
          const AppMetaCompanion(
            key: Value(AppMetaKeys.onboardingCompleted),
            value: Value('false'),
          ),
          // Random, local-only, and never transmitted: there is nowhere to
          // transmit it to (docs/DATA-SOURCES.md section 7).
          AppMetaCompanion.insert(
            key: AppMetaKeys.installId,
            value: Value(const Uuid().v4()),
          ),
        ], mode: InsertMode.insertOrIgnore);
    });
  }

  /// Drops and rebuilds the full-text index from the base tables.
  ///
  /// `words_fts` is derived, so this is always safe and is the supported way to
  /// bring it forward across a migration: rebuild rather than patch. Call it
  /// from any migration step that touches `words` or `word_notes`.
  Future<void> rebuildFtsIndex() async {
    await transaction(() async {
      for (final trigger in _ftsTriggers) {
        await customStatement('DROP TRIGGER IF EXISTS $trigger');
      }
      await customStatement('DROP TABLE IF EXISTS words_fts');

      // Recreate from the schema the generated code carries, so there is one
      // definition of the index rather than two that can drift apart.
      await customStatement(_createFtsTable);
      await customStatement(
        'INSERT INTO words_fts (word_id, headword, definition, example, notes) '
        "SELECT w.id, w.headword, coalesce(w.definition, ''), "
        "coalesce(w.example, ''), "
        "coalesce((SELECT group_concat(n.body, ' ') FROM word_notes n "
        "WHERE n.word_id = w.id), '') "
        'FROM words w',
      );
      for (final statement in _ftsTriggerStatements) {
        await customStatement(statement);
      }
    });
  }

  static const List<String> _ftsTriggers = <String>[
    'words_fts_after_insert',
    'words_fts_after_update',
    'words_fts_after_delete',
    'notes_fts_after_insert',
    'notes_fts_after_update',
    'notes_fts_after_delete',
  ];

  // The trigger bodies, kept beside [rebuildFtsIndex] so a rebuild produces
  // exactly what `fts.drift` creates on a fresh install. If you change one,
  // change both - `fts_test.dart` asserts the two agree.
  static const String _notesAggregate =
      "coalesce((SELECT group_concat(body, ' ') FROM word_notes "
      "WHERE word_id = %s.word_id), '')";

  static String _notesTrigger(String name, String timing, String alias) =>
      'CREATE TRIGGER $name AFTER $timing ON word_notes BEGIN '
      'UPDATE words_fts SET notes = '
      '${_notesAggregate.replaceAll('%s', alias)} '
      'WHERE word_id = $alias.word_id; END';

  static const String _createFtsTable =
      'CREATE VIRTUAL TABLE words_fts USING fts5 '
      '(word_id UNINDEXED, headword, definition, example, notes, '
      "tokenize = 'unicode61 remove_diacritics 2')";

  static const String _wordsInsertTrigger =
      'CREATE TRIGGER words_fts_after_insert AFTER INSERT ON words BEGIN '
      'INSERT INTO words_fts (word_id, headword, definition, example, notes) '
      "VALUES (new.id, new.headword, coalesce(new.definition, ''), "
      "coalesce(new.example, ''), ''); END";

  static const String _wordsUpdateTrigger =
      'CREATE TRIGGER words_fts_after_update AFTER UPDATE ON words BEGIN '
      'UPDATE words_fts SET headword = new.headword, '
      "definition = coalesce(new.definition, ''), "
      "example = coalesce(new.example, '') "
      'WHERE word_id = new.id; END';

  static const String _wordsDeleteTrigger =
      'CREATE TRIGGER words_fts_after_delete AFTER DELETE ON words BEGIN '
      'DELETE FROM words_fts WHERE word_id = old.id; END';

  /// The six triggers, in the order they are created.
  static List<String> get _ftsTriggerStatements => <String>[
    _wordsInsertTrigger,
    _wordsUpdateTrigger,
    _wordsDeleteTrigger,
    _notesTrigger('notes_fts_after_insert', 'INSERT', 'new'),
    _notesTrigger('notes_fts_after_update', 'UPDATE', 'new'),
    _notesTrigger('notes_fts_after_delete', 'DELETE', 'old'),
  ];
}
