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

        final known = <String>{
          for (final list in await _db.select(_db.wordLists).get())
            _key(list.name),
        };
        final newLists = <String>[
          for (final row in words)
            for (final name in row.listNames)
              if (known.add(_key(name))) name,
        ];

        return WordImportPreview(
          rows: parsed.rows,
          skippedLines: parsed.skipped,
          newWords: words.length - existing,
          existingWords: existing,
          newListNames: newLists,
        );
      }, onError: (_, _) => const DatabaseFailure(operation: 'preview import'));

  @override
  AsyncResult<WordImportReport> import(
    WordImportPreview preview, {
    required TtsLocale accent,
  }) => Results.guard(() async {
    final now = _now();
    var added = 0;
    var filled = 0;
    var unchanged = 0;
    var listsCreated = 0;

    // One transaction: a deck half-imported is worse than none, because the
    // user cannot tell which half.
    await _db.transaction(() async {
      final lists = await _db.select(_db.wordLists).get();
      final listIds = <String, String>{
        for (final list in lists) _key(list.name): list.id,
      };
      var order = lists.length;

      Future<String> listFor(String name) async {
        if (listIds[_key(name)] case final String id) return id;
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
          ),
        );
        order++;
        listsCreated++;
        return listIds[_key(name)] = id;
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

        for (final name in row.listNames) {
          await _db.listsDao.addWord(
            listId: await listFor(name),
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
    );
  }, onError: (_, _) => const DatabaseFailure(operation: 'import words'));

  /// List names match whatever their case or surrounding spaces.
  static String _key(String name) => name.trim().toLowerCase();

  /// One row per word: a word the file names twice keeps its first spelling
  /// and its first IPA and meaning, and joins every list either row names.
  static List<WordImportRow> _fold(List<WordImportRow> rows) {
    final byWord = <String, WordImportRow>{};
    for (final row in rows) {
      final key = Headword.normalize(row.headword);
      final first = byWord[key];
      if (first == null) {
        byWord[key] = row;
        continue;
      }
      final names = <String>{for (final n in first.listNames) _key(n)};
      byWord[key] = WordImportRow(
        line: first.line,
        headword: first.headword,
        ipa: first.ipa ?? row.ipa,
        meaning: first.meaning ?? row.meaning,
        listNames: <String>[
          ...first.listNames,
          for (final name in row.listNames)
            if (names.add(_key(name))) name,
        ],
      );
    }
    return byWord.values.toList();
  }
}
