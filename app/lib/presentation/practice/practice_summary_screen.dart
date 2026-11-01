import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vocabnote/application/lists/list_actions_controller.dart';
import 'package:vocabnote/application/lists/list_controller.dart';
import 'package:vocabnote/application/practice/game_contracts.dart';
import 'package:vocabnote/application/practice/practice_session_controller.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/router/routes.dart';
import 'package:vocabnote/core/theme/app_metrics.dart';
import 'package:vocabnote/core/theme/app_theme.dart';
import 'package:vocabnote/domain/entities/practice_session.dart';
import 'package:vocabnote/domain/entities/word_list.dart';
import 'package:vocabnote/presentation/common/empty_state.dart';
import 'package:vocabnote/presentation/design/gap.dart';

/// What a session was worth (`docs/UI-UX.md` §4.8, F-064).
///
/// The copy is deliberately warm. Missed words are **"worth another look"**,
/// never "wrong" — a person who just practised has done the right thing, and a
/// summary that reads as a report card is one people stop opening.
class PracticeSummaryScreen extends ConsumerWidget {
  /// Creates the summary.
  const new({super.key});

  /// The choices just made, for another go.
  ///
  /// A quick test draws a fresh sample: "again" means more practice, not the
  /// same words in the same order. A daily review keeps its config and picks
  /// up whatever is still due - a word just failed is back in ten minutes.
  static GameConfig _again(GameConfig config) =>
      config.mode == PracticeMode.quickTest
      ? config.withSeed(Random().nextInt(1 << 31))
      : config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final metrics = context.metrics;
    final session = ref.watch(practiceSessionRunnerProvider);
    final summary = session?.summary;

    if (session == null || summary == null) {
      // Reached by URL, or after the runner was disposed. There is nothing to
      // summarise and nothing to recover, so say so and offer the way back
      // rather than showing an empty score.
      return Scaffold(
        appBar: AppBar(title: Text(l10n.summaryTitle)),
        body: EmptyState(
          icon: Icons.history,
          title: l10n.summaryMissingTitle,
          body: l10n.summaryMissingBody,
          actionLabel: l10n.summaryDone,
          onAction: () => context.go(Routes.practice),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.summaryTitle),
      ),
      body: ListView(
        padding: EdgeInsets.all(metrics.spaceLg),
        children: <Widget>[
          _Score(summary: summary),
          const VnGap(VnSpace.xl),
          if (summary.missed.isNotEmpty) ...<Widget>[
            _MissedWords(summary: summary),
            const VnGap(VnSpace.xl),
          ],
          FilledButton.tonal(
            onPressed: () => context.go(
              Routes.practiceRunOf(session.config.gameId),
              extra: _again(session.config),
            ),
            child: Text(l10n.summaryPractiseAgain),
          ),
          const VnGap(VnSpace.sm),
          FilledButton(
            onPressed: () => context.go(Routes.practice),
            child: Text(l10n.summaryDone),
          ),
        ],
      ),
    );
  }
}

/// "Nice work — 8 of 10", and how long it took.
class _Score extends StatelessWidget {
  const new({required this.summary});

  final SessionSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);

    return Column(
      children: <Widget>[
        Text(
          // Every card skipped: "Nice work - 0 of 0" would be praise for
          // nothing, and a score of nothing.
          summary.totalRounds == 0
              ? l10n.summaryNothingGraded
              : l10n.summaryScore(summary.correctRounds, summary.totalRounds),
          style: context.type.displayWord,
          textAlign: TextAlign.center,
        ),
        const VnGap(VnSpace.sm),
        if (summary.skippedRounds > 0) ...<Widget>[
          Text(
            l10n.summarySkipped(summary.skippedRounds),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const VnGap(VnSpace.sm),
        ],
        Text(
          l10n.summaryTime(
            summary.duration.inMinutes,
            summary.duration.inSeconds % 60,
          ),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// The words worth another look, and one tap to collect them.
class _MissedWords extends ConsumerWidget {
  const new({required this.summary});

  final SessionSummary summary;

  Future<void> _addAllToList(BuildContext context, WidgetRef ref) async {
    // Read before the first await: a WidgetRef is only good for the build that
    // produced it.
    final actions = ref.read(listActionsProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppL10n.of(context);
    final lists =
        ref.read(listSummariesProvider).value ?? const <WordListSummary>[];

    final chosen = await showModalBottomSheet<WordList>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            for (final summary in lists)
              ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: Text(summary.list.name),
                onTap: () => Navigator.of(context).pop(summary.list),
              ),
          ],
        ),
      ),
    );
    if (chosen == null) return;

    for (final card in summary.missed) {
      await actions.addWordToList(listId: chosen.id, wordId: card.word.id);
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          l10n.summaryAddedToList(summary.missed.length, chosen.name),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final metrics = context.metrics;
    final hasLists =
        (ref.watch(listSummariesProvider).value ?? const <WordListSummary>[])
            .isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(l10n.summaryMissedHeading, style: theme.textTheme.titleMedium),
        const VnGap(VnSpace.sm),
        Wrap(
          spacing: metrics.spaceSm,
          runSpacing: metrics.spaceSm,
          children: <Widget>[
            for (final card in summary.missed)
              ActionChip(
                label: Text(card.word.headword.value),
                onPressed: () =>
                    context.push(Routes.wordDetailOf(card.word.id)),
              ),
          ],
        ),
        if (hasLists) ...<Widget>[
          const VnGap(VnSpace.md),
          OutlinedButton.icon(
            icon: const Icon(Icons.playlist_add),
            label: Text(l10n.summaryAddMissed),
            onPressed: () => unawaited(_addAllToList(context, ref)),
          ),
        ],
      ],
    );
  }
}
