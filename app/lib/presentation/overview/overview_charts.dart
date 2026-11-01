import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/theme/app_metrics.dart';
import 'package:vocabnote/domain/entities/word_list.dart';
import 'package:vocabnote/domain/entities/word_overview.dart';
import 'package:vocabnote/presentation/design/gap.dart';
import 'package:vocabnote/presentation/design/section.dart';

/// The charts on the overview. Drawn with plain widgets: one hue from the
/// theme, so they follow light and dark, and no chart package for three bars
/// (`docs/RULES.md` §18).

/// How many lists [TopListsChart] compares.
const int _topListCount = 5;

/// The stages' place on one light-to-dark ramp of the primary colour. The
/// stages are ordered, so a ramp says so where separate hues would not.
const Map<KnowledgeStage, double> _stageStrength = <KnowledgeStage, double>{
  KnowledgeStage.fresh: 0.45,
  KnowledgeStage.learning: 0.6,
  KnowledgeStage.familiar: 0.8,
  KnowledgeStage.strong: 1,
};

/// Words by stage, as one segmented bar with a legend that carries the counts.
class StageChart extends StatelessWidget {
  /// Creates the chart.
  const new({required this.stages, super.key});

  /// Words at each stage.
  final Map<KnowledgeStage, int> stages;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final metrics = context.metrics;

    Color colorOf(KnowledgeStage stage) =>
        theme.colorScheme.primary.withValues(alpha: _stageStrength[stage]);

    String labelOf(KnowledgeStage stage) => switch (stage) {
      KnowledgeStage.fresh => l10n.stageFresh,
      KnowledgeStage.learning => l10n.stageLearning,
      KnowledgeStage.familiar => l10n.stageFamiliar,
      KnowledgeStage.strong => l10n.stageStrong,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // The legend says all of this in words, so the bar stays silent.
        ExcludeSemantics(
          child: ClipRRect(
            borderRadius: metrics.chipBorder,
            child: SizedBox(
              height: metrics.spaceLg,
              child: Row(
                // A ColoredBox has no height of its own: without stretch every
                // segment is zero pixels tall.
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: metrics.spaceXs / 2,
                children: <Widget>[
                  for (final stage in KnowledgeStage.values)
                    if ((stages[stage] ?? 0) > 0)
                      Expanded(
                        flex: stages[stage]!,
                        child: ColoredBox(color: colorOf(stage)),
                      ),
                ],
              ),
            ),
          ),
        ),
        const VnGap(VnSpace.sm),
        Wrap(
          spacing: metrics.spaceLg,
          runSpacing: metrics.spaceXs,
          children: <Widget>[
            for (final stage in KnowledgeStage.values)
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: metrics.spaceXs,
                children: <Widget>[
                  ExcludeSemantics(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colorOf(stage),
                        borderRadius: BorderRadius.circular(metrics.spaceXs),
                      ),
                      child: SizedBox.square(dimension: metrics.spaceMd),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      '${labelOf(stage)} ${stages[stage] ?? 0}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
          ],
        ),
        const VnGap(VnSpace.xs),
        VnQuietText(l10n.overviewStagesHint),
      ],
    );
  }
}

/// Answers per day, oldest on the left and today on the right.
class ActivityChart extends StatelessWidget {
  /// Creates the chart.
  const new({required this.overview, super.key});

  /// The days to draw.
  final WordOverview overview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final metrics = context.metrics;
    if (overview.answers == 0) {
      return VnQuietText(
        l10n.overviewActivityEmpty,
        emphasis: VnQuietEmphasis.body,
      );
    }

    final dates = DateFormat.MMMd(
      Localizations.localeOf(context).toLanguageTag(),
    );
    final peak = overview.busiestDay;
    final summary = l10n.overviewActivitySummary(overview.answers);
    final busiest = l10n.overviewActivityPeak(peak);

    return Semantics(
      container: true,
      label: '$summary. $busiest.',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              height: metrics.spaceXxl * 3,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: metrics.spaceXs / 2,
                children: <Widget>[
                  for (final day in overview.days)
                    Expanded(
                      child: Tooltip(
                        message: l10n.overviewDayAnswers(
                          dates.format(day.date),
                          day.answers,
                        ),
                        child: _DayBar(share: day.answers / peak),
                      ),
                    ),
                ],
              ),
            ),
            const VnGap(VnSpace.xs),
            // A Wrap: at large text the two dates can outgrow one line.
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              children: <Widget>[
                VnQuietText(dates.format(overview.days.first.date)),
                VnQuietText(l10n.overviewToday),
              ],
            ),
            const VnGap(VnSpace.xs),
            Text('$summary · $busiest', style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

/// A day with no answers, as a share of the chart's height: a hairline, so it
/// still reads as a day.
const double _emptyDayShare = 0.02;

/// One day: a rounded bar on the baseline, or a hairline for no answers.
class _DayBar extends StatelessWidget {
  const new({required this.share});

  /// This day's height as a share of the busiest day's.
  final double share;

  @override
  Widget build(BuildContext context) {
    final metrics = context.metrics;
    final scheme = Theme.of(context).colorScheme;
    final corner = Radius.circular(metrics.spaceXs);

    return Align(
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: math.max(share, _emptyDayShare),
        widthFactor: 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: share > 0 ? scheme.primary : scheme.outlineVariant,
            borderRadius: BorderRadius.only(topLeft: corner, topRight: corner),
          ),
        ),
      ),
    );
  }
}

/// The lists with the most words, biggest first.
class TopListsChart extends StatelessWidget {
  /// Creates the chart from every list; it picks the biggest itself.
  const new({required this.lists, super.key});

  /// Every list.
  final List<WordListSummary> lists;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metrics = context.metrics;
    final top = lists.where((s) => s.wordCount > 0).toList()
      ..sort((a, b) => b.wordCount.compareTo(a.wordCount));
    final shown = top.take(_topListCount).toList();
    final biggest = shown.first.wordCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (final summary in shown)
          Padding(
            padding: EdgeInsets.symmetric(vertical: metrics.spaceXs),
            child: MergeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          summary.list.name,
                          style: theme.textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const VnGap(VnSpace.sm, axis: Axis.horizontal),
                      Text(
                        '${summary.wordCount}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const VnGap(VnSpace.xs),
                  ExcludeSemantics(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(metrics.spaceXs),
                      child: LinearProgressIndicator(
                        value: summary.wordCount / biggest,
                        minHeight: metrics.spaceXs,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
