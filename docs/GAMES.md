# Practice game framework

Requirement: flashcards ship in v1, but more games follow. **Adding a game must not require
touching the practice hub, the config sheet, session persistence, stats or the database.**
So practice is a registry of small plugins behind one set of contracts.

## 1. Responsibilities, split three ways

| Concern | Owner | Why separate |
|---|---|---|
| *Which cards do I practise?* | `PracticeRepository.loadPool` | Every game wants "due today" or "30 random from a list" — write it once. |
| *What does a round look like and what counts as correct?* | `PracticeGame` | The only thing a new game must implement. |
| *When does this card come back?* | `ReviewScheduler` | Leitner now, SM-2 later, without rewriting any game. |

## 2. Contracts (`application/practice/game_contracts.dart`)

```dart
enum PracticeMode  { daily, quickTest }                  // domain, persisted
enum PromptSide    { wordFirst, ipaFirst, meaningFirst, mix } // domain, persisted
enum MixOrder      { random, rotate }                    // domain, settings.mix_order
enum ReviewOutcome { again, good, easy, skipped }        // domain, study_cards.last_result

/// Static description used by the hub to render a game card.
class GameDescriptor {
  final String id;                              // stable, stored in practice_sessions.game_id
  final String Function(AppL10n) title;
  final String Function(AppL10n) description;
  final IconData icon;
  final Set<PracticeMode> supportedModes;
  final int minCards;                           // hub greys the game out below this
  final bool requiresIpa;                       // hub filters the pool accordingly
  final bool requiresAudio;
  int get maxQuickTestCards;                    // 30, from PracticeRepository
}

/// Everything the user chose in the config sheet. Serialised into
/// practice_sessions.config_json — readers must tolerate unknown keys.
/// Hand-written, not freezed, so the constructor can clamp a quick test to 30.
class GameConfig {
  GameConfig({
    required String gameId,
    required PracticeMode mode,
    required CardSelection selection,           // due | random | weakest | newest
    required int limit,                         // clamped to 30 in quickTest
    CardSourceKind source = CardSourceKind.all, // all | list | favourites
    String? sourceId,                           // the list, for CardSourceKind.list
    PromptSide promptSide = PromptSide.wordFirst,
    bool ttsAutoPlay = true,
    int? seed,                                  // stored so a test can be repeated
  });
  GameConfig withSeed(int? seed);               // Practise again: same choices, new draw
}

/// A word plus its study state, denormalised for the session.
class PracticeCardData {                        // domain/repositories/practice_repository.dart
  final Word word;
  final StudyCard card;
  final List<IpaHighlight> highlights;
  final String? firstNote;                      // for the back of a flashcard
}

// The pool: PracticeRepository.loadPool(selection, mode, limit, source, sourceId, seed)
//   → List<PracticeCardData>, everything a round can need, loaded before it starts.

/// One question. Games subclass this with whatever they need.
abstract class GameRound {
  final int index;
  final PracticeCardData card;
}

class GameAnswer {
  final ReviewOutcome result;
  final Duration elapsed;
  final Object? payload;                        // e.g. the option a user tapped
}

/// The only things a round view may ask the runner for.
class GameRoundCallbacks {
  final void Function(GameAnswer) onAnswer;             // exactly once per round
  final VoidCallback? onSpeak;                           // say the current word
  final String? Function(ReviewOutcome)? intervalLabel; // "2d"; null in a quick test
  final int position;                                    // place in the session
}

abstract interface class PracticeGame<R extends GameRound> {
  GameDescriptor get descriptor;

  /// Turn a pool into an ordered list of rounds. Pure; no I/O.
  List<R> buildRounds(GameConfig config, List<PracticeCardData> pool);

  /// Decide the outcome. Pure; no I/O. Self-graded games just echo the tap.
  ReviewOutcome grade(R round, GameAnswer answer);

  /// The round UI. Calls onAnswer(GameAnswer) exactly once.
  Widget buildRoundView(BuildContext context, R round, GameRoundCallbacks cb);
}

abstract interface class ReviewScheduler {
  StudyCard apply(StudyCard current, ReviewOutcome result, DateTime now);
}

class GameRegistry {
  void register(PracticeGame game);
  List<GameDescriptor> available(int wordCount); // every game; the hub greys locked ones
  bool isUnlocked(GameDescriptor descriptor, int wordCount);
  PracticeGame byId(String id);
}
```

*Corrected at M5, where the build and this sketch parted:*

- *`RoundResult` is `ReviewOutcome`, `PracticeCard` is `PracticeCardData`, and `PromptSide` is
  the domain's. All three already existed in `domain/`, persisted and with storage mappings; a
  second copy either side of a layer boundary means converting at every call until one drifts.*
- *`titleKey` / `descriptionKey` became functions of `AppL10n`. Generated localisations have no
  runtime key lookup, so a key string would need a hand-kept map the compiler cannot check —
  a typo would be a blank hub card rather than a build error.*
- *`GameConfig` is hand-written rather than freezed, because a generated constructor cannot
  clamp. There is no way to hold an over-limit config (§4).*
- *`CardPoolProvider` became `PracticeRepository.loadPool`. Each selection is one query; a
  provider per selection would have been four one-line wrappers.*
- *`GameRoundCallbacks` gained `onSpeak` and `intervalLabel`. The play button (F-063) and the
  next-interval hint on each grade (`UI-UX.md` §4.7) both need things only the runner has.*
- *A round view is handed a **new round object** for every round and must reset per object,
  not per `index`: a repeat (§3) is built as a one-card session, so repeats are all index 0.
  For the same reason `GameRoundCallbacks.position` carries the round's place in the session
  — the flashcard's round-1-only hint read `index` and showed on every repeat.*

## 3. The runner (written once, shared by all games)

`PracticeSessionRunner` (`application/practice/practice_session_controller.dart`) is a
Riverpod notifier that:

1. loads the pool with `PracticeRepository.loadPool` for `config.selection`
2. calls `game.buildRounds(...)`
3. opens a `practice_sessions` row with `affects_scheduling = mode == daily`
4. per round: renders `game.buildRoundView`, receives the answer, calls `game.grade`,
   writes a `practice_answers` row at the round's **position in the session**, and — **only
   if `affects_scheduling`** — applies `ReviewScheduler`, with the user's schedule (§5), to
   the `study_cards` row
5. takes **one answer at a time**: an answer that arrives while the last is still saving (a
   double tap, a swipe and a tap) is ignored, so no game can grade a round twice
6. on *again*, asks the card once more later **in the same session**, up to
   `settings.again_repeats` times per card (default 1); the repeat writes nothing to
   `study_cards`
7. closes the session and hands a `SessionSummary` to the shared summary screen

Games never touch the database, never navigate, never own a progress bar.

## 4. Modes

### Daily review (`PracticeMode.daily`)
- Selection: `due` → `WHERE due_at <= now AND suspended = 0`, ordered by `due_at`, then random.
- Limit: the user's daily goal (default 20). If nothing is due, the hub offers "Nothing due —
  practise 10 at random instead?" which starts a **quick test** (schedule untouched).
- `affects_scheduling = true`.

### Quick test (`PracticeMode.quickTest`)
- Source: All words / a specific list / Favourites. A list source with no list is an empty
  pool, never the whole library.
- Size: 5 · 10 · 20 · **All (max 30)**. The 30 cap is enforced in `GameConfig` construction
  *and* in the query, and is unit-tested with a 500-word fixture.
- Selection: `random` with a stored `seed` so a session can be replayed or debugged. The
  sample is drawn in Dart from ids in a fixed order — SQL `RANDOM()` cannot be seeded.
  `Random(seed)` is stable within one SDK release, not across them, so a seed replays a
  session within a build; `practice_answers` is the durable record of what was asked.
- `affects_scheduling = false` — a casual test must never damage a carefully built schedule.
  Answers are still recorded for stats.

## 5. Scheduling — `LeitnerScheduler` (v1)

| Box | Interval on *good* |
|---|---|
| 0 | same day, +10 min |
| 1 | 1 day |
| 2 | 2 days |
| 3 | 4 days |
| 4 | 7 days |
| 5 | 15 days |
| 6 | 30 days |

- `again` → box 0, `lapses++`, due in 10 minutes
- `good`  → box + 1 (max 6)
- `easy`  → box + 2 (max 6)
- `due_at = now + interval`, where the interval is the one for the box the card **lands in**,
  jittered ±10% so decks don't clump on one day
- `repetitions++`, `last_result`, `last_reviewed_at` written on every **graded** answer
- a **skipped** round writes `last_result` and `last_reviewed_at` only. It does not
  advance the box, move `due_at`, or count as a repetition or a lapse.
  *Clarified at M5: this line said "always", which read literally would count
  scrolling past a card as reviewing it — inflating the schedule and pushing real work
  into the future. `ReviewOutcome.skipped`'s own contract, "recorded, but never
  schedules", is the one that holds.*

*Changed at M5, at the user's request: the table above is the **default**, not a constant.*
`ReviewSchedule` (`application/practice/scheduler/review_schedule.dart`) holds one interval
per box and is stored as JSON in `settings.review_schedule` (`DATABASE.md`). A pace preset
*produces* a table — *gentle* ×1.5, *standard* ×1 (exactly the table above), *intensive* ×0.6
— which can then be edited box by box, so there is one source of truth rather than a mode.
Two things stay out of the user's hands: box 0 is always same-day, and a lapse is always ten
minutes. A table that would stop words coming back — a 0 past box 0, a box shorter than the
one before it, the wrong number of boxes — is refused with a sentence saying what is wrong,
and a stored table that cannot be read falls back to the default.

`Sm2Scheduler` (phase 2) uses `ease_factor`, which already exists in the schema — swapping it
in is a single provider override with **no migration**.

## 6. v1 game: `FlashcardGame`

- `presentation/practice/games/flashcard/` — a round view needs the shared UI (`IpaText`, the
  spacing tokens), and `application` may not import `presentation` (RULES §20).
- `descriptor.id = 'flashcard'`, modes `{daily, quickTest}`, `minCards = 4`, `requiresIpa = false`
- `buildRounds` → one `FlashcardRound` per card, shuffled by `seed`
- `grade` → self-graded: the tapped button *is* the result
- `buildRoundView` → front (prompt side per config, with the play button) → tap or swipe up to
  flip → back (word + IPA with the user's highlights + definition + first note) → Again /
  Good / Easy, each showing its next interval. After the flip, swipe left = Again and right =
  Good, at ≥ 300 px/s so a thumb resting on the card does not grade it — a shortcut for the
  buttons, never instead of them.

## 7. Adding game #2 — the checklist

1. New folder `presentation/practice/games/<name>/`
2. `class XGame implements PracticeGame<XRound>` with a `GameDescriptor`
3. A round widget in the same folder
4. One line in `presentation/practice/game_registry_provider.dart`
5. l10n strings for title + description
6. Tests: `buildRounds` determinism under a fixed seed, `grade` truth table, one widget test

If steps 2–6 required editing any shared file other than the registry and l10n, the framework
is wrong — fix the framework, not the game. `DummyGame` in
`test/unit/application/dummy_game.dart` exists purely to keep this honest and must stay green.
*Corrected at M5: step 1 put games under `application/`, which the layer-boundaries test
rejects — see §6.*
