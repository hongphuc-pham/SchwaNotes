import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vocabnote/application/lists/list_actions_controller.dart';
import 'package:vocabnote/application/lists/list_controller.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/router/routes.dart';
import 'package:vocabnote/core/theme/app_metrics.dart';
import 'package:vocabnote/domain/entities/word_list.dart';
import 'package:vocabnote/presentation/common/empty_state.dart';
import 'package:vocabnote/presentation/common/settings_action.dart';
import 'package:vocabnote/presentation/design/section.dart';
import 'package:vocabnote/presentation/lists/list_editor_sheet.dart';
import 'package:vocabnote/presentation/lists/list_row.dart';

/// The Lists tab: lists A-Z, then the tags (`docs/UI-UX.md` §4.5, F-042).
///
/// Selecting several lists turns them into tags in one go, which is what a
/// library imported before tags existed needs: there, every tag is a list.
class ListsScreen extends ConsumerStatefulWidget {
  /// Creates the lists screen.
  const new({super.key});

  @override
  ConsumerState<ListsScreen> createState() => _ListsScreenState();
}

class _ListsScreenState extends ConsumerState<ListsScreen> {
  /// The ticked lists, or null when not selecting.
  Set<String>? _selected;

  void _toggle(String id) {
    setState(() {
      final selected = _selected ??= <String>{};
      if (!selected.remove(id)) selected.add(id);
    });
  }

  void _stopSelecting() => setState(() => _selected = null);

  Future<void> _create() async {
    // The notifier is read *before* the await, not after: this runs unawaited,
    // so a throw from a stale `ref` would be swallowed and the list silently
    // never created.
    final actions = ref.read(listActionsProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    final failedMessage = AppL10n.of(context).listSaveFailed;
    final draft = await ListEditorSheet.show(context);
    if (draft == null) return;

    final result = await actions.create(name: draft.name, color: draft.color);
    // Never swallow the Result. A create that fails silently looks exactly
    // like a create that never happened, which is how this went unnoticed
    // until a widget test asked the database whether the row existed.
    if (result.isErr) {
      messenger.showSnackBar(SnackBar(content: Text(failedMessage)));
    }
  }

  Future<void> _makeTags() async {
    final ids = _selected?.toList() ?? const <String>[];
    if (ids.isEmpty) return;
    final l10n = AppL10n.of(context);
    final actions = ref.read(listActionsProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);

    // Confirmed, because there is no way back: a tag cannot become a list.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.listsMakeTagsTitle(ids.length)),
        content: Text(l10n.listsMakeTagsBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.listsMakeTagsAction),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false)) return;

    final result = await actions.makeTags(ids);
    if (mounted && result.isOk) _stopSelecting();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          result.isOk
              ? l10n.listsMadeTagsSnack(ids.length)
              : l10n.listSaveFailed,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final lists = ref.watch(listSummariesProvider);
    final tags =
        ref.watch(tagSummariesProvider).value ?? const <WordListSummary>[];
    final selected = _selected;
    final all = lists.value ?? const <WordListSummary>[];

    return PopScope(
      // Back leaves selection before it leaves anything else.
      canPop: selected == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _stopSelecting();
      },
      child: Scaffold(
        appBar: selected == null
            ? AppBar(
                title: Text(l10n.listsTitle),
                actions: <Widget>[
                  if (all.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.checklist),
                      tooltip: l10n.listsSelectAction,
                      onPressed: () => setState(() => _selected = <String>{}),
                    ),
                  const SettingsAction(),
                ],
              )
            : AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: l10n.listsCancelSelection,
                  onPressed: _stopSelecting,
                ),
                title: Text(l10n.listsSelectedCount(selected.length)),
                actions: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.select_all),
                    tooltip: l10n.listsSelectAll,
                    onPressed: () => setState(
                      () => _selected = <String>{
                        for (final summary in all) summary.list.id,
                      },
                    ),
                  ),
                ],
              ),
        floatingActionButton: selected == null
            ? FloatingActionButton.extended(
                // Unique per branch - see the note on the overview's FAB.
                heroTag: Routes.lists,
                onPressed: () => unawaited(_create()),
                icon: const Icon(Icons.add),
                label: Text(l10n.newListAction),
              )
            : selected.isEmpty
            ? null
            : FloatingActionButton.extended(
                heroTag: Routes.lists,
                onPressed: () => unawaited(_makeTags()),
                icon: const Icon(Icons.sell_outlined),
                label: Text(l10n.listsMakeTagsAction),
              ),
        body: lists.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => EmptyState(
            icon: Icons.error_outline,
            title: l10n.listsLoadFailedTitle,
            body: l10n.listsLoadFailedBody,
          ),
          data: (data) => data.isEmpty && tags.isEmpty
              ? EmptyState(
                  icon: Icons.folder_copy_outlined,
                  title: l10n.listsEmptyTitle,
                  body: l10n.listsEmptyBody,
                  actionLabel: l10n.newListAction,
                  onAction: () => unawaited(_create()),
                )
              : _Rows(
                  lists: data,
                  tags: tags,
                  selected: selected,
                  onToggle: _toggle,
                ),
        ),
      ),
    );
  }
}

/// The lists, then the tags. The tags step aside while selecting: only a list
/// can be selected.
class _Rows extends ConsumerWidget {
  const new({
    required this.lists,
    required this.tags,
    required this.selected,
    required this.onToggle,
  });

  final List<WordListSummary> lists;
  final List<WordListSummary> tags;
  final Set<String>? selected;
  final ValueChanged<String> onToggle;

  Future<void> _actions(
    BuildContext context,
    WidgetRef ref,
    WordList list,
  ) async {
    // Read before the first await - see the note on `_create`.
    final actions = ref.read(listActionsProvider.notifier);
    final chosen = await showModalBottomSheet<_ListAction>(
      context: context,
      builder: (context) {
        final l10n = AppL10n.of(context);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: Text(l10n.renameListAction),
                onTap: () => Navigator.of(context).pop(_ListAction.edit),
              ),
              ListTile(
                leading: const Icon(Icons.sell_outlined),
                title: Text(l10n.makeTagAction),
                onTap: () => Navigator.of(context).pop(_ListAction.makeTag),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(l10n.deleteListAction),
                onTap: () => Navigator.of(context).pop(_ListAction.delete),
              ),
            ],
          ),
        );
      },
    );
    if (!context.mounted || chosen == null) return;

    switch (chosen) {
      case _ListAction.edit:
        final draft = await ListEditorSheet.show(context, existing: list);
        if (draft == null) return;
        await actions.rename(list.copyWith(color: draft.color), draft.name);
      case _ListAction.delete:
        await _confirmDelete(context, actions, list);
      case _ListAction.makeTag:
        await actions.makeTag(list.id);
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ListActions actions,
    WordList list,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l10n = AppL10n.of(context);
        return AlertDialog(
          title: Text(l10n.deleteListTitle),
          // Says plainly that the words survive. Deleting a deck and deleting
          // a vocabulary look identical from the outside (F-042).
          content: Text(l10n.deleteListBody),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancelAction),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.deleteListAction),
            ),
          ],
        );
      },
    );
    if (confirmed ?? false) await actions.delete(list.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final metrics = context.metrics;
    final picked = selected;
    final showTags = picked == null && tags.isNotEmpty;

    return ListView.builder(
      padding: EdgeInsets.only(
        top: metrics.spaceSm,
        // Room for the FAB not to cover the last row.
        bottom: metrics.fabClearance,
      ),
      itemCount: lists.length + (showTags ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == lists.length) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              metrics.spaceLg,
              metrics.spaceLg,
              metrics.spaceLg,
              0,
            ),
            child: VnSection(
              heading: l10n.listsTagsTitle,
              padded: false,
              child: Wrap(
                spacing: metrics.spaceSm,
                children: <Widget>[
                  for (final tag in tags)
                    ActionChip(
                      label: Text(
                        l10n.tagChipLabel(tag.list.name, tag.wordCount),
                      ),
                      onPressed: () =>
                          context.push(Routes.listDetailOf(tag.list.id)),
                    ),
                ],
              ),
            ),
          );
        }

        final summary = lists[index];
        final id = summary.list.id;
        return ListRow(
          key: ValueKey<String>(id),
          summary: summary,
          selected: picked?.contains(id),
          onTap: picked == null
              ? () => context.push(Routes.listDetailOf(id))
              : () => onToggle(id),
          onLongPress: () => onToggle(id),
          onActions: picked == null
              ? () => unawaited(_actions(context, ref, summary.list))
              : null,
        );
      },
    );
  }
}

enum _ListAction { edit, delete, makeTag }
