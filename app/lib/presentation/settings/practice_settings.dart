import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabnote/application/practice/scheduler/review_schedule.dart';
import 'package:vocabnote/application/settings/reminder_controller.dart';
import 'package:vocabnote/application/settings/settings_actions.dart';
import 'package:vocabnote/application/settings/settings_controller.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/theme/app_metrics.dart';
import 'package:vocabnote/domain/entities/practice_session.dart';
import 'package:vocabnote/domain/repositories/reminder_service.dart';
import 'package:vocabnote/presentation/practice/mix_options.dart';
import 'package:vocabnote/presentation/settings/interval_editor_sheet.dart';
import 'package:vocabnote/presentation/settings/settings_tiles.dart';

/// The reminder's words, in the user's language.
ReminderCopy reminderCopyOf(AppL10n l10n) => ReminderCopy(
  title: l10n.reminderNotificationTitle,
  body: l10n.reminderNotificationBody,
  channelName: l10n.reminderChannelName,
  channelDescription: l10n.reminderChannelDescription,
);

/// Practice: goal, card side, the daily reminder (F-066), and the repetition
/// schedule (`docs/GAMES.md` §5).
class PracticeSettings extends ConsumerWidget {
  /// Creates the section.
  const new({super.key});

  /// The goals offered. A stored goal outside these (from a backup, say) is
  /// added to the list rather than silently replaced.
  static const List<int> _goals = <int>[5, 10, 15, 20, 30, 40, 50];

  /// The in-session repeats offered for a missed card.
  static const List<int> _repeats = <int>[0, 1, 2, 3];

  static List<int> _withCurrent(List<int> offered, int current) =>
      <int>{...offered, current}.toList()..sort();

  Future<void> _enableReminder(BuildContext context, WidgetRef ref) async {
    // Read before the await - a WidgetRef is only good for its build.
    final actions = ref.read(reminderActionsProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppL10n.of(context);

    final outcome = await actions.enable(reminderCopyOf(l10n));
    // Said plainly and once. A refusal is the user's decision, or their
    // phone's; nothing here argues with it.
    switch (outcome) {
      case ReminderOutcome.on:
        break;
      case ReminderOutcome.denied:
        messenger.showSnackBar(SnackBar(content: Text(l10n.reminderDenied)));
      case ReminderOutcome.failed:
        messenger.showSnackBar(SnackBar(content: Text(l10n.reminderFailed)));
    }
  }

  Future<void> _pickTime(
    BuildContext context,
    WidgetRef ref,
    TimeOfDay current,
  ) async {
    final actions = ref.read(reminderActionsProvider.notifier);
    final copy = reminderCopyOf(AppL10n.of(context));
    final picked = await showTimePicker(context: context, initialTime: current);
    if (picked == null) return;
    await actions.setTime(picked.hour * 60 + picked.minute, copy);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final settings = ref.watch(appSettingsOrDefaultsProvider);
    final schedule = ReviewSchedule.fromStoredJson(settings.reviewScheduleJson);
    final minutes =
        settings.reminderTimeMinutes ?? ReminderActions.defaultMinutes;
    final time = TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
    final timeText = time.format(context);

    SettingsActions actions() => ref.read(settingsActionsProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SettingsHeader(l10n.settingsPracticeSection),
        SettingsChoiceTile<int>(
          title: l10n.settingsDailyGoal,
          value: settings.dailyGoal,
          options: _withCurrent(_goals, settings.dailyGoal),
          labelOf: l10n.settingsDailyGoalValue,
          onChanged: (goal) => unawaited(actions().setDailyGoal(goal)),
        ),
        SettingsChoiceTile<PromptSide>(
          title: l10n.settingsPromptSide,
          value: settings.promptSide,
          options: PromptSide.values,
          labelOf: (side) => promptSideLabel(l10n, side),
          onChanged: (side) => unawaited(actions().setPromptSide(side)),
        ),
        if (settings.promptSide == PromptSide.mix)
          Padding(
            padding: EdgeInsets.fromLTRB(
              context.metrics.spaceLg,
              0,
              context.metrics.spaceLg,
              context.metrics.spaceMd,
            ),
            child: MixOptions(
              sides: settings.mixSides,
              order: settings.mixOrder,
              onSidesChanged: (sides) =>
                  unawaited(actions().setMixSides(sides)),
              onOrderChanged: (order) =>
                  unawaited(actions().setMixOrder(order)),
            ),
          ),
        SwitchListTile(
          title: Text(l10n.reminderTitle),
          subtitle: Text(
            settings.reminderEnabled
                ? l10n.reminderOnAt(timeText)
                : l10n.reminderOff,
          ),
          value: settings.reminderEnabled,
          onChanged: (on) => unawaited(
            on
                ? _enableReminder(context, ref)
                : ref.read(reminderActionsProvider.notifier).disable(),
          ),
        ),
        if (settings.reminderEnabled)
          ListTile(
            title: Text(l10n.reminderTimeLabel),
            trailing: Text(timeText),
            onTap: () => unawaited(_pickTime(context, ref, time)),
          ),
        SettingsChoiceTile<IntervalPace?>(
          title: l10n.settingsPace,
          value: schedule.pace,
          options: IntervalPace.values,
          labelOf: (pace) => switch (pace) {
            IntervalPace.gentle => l10n.paceGentle,
            IntervalPace.standard => l10n.paceStandard,
            IntervalPace.intensive => l10n.paceIntensive,
            null => l10n.paceCustom,
          },
          hintOf: (pace) => switch (pace) {
            IntervalPace.gentle => l10n.paceGentleHint,
            IntervalPace.standard => l10n.paceStandardHint,
            IntervalPace.intensive => l10n.paceIntensiveHint,
            null => null,
          },
          onChanged: (pace) {
            if (pace != null) unawaited(actions().setPace(pace));
          },
        ),
        ListTile(
          title: Text(l10n.settingsIntervals),
          subtitle: Text(
            l10n.settingsIntervalsValue(
              schedule.intervalDays.skip(1).join(l10n.listSeparator),
            ),
          ),
          onTap: () => unawaited(IntervalEditorSheet.show(context, schedule)),
        ),
        SettingsChoiceTile<int>(
          title: l10n.settingsRepeats,
          value: settings.againRepeats,
          options: _withCurrent(_repeats, settings.againRepeats),
          labelOf: l10n.settingsRepeatsValue,
          onChanged: (repeats) => unawaited(actions().setAgainRepeats(repeats)),
        ),
      ],
    );
  }
}
