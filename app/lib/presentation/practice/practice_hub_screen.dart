import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vocabnote/application/practice/game_contracts.dart';
import 'package:vocabnote/application/practice/practice_hub_controller.dart';
import 'package:vocabnote/application/settings/settings_controller.dart';
import 'package:vocabnote/application/words/word_list_controller.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/router/routes.dart';
import 'package:vocabnote/core/theme/app_metrics.dart';
import 'package:vocabnote/domain/entities/practice_session.dart';
import 'package:vocabnote/domain/repositories/practice_repository.dart';
import 'package:vocabnote/presentation/common/empty_state.dart';
import 'package:vocabnote/presentation/common/settings_action.dart';
import 'package:vocabnote/presentation/design/button_row.dart';
import 'package:vocabnote/presentation/design/gap.dart';
import 'package:vocabnote/presentation/practice/game_registry_provider.dart';
import 'package:vocabnote/presentation/practice/quick_test_sheet.dart';

/// The practice hub (`docs/UI-UX.md` §4.6, F-060).
///
/// One card per registered game, whether or not it can be started — a game the
/// user cannot play yet still needs to say *why*, which is more useful than an
/// empty screen.
class PracticeHubScreen extends ConsumerStatefulWidget {
  /// Creates the hub.
  const new({super.key});

  @override
  ConsumerState<PracticeHubScreen> createState() => _PracticeHubScreenState();
}

class _PracticeHubScreenState extends ConsumerState<PracticeHubScreen> {
  // Time passes without a database write: a card graded *Again* comes due ten
  // minutes later, and nothing re-runs the count. Coming back to the app
  // re-reads it, or the hub would go on saying nothing is due - with Daily
  // review disabled - until a restart (M8).
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onResume: () => ref.invalidate(dueCardCountProvider),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final metrics = context.metrics;
    final registry = ref.watch(gameRegistryProvider);
    final words = ref.watch(totalWordCountProvider);
    // Null while it loads; a failure is told apart from an empty library
    // below, or a read that failed would read as "no words yet" (M7).
    final wordCount = words.value ?? 0;
    final dueCount = ref.watch(dueCardCountProvider).value ?? 0;
    final descriptors = registry.available(wordCount);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.practiceTitle),
        actions: const <Widget>[SettingsAction()],
      ),
      body: words.hasError
          ? EmptyState(
              icon: Icons.error_outline,
              title: l10n.practiceCountsFailedTitle,
              body: l10n.practiceCountsFailedBody,
              actionLabel: l10n.retryAction,
              onAction: () => ref.invalidate(totalWordCountProvider),
            )
          : wordCount == 0
          ? EmptyState(
              icon: Icons.school_outlined,
              title: l10n.practiceEmptyTitle,
              body: l10n.practiceEmptyBody,
              actionLabel: l10n.addWordAction,
              onAction: () => context.push(Routes.wordAdd),
            )
          : ListView(
              padding: EdgeInsets.all(metrics.spaceLg),
              children: <Widget>[
                const _GoalCard(),
                const VnGap(VnSpace.md),
                for (final descriptor in descriptors)
                  Padding(
                    padding: EdgeInsets.only(bottom: metrics.spaceMd),
                    child: _GameCard(
                      descriptor: descriptor,
                      unlocked: registry.isUnlocked(descriptor, wordCount),
                      wordCount: wordCount,
                      dueCount: dueCount,
                    ),
                  ),
              ],
            ),
    );
  }
}

/// Today's goal and the run of days behind it (F-065, `docs/UI-UX.md` §4.6).
///
/// Encouraging copy, never a warning (`docs/RULES.md` §6). A streak of zero is
/// not mentioned at all — there is no "you lost your streak" — and today is
/// never "at risk": a day is not missed until it is over.
class _GoalCard extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(practiceProgressProvider).value;
    // Nothing rather than a zero while the first query runs: "0 of 20 today"
    // for a frame would read as a verdict.
    if (progress == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final metrics = context.metrics;
    final goal = ref.watch(appSettingsOrDefaultsProvider).dailyGoal;
    final streak = progress.streak;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(metrics.spaceLg),
        // One sentence to a screen reader — "3 of 20 today. 2 days in a row." —
        // rather than a ring, a number and a line read out separately.
        child: MergeSemantics(
          child: Row(
            children: <Widget>[
              // The words carry the meaning and the ring draws the same fact,
              // so colour is never the only way to tell (WCAG 1.4.11).
              ExcludeSemantics(
                child: SizedBox.square(
                  dimension: metrics.minTouchTarget,
                  child: CircularProgressIndicator(
                    value: progress.fractionOf(goal),
                    strokeWidth: metrics.spaceXs,
                    color: theme.colorScheme.secondary,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
              ),
              const VnGap(VnSpace.lg, axis: Axis.horizontal),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      progress.goalReached(goal)
                          ? l10n.practiceGoalReached
                          : l10n.practiceGoalProgress(
                              progress.wordsToday,
                              goal,
                            ),
                      style: theme.textTheme.titleMedium,
                    ),
                    const VnGap(VnSpace.xs),
                    Text(
                      streak > 0
                          ? l10n.practiceStreak(streak)
                          : l10n.practiceGoalStart,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One game's card.
class _GameCard extends ConsumerWidget {
  const new({
    required this.descriptor,
    required this.unlocked,
    required this.wordCount,
    required this.dueCount,
  });

  final GameDescriptor descriptor;
  final bool unlocked;
  final int wordCount;
  final int dueCount;

  Future<void> _startQuickTest(BuildContext context, WidgetRef ref) async {
    final config = await QuickTestSheet.show(context, gameId: descriptor.id);
    if (config == null || !context.mounted) return;
    unawaited(context.push(Routes.practiceRunOf(descriptor.id), extra: config));
  }

  void _startDaily(BuildContext context, WidgetRef ref) {
    final goal = ref.read(appSettingsOrDefaultsProvider).dailyGoal;
    unawaited(
      context.push(
        Routes.practiceRunOf(descriptor.id),
        extra: GameConfig(
          gameId: descriptor.id,
          mode: PracticeMode.daily,
          selection: CardSelection.due,
          limit: goal,
          promptSide: ref.read(appSettingsOrDefaultsProvider).promptSide,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final metrics = context.metrics;
    final hasDaily = descriptor.supportedModes.contains(PracticeMode.daily);
    final hasQuickTest = descriptor.supportedModes.contains(
      PracticeMode.quickTest,
    );

    return Card(
      child: Padding(
        padding: EdgeInsets.all(metrics.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(descriptor.icon, color: theme.colorScheme.primary),
                const VnGap(VnSpace.sm, axis: Axis.horizontal),
                Expanded(
                  child: Text(
                    descriptor.title(l10n),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const VnGap(VnSpace.sm),
            Text(
              descriptor.description(l10n),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const VnGap(VnSpace.lg),
            if (!unlocked)
              // Says what to do, not merely that the game is unavailable.
              Text(
                l10n.practiceLockedHint(descriptor.minCards - wordCount),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else
              // Stacks rather than wraps at large text (UI-UX §6).
              VnButtonRow(
                labels: <String>[
                  if (hasDaily) l10n.practiceDailyReview(dueCount),
                  if (hasQuickTest) l10n.practiceQuickTest,
                ],
                children: <Widget>[
                  if (hasDaily)
                    FilledButton(
                      onPressed: dueCount == 0
                          ? null
                          : () => _startDaily(context, ref),
                      child: Text(l10n.practiceDailyReview(dueCount)),
                    ),
                  if (hasQuickTest)
                    OutlinedButton(
                      onPressed: () => unawaited(_startQuickTest(context, ref)),
                      child: Text(l10n.practiceQuickTest),
                    ),
                ],
              ),
            if (unlocked && dueCount == 0) ...<Widget>[
              const VnGap(VnSpace.sm),
              // `GAMES.md` §4: nothing due is an offer, never a scolding.
              Text(
                l10n.practiceNothingDue,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
