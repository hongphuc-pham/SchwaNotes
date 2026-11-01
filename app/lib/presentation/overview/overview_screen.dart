import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vocabnote/application/lists/list_controller.dart';
import 'package:vocabnote/application/practice/practice_hub_controller.dart';
import 'package:vocabnote/application/words/word_actions_controller.dart';
import 'package:vocabnote/application/words/word_list_controller.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/router/routes.dart';
import 'package:vocabnote/core/theme/app_metrics.dart';
import 'package:vocabnote/domain/entities/word_list.dart';
import 'package:vocabnote/domain/entities/word_overview.dart';
import 'package:vocabnote/domain/repositories/word_repository.dart';
import 'package:vocabnote/presentation/common/empty_state.dart';
import 'package:vocabnote/presentation/common/settings_action.dart';
import 'package:vocabnote/presentation/design/section.dart';
import 'package:vocabnote/presentation/overview/overview_charts.dart';
import 'package:vocabnote/presentation/overview/overview_stats.dart';
import 'package:vocabnote/presentation/words/word_tile.dart';

/// The app's home: the shape of the user's words and practice, then a few of
/// the words themselves (`docs/UI-UX.md` §4.1).
///
/// The full list is a tap away on [Routes.wordsAll], with search, filters and
/// sort. Those narrow a list, so they live with it rather than here.
class OverviewScreen extends ConsumerWidget {
  /// Creates the overview.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final total = ref.watch(totalWordCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.wordsTitle),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: l10n.wordsSearchLabel,
            onPressed: () => context.push(Routes.wordsSearch),
          ),
          const SettingsAction(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        // The shell is an indexed stack, so every branch's FAB is in the tree
        // at once and the default hero tag collides. The route path is already
        // unique per branch.
        heroTag: Routes.words,
        onPressed: () => context.push(Routes.wordAdd),
        icon: const Icon(Icons.add),
        label: Text(l10n.addWordAction),
      ),
      body: total.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => EmptyState(
          icon: Icons.error_outline,
          title: l10n.wordsLoadFailedTitle,
          body: l10n.wordsLoadFailedBody,
          actionLabel: l10n.retryAction,
          onAction: () => ref.invalidate(totalWordCountProvider),
        ),
        data: (count) => count == 0
            // The first-run state. Teaches the feature rather than apologising.
            ? EmptyState(
                icon: Icons.auto_stories_outlined,
                title: l10n.emptyWordsTitle,
                body: l10n.emptyWordsBody,
                actionLabel: l10n.emptyWordsAction,
                onAction: () => context.push(Routes.wordAdd),
                secondaryLabel: l10n.emptyWordsGuide,
                onSecondary: () => context.push(Routes.guide),
              )
            : _Overview(total: count),
      ),
    );
  }
}

class _Overview extends ConsumerWidget {
  const new({required this.total});

  final int total;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final metrics = context.metrics;
    final overview = ref.watch(wordOverviewProvider).value;
    final lists =
        ref.watch(listSummariesProvider).value ?? const <WordListSummary>[];

    // Not a lazy list: the page is a fixed handful of blocks, whoever's
    // library it describes.
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        metrics.spaceLg,
        metrics.spaceSm,
        metrics.spaceLg,
        // Room for the FAB not to cover the last card.
        metrics.fabClearance,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          OverviewHero(total: total, addedThisWeek: overview?.addedThisWeek),
          const OverviewStats(),
          if (overview case final WordOverview loaded) ...<Widget>[
            VnSection(
              heading: l10n.overviewStagesTitle,
              child: StageChart(stages: loaded.stages),
            ),
            VnSection(
              heading: l10n.overviewActivityTitle,
              child: ActivityChart(overview: loaded),
            ),
          ],
          if (lists.any((s) => s.wordCount > 0))
            VnSection(
              heading: l10n.overviewTopListsTitle,
              child: TopListsChart(lists: lists),
            ),
          VnSection(
            heading: l10n.overviewRecentTitle,
            padded: false,
            child: const _RecentWords(),
          ),
        ],
      ),
    );
  }
}

/// A few words, then the way to all of them.
class _RecentWords extends ConsumerWidget {
  const new();

  void _delete(WidgetRef ref, WordListEntry entry, BuildContext context) {
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final actions = ref.read(wordActionsProvider.notifier);

    unawaited(
      actions.delete(entry.word.id).then((result) {
        if (result.isErr) return;
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(l10n.wordDeletedSnack(entry.word.headword.value)),
              action: SnackBarAction(
                label: l10n.undoAction,
                onPressed: () => unawaited(actions.restore(entry.word.id)),
              ),
            ),
          );
      }),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final words =
        ref.watch(recentWordsProvider).value ?? const <WordListEntry>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (final entry in words)
          WordTile(
            key: ValueKey<String>(entry.word.id),
            entry: entry,
            onTap: () => context.push(Routes.wordDetailOf(entry.word.id)),
            onToggleFavourite: () => unawaited(
              ref
                  .read(wordActionsProvider.notifier)
                  .setFavourite(
                    entry.word.id,
                    isFavourite: !entry.word.isFavourite,
                  ),
            ),
            onDelete: () => _delete(ref, entry, context),
          ),
        OutlinedButton(
          onPressed: () => context.push(Routes.wordsAll),
          child: Text(l10n.overviewSeeAll),
        ),
      ],
    );
  }
}
