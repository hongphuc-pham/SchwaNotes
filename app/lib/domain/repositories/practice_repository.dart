import 'package:vocabnote/core/result.dart';
import 'package:vocabnote/domain/entities/ipa_highlight.dart';
import 'package:vocabnote/domain/entities/practice_progress.dart';
import 'package:vocabnote/domain/entities/practice_session.dart';
import 'package:vocabnote/domain/entities/study_card.dart';
import 'package:vocabnote/domain/entities/word.dart';
import 'package:vocabnote/domain/entities/word_overview.dart';

/// A word, its study state and its highlights - one practice card.
///
/// Denormalised for the session so a running game never queries: everything a
/// round needs is loaded up front (`docs/GAMES.md` section 2).
class PracticeCardData {
  /// Creates a card.
  const new({
    required this.word,
    required this.card,
    this.highlights = const <IpaHighlight>[],
    this.firstNote,
  });

  /// The word being practised.
  final Word word;

  /// Its scheduling state.
  final StudyCard card;

  /// Its highlights, for the reverse of the flashcard.
  final List<IpaHighlight> highlights;

  /// The oldest note on the word, shown on the back of a card
  /// (`docs/UI-UX.md` §4.7). Denormalised here for the same reason as
  /// [highlights]: a running game must never query.
  final String? firstNote;
}

/// How a pool is chosen (`docs/GAMES.md` section 2, `CardSelection`).
enum CardSelection {
  /// Cards due now, soonest first.
  due,

  /// A random sample.
  random,

  /// Lowest box first, then most lapses.
  weakest,

  /// Most recently added first.
  newest,
}

/// Persistence for practice (`docs/GAMES.md` section 3).
///
/// The session runner owns all of this; games never touch the database.
abstract interface class PracticeRepository {
  /// A limit that asks for every card: a quick test of the full list.
  static const int everyCard = 0x7FFFFFFF;

  /// Loads a pool of up to [limit] cards.
  AsyncResult<List<PracticeCardData>> loadPool({
    required CardSelection selection,
    required PracticeMode mode,
    required int limit,
    CardSourceKind source = CardSourceKind.all,
    String? sourceId,
    int? seed,
  });

  /// Watches how many cards are due - the "Daily review (N due)" count.
  ResultStream<int> watchDueCount();

  /// Creates the study card that belongs to a new word.
  AsyncResult<void> createCardForWord(String wordId);

  /// Opens a session row and returns it.
  AsyncResult<PracticeSession> startSession(PracticeSession session);

  /// Records one graded round.
  ///
  /// Writing the answer and moving the schedule are one call so they cannot
  /// diverge - and the schedule is only touched when the session's
  /// `affectsScheduling` is true.
  AsyncResult<void> recordAnswer({
    required PracticeAnswer answer,
    required bool affectsScheduling,
    StudyCard? updatedCard,
  });

  /// Closes a session with its totals.
  AsyncResult<PracticeSession> endSession({
    required String sessionId,
    required DateTime endedAt,
    required int totalRounds,
    required int correctRounds,
  });

  /// Reads a finished session, for the summary screen.
  AsyncResult<PracticeSession?> getSession(String id);

  /// The answers in a session, in order.
  AsyncResult<List<PracticeAnswer>> answersForSession(String sessionId);

  /// Recent finished sessions, for the streak and the goal ring.
  ResultStream<List<PracticeSession>> watchRecentSessions({int limit});

  /// Watches today's words and the days practised — the goal ring and the
  /// streak (F-065). Every mode counts: a quick test is practice too.
  ///
  /// Not built on [watchRecentSessions]: that stops at a number of sessions,
  /// and a busy day can use them all.
  ResultStream<PracticeProgress> watchProgress();

  /// Watches the numbers behind the home screen's overview.
  ResultStream<WordOverview> watchOverview();
}
