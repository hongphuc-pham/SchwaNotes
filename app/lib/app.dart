import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabnote/application/settings/settings_controller.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/router/app_router.dart';
import 'package:vocabnote/core/theme/app_theme.dart';
import 'package:vocabnote/domain/entities/app_settings.dart';
import 'package:vocabnote/presentation/design/system_bar_inset.dart';

/// The root widget: `MaterialApp.router` plus theme and localisation wiring.
///
/// Everything above this (database, migrations, settings) is resolved in
/// `bootstrap.dart` before the first frame, so this widget stays synchronous
/// and cheap - it is on the cold-start budget of 2s (`F-092`).
class VocabNoteApp extends ConsumerWidget {
  /// Creates the app.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    // Only the theme is watched here, so a change to speech rate does not
    // rebuild the whole app.
    final theme = ref.watch(
      appSettingsOrDefaultsProvider.select((s) => s.themeMode),
    );

    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,

      // Outside the navigator, so screens, sheets and dialogs are all covered
      // and none has to remember to.
      builder: (context, child) =>
          VnSystemBarInset(child: child ?? const SizedBox.shrink()),

      // The title shown in the OS task switcher. Localised via
      // onGenerateTitle so it follows the device language.
      onGenerateTitle: (context) => AppL10n.of(context).appTitle,

      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: switch (theme) {
        ThemePreference.system => ThemeMode.system,
        ThemePreference.light => ThemeMode.light,
        ThemePreference.dark => ThemeMode.dark,
      },

      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,

      localeListResolutionCallback: (locales, supported) {
        // Explicit rather than implicit: an unsupported device language falls
        // back to English instead of whatever happens to sort first.
        for (final locale in locales ?? const <Locale>[]) {
          for (final candidate in supported) {
            if (candidate.languageCode == locale.languageCode) return candidate;
          }
        }
        return const Locale('en');
      },
    );
  }
}
