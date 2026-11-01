import 'package:drift/drift.dart';
import 'package:vocabnote/core/failure.dart';
import 'package:vocabnote/core/result.dart';
import 'package:vocabnote/core/utils/combine_latest.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/db/daos/practice_dao.dart';
import 'package:vocabnote/data/repositories/mappers.dart';
import 'package:vocabnote/domain/entities/ipa_highlight.dart';
import 'package:vocabnote/domain/entities/practice_progress.dart';
import 'package:vocabnote/domain/entities/practice_session.dart';
import 'package:vocabnote/domain/entities/study_card.dart';
import 'package:vocabnote/domain/entities/word_overview.dart';
import 'package:vocabnote/domain/repositories/practice_repository.dart';

/// Drift-backed [PracticeRepository].
class PracticeRepositoryImpl implements PracticeRepository {
  /// Creates the repository over the given database.
  new(this._db, {DateTime Function()? now}) : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  AppFailure _dbFailure(String operation) =>
      DatabaseFailure(operation: operation);

  @override
  AsyncResult<List<PracticeCardData>> loadPool({
    required CardSelection selection,
    required PracticeMode mode,
    required int limit,
    CardSourceKind source = CardSourceKind.all,
    String? sourceId,
    int? seed,
  }) => Results.guard(() async {
    final pool = switch (selection) {
      CardSelection.due => await _db.practiceDao.dueCards(
        limit: limit,
        now: _now(),
        source: source,
        sourceId: sourceId,
      ),
      CardSelection.random => await _db.practiceDao.randomCards(
        limit: limit,
        source: source,
        sourceId: sourceId,
        seed: seed,
      ),
      CardSelection.weakest => await _db.practiceDao.weakestCards(
        limit: limit,
        source: source,
        sourceId: sourceId,
      ),
      CardSelection.newest => await _db.practiceDao.newestCards(
        limit: limit,
        source: source,
        sourceId: sourceId,
      ),
    };

    return await _attachHighlights(pool);
  }, onError: (_, _) => _dbFailure('load practice pool'));

  /// Loads the highlights and first notes for a whole pool and attaches them.
  ///
  /// A running game must never touch the database, so everything a round can
  /// need is resolved before the session starts (`docs/GAMES.md` §2).
  ///
  /// The pool's order is kept. A daily review is already due-first, and a
  /// quick test was drawn by its seed in the query; shuffling here would throw
  /// the first away and add nothing to the second.
  Future<List<PracticeCardData>> _attachHighlights(
    List<WordWithCard> pool,
  ) async {
    if (pool.isEmpty) return <PracticeCardData>[];

    final ids = pool.map((entry) => entry.word.id).toSet();
    final grouped = await _db.highlightsDao.groupedByWords(ids);
    final firstNotes = await _db.notesDao.firstBodyByWord(ids);

    return <PracticeCardData>[
      for (final entry in pool)
        PracticeCardData(
          word: entry.word.toEntity(),
          card: entry.card.toEntity(),
          highlights: (grouped[entry.word.id] ?? const <IpaHighlightRow>[])
              .map((row) => row.toEntityOrNull())
              .whereType<IpaHighlight>()
              .toList(),
          firstNote: firstNotes[entry.word.id],
        ),
    ];
  }

  @override
  ResultStream<int> watchDueCount() => _db.practiceDao.watchDueCount().guarded(
    onError: (_, _) => _dbFailure('count due cards'),
  );

  @override
  AsyncResult<void> createCardForWord(String wordId) => Results.guard(
    () => _db.practiceDao.insertCard(
      StudyCard.newCard(wordId: wordId, now: _now()).toCompanion(),
    ),
    onError: (_, _) => _dbFailure('create study card'),
  );

  @override
  AsyncResult<PracticeSession> startSession(PracticeSession session) =>
      Results.guard(() async {
        await _db.practiceDao.insertSession(session.toCompanion());
        return session;
      }, onError: (_, _) => _dbFailure('start practice session'));

  @override
  AsyncResult<void> recordAnswer({
    required PracticeAnswer answer,
    required bool affectsScheduling,
    StudyCard? updatedCard,
  }) => Results.guard(
    () => _db.transaction(() async {
      await _db.practiceDao.insertAnswer(answer.toCompanion());

      // The single most important line in the practice layer: a quick test
      // records answers and leaves study_cards alone. Asserted by
      // practice_repository_test.dart.
      if (affectsScheduling && updatedCard != null) {
        await _db.practiceDao.updateCard(
          updatedCard.wordId,
          updatedCard.toCompanion(),
        );
      }
    }),
    onError: (_, _) => _dbFailure('record answer'),
  );

  @override
  AsyncResult<PracticeSession> endSession({
    required String sessionId,
    required DateTime endedAt,
    required int totalRounds,
    required int correctRounds,
  }) => Results.guard(() async {
    await _db.practiceDao.closeSession(
      sessionId,
      PracticeSessionsCompanion(
        endedAt: Value(endedAt),
        totalRounds: Value(totalRounds),
        correctRounds: Value(correctRounds),
      ),
    );
    final row = await _db.practiceDao.getSession(sessionId);
    if (row == null) {
      throw StateError('session $sessionId vanished while closing');
    }
    return row.toEntity();
  }, onError: (_, _) => _dbFailure('end practice session'));

  @override
  AsyncResult<PracticeSession?> getSession(String id) => Results.guard(
    () async => (await _db.practiceDao.getSession(id))?.toEntity(),
    onError: (_, _) => _dbFailure('read practice session'),
  );

  @override
  AsyncResult<List<PracticeAnswer>> answersForSession(String sessionId) =>
      Results.guard(
        () async =>
            (await _db.practiceDao.answersForSession(sessionId))
                .map((row) => row.toEntity())
                .toList(),
        onError: (_, _) => _dbFailure('read session answers'),
      );

  @override
  ResultStream<PracticeProgress> watchProgress() {
    final now = _now();
    final today = DateTime(now.year, now.month, now.day);
    final since = DateTime(
      now.year,
      now.month,
      now.day - PracticeProgress.lookBackDays,
    );

    return _db.practiceDao
        .watchAnswerQuarterHours(since)
        .asyncMap(
          (quarters) async => PracticeProgress(
            today: today,
            // A one-shot read beside the watch, so both halves describe the
            // same moment - and no `.first` on a second watch stream.
            wordsToday: await _db.practiceDao.countWordsAnsweredSince(today),
            daysPractised: <DateTime>{
              for (final quarter in quarters) _localDate(quarter),
            },
          ),
        )
        .guarded(onError: (_, _) => _dbFailure('watch practice progress'));
  }

  @override
  ResultStream<WordOverview> watchOverview() {
    final now = _now();
    final since = DateTime(
      now.year,
      now.month,
      now.day - (WordOverview.windowDays - 1),
    );
    final weekAgo = DateTime(now.year, now.month, now.day - 6);

    return combineLatest3(
      _db.practiceDao.watchBoxCounts(),
      _db.practiceDao.watchAnswerTallies(since),
      _db.practiceDao.watchWordsAddedSince(weekAgo),
      (boxes, tallies, added) {
        final stages = <KnowledgeStage, int>{};
        boxes.forEach((box, words) {
          stages.update(
            KnowledgeStage.ofBox(box),
            (count) => count + words,
            ifAbsent: () => words,
          );
        });

        final answersOn = <DateTime, int>{};
        var remembered = 0;
        for (final tally in tallies) {
          answersOn.update(
            _localDate(tally.at),
            (count) => count + tally.answers,
            ifAbsent: () => tally.answers,
          );
          remembered += tally.remembered;
        }

        return WordOverview(
          addedThisWeek: added,
          stages: stages,
          days: List<DayActivity>.generate(WordOverview.windowDays, (i) {
            // By calendar fields: see `PracticeProgress._dayBefore`.
            final date = DateTime(since.year, since.month, since.day + i);
            return DayActivity(date: date, answers: answersOn[date] ?? 0);
          }),
          remembered: remembered,
        );
      },
    ).guarded(onError: (_, _) => _dbFailure('watch overview'));
  }

  /// The date [instant] falls on, on this device, at local midnight.
  static DateTime _localDate(DateTime instant) {
    final local = instant.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  @override
  ResultStream<List<PracticeSession>> watchRecentSessions({int limit = 30}) =>
      _db.practiceDao
          .watchRecentSessions(limit: limit)
          .map((rows) => rows.map((row) => row.toEntity()).toList())
          .guarded(onError: (_, _) => _dbFailure('watch recent sessions'));
}
