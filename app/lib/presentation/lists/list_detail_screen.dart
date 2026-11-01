import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vocabnote/application/lists/list_actions_controller.dart';
import 'package:vocabnote/application/lists/list_controller.dart';
import 'package:vocabnote/application/words/word_actions_controller.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/router/routes.dart';
import 'package:vocabnote/core/theme/app_metrics.dart';
import 'package:vocabnote/domain/entities/practice_session.dart';
import 'package:vocabnote/domain/entities/word_list.dart';
import 'package:vocabnote/domain/repositories/word_repository.dart';
import 'package:vocabnote/presentation/common/empty_state.dart';
import 'package:vocabnote/presentation/lists/list_editor_sheet.dart';
import 'package:vocabnote/presentation/practice/game_registry_provider.dart';
import 'package:vocabnote/presentation/practice/quick_test_sheet.dart';
import 'package:vocabnote/presentation/words/word_tile.dart';

/// One list's words (`docs/UI-UX.md` §4.5, F-042).
///
/// "Detail = a filtered Words screen with **Practise this list** in the app
/// bar." It reads a family provider rather than the words tab's global query,
/// so opening a list does not disturb the filter the user left there — going
/// back finds that tab exactly as it was.
class ListDetailScreen extends ConsumerWidget {
  /// Creates the screen for [listId].
  const new({required this.listId, super.key});

  /// Which list to show.
  final String listId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final list = ref.watch(listByIdProvider(listId));
    final words = ref.watch(wordsInListProvider(listId));

    return Scaffold(
      appBar: AppBar(
        title: Text(list.value?.name ?? l10n.listsTitle),
        actions: <Widget>[
          _PractiseAction(
            listId: listId,
            hasWords: words.value?.isNotEmpty ?? false,
          ),
          if (list.value case final WordList tag when tag.kind == ListKind.tag)
            _TagMenu(tag: tag),
        ],
      ),
      body: words.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => EmptyState(
          icon: Icons.error_outline,
          title: l10n.wordsLoadFailedTitle,
          body: l10n.wordsLoadFailedBody,
        ),
        data: (entries) => entries.isEmpty
            ? EmptyState(
                icon: Icons.folder_open_outlined,
                title: l10n.listEmptyTitle,
                body: l10n.listEmptyBody,
              )
            : _Words(entries: entries),
      ),
    );
  }
}

/// Renaming and deleting a tag. A list has these on its card; a tag has no
/// card.
class _TagMenu extends ConsumerWidget {
  const new({required this.tag});

  final WordList tag;

  Future<void> _rename(BuildContext context, ListActions actions) async {
    final draft = await ListEditorSheet.show(context, existing: tag);
    if (draft == null) return;
    await actions.rename(tag.copyWith(color: draft.color), draft.name);
  }

  Future<void> _delete(BuildContext context, ListActions actions) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l10n = AppL10n.of(context);
        return AlertDialog(
          title: Text(l10n.deleteTagTitle),
          content: Text(l10n.deleteTagBody),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancelAction),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.deleteTagAction),
            ),
          ],
        );
      },
    );
    if (!(confirmed ?? false)) return;
    await actions.delete(tag.id);
    if (context.mounted) context.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    return MenuAnchor(
      builder: (context, controller, _) => IconButton(
        icon: const Icon(Icons.more_vert),
        tooltip: MaterialLocalizations.of(context).showMenuTooltip,
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
      ),
      menuChildren: <Widget>[
        MenuItemButton(
          leadingIcon: const Icon(Icons.edit_outlined),
          onPressed: () => unawaited(
            _rename(context, ref.read(listActionsProvider.notifier)),
          ),
          child: Text(l10n.renameListAction),
        ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.delete_outline),
          onPressed: () => unawaited(
            _delete(context, ref.read(listActionsProvider.notifier)),
          ),
          child: Text(l10n.deleteTagAction),
        ),
      ],
    );
  }
}

class _Words extends ConsumerWidget {
  const new({required this.entries});

  final List<WordListEntry> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = context.metrics;

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        metrics.spaceLg,
        metrics.spaceSm,
        metrics.spaceLg,
        metrics.spaceXl,
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
        );
      },
    );
  }
}

/// *Practise this list*: as text while it leaves the title room, and as an
/// icon with the same tooltip once it would not.
///
/// At 200% text on 320dp the text button took the whole app bar and the list's
/// name vanished (found on the emulator). So it never takes more than half.
class _PractiseAction extends ConsumerWidget {
  const new({required this.listId, required this.hasWords});

  final String listId;
  final bool hasWords;

  /// Opens the quick test here, with this list chosen, rather than going by
  /// the Practice tab: that tab is a branch of the shell, and pushing a shell
  /// route from above the shell leaves a blank page and tabs that no longer
  /// switch.
  Future<void> _practise(BuildContext context, WidgetRef ref) async {
    final descriptor = ref
        .read(gameRegistryProvider)
        .games
        .map((game) => game.descriptor)
        .firstWhere((d) => d.supportedModes.contains(PracticeMode.quickTest));
    final config = await QuickTestSheet.show(
      context,
      gameId: descriptor.id,
      listId: listId,
    );
    if (config == null || !context.mounted) return;
    unawaited(context.push(Routes.practiceRunOf(descriptor.id), extra: config));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final label = AppL10n.of(context).practiseListAction;
    final painter = TextPainter(
      text: TextSpan(
        text: label,
        style: Theme.of(context).textTheme.labelLarge,
      ),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final fits = painter.width <= MediaQuery.sizeOf(context).width / 2;
    painter.dispose();

    final open = hasWords ? () => unawaited(_practise(context, ref)) : null;

    return fits
        ? TextButton(onPressed: open, child: Text(label))
        : IconButton(
            icon: const Icon(Icons.school_outlined),
            tooltip: label,
            onPressed: open,
          );
  }
}
