import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vocabnote/application/practice/game_contracts.dart';
import 'package:vocabnote/application/practice/practice_session_controller.dart';
import 'package:vocabnote/application/practice/scheduler/review_schedule.dart';
import 'package:vocabnote/application/repositories.dart';
import 'package:vocabnote/application/settings/settings_controller.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/router/routes.dart';
import 'package:vocabnote/domain/entities/practice_session.dart';
import 'package:vocabnote/domain/repositories/practice_repository.dart';
import 'package:vocabnote/presentation/common/empty_state.dart';
import 'package:vocabnote/presentation/practice/game_registry_provider.dart';

/// Runs one session (`docs/UI-UX.md` §4.7).
///
/// The screen owns the chrome — progress, close, confirm-before-abandoning —
/// and hands the middle of the screen to `game.buildRoundView`. It never looks
/// inside a round.
class PracticeRunScreen extends ConsumerStatefulWidget {
  /// Creates the run screen.
  const new({required this.gameId, this.config, super.key});

  /// Which game to run.
  final String gameId;

  /// What the user chose on the hub or in the config sheet.
  ///
  /// Null when the route was opened by URL rather than from the hub — a deep
  /// link, or the daily reminder in F-066. That is not an error: it means
  /// "start today's review". A route that
  /// cannot be opened by its own URL is a broken route.
  final GameConfig? config;

  @override
  ConsumerState<PracticeRunScreen> createState() => _PracticeRunScreenState();
}

class _PracticeRunScreenState extends ConsumerState<PracticeRunScreen> {
  bool _starting = true;
  bool _empty = false;
  bool _failed = false;
  late GameConfig _config;

  /// The daily review the user's settings describe.
  GameConfig _dailyFromSettings() {
    final settings = ref.read(appSettingsOrDefaultsProvider);
    return GameConfig(
      gameId: widget.gameId,
      mode: PracticeMode.daily,
      selection: CardSelection.due,
      limit: settings.dailyGoal,
      promptSide: settings.promptSide,
      mixSides: settings.mixSides,
      mixOrder: settings.mixOrder,
    );
  }

  @override
  void initState() {
    super.initState();
    unawaited(_start());
  }

  Future<void> _start() async {
    _config = widget.config ?? _dailyFromSettings();
    final settings = ref.read(appSettingsOrDefaultsProvider);
    final game = ref.read(gameRegistryProvider).byId(widget.gameId);
    final bool started;
    try {
      started = await ref
          .read(practiceSessionRunnerProvider.notifier)
          .start(
            config: _config,
            game: game,
            // The user's own pace, not the default. `fromJson` falls back to
            // the documented table if the stored value is ever unusable, so a
            // corrupt setting can never stop practice.
            schedule: ReviewSchedule.fromStoredJson(
              settings.reviewScheduleJson,
            ),
            againRepeats: settings.againRepeats,
          );
    } on Object {
      // Nothing awaits `_start`, so a throw here used to leave the screen
      // spinning for ever with no way to know why (M7).
      if (!mounted) return;
      setState(() {
        _starting = false;
        _failed = true;
      });
      return;
    }
    if (!mounted) return;
    setState(() {
      _starting = false;
      _empty = !started;
    });
  }

  void _retry() {
    setState(() {
      _starting = true;
      _failed = false;
    });
    unawaited(_start());
  }

  /// Says the headword.
  ///
  /// Deliberately **not** gated on `ttsAutoPlay`: that setting decides whether
  /// the word is spoken *automatically on reveal*, not whether the play button
  /// works. Gating here made the button dead whenever autoplay was off.
  ///
  /// Fire-and-forget: a silent device is a disappointment, not an error, and
  /// `SpeechService` already reports an unavailable engine as a failure the
  /// word detail screen surfaces. Interrupting a practice session with a
  /// snackbar about text-to-speech would be worse than staying quiet.
  Future<void> _speak(GameRound round) async {
    final settings = ref.read(appSettingsOrDefaultsProvider);
    await ref
        .read(speechServiceProvider)
        .speak(
          round.card.word.headword.value,
          locale: settings.ttsLocale,
          rate: settings.ttsRate,
          pitch: settings.ttsPitch,
        );
  }

  Future<void> _confirmClose() async {
    final l10n = AppL10n.of(context);
    // Only a daily review is worth confirming: it has moved the schedule, so
    // abandoning it leaves the session half-applied. A quick test has changed
    // nothing and can just close.
    if (!_config.affectsScheduling) {
      context.pop();
      return;
    }

    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.practiceAbandonTitle),
        content: Text(l10n.practiceAbandonBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.practiceAbandonStay),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.practiceAbandonLeave),
          ),
        ],
      ),
    );
    if ((leave ?? false) && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final state = ref.watch(practiceSessionRunnerProvider);
    final game = ref.read(gameRegistryProvider).byId(widget.gameId);

    // The summary is a screen of its own; getting there is the runner's job to
    // signal and this screen's job to obey.
    ref.listen(practiceSessionRunnerProvider, (previous, next) {
      if (next?.summary != null && mounted) {
        context.pushReplacement(
          Routes.practiceSummaryOf(next!.summary!.sessionId),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: l10n.practiceCloseLabel,
          onPressed: () => unawaited(_confirmClose()),
        ),
        title: state == null || state.rounds.isEmpty
            ? Text(l10n.practiceTitle)
            : Text('${state.index + 1}/${state.rounds.length}'),
        bottom: state == null
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(4),
                child: LinearProgressIndicator(value: state.progress),
              ),
      ),
      // The grades sit on the bottom edge; without this they grow into the
      // gesture bar at large text. The app bar already keeps the top clear.
      body: SafeArea(
        top: false,
        child: switch ((_starting, _failed, _empty, state?.current)) {
          (true, _, _, _) => const Center(child: CircularProgressIndicator()),
          (_, true, _, _) => EmptyState(
            icon: Icons.error_outline,
            title: l10n.practiceFailedTitle,
            body: l10n.practiceFailedBody,
            actionLabel: l10n.retryAction,
            onAction: _retry,
          ),
          (_, _, true, _) => EmptyState(
            icon: Icons.done_all,
            title: _config.mode == PracticeMode.daily
                ? l10n.practiceNothingDueTitle
                : l10n.practiceNoCardsTitle,
            body: _config.mode == PracticeMode.daily
                ? l10n.practiceNothingDueBody
                : l10n.practiceNoCardsBody,
          ),
          (_, _, _, final GameRound round) => game.buildRoundView(
            context,
            round,
            GameRoundCallbacks(
              onAnswer: (answer) => unawaited(
                ref
                    .read(practiceSessionRunnerProvider.notifier)
                    .answer(game, answer),
              ),
              // Without this the card has no play button at all, which
              // `UI-UX.md` §4.7 requires and F-063 builds autoplay on. It was
              // missing until the card was looked at on a device.
              onSpeak: () => unawaited(_speak(round)),
              intervalLabel: ref
                  .read(practiceSessionRunnerProvider.notifier)
                  .intervalLabelFor,
              position: state?.index ?? 0,
            ),
          ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}
