/// The settings screen's write side (F-070, `docs/UI-UX.md` §4.9).
///
/// The daily reminder is not here: it has to ask the OS before it may write
/// anything, so it keeps its own controller (`reminder_controller.dart`).
library;

import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vocabnote/application/practice/scheduler/review_schedule.dart';
import 'package:vocabnote/application/repositories.dart';
import 'package:vocabnote/domain/entities/app_settings.dart';
import 'package:vocabnote/domain/entities/practice_session.dart';

part 'settings_actions.g.dart';

/// Changes one setting at a time.
///
/// Each change is a transform of the stored row, applied atomically by
/// `SettingsRepository.update`, so a slider released while a switch flips
/// cannot write back a stale copy of the other. Every screen watching
/// `appSettingsProvider` sees the result at once - nothing needs a restart.
@Riverpod(keepAlive: true)
class SettingsActions extends _$SettingsActions {
  @override
  void build() {}

  Future<void> _update(AppSettings Function(AppSettings current) change) =>
      ref.read(settingsRepositoryProvider).update(change);

  /// Light, dark, or follow the phone.
  Future<void> setTheme(ThemePreference theme) =>
      _update((s) => s.copyWith(themeMode: theme));

  /// Which English the voice speaks.
  Future<void> setVoice(TtsLocale locale) =>
      _update((s) => s.copyWith(ttsLocale: locale));

  /// Speech rate, as flutter_tts defines it (0.5 is normal pace).
  Future<void> setRate(double rate) =>
      _update((s) => s.copyWith(ttsRate: rate));

  /// Speech pitch (1.0 is unmodified).
  Future<void> setPitch(double pitch) =>
      _update((s) => s.copyWith(ttsPitch: pitch));

  /// Whether a word speaks itself when its detail screen opens.
  Future<void> setAutoplay({required bool enabled}) =>
      _update((s) => s.copyWith(autoplayOnOpen: enabled));

  /// Cards to aim for each day; also caps the daily review.
  Future<void> setDailyGoal(int goal) =>
      _update((s) => s.copyWith(dailyGoal: goal));

  /// Which face of a practice card is shown first.
  Future<void> setPromptSide(PromptSide side) =>
      _update((s) => s.copyWith(promptSide: side));

  /// The faces a mix draws from. A set that is not a valid mix (fewer than
  /// two faces) is replaced by the default rather than stored.
  Future<void> setMixSides(Set<PromptSide> sides) =>
      _update((s) => s.copyWith(mixSides: PromptSide.validMix(sides)));

  /// Random faces, or taking turns.
  Future<void> setMixOrder(MixOrder order) =>
      _update((s) => s.copyWith(mixOrder: order));

  /// Extra times a missed card returns within one session. 0 disables it.
  Future<void> setAgainRepeats(int repeats) =>
      _update((s) => s.copyWith(againRepeats: repeats));

  /// Whether *Look up* is offered on the word form.
  Future<void> setLookupEnabled({required bool enabled}) =>
      _update((s) => s.copyWith(lookupEnabled: enabled));

  /// Records that onboarding was finished or skipped, so it is never shown
  /// again (F-077).
  Future<void> completeOnboarding() async {
    await ref.read(settingsRepositoryProvider).completeOnboarding();
  }

  /// Replaces the whole table with the one [pace] produces.
  Future<void> setPace(IntervalPace pace) =>
      _writeSchedule(ReviewSchedule.forPace(pace));

  /// Saves a table of the user's own, or says why it cannot be used.
  ///
  /// Nothing is written when the table is refused: a schedule that stops
  /// words coming back must never reach the scheduler, even for a moment.
  Future<ScheduleIssue?> setSchedule(ReviewSchedule schedule) async {
    final issue = schedule.issue;
    if (issue != null) return issue;
    await _writeSchedule(schedule);
    return null;
  }

  Future<void> _writeSchedule(ReviewSchedule schedule) => _update(
    (s) => s.copyWith(reviewScheduleJson: jsonEncode(schedule.toJson())),
  );
}
