import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vocabnote/domain/entities/study_card.dart';
import 'package:vocabnote/domain/value_objects/storage_enum.dart';

part 'practice_session.freezed.dart';

/// How a practice session treats the review schedule
/// (`practice_sessions.mode`).
///
/// `docs/GAMES.md` §2 lists this among the contracts in
/// `application/practice/game_contracts.dart`. It is defined **here** because
/// it is persisted data, and `domain/` may not import `application/`
/// (`docs/RULES.md` §20). M5's `game_contracts.dart` re-exports it, so the
/// contract still reads exactly as documented.
enum PracticeMode implements StorageEnum {
  /// Leitner-scheduled cards that are due. Grading moves the schedule.
  daily('daily'),

  /// A casual set the user sized themselves. Records answers, never
  /// schedules - a quick test must not damage a carefully built schedule.
  quickTest('quick_test');

  new(this.storageValue);

  /// The exact string written to `practice_sessions.mode`.
  ///
  /// Note `quick_test`, not `quickTest`: the storage value is pinned to the
  /// documented schema, not to the Dart identifier.
  @override
  final String storageValue;

  /// Parses a stored value, or null if unrecognised.
  static PracticeMode? tryFromStorage(String value) {
    for (final mode in PracticeMode.values) {
      if (mode.storageValue == value) return mode;
    }
    return null;
  }

  /// Whether sessions in this mode apply the [StudyCard] schedule.
  ///
  /// Mirrored into `practice_sessions.affects_scheduling` so the stored row
  /// records what actually happened, not what this build believes today.
  bool get affectsScheduling => this == PracticeMode.daily;
}

/// Where a session drew its cards from (`practice_sessions.source_kind`).
enum CardSourceKind implements StorageEnum {
  /// Every word.
  all('all'),

  /// One list; the id is in `practice_sessions.source_id`.
  list('list'),

  /// Starred words only.
  favourites('favourites');

  new(this.storageValue);

  /// The exact string written to the database.
  @override
  final String storageValue;

  /// Parses a stored value, falling back to [CardSourceKind.all].
  static CardSourceKind fromStorage(String value) {
    for (final kind in CardSourceKind.values) {
      if (kind.storageValue == value) return kind;
    }
    return CardSourceKind.all;
  }
}

/// Which face of a card the user is shown first (`settings.prompt_side`).
///
/// Defined here for the same reason as [PracticeMode]: it is persisted.
enum PromptSide implements StorageEnum {
  /// Show the word, recall the meaning.
  wordFirst('word_first'),

  /// Show the transcription, recall the word.
  ipaFirst('ipa_first'),

  /// Show the meaning, recall the word.
  meaningFirst('meaning_first'),

  /// Each card opens on one of the faces the user ticked ([mixableSides]),
  /// picked by [MixOrder].
  ///
  /// Never the side of a built round: the game resolves it to a real face
  /// when it builds the rounds, so a replayed session shows the same faces.
  mix('mix');

  new(this.storageValue);

  /// The exact string written to the database.
  @override
  final String storageValue;

  /// The faces a mix can be made of, in take-turns order.
  static const Set<PromptSide> mixableSides = <PromptSide>{
    PromptSide.wordFirst,
    PromptSide.ipaFirst,
    PromptSide.meaningFirst,
  };

  /// What a mix uses until the user ticks otherwise: word and meaning, the
  /// two directions every card has once it has a definition.
  static const Set<PromptSide> defaultMixSides = <PromptSide>{
    PromptSide.wordFirst,
    PromptSide.meaningFirst,
  };

  /// The fewest faces a mix may have. One face is not a mix.
  static const int minMixSides = 2;

  /// Parses a stored value, falling back to [PromptSide.wordFirst].
  static PromptSide fromStorage(String value) {
    for (final side in PromptSide.values) {
      if (side.storageValue == value) return side;
    }
    return PromptSide.wordFirst;
  }

  /// [sides] if they make a valid mix, otherwise [defaultMixSides].
  ///
  /// Valid means: only [mixableSides], and at least [minMixSides] of them.
  /// Returned in take-turns order whatever order they arrived in.
  static Set<PromptSide> validMix(Iterable<PromptSide> sides) {
    final picked = <PromptSide>{
      for (final side in mixableSides)
        if (sides.contains(side)) side,
    };
    return picked.length >= minMixSides ? picked : defaultMixSides;
  }

  /// `settings.mix_sides`: storage values joined by commas.
  static String encodeMix(Set<PromptSide> sides) =>
      validMix(sides).map((side) => side.storageValue).join(',');

  /// Reads `settings.mix_sides`, falling back to [defaultMixSides].
  static Set<PromptSide> decodeMix(String stored) => validMix(<PromptSide>[
    for (final part in stored.split(','))
      for (final side in mixableSides)
        if (side.storageValue == part.trim()) side,
  ]);
}

/// How a [PromptSide.mix] session picks each card's face.
enum MixOrder implements StorageEnum {
  /// A seeded random pick per card.
  random('random'),

  /// Word, sounds, meaning, word… through the ticked faces.
  rotate('rotate');

  new(this.storageValue);

  /// The exact string written to `settings.mix_order`.
  @override
  final String storageValue;

  /// Parses a stored value, falling back to [MixOrder.random].
  static MixOrder fromStorage(String value) {
    for (final order in MixOrder.values) {
      if (order.storageValue == value) return order;
    }
    return MixOrder.random;
  }
}

/// One run of one game.
///
/// Opened when the session starts and closed when it ends, so an abandoned
/// session is simply one with a null [endedAt] - visible in stats rather than
/// lost.
@freezed
abstract class PracticeSession with _$PracticeSession {
  /// Creates a session.
  const factory({
    /// UUID v4.
    required String id,

    /// Which game ran, e.g. `flashcard`. Stable across releases.
    required String gameId,

    /// Daily review or quick test.
    required PracticeMode mode,

    /// Where the cards came from.
    required CardSourceKind sourceKind,

    /// The full `GameConfig` as JSON. Readers must tolerate unknown keys, so a
    /// session recorded by a newer build stays readable.
    required String configJson,

    /// When the session started.
    required DateTime startedAt,

    /// Whether this session applied the review schedule.
    ///
    /// Stored rather than recomputed from [mode]: if the rule ever changes,
    /// history must still say what actually happened.
    required bool affectsScheduling,

    /// The list id, when [sourceKind] is [CardSourceKind.list].
    String? sourceId,

    /// When the session finished. Null while it is still running, or if the
    /// user abandoned it.
    DateTime? endedAt,

    /// How many rounds were played.
    @Default(0) int totalRounds,

    /// How many were answered `good` or `easy`.
    @Default(0) int correctRounds,
  }) = _PracticeSession;

  const new _();

  /// Whether the session is still in progress.
  bool get isOpen => endedAt == null;

  /// How long the session took, or null while it is still open.
  Duration? get duration => endedAt?.difference(startedAt);

  /// Score as a fraction, or null when no rounds were played.
  ///
  /// Null rather than zero: "0 of 0" is not a score, and the summary screen
  /// should not tell someone they got nothing right when they answered nothing.
  double? get accuracy => totalRounds == 0 ? null : correctRounds / totalRounds;
}

/// One graded round within a session.
@freezed
abstract class PracticeAnswer with _$PracticeAnswer {
  /// Creates an answer.
  const factory({
    /// UUID v4.
    required String id,

    /// The session this answer belongs to. Cascades on delete.
    required String sessionId,

    /// The word that was asked. Cascades on delete.
    required String wordId,

    /// Zero-based position within the session.
    required int roundIndex,

    /// How the user graded it.
    required ReviewOutcome result,

    /// When it was answered.
    required DateTime answeredAt,

    /// How long the user took, in milliseconds.
    int? responseMs,
  }) = _PracticeAnswer;

  const new _();

  /// Whether this counts towards the session score.
  bool get isCorrect =>
      result == ReviewOutcome.good || result == ReviewOutcome.easy;
}
