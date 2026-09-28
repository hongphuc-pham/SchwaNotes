import 'dart:math';

import 'package:drift/drift.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/db/tables/practice_answers.dart';
import 'package:vocabnote/data/db/tables/practice_sessions.dart';
import 'package:vocabnote/data/db/tables/study_cards.dart';
import 'package:vocabnote/data/db/tables/word_list_items.dart';
import 'package:vocabnote/data/db/tables/words.dart';
import 'package:vocabnote/domain/entities/practice_session.dart';

part 'practice_dao.g.dart';

/// A word paired with its study state, as a practice pool needs it.
class WordWithCard {
  /// Creates a pool entry.
  const new({required this.word, required this.card});

  /// The word being practised.
  final WordRow word;

  /// Its study state. Never null: a card is created with the word (F-001).
  final StudyCardRow card;
}

/// Reads and writes `study_cards`, `practice_sessions` and `practice_answers`
/// (`docs/GAMES.md`).
@DriftAccessor(
  tables: <Type>[
    StudyCards,
    PracticeSessions,
    PracticeAnswers,
    Words,
    WordListItems,
  ],
)
class PracticeDao extends DatabaseAccessor<AppDatabase>
    with _$PracticeDaoMixin {
  /// Creates the DAO.
  new(super.attachedDatabase);

  // --- Study cards ---------------------------------------------------------

  /// Creates the study card that a new word gets: box 0, due now (F-001).
  Future<void> insertCard(StudyCardsCompanion card) =>
      into(studyCards).insert(card, mode: InsertMode.insertOrIgnore);

  /// Reads one card.
  Future<StudyCardRow?> getCard(String wordId) => (select(
    studyCards,
  )..where((c) => c.wordId.equals(wordId))).getSingleOrNull();

  /// Writes a card back after the scheduler has moved it.
  ///
  /// Only ever called when the session's `affects_scheduling` is true - a
  /// quick test records answers and leaves this table alone
  /// (`docs/GAMES.md` section 4).
  Future<int> updateCard(String wordId, StudyCardsCompanion patch) =>
      (update(studyCards)..where((c) => c.wordId.equals(wordId))).write(patch);

  /// How many cards are due now - the "Daily review (N due)" count.
  ///
  /// "Now" is SQLite's own clock, read each time the query re-runs. It used
  /// to be a Dart `DateTime` fixed when the stream started, so a word added
  /// while the hub was open - due at once - was never counted, and the count
  /// said "2 due" over a four-card round (M8, found on the emulator).
  /// Milliseconds, not `strftime('%s')`: a card made in the same second as
  /// the re-run must count. [now] pins the clock for tests.
  Stream<int> watchDueCount({DateTime? now}) {
    final at = now == null
        ? const CustomExpression<int>(
            "CAST((julianday('now') - 2440587.5) * 86400000 AS INTEGER)",
          )
        : Variable<int>(now.toUtc().millisecondsSinceEpoch);
    final count = studyCards.wordId.count();
    final query =
        selectOnly(studyCards).join(<Join<HasResultSet, dynamic>>[
            innerJoin(
              words,
              words.id.equalsExp(studyCards.wordId) &
                  words.deletedAt.isNull() &
                  words.isArchived.equals(false),
            ),
          ])
          ..addColumns(<Expression<Object>>[count])
          ..where(
            studyCards.suspended.equals(false) &
                studyCards.dueAt.isSmallerOrEqual(at),
          );
    return query.map((row) => row.read(count) ?? 0).watchSingle();
  }

  /// The cards due now, soonest first, capped at [limit].
  ///
  /// Suspended cards and deleted or archived words never appear. Cards due at
  /// the same moment come in a random order (F-061), or a batch of words
  /// added together would be practised in the same order every day.
  Future<List<WordWithCard>> dueCards({
    required int limit,
    DateTime? now,
    CardSourceKind source = CardSourceKind.all,
    String? sourceId,
  }) {
    final at = now ?? DateTime.now();
    final query = _poolQuery(source, sourceId)
      ..where(
        studyCards.suspended.equals(false) &
            studyCards.dueAt.isSmallerOrEqualValue(
              at.toUtc().millisecondsSinceEpoch,
            ),
      )
      ..orderBy(<OrderingTerm>[
        OrderingTerm.asc(studyCards.dueAt),
        OrderingTerm.random(),
      ])
      ..limit(limit);
    return _readPool(query);
  }

  /// A random pool of at most [limit], in the order it was drawn - the quick
  /// test.
  ///
  /// Drawn in Dart from ids in a fixed order, not with SQL `RANDOM()`, which
  /// cannot be seeded: the session stores [seed] so it can be replayed, and a
  /// seed that only reordered an unrepeatable sample would replay nothing.
  /// `Random(seed)` is only stable within one SDK release, so the durable
  /// record of what a session asked is still `practice_answers`.
  ///
  /// The 30-card ceiling is enforced by the caller in `GameConfig` **and**
  /// again here by whatever [limit] it passes, so neither layer can be the
  /// only thing standing between a user and a 500-card session.
  Future<List<WordWithCard>> randomCards({
    required int limit,
    CardSourceKind source = CardSourceKind.all,
    String? sourceId,
    int? seed,
  }) async {
    final idQuery = _poolQuery(source, sourceId, idsOnly: true)
      ..orderBy(<OrderingTerm>[OrderingTerm.asc(words.id)]);
    final ids = [for (final row in await idQuery.get()) row.read(words.id)!];
    final drawn = (ids..shuffle(Random(seed))).take(limit).toList();
    if (drawn.isEmpty) return <WordWithCard>[];

    final byId = <String, WordWithCard>{
      for (final entry in await _readPool(
        _poolQuery(CardSourceKind.all, null)..where(words.id.isIn(drawn)),
      ))
        entry.word.id: entry,
    };
    return <WordWithCard>[for (final id in drawn) ?byId[id]];
  }

  /// The weakest cards first: lowest box, then most lapses.
  Future<List<WordWithCard>> weakestCards({
    required int limit,
    CardSourceKind source = CardSourceKind.all,
    String? sourceId,
  }) {
    final query = _poolQuery(source, sourceId)
      ..where(studyCards.suspended.equals(false))
      ..orderBy(<OrderingTerm>[
        OrderingTerm.asc(studyCards.box),
        OrderingTerm.desc(studyCards.lapses),
      ])
      ..limit(limit);
    return _readPool(query);
  }

  /// The most recently added words first.
  Future<List<WordWithCard>> newestCards({
    required int limit,
    CardSourceKind source = CardSourceKind.all,
    String? sourceId,
  }) {
    final query = _poolQuery(source, sourceId)
      ..orderBy(<OrderingTerm>[OrderingTerm.desc(words.createdAt)])
      ..limit(limit);
    return _readPool(query);
  }

  /// Live words with their cards, narrowed to [source].
  ///
  /// [idsOnly] selects just `words.id`, for drawing a sample without reading
  /// every definition in the library.
  JoinedSelectStatement<HasResultSet, dynamic> _poolQuery(
    CardSourceKind source,
    String? sourceId, {
    bool idsOnly = false,
  }) {
    final joins = <Join<HasResultSet, dynamic>>[
      innerJoin(words, words.id.equalsExp(studyCards.wordId)),
    ];
    final query =
        (idsOnly
              ? (selectOnly(studyCards).join(joins)
                  ..addColumns(<Expression<Object>>[words.id]))
              : select(studyCards).join(joins))
          ..where(words.deletedAt.isNull() & words.isArchived.equals(false));

    switch (source) {
      case CardSourceKind.all:
        break;
      case CardSourceKind.favourites:
        query.where(words.isFavourite.equals(true));
      case CardSourceKind.list:
        // A list source with no list is an empty pool. Falling through to
        // every word would quietly start a session over the whole library.
        query.where(
          sourceId == null
              ? const Constant(false)
              : existsQuery(
                  select(wordListItems)
                    ..where((i) => i.wordId.equalsExp(words.id))
                    ..where((i) => i.listId.equals(sourceId)),
                ),
        );
    }
    return query;
  }

  Future<List<WordWithCard>> _readPool(
    JoinedSelectStatement<HasResultSet, dynamic> query,
  ) async {
    final rows = await query.get();
    return rows
        .map(
          (row) => WordWithCard(
            word: row.readTable(words),
            card: row.readTable(studyCards),
          ),
        )
        .toList();
  }

  // --- Sessions and answers ------------------------------------------------

  /// Opens a session row.
  Future<void> insertSession(PracticeSessionsCompanion session) =>
      into(practiceSessions).insert(session);

  /// Closes a session with its totals.
  Future<int> closeSession(String id, PracticeSessionsCompanion patch) =>
      (update(practiceSessions)..where((s) => s.id.equals(id))).write(patch);

  /// Reads one session.
  Future<PracticeSessionRow?> getSession(String id) => (select(
    practiceSessions,
  )..where((s) => s.id.equals(id))).getSingleOrNull();

  /// Records one graded round.
  Future<void> insertAnswer(PracticeAnswersCompanion answer) =>
      into(practiceAnswers).insert(answer);

  /// The answers in a session, in the order they were given.
  Future<List<PracticeAnswerRow>> answersForSession(String sessionId) =>
      (select(practiceAnswers)
            ..where((a) => a.sessionId.equals(sessionId))
            ..orderBy(<OrderClauseGenerator<PracticeAnswers>>[
              (a) => OrderingTerm.asc(a.roundIndex),
            ]))
          .get();

  /// How many different words were answered at or after [since].
  ///
  /// Today's progress towards the daily goal (F-065): a word asked twice today
  /// — a repeat, or two sessions — is one word practised.
  Future<int> countWordsAnsweredSince(DateTime since) {
    final words = practiceAnswers.wordId.count(distinct: true);
    final query = selectOnly(practiceAnswers)
      ..addColumns(<Expression<Object>>[words])
      ..where(
        practiceAnswers.answeredAt.isBiggerOrEqualValue(
          since.toUtc().millisecondsSinceEpoch,
        ),
      );
    return query.map((row) => row.read(words) ?? 0).getSingle();
  }

  /// The quarter-hours since [since] in which anything was answered, as
  /// instants — the raw material of the streak (F-065).
  ///
  /// Quarter-hours rather than days, because which *local* day an answer falls
  /// on depends on the device's offset, which SQLite does not reliably know.
  /// Every offset in use is a multiple of fifteen minutes, so a quarter-hour
  /// never straddles a local midnight and the caller can date each one
  /// exactly. There are at most 96 a day, so the list stays small however many
  /// answers there were.
  Stream<List<DateTime>> watchAnswerQuarterHours(DateTime since) {
    return customSelect(
      'SELECT DISTINCT answered_at / $_quarterHourMs AS quarter '
      'FROM practice_answers WHERE answered_at >= ?',
      variables: <Variable<Object>>[
        Variable.withInt(since.toUtc().millisecondsSinceEpoch),
      ],
      readsFrom: <ResultSetImplementation<dynamic, dynamic>>{practiceAnswers},
    ).watch().map(
      (rows) => <DateTime>[
        for (final row in rows)
          DateTime.fromMillisecondsSinceEpoch(
            row.read<int>('quarter') * _quarterHourMs,
            isUtc: true,
          ),
      ],
    );
  }

  static const int _quarterHourMs = 15 * 60 * 1000;

  /// The most recent finished sessions - the streak and history on the hub.
  Stream<List<PracticeSessionRow>> watchRecentSessions({int limit = 30}) =>
      (select(practiceSessions)
            ..where((s) => s.endedAt.isNotNull())
            ..orderBy(<OrderClauseGenerator<PracticeSessions>>[
              (s) => OrderingTerm.desc(s.startedAt),
            ])
            ..limit(limit))
          .watch();
}
