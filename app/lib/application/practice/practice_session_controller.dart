/// The session runner (`docs/GAMES.md` §3).
///
/// Written once and shared by every game. It owns the three things a game must
/// never touch: **persistence, scheduling and navigation**. A game is two pure
/// functions and a widget; everything consequential happens here.
library;

import 'dart:convert';
import 'dart:math';

// Riverpod 3 ships its own AsyncResult; ours is the Result-based one.
import 'package:riverpod_annotation/riverpod_annotation.dart' hide AsyncResult;
import 'package:uuid/uuid.dart';
import 'package:vocabnote/application/practice/game_contracts.dart';
import 'package:vocabnote/application/practice/scheduler/leitner_scheduler.dart';
import 'package:vocabnote/application/practice/scheduler/review_schedule.dart';
import 'package:vocabnote/application/repositories.dart';
import 'package:vocabnote/domain/entities/practice_session.dart';
import 'package:vocabnote/domain/entities/study_card.dart';
import 'package:vocabnote/domain/repositories/practice_repository.dart';

part 'practice_session_controller.g.dart';

/// What a finished session is worth telling the user (`UI-UX.md` §4.8).
class SessionSummary {
  /// Creates a summary.
  const new({
    required this.sessionId,
    required this.totalRounds,
    required this.correctRounds,
    required this.duration,
    required this.missed,
    this.skippedRounds = 0,
  });

  /// The session this summarises.
  final String sessionId;

  /// How many rounds were answered, skipped ones not counting.
  final int totalRounds;

  /// How many rounds the user moved past without grading.
  final int skippedRounds;

  /// How many were `good` or `easy`.
  final int correctRounds;

  /// How long it took.
  final Duration duration;

  /// The cards graded `again` — "worth another look", never "wrong".
  final List<PracticeCardData> missed;
}

/// A session in progress.
class PracticeSessionState {
  /// Creates a state.
  const new({
    required this.config,
    required this.rounds,
    required this.index,
    this.sessionId,
    this.summary,
  });

  /// What the user chose.
  final GameConfig config;

  /// Every round, including any repeats appended during the session.
  final List<GameRound> rounds;

  /// Which round is showing.
  final int index;

  /// The open session row, once it exists.
  final String? sessionId;

  /// Set once the session has ended.
  final SessionSummary? summary;

  /// The round the user is looking at, or null when the session is over.
  GameRound? get current => index < rounds.length ? rounds[index] : null;

  /// Whether every round has been answered.
  bool get isFinished => summary != null;

  /// How far through, for the progress bar.
  double get progress => rounds.isEmpty ? 0 : index / rounds.length;

  /// Copies with the given changes.
  PracticeSessionState copyWith({
    List<GameRound>? rounds,
    int? index,
    String? sessionId,
    SessionSummary? summary,
  }) => PracticeSessionState(
    config: config,
    rounds: rounds ?? this.rounds,
    index: index ?? this.index,
    sessionId: sessionId ?? this.sessionId,
    summary: summary ?? this.summary,
  );
}

/// How many extra times an `again` card may reappear in the same session.
///
/// Session-local, and deliberately so: it changes what *this* sitting feels
/// like without touching a single scheduling column. Zero disables it.
/// Not persisted yet — see the schema question in the M5 task docs.
const int kDefaultAgainRepeats = 1;

/// Runs one practice session.
@riverpod
class PracticeSessionRunner extends _$PracticeSessionRunner {
  @override
  PracticeSessionState? build() => null;

  /// Starts a session for [config] with [game].
  ///
  /// Returns false when there is nothing to practise — the hub decides what to
  /// say about that, because "no cards due" and "no words at all" need
  /// different answers.
  Future<bool> start({
    required GameConfig config,
    required PracticeGame<GameRound> game,
    ReviewSchedule schedule = ReviewSchedule.standard,
    int againRepeats = kDefaultAgainRepeats,
  }) async {
    _schedule = schedule;
    _againRepeats = againRepeats;
    // The runner can outlive a session - "Practise again" starts the next one
    // on it - so nothing from the last one may carry over. A stale miss would
    // appear in the new summary and lower its score.
    _repeatsUsed.clear();
    _missed.clear();
    _skipped = 0;

    final repository = ref.read(practiceRepositoryProvider);
    final pool = await repository.loadPool(
      selection: config.selection,
      mode: config.mode,
      limit: config.limit,
      source: config.source,
      sourceId: config.sourceId,
      seed: config.seed,
    );

    final cards = pool.valueOrNull ?? const <PracticeCardData>[];
    if (cards.isEmpty) return false;

    final rounds = game.buildRounds(config, cards);
    if (rounds.isEmpty) return false;

    final started = await repository.startSession(
      PracticeSession(
        id: const Uuid().v4(),
        gameId: config.gameId,
        mode: config.mode,
        sourceKind: config.source,
        sourceId: config.sourceId,
        configJson: jsonEncode(config.toJson()),
        startedAt: DateTime.now(),
        // The single most consequential value in the milestone. A quick test
        // must never damage a schedule built over weeks (F-062).
        affectsScheduling: config.affectsScheduling,
      ),
    );

    state = PracticeSessionState(
      config: config,
      rounds: rounds,
      index: 0,
      sessionId: started.valueOrNull?.id,
    );
    return true;
  }

  ReviewSchedule _schedule = ReviewSchedule.standard;
  int _againRepeats = kDefaultAgainRepeats;
  final Map<String, int> _repeatsUsed = <String, int>{};
  final List<PracticeCardData> _missed = <PracticeCardData>[];
  int _skipped = 0;
  bool _answering = false;

  /// Records [answer] for the current round and moves on.
  ///
  /// One answer per round. The round only moves on once the answer is saved,
  /// so a double tap - or a swipe and a tap - would otherwise grade the same
  /// round twice: two answer rows, the card counted as missed twice, and the
  /// repeat budget spent twice. Guarded here so that every game gets this, not
  /// only the ones that remember to guard their own buttons (F-067).
  Future<void> answer(PracticeGame<GameRound> game, GameAnswer answer) async {
    if (_answering) return;
    _answering = true;
    try {
      await _record(game, answer);
    } finally {
      _answering = false;
    }
  }

  Future<void> _record(PracticeGame<GameRound> game, GameAnswer answer) async {
    final current = state;
    if (current == null) return;
    final round = current.current;
    if (round == null) return;

    final result = game.grade(round, answer);
    final repository = ref.read(practiceRepositoryProvider);

    // Scheduling is applied here or nowhere. A game cannot reach it, and a
    // quick test never gets a card to apply it to.
    final updatedCard = current.config.affectsScheduling
        ? LeitnerScheduler(schedule: _schedule)
              .apply(round.card.card, result, DateTime.now())
        : null;

    await repository.recordAnswer(
      answer: PracticeAnswer(
        id: const Uuid().v4(),
        sessionId: current.sessionId ?? '',
        wordId: round.card.word.id,
        // The position in *this* session, not the round's own index: a repeat
        // is built as a one-card session, so its index is always 0.
        roundIndex: current.index,
        result: result,
        answeredAt: DateTime.now(),
        responseMs: answer.elapsed.inMilliseconds,
      ),
      affectsScheduling: current.config.affectsScheduling,
      updatedCard: updatedCard,
    );

    if (result == ReviewOutcome.again) _missed.add(round.card);
    if (result == ReviewOutcome.skipped) _skipped++;

    final rounds = _withRepeatFor(game, current, round, result);
    final next = current.index + 1;

    if (next >= rounds.length) {
      await _finish(current.copyWith(rounds: rounds, index: next));
      return;
    }
    state = current.copyWith(rounds: rounds, index: next);
  }

  /// Appends another attempt at [round] when the user got it wrong.
  ///
  /// The card is asked again *later in this sitting*, which is what people
  /// mean by "let me try that again" — and it writes nothing, so a schedule is
  /// untouched however many times a card reappears.
  List<GameRound> _withRepeatFor(
    PracticeGame<GameRound> game,
    PracticeSessionState current,
    GameRound round,
    ReviewOutcome result,
  ) {
    if (result != ReviewOutcome.again || _againRepeats <= 0) {
      return current.rounds;
    }
    final wordId = round.card.word.id;
    final used = _repeatsUsed[wordId] ?? 0;
    // Capped, or a card the user keeps failing would make the session endless.
    if (used >= _againRepeats) return current.rounds;
    _repeatsUsed[wordId] = used + 1;

    final repeat = game.buildRounds(current.config, <PracticeCardData>[
      round.card,
    ]);
    if (repeat.isEmpty) return current.rounds;

    return <GameRound>[...current.rounds, repeat.single];
  }

  Future<void> _finish(PracticeSessionState current) async {
    final repository = ref.read(practiceRepositoryProvider);
    // A skip is "not now", not a right answer: left in, it scored as correct.
    final answered = current.rounds.length - _skipped;
    final correct = answered - _missed.length;

    final ended = await repository.endSession(
      sessionId: current.sessionId ?? '',
      endedAt: DateTime.now(),
      totalRounds: answered,
      correctRounds: max(correct, 0),
    );

    state = current.copyWith(
      summary: SessionSummary(
        sessionId: current.sessionId ?? '',
        totalRounds: answered,
        correctRounds: max(correct, 0),
        skippedRounds: _skipped,
        duration: ended.valueOrNull?.duration ?? Duration.zero,
        // Deduplicated: a card failed twice is one word worth another look,
        // not two.
        missed: <PracticeCardData>{..._missed}.toList(),
      ),
    );
  }

  /// How long until the current card returns if graded [outcome].
  ///
  /// Null in a quick test, because the schedule does not move and any interval
  /// shown would be a lie (`UI-UX.md` §4.7).
  ///
  /// The **nominal** interval, not the jittered one. Reading it off
  /// `apply().dueAt` was wrong twice over: the ±10% jitter made the label
  /// change on every rebuild, and truncating the result meant "2 days minus
  /// 10%" displayed as `1d` — so *Good* and *Easy* both read `1d`, and a lapse
  /// read `9m` instead of `10m`. A button that promises two days and delivers
  /// 1.8 is fine; one that *says* one day when it means two is not.
  String? intervalLabelFor(ReviewOutcome outcome) {
    final current = state;
    final round = current?.current;
    if (current == null || round == null) return null;
    if (!current.config.affectsScheduling) return null;

    if (outcome == ReviewOutcome.skipped) return null;

    final box = LeitnerScheduler(schedule: _schedule)
        .boxAfter(round.card.card.box, outcome);
    final days = _schedule.daysForBox(box);

    // Box 0 is same-day: the relearn interval, not a number of days.
    if (days == 0) return '${LeitnerScheduler.relearnInterval.inMinutes}m';
    return '${days}d';
  }
}
