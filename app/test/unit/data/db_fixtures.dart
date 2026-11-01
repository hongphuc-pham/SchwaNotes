/// Seed helpers for the data-layer tests.
///
/// Every helper takes explicit ids and timestamps so a test asserts on values
/// it chose, never on whatever the clock or a uuid generator produced.
library;

import 'package:drift/drift.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/domain/entities/ipa_highlight.dart';
import 'package:vocabnote/domain/entities/practice_session.dart';
import 'package:vocabnote/domain/entities/study_card.dart';
import 'package:vocabnote/domain/entities/word.dart';
import 'package:vocabnote/domain/entities/word_list.dart';
import 'package:vocabnote/domain/value_objects/ipa_color_token.dart';

/// A fixed instant, so timestamp assertions are stable.
final DateTime testNow = DateTime.utc(2026, 9, 9, 12);

/// Inserts a word, and the study card that always accompanies one.
Future<void> seedWord(
  AppDatabase db, {
  required String id,
  required String headword,
  WordSource source = WordSource.manual,
  String? ipaUk,
  String? ipaUs,
  String? definition,
  String? example,
  bool isFavourite = false,
  bool isArchived = false,
  DateTime? createdAt,
  DateTime? updatedAt,
  DateTime? dueAt,
  int box = 0,
  bool withCard = true,
}) async {
  final created = createdAt ?? testNow;
  await db
      .into(db.words)
      .insert(
        WordsCompanion.insert(
          id: id,
          headword: headword,
          headwordNormalized: headword.trim().toLowerCase(),
          source: Value(source),
          ipaUk: Value(ipaUk),
          ipaUs: Value(ipaUs),
          definition: Value(definition),
          example: Value(example),
          isFavourite: Value(isFavourite),
          isArchived: Value(isArchived),
          createdAt: created,
          updatedAt: updatedAt ?? created,
        ),
      );

  if (withCard) {
    await db
        .into(db.studyCards)
        .insert(
          StudyCardsCompanion.insert(
            wordId: id,
            dueAt: dueAt ?? created,
            box: Value(box),
          ),
        );
  }
}

/// Inserts a note on an existing word.
Future<void> seedNote(
  AppDatabase db, {
  required String id,
  required String wordId,
  required String body,
  bool pinned = false,
  DateTime? createdAt,
}) async {
  final created = createdAt ?? testNow;
  await db
      .into(db.wordNotes)
      .insert(
        WordNotesCompanion.insert(
          id: id,
          wordId: wordId,
          body: body,
          createdAt: created,
          updatedAt: created,
          pinned: Value(pinned),
        ),
      );
}

/// Inserts a highlight on an existing word.
Future<void> seedHighlight(
  AppDatabase db, {
  required String id,
  required String wordId,
  HighlightTarget target = HighlightTarget.ipaUk,
  IpaColorToken color = IpaColorToken.amber,
  int start = 0,
  int end = 2,
  String? label,
  DateTime? createdAt,
}) async {
  await db
      .into(db.ipaHighlights)
      .insert(
        IpaHighlightsCompanion.insert(
          id: id,
          wordId: wordId,
          target: target,
          startGrapheme: start,
          endGrapheme: end,
          colorToken: color,
          label: Value(label),
          createdAt: createdAt ?? testNow,
        ),
      );
}

/// Inserts a list.
Future<void> seedList(
  AppDatabase db, {
  required String id,
  required String name,
  IpaColorToken color = IpaColorToken.teal,
  int sortOrder = 0,
  DateTime? createdAt,
  ListKind kind = ListKind.list,
}) async {
  final created = createdAt ?? testNow;
  await db
      .into(db.wordLists)
      .insert(
        WordListsCompanion.insert(
          id: id,
          name: name,
          colorToken: color,
          sortOrder: sortOrder,
          kind: Value(kind),
          createdAt: created,
          updatedAt: created,
        ),
      );
}

/// Puts a word in a list.
Future<void> seedMembership(
  AppDatabase db, {
  required String listId,
  required String wordId,
  DateTime? addedAt,
}) async {
  await db
      .into(db.wordListItems)
      .insert(
        WordListItemsCompanion.insert(
          listId: listId,
          wordId: wordId,
          addedAt: addedAt ?? testNow,
        ),
      );
}

/// Opens a practice session.
Future<void> seedSession(
  AppDatabase db, {
  required String id,
  String gameId = 'flashcard',
  PracticeMode mode = PracticeMode.daily,
  CardSourceKind sourceKind = CardSourceKind.all,
  String? sourceId,
  String configJson = '{}',
  DateTime? startedAt,
  DateTime? endedAt,
  int totalRounds = 0,
  int correctRounds = 0,
  bool? affectsScheduling,
}) async {
  await db
      .into(db.practiceSessions)
      .insert(
        PracticeSessionsCompanion.insert(
          id: id,
          gameId: gameId,
          mode: mode,
          sourceKind: sourceKind,
          sourceId: Value(sourceId),
          configJson: configJson,
          startedAt: startedAt ?? testNow,
          endedAt: Value(endedAt),
          totalRounds: Value(totalRounds),
          correctRounds: Value(correctRounds),
          affectsScheduling: affectsScheduling ?? mode.affectsScheduling,
        ),
      );
}

/// Records an answer within a session.
Future<void> seedAnswer(
  AppDatabase db, {
  required String id,
  required String sessionId,
  required String wordId,
  int roundIndex = 0,
  ReviewOutcome result = ReviewOutcome.good,
  int? responseMs,
  DateTime? answeredAt,
}) async {
  await db
      .into(db.practiceAnswers)
      .insert(
        PracticeAnswersCompanion.insert(
          id: id,
          sessionId: sessionId,
          wordId: wordId,
          roundIndex: roundIndex,
          result: result,
          responseMs: Value(responseMs),
          answeredAt: answeredAt ?? testNow,
        ),
      );
}

/// Seeds [count] words, for the performance and cap tests.
///
/// Headwords are generated so search terms are predictable: `word0000`,
/// `word0001`, and so on, each with a definition and an example.
Future<void> seedManyWords(AppDatabase db, int count) async {
  await db.batch((batch) {
    for (var i = 0; i < count; i++) {
      final id = 'w${i.toString().padLeft(5, '0')}';
      final headword = 'word${i.toString().padLeft(4, '0')}';
      batch
        ..insert(
          db.words,
          WordsCompanion.insert(
            id: id,
            headword: headword,
            headwordNormalized: headword,
            definition: Value('definition for $headword'),
            example: Value('an example using $headword'),
            ipaUs: Value('wɜːd$i'),
            createdAt: testNow.add(Duration(seconds: i)),
            updatedAt: testNow.add(Duration(seconds: i)),
          ),
        )
        ..insert(
          db.studyCards,
          StudyCardsCompanion.insert(
            wordId: id,
            dueAt: testNow.add(Duration(minutes: i)),
            box: Value(i % 7),
          ),
        );
    }
  });
}
