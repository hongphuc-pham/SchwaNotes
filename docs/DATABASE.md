# Database & upgrade safety

> The single most important non-negotiable in this project: **installing a new version of
> Schwa Notes must adopt the user's existing database, in place, without data loss.**
> There is no backend to restore from. A wiped database is a permanently lost user.

## 1. Storage

| Item | Value |
|---|---|
| Engine | SQLite via Drift (`package:sqlite3` 3.x bundles the native libraries — same version on both platforms; `sqlite3_flutter_libs` is an EOL stub since 0.6.0, see ARCHITECTURE §3.1) |
| Path | `getApplicationSupportDirectory()/vocabnote/vocabnote.sqlite` |
| Android | `/data/data/<pkg>/files/…` — survives app updates, cleared on uninstall |
| iOS | `Library/Application Support/…` — survives app updates, cleared on uninstall |
| Journal | WAL (`PRAGMA journal_mode=WAL`) |
| Keys | `PRAGMA foreign_keys=ON` (set in `beforeOpen`, after migration) |
| Backups | Android Auto Backup enabled; iOS included in iCloud backup; plus manual export |

`getApplicationDocumentsDirectory()` is **not** used: on iOS it is user-visible via Files
sharing and invites accidental deletion.

## 2. Schema (v1)

IDs are `TEXT` UUID v4 so exports can be merged across devices later without collisions.
All timestamps are `INTEGER` epoch **milliseconds UTC**.

### `words`
| Column | Type | Notes |
|---|---|---|
| `id` | TEXT PK | uuid |
| `headword` | TEXT NOT NULL | as the user typed it |
| `headword_normalized` | TEXT NOT NULL | lowercased, trimmed — for dedupe + search |
| `part_of_speech` | TEXT NULL | noun/verb/… free text |
| `ipa_uk` | TEXT NULL | without slashes; UI adds them |
| `ipa_us` | TEXT NULL | |
| `definition` | TEXT NULL | |
| `example` | TEXT NULL | |
| `source` | TEXT NOT NULL | `manual` \| `api` \| `offline` \| `mixed` |
| `source_attribution` | TEXT NULL | e.g. `Wiktionary via FreeDictionaryAPI.com — CC BY-SA 4.0` + source URL |
| `is_favourite` | INTEGER NOT NULL DEFAULT 0 | |
| `is_archived` | INTEGER NOT NULL DEFAULT 0 | hidden from lists, kept for stats |
| `created_at` / `updated_at` | INTEGER NOT NULL | |
| `deleted_at` | INTEGER NULL | soft delete; purged after 30 days |

Index: `idx_words_normalized (headword_normalized)`, `idx_words_updated (updated_at DESC)`.

### `word_notes` — the user's own comments, many per word
`id` PK · `word_id` FK→words ON DELETE CASCADE · `body` TEXT NOT NULL · `created_at` ·
`updated_at` · `pinned` INTEGER NOT NULL DEFAULT 0.

### `ipa_highlights` — the signature feature
`id` PK · `word_id` FK CASCADE · `target` TEXT NOT NULL (`ipa_uk`\|`ipa_us`) ·
`start_grapheme` INTEGER NOT NULL · `end_grapheme` INTEGER NOT NULL (exclusive) ·
`color_token` TEXT NOT NULL (`amber`\|`coral`\|`violet`\|`teal`\|`blue` — token names, **not**
hex, so themes can change) · `label` TEXT NULL · `created_at`.

> Offsets are **grapheme cluster** indices over the stored IPA string (see ARCHITECTURE
> ADR-006). Editing the IPA string re-validates highlights and drops any range that no longer
> fits, warning the user first.

### `word_lists` (decks)
`id` PK · `name` TEXT NOT NULL · `color_token` TEXT NOT NULL · `icon_key` TEXT NULL ·
`sort_order` INTEGER NOT NULL · `created_at` · `updated_at`.

> **No seeded "All words" row** *(decided at M1)*. **All** is a filter chip
> (`UI-UX.md` §4.1), not a list. A row would be renameable, recolourable, reorderable and
> deletable, none of which is true of "all your words". `onCreate` therefore seeds only the
> `settings` row and the `app_meta` keys.

### `word_list_items`
`list_id` FK CASCADE · `word_id` FK CASCADE · `added_at` · PRIMARY KEY (`list_id`,`word_id`).

### `study_cards` — one per word, SRS-ready from day one
`word_id` PK FK CASCADE · `box` INTEGER NOT NULL DEFAULT 0 (Leitner 0–6, see docs/GAMES.md §5) ·
`due_at` INTEGER NOT NULL · `interval_days` INTEGER NOT NULL DEFAULT 0 ·
`ease_factor` REAL NOT NULL DEFAULT 2.5 *(unused in v1, present for SM-2)* ·
`repetitions` INTEGER NOT NULL DEFAULT 0 · `lapses` INTEGER NOT NULL DEFAULT 0 ·
`last_reviewed_at` INTEGER NULL · `last_result` TEXT NULL (`again`\|`good`\|`easy`) ·
`suspended` INTEGER NOT NULL DEFAULT 0.

Indexes: `idx_cards_due (due_at, suspended)` · `idx_cards_box_lapses (box, lapses)`
*(added at schema v2 — the least-known sort orders on exactly this pair and was the slowest
query in the app by 15× without it; PROGRESS §3 decision 3).*

### `practice_sessions`
`id` PK · `game_id` TEXT NOT NULL (`flashcard`, later `ipa_match`, …) ·
`mode` TEXT NOT NULL (`daily`\|`quick_test`) · `source_kind` TEXT NOT NULL (`all`\|`list`\|`favourites`) ·
`source_id` TEXT NULL · `config_json` TEXT NOT NULL (full `GameConfig`, forward-compatible) ·
`started_at` · `ended_at` NULL · `total_rounds` · `correct_rounds` · `affects_scheduling` INTEGER NOT NULL.

### `practice_answers`
`id` PK · `session_id` FK CASCADE · `word_id` FK CASCADE · `round_index` ·
`result` TEXT NOT NULL · `response_ms` INTEGER NULL · `answered_at`.

### `app_meta` — key/value
`key` PK · `value` TEXT. Holds `schema_version_mirror`, `onboarding_completed`,
`last_backup_at`, `install_id` (random, local-only, never transmitted).

### `settings` — single row (`id = 1`)
`theme_mode` · `tts_locale` (`en-GB`\|`en-US`) · `tts_rate` REAL · `tts_pitch` REAL ·
`autoplay_on_open` INTEGER · `daily_goal` INTEGER DEFAULT 20 · `reminder_enabled` INTEGER ·
`reminder_time_minutes` INTEGER NULL · `prompt_side` TEXT · `lookup_enabled` INTEGER DEFAULT 1 ·
`review_schedule` TEXT DEFAULT `'[0,1,2,4,7,15,30]'` · `again_repeats` INTEGER DEFAULT 1
*(both added at schema v2)*.

`review_schedule` is the interval each Leitner box waits, as a JSON array of seven integers.
Its default **is** the `GAMES.md` §5 table, so a user who never opens Settings gets exactly
the documented behaviour. Stored as JSON rather than seven columns because the user edits it
as a unit, and because a `Sm2Scheduler` in phase 2 would want a different shape entirely
(ADR-005). `again_repeats` is how many extra times a card graded *again* may return **within
the same session**; it touches no scheduling column, and 0 disables it.

### `words_fts` — FTS5 virtual table
Over `headword`, `definition`, `example`, and note bodies; kept in sync by triggers.
It is a **derived** table: it may be dropped and rebuilt in any migration without data loss.

## 3. Migration policy (the rules that keep promise P2)

1. **`schemaVersion` increments by exactly 1 per released schema change.** Never reuse a number.
2. **Additive only.** Add tables and columns. Do not drop or rename a column that has ever
   shipped; mark it deprecated in a comment and stop writing to it.
3. **Every new column is nullable or has a non-null DEFAULT.** No exceptions.
4. **Use generated step-by-step migrations.** After every schema change:
   ```bash
   dart run drift_dev schema dump  lib/data/db/app_database.dart drift_schemas/
   dart run drift_dev schema steps drift_schemas/ lib/data/db/schema_versions.dart
   dart run drift_dev schema generate --data-classes --companions drift_schemas/ test/migration/generated/
   ```

   `drift_schemas/` and `schema_versions.dart` are **committed**.

   The `--data-classes --companions` flags matter: without them the generated helpers have
   table definitions but no companions, and a migration test cannot write rows the way an
   older version wrote them. Note also that those helpers type booleans as `int`, so a
   seed writes `Value(1)`, not `Value(true)`.
5. **A migration test is part of the same PR.** For new version *n* you must add:
   - `n-1 → n` with seeded rows, asserting every row survives with correct values;
   - `1 → n` end-to-end (a user who skipped five releases must upgrade cleanly);
   - `validateDatabaseSchema()` passes after migrating.
   CI blocks the merge if `test/migration/` fails.
6. **Automatic pre-migration backup.** `bootstrap.dart` copies the DB to
   `vocabnote.pre-v<n>.bak` before opening when the on-disk version is lower than
   `schemaVersion`. On success the backup is kept until the next migration — or until the
   user chooses *Delete all data*, which removes every copy of the library (§5); on failure
   it is restored and the app shows a recovery screen with *Export my data*. *Since M6* that
   button works: it opens the file with `package:sqlite3` directly, **read-only**, and writes
   the same `.vnb` as any other backup through the same table reader — the format names SQL
   columns, so no Drift code is needed to read a file Drift refused. A table the file's schema
   never had is exported empty (`data/backup/recovery_export.dart`).
   Implemented in `data/db/database_opener.dart` (so it can be tested against a temporary
   directory rather than a device) and surfaced by
   `presentation/common/recovery_screen.dart`. The on-disk version is read with a raw
   `PRAGMA user_version` **before** Drift opens the file — asking Drift would run the
   migration, which is the very thing being decided.
7. **Migrations run in a transaction** and are idempotent — safe to re-run after a crash.
8. **Never `deleteDatabase()`, never "recreate on error", never `if (from != to) drop`.**
   Any PR containing those patterns is rejected. There is a CI grep for them.
9. **Data backfills are guarded**: `UPDATE … WHERE new_col IS NULL`, never blanket rewrites.
10. **Downgrade is not supported** but must not destroy anything: if the on-disk version is
    *higher* than the binary's, refuse to open, show "This data was created by a newer version
    of Schwa Notes — please update", and offer export. Do not migrate downwards.

## 4. Worked example — adding a field in v2

```dart
// tables/words.dart
TextColumn get synonyms => text().nullable()();   // v2

// app_database.dart
@override int get schemaVersion => 2;

@override
MigrationStrategy get migration => MigrationStrategy(
  onCreate: (m) async {
    await m.createAll();
    await _seedDefaults();
  },
  onUpgrade: stepByStep(
    from1To2: (m, schema) async {
      await m.addColumn(schema.words, schema.words.synonyms);
    },
  ),
  beforeOpen: (details) async {
    await customStatement('PRAGMA foreign_keys = ON');
    if (kDebugMode) await _assertExpectedTablesExist();   // see note below
  },
);
```

> **Correction, made at M1.** Earlier revisions of this section showed drift's own
> `validateDatabaseSchema()` inside `beforeOpen`. That call lives in `package:drift_dev`, a
> **dev** dependency — invoking it from `lib/` would ship the Dart analyzer inside the app.
> So the split is:
>
> * **production**, in `beforeOpen` under `kDebugMode`: `_assertExpectedTablesExist()`, a
>   cheap check that every expected table is present, which turns a confusing "no such
>   column" three screens later into an obvious failure at startup;
> * **tests**, in `test/migration/`: the real `db.validateDatabaseSchema()` plus
>   `SchemaVerifier.migrateAndValidate()`, which compare the live schema against the
>   committed snapshot column by column.
>
> The blocking check is the one in CI; the runtime one is a convenience.

Test (`test/migration/v1_to_v2_test.dart`): open v1 with a seeded word + note + highlight +
card, migrate, assert all four rows are intact and `synonyms` is `NULL`.

## 5. Export / import (the user's own backup)

Because there is no cloud, export is how a user moves to a new phone.

- Format: `vocabnote-backup-YYYYMMDD-HHmm.vnb` — a ZIP containing `manifest.json`
  (`{app_version, schema_version, export_format_version, exported_at, counts}`) and
  `data.json` (all tables, arrays of objects).
- **The export format is versioned independently of the schema.** Readers must ignore unknown
  fields and default missing ones — an older app must be able to read a newer file's known parts.

*Built at M6 — export format version 1* (`data/backup/backup_codec.dart`):

- **Rows are keyed by SQL column name, with values as SQLite stores them** — epoch
  milliseconds, `0`/`1`, the documented enum strings. The file format *is* §2, not a second
  vocabulary, and export is `SELECT *`, so a column added by a later additive migration is
  carried without the exporter changing.
- `data.json` is `{"tables": {"<table>": [{row}, …]}}`. `exported_at` is ISO-8601 UTC.
- **Carried**, parents before children (the order they are restored in): `words` —
  soft-deleted ones too, with `deleted_at`, so Replace restores them within their window —
  `word_notes`, `ipa_highlights`, `word_lists`, `word_list_items`, `study_cards`,
  `practice_sessions`, `practice_answers`, `settings`.
- **Not carried:** `app_meta` — `install_id` is local-only by promise (`DATA-SOURCES.md` §7)
  and the other keys describe this install, not the library — and `words_fts`, which is
  derived.
- **Refused before anything is written:** a file over 64 MB, or an entry declaring more than
  256 MB inflated (`package:archive` has no zip-bomb guard of its own); a file that is not a
  ZIP, or a ZIP with no `manifest.json` (*not a backup*); a ZIP that cannot be read — most
  often one cut short by an interrupted download — or whose manifest or data is not a JSON
  object (*damaged*).
- **Accepted, because it is merely unfamiliar:** a newer format or schema version, unknown
  keys, unknown tables. A row that is not an object is dropped and counted; a manifest value
  of the wrong type takes its default.
- The export is read in one transaction, so it is a single moment of the library; encoded off
  the UI isolate; written to the OS temporary directory (earlier exports there are removed —
  each is a full copy of the user's words); and handed to the share sheet.
  `app_meta.last_backup_at` moves only when the sheet reports the file went somewhere, or
  cannot say — never for a file still sitting in a cache folder.

*Built at M6 — import* (`data/backup/backup_importer.dart`, `backup_merge.dart`,
`backup_rows.dart`):

- **Rows are checked against the live Drift schema first** — its own column list, so a
  column added later is understood without the reader changing. Unknown columns are ignored;
  a missing column that has a default is left for SQLite to fill; a missing column without
  one, or a value of the wrong type, refuses that row. Refused rows, and rows pointing at
  something the backup does not contain, are counted for the report — never a reason to
  refuse the rest. Things attached to a word the backup itself had deleted are skipped
  quietly: they are not broken.
- **Merge only adds and updates.** It never deletes or hides a word:

  | Table | Matched on | When both sides have it |
  |---|---|---|
  | `words` | `id`, then a live word's `headword_normalized` | newer `updated_at` wins the content; a word deleted in the backup is skipped; a word deleted here comes back if the backup's live copy is newer |
  | `word_notes` | `id` (the word remapped to this phone's) | newer `updated_at` wins |
  | `ipa_highlights` | `id` | added only if absent, only onto the transcription it was drawn on, and only if its range fits that transcription's grapheme length |
  | `word_lists` | `id`, then trimmed case-insensitive `name` | newer `updated_at` wins name, colour and icon; new lists go after this phone's |
  | `word_list_items` | both ids, remapped | added if absent |
  | `study_cards` | the word, remapped | the card reviewed most recently wins |
  | `practice_sessions`, `practice_answers` | `id` | added if absent; a session practised from a list follows that list |
  | `settings` | — | this phone keeps its own — *unless it is still on the defaults*, as a new phone is, in which case it takes the backup's. Otherwise moving to a new phone with the default mode would silently drop the user's review schedule and goal. |

- **Replace** writes a safety copy of the current library to
  `<app support>/vocabnote/backups/vocabnote-before-replace-<time>.vnb` — the newest three
  are kept — **before anything is touched**, and does nothing if that copy cannot be
  written. It then empties every table and writes the backup's rows, each reference checked
  before its row is written, so no single bad row can abort the rest.
- **Neither restores the daily reminder.** It needs this phone's notification permission, and
  only its own switch may ask (F-066); the chosen time is kept.
- Both run in **one transaction**: a failure part-way leaves the library exactly as it was.
  That is tested with a SQLite trigger forcing a real failure mid-import, not a hook in the
  code. The file is decoded off the UI isolate, and refused before anything — even the
  safety copy — is written.
- The round trip, export → wipe → import → every table deep-equal, runs on the host in
  `test/unit/data/backup_replace_test.dart`; the device run lives in `integration_test/`.

*Built at M6 — Delete all data* (`UserDataRepository.deleteAll`, `UI-UX.md` §4.9):

- A hard delete on explicit user action, which RULES §10 allows, behind a typed confirmation
  (RULES §11). Every backed-up table is emptied in one transaction and `settings` returns
  to its defaults. `app_meta` stays: `install_id` and a finished onboarding describe the
  install, not the library.
- **Then every other copy of the library on disk goes too:** Replace's safety copies, any
  exported `.vnb` still in the temporary folder, the `vocabnote.pre-v<n>.bak` copies taken
  before an upgrade, the dictionary cache, and the error log (a message line in it may hold
  something the user typed). So are the copies the OS plugins keep in the app's cache: the
  share sheet's copy of the last export (`share_plus` clears it only at the next share) and
  the picker's copy of a chosen backup (also cleared as soon as it has been read). Each is
  removed independently and best-effort
  — the rows are already gone, and one file that will not delete must not keep the others.
  The open database file itself is emptied, never deleted — and then **scrubbed**: deleting
  a row does not erase it, and FTS5 keeps a deleted word's tokens in its index segments
  until they merge (found on a device: the headword was still in the file four times). The
  index is rebuilt from its now-empty content (`INSERT INTO words_fts(words_fts)
  VALUES('rebuild')`) and `VACUUM` rewrites every page, so no word is left readable in the
  file. Tested on a file-backed database.
- The reminder is cancelled with the OS, since its setting is back to off.
- Import offers **Merge** (default: match on `id`, then on `headword_normalized`; newer
  `updated_at` wins) or **Replace** (explicit confirmation, takes a backup first).
- Import runs in one transaction and reports a summary: added / updated / skipped.
- Round-trip is covered by an integration test: export → wipe → import → deep-equal.
