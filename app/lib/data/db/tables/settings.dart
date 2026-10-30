import 'package:drift/drift.dart';
import 'package:vocabnote/data/db/converters/converters.dart';

/// `settings` - a single row, always `id = 1`.
///
/// Real columns rather than key/value pairs, because these are a fixed, known
/// set with real types; `app_meta` is where loose state goes. The single-row
/// invariant is a CHECK constraint, not a convention someone can forget.
@DataClassName('SettingsRow')
class Settings extends Table {
  /// Always 1. See the CHECK constraint below.
  IntColumn get id => integer().withDefault(const Constant(1))();

  /// `system`, `light` or `dark`.
  TextColumn get themeMode => text()
      .named('theme_mode')
      .map(themePreferenceConverter)
      .withDefault(const Constant('system'))();

  /// `en-GB` or `en-US`.
  TextColumn get ttsLocale => text()
      .named('tts_locale')
      .map(ttsLocaleConverter)
      .withDefault(const Constant('en-GB'))();

  /// Speech rate, 0.0-1.0 as flutter_tts defines it.
  RealColumn get ttsRate =>
      real().named('tts_rate').withDefault(const Constant(0.5))();

  /// Speech pitch, 0.5-2.0.
  RealColumn get ttsPitch =>
      real().named('tts_pitch').withDefault(const Constant(1))();

  /// Speak the word when its detail screen opens.
  BoolColumn get autoplayOnOpen =>
      boolean().named('autoplay_on_open').withDefault(const Constant(false))();

  /// Cards to aim for each day; caps the daily review pool.
  IntColumn get dailyGoal =>
      integer().named('daily_goal').withDefault(const Constant(20))();

  /// Off by default. Permission is requested only when the user turns it on
  /// (F-066, `docs/RULES.md` section 6).
  BoolColumn get reminderEnabled =>
      boolean().named('reminder_enabled').withDefault(const Constant(false))();

  /// Minutes after local midnight, or null when never set.
  IntColumn get reminderTimeMinutes =>
      integer().named('reminder_time_minutes').nullable()();

  /// `word_first`, `ipa_first`, `meaning_first` or `mix` (v3).
  TextColumn get promptSide => text()
      .named('prompt_side')
      .map(promptSideConverter)
      .withDefault(const Constant('word_first'))();

  /// Whether the *Look up* button is offered on the word form.
  ///
  /// Turning it off makes the app entirely offline by choice, not merely by
  /// circumstance.
  BoolColumn get lookupEnabled =>
      boolean().named('lookup_enabled').withDefault(const Constant(true))();

  /// The interval each Leitner box waits, as a JSON array of seven integers.
  ///
  /// The default **is** the `docs/GAMES.md` §5 table, so a user who never
  /// opens Settings gets exactly the documented behaviour. Stored as JSON
  /// rather than seven columns because it is one setting the user edits as a
  /// unit, and because a `Sm2Scheduler` in phase 2 would want a different
  /// shape entirely (ADR-005).
  TextColumn get reviewSchedule => text()
      .named('review_schedule')
      .withDefault(const Constant('[0,1,2,4,7,15,30]'))();

  /// How many extra times a card graded *again* may return in the same session.
  ///
  /// Session-local: it changes what one sitting feels like and touches no
  /// scheduling column. 0 disables it.
  IntColumn get againRepeats =>
      integer().named('again_repeats').withDefault(const Constant(1))();

  /// The faces a `mix` prompt draws from: storage values joined by commas
  /// (v3). Read through `PromptSide.decodeMix`, which falls back rather than
  /// trusting the string.
  TextColumn get mixSides => text()
      .named('mix_sides')
      .withDefault(const Constant('word_first,meaning_first'))();

  /// `random` or `rotate` - how a `mix` prompt picks each card's face (v3).
  TextColumn get mixOrder => text()
      .named('mix_order')
      .map(mixOrderConverter)
      .withDefault(const Constant('random'))();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => <String>['CHECK (id = 1)'];
}
