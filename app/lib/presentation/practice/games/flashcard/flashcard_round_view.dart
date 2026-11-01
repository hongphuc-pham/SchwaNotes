import 'package:flutter/material.dart';
import 'package:vocabnote/application/practice/game_contracts.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/theme/app_metrics.dart';
import 'package:vocabnote/core/theme/app_theme.dart';
import 'package:vocabnote/core/theme/tokens.dart';
import 'package:vocabnote/core/utils/answer_match.dart';
import 'package:vocabnote/domain/entities/study_card.dart';
import 'package:vocabnote/presentation/common/ipa_text.dart';
import 'package:vocabnote/presentation/design/button_row.dart';
import 'package:vocabnote/presentation/design/gap.dart';
import 'package:vocabnote/presentation/practice/games/flashcard/flashcard_game.dart';

/// One flashcard: a front, a flip, a back, three grades (`UI-UX.md` §4.7).
///
/// The front can be answered by typing and checking, or just flipped; either
/// way the user grades the back. Skip moves on from either side without a
/// grade.
///
/// A game owns its round widget and nothing else — no navigation, no database,
/// no progress bar. Everything it needs arrives in [round]; everything it wants
/// done goes through [callbacks].
class FlashcardRoundView extends StatefulWidget {
  /// Creates the view.
  const new({required this.round, required this.callbacks, super.key});

  /// The card being asked about.
  final FlashcardRound round;

  /// The only things this view may ask the runner to do.
  final GameRoundCallbacks callbacks;

  @override
  State<FlashcardRoundView> createState() => _FlashcardRoundViewState();
}

/// How fast a sideways swipe must be to count, in logical pixels per second.
///
/// Flutter counts anything over 50 as a fling, which a thumb resting on the
/// card while reading the back can manage. A swipe grades the back and skips
/// the front, so only one that was plainly meant counts.
const double _swipeVelocity = 300;

/// The most of the round's height the controls under the card may take.
///
/// With the keyboard up at 200% text they want more than there is. Past this
/// they scroll, and the card keeps enough room to show its question.
const double _controlsShare = 0.6;

class _FlashcardRoundViewState extends State<FlashcardRoundView> {
  bool _revealed = false;
  bool _answered = false;
  final Stopwatch _elapsed = Stopwatch()..start();
  final TextEditingController _typed = TextEditingController();

  /// What was checked and how close it was. Null unless Check was used.
  String? _checkedAnswer;
  int? _matchPercent;

  @override
  void dispose() {
    _typed.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(FlashcardRoundView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A new round reuses this State when the runner swaps the card, so the
    // reveal has to be reset explicitly. Without this the second card of a
    // session opens already answered.
    //
    // By identity, not by `index`: a repeat is built as a one-card session,
    // so two repeats in a row are both index 0, and the second would open
    // revealed and - with answering guarded - never accept an answer.
    if (!identical(oldWidget.round, widget.round)) {
      _revealed = false;
      _answered = false;
      _checkedAnswer = null;
      _matchPercent = null;
      _typed.clear();
      _elapsed
        ..reset()
        ..start();
    }
  }

  void _reveal() {
    if (_revealed) return;
    setState(() => _revealed = true);
    // Only when the user asked for it. The play button on the front is always
    // available regardless (F-063: autoplay is "optional").
    if (!widget.round.autoPlayOnReveal) return;
    if (widget.callbacks.onSpeak case final VoidCallback speak) speak();
  }

  void _check() {
    final typed = _typed.text.trim();
    final expected = widget.round.expectedAnswer;
    if (_revealed || typed.isEmpty || expected == null) return;
    _checkedAnswer = typed;
    _matchPercent = answerMatchPercent(typed, expected);
    _reveal();
  }

  /// Moves on without a grade, from either side: the card stays due.
  void _skip() {
    if (_answered) return;
    _answered = true;
    _elapsed.stop();
    widget.callbacks.onAnswer(
      GameAnswer(result: ReviewOutcome.skipped, elapsed: _elapsed.elapsed),
    );
  }

  void _swipe(ReviewOutcome outcome) {
    _revealed ? _answer(outcome) : _skip();
  }

  void _answer(ReviewOutcome result) {
    // Grading before revealing would record an answer the user never saw the
    // question for. Grading twice would record one answer as two: the round is
    // only swapped once the runner has saved, so a double tap - or a swipe and
    // a tap - both land here.
    if (!_revealed || _answered) return;
    _answered = true;
    _elapsed.stop();
    widget.callbacks.onAnswer(
      GameAnswer(result: result, elapsed: _elapsed.elapsed),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final metrics = context.metrics;

    return Padding(
      padding: EdgeInsets.all(metrics.spaceLg),
      child: Column(
        children: <Widget>[
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              key: const ValueKey<String>('flashcard-skip'),
              icon: const Icon(Icons.skip_next),
              label: Text(l10n.flashcardSkip),
              onPressed: _skip,
            ),
          ),
          const VnGap(VnSpace.sm),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => Column(
                children: <Widget>[
                  Expanded(
                    child: _Card(
                      round: widget.round,
                      revealed: _revealed,
                      // The hint on the session's first round only (UI-UX
                      // §4.7). A repeat is built as a one-card session, so it
                      // believes it is round 1 too; the runner's position
                      // knows better.
                      showHint:
                          widget.round.isFirstRound &&
                          widget.callbacks.position == 0,
                      onReveal: _reveal,
                      onSwipe: _swipe,
                      onSpeak: widget.callbacks.onSpeak,
                    ),
                  ),
                  const VnGap(VnSpace.lg),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: constraints.maxHeight * _controlsShare,
                    ),
                    child: SingleChildScrollView(
                      child: _revealed
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                if (_matchPercent case final int percent)
                                  _MatchResult(
                                    percent: percent,
                                    answer: _checkedAnswer ?? '',
                                  ),
                                _Grades(
                                  intervalLabel: widget.callbacks.intervalLabel,
                                  onGrade: _answer,
                                ),
                              ],
                            )
                          : _AnswerControls(
                              round: widget.round,
                              typed: _typed,
                              onCheck: _check,
                              onShow: _reveal,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The card itself, front or back.
class _Card extends StatelessWidget {
  const new({
    required this.round,
    required this.revealed,
    required this.showHint,
    required this.onReveal,
    required this.onSwipe,
    this.onSpeak,
  });

  final FlashcardRound round;
  final bool revealed;
  final bool showHint;
  final VoidCallback onReveal;
  final void Function(ReviewOutcome outcome) onSwipe;
  final VoidCallback? onSpeak;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final metrics = context.metrics;

    return Semantics(
      // UI-UX §6: the flip card announces its state, rather than silently
      // changing what it says.
      label: revealed ? l10n.flashcardBackLabel : l10n.flashcardFrontLabel,
      button: !revealed,
      onTap: revealed ? null : onReveal,
      child: GestureDetector(
        // The swipes are shortcuts for the reveal above and the grade buttons
        // below, never the only way. Left in the semantics tree they made an
        // unlabelled node of their own - a tap plus four scroll actions - that
        // a screen reader would announce as nothing (found by the M7 guideline
        // test). The labelled reveal is the `Semantics` above.
        excludeFromSemantics: true,
        onTap: onReveal,
        // Swipe up reveals, as an alternative to tapping - never the only way
        // (UI-UX §1).
        onVerticalDragEnd: (details) {
          if ((details.primaryVelocity ?? 0) < 0) onReveal();
        },
        // On the back, left = Again and right = Good (UI-UX §4.7), AnkiMobile's
        // mapping too. On the front there is nothing to grade yet, so either
        // way skips. Shortcuts for the buttons, never instead of them (WCAG
        // 2.5.1).
        onHorizontalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          if (velocity.abs() < _swipeVelocity) return;
          onSwipe(velocity < 0 ? ReviewOutcome.again : ReviewOutcome.good);
        },
        child: Card(
          child: SizedBox.expand(
            child: Padding(
              padding: EdgeInsets.all(metrics.spaceLg),
              child: AnimatedSwitcher(
                // Zero when the user has asked for reduced motion (F-093):
                // `durationFor` is the single place that check lives.
                duration: AppMotion.durationFor(context, metrics.flip),
                switchInCurve: AppMotion.flipCurve,
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: revealed
                    ? _Back(
                        key: const ValueKey<bool>(true),
                        round: round,
                        onSpeak: onSpeak,
                      )
                    : _Front(
                        key: const ValueKey<bool>(false),
                        round: round,
                        showHint: showHint,
                        onSpeak: onSpeak,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The question side.
class _Front extends StatelessWidget {
  const new({
    required this.round,
    required this.showHint,
    this.onSpeak,
    super.key,
  });

  final FlashcardRound round;
  final bool showHint;
  final VoidCallback? onSpeak;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);

    // Scrolls because the keyboard can leave the card very little height. It
    // only takes a drag when it overflows, so a swipe up still reveals.
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (round.frontIsIpa)
                IpaText(
                  ipa: round.frontText,
                  highlights: round.card.highlights,
                  style: context.type.ipaLarge,
                )
              else
                Text(
                  round.frontText,
                  style: context.type.displayWord,
                  textAlign: TextAlign.center,
                ),
              if (onSpeak case final VoidCallback speak
                  when !round.wordIsHidden) ...<Widget>[
                const VnGap(VnSpace.lg),
                _PlayButton(
                  round: round,
                  onSpeak: speak,
                  // The sound is what an IPA front is for; the word's name is
                  // not.
                  nameWord: !round.frontIsIpa,
                ),
              ],
              if (showHint) ...<Widget>[
                const VnGap(VnSpace.xl),
                Text(
                  l10n.flashcardTapToReveal,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Speaks the word.
class _PlayButton extends StatelessWidget {
  const new({required this.round, required this.onSpeak, this.nameWord = true});

  final FlashcardRound round;
  final VoidCallback onSpeak;

  /// Whether the label may say the word: the tooltip and a screen reader both
  /// read it, so it must not where the word is still the answer.
  final bool nameWord;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final word = round.card.word;

    return IconButton.filledTonal(
      icon: const Icon(Icons.volume_up),
      tooltip: nameWord
          ? l10n.detailPlayLabel(
              word.headword.value,
              word.ipaUk != null ? l10n.detailAccentUk : l10n.detailAccentUs,
            )
          : l10n.flashcardPlaySoundLabel,
      onPressed: onSpeak,
    );
  }
}

/// The answer side: word · IPA with highlights · definition · first note.
class _Back extends StatelessWidget {
  const new({required this.round, this.onSpeak, super.key});

  final FlashcardRound round;
  final VoidCallback? onSpeak;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final word = round.card.word;
    final ipa = word.preferredIpa;

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Text(
            word.headword.value,
            style: context.type.displayWord,
            textAlign: TextAlign.center,
          ),
          if (ipa != null) ...<Widget>[
            const VnGap(VnSpace.sm),
            IpaText(
              ipa: ipa.value,
              highlights: round.card.highlights,
              style: context.type.ipaLarge,
            ),
          ],
          // The one card whose front had no button (F-063): without this, a
          // user with autoplay off could never hear the word on it.
          if (onSpeak case final VoidCallback speak
              when round.wordIsHidden) ...<Widget>[
            const VnGap(VnSpace.sm),
            _PlayButton(round: round, onSpeak: speak),
          ],
          if (word.definition case final String definition
              when definition.isNotEmpty) ...<Widget>[
            const VnGap(VnSpace.lg),
            Text(
              definition,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
          if (round.card.firstNote case final String note
              when note.isNotEmpty) ...<Widget>[
            const VnGap(VnSpace.lg),
            Text(
              note,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// The answer field, Check and Show answer, under an unflipped card.
///
/// No autofocus: a keyboard rising on every card would punish the people who
/// only want to flip it.
class _AnswerControls extends StatelessWidget {
  const new({
    required this.round,
    required this.typed,
    required this.onCheck,
    required this.onShow,
  });

  final FlashcardRound round;
  final TextEditingController typed;
  final VoidCallback onCheck;
  final VoidCallback onShow;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    if (round.expectedAnswer == null) {
      return FilledButton(
        key: const ValueKey<String>('flashcard-show-answer'),
        onPressed: onShow,
        child: Text(l10n.flashcardShowAnswer),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: context.metrics.spaceSm,
      children: <Widget>[
        TextField(
          key: const ValueKey<String>('flashcard-answer'),
          controller: typed,
          // Spelling is what is being practised: a keyboard that corrects it
          // would answer the card for the user.
          //
          // Never `enableSuggestions: false` as well. On Android that also
          // marks the field a visible password, which puts keyboards in raw
          // Latin input: Vietnamese Telex and VNI could not compose an accent.
          // Users answer in their own language, so that matters more than
          // hiding a suggestion strip.
          autocorrect: false,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => onCheck(),
          decoration: InputDecoration(
            labelText: round.asksForWord
                ? l10n.flashcardTypeWord
                : l10n.flashcardTypeMeaning,
          ),
        ),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: typed,
          builder: (context, value, _) => VnButtonRow(
            labels: <String>[l10n.flashcardShowAnswer, l10n.flashcardCheck],
            children: <Widget>[
              OutlinedButton(
                key: const ValueKey<String>('flashcard-show-answer'),
                onPressed: onShow,
                child: Text(l10n.flashcardShowAnswer),
              ),
              FilledButton(
                key: const ValueKey<String>('flashcard-check'),
                onPressed: value.text.trim().isEmpty ? null : onCheck,
                child: Text(l10n.flashcardCheck),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// How close the typed answer was, and what it was.
///
/// Outside the card so a long back cannot scroll it away.
class _MatchResult extends StatelessWidget {
  const new({required this.percent, required this.answer});

  final int percent;
  final String answer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: context.metrics.spaceSm),
      child: Semantics(
        container: true,
        liveRegion: true,
        child: Column(
          children: <Widget>[
            Text(
              l10n.flashcardMatch(percent),
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            Text(
              l10n.flashcardYouWrote(answer),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Again · Good · Easy, each showing when the card returns.
class _Grades extends StatelessWidget {
  const new({required this.onGrade, this.intervalLabel});

  final String? Function(ReviewOutcome outcome)? intervalLabel;
  final void Function(ReviewOutcome outcome) onGrade;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    // Stacks rather than wraps at large text: three equal buttons on a 320dp
    // phone at 200% broke "Again" mid-word (UI-UX §6).
    return VnButtonRow(
      labels: <String>[l10n.gradeAgain, l10n.gradeGood, l10n.gradeEasy],
      children: <Widget>[
        _GradeButton(
          outcome: ReviewOutcome.again,
          label: l10n.gradeAgain,
          interval: intervalLabel?.call(ReviewOutcome.again),
          style: _GradeStyle.outlined,
          onPressed: () => onGrade(ReviewOutcome.again),
        ),
        _GradeButton(
          outcome: ReviewOutcome.good,
          label: l10n.gradeGood,
          interval: intervalLabel?.call(ReviewOutcome.good),
          style: _GradeStyle.filled,
          onPressed: () => onGrade(ReviewOutcome.good),
        ),
        _GradeButton(
          outcome: ReviewOutcome.easy,
          label: l10n.gradeEasy,
          interval: intervalLabel?.call(ReviewOutcome.easy),
          style: _GradeStyle.tonal,
          onPressed: () => onGrade(ReviewOutcome.easy),
        ),
      ],
    );
  }
}

enum _GradeStyle { outlined, filled, tonal }

class _GradeButton extends StatelessWidget {
  const new({
    required this.outcome,
    required this.label,
    required this.style,
    required this.onPressed,
    this.interval,
  });

  final ReviewOutcome outcome;
  final String label;
  final String? interval;
  final _GradeStyle style;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // The interval is a hint, not a second label: a screen reader saying
    // "Good, 2d" is fine, but it must not read as two separate controls.
    final child = Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(label),
        if (interval case final String next)
          Text(next, style: theme.textTheme.labelSmall),
      ],
    );

    return switch (style) {
      _GradeStyle.outlined => OutlinedButton(
        key: ValueKey<String>('grade-${outcome.name}'),
        onPressed: onPressed,
        child: child,
      ),
      _GradeStyle.filled => FilledButton(
        key: ValueKey<String>('grade-${outcome.name}'),
        onPressed: onPressed,
        child: child,
      ),
      _GradeStyle.tonal => FilledButton.tonal(
        key: ValueKey<String>('grade-${outcome.name}'),
        onPressed: onPressed,
        child: child,
      ),
    };
  }
}
