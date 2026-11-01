import 'package:flutter/material.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/theme/app_metrics.dart';
import 'package:vocabnote/core/theme/ipa_palette.dart';
import 'package:vocabnote/domain/entities/word_list.dart';

/// One row on the Lists tab (`docs/UI-UX.md` §4.5, F-042).
///
/// A row rather than the card it replaced: an imported deck can hold dozens of
/// lists, and two cards to a screen line made those a long scroll. The list's
/// colour stays, as a dot.
class ListRow extends StatelessWidget {
  /// Creates a row for [summary].
  const new({
    required this.summary,
    required this.onTap,
    required this.onLongPress,
    this.onActions,
    this.selected,
    super.key,
  });

  /// The list and its counts.
  final WordListSummary summary;

  /// Opens the list, or toggles it while selecting.
  final VoidCallback onTap;

  /// Starts selecting. The app bar's *Select lists* does the same, so this is
  /// never the only way (`docs/UI-UX.md` §1).
  final VoidCallback onLongPress;

  /// Opens rename, recolour and delete. Null hides the button while selecting.
  final VoidCallback? onActions;

  /// Whether the row is ticked, or null when not selecting.
  final bool? selected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final metrics = context.metrics;
    final colors = context.ipaPalette.resolve(summary.list.color);
    final words = l10n.listWordCount(summary.wordCount);

    return ListTile(
      onTap: onTap,
      onLongPress: onLongPress,
      contentPadding: EdgeInsets.only(left: metrics.spaceSm),
      visualDensity: VisualDensity.compact,
      leading: switch (selected) {
        final bool ticked => Checkbox(value: ticked, onChanged: (_) => onTap()),
        null => Padding(
          padding: EdgeInsets.all(metrics.spaceSm),
          child: ExcludeSemantics(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.line,
                shape: BoxShape.circle,
              ),
              child: SizedBox.square(dimension: metrics.spaceMd),
            ),
          ),
        ),
      },
      title: Text(
        summary.list.name,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        summary.dueCount > 0
            ? l10n.listRowCounts(words, l10n.listDueCount(summary.dueCount))
            : words,
      ),
      trailing: onActions == null
          ? null
          : IconButton(
              icon: const Icon(Icons.more_vert),
              tooltip: l10n.listActionsLabel(summary.list.name),
              onPressed: onActions,
            ),
    );
  }
}
