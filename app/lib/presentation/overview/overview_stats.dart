import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vocabnote/application/practice/practice_hub_controller.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/router/routes.dart';
import 'package:vocabnote/core/theme/app_metrics.dart';
import 'package:vocabnote/presentation/design/gap.dart';

/// The total, as the page's one big number.
class OverviewHero extends StatelessWidget {
  /// Creates the headline for [total] words.
  const new({required this.total, required this.addedThisWeek, super.key});

  /// How many live words there are.
  final int total;

  /// How many are new this week, or null while that loads.
  final int? addedThisWeek;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final metrics = context.metrics;
    final added = addedThisWeek ?? 0;

    return Padding(
      padding: EdgeInsets.only(bottom: metrics.spaceLg),
      child: Semantics(
        container: true,
        child: Wrap(
          spacing: metrics.spaceSm,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: <Widget>[
            Text('$total', style: theme.textTheme.displayMedium),
            Text(
              l10n.overviewWordCountLabel(total),
              style: theme.textTheme.titleMedium,
            ),
            if (added > 0)
              Text(
                l10n.overviewAddedThisWeek(added),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Up to four numbers, each only when it has something true to say: a streak
/// of zero is never shown (`docs/RULES.md` §6), and a share of no answers is
/// not a number.
class OverviewStats extends ConsumerWidget {
  /// Creates the tiles.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final metrics = context.metrics;
    final due = ref.watch(dueCardCountProvider).value ?? 0;
    final progress = ref.watch(practiceProgressProvider).value;
    final share = ref.watch(wordOverviewProvider).value?.rememberedShare;
    final streak = progress?.streak ?? 0;

    final tiles = <Widget>[
      _StatTile(
        icon: Icons.schedule,
        value: '$due',
        label: l10n.overviewDueLabel,
        onTap: () => context.go(Routes.practice),
      ),
      _StatTile(
        icon: Icons.today_outlined,
        value: '${progress?.wordsToday ?? 0}',
        label: l10n.overviewTodayLabel,
      ),
      if (streak > 0)
        _StatTile(
          icon: Icons.local_fire_department_outlined,
          value: '$streak',
          label: l10n.overviewStreakLabel,
        ),
      if (share != null)
        _StatTile(
          icon: Icons.check_circle_outline,
          value: l10n.overviewRememberedValue((share * 100).round()),
          label: l10n.overviewRememberedLabel,
        ),
    ];

    return Padding(
      padding: EdgeInsets.only(bottom: metrics.spaceLg),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Two across on a phone; one when large text would crush them, so
          // the width follows the text as the lists used to.
          final scale = MediaQuery.textScalerOf(context).scale(1);
          final gap = metrics.spaceSm;
          final twoAcross = (constraints.maxWidth - gap) / 2;
          final width = twoAcross >= metrics.spaceXxl * 4 * scale
              ? twoAcross
              : constraints.maxWidth;

          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: <Widget>[
              for (final tile in tiles) SizedBox(width: width, child: tile),
            ],
          );
        },
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const new({
    required this.icon,
    required this.value,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metrics = context.metrics;

    // Merged around the ink, so a tile that opens something is one button
    // that says what it is.
    return MergeSemantics(
      child: Material(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: metrics.cardBorder,
        child: InkWell(
          onTap: onTap,
          borderRadius: metrics.cardBorder,
          child: Padding(
            padding: EdgeInsets.all(metrics.spaceMd),
            child: Row(
              children: <Widget>[
                Icon(icon, color: theme.colorScheme.onSurfaceVariant),
                const VnGap(VnSpace.sm, axis: Axis.horizontal),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(value, style: theme.textTheme.titleLarge),
                      Text(
                        label,
                        style: theme.textTheme.bodySmall?.copyWith(
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
      ),
    );
  }
}
