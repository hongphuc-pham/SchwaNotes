import 'package:flutter/material.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/theme/app_metrics.dart';
import 'package:vocabnote/domain/entities/practice_session.dart';
import 'package:vocabnote/presentation/design/gap.dart';

/// The label for a card face, wherever the user chooses one.
String promptSideLabel(AppL10n l10n, PromptSide side) => switch (side) {
  PromptSide.wordFirst => l10n.promptSideWord,
  PromptSide.ipaFirst => l10n.promptSideIpa,
  PromptSide.meaningFirst => l10n.promptSideMeaning,
  PromptSide.mix => l10n.promptSideMix,
};

/// Which faces a [PromptSide.mix] draws from, and in what order.
///
/// Shared by Settings and the quick-test sheet so the two cannot drift. A chip
/// that would leave fewer than [PromptSide.minMixSides] ticked is disabled
/// rather than accepted and silently reset.
class MixOptions extends StatelessWidget {
  /// Creates the options.
  const new({
    required this.sides,
    required this.order,
    required this.onSidesChanged,
    required this.onOrderChanged,
    super.key,
  });

  /// The ticked faces.
  final Set<PromptSide> sides;

  /// Random or take turns.
  final MixOrder order;

  /// Called with the new set of ticked faces.
  final ValueChanged<Set<PromptSide>> onSidesChanged;

  /// Called with the new order.
  final ValueChanged<MixOrder> onOrderChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final metrics = context.metrics;
    final atMinimum = sides.length <= PromptSide.minMixSides;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(l10n.mixSidesLabel, style: theme.textTheme.labelLarge),
        const VnGap(VnSpace.sm),
        Wrap(
          spacing: metrics.spaceSm,
          runSpacing: metrics.spaceSm,
          children: <Widget>[
            for (final side in PromptSide.mixableSides)
              FilterChip(
                label: Text(promptSideLabel(l10n, side)),
                selected: sides.contains(side),
                onSelected: sides.contains(side) && atMinimum
                    ? null
                    : (on) => onSidesChanged(<PromptSide>{
                        for (final s in sides)
                          if (s != side) s,
                        if (on) side,
                      }),
              ),
          ],
        ),
        if (atMinimum) ...<Widget>[
          const VnGap(VnSpace.xs),
          Text(l10n.mixSidesHint, style: theme.textTheme.bodySmall),
        ],
        const VnGap(VnSpace.md),
        Text(l10n.mixOrderLabel, style: theme.textTheme.labelLarge),
        const VnGap(VnSpace.sm),
        Wrap(
          spacing: metrics.spaceSm,
          runSpacing: metrics.spaceSm,
          children: <Widget>[
            for (final value in MixOrder.values)
              ChoiceChip(
                label: Text(switch (value) {
                  MixOrder.random => l10n.mixOrderRandom,
                  MixOrder.rotate => l10n.mixOrderRotate,
                }),
                selected: order == value,
                onSelected: (_) => onOrderChanged(value),
              ),
          ],
        ),
      ],
    );
  }
}
