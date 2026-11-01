import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vocabnote/application/words/word_actions_controller.dart';
import 'package:vocabnote/application/words/word_list_controller.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/router/routes.dart';
import 'package:vocabnote/core/theme/app_metrics.dart';
import 'package:vocabnote/core/theme/tokens.dart';
import 'package:vocabnote/domain/repositories/word_query.dart';
import 'package:vocabnote/domain/repositories/word_repository.dart';
import 'package:vocabnote/presentation/common/empty_state.dart';
import 'package:vocabnote/presentation/common/settings_action.dart';
import 'package:vocabnote/presentation/words/word_filter_bar.dart';
import 'package:vocabnote/presentation/words/word_tile.dart';

/// Every word, opened from the overview (`docs/UI-UX.md` §4.1, F-040, F-041).
///
/// One primary action: **Add word**. Everything else - search, filters, sort -
/// narrows what is already there.
class WordsScreen extends ConsumerStatefulWidget {
  /// Creates the words screen.
  const new({this.startSearching = false, super.key});

  /// Whether to open with the search field ready, as the overview's search
  /// button does.
  final bool startSearching;

  @override
  ConsumerState<WordsScreen> createState() => _WordsScreenState();
}

class _WordsScreenState extends ConsumerState<WordsScreen> {
  final TextEditingController _search = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  late bool _searching = widget.startSearching;

  @override
  void initState() {
    super.initState();
    if (_searching) _searchFocus.requestFocus();
  }

  @override
  void dispose() {
    _search.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _openSearch() {
    setState(() => _searching = true);
    _searchFocus.requestFocus();
  }

  void _closeSearch() {
    setState(() => _searching = false);
    _search.clear();
    ref.read(wordListQueryProvider.notifier).setSearchTermNow('');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final words = ref.watch(wordListProvider);
    final query = ref.watch(wordListQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? _SearchField(
                controller: _search,
                focusNode: _searchFocus,
                onChanged: (term) => ref
                    .read(wordListQueryProvider.notifier)
                    .setSearchTerm(term),
              )
            : Text(l10n.allWordsTitle),
        actions: <Widget>[
          if (_searching)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: l10n.wordsCloseSearchLabel,
              onPressed: _closeSearch,
            )
          else ...<Widget>[
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: l10n.wordsSearchLabel,
              onPressed: _openSearch,
            ),
            const _SortMenu(),
            const SettingsAction(),
          ],
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(56),
          child: WordFilterBar(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        // The shell is an indexed stack, so every branch's FAB is in the tree
        // at once and the default hero tag collides. The route path is already
        // unique per branch.
        heroTag: Routes.wordsAll,
        onPressed: () => context.push(Routes.wordAdd),
        icon: const Icon(Icons.add),
        label: Text(l10n.addWordAction),
      ),
      body: words.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => EmptyState(
          icon: Icons.error_outline,
          title: l10n.wordsLoadFailedTitle,
          body: l10n.wordsLoadFailedBody,
          actionLabel: l10n.retryAction,
          onAction: () => ref.invalidate(wordListProvider),
        ),
        data: (entries) => entries.isEmpty
            ? _EmptyBody(query: query, onClear: _closeSearch)
            : _WordList(entries: entries),
      ),
    );
  }
}

/// The list itself, once there is something to show.
class _WordList extends ConsumerWidget {
  const new({required this.entries});

  final List<WordListEntry> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = context.metrics;

    // No separator: cards are told apart by tone and by the gap each one
    // carries, so a divider between them would be drawing the same boundary
    // twice. (The `Divider(indent: 16)` this replaces also hard-coded its
    // indent, which is exactly what RULES §22 forbids.)
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        metrics.spaceLg,
        metrics.spaceSm,
        metrics.spaceLg,
        // Room for the FAB not to cover the last card. `spaceXxl * 2` was 8dp
        // short of the FAB's footprint, so the last card never fully cleared.
        metrics.fabClearance,
      ),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return WordTile(
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
          onDelete: () => _deleteWithUndo(context, ref, entry),
        );
      },
    );
  }
}

/// Soft-deletes a word and offers Undo for five seconds (F-008).
///
/// The snackbar duration **is** the promise: `docs/RULES.md` §11 requires a
/// destructive action to have either Undo or a typed confirmation, and this is
/// the Undo. Nothing is actually destroyed either way - the row is flagged and
/// only purged after 30 days.
Future<void> _deleteWithUndo(
  BuildContext context,
  WidgetRef ref,
  WordListEntry entry,
) async {
  final l10n = AppL10n.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final actions = ref.read(wordActionsProvider.notifier);

  final result = await actions.delete(entry.word.id);
  if (result.isErr) return;

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(l10n.wordDeletedSnack(entry.word.headword.value)),
        duration: AppTiming.undoWindow,
        action: SnackBarAction(
          label: l10n.undoAction,
          onPressed: () => unawaited(actions.restore(entry.word.id)),
        ),
      ),
    );
}

/// Chooses which empty state to show.
///
/// Three different situations that look identical if you are careless: no words
/// at all, a filter that matches nothing, and a search that found nothing. Each
/// needs different copy and a different way out.
class _EmptyBody extends ConsumerWidget {
  const new({required this.query, required this.onClear});

  final WordQuery query;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final total = ref.watch(totalWordCountProvider).value ?? 0;

    if (query.isSearching) {
      return EmptyState(
        icon: Icons.search_off,
        title: l10n.emptySearchTitle,
        body: l10n.emptySearchBody(query.searchTerm!.trim()),
        actionLabel: l10n.emptyFilterClear,
        onAction: onClear,
      );
    }

    if (total > 0) {
      return EmptyState(
        icon: Icons.filter_alt_off_outlined,
        title: l10n.emptyFilterTitle,
        body: l10n.emptyFilterBody,
        actionLabel: l10n.emptyFilterClear,
        onAction: () => ref.read(wordListQueryProvider.notifier).reset(),
      );
    }

    // The first-run state. Teaches the feature rather than apologising.
    return EmptyState(
      icon: Icons.auto_stories_outlined,
      title: l10n.emptyWordsTitle,
      body: l10n.emptyWordsBody,
      actionLabel: l10n.emptyWordsAction,
      onAction: () => context.push(Routes.wordAdd),
      secondaryLabel: l10n.emptyWordsGuide,
      onSecondary: () => context.push(Routes.guide),
    );
  }
}

/// The inline search field that replaces the app bar title.
class _SearchField extends StatelessWidget {
  const new({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: l10n.wordsSearchHint,
        border: InputBorder.none,
      ),
      style: Theme.of(context).textTheme.titleMedium,
    );
  }
}

/// The sort menu (F-040).
class _SortMenu extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final current = ref.watch(wordListQueryProvider).sort;

    String labelFor(WordSort sort) => switch (sort) {
      WordSort.recent => l10n.sortRecent,
      WordSort.alphabetical => l10n.sortAlphabetical,
      WordSort.leastKnown => l10n.sortLeastKnown,
    };

    return PopupMenuButton<WordSort>(
      icon: const Icon(Icons.sort),
      tooltip: l10n.wordsSortLabel,
      initialValue: current,
      onSelected: (sort) =>
          ref.read(wordListQueryProvider.notifier).setSort(sort),
      itemBuilder: (context) => <PopupMenuEntry<WordSort>>[
        for (final sort in WordSort.values)
          PopupMenuItem<WordSort>(value: sort, child: Text(labelFor(sort))),
      ],
    );
  }
}
