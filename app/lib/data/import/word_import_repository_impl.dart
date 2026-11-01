import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:vocabnote/core/failure.dart';
import 'package:vocabnote/core/result.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/import/word_csv_parser.dart';
import 'package:vocabnote/data/repositories/mappers.dart';
import 'package:vocabnote/domain/entities/app_settings.dart';
import 'package:vocabnote/domain/entities/study_card.dart';
import 'package:vocabnote/domain/entities/word.dart';
import 'package:vocabnote/domain/entities/word_import.dart';
import 'package:vocabnote/domain/entities/word_list.dart';
import 'package:vocabnote/domain/repositories/word_import_repository.dart';
import 'package:vocabnote/domain/value_objects/headword.dart';
import 'package:vocabnote/domain/value_objects/ipa_color_token.dart';

/// Drift-backed [WordImportRepository].
class WordImportRepositoryImpl implements WordImportRepository {
  /// Creates the repository over the given database.
  new(this._db, {this._uuid = const Uuid(), DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final Uuid _uuid;
  final DateTime Function() _now;

  @override
  AsyncResult<WordImportPreview> preview(Uint8List bytes) =>
      Results.guard(() async {
        final parsed = WordCsvParser.readFile(bytes);
        if (parsed.problem case final WordImportProblem problem) {
          return WordImportPreview.refused(problem);
        }

        final words = _fold(parsed.rows);
        var existing = 0;
        for (final row in words) {
          final key = Headword.normalize(row.headword);
          if (await _db.wordsDao.findByNormalized(key) != null) existing++;
        }

        final all = await _db.select(_db.wordLists).get();
        Set<String> names(ListKind kind) => <String>{
          for (final list in all)
            if (list.kind == kind) _key(list.name),
        };
        final knownLists = names(ListKind.list);
        final knownTags = names(ListKind.tag);
        final newLists = <String>[
          for (final row in words)
            if (row.category case final String name)
              if (knownLists.add(_key(name))) name,
        ];
        final newTags = <String>[
          for (final row in words)
            for (final name in row.tagNames)
              if (knownTags.add(_key(name))) name,
        ];

        return WordImportPreview(
          rows: parsed.rows,
          skippedLines: parsed.skipped,
          newWords: words.length - existing,
          existingWords: existing,
          newListNames: newLists,
          newTagNames: newTags,
        );
      }, onError: (_, _) => const DatabaseFailure(operation: 'preview import'));

  @override
  AsyncResult<WordImportReport> import(
    WordImportPreview preview, {
    required TtsLocale accent,
    required String fallbackList,
  }) => Results.guard(() async {
    final now = _now();
    var added = 0;
    var filled = 0;
    var unchanged = 0;
    var listsCreated = 0;
    var tagsCreated = 0;

    // One transaction: a deck half-imported is worse than none, because the
    // user cannot tell which half.
    await _db.transaction(() async {
      final lists = await _db.select(_db.wordLists).get();
      // By kind as well as name: a list "Verbs" and a tag "verbs" are two
      // different things, and a deck can well have both.
      final listIds = <(ListKind, String), String>{
        for (final list in lists) (list.kind, _key(list.name)): list.id,
      };
      var order = lists.length;

      Future<String> listFor(String name, ListKind kind) async {
        if (listIds[(kind, _key(name))] case final String id) return id;
        final id = _uuid.v4();
        await _db.listsDao.insertList(
          WordListsCompanion.insert(
            id: id,
            name: name,
            colorToken:
                IpaColorToken.values[order % IpaColorToken.values.length],
            sortOrder: order,
            createdAt: now,
            updatedAt: now,
            kind: Value(kind),
          ),
        );
        order++;
        switch (kind) {
          case ListKind.list:
            listsCreated++;
          case ListKind.tag:
            tagsCreated++;
        }
        return listIds[(kind, _key(name))] = id;
      }

      for (final row in _fold(preview.rows)) {
        final headword = Headword(row.headword);
        final existing = await _db.wordsDao.findByNormalized(
          headword.normalized,
        );
        final String wordId;
        if (existing == null) {
          wordId = _uuid.v4();
          await _db.wordsDao.insertWord(
            WordsCompanion.insert(
              id: wordId,
              headword: headword.value,
              headwordNormalized: headword.normalized,
              source: const Value(WordSource.manual),
              ipaUk: Value(accent == TtsLocale.enGb ? row.ipa : null),
              ipaUs: Value(accent == TtsLocale.enUs ? row.ipa : null),
              definition: Value(row.meaning),
              createdAt: now,
              updatedAt: now,
            ),
          );
          await _db.practiceDao.insertCard(
            StudyCard.newCard(wordId: wordId, now: now).toCompanion(),
          );
          added++;
        } else {
          wordId = existing.id;
          // Never overwrite: only a field that is empty takes the file's value.
          bool blank(String? value) => value == null || value.trim().isEmpty;
          final fillIpa =
              row.ipa != null &&
              blank(accent == TtsLocale.enGb ? existing.ipaUk : existing.ipaUs);
          final fillMeaning = row.meaning != null && blank(existing.definition);
          if (fillIpa || fillMeaning) {
            await _db.wordsDao.patchWord(
              wordId,
              WordsCompanion(
                ipaUk: fillIpa && accent == TtsLocale.enGb
                    ? Value(row.ipa)
                    : const Value.absent(),
                ipaUs: fillIpa && accent == TtsLocale.enUs
                    ? Value(row.ipa)
                    : const Value.absent(),
                definition: fillMeaning
                    ? Value(row.meaning)
                    : const Value.absent(),
                updatedAt: Value(now),
              ),
            );
            filled++;
          } else {
            unchanged++;
          }
        }

        final category =
            row.category ??
            (existing != null && await _db.listsDao.isInAnyList(wordId)
                ? null
                : fallbackList);
        if (category != null) {
          await _db.listsDao.addWord(
            listId: await listFor(category, ListKind.list),
            wordId: wordId,
            addedAt: now,
          );
        }
        for (final name in row.tagNames) {
          await _db.listsDao.addWord(
            listId: await listFor(name, ListKind.tag),
            wordId: wordId,
            addedAt: now,
          );
        }
      }
    });

    return WordImportReport(
      added: added,
      filled: filled,
      unchanged: unchanged,
      skipped: preview.skippedLines,
      listsCreated: listsCreated,
      tagsCreated: tagsCreated,
    );
  }, onError: (_, _) => const DatabaseFailure(operation: 'import words'));

  /// List names match whatever their case or surrounding spaces.
  static String _key(String name) => name.trim().toLowerCase();

  /// One row per word: a word the file names twice keeps its first spelling
  /// and its first IPA, meaning and category, and takes every tag either row
  /// names.
  static List<WordImportRow> _fold(List<WordImportRow> rows) {
    final byWord = <String, WordImportRow>{};
    for (final row in rows) {
      final key = Headword.normalize(row.headword);
      final first = byWord[key];
      if (first == null) {
        byWord[key] = row;
        continue;
      }
      final names = <String>{for (final n in first.tagNames) _key(n)};
      byWord[key] = WordImportRow(
        line: first.line,
        headword: first.headword,
        ipa: first.ipa ?? row.ipa,
        meaning: first.meaning ?? row.meaning,
        category: first.category ?? row.category,
        tagNames: <String>[
          ...first.tagNames,
          for (final name in row.tagNames)
            if (names.add(_key(name))) name,
        ],
      );
    }
    return byWord.values.toList();
  }
}
