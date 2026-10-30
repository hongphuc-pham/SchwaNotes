import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vocabnote/domain/entities/practice_session.dart';
import 'package:vocabnote/domain/value_objects/storage_enum.dart';

part 'app_settings.freezed.dart';

/// The user's theme choice (`settings.theme_mode`).
enum ThemePreference implements StorageEnum {
  /// Follow the device.
  system('system'),

  /// Always light.
  light('light'),

  /// Always dark.
  dark('dark');

  new(this.storageValue);

  /// The exact string written to the database.
  @override
  final String storageValue;

  /// Parses a stored value, falling back to [ThemePreference.system].
  static ThemePreference fromStorage(String value) {
    for (final preference in ThemePreference.values) {
      if (preference.storageValue == value) return preference;
    }
    return ThemePreference.system;
  }
}

/// Which English the text-to-speech voice should use (`settings.tts_locale`).
///
/// Only the two the app offers. If the device has neither, startup falls back
/// `en-GB -> en-US -> device default` and says so once
/// (`docs/DATA-SOURCES.md` §4).
enum TtsLocale implements StorageEnum {
  /// British English.
  enGb('en-GB'),

  /// American English.
  enUs('en-US');

  new(this.storageValue);

  /// The BCP-47 tag, which is also what is stored and what is handed to the
  /// platform speech engine.
  @override
  final String storageValue;

  /// Parses a stored value, falling back to [TtsLocale.enGb].
  static TtsLocale fromStorage(String value) {
    for (final locale in TtsLocale.values) {
      if (locale.storageValue == value) return locale;
    }
    return TtsLocale.enGb;
  }
}

/// Everything on the settings screen, as one row (`settings`, id = 1).
///
/// A single row rather than a key/value table because these are a fixed,
/// known set with real types - `app_meta` is where loose key/value state goes.
@freezed
abstract class AppSettings with _$AppSettings {
  /// Creates a settings snapshot.
  const factory({
    /// Light, dark or follow the system.
    @Default(ThemePreference.system) ThemePreference themeMode,

    /// Preferred speech voice.
    @Default(TtsLocale.enGb) TtsLocale ttsLocale,

    /// Speech rate, 0.0-1.0 as flutter_tts defines it. 0.5 is normal pace.
    @Default(0.5) double ttsRate,

    /// Speech pitch, 0.5-2.0. 1.0 is unmodified.
    @Default(1) double ttsPitch,

    /// Speak the word automatically when its detail screen opens.
    @Default(false) bool autoplayOnOpen,

    /// Cards to aim for each day. Caps the daily review pool.
    @Default(20) int dailyGoal,

    /// Off by default, and permission is only requested when the user turns it
    /// on (F-066, RULES §6 - no forced notifications).
    @Default(false) bool reminderEnabled,

    /// Minutes after local midnight for the reminder. Null when never set.
    int? reminderTimeMinutes,

    /// Which face of a practice card is shown first.
    @Default(PromptSide.wordFirst) PromptSide promptSide,

    /// The faces a [PromptSide.mix] prompt draws from. Always a valid mix
    /// when read from the database (`PromptSide.decodeMix`).
    @Default(PromptSide.defaultMixSides) Set<PromptSide> mixSides,

    /// How a [PromptSide.mix] prompt picks each card's face.
    @Default(MixOrder.random) MixOrder mixOrder,

    /// Whether the *Look up* button is offered on the word form.
    ///
    /// Turning it off makes the app entirely offline by choice, not just by
    /// circumstance.
    @Default(true) bool lookupEnabled,

    /// The interval each Leitner box waits, as a JSON array of seven integers.
    ///
    /// Kept as the stored string here rather than a parsed object: `domain`
    /// may not import `application`, and `ReviewSchedule` lives there with the
    /// scheduler it serves. `ReviewSchedule.fromJson` does the parsing, and
    /// falls back to the documented default if this is ever unusable.
    @Default('[0,1,2,4,7,15,30]') String reviewScheduleJson,

    /// How many extra times a card graded *again* returns in the same session.
    ///
    /// Session-local: it touches no scheduling column. 0 disables it.
    @Default(1) int againRepeats,
  }) = _AppSettings;

  const new _();

  /// The row every new install starts with (`onCreate` seeds exactly this).
  static const AppSettings defaults = AppSettings();

  /// The slow-replay rate for a long-press on play (F-021): 0.6x.
  double get slowTtsRate => ttsRate * 0.6;

  /// The reminder time as hour and minute, or null when unset.
  ({int hour, int minute})? get reminderTime {
    final minutes = reminderTimeMinutes;
    if (minutes == null) return null;
    return (hour: minutes ~/ 60, minute: minutes % 60);
  }
}
