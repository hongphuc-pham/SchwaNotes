import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:vocabnote/application/backup/backup_actions.dart';
import 'package:vocabnote/application/repositories.dart';
import 'package:vocabnote/application/settings/app_info.dart';
import 'package:vocabnote/application/settings/settings_actions.dart';
import 'package:vocabnote/application/settings/settings_controller.dart';
import 'package:vocabnote/application/words/pronunciation_controller.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/router/routes.dart';
import 'package:vocabnote/core/theme/app_metrics.dart';
import 'package:vocabnote/domain/entities/app_settings.dart';
import 'package:vocabnote/presentation/settings/delete_all_flow.dart';
import 'package:vocabnote/presentation/settings/privacy_note.dart';
import 'package:vocabnote/presentation/settings/settings_tiles.dart';

/// Appearance: the theme, and where text size is set.
class AppearanceSettings extends ConsumerWidget {
  /// Creates the section.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = ref.watch(
      appSettingsOrDefaultsProvider.select((s) => s.themeMode),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SettingsHeader(l10n.settingsAppearanceSection),
        SettingsChoiceTile<ThemePreference>(
          title: l10n.settingsTheme,
          value: theme,
          options: ThemePreference.values,
          labelOf: (option) => switch (option) {
            ThemePreference.system => l10n.themeSystem,
            ThemePreference.light => l10n.themeLight,
            ThemePreference.dark => l10n.themeDark,
          },
          onChanged: (option) => unawaited(
            ref.read(settingsActionsProvider.notifier).setTheme(option),
          ),
        ),
        // Deliberately not a control: the app follows the phone's text size,
        // and a second size here would fight it. Where it lives is the
        // useful thing to say.
        ListTile(
          title: Text(l10n.settingsTextSize),
          subtitle: Text(l10n.settingsTextSizeHint),
        ),
      ],
    );
  }
}

/// Pronunciation: voice, speed, pitch, autoplay, and a way to hear them.
class PronunciationSettings extends ConsumerWidget {
  /// Creates the section.
  const new({super.key});

  Future<void> _testVoice(
    BuildContext context,
    WidgetRef ref,
    TtsLocale locale,
  ) async {
    // Read before the await - a WidgetRef is only good for its build.
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppL10n.of(context);

    final result = await ref
        .read(pronunciationProvider.notifier)
        .play(l10n.settingsTestVoiceSample, locale: locale);
    if (result.isErr) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.detailSpeechFailed)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final metrics = context.metrics;
    final settings = ref.watch(appSettingsOrDefaultsProvider);
    // Watched so the player lives exactly as long as the screen: leaving
    // Settings mid-word stops it.
    final playback = ref.watch(pronunciationProvider);

    SettingsActions actions() => ref.read(settingsActionsProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SettingsHeader(l10n.settingsPronunciationSection),
        SettingsChoiceTile<TtsLocale>(
          title: l10n.settingsVoice,
          value: settings.ttsLocale,
          options: TtsLocale.values,
          labelOf: (option) => switch (option) {
            TtsLocale.enGb => l10n.voiceBritish,
            TtsLocale.enUs => l10n.voiceAmerican,
          },
          onChanged: (option) => unawaited(actions().setVoice(option)),
        ),
        // 0.5 is flutter_tts's normal pace on both platforms, so the range
        // reads as half to one-and-a-half times normal.
        SettingsSliderTile(
          title: l10n.settingsSpeed,
          value: settings.ttsRate,
          min: 0.25,
          max: 0.75,
          divisions: 10,
          normal: 0.5,
          onChangeEnd: (value) => unawaited(actions().setRate(value)),
        ),
        SettingsSliderTile(
          title: l10n.settingsPitch,
          value: settings.ttsPitch,
          min: 0.5,
          max: 2,
          divisions: 15,
          normal: 1,
          onChangeEnd: (value) => unawaited(actions().setPitch(value)),
        ),
        SwitchListTile(
          title: Text(l10n.settingsAutoplay),
          value: settings.autoplayOnOpen,
          onChanged: (on) => unawaited(actions().setAutoplay(enabled: on)),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: metrics.spaceLg,
            vertical: metrics.spaceSm,
          ),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: FilledButton.tonalIcon(
              onPressed: () =>
                  unawaited(_testVoice(context, ref, settings.ttsLocale)),
              icon: Icon(
                playback.speaking == null
                    ? Icons.play_arrow_rounded
                    : Icons.volume_up_rounded,
              ),
              label: Text(l10n.settingsTestVoice),
            ),
          ),
        ),
      ],
    );
  }
}

/// Your data: backup, storage used, dictionary look-up, delete all data.
class DataSettings extends ConsumerWidget {
  /// Creates the section.
  const new({super.key});

  /// A size in the unit a person would say it in.
  static String _size(BuildContext context, AppL10n l10n, int bytes) {
    const kilobyte = 1024;
    const megabyte = kilobyte * 1024;
    if (bytes < megabyte) {
      return l10n.storageKilobytes((bytes / kilobyte).ceil());
    }
    final locale = Localizations.localeOf(context).toString();
    return l10n.storageMegabytes(
      NumberFormat('0.0', locale).format(bytes / megabyte),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final lookup = ref.watch(
      appSettingsOrDefaultsProvider.select((s) => s.lookupEnabled),
    );
    final storage = ref.watch(storageUsedProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SettingsHeader(l10n.settingsDataSection),
        _LinkTile(
          title: l10n.settingsBackup,
          subtitle: l10n.settingsBackupHint,
          route: Routes.backup,
        ),
        ListTile(
          title: Text(l10n.settingsStorage),
          subtitle: switch (storage) {
            AsyncData(value: final int bytes) => Text(
              _size(context, l10n, bytes),
            ),
            AsyncLoading() => Text(l10n.settingsStorageCounting),
            // Unmeasurable just now: say nothing rather than a wrong number.
            _ => null,
          },
        ),
        SwitchListTile(
          title: Text(l10n.settingsLookup),
          subtitle: Text(
            lookup ? l10n.settingsLookupOn : l10n.settingsLookupOff,
          ),
          value: lookup,
          onChanged: (on) => unawaited(
            ref
                .read(settingsActionsProvider.notifier)
                .setLookupEnabled(enabled: on),
          ),
        ),
        ListTile(
          title: Text(
            l10n.settingsDeleteAll,
            style: TextStyle(color: theme.colorScheme.error),
          ),
          subtitle: Text(l10n.settingsDeleteAllHint),
          onTap: () => unawaited(deleteAllData(context, ref)),
        ),
      ],
    );
  }
}

/// Help: always *How to use* and *Help & feedback* (RULES §4, P8).
class HelpSettings extends StatelessWidget {
  /// Creates the section.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SettingsHeader(l10n.settingsHelpSection),
        _LinkTile(title: l10n.guideTitle, route: Routes.guide),
        _LinkTile(title: l10n.helpTitle, route: Routes.help),
      ],
    );
  }
}

/// About: the version, and where the app's content comes from.
class AboutSettings extends ConsumerWidget {
  /// Creates the section.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SettingsHeader(l10n.settingsAboutSection),
        ListTile(
          title: Text(l10n.settingsVersion),
          // Empty until the platform answers; start-up does not wait (F-092).
          subtitle: Text(ref.watch(appVersionProvider).value ?? ''),
        ),
        _LinkTile(title: l10n.licencesTitle, route: Routes.licences),
        // A sheet rather than a route: one paragraph does not earn a place
        // in the navigation (RULES §42). The same note heads the licences.
        ListTile(
          title: Text(l10n.settingsPrivacy),
          subtitle: Text(l10n.settingsPrivacyHint),
          onTap: () => unawaited(PrivacyNote.show(context)),
        ),
        // Last, quiet, and absent until there is a page to go to. It unlocks
        // nothing, and says so.
        if (ref.watch(supportLinkProvider) case final Uri link)
          ListTile(
            title: Text(l10n.settingsSupport),
            subtitle: Text(l10n.settingsSupportHint),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => unawaited(_openSupport(context, ref, link)),
          ),
      ],
    );
  }

  Future<void> _openSupport(
    BuildContext context,
    WidgetRef ref,
    Uri link,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppL10n.of(context);
    if (!await ref.read(linkOpenerProvider).open(link)) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.helpLinkFailed)));
    }
  }
}

/// A row that opens another settings screen.
class _LinkTile extends StatelessWidget {
  const new({required this.title, required this.route, this.subtitle});

  final String title;
  final String? subtitle;
  final String route;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: switch (subtitle) {
        final String text => Text(text),
        null => null,
      },
      trailing: const Icon(Icons.chevron_right),
      onTap: () => unawaited(context.push<void>(route)),
    );
  }
}
