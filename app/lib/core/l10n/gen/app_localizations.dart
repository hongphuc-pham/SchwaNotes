import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n)!;
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// The application name. Not translated.
  ///
  /// In en, this message translates to:
  /// **'Schwa Notes'**
  String get appTitle;

  /// Bottom navigation label for the words tab.
  ///
  /// In en, this message translates to:
  /// **'Words'**
  String get navWords;

  /// Bottom navigation label for the practice tab.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get navPractice;

  /// Bottom navigation label for the lists tab.
  ///
  /// In en, this message translates to:
  /// **'Lists'**
  String get navLists;

  /// App bar title on the words (home) screen.
  ///
  /// In en, this message translates to:
  /// **'My words'**
  String get wordsTitle;

  /// App bar title on the practice hub.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get practiceTitle;

  /// App bar title on the lists screen.
  ///
  /// In en, this message translates to:
  /// **'Lists'**
  String get listsTitle;

  /// App bar title on the settings screen.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Accessibility label for the icon-only settings button in the app bar.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get settingsOpenLabel;

  /// Accessibility label for an icon-only back button.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get backLabel;

  /// Title of the six-card usage guide. Always present in Settings.
  ///
  /// In en, this message translates to:
  /// **'How to use'**
  String get guideTitle;

  /// Title of the help and feedback screen. Always present in Settings.
  ///
  /// In en, this message translates to:
  /// **'Help & feedback'**
  String get helpTitle;

  /// Title of the backup export/import screen.
  ///
  /// In en, this message translates to:
  /// **'Backup & restore'**
  String get backupTitle;

  /// Title of the licences and attribution screen.
  ///
  /// In en, this message translates to:
  /// **'Data sources & licences'**
  String get licencesTitle;

  /// Title of the onboarding flow.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get onboardingTitle;

  /// Placeholder app bar title for the word detail screen.
  ///
  /// In en, this message translates to:
  /// **'Word'**
  String get wordDetailTitle;

  /// App bar title when adding or editing a word.
  ///
  /// In en, this message translates to:
  /// **'Edit word'**
  String get wordEditTitle;

  /// App bar title for the IPA highlight editor.
  ///
  /// In en, this message translates to:
  /// **'Edit IPA highlights'**
  String get ipaEditorTitle;

  /// Placeholder app bar title for a single list.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get listDetailTitle;

  /// App bar title while a practice session is running.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get practiceRunTitle;

  /// App bar title on the session summary screen.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get practiceSummaryTitle;

  /// Heading on a placeholder screen that is not built yet.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoonTitle;

  /// Body text on a placeholder screen that is not built yet.
  ///
  /// In en, this message translates to:
  /// **'This screen arrives in a later milestone.'**
  String get comingSoonBody;

  /// Shows which route a placeholder screen is standing in for. Developer-facing, removed once the real screens land.
  ///
  /// In en, this message translates to:
  /// **'Route: {route}'**
  String comingSoonRoute(String route);

  /// Heading shown when a route cannot be resolved.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get routeNotFoundTitle;

  /// Body text shown when a route cannot be resolved.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find that page. Let\'s get you back to your words.'**
  String get routeNotFoundBody;

  /// Button that returns the user to the words screen from an unresolved route.
  ///
  /// In en, this message translates to:
  /// **'Go to my words'**
  String get routeNotFoundAction;

  /// Heading when the database on disk was written by a newer version of the app.
  ///
  /// In en, this message translates to:
  /// **'This data was made by a newer Schwa Notes'**
  String get recoverySchemaTooNewTitle;

  /// Body when the database was written by a newer version. Explains why the app refuses to open it.
  ///
  /// In en, this message translates to:
  /// **'Please update Schwa Notes to open your words. Opening them with this older version could damage them, so we haven\'t tried.'**
  String get recoverySchemaTooNewBody;

  /// Heading when a database migration failed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t finish updating your words'**
  String get recoveryMigrationTitle;

  /// Body when a migration failed and no backup was restored.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while moving your words to the new version. Your original database is still on your phone, exactly as it was.'**
  String get recoveryMigrationBody;

  /// Body when a migration failed and the pre-migration backup was successfully restored.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while moving your words to the new version, so we put the backup we took beforehand straight back. Nothing was lost.'**
  String get recoveryMigrationBodyRestored;

  /// Heading when the database could not be opened for some other reason.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t open your words'**
  String get recoveryGenericTitle;

  /// Body when the database could not be opened for some other reason.
  ///
  /// In en, this message translates to:
  /// **'The file holding your words couldn\'t be read. It\'s still on your phone and nothing has been removed.'**
  String get recoveryGenericBody;

  /// Reassurance shown on the recovery screen. States the app's data-safety promise plainly.
  ///
  /// In en, this message translates to:
  /// **'Nothing has been deleted. Schwa Notes never resets your database to recover from a problem.'**
  String get recoveryNothingDeleted;

  /// Button that exports whatever can be read, from the recovery screen.
  ///
  /// In en, this message translates to:
  /// **'Export my data'**
  String get recoveryExportAction;

  /// Placeholder in the words search field.
  ///
  /// In en, this message translates to:
  /// **'Search your words'**
  String get wordsSearchHint;

  /// Accessibility label for the search icon button.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get wordsSearchLabel;

  /// Accessibility label for the button that closes the search field.
  ///
  /// In en, this message translates to:
  /// **'Close search'**
  String get wordsCloseSearchLabel;

  /// Accessibility label for the sort menu button.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get wordsSortLabel;

  /// Filter chip showing every word. Not a stored list.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// Filter chip showing starred words only.
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get filterFavourites;

  /// Filter chip showing words whose practice card is due.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get filterDueToday;

  /// Filter chip showing words with no pronunciation typed yet.
  ///
  /// In en, this message translates to:
  /// **'No IPA yet'**
  String get filterNoIpa;

  /// Sort option: most recently changed first.
  ///
  /// In en, this message translates to:
  /// **'Recently updated'**
  String get sortRecent;

  /// Sort option: alphabetical.
  ///
  /// In en, this message translates to:
  /// **'A to Z'**
  String get sortAlphabetical;

  /// Sort option: weakest practice cards first.
  ///
  /// In en, this message translates to:
  /// **'Least known'**
  String get sortLeastKnown;

  /// Label on the floating button that opens the add-word form.
  ///
  /// In en, this message translates to:
  /// **'Add word'**
  String get addWordAction;

  /// Heading of the empty state when the user has no words at all.
  ///
  /// In en, this message translates to:
  /// **'Your first word goes here'**
  String get emptyWordsTitle;

  /// Body of the empty state when the user has no words at all.
  ///
  /// In en, this message translates to:
  /// **'Save a word, write how it sounds, and mark the part you keep getting wrong.'**
  String get emptyWordsBody;

  /// Primary button in the empty state.
  ///
  /// In en, this message translates to:
  /// **'Add a word'**
  String get emptyWordsAction;

  /// Secondary link in the empty state, opening the guide.
  ///
  /// In en, this message translates to:
  /// **'See how it works'**
  String get emptyWordsGuide;

  /// Heading when a filter matches no words.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get emptyFilterTitle;

  /// Body when a filter matches no words.
  ///
  /// In en, this message translates to:
  /// **'No words match this filter. Try another one, or add a new word.'**
  String get emptyFilterBody;

  /// Heading when a search returns nothing.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get emptySearchTitle;

  /// Body when a search returns nothing.
  ///
  /// In en, this message translates to:
  /// **'Nothing matched {term}. Check the spelling, or add it as a new word.'**
  String emptySearchBody(String term);

  /// Button that resets the filter and search.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get emptyFilterClear;

  /// Error state title on the lists grid.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your lists'**
  String get listsLoadFailedTitle;

  /// Error state body on the lists grid. Reassures that nothing was lost.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong reading them. Your lists are still saved.'**
  String get listsLoadFailedBody;

  /// Snackbar shown when creating or editing a list fails.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save that list. Please try again.'**
  String get listSaveFailed;

  /// Empty state title on a list's detail screen.
  ///
  /// In en, this message translates to:
  /// **'Nothing in this list yet'**
  String get listEmptyTitle;

  /// Empty state body on a list's detail screen.
  ///
  /// In en, this message translates to:
  /// **'Add a word to this list from the word\'s own screen.'**
  String get listEmptyBody;

  /// Name of the flashcard game on the practice hub.
  ///
  /// In en, this message translates to:
  /// **'Flashcards'**
  String get gameFlashcardTitle;

  /// One-line description of the flashcard game.
  ///
  /// In en, this message translates to:
  /// **'See a word, recall it, then say how it went.'**
  String get gameFlashcardDescription;

  /// Hint on the first card of a session only.
  ///
  /// In en, this message translates to:
  /// **'Tap to reveal'**
  String get flashcardTapToReveal;

  /// Screen-reader label for the unflipped card.
  ///
  /// In en, this message translates to:
  /// **'Card front. Tap to reveal the answer.'**
  String get flashcardFrontLabel;

  /// Screen-reader label for the flipped card.
  ///
  /// In en, this message translates to:
  /// **'Card back. Choose how well you knew it.'**
  String get flashcardBackLabel;

  /// Grading button: the user did not know the word.
  ///
  /// In en, this message translates to:
  /// **'Again'**
  String get gradeAgain;

  /// Grading button: the user knew the word.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get gradeGood;

  /// Grading button: the user knew the word easily.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get gradeEasy;

  /// Empty state title on the practice hub when there are no words.
  ///
  /// In en, this message translates to:
  /// **'Nothing to practise yet'**
  String get practiceEmptyTitle;

  /// Empty state body on the practice hub.
  ///
  /// In en, this message translates to:
  /// **'Add a few words and they\'ll show up here ready to review.'**
  String get practiceEmptyBody;

  /// Button that opens the quick-test config sheet.
  ///
  /// In en, this message translates to:
  /// **'Quick test'**
  String get practiceQuickTest;

  /// Encouraging line when no cards are due. Never a warning (UI-UX 4.6).
  ///
  /// In en, this message translates to:
  /// **'Nothing due right now - a quick test still counts.'**
  String get practiceNothingDue;

  /// The daily goal on the practice hub: different words practised today, out of the goal (F-065). Never a warning.
  ///
  /// In en, this message translates to:
  /// **'{count} of {goal} today'**
  String practiceGoalProgress(int count, int goal);

  /// Shown once today's words reach the daily goal (F-065).
  ///
  /// In en, this message translates to:
  /// **'Today\'s goal reached - nice work'**
  String get practiceGoalReached;

  /// Days practised in a row (F-065). A streak of zero is never shown.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day in a row} other{{days} days in a row}}'**
  String practiceStreak(int days);

  /// Under the goal when there is no streak yet. Encouraging, never 'you lost your streak' (RULES 6).
  ///
  /// In en, this message translates to:
  /// **'Any card you practise today counts'**
  String get practiceGoalStart;

  /// Shown when a daily review is started with nothing due.
  ///
  /// In en, this message translates to:
  /// **'All caught up'**
  String get practiceNothingDueTitle;

  /// Body when a daily review has no cards.
  ///
  /// In en, this message translates to:
  /// **'Nothing is due today. Try a quick test if you\'d like more.'**
  String get practiceNothingDueBody;

  /// Shown when a quick test finds no matching words.
  ///
  /// In en, this message translates to:
  /// **'No cards here'**
  String get practiceNoCardsTitle;

  /// Body when a quick test pool is empty.
  ///
  /// In en, this message translates to:
  /// **'Nothing matched that choice. Try a different source.'**
  String get practiceNoCardsBody;

  /// Generic retry button.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retryAction;

  /// Title when starting a practice session threw.
  ///
  /// In en, this message translates to:
  /// **'This session couldn\'t start'**
  String get practiceFailedTitle;

  /// Body when starting a practice session threw: what happened, what to do (UI-UX §5).
  ///
  /// In en, this message translates to:
  /// **'Something went wrong picking the cards. Try again, or close practice and come back to it.'**
  String get practiceFailedBody;

  /// Title on the practice hub when the word count could not be read.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read your words'**
  String get practiceCountsFailedTitle;

  /// Body on the practice hub when the word count could not be read.
  ///
  /// In en, this message translates to:
  /// **'Practice needs to know what\'s in your library. Try again, and if it keeps happening, restart the app.'**
  String get practiceCountsFailedBody;

  /// Screen-reader label for the close button during a session.
  ///
  /// In en, this message translates to:
  /// **'Close practice'**
  String get practiceCloseLabel;

  /// Title of the confirm dialog when abandoning a daily review.
  ///
  /// In en, this message translates to:
  /// **'Leave this review?'**
  String get practiceAbandonTitle;

  /// Body of the abandon dialog. Says plainly that nothing is lost.
  ///
  /// In en, this message translates to:
  /// **'The cards you\'ve already answered stay answered. The rest keep their current schedule.'**
  String get practiceAbandonBody;

  /// Button that dismisses the abandon dialog.
  ///
  /// In en, this message translates to:
  /// **'Keep going'**
  String get practiceAbandonStay;

  /// Button that abandons the session.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get practiceAbandonLeave;

  /// Title of the quick-test config sheet.
  ///
  /// In en, this message translates to:
  /// **'Quick test'**
  String get quickTestTitle;

  /// Label for the source chips in the quick-test sheet.
  ///
  /// In en, this message translates to:
  /// **'Words from'**
  String get quickTestSource;

  /// Label for the size chips in the quick-test sheet.
  ///
  /// In en, this message translates to:
  /// **'How many'**
  String get quickTestSize;

  /// Label for the prompt-side chips in the quick-test sheet.
  ///
  /// In en, this message translates to:
  /// **'Show me first'**
  String get quickTestPromptSide;

  /// Toggle for text-to-speech autoplay during a quick test.
  ///
  /// In en, this message translates to:
  /// **'Say the word when I reveal it'**
  String get quickTestAutoplay;

  /// Button that starts the quick test.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get quickTestStart;

  /// Prompt side: show the headword first.
  ///
  /// In en, this message translates to:
  /// **'The word'**
  String get promptSideWord;

  /// Prompt side: show the transcription first.
  ///
  /// In en, this message translates to:
  /// **'The sounds'**
  String get promptSideIpa;

  /// Prompt side: show the definition first.
  ///
  /// In en, this message translates to:
  /// **'The meaning'**
  String get promptSideMeaning;

  /// Button that starts a daily review, with how many cards are due.
  ///
  /// In en, this message translates to:
  /// **'Daily review ({count} due)'**
  String practiceDailyReview(int count);

  /// Says how many words are still needed before a game unlocks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Add 1 more word to unlock this} other{Add {count} more words to unlock this}}'**
  String practiceLockedHint(int count);

  /// The All size chip, naming the hard cap out loud.
  ///
  /// In en, this message translates to:
  /// **'All (max {max})'**
  String quickTestSizeAll(int max);

  /// Heading of the practice section in Settings (UI-UX 4.9).
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get settingsPracticeSection;

  /// The switch for the optional daily reminder (F-066). Off by default.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder'**
  String get reminderTitle;

  /// Under the reminder switch when it is off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get reminderOff;

  /// Under the reminder switch when it is on. The time is already formatted for the user's locale.
  ///
  /// In en, this message translates to:
  /// **'Every day at {time}'**
  String reminderOnAt(String time);

  /// The row that changes when the daily reminder arrives.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get reminderTimeLabel;

  /// Snackbar when notification permission is refused. Plain, never pleading.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off for Schwa Notes. You can allow them in your phone\'s settings.'**
  String get reminderDenied;

  /// Snackbar when the reminder could not be scheduled.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t set the reminder just now. Please try again.'**
  String get reminderFailed;

  /// Title of the daily reminder notification. An invitation, never a warning: no streak loss, no guilt (RULES 6).
  ///
  /// In en, this message translates to:
  /// **'A few words today?'**
  String get reminderNotificationTitle;

  /// Body of the daily reminder notification.
  ///
  /// In en, this message translates to:
  /// **'A short practice keeps them fresh.'**
  String get reminderNotificationBody;

  /// The notification channel's name in Android's system settings.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder'**
  String get reminderChannelName;

  /// The notification channel's description in Android's system settings.
  ///
  /// In en, this message translates to:
  /// **'One gentle reminder a day, at the time you chose.'**
  String get reminderChannelDescription;

  /// Heading of the appearance section in Settings (UI-UX 4.9).
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearanceSection;

  /// Heading of the pronunciation section in Settings (UI-UX 4.9).
  ///
  /// In en, this message translates to:
  /// **'Pronunciation'**
  String get settingsPronunciationSection;

  /// Heading of the data section in Settings: backup, look-up, storage, delete.
  ///
  /// In en, this message translates to:
  /// **'Your data'**
  String get settingsDataSection;

  /// Heading of the help section in Settings. Always contains How to use and Help & feedback (RULES 4).
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get settingsHelpSection;

  /// Heading of the about section in Settings.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAboutSection;

  /// The setting that chooses light, dark or the phone's own theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// Theme choice: follow the device's light or dark setting.
  ///
  /// In en, this message translates to:
  /// **'Same as my phone'**
  String get themeSystem;

  /// Theme choice: always light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// Theme choice: always dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// A row explaining where text size is set. Not a control.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get settingsTextSize;

  /// Explains that the app follows the OS text size rather than having its own.
  ///
  /// In en, this message translates to:
  /// **'Schwa Notes uses your phone\'s text size. You can change it in your phone\'s display settings.'**
  String get settingsTextSizeHint;

  /// The setting that chooses British or American English for speech.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get settingsVoice;

  /// Voice choice: en-GB.
  ///
  /// In en, this message translates to:
  /// **'British English'**
  String get voiceBritish;

  /// Voice choice: en-US.
  ///
  /// In en, this message translates to:
  /// **'American English'**
  String get voiceAmerican;

  /// The speech speed slider.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get settingsSpeed;

  /// The speech pitch slider.
  ///
  /// In en, this message translates to:
  /// **'Pitch'**
  String get settingsPitch;

  /// Switch: speak a word automatically when its detail screen opens.
  ///
  /// In en, this message translates to:
  /// **'Say the word when I open it'**
  String get settingsAutoplay;

  /// Button that speaks a sample word with the current voice, speed and pitch.
  ///
  /// In en, this message translates to:
  /// **'Test voice'**
  String get settingsTestVoice;

  /// The English word Test voice speaks. Keep it English in every locale: the voice is always English.
  ///
  /// In en, this message translates to:
  /// **'pronunciation'**
  String get settingsTestVoiceSample;

  /// The setting for how many words to aim for each day.
  ///
  /// In en, this message translates to:
  /// **'Daily goal'**
  String get settingsDailyGoal;

  /// A daily goal, as shown under the setting and in its list.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 word a day} other{{count} words a day}}'**
  String settingsDailyGoalValue(int count);

  /// The setting for which side of a practice card is shown first.
  ///
  /// In en, this message translates to:
  /// **'Show me first'**
  String get settingsPromptSide;

  /// The setting that picks a preset repetition schedule (GAMES.md 5).
  ///
  /// In en, this message translates to:
  /// **'Review pace'**
  String get settingsPace;

  /// Review pace: longer gaps.
  ///
  /// In en, this message translates to:
  /// **'Gentle'**
  String get paceGentle;

  /// One line explaining the gentle pace.
  ///
  /// In en, this message translates to:
  /// **'Longer gaps between reviews'**
  String get paceGentleHint;

  /// Review pace: the default gaps.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get paceStandard;

  /// One line explaining the standard pace.
  ///
  /// In en, this message translates to:
  /// **'The usual gaps'**
  String get paceStandardHint;

  /// Review pace: shorter gaps.
  ///
  /// In en, this message translates to:
  /// **'Intensive'**
  String get paceIntensive;

  /// One line explaining the intensive pace.
  ///
  /// In en, this message translates to:
  /// **'Shorter gaps and more reviews - good before an exam'**
  String get paceIntensiveHint;

  /// Shown as the review pace once the user has changed a box by hand.
  ///
  /// In en, this message translates to:
  /// **'Your own'**
  String get paceCustom;

  /// The row, and the sheet, for editing the interval of each box.
  ///
  /// In en, this message translates to:
  /// **'Days between reviews'**
  String get settingsIntervals;

  /// Summary of the intervals for boxes 1 to 6, already joined with listSeparator.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String settingsIntervalsValue(String days);

  /// Separator between items in a short inline list.
  ///
  /// In en, this message translates to:
  /// **' · '**
  String get listSeparator;

  /// Explains the boxes at the top of the interval editor.
  ///
  /// In en, this message translates to:
  /// **'Each time you know a word, it moves up a box and waits a little longer before it comes back.'**
  String get intervalEditorBody;

  /// The fixed first box, which the user cannot change.
  ///
  /// In en, this message translates to:
  /// **'Box 0 - later the same day, for words worth another look'**
  String get intervalEditorBoxZero;

  /// Label of the field for one box's interval.
  ///
  /// In en, this message translates to:
  /// **'Box {box}'**
  String intervalEditorBox(int box);

  /// Unit shown after each interval field.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get intervalEditorDays;

  /// Button that fills the interval fields with the standard table.
  ///
  /// In en, this message translates to:
  /// **'Use standard'**
  String get intervalEditorReset;

  /// Button that saves the interval table.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get intervalEditorSave;

  /// Why a table was refused: a box waits less than a day.
  ///
  /// In en, this message translates to:
  /// **'Box {box} needs at least 1 day, or its words never come back.'**
  String scheduleIssueTooShort(int box);

  /// Why a table was refused: a box waits less than the one before it.
  ///
  /// In en, this message translates to:
  /// **'Box {box} can\'t be shorter than box {previous}. Later boxes wait longer.'**
  String scheduleIssueShorter(int box, int previous);

  /// Why a table cannot be saved: a field is empty.
  ///
  /// In en, this message translates to:
  /// **'Box {box} needs a whole number of days.'**
  String scheduleIssueNotNumber(int box);

  /// Fallback reason for a table the editor cannot produce by hand.
  ///
  /// In en, this message translates to:
  /// **'This schedule can\'t be used. Try Use standard.'**
  String get scheduleIssueUnusable;

  /// The setting for how often a missed card returns within one session.
  ///
  /// In en, this message translates to:
  /// **'Repeat missed cards'**
  String get settingsRepeats;

  /// How many extra times a missed card comes back in one session.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Don\'t repeat} =1{Once in the same session} =2{Twice in the same session} other{{count} times in the same session}}'**
  String settingsRepeatsValue(int count);

  /// Row that opens export and import.
  ///
  /// In en, this message translates to:
  /// **'Backup & restore'**
  String get settingsBackup;

  /// Under the Backup & restore row.
  ///
  /// In en, this message translates to:
  /// **'Keep a copy of your words, or move them to a new phone'**
  String get settingsBackupHint;

  /// Switch that offers or hides the Look up button on the word form.
  ///
  /// In en, this message translates to:
  /// **'Dictionary look-up'**
  String get settingsLookup;

  /// Under the look-up switch when it is on. Says exactly what leaves the phone.
  ///
  /// In en, this message translates to:
  /// **'Look up sends only the word to freedictionaryapi.com'**
  String get settingsLookupOn;

  /// Under the look-up switch when it is off.
  ///
  /// In en, this message translates to:
  /// **'Off - Schwa Notes stays fully offline'**
  String get settingsLookupOff;

  /// Top of the backup screen. Says what is in the file and that nothing leaves the phone by itself.
  ///
  /// In en, this message translates to:
  /// **'A backup is one file holding all your words, sounds, highlights, notes, lists and practice history. Nothing is uploaded: you choose where it goes.'**
  String get backupIntro;

  /// Shown when no backup has ever been exported. A fact, never a warning.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t made a backup yet.'**
  String get backupNever;

  /// When the last backup was handed over. The date is already formatted for the user's locale.
  ///
  /// In en, this message translates to:
  /// **'Last backup: {when}'**
  String backupLast(String when);

  /// Button that writes a backup file and opens the share sheet.
  ///
  /// In en, this message translates to:
  /// **'Export backup'**
  String get backupExport;

  /// The export button's label while the file is being written.
  ///
  /// In en, this message translates to:
  /// **'Preparing your backup…'**
  String get backupPreparing;

  /// Under the export button: where a backup is worth keeping.
  ///
  /// In en, this message translates to:
  /// **'Save it somewhere you can reach from your next phone - your email, your cloud storage or your files.'**
  String get backupExportHint;

  /// Snackbar after the backup was handed to another app.
  ///
  /// In en, this message translates to:
  /// **'Backup shared. Keep it somewhere safe.'**
  String get backupExportDone;

  /// Snackbar when the backup could not be written or shared. Reassures first.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t make the backup just now. Your words are safe - please try again.'**
  String get backupExportFailed;

  /// Button that chooses a backup file to bring in.
  ///
  /// In en, this message translates to:
  /// **'Import backup'**
  String get backupImport;

  /// The import button's label while a backup is being written.
  ///
  /// In en, this message translates to:
  /// **'Bringing your words in…'**
  String get backupImporting;

  /// Under the import button.
  ///
  /// In en, this message translates to:
  /// **'Bring words in from a backup file. You\'ll see what\'s in it before anything changes.'**
  String get backupImportHint;

  /// The chosen file is not a backup at all.
  ///
  /// In en, this message translates to:
  /// **'That file isn\'t a Schwa Notes backup. Backups end in .vnb.'**
  String get importProblemNotABackup;

  /// The chosen file is far larger than any backup could be.
  ///
  /// In en, this message translates to:
  /// **'That file is too large to be a Schwa Notes backup.'**
  String get importProblemTooLarge;

  /// The backup is ours but broken - often cut short by an interrupted download.
  ///
  /// In en, this message translates to:
  /// **'That backup is damaged and can\'t be read. If you still have the phone it came from, try exporting it again.'**
  String get importProblemDamaged;

  /// The chosen file could not be read at all.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open that file. Please try again.'**
  String get importProblemUnreadable;

  /// Title of the sheet showing what a chosen backup holds.
  ///
  /// In en, this message translates to:
  /// **'Bring in this backup?'**
  String get importPreviewTitle;

  /// How many words a backup holds.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 word} other{{count} words}}'**
  String importPreviewWords(int count);

  /// How many lists a backup holds.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{no lists} =1{1 list} other{{count} lists}}'**
  String importPreviewLists(int count);

  /// When the backup was made. The date is already formatted for the user's locale.
  ///
  /// In en, this message translates to:
  /// **'Made {when}'**
  String importPreviewMade(String when);

  /// Import choice: merge. The default.
  ///
  /// In en, this message translates to:
  /// **'Add to my words'**
  String get importModeMerge;

  /// What merging does.
  ///
  /// In en, this message translates to:
  /// **'New words are added and newer copies win. Nothing on this phone is removed.'**
  String get importModeMergeHint;

  /// Import choice: replace.
  ///
  /// In en, this message translates to:
  /// **'Replace everything'**
  String get importModeReplace;

  /// What replacing does, and that there is a way back.
  ///
  /// In en, this message translates to:
  /// **'Everything on this phone becomes what\'s in the backup. A copy of what\'s here now is kept first.'**
  String get importModeReplaceHint;

  /// Button that goes ahead with the chosen import mode.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get importContinue;

  /// Title of the typed confirmation before a replace.
  ///
  /// In en, this message translates to:
  /// **'Replace everything on this phone?'**
  String get replaceConfirmTitle;

  /// What a replace does, before the user types the confirmation word.
  ///
  /// In en, this message translates to:
  /// **'Your words, notes, highlights, lists and practice history here will be swapped for the backup\'s. A copy of what\'s here now is kept on this phone first.'**
  String get replaceConfirmBody;

  /// The word the user types to confirm a replace (RULES 11). Matched without regard to case.
  ///
  /// In en, this message translates to:
  /// **'replace'**
  String get replaceConfirmWord;

  /// The button that carries out a confirmed replace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get replaceConfirmAction;

  /// Prompt above the field in a typed confirmation.
  ///
  /// In en, this message translates to:
  /// **'Type “{word}” to confirm'**
  String typedConfirmPrompt(String word);

  /// Title of the report after an import.
  ///
  /// In en, this message translates to:
  /// **'Your backup is in'**
  String get importReportTitle;

  /// Words a merge added.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No new words} =1{1 word added} other{{count} words added}}'**
  String importReportAdded(int count);

  /// Words a merge updated with a newer copy.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 word updated} other{{count} words updated}}'**
  String importReportUpdated(int count);

  /// Words a merge left as they were.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 word was already here} other{{count} words were already here}}'**
  String importReportSkipped(int count);

  /// Words a replace restored.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No words restored} =1{1 word restored} other{{count} words restored}}'**
  String importReportRestored(int count);

  /// Notes brought in, as one item of a list.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 note} other{{count} notes}}'**
  String importReportNotes(int count);

  /// Highlights brought in, as one item of a list.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 highlight} other{{count} highlights}}'**
  String importReportHighlights(int count);

  /// Lists brought in, as one item of a list.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 list} other{{count} lists}}'**
  String importReportLists(int count);

  /// The other things an import brought, already joined with listSeparator.
  ///
  /// In en, this message translates to:
  /// **'Also brought in: {items}'**
  String importReportAlso(String items);

  /// Rows that could not be used. Worth knowing, never alarming.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item couldn\'t be read and was left out.} other{{count} items couldn\'t be read and were left out.}}'**
  String importReportRejected(int count);

  /// After a replace: the way back exists.
  ///
  /// In en, this message translates to:
  /// **'A copy of what was here before is kept on this phone.'**
  String get importReportSafetyCopy;

  /// Closes the import report.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get importReportDone;

  /// Snackbar when an import failed part-way and was rolled back.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t bring the backup in. Nothing on this phone was changed.'**
  String get importFailed;

  /// Row showing how much space the library takes on the phone.
  ///
  /// In en, this message translates to:
  /// **'Storage used'**
  String get settingsStorage;

  /// Under Storage used while it is being measured.
  ///
  /// In en, this message translates to:
  /// **'Counting…'**
  String get settingsStorageCounting;

  /// A size under one megabyte.
  ///
  /// In en, this message translates to:
  /// **'{size} KB'**
  String storageKilobytes(int size);

  /// A size of a megabyte or more, already formatted with one decimal.
  ///
  /// In en, this message translates to:
  /// **'{size} MB'**
  String storageMegabytes(String size);

  /// Row that removes the whole library. Asks twice, the second time for a typed word.
  ///
  /// In en, this message translates to:
  /// **'Delete all data'**
  String get settingsDeleteAll;

  /// Under the Delete all data row.
  ///
  /// In en, this message translates to:
  /// **'Removes every word, note, list and practice record from this phone'**
  String get settingsDeleteAllHint;

  /// Title of the first step of Delete all data.
  ///
  /// In en, this message translates to:
  /// **'Delete everything?'**
  String get deleteAllTitle;

  /// What Delete all data does, with the offer of a backup.
  ///
  /// In en, this message translates to:
  /// **'This removes every word, sound, highlight, note, list and practice record from this phone, and it can\'t be undone. You may want a backup first.'**
  String get deleteAllBody;

  /// Opens Backup & restore instead of deleting.
  ///
  /// In en, this message translates to:
  /// **'Make a backup first'**
  String get deleteAllBackupFirst;

  /// Goes on to the typed confirmation.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get deleteAllContinue;

  /// Title of the typed confirmation for Delete all data.
  ///
  /// In en, this message translates to:
  /// **'Delete all data?'**
  String get deleteAllConfirmTitle;

  /// The last warning before Delete all data.
  ///
  /// In en, this message translates to:
  /// **'Everything on this phone goes, including the copies kept from earlier restores. Without a backup, it can\'t be brought back.'**
  String get deleteAllConfirmBody;

  /// The word the user types to confirm Delete all data (RULES 11). Lower case on purpose; matched without regard to case.
  ///
  /// In en, this message translates to:
  /// **'delete'**
  String get deleteAllConfirmWord;

  /// The button that carries out a confirmed Delete all data.
  ///
  /// In en, this message translates to:
  /// **'Delete everything'**
  String get deleteAllConfirmAction;

  /// Snackbar after Delete all data.
  ///
  /// In en, this message translates to:
  /// **'Everything has been deleted. Schwa Notes is ready for new words.'**
  String get deleteAllDone;

  /// Snackbar when Delete all data failed and was rolled back.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete everything just now. Your words are still here.'**
  String get deleteAllFailed;

  /// Top of the How to use guide.
  ///
  /// In en, this message translates to:
  /// **'Six small things that make Schwa Notes work for you. Tap Try it on any of them to go straight there.'**
  String get guideIntro;

  /// Guide card 1 title.
  ///
  /// In en, this message translates to:
  /// **'Add a word'**
  String get guideAddTitle;

  /// Guide card 1 sentence.
  ///
  /// In en, this message translates to:
  /// **'Tap + on My words and type the word you\'re learning. Saving takes two taps.'**
  String get guideAddBody;

  /// Guide card 2 title.
  ///
  /// In en, this message translates to:
  /// **'Fill it from the dictionary'**
  String get guideLookupTitle;

  /// Guide card 2 sentence.
  ///
  /// In en, this message translates to:
  /// **'Tap Look up to see how it sounds, what it means and an example. Nothing is filled in until you tap the part you want.'**
  String get guideLookupBody;

  /// Guide card 3 title.
  ///
  /// In en, this message translates to:
  /// **'Write the IPA yourself'**
  String get guideIpaTitle;

  /// Guide card 3 sentence.
  ///
  /// In en, this message translates to:
  /// **'The row above the keyboard has every sound English needs. Typing the IPA yourself is one of the best ways to remember it.'**
  String get guideIpaBody;

  /// Guide card 3's honest line about text-to-speech (DATA-SOURCES 4). Required by UI-UX 4.10.
  ///
  /// In en, this message translates to:
  /// **'Tap play to hear the word. The voice is your phone\'s text-to-speech: a good guide to stress and vowels, but not a native speaker.'**
  String get guideIpaVoice;

  /// Guide card 4 title.
  ///
  /// In en, this message translates to:
  /// **'Highlight the sound you struggle with'**
  String get guideHighlightTitle;

  /// Guide card 4 sentence.
  ///
  /// In en, this message translates to:
  /// **'Open a word\'s IPA and mark the sounds you keep getting wrong, in a colour and with a note to yourself.'**
  String get guideHighlightBody;

  /// Guide card 5 title.
  ///
  /// In en, this message translates to:
  /// **'Leave a note for yourself'**
  String get guideNoteTitle;

  /// Guide card 5 sentence.
  ///
  /// In en, this message translates to:
  /// **'Add as many notes to a word as you like - where you heard it, what your mouth should do, what to listen for.'**
  String get guideNoteBody;

  /// Guide card 6 title.
  ///
  /// In en, this message translates to:
  /// **'Practise a little every day'**
  String get guidePractiseTitle;

  /// Guide card 6 sentence.
  ///
  /// In en, this message translates to:
  /// **'A few cards a day beats a long session once a week. The words you find hard come back sooner.'**
  String get guidePractiseBody;

  /// Button on each guide card that opens the real screen.
  ///
  /// In en, this message translates to:
  /// **'Try it'**
  String get guideTryIt;

  /// What a screen reader hears for a card's Try it button, so six buttons are not all just 'Try it'.
  ///
  /// In en, this message translates to:
  /// **'Try it: {title}'**
  String guideTryItFor(String title);

  /// Sample word drawn in the guide's illustrations. An English word in every locale: the app teaches English.
  ///
  /// In en, this message translates to:
  /// **'cough'**
  String get guideSampleWord;

  /// IPA for the sample word. Do not translate; the illustration highlights its second symbol.
  ///
  /// In en, this message translates to:
  /// **'kɒf'**
  String get guideSampleIpa;

  /// Sample part of speech in the guide's dictionary illustration.
  ///
  /// In en, this message translates to:
  /// **'noun'**
  String get guideSamplePartOfSpeech;

  /// Sample definition in the guide's dictionary illustration.
  ///
  /// In en, this message translates to:
  /// **'A sudden, noisy push of air out of the lungs'**
  String get guideSampleDefinition;

  /// Sample highlight label in the guide's illustration.
  ///
  /// In en, this message translates to:
  /// **'Rounder lips here'**
  String get guideSampleHighlightLabel;

  /// Sample note in the guide's illustration.
  ///
  /// In en, this message translates to:
  /// **'Heard it on a podcast. Lips rounder on the ɒ.'**
  String get guideSampleNote;

  /// Sample daily goal beside the ring in the guide's illustration.
  ///
  /// In en, this message translates to:
  /// **'12 of 20 today'**
  String get guideSampleGoal;

  /// On every onboarding slide: leave onboarding for good.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// Goes to the next onboarding slide.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// On the last slide: goes on to the guide.
  ///
  /// In en, this message translates to:
  /// **'See how it works'**
  String get onboardingShowMe;

  /// At the end of the guide during onboarding: leaves onboarding for good.
  ///
  /// In en, this message translates to:
  /// **'Start using Schwa Notes'**
  String get onboardingStart;

  /// What a screen reader hears for the onboarding page dots.
  ///
  /// In en, this message translates to:
  /// **'Page {page} of {count}'**
  String onboardingPage(int page, int count);

  /// Onboarding slide 1 title.
  ///
  /// In en, this message translates to:
  /// **'Note the words you\'re learning'**
  String get onboardingSlide1Title;

  /// Onboarding slide 1 sentence.
  ///
  /// In en, this message translates to:
  /// **'Save each word with how it sounds, what it means, and notes of your own.'**
  String get onboardingSlide1Body;

  /// Onboarding slide 2 title.
  ///
  /// In en, this message translates to:
  /// **'Mark the sounds you find hard'**
  String get onboardingSlide2Title;

  /// Onboarding slide 2 sentence.
  ///
  /// In en, this message translates to:
  /// **'Colour the exact part of the IPA you keep getting wrong, so it catches your eye every time.'**
  String get onboardingSlide2Body;

  /// Onboarding slide 3 title.
  ///
  /// In en, this message translates to:
  /// **'Practise a little, every day'**
  String get onboardingSlide3Title;

  /// Onboarding slide 3 sentence, with the privacy promise in one line.
  ///
  /// In en, this message translates to:
  /// **'Short sessions bring back the words you find hard. Everything stays on this phone: no account, no ads.'**
  String get onboardingSlide3Body;

  /// Hint in the FAQ search field on Help & feedback.
  ///
  /// In en, this message translates to:
  /// **'Search the answers'**
  String get faqSearchHint;

  /// How many FAQ answers are showing. Read out as it changes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 answer} other{{count} answers}}'**
  String faqCount(int count);

  /// When the FAQ search matches nothing.
  ///
  /// In en, this message translates to:
  /// **'No answers mention “{query}”.'**
  String faqNoAnswers(String query);

  /// Clears the FAQ search.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get faqClear;

  /// FAQ question 1.
  ///
  /// In en, this message translates to:
  /// **'Where are my words kept?'**
  String get faqQ1;

  /// FAQ answer 1.
  ///
  /// In en, this message translates to:
  /// **'Only on this phone, in Schwa Notes\'s own private storage. There is no account and no server. To keep a copy anywhere else, make a backup.'**
  String get faqA1;

  /// FAQ question 2.
  ///
  /// In en, this message translates to:
  /// **'How do I move my words to a new phone?'**
  String get faqQ2;

  /// FAQ answer 2.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings → Backup & restore → Export backup, and save the file somewhere your new phone can reach. Then install Schwa Notes there and choose Import backup.'**
  String get faqA2;

  /// FAQ question 3.
  ///
  /// In en, this message translates to:
  /// **'Does Schwa Notes need the internet?'**
  String get faqQ3;

  /// FAQ answer 3.
  ///
  /// In en, this message translates to:
  /// **'No. Everything works offline. Only Look up uses the internet, and all it sends is the word you are looking up.'**
  String get faqA3;

  /// FAQ question 4.
  ///
  /// In en, this message translates to:
  /// **'Why does the voice sound like a computer?'**
  String get faqQ4;

  /// FAQ answer 4. The honest line about TTS (DATA-SOURCES 4).
  ///
  /// In en, this message translates to:
  /// **'It is your phone\'s own text-to-speech: a good guide to stress and vowels, but not a native speaker. You can change the voice, speed and pitch in Settings → Pronunciation.'**
  String get faqA4;

  /// FAQ question 5.
  ///
  /// In en, this message translates to:
  /// **'My phone has no British English voice.'**
  String get faqQ5;

  /// FAQ answer 5.
  ///
  /// In en, this message translates to:
  /// **'Add one in your phone\'s settings, under Text-to-speech on Android or Spoken Content on iPhone. Until then, Schwa Notes uses the closest voice it can find.'**
  String get faqA5;

  /// FAQ question 6.
  ///
  /// In en, this message translates to:
  /// **'How do I type IPA symbols?'**
  String get faqQ6;

  /// FAQ answer 6.
  ///
  /// In en, this message translates to:
  /// **'Tap into an IPA field and a row of symbols appears above the keyboard. Tap a symbol to add it where the cursor is.'**
  String get faqA6;

  /// FAQ question 7.
  ///
  /// In en, this message translates to:
  /// **'What is IPA?'**
  String get faqQ7;

  /// FAQ answer 7.
  ///
  /// In en, this message translates to:
  /// **'The International Phonetic Alphabet: one symbol for each sound, so a pronunciation is written down exactly - /kɒf/ rather than \"coff\".'**
  String get faqA7;

  /// FAQ question 8.
  ///
  /// In en, this message translates to:
  /// **'How do highlights work?'**
  String get faqQ8;

  /// FAQ answer 8.
  ///
  /// In en, this message translates to:
  /// **'Open a word, tap Edit IPA highlights, choose the symbols you struggle with and pick a colour. A short label, like \"lips rounder\", helps too.'**
  String get faqA8;

  /// FAQ question 9.
  ///
  /// In en, this message translates to:
  /// **'How does practice decide what comes back?'**
  String get faqQ9;

  /// FAQ answer 9.
  ///
  /// In en, this message translates to:
  /// **'Each word sits in a box. Know it and it moves up a box and waits longer; miss it and it comes back later the same day. You can change the gaps in Settings → Practice.'**
  String get faqA9;

  /// FAQ question 10.
  ///
  /// In en, this message translates to:
  /// **'What\'s the difference between Daily review and Quick test?'**
  String get faqQ10;

  /// FAQ answer 10.
  ///
  /// In en, this message translates to:
  /// **'Daily review shows the words that are due, and your answers decide when each comes back. A quick test is just for practice: it never changes that.'**
  String get faqA10;

  /// FAQ question 11.
  ///
  /// In en, this message translates to:
  /// **'I deleted a word by mistake.'**
  String get faqQ11;

  /// FAQ answer 11.
  ///
  /// In en, this message translates to:
  /// **'Tap Undo on the message that appears straight away. After that, importing a backup made before you deleted it will bring it back.'**
  String get faqA11;

  /// FAQ question 12.
  ///
  /// In en, this message translates to:
  /// **'Where do the definitions come from?'**
  String get faqQ12;

  /// FAQ answer 12.
  ///
  /// In en, this message translates to:
  /// **'From Wiktionary, through FreeDictionaryAPI.com, shared under CC BY-SA 4.0. Offline pronunciations come from the CMU Pronouncing Dictionary. Settings → Data sources & licences has the details.'**
  String get faqA12;

  /// Heading above the ways to reach a person.
  ///
  /// In en, this message translates to:
  /// **'Still stuck?'**
  String get helpStillStuck;

  /// Row that opens the feedback preview. Shown only when a feedback address is configured.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get feedbackSend;

  /// Under Send feedback.
  ///
  /// In en, this message translates to:
  /// **'Opens your email app. You\'ll see what\'s included first.'**
  String get feedbackSendHint;

  /// Row that opens the project's GitHub Issues in the browser.
  ///
  /// In en, this message translates to:
  /// **'Report a problem on GitHub'**
  String get helpGitHub;

  /// Under Report a problem on GitHub.
  ///
  /// In en, this message translates to:
  /// **'Opens the project\'s issue page in your browser'**
  String get helpGitHubHint;

  /// Row that shows the on-device error log (F-079).
  ///
  /// In en, this message translates to:
  /// **'View error log'**
  String get helpErrorLog;

  /// Under View error log.
  ///
  /// In en, this message translates to:
  /// **'Kept on this phone, never sent by itself'**
  String get helpErrorLogHint;

  /// Snackbar when a link could not be opened.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open that link.'**
  String get helpLinkFailed;

  /// Title of the feedback preview.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get feedbackPreviewTitle;

  /// Above the preview of the email body.
  ///
  /// In en, this message translates to:
  /// **'Your email app will open with this, addressed to {address}:'**
  String feedbackPreviewIntro(String address);

  /// Subject of the feedback email.
  ///
  /// In en, this message translates to:
  /// **'Schwa Notes feedback'**
  String get feedbackSubject;

  /// First line of the feedback email body, where the user types.
  ///
  /// In en, this message translates to:
  /// **'Write your message here.'**
  String get feedbackBodyPrompt;

  /// Separates the user's message from the details below it.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get feedbackBodyDivider;

  /// Feedback email line.
  ///
  /// In en, this message translates to:
  /// **'App version: {version}'**
  String feedbackAppVersion(String version);

  /// Feedback email line.
  ///
  /// In en, this message translates to:
  /// **'OS: {os}'**
  String feedbackOsVersion(String os);

  /// Feedback email line: the phone's model, never its name.
  ///
  /// In en, this message translates to:
  /// **'Device: {model}'**
  String feedbackDeviceModel(String model);

  /// In the feedback email when a detail could not be read.
  ///
  /// In en, this message translates to:
  /// **'unknown'**
  String get feedbackUnknown;

  /// Heading above the attached error log in the feedback email.
  ///
  /// In en, this message translates to:
  /// **'Error log (newest entries):'**
  String get feedbackLogHeading;

  /// Checkbox in the feedback preview. Unticked by default.
  ///
  /// In en, this message translates to:
  /// **'Include the error log'**
  String get feedbackIncludeLog;

  /// The promise under the feedback preview (F-072).
  ///
  /// In en, this message translates to:
  /// **'Nothing else is included.'**
  String get feedbackNothingElse;

  /// Opens the user's mail app with the previewed email.
  ///
  /// In en, this message translates to:
  /// **'Open email'**
  String get feedbackOpenEmail;

  /// Snackbar when no mail app could be opened.
  ///
  /// In en, this message translates to:
  /// **'No email app opened. You can write to {address} from any email account.'**
  String feedbackNoMailApp(String address);

  /// Title of the error log sheet.
  ///
  /// In en, this message translates to:
  /// **'Error log'**
  String get errorLogTitle;

  /// Top of the error log sheet.
  ///
  /// In en, this message translates to:
  /// **'Problems Schwa Notes ran into, kept only on this phone. Nothing here is ever sent by itself.'**
  String get errorLogIntro;

  /// When the error log is empty.
  ///
  /// In en, this message translates to:
  /// **'Nothing has gone wrong. If something does, a short note appears here - it stays on this phone unless you attach it to feedback.'**
  String get errorLogEmpty;

  /// While the error log is being read.
  ///
  /// In en, this message translates to:
  /// **'Reading…'**
  String get errorLogReading;

  /// Empties the error log.
  ///
  /// In en, this message translates to:
  /// **'Clear log'**
  String get errorLogClear;

  /// About row that opens the privacy note (F-076).
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settingsPrivacy;

  /// Under the Privacy row.
  ///
  /// In en, this message translates to:
  /// **'What leaves your phone, and when'**
  String get settingsPrivacyHint;

  /// Last row of About, shown only when the build has a Ko-fi page. Opens it in the browser.
  ///
  /// In en, this message translates to:
  /// **'Buy me a coffee'**
  String get settingsSupport;

  /// Under the Buy me a coffee row. Must stay true: the tip changes nothing in the app.
  ///
  /// In en, this message translates to:
  /// **'Schwa Notes is free. A tip on Ko-fi is kind, unlocks nothing, and is never expected.'**
  String get settingsSupportHint;

  /// Heading of the privacy note.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacyHeading;

  /// F-076, word for word. Must match FEATURES F-076, DATA-SOURCES 7 and the store privacy declarations; change all in the same PR.
  ///
  /// In en, this message translates to:
  /// **'Schwa Notes has no account and no analytics. Your words never leave your phone unless you export them. Looking up a word sends only that word to freedictionaryapi.com.'**
  String get privacyNote;

  /// Privacy point (DATA-SOURCES 7).
  ///
  /// In en, this message translates to:
  /// **'No account, no sign-in, and no server of ours.'**
  String get privacyPoint1;

  /// Privacy point (DATA-SOURCES 7).
  ///
  /// In en, this message translates to:
  /// **'No analytics, no ads, no tracking, and no advertising ID.'**
  String get privacyPoint2;

  /// Privacy point (DATA-SOURCES 7).
  ///
  /// In en, this message translates to:
  /// **'Schwa Notes reaches the internet only when you ask it to: to look up a word, or to open a link you tapped, in your browser.'**
  String get privacyPoint3;

  /// Privacy point (DATA-SOURCES 7).
  ///
  /// In en, this message translates to:
  /// **'Feedback is written in your own email app. You see what it includes before it opens, and nothing else is attached unless you choose to add the error log.'**
  String get privacyPoint4;

  /// Privacy point (DATA-SOURCES 7).
  ///
  /// In en, this message translates to:
  /// **'Your words, IPA, highlights, notes and practice history stay on this phone, and leave it only in a backup you export.'**
  String get privacyPoint5;

  /// Licences section heading.
  ///
  /// In en, this message translates to:
  /// **'Dictionary look-up'**
  String get licencesDictionaryHeading;

  /// Attribution for dictionary content (CC BY-SA 4.0: attribute, name the licence, no implied endorsement).
  ///
  /// In en, this message translates to:
  /// **'Definitions, examples and pronunciations you choose from Look up come from Wiktionary, shared under the CC BY-SA 4.0 licence through FreeDictionaryAPI.com. Each word keeps a link to its source page. Neither Wiktionary nor FreeDictionaryAPI.com endorses Schwa Notes.'**
  String get licencesDictionaryBody;

  /// Link to Wiktionary.
  ///
  /// In en, this message translates to:
  /// **'Wiktionary'**
  String get licencesWiktionary;

  /// Link to FreeDictionaryAPI.com.
  ///
  /// In en, this message translates to:
  /// **'FreeDictionaryAPI.com'**
  String get licencesFreeDictionary;

  /// Link to the CC BY-SA 4.0 licence.
  ///
  /// In en, this message translates to:
  /// **'CC BY-SA 4.0 licence'**
  String get licencesCcBySa;

  /// Licences section heading.
  ///
  /// In en, this message translates to:
  /// **'Offline pronunciations'**
  String get licencesOfflineHeading;

  /// Acknowledgement of CMUdict (DATA-SOURCES 2).
  ///
  /// In en, this message translates to:
  /// **'When there is no internet, US pronunciations come from the CMU Pronouncing Dictionary, made at Carnegie Mellon University and free for any use.'**
  String get licencesOfflineBody;

  /// Link to CMUdict.
  ///
  /// In en, this message translates to:
  /// **'CMU Pronouncing Dictionary'**
  String get licencesCmudict;

  /// Licences section heading.
  ///
  /// In en, this message translates to:
  /// **'Fonts'**
  String get licencesFontsHeading;

  /// The bundled fonts and their licence (DATA-SOURCES 5).
  ///
  /// In en, this message translates to:
  /// **'Inter for the words on screen, and Charis SIL for IPA - both shared under the SIL Open Font License 1.1.'**
  String get licencesFontsBody;

  /// Font name. Not translated.
  ///
  /// In en, this message translates to:
  /// **'Inter'**
  String get licencesInter;

  /// Font name. Not translated.
  ///
  /// In en, this message translates to:
  /// **'Charis SIL'**
  String get licencesCharis;

  /// Licence name. Not translated.
  ///
  /// In en, this message translates to:
  /// **'SIL Open Font License 1.1'**
  String get licencesOflName;

  /// Opens a bundled font's licence text.
  ///
  /// In en, this message translates to:
  /// **'View licence'**
  String get licencesViewLicence;

  /// What a screen reader hears for View licence.
  ///
  /// In en, this message translates to:
  /// **'View the licence for {font}'**
  String licencesViewLicenceFor(String font);

  /// While a licence text loads.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get licencesLoading;

  /// Licences section heading.
  ///
  /// In en, this message translates to:
  /// **'Software'**
  String get licencesPackagesHeading;

  /// Above the button to the full package licence list.
  ///
  /// In en, this message translates to:
  /// **'Schwa Notes is built with open-source packages, all under permissive licences.'**
  String get licencesPackagesBody;

  /// Opens Flutter's licence page.
  ///
  /// In en, this message translates to:
  /// **'All package licences'**
  String get licencesPackages;

  /// The recovery screen's export button while the file is being written.
  ///
  /// In en, this message translates to:
  /// **'Exporting…'**
  String get recoveryExporting;

  /// Snackbar when the recovery export failed. Reassures first: the database was only read.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t make the export just now. Your data is still on this phone, untouched.'**
  String get recoveryExportFailed;

  /// Row showing the app version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// Title of the session summary screen.
  ///
  /// In en, this message translates to:
  /// **'How that went'**
  String get summaryTitle;

  /// Heading above the words the user got wrong. Never 'wrong' (UI-UX 4.8).
  ///
  /// In en, this message translates to:
  /// **'Worth another look'**
  String get summaryMissedHeading;

  /// Button that adds every missed word to a chosen list.
  ///
  /// In en, this message translates to:
  /// **'Add these to a list'**
  String get summaryAddMissed;

  /// Button that leaves the summary.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get summaryDone;

  /// Button on the summary that starts another session with the same choices (UI-UX 4.8).
  ///
  /// In en, this message translates to:
  /// **'Practise again'**
  String get summaryPractiseAgain;

  /// Shown when the summary is opened with no session in memory.
  ///
  /// In en, this message translates to:
  /// **'That session has finished'**
  String get summaryMissingTitle;

  /// Body when there is no session to summarise. Reassures that nothing was lost.
  ///
  /// In en, this message translates to:
  /// **'Your answers were saved as you went. Start another whenever you like.'**
  String get summaryMissingBody;

  /// The score line. Warm, never a grade.
  ///
  /// In en, this message translates to:
  /// **'Nice work - {correct} of {total}'**
  String summaryScore(int correct, int total);

  /// How long the session took.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m {seconds}s'**
  String summaryTime(int minutes, int seconds);

  /// Snackbar after adding missed words to a list.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 word added to {name}} other{{count} words added to {name}}}'**
  String summaryAddedToList(int count, String name);

  /// Empty state title on the lists grid.
  ///
  /// In en, this message translates to:
  /// **'No lists yet'**
  String get listsEmptyTitle;

  /// Empty state body on the lists grid.
  ///
  /// In en, this message translates to:
  /// **'Lists group words however you like - a course, a topic, the sounds you keep getting wrong.'**
  String get listsEmptyBody;

  /// Button that creates a list.
  ///
  /// In en, this message translates to:
  /// **'New list'**
  String get newListAction;

  /// Title of the sheet that creates a list.
  ///
  /// In en, this message translates to:
  /// **'New list'**
  String get createListTitle;

  /// Title of the sheet that renames or recolours a list.
  ///
  /// In en, this message translates to:
  /// **'Edit list'**
  String get editListTitle;

  /// Text field label for a list name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get listNameLabel;

  /// Example list name shown in the empty field.
  ///
  /// In en, this message translates to:
  /// **'IELTS speaking'**
  String get listNameHint;

  /// Validation message when a list name is blank.
  ///
  /// In en, this message translates to:
  /// **'Give the list a name.'**
  String get listNameRequired;

  /// Menu item that moves a list one place earlier in the grid.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get moveListUpAction;

  /// Menu item that moves a list one place later in the grid.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get moveListDownAction;

  /// Menu item that edits a list.
  ///
  /// In en, this message translates to:
  /// **'Rename or recolour'**
  String get renameListAction;

  /// Menu item that deletes a list.
  ///
  /// In en, this message translates to:
  /// **'Delete list'**
  String get deleteListAction;

  /// Title of the delete-list confirmation.
  ///
  /// In en, this message translates to:
  /// **'Delete this list?'**
  String get deleteListTitle;

  /// Body of the delete-list confirmation. States plainly that words survive (F-042).
  ///
  /// In en, this message translates to:
  /// **'The list goes, but every word in it stays in your words.'**
  String get deleteListBody;

  /// Screen-reader label for the button that opens a list's actions.
  ///
  /// In en, this message translates to:
  /// **'Actions for {name}'**
  String listActionsLabel(String name);

  /// App bar action on a list's detail screen.
  ///
  /// In en, this message translates to:
  /// **'Practise this list'**
  String get practiseListAction;

  /// Menu item that edits an existing note.
  ///
  /// In en, this message translates to:
  /// **'Edit note'**
  String get editNoteAction;

  /// Button that saves an edited note.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveNoteAction;

  /// Word count on a list card.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No words} =1{1 word} other{{count} words}}'**
  String listWordCount(int count);

  /// Due-today badge on a list card.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 due} other{{count} due}}'**
  String listDueCount(int count);

  /// Screen-reader label for a filter chip that shows a word count.
  ///
  /// In en, this message translates to:
  /// **'{label}, {count, plural, =1{1 word} other{{count} words}}'**
  String filterCountLabel(String label, int count);

  /// Screen-reader label for the note count on a word row.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 note} other{{count} notes}}'**
  String wordNoteCountLabel(int count);

  /// Accessibility label for the star button when the word is not a favourite.
  ///
  /// In en, this message translates to:
  /// **'Add {word} to favourites'**
  String wordFavouriteLabel(String word);

  /// Accessibility label for the star button when the word is already a favourite.
  ///
  /// In en, this message translates to:
  /// **'Remove {word} from favourites'**
  String wordUnfavouriteLabel(String word);

  /// Heading when the words list fails to load.
  ///
  /// In en, this message translates to:
  /// **'We could not load your words'**
  String get wordsLoadFailedTitle;

  /// Body when the words list fails to load.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong reading your database. Nothing has been lost.'**
  String get wordsLoadFailedBody;

  /// Menu item that deletes a word.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteWordAction;

  /// Snackbar shown after deleting a word.
  ///
  /// In en, this message translates to:
  /// **'Deleted {word}'**
  String wordDeletedSnack(String word);

  /// Button that restores a just-deleted word.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undoAction;

  /// App bar title when adding a word.
  ///
  /// In en, this message translates to:
  /// **'Add word'**
  String get editorTitleAdd;

  /// App bar title when editing a word.
  ///
  /// In en, this message translates to:
  /// **'Edit word'**
  String get editorTitleEdit;

  /// App bar action that saves the form.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveAction;

  /// Generic cancel button.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelAction;

  /// Label for the headword field.
  ///
  /// In en, this message translates to:
  /// **'Word'**
  String get fieldWord;

  /// Hint for the headword field.
  ///
  /// In en, this message translates to:
  /// **'The word you are studying'**
  String get fieldWordHint;

  /// Button that queries the dictionary for the typed word.
  ///
  /// In en, this message translates to:
  /// **'Look up'**
  String get lookUpAction;

  /// Quiet subtitle under the Look up button.
  ///
  /// In en, this message translates to:
  /// **'optional - typing it yourself helps you remember'**
  String get lookUpHint;

  /// Label for the British pronunciation field.
  ///
  /// In en, this message translates to:
  /// **'IPA (UK)'**
  String get fieldIpaUk;

  /// Label for the American pronunciation field.
  ///
  /// In en, this message translates to:
  /// **'IPA (US)'**
  String get fieldIpaUs;

  /// Label for the part-of-speech chips.
  ///
  /// In en, this message translates to:
  /// **'Part of speech'**
  String get fieldPartOfSpeech;

  /// Label for the definition field.
  ///
  /// In en, this message translates to:
  /// **'Definition'**
  String get fieldDefinition;

  /// Label for the example sentence field.
  ///
  /// In en, this message translates to:
  /// **'Example'**
  String get fieldExample;

  /// Label for the first-note field, shown only when adding.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get fieldNote;

  /// Hint for the first-note field.
  ///
  /// In en, this message translates to:
  /// **'Something to remind yourself'**
  String get fieldNoteHint;

  /// Label for the list-membership chips.
  ///
  /// In en, this message translates to:
  /// **'Add to lists'**
  String get fieldLists;

  /// Shown in place of list chips when the user has no lists.
  ///
  /// In en, this message translates to:
  /// **'No lists yet'**
  String get fieldListsEmpty;

  /// Part-of-speech chip.
  ///
  /// In en, this message translates to:
  /// **'noun'**
  String get posNoun;

  /// Part-of-speech chip.
  ///
  /// In en, this message translates to:
  /// **'verb'**
  String get posVerb;

  /// Part-of-speech chip.
  ///
  /// In en, this message translates to:
  /// **'adjective'**
  String get posAdjective;

  /// Part-of-speech chip.
  ///
  /// In en, this message translates to:
  /// **'adverb'**
  String get posAdverb;

  /// Part-of-speech chip for anything else.
  ///
  /// In en, this message translates to:
  /// **'other'**
  String get posOther;

  /// Accessibility label for the row of IPA symbol buttons above the keyboard.
  ///
  /// In en, this message translates to:
  /// **'IPA symbols'**
  String get ipaKeyboardLabel;

  /// Accessibility label for one IPA symbol button.
  ///
  /// In en, this message translates to:
  /// **'Insert {symbol}'**
  String ipaSymbolLabel(String symbol);

  /// What a screen reader says for a transcription: the sounds it spells, by their learner names (UI-UX §6).
  ///
  /// In en, this message translates to:
  /// **'pronunciation: {sounds}'**
  String ipaSpokenPronunciation(String sounds);

  /// Between two sound names in a spoken transcription.
  ///
  /// In en, this message translates to:
  /// **', '**
  String get ipaSoundSeparator;

  /// Spoken name of the IPA sound p.
  ///
  /// In en, this message translates to:
  /// **'p'**
  String get ipaSoundP;

  /// Spoken name of the IPA sound b.
  ///
  /// In en, this message translates to:
  /// **'b'**
  String get ipaSoundB;

  /// Spoken name of the IPA sound t.
  ///
  /// In en, this message translates to:
  /// **'t'**
  String get ipaSoundT;

  /// Spoken name of the IPA sound d.
  ///
  /// In en, this message translates to:
  /// **'d'**
  String get ipaSoundD;

  /// Spoken name of the IPA sound k.
  ///
  /// In en, this message translates to:
  /// **'k'**
  String get ipaSoundK;

  /// Spoken name of the IPA sound ɡ.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get ipaSoundG;

  /// Spoken name of the IPA sound f.
  ///
  /// In en, this message translates to:
  /// **'f'**
  String get ipaSoundF;

  /// Spoken name of the IPA sound v.
  ///
  /// In en, this message translates to:
  /// **'v'**
  String get ipaSoundV;

  /// Spoken name of the IPA sound θ.
  ///
  /// In en, this message translates to:
  /// **'th as in thin'**
  String get ipaSoundThVoiceless;

  /// Spoken name of the IPA sound ð.
  ///
  /// In en, this message translates to:
  /// **'th as in this'**
  String get ipaSoundThVoiced;

  /// Spoken name of the IPA sound s.
  ///
  /// In en, this message translates to:
  /// **'s'**
  String get ipaSoundS;

  /// Spoken name of the IPA sound z.
  ///
  /// In en, this message translates to:
  /// **'z'**
  String get ipaSoundZ;

  /// Spoken name of the IPA sound ʃ.
  ///
  /// In en, this message translates to:
  /// **'sh'**
  String get ipaSoundSh;

  /// Spoken name of the IPA sound ʒ.
  ///
  /// In en, this message translates to:
  /// **'zh as in measure'**
  String get ipaSoundZh;

  /// Spoken name of the IPA sound tʃ.
  ///
  /// In en, this message translates to:
  /// **'ch'**
  String get ipaSoundCh;

  /// Spoken name of the IPA sound dʒ.
  ///
  /// In en, this message translates to:
  /// **'j'**
  String get ipaSoundJudge;

  /// Spoken name of the IPA sound h.
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get ipaSoundH;

  /// Spoken name of the IPA sound m.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get ipaSoundM;

  /// Spoken name of the IPA sound n.
  ///
  /// In en, this message translates to:
  /// **'n'**
  String get ipaSoundN;

  /// Spoken name of the IPA sound ŋ.
  ///
  /// In en, this message translates to:
  /// **'ng as in sing'**
  String get ipaSoundNg;

  /// Spoken name of the IPA sound l.
  ///
  /// In en, this message translates to:
  /// **'l'**
  String get ipaSoundL;

  /// Spoken name of the IPA sound r (ɹ).
  ///
  /// In en, this message translates to:
  /// **'r'**
  String get ipaSoundR;

  /// Spoken name of the IPA sound j.
  ///
  /// In en, this message translates to:
  /// **'y as in yes'**
  String get ipaSoundYes;

  /// Spoken name of the IPA sound w.
  ///
  /// In en, this message translates to:
  /// **'w'**
  String get ipaSoundW;

  /// Spoken name of the IPA vowel iː.
  ///
  /// In en, this message translates to:
  /// **'long e as in see'**
  String get ipaSoundFleece;

  /// Spoken name of the IPA vowel i.
  ///
  /// In en, this message translates to:
  /// **'e as in happy'**
  String get ipaSoundHappy;

  /// Spoken name of the IPA vowel ɪ.
  ///
  /// In en, this message translates to:
  /// **'short i as in sit'**
  String get ipaSoundKit;

  /// Spoken name of the IPA vowel e / ɛ.
  ///
  /// In en, this message translates to:
  /// **'short e as in bed'**
  String get ipaSoundDress;

  /// Spoken name of the IPA vowel æ.
  ///
  /// In en, this message translates to:
  /// **'short a as in cat'**
  String get ipaSoundTrap;

  /// Spoken name of the IPA vowel ʌ.
  ///
  /// In en, this message translates to:
  /// **'short u as in cup'**
  String get ipaSoundStrut;

  /// Spoken name of the IPA vowel ɑː / ɑ.
  ///
  /// In en, this message translates to:
  /// **'a as in father'**
  String get ipaSoundPalm;

  /// Spoken name of the IPA vowel ɒ.
  ///
  /// In en, this message translates to:
  /// **'short o as in hot'**
  String get ipaSoundLot;

  /// Spoken name of the IPA vowel ɔː / ɔ.
  ///
  /// In en, this message translates to:
  /// **'aw as in saw'**
  String get ipaSoundThought;

  /// Spoken name of the IPA vowel ʊ.
  ///
  /// In en, this message translates to:
  /// **'short oo as in book'**
  String get ipaSoundFoot;

  /// Spoken name of the IPA vowel uː / u.
  ///
  /// In en, this message translates to:
  /// **'long oo as in food'**
  String get ipaSoundGoose;

  /// Spoken name of the IPA vowel ɜː / ɝ.
  ///
  /// In en, this message translates to:
  /// **'er as in her'**
  String get ipaSoundNurse;

  /// Spoken name of the IPA vowel ə (schwa).
  ///
  /// In en, this message translates to:
  /// **'uh as in about'**
  String get ipaSoundComma;

  /// Spoken name of the IPA vowel ɚ.
  ///
  /// In en, this message translates to:
  /// **'er as in butter'**
  String get ipaSoundLetter;

  /// Spoken name of the IPA vowel eɪ.
  ///
  /// In en, this message translates to:
  /// **'ay as in day'**
  String get ipaSoundFace;

  /// Spoken name of the IPA vowel aɪ.
  ///
  /// In en, this message translates to:
  /// **'long i as in my'**
  String get ipaSoundPrice;

  /// Spoken name of the IPA vowel ɔɪ.
  ///
  /// In en, this message translates to:
  /// **'oy as in boy'**
  String get ipaSoundChoice;

  /// Spoken name of the IPA vowel əʊ / oʊ.
  ///
  /// In en, this message translates to:
  /// **'long o as in go'**
  String get ipaSoundGoat;

  /// Spoken name of the IPA vowel aʊ.
  ///
  /// In en, this message translates to:
  /// **'ow as in now'**
  String get ipaSoundMouth;

  /// Spoken name of the IPA vowel ɪə.
  ///
  /// In en, this message translates to:
  /// **'ear as in near'**
  String get ipaSoundNear;

  /// Spoken name of the IPA vowel eə / ɛə.
  ///
  /// In en, this message translates to:
  /// **'air as in hair'**
  String get ipaSoundSquare;

  /// Spoken name of the IPA vowel ʊə.
  ///
  /// In en, this message translates to:
  /// **'oor as in poor'**
  String get ipaSoundCure;

  /// Spoken for the IPA stress mark ˈ, before the stressed syllable.
  ///
  /// In en, this message translates to:
  /// **'stress'**
  String get ipaSoundPrimaryStress;

  /// Spoken for the IPA secondary stress mark ˌ.
  ///
  /// In en, this message translates to:
  /// **'light stress'**
  String get ipaSoundSecondaryStress;

  /// Spoken for an IPA length mark ː that is not part of a long vowel.
  ///
  /// In en, this message translates to:
  /// **'long'**
  String get ipaSoundLong;

  /// Non-blocking banner shown when the typed word already exists.
  ///
  /// In en, this message translates to:
  /// **'You already have {word}'**
  String duplicateBanner(String word);

  /// Button in the duplicate banner that opens the existing word.
  ///
  /// In en, this message translates to:
  /// **'Open it'**
  String get duplicateBannerOpen;

  /// Button in the duplicate banner that dismisses it and lets the user save anyway.
  ///
  /// In en, this message translates to:
  /// **'Keep both'**
  String get duplicateBannerDismiss;

  /// Shown while a dictionary look-up is in flight.
  ///
  /// In en, this message translates to:
  /// **'Looking up {word}...'**
  String lookupSearching(String word);

  /// Heading of the look-up results card.
  ///
  /// In en, this message translates to:
  /// **'From the dictionary'**
  String get lookupResultsTitle;

  /// Shown when the dictionary has no entry.
  ///
  /// In en, this message translates to:
  /// **'No entry found for {word}. You can still type it in yourself.'**
  String lookupNoResults(String word);

  /// Quiet inline message when a look-up fails. The form stays fully usable.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the dictionary - you can still type it in.'**
  String get lookupFailed;

  /// Button that hides the look-up results card.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get lookupDismiss;

  /// Link to the Wiktionary page a result came from.
  ///
  /// In en, this message translates to:
  /// **'View source'**
  String get lookupViewSource;

  /// Attribution line under look-up results.
  ///
  /// In en, this message translates to:
  /// **'{source} - {license}'**
  String lookupAttributionLine(String source, String license);

  /// Badge on a suggestion that came from the bundled offline dictionary.
  ///
  /// In en, this message translates to:
  /// **'offline'**
  String get lookupOfflineBadge;

  /// Accessibility label for a suggestion chip.
  ///
  /// In en, this message translates to:
  /// **'Use {value}'**
  String lookupApplyLabel(String value);

  /// Title of the dialog shown before a suggestion overwrites typed text.
  ///
  /// In en, this message translates to:
  /// **'Replace what you typed?'**
  String get overwriteTitle;

  /// Body of the overwrite confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'This will replace {current} with {replacement}.'**
  String overwriteBody(String current, String replacement);

  /// Confirm button in the overwrite dialog.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get overwriteReplace;

  /// Cancel button in the overwrite dialog.
  ///
  /// In en, this message translates to:
  /// **'Keep mine'**
  String get overwriteKeep;

  /// Short label on the British transcription row of the word detail screen.
  ///
  /// In en, this message translates to:
  /// **'UK'**
  String get detailAccentUk;

  /// Short label on the American transcription row of the word detail screen.
  ///
  /// In en, this message translates to:
  /// **'US'**
  String get detailAccentUs;

  /// Accessibility label for the play button on a transcription row.
  ///
  /// In en, this message translates to:
  /// **'Play {word} in {accent}'**
  String detailPlayLabel(String word, String accent);

  /// Accessibility label for the slow replay, reached by long-pressing play.
  ///
  /// In en, this message translates to:
  /// **'Play {word} slowly in {accent}'**
  String detailPlaySlowLabel(String word, String accent);

  /// Accessibility label for the play button while it is speaking.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get detailStopLabel;

  /// Announced while a word is being spoken.
  ///
  /// In en, this message translates to:
  /// **'Speaking {word}'**
  String detailPlayingLabel(String word);

  /// Hint under the play buttons explaining the long-press slow replay.
  ///
  /// In en, this message translates to:
  /// **'Hold to hear it slowly'**
  String get detailSlowHint;

  /// Shown when the device speech engine could not speak the word.
  ///
  /// In en, this message translates to:
  /// **'This device has no speech voice available.'**
  String get detailSpeechFailed;

  /// Button that opens the operating system voice settings.
  ///
  /// In en, this message translates to:
  /// **'Voice settings'**
  String get detailSpeechSettingsAction;

  /// Heading shown on word detail when neither transcription is filled in.
  ///
  /// In en, this message translates to:
  /// **'No pronunciation yet'**
  String get detailNoIpaTitle;

  /// Body shown on word detail when neither transcription is filled in.
  ///
  /// In en, this message translates to:
  /// **'Add a transcription to hear this word and to colour the sounds you find hard.'**
  String get detailNoIpaBody;

  /// Button that opens the word editor to add a transcription.
  ///
  /// In en, this message translates to:
  /// **'Add pronunciation'**
  String get detailAddIpaAction;

  /// Button that opens the IPA highlight editor from word detail.
  ///
  /// In en, this message translates to:
  /// **'Edit IPA highlights'**
  String get detailEditHighlightsAction;

  /// Heading of the notes section on word detail.
  ///
  /// In en, this message translates to:
  /// **'My notes'**
  String get detailNotesHeading;

  /// Button that adds a note to the word.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get detailAddNoteAction;

  /// Shown in the notes section when the word has none.
  ///
  /// In en, this message translates to:
  /// **'No notes yet.'**
  String get detailNoNotesBody;

  /// Accessibility label for removing one note.
  ///
  /// In en, this message translates to:
  /// **'Delete note'**
  String get detailNoteDeleteAction;

  /// Confirmation shown after a note is removed.
  ///
  /// In en, this message translates to:
  /// **'Note deleted'**
  String get detailNoteDeletedSnack;

  /// Title of the sheet that adds a note.
  ///
  /// In en, this message translates to:
  /// **'Add a note'**
  String get detailNoteHeading;

  /// Heading shown when the word being viewed no longer exists.
  ///
  /// In en, this message translates to:
  /// **'This word is gone'**
  String get detailNotFoundTitle;

  /// Body shown when the word being viewed no longer exists.
  ///
  /// In en, this message translates to:
  /// **'It was deleted. You can undo a deletion from the words list for a few seconds.'**
  String get detailNotFoundBody;

  /// Heading shown when the word detail screen fails to load.
  ///
  /// In en, this message translates to:
  /// **'Could not open this word'**
  String get detailLoadFailedTitle;

  /// Body shown when the word detail screen fails to load.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong reading it from your device.'**
  String get detailLoadFailedBody;

  /// Button that opens the word editor from word detail.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get detailEditAction;

  /// Heading above the list of labelled IPA highlights on word detail.
  ///
  /// In en, this message translates to:
  /// **'Sounds you marked'**
  String get detailLegendHeading;

  /// One legend line: the colour name and the label the user wrote.
  ///
  /// In en, this message translates to:
  /// **'{color}: {label}'**
  String detailLegendEntry(String color, String label);

  /// Accessibility label for a tappable legend line.
  ///
  /// In en, this message translates to:
  /// **'Show {label} in the transcription'**
  String detailLegendJumpLabel(String label);

  /// Name of the amber IPA highlight colour. Shown as text so colour is never the only cue.
  ///
  /// In en, this message translates to:
  /// **'amber'**
  String get ipaColorAmber;

  /// Name of the coral IPA highlight colour.
  ///
  /// In en, this message translates to:
  /// **'coral'**
  String get ipaColorCoral;

  /// Name of the violet IPA highlight colour.
  ///
  /// In en, this message translates to:
  /// **'violet'**
  String get ipaColorViolet;

  /// Name of the teal IPA highlight colour.
  ///
  /// In en, this message translates to:
  /// **'teal'**
  String get ipaColorTeal;

  /// Name of the blue IPA highlight colour.
  ///
  /// In en, this message translates to:
  /// **'blue'**
  String get ipaColorBlue;

  /// Button that opens the word on dictionary.cambridge.org in the browser.
  ///
  /// In en, this message translates to:
  /// **'Open in Cambridge Dictionary'**
  String get detailCambridgeAction;

  /// Shown when no app on the device could open the dictionary link.
  ///
  /// In en, this message translates to:
  /// **'Could not open your browser.'**
  String get detailCambridgeFailed;

  /// Instruction at the top of the IPA highlight editor.
  ///
  /// In en, this message translates to:
  /// **'Tap a symbol, or drag across several, then choose a colour.'**
  String get ipaEditorIntro;

  /// Announced when a run of IPA symbols is selected. UI-UX section 4.4.
  ///
  /// In en, this message translates to:
  /// **'selected {symbols}'**
  String ipaEditorSelectedLabel(String symbols);

  /// Shown where the selection would be announced, before anything is chosen.
  ///
  /// In en, this message translates to:
  /// **'Nothing selected yet'**
  String get ipaEditorNothingSelected;

  /// App bar action that saves the highlight session.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get ipaEditorDoneAction;

  /// App bar action that steps back one change in the editor.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get ipaEditorUndoAction;

  /// Title of the sheet that colours the selected run.
  ///
  /// In en, this message translates to:
  /// **'Colour this sound'**
  String get ipaEditorColorHeading;

  /// Hint on the optional label field in the colour sheet.
  ///
  /// In en, this message translates to:
  /// **'Why is it hard? (optional)'**
  String get ipaEditorLabelHint;

  /// Button that removes the highlight being edited.
  ///
  /// In en, this message translates to:
  /// **'Delete highlight'**
  String get ipaEditorDeleteAction;

  /// Accessibility label for one colour swatch.
  ///
  /// In en, this message translates to:
  /// **'Use {color}'**
  String ipaEditorColorLabel(String color);

  /// Shown when writing the highlight session to the database failed.
  ///
  /// In en, this message translates to:
  /// **'Could not save your highlights.'**
  String get ipaEditorSaveFailed;

  /// Heading when the editor is opened for a word with no transcription.
  ///
  /// In en, this message translates to:
  /// **'Nothing to highlight yet'**
  String get ipaEditorNoIpaTitle;

  /// Body when the editor is opened for a word with no transcription.
  ///
  /// In en, this message translates to:
  /// **'Add a transcription first, then come back to colour the sounds you find hard.'**
  String get ipaEditorNoIpaBody;

  /// Title of the confirmation shown when leaving the editor unsaved.
  ///
  /// In en, this message translates to:
  /// **'Discard your colours?'**
  String get ipaEditorDiscardTitle;

  /// Body of the confirmation shown when leaving the editor unsaved.
  ///
  /// In en, this message translates to:
  /// **'You have changes that have not been saved.'**
  String get ipaEditorDiscardBody;

  /// Button that leaves the editor without saving.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get ipaEditorDiscardAction;

  /// Button that returns to the editor instead of discarding.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get ipaEditorKeepEditingAction;

  /// Title of the dialog shown when an IPA edit invalidates highlights (F-023).
  ///
  /// In en, this message translates to:
  /// **'Some highlights no longer fit'**
  String get ipaRevalidateTitle;

  /// Body of the F-023 confirmation, listing how many highlights would be dropped.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{One coloured run no longer matches the new transcription and will be removed.} other{{count} coloured runs no longer match the new transcription and will be removed.}}'**
  String ipaRevalidateBody(int count);

  /// Button that accepts dropping the highlights that no longer fit.
  ///
  /// In en, this message translates to:
  /// **'Remove them'**
  String get ipaRevalidateConfirm;

  /// Button that returns to the word form instead of dropping highlights.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get ipaRevalidateCancel;

  /// One-time notice shown when the preferred speech voice is unavailable.
  ///
  /// In en, this message translates to:
  /// **'This device has no British English voice, so words are spoken in the closest voice it does have. You can add voices in your device settings, under Text-to-speech.'**
  String get voiceFallbackNotice;

  /// Button that dismisses the one-time voice notice for good.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get voiceFallbackDismiss;
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppL10nEn();
  }

  throw FlutterError(
    'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
