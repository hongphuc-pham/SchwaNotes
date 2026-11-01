import 'package:flutter/material.dart';
import 'package:vocabnote/application/practice/game_contracts.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/theme/app_metrics.dart';
import 'package:vocabnote/core/theme/app_theme.dart';
import 'package:vocabnote/core/theme/tokens.dart';
import 'package:vocabnote/domain/entities/study_card.dart';
import 'package:vocabnote/presentation/common/ipa_text.dart';
import 'package:vocabnote/presentation/design/button_row.dart';
import 'package:vocabnote/presentation/design/gap.dart';
import 'package:vocabnote/presentation/practice/games/flashcard/flashcard_game.dart';

/// One flashcard: a front, a flip, a back, three grades (`UI-UX.md` §4.7).
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

/// How fast a sideways swipe must be to grade the card, in logical pixels per
/// second.
///
/// Flutter counts anything over 50 as a fling, which a thumb resting on the
/// card while reading the back can manage. A grade moves the schedule, so only
/// a swipe that was plainly meant counts.
const double _swipeGradeVelocity = 300;

class _FlashcardRoundViewState extends State<FlashcardRoundView> {
  bool _revealed = false;
  bool _answered = false;
  final Stopwatch _elapsed = Stopwatch()..start();

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
    final metrics = context.metrics;

    return Padding(
      padding: EdgeInsets.all(metrics.spaceLg),
      child: Column(
        children: <Widget>[
          Expanded(
            child: _Card(
              round: widget.round,
              revealed: _revealed,
              // "Tap to reveal" on the session's first round only (UI-UX
              // §4.7). A repeat is built as a one-card session, so it believes
              // it is round 1 too; the runner's position knows better.
              showHint:
                  widget.round.isFirstRound && widget.callbacks.position == 0,
              onReveal: _reveal,
              onSwipe: _answer,
              onSpeak: widget.callbacks.onSpeak,
            ),
          ),
          const VnGap(VnSpace.lg),
          _Grades(
            enabled: _revealed,
            intervalLabel: widget.callbacks.intervalLabel,
            onGrade: _answer,
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
        // Left = Again, right = Good (UI-UX §4.7), AnkiMobile's mapping too.
        // A shortcut for the buttons below, never instead of them (WCAG
        // 2.5.1), and ignored until the answer is showing - `onSwipe` refuses
        // an unrevealed card exactly as the disabled buttons do.
        onHorizontalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          if (velocity.abs() < _swipeGradeVelocity) return;
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

    return Column(
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
            // The sound is what an IPA front is for; the word's name is not.
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
          ),
        ],
      ],
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

/// Again · Good · Easy, each showing when the card returns.
class _Grades extends StatelessWidget {
  const new({required this.enabled, required this.onGrade, this.intervalLabel});

  final bool enabled;
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
          onPressed: enabled ? () => onGrade(ReviewOutcome.again) : null,
        ),
        _GradeButton(
          outcome: ReviewOutcome.good,
          label: l10n.gradeGood,
          interval: intervalLabel?.call(ReviewOutcome.good),
          style: _GradeStyle.filled,
          onPressed: enabled ? () => onGrade(ReviewOutcome.good) : null,
        ),
        _GradeButton(
          outcome: ReviewOutcome.easy,
          label: l10n.gradeEasy,
          interval: intervalLabel?.call(ReviewOutcome.easy),
          style: _GradeStyle.tonal,
          onPressed: enabled ? () => onGrade(ReviewOutcome.easy) : null,
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
  final VoidCallback? onPressed;

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
