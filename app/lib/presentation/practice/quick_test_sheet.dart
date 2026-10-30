import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabnote/application/lists/list_controller.dart';
import 'package:vocabnote/application/practice/game_contracts.dart';
import 'package:vocabnote/application/settings/settings_controller.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/theme/app_metrics.dart';
import 'package:vocabnote/domain/entities/practice_session.dart';
import 'package:vocabnote/domain/entities/word_list.dart';
import 'package:vocabnote/domain/repositories/practice_repository.dart';
import 'package:vocabnote/presentation/design/gap.dart';
import 'package:vocabnote/presentation/practice/mix_options.dart';

/// Configures a quick test (`docs/UI-UX.md` §4.6, F-062).
///
/// Source · size · prompt side · autoplay · Start. Everything the sheet can
/// produce is already capped at 30 by [GameConfig]'s constructor, so the *All*
/// chip advertising "max 30" is a description of the truth rather than a
/// promise the UI has to keep.
class QuickTestSheet extends ConsumerStatefulWidget {
  /// Creates the sheet.
  const new({required this.gameId, this.listId, super.key});

  /// Which game the test will run.
  final String gameId;

  /// Pre-selects a list, when opened from a list's *Practise this list*.
  final String? listId;

  /// Shows the sheet, resolving to a config or null if dismissed.
  static Future<GameConfig?> show(
    BuildContext context, {
    required String gameId,
    String? listId,
  }) {
    return showModalBottomSheet<GameConfig>(
      context: context,
      isScrollControlled: true,
      // A tall sheet otherwise grows under the status bar (UI-UX §6).
      useSafeArea: true,
      builder: (context) => QuickTestSheet(gameId: gameId, listId: listId),
    );
  }

  @override
  ConsumerState<QuickTestSheet> createState() => _QuickTestSheetState();
}

class _QuickTestSheetState extends ConsumerState<QuickTestSheet> {
  /// The sizes `UI-UX.md` §4.6 offers. Null is *All*, meaning "up to the cap".
  static const List<int?> _sizes = <int?>[5, 10, 20, null];

  late CardSourceKind _source = widget.listId == null
      ? CardSourceKind.all
      : CardSourceKind.list;
  late String? _listId = widget.listId;
  int? _size = 10;
  PromptSide _promptSide = PromptSide.wordFirst;
  // Starts from the user's settings; changing it here is for this test only.
  late Set<PromptSide> _mixSides = ref
      .read(appSettingsOrDefaultsProvider)
      .mixSides;
  late MixOrder _mixOrder = ref.read(appSettingsOrDefaultsProvider).mixOrder;
  bool _autoplay = true;

  void _start() {
    Navigator.of(context).pop(
      GameConfig(
        gameId: widget.gameId,
        mode: PracticeMode.quickTest,
        selection: CardSelection.random,
        limit: _size ?? PracticeRepository.quickTestMaxCards,
        source: _source,
        sourceId: _source == CardSourceKind.list ? _listId : null,
        promptSide: _promptSide,
        mixSides: _mixSides,
        mixOrder: _mixOrder,
        ttsAutoPlay: _autoplay,
        // Stored so a session can be replayed or debugged (`GAMES.md` §4).
        seed: Random().nextInt(1 << 31),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final metrics = context.metrics;
    final lists =
        ref.watch(listSummariesProvider).value ?? const <WordListSummary>[];

    return Padding(
      padding: EdgeInsets.only(
        left: metrics.spaceLg,
        right: metrics.spaceLg,
        top: metrics.spaceLg,
        bottom: MediaQuery.viewInsetsOf(context).bottom + metrics.spaceLg,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(l10n.quickTestTitle, style: theme.textTheme.titleLarge),
            const VnGap(VnSpace.lg),

            Text(l10n.quickTestSource, style: theme.textTheme.labelLarge),
            const VnGap(VnSpace.sm),
            Wrap(
              spacing: metrics.spaceSm,
              runSpacing: metrics.spaceSm,
              children: <Widget>[
                ChoiceChip(
                  label: Text(l10n.filterAll),
                  selected: _source == CardSourceKind.all,
                  onSelected: (_) =>
                      setState(() => _source = CardSourceKind.all),
                ),
                ChoiceChip(
                  label: Text(l10n.filterFavourites),
                  selected: _source == CardSourceKind.favourites,
                  onSelected: (_) =>
                      setState(() => _source = CardSourceKind.favourites),
                ),
                for (final summary in lists)
                  ChoiceChip(
                    label: Text(summary.list.name),
                    selected:
                        _source == CardSourceKind.list &&
                        _listId == summary.list.id,
                    onSelected: (_) => setState(() {
                      _source = CardSourceKind.list;
                      _listId = summary.list.id;
                    }),
                  ),
              ],
            ),
            const VnGap(VnSpace.lg),

            Text(l10n.quickTestSize, style: theme.textTheme.labelLarge),
            const VnGap(VnSpace.sm),
            Wrap(
              spacing: metrics.spaceSm,
              children: <Widget>[
                for (final size in _sizes)
                  ChoiceChip(
                    label: Text(
                      size == null
                          // Says the cap out loud rather than silently
                          // trimming a 200-word list to 30.
                          ? l10n.quickTestSizeAll(
                              PracticeRepository.quickTestMaxCards,
                            )
                          : '$size',
                    ),
                    selected: _size == size,
                    onSelected: (_) => setState(() => _size = size),
                  ),
              ],
            ),
            const VnGap(VnSpace.lg),

            Text(l10n.quickTestPromptSide, style: theme.textTheme.labelLarge),
            const VnGap(VnSpace.sm),
            Wrap(
              spacing: metrics.spaceSm,
              runSpacing: metrics.spaceSm,
              children: <Widget>[
                for (final side in PromptSide.values)
                  ChoiceChip(
                    label: Text(promptSideLabel(l10n, side)),
                    selected: _promptSide == side,
                    onSelected: (_) => setState(() => _promptSide = side),
                  ),
              ],
            ),
            if (_promptSide == PromptSide.mix) ...<Widget>[
              const VnGap(VnSpace.md),
              MixOptions(
                sides: _mixSides,
                order: _mixOrder,
                onSidesChanged: (sides) => setState(() => _mixSides = sides),
                onOrderChanged: (order) => setState(() => _mixOrder = order),
              ),
            ],
            const VnGap(VnSpace.sm),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.quickTestAutoplay),
              value: _autoplay,
              onChanged: (value) => setState(() => _autoplay = value),
            ),
            const VnGap(VnSpace.sm),

            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: _start,
                child: Text(l10n.quickTestStart),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
