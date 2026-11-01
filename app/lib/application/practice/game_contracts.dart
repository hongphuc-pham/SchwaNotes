/// The contracts every practice game implements (`docs/GAMES.md` §2).
///
/// Three names §2 sketches as new are **not** redefined here, because
/// `domain/` already has them and they are already persisted: `RoundResult` is
/// [ReviewOutcome] (`study_cards.last_result`), `PromptSide` is the domain's
/// (`practice_sessions.prompt_side`), and `PracticeCard` is [PracticeCardData].
/// A second copy either side of a layer boundary means converting at every call
/// until one of them drifts.
///
/// The split this file exists to enforce: **the runner owns persistence,
/// scheduling and navigation; a game is two pure functions and one widget.**
/// `buildRounds` and `grade` take no I/O and no clock. If a game ever needs the
/// database, the contract has been broken and F-067 is already false.
library;

import 'package:flutter/widgets.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/domain/entities/practice_session.dart';
import 'package:vocabnote/domain/entities/study_card.dart';
import 'package:vocabnote/domain/repositories/practice_repository.dart';

/// What the hub needs to draw a game's card, without instantiating the game.
@immutable
class GameDescriptor {
  /// Creates a descriptor.
  const new({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.supportedModes,
    this.minCards = 4,
    this.requiresIpa = false,
    this.requiresAudio = false,
  });

  /// Stable, and stored in `practice_sessions.game_id`. Never localise this.
  final String id;

  /// The game's name.
  ///
  /// A function of [AppL10n] rather than the `titleKey` string `GAMES.md` §2
  /// sketches: Flutter's generated localisations have no runtime key lookup, so
  /// a key would have to be resolved through a hand-kept map that the compiler
  /// could not check. This way a missing string is a build error.
  final String Function(AppL10n l10n) title;

  /// One line describing the game, for the hub card.
  final String Function(AppL10n l10n) description;

  /// The hub card's icon.
  final IconData icon;

  /// Which modes this game can run in.
  final Set<PracticeMode> supportedModes;

  /// Below this many cards the hub greys the game out and says why.
  final int minCards;

  /// When true the hub filters the pool to words that have a transcription.
  final bool requiresIpa;

  /// When true the game needs the speech engine.
  final bool requiresAudio;
}

/// Everything the user chose in the config sheet.
///
/// Serialised into `practice_sessions.config_json`. Readers **must tolerate
/// unknown keys** (`GAMES.md` §2), so `fromJson` ignores what it does not
/// recognise rather than throwing — a session written by a later version must
/// still open in this one.
///
/// Deliberately not freezed. `GAMES.md` §4 requires the 30-card cap to be
/// "enforced in `GameConfig` construction"; a generated constructor cannot
/// clamp, so this one does it in the initialiser list and there is no way to
/// hold an over-limit config at all.
@immutable
class GameConfig {
  /// Creates a config.
  new({
    required this.gameId,
    required this.mode,
    required this.selection,
    required this.limit,
    this.source = CardSourceKind.all,
    this.sourceId,
    this.promptSide = PromptSide.wordFirst,
    Set<PromptSide> mixSides = PromptSide.defaultMixSides,
    this.mixOrder = MixOrder.random,
    this.ttsAutoPlay = true,
    this.seed,
  }) : mixSides = PromptSide.validMix(mixSides),
       assert(limit > 0, 'a session of no cards is not a session');

  /// Rebuilds a config from `config_json`.
  ///
  /// Every field falls back rather than throwing: a stored session is history,
  /// and history that cannot be opened is worse than history with a default in
  /// it.
  factory fromJson(Map<String, dynamic> json) {
    T? enumOf<T extends Enum>(List<T> values, Object? name) {
      for (final value in values) {
        if (value.name == name) return value;
      }
      return null;
    }

    return GameConfig(
      gameId: json['gameId'] as String? ?? '',
      mode: enumOf(PracticeMode.values, json['mode']) ?? PracticeMode.quickTest,
      selection:
          enumOf(CardSelection.values, json['selection']) ??
          CardSelection.random,
      limit: (json['limit'] as num?)?.toInt() ?? 10,
      source:
          enumOf(CardSourceKind.values, json['source']) ?? CardSourceKind.all,
      sourceId: json['sourceId'] as String?,
      promptSide:
          enumOf(PromptSide.values, json['promptSide']) ?? PromptSide.wordFirst,
      mixSides: <PromptSide>{
        if (json['mixSides'] case final List<Object?> names)
          for (final name in names)
            if (enumOf(PromptSide.values, name) case final PromptSide side)
              side,
      },
      mixOrder: enumOf(MixOrder.values, json['mixOrder']) ?? MixOrder.random,
      ttsAutoPlay: json['ttsAutoPlay'] as bool? ?? true,
      seed: (json['seed'] as num?)?.toInt(),
    );
  }

  /// Which game this session runs.
  final String gameId;

  /// Daily review or quick test. Decides whether the schedule moves at all.
  final PracticeMode mode;

  /// Where the pool comes from.
  final CardSourceKind source;

  /// The list id, when [source] is [CardSourceKind.list].
  final String? sourceId;

  /// How the pool is ordered and picked.
  final CardSelection selection;

  /// How many cards. Already clamped for a quick test — see the constructor.
  final int limit;

  /// Which face the card opens on.
  final PromptSide promptSide;

  /// The faces a [PromptSide.mix] session draws from. Always a valid mix —
  /// the constructor falls back to [PromptSide.defaultMixSides].
  final Set<PromptSide> mixSides;

  /// How a [PromptSide.mix] session picks among [mixSides].
  final MixOrder mixOrder;

  /// Whether the word is spoken on reveal.
  final bool ttsAutoPlay;

  /// The shuffle seed, stored so a session can be replayed or debugged.
  final int? seed;

  /// Whether answering in this session moves the Leitner schedule.
  ///
  /// The single most consequential line in the milestone: a quick test must
  /// never damage a schedule the user has spent weeks building (F-062).
  bool get affectsScheduling => mode == PracticeMode.daily;

  /// The same choices with a different [seed].
  ///
  /// For *Practise again* on the summary, which draws a fresh sample rather
  /// than replaying the words just seen.
  GameConfig withSeed(int? seed) => GameConfig(
    gameId: gameId,
    mode: mode,
    selection: selection,
    limit: limit,
    source: source,
    sourceId: sourceId,
    promptSide: promptSide,
    mixSides: mixSides,
    mixOrder: mixOrder,
    ttsAutoPlay: ttsAutoPlay,
    seed: seed,
  );

  /// The config as it is stored in `practice_sessions.config_json`.
  Map<String, dynamic> toJson() => <String, dynamic>{
    'gameId': gameId,
    'mode': mode.name,
    'source': source.name,
    if (sourceId != null) 'sourceId': sourceId,
    'selection': selection.name,
    'limit': limit,
    'promptSide': promptSide.name,
    'mixSides': <String>[for (final side in mixSides) side.name],
    'mixOrder': mixOrder.name,
    'ttsAutoPlay': ttsAutoPlay,
    if (seed != null) 'seed': seed,
  };
}

/// One question. Games subclass this with whatever else they need.
@immutable
abstract class GameRound {
  /// Creates a round.
  const new({required this.index, required this.card});

  /// Position in the session, from zero.
  final int index;

  /// The card being asked about.
  final PracticeCardData card;
}

/// What the user did with a round.
@immutable
class GameAnswer {
  /// Creates an answer.
  const new({required this.result, required this.elapsed, this.payload});

  /// The outcome the user chose, or the game computed.
  final ReviewOutcome result;

  /// How long the round took.
  final Duration elapsed;

  /// Anything the game wants to record — the option tapped, say.
  final Object? payload;
}

/// What a round view may ask the runner to do.
///
/// Deliberately narrow. A game that could navigate, or write, or end the
/// session, would make F-067 impossible to keep.
@immutable
class GameRoundCallbacks {
  /// Creates the callbacks.
  const new({
    required this.onAnswer,
    this.onSpeak,
    this.intervalLabel,
    this.position = 0,
  });

  /// Called **exactly once** per round, with the user's answer.
  final void Function(GameAnswer answer) onAnswer;

  /// Speaks the current card, when the game offers playback.
  final VoidCallback? onSpeak;

  /// How long until the card returns if graded a given outcome - "2d", "10m".
  ///
  /// `UI-UX.md` §4.7 wants each grading button to show its next interval, "so
  /// the schedule is never mysterious". The runner supplies it because the
  /// runner owns scheduling; a game that computed this would need the
  /// scheduler, and F-067 would be false.
  ///
  /// **Null in a quick test**, and that is the point: a quick test does not
  /// move the schedule, so any interval shown on its buttons would be a lie.
  final String? Function(ReviewOutcome outcome)? intervalLabel;

  /// Where this round falls in the session, from zero.
  ///
  /// Not the same as `round.index`: a repeat is built as a one-card session,
  /// so its own index is always 0. A view that cares where it is in the
  /// session - the flashcard's round-1-only hint - reads this.
  final int position;
}

/// A practice game (`docs/GAMES.md` §2).
abstract interface class PracticeGame<R extends GameRound> {
  /// How the hub describes this game.
  GameDescriptor get descriptor;

  /// Turns a pool into an ordered list of rounds. **Pure; no I/O.**
  List<R> buildRounds(GameConfig config, List<PracticeCardData> pool);

  /// Decides the outcome. **Pure; no I/O.** Self-graded games echo the tap.
  ReviewOutcome grade(R round, GameAnswer answer);

  /// The round UI. Calls [GameRoundCallbacks.onAnswer] exactly once.
  Widget buildRoundView(
    BuildContext context,
    R round,
    GameRoundCallbacks callbacks,
  );
}

/// The set of games the app knows about.
///
/// Registering is the *only* shared-file edit adding a game is allowed to
/// need (F-067). `DummyGame` in the tests proves it.
class GameRegistry {
  final Map<String, PracticeGame<GameRound>> _games =
      <String, PracticeGame<GameRound>>{};

  /// Every registered game, in registration order.
  Iterable<PracticeGame<GameRound>> get games => _games.values;

  /// Adds [game]. Registering the same id twice replaces the first.
  void register(PracticeGame<GameRound> game) {
    _games[game.descriptor.id] = game;
  }

  /// The descriptors the hub should draw, given how many words exist.
  ///
  /// Returns every game rather than filtering: a game the user cannot start
  /// yet still needs a card saying *why*, which is what F-060's "Add 4 words to
  /// unlock" is. Availability is [GameDescriptor.minCards] against [wordCount].
  List<GameDescriptor> available(int wordCount) =>
      _games.values.map((game) => game.descriptor).toList();

  /// Whether [descriptor] can be started with [wordCount] words.
  bool isUnlocked(GameDescriptor descriptor, int wordCount) =>
      wordCount >= descriptor.minCards;

  /// The game with [id].
  ///
  /// Throws when it is missing: an unknown id means a stored session names a
  /// game this build does not have, and guessing a substitute would grade the
  /// user against rules they never played by.
  PracticeGame<GameRound> byId(String id) {
    final game = _games[id];
    if (game == null) {
      throw StateError('No practice game registered with id "$id"');
    }
    return game;
  }
}
