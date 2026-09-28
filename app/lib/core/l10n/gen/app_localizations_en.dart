// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppL10nEn extends AppL10n {
  AppL10nEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Schwa Notes';

  @override
  String get navWords => 'Words';

  @override
  String get navPractice => 'Practice';

  @override
  String get navLists => 'Lists';

  @override
  String get wordsTitle => 'My words';

  @override
  String get practiceTitle => 'Practice';

  @override
  String get listsTitle => 'Lists';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsOpenLabel => 'Open settings';

  @override
  String get backLabel => 'Go back';

  @override
  String get guideTitle => 'How to use';

  @override
  String get helpTitle => 'Help & feedback';

  @override
  String get backupTitle => 'Backup & restore';

  @override
  String get licencesTitle => 'Data sources & licences';

  @override
  String get onboardingTitle => 'Welcome';

  @override
  String get wordDetailTitle => 'Word';

  @override
  String get wordEditTitle => 'Edit word';

  @override
  String get ipaEditorTitle => 'Edit IPA highlights';

  @override
  String get listDetailTitle => 'List';

  @override
  String get practiceRunTitle => 'Practice';

  @override
  String get practiceSummaryTitle => 'Summary';

  @override
  String get comingSoonTitle => 'Coming soon';

  @override
  String get comingSoonBody => 'This screen arrives in a later milestone.';

  @override
  String comingSoonRoute(String route) {
    return 'Route: $route';
  }

  @override
  String get routeNotFoundTitle => 'Page not found';

  @override
  String get routeNotFoundBody =>
      'We couldn\'t find that page. Let\'s get you back to your words.';

  @override
  String get routeNotFoundAction => 'Go to my words';

  @override
  String get recoverySchemaTooNewTitle =>
      'This data was made by a newer Schwa Notes';

  @override
  String get recoverySchemaTooNewBody =>
      'Please update Schwa Notes to open your words. Opening them with this older version could damage them, so we haven\'t tried.';

  @override
  String get recoveryMigrationTitle =>
      'We couldn\'t finish updating your words';

  @override
  String get recoveryMigrationBody =>
      'Something went wrong while moving your words to the new version. Your original database is still on your phone, exactly as it was.';

  @override
  String get recoveryMigrationBodyRestored =>
      'Something went wrong while moving your words to the new version, so we put the backup we took beforehand straight back. Nothing was lost.';

  @override
  String get recoveryGenericTitle => 'We couldn\'t open your words';

  @override
  String get recoveryGenericBody =>
      'The file holding your words couldn\'t be read. It\'s still on your phone and nothing has been removed.';

  @override
  String get recoveryNothingDeleted =>
      'Nothing has been deleted. Schwa Notes never resets your database to recover from a problem.';

  @override
  String get recoveryExportAction => 'Export my data';

  @override
  String get wordsSearchHint => 'Search your words';

  @override
  String get wordsSearchLabel => 'Search';

  @override
  String get wordsCloseSearchLabel => 'Close search';

  @override
  String get wordsSortLabel => 'Sort';

  @override
  String get filterAll => 'All';

  @override
  String get filterFavourites => 'Favourites';

  @override
  String get filterDueToday => 'Due today';

  @override
  String get filterNoIpa => 'No IPA yet';

  @override
  String get sortRecent => 'Recently updated';

  @override
  String get sortAlphabetical => 'A to Z';

  @override
  String get sortLeastKnown => 'Least known';

  @override
  String get addWordAction => 'Add word';

  @override
  String get emptyWordsTitle => 'Your first word goes here';

  @override
  String get emptyWordsBody =>
      'Save a word, write how it sounds, and mark the part you keep getting wrong.';

  @override
  String get emptyWordsAction => 'Add a word';

  @override
  String get emptyWordsGuide => 'See how it works';

  @override
  String get emptyFilterTitle => 'Nothing here yet';

  @override
  String get emptyFilterBody =>
      'No words match this filter. Try another one, or add a new word.';

  @override
  String get emptySearchTitle => 'No matches';

  @override
  String emptySearchBody(String term) {
    return 'Nothing matched $term. Check the spelling, or add it as a new word.';
  }

  @override
  String get emptyFilterClear => 'Clear filters';

  @override
  String get listsLoadFailedTitle => 'Couldn\'t load your lists';

  @override
  String get listsLoadFailedBody =>
      'Something went wrong reading them. Your lists are still saved.';

  @override
  String get listSaveFailed => 'Couldn\'t save that list. Please try again.';

  @override
  String get listEmptyTitle => 'Nothing in this list yet';

  @override
  String get listEmptyBody =>
      'Add a word to this list from the word\'s own screen.';

  @override
  String get gameFlashcardTitle => 'Flashcards';

  @override
  String get gameFlashcardDescription =>
      'See a word, recall it, then say how it went.';

  @override
  String get flashcardTapToReveal => 'Tap to reveal';

  @override
  String get flashcardFrontLabel => 'Card front. Tap to reveal the answer.';

  @override
  String get flashcardBackLabel => 'Card back. Choose how well you knew it.';

  @override
  String get gradeAgain => 'Again';

  @override
  String get gradeGood => 'Good';

  @override
  String get gradeEasy => 'Easy';

  @override
  String get practiceEmptyTitle => 'Nothing to practise yet';

  @override
  String get practiceEmptyBody =>
      'Add a few words and they\'ll show up here ready to review.';

  @override
  String get practiceQuickTest => 'Quick test';

  @override
  String get practiceNothingDue =>
      'Nothing due right now - a quick test still counts.';

  @override
  String practiceGoalProgress(int count, int goal) {
    return '$count of $goal today';
  }

  @override
  String get practiceGoalReached => 'Today\'s goal reached - nice work';

  @override
  String practiceStreak(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days in a row',
      one: '1 day in a row',
    );
    return '$_temp0';
  }

  @override
  String get practiceGoalStart => 'Any card you practise today counts';

  @override
  String get practiceNothingDueTitle => 'All caught up';

  @override
  String get practiceNothingDueBody =>
      'Nothing is due today. Try a quick test if you\'d like more.';

  @override
  String get practiceNoCardsTitle => 'No cards here';

  @override
  String get practiceNoCardsBody =>
      'Nothing matched that choice. Try a different source.';

  @override
  String get retryAction => 'Try again';

  @override
  String get practiceFailedTitle => 'This session couldn\'t start';

  @override
  String get practiceFailedBody =>
      'Something went wrong picking the cards. Try again, or close practice and come back to it.';

  @override
  String get practiceCountsFailedTitle => 'Couldn\'t read your words';

  @override
  String get practiceCountsFailedBody =>
      'Practice needs to know what\'s in your library. Try again, and if it keeps happening, restart the app.';

  @override
  String get practiceCloseLabel => 'Close practice';

  @override
  String get practiceAbandonTitle => 'Leave this review?';

  @override
  String get practiceAbandonBody =>
      'The cards you\'ve already answered stay answered. The rest keep their current schedule.';

  @override
  String get practiceAbandonStay => 'Keep going';

  @override
  String get practiceAbandonLeave => 'Leave';

  @override
  String get quickTestTitle => 'Quick test';

  @override
  String get quickTestSource => 'Words from';

  @override
  String get quickTestSize => 'How many';

  @override
  String get quickTestPromptSide => 'Show me first';

  @override
  String get quickTestAutoplay => 'Say the word when I reveal it';

  @override
  String get quickTestStart => 'Start';

  @override
  String get promptSideWord => 'The word';

  @override
  String get promptSideIpa => 'The sounds';

  @override
  String get promptSideMeaning => 'The meaning';

  @override
  String practiceDailyReview(int count) {
    return 'Daily review ($count due)';
  }

  @override
  String practiceLockedHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Add $count more words to unlock this',
      one: 'Add 1 more word to unlock this',
    );
    return '$_temp0';
  }

  @override
  String quickTestSizeAll(int max) {
    return 'All (max $max)';
  }

  @override
  String get settingsPracticeSection => 'Practice';

  @override
  String get reminderTitle => 'Daily reminder';

  @override
  String get reminderOff => 'Off';

  @override
  String reminderOnAt(String time) {
    return 'Every day at $time';
  }

  @override
  String get reminderTimeLabel => 'Time';

  @override
  String get reminderDenied =>
      'Notifications are off for Schwa Notes. You can allow them in your phone\'s settings.';

  @override
  String get reminderFailed =>
      'Couldn\'t set the reminder just now. Please try again.';

  @override
  String get reminderNotificationTitle => 'A few words today?';

  @override
  String get reminderNotificationBody => 'A short practice keeps them fresh.';

  @override
  String get reminderChannelName => 'Daily reminder';

  @override
  String get reminderChannelDescription =>
      'One gentle reminder a day, at the time you chose.';

  @override
  String get settingsAppearanceSection => 'Appearance';

  @override
  String get settingsPronunciationSection => 'Pronunciation';

  @override
  String get settingsDataSection => 'Your data';

  @override
  String get settingsHelpSection => 'Help';

  @override
  String get settingsAboutSection => 'About';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeSystem => 'Same as my phone';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsTextSize => 'Text size';

  @override
  String get settingsTextSizeHint =>
      'Schwa Notes uses your phone\'s text size. You can change it in your phone\'s display settings.';

  @override
  String get settingsVoice => 'Voice';

  @override
  String get voiceBritish => 'British English';

  @override
  String get voiceAmerican => 'American English';

  @override
  String get settingsSpeed => 'Speed';

  @override
  String get settingsPitch => 'Pitch';

  @override
  String get settingsAutoplay => 'Say the word when I open it';

  @override
  String get settingsTestVoice => 'Test voice';

  @override
  String get settingsTestVoiceSample => 'pronunciation';

  @override
  String get settingsDailyGoal => 'Daily goal';

  @override
  String settingsDailyGoalValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count words a day',
      one: '1 word a day',
    );
    return '$_temp0';
  }

  @override
  String get settingsPromptSide => 'Show me first';

  @override
  String get settingsPace => 'Review pace';

  @override
  String get paceGentle => 'Gentle';

  @override
  String get paceGentleHint => 'Longer gaps between reviews';

  @override
  String get paceStandard => 'Standard';

  @override
  String get paceStandardHint => 'The usual gaps';

  @override
  String get paceIntensive => 'Intensive';

  @override
  String get paceIntensiveHint =>
      'Shorter gaps and more reviews - good before an exam';

  @override
  String get paceCustom => 'Your own';

  @override
  String get settingsIntervals => 'Days between reviews';

  @override
  String settingsIntervalsValue(String days) {
    return '$days days';
  }

  @override
  String get listSeparator => ' · ';

  @override
  String get intervalEditorBody =>
      'Each time you know a word, it moves up a box and waits a little longer before it comes back.';

  @override
  String get intervalEditorBoxZero =>
      'Box 0 - later the same day, for words worth another look';

  @override
  String intervalEditorBox(int box) {
    return 'Box $box';
  }

  @override
  String get intervalEditorDays => 'days';

  @override
  String get intervalEditorReset => 'Use standard';

  @override
  String get intervalEditorSave => 'Save';

  @override
  String scheduleIssueTooShort(int box) {
    return 'Box $box needs at least 1 day, or its words never come back.';
  }

  @override
  String scheduleIssueShorter(int box, int previous) {
    return 'Box $box can\'t be shorter than box $previous. Later boxes wait longer.';
  }

  @override
  String scheduleIssueNotNumber(int box) {
    return 'Box $box needs a whole number of days.';
  }

  @override
  String get scheduleIssueUnusable =>
      'This schedule can\'t be used. Try Use standard.';

  @override
  String get settingsRepeats => 'Repeat missed cards';

  @override
  String settingsRepeatsValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times in the same session',
      two: 'Twice in the same session',
      one: 'Once in the same session',
      zero: 'Don\'t repeat',
    );
    return '$_temp0';
  }

  @override
  String get settingsBackup => 'Backup & restore';

  @override
  String get settingsBackupHint =>
      'Keep a copy of your words, or move them to a new phone';

  @override
  String get settingsLookup => 'Dictionary look-up';

  @override
  String get settingsLookupOn =>
      'Look up sends only the word to freedictionaryapi.com';

  @override
  String get settingsLookupOff => 'Off - Schwa Notes stays fully offline';

  @override
  String get backupIntro =>
      'A backup is one file holding all your words, sounds, highlights, notes, lists and practice history. Nothing is uploaded: you choose where it goes.';

  @override
  String get backupNever => 'You haven\'t made a backup yet.';

  @override
  String backupLast(String when) {
    return 'Last backup: $when';
  }

  @override
  String get backupExport => 'Export backup';

  @override
  String get backupPreparing => 'Preparing your backup…';

  @override
  String get backupExportHint =>
      'Save it somewhere you can reach from your next phone - your email, your cloud storage or your files.';

  @override
  String get backupExportDone => 'Backup shared. Keep it somewhere safe.';

  @override
  String get backupExportFailed =>
      'Couldn\'t make the backup just now. Your words are safe - please try again.';

  @override
  String get backupImport => 'Import backup';

  @override
  String get backupImporting => 'Bringing your words in…';

  @override
  String get backupImportHint =>
      'Bring words in from a backup file. You\'ll see what\'s in it before anything changes.';

  @override
  String get importProblemNotABackup =>
      'That file isn\'t a Schwa Notes backup. Backups end in .vnb.';

  @override
  String get importProblemTooLarge =>
      'That file is too large to be a Schwa Notes backup.';

  @override
  String get importProblemDamaged =>
      'That backup is damaged and can\'t be read. If you still have the phone it came from, try exporting it again.';

  @override
  String get importProblemUnreadable =>
      'Couldn\'t open that file. Please try again.';

  @override
  String get importPreviewTitle => 'Bring in this backup?';

  @override
  String importPreviewWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count words',
      one: '1 word',
    );
    return '$_temp0';
  }

  @override
  String importPreviewLists(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lists',
      one: '1 list',
      zero: 'no lists',
    );
    return '$_temp0';
  }

  @override
  String importPreviewMade(String when) {
    return 'Made $when';
  }

  @override
  String get importModeMerge => 'Add to my words';

  @override
  String get importModeMergeHint =>
      'New words are added and newer copies win. Nothing on this phone is removed.';

  @override
  String get importModeReplace => 'Replace everything';

  @override
  String get importModeReplaceHint =>
      'Everything on this phone becomes what\'s in the backup. A copy of what\'s here now is kept first.';

  @override
  String get importContinue => 'Continue';

  @override
  String get replaceConfirmTitle => 'Replace everything on this phone?';

  @override
  String get replaceConfirmBody =>
      'Your words, notes, highlights, lists and practice history here will be swapped for the backup\'s. A copy of what\'s here now is kept on this phone first.';

  @override
  String get replaceConfirmWord => 'replace';

  @override
  String get replaceConfirmAction => 'Replace';

  @override
  String typedConfirmPrompt(String word) {
    return 'Type “$word” to confirm';
  }

  @override
  String get importReportTitle => 'Your backup is in';

  @override
  String importReportAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count words added',
      one: '1 word added',
      zero: 'No new words',
    );
    return '$_temp0';
  }

  @override
  String importReportUpdated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count words updated',
      one: '1 word updated',
    );
    return '$_temp0';
  }

  @override
  String importReportSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count words were already here',
      one: '1 word was already here',
    );
    return '$_temp0';
  }

  @override
  String importReportRestored(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count words restored',
      one: '1 word restored',
      zero: 'No words restored',
    );
    return '$_temp0';
  }

  @override
  String importReportNotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notes',
      one: '1 note',
    );
    return '$_temp0';
  }

  @override
  String importReportHighlights(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count highlights',
      one: '1 highlight',
    );
    return '$_temp0';
  }

  @override
  String importReportLists(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lists',
      one: '1 list',
    );
    return '$_temp0';
  }

  @override
  String importReportAlso(String items) {
    return 'Also brought in: $items';
  }

  @override
  String importReportRejected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items couldn\'t be read and were left out.',
      one: '1 item couldn\'t be read and was left out.',
    );
    return '$_temp0';
  }

  @override
  String get importReportSafetyCopy =>
      'A copy of what was here before is kept on this phone.';

  @override
  String get importReportDone => 'Done';

  @override
  String get importFailed =>
      'Couldn\'t bring the backup in. Nothing on this phone was changed.';

  @override
  String get settingsStorage => 'Storage used';

  @override
  String get settingsStorageCounting => 'Counting…';

  @override
  String storageKilobytes(int size) {
    return '$size KB';
  }

  @override
  String storageMegabytes(String size) {
    return '$size MB';
  }

  @override
  String get settingsDeleteAll => 'Delete all data';

  @override
  String get settingsDeleteAllHint =>
      'Removes every word, note, list and practice record from this phone';

  @override
  String get deleteAllTitle => 'Delete everything?';

  @override
  String get deleteAllBody =>
      'This removes every word, sound, highlight, note, list and practice record from this phone, and it can\'t be undone. You may want a backup first.';

  @override
  String get deleteAllBackupFirst => 'Make a backup first';

  @override
  String get deleteAllContinue => 'Continue';

  @override
  String get deleteAllConfirmTitle => 'Delete all data?';

  @override
  String get deleteAllConfirmBody =>
      'Everything on this phone goes, including the copies kept from earlier restores. Without a backup, it can\'t be brought back.';

  @override
  String get deleteAllConfirmWord => 'delete';

  @override
  String get deleteAllConfirmAction => 'Delete everything';

  @override
  String get deleteAllDone =>
      'Everything has been deleted. Schwa Notes is ready for new words.';

  @override
  String get deleteAllFailed =>
      'Couldn\'t delete everything just now. Your words are still here.';

  @override
  String get guideIntro =>
      'Six small things that make Schwa Notes work for you. Tap Try it on any of them to go straight there.';

  @override
  String get guideAddTitle => 'Add a word';

  @override
  String get guideAddBody =>
      'Tap + on My words and type the word you\'re learning. Saving takes two taps.';

  @override
  String get guideLookupTitle => 'Fill it from the dictionary';

  @override
  String get guideLookupBody =>
      'Tap Look up to see how it sounds, what it means and an example. Nothing is filled in until you tap the part you want.';

  @override
  String get guideIpaTitle => 'Write the IPA yourself';

  @override
  String get guideIpaBody =>
      'The row above the keyboard has every sound English needs. Typing the IPA yourself is one of the best ways to remember it.';

  @override
  String get guideIpaVoice =>
      'Tap play to hear the word. The voice is your phone\'s text-to-speech: a good guide to stress and vowels, but not a native speaker.';

  @override
  String get guideHighlightTitle => 'Highlight the sound you struggle with';

  @override
  String get guideHighlightBody =>
      'Open a word\'s IPA and mark the sounds you keep getting wrong, in a colour and with a note to yourself.';

  @override
  String get guideNoteTitle => 'Leave a note for yourself';

  @override
  String get guideNoteBody =>
      'Add as many notes to a word as you like - where you heard it, what your mouth should do, what to listen for.';

  @override
  String get guidePractiseTitle => 'Practise a little every day';

  @override
  String get guidePractiseBody =>
      'A few cards a day beats a long session once a week. The words you find hard come back sooner.';

  @override
  String get guideTryIt => 'Try it';

  @override
  String guideTryItFor(String title) {
    return 'Try it: $title';
  }

  @override
  String get guideSampleWord => 'cough';

  @override
  String get guideSampleIpa => 'kɒf';

  @override
  String get guideSamplePartOfSpeech => 'noun';

  @override
  String get guideSampleDefinition =>
      'A sudden, noisy push of air out of the lungs';

  @override
  String get guideSampleHighlightLabel => 'Rounder lips here';

  @override
  String get guideSampleNote => 'Heard it on a podcast. Lips rounder on the ɒ.';

  @override
  String get guideSampleGoal => '12 of 20 today';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingShowMe => 'See how it works';

  @override
  String get onboardingStart => 'Start using Schwa Notes';

  @override
  String onboardingPage(int page, int count) {
    return 'Page $page of $count';
  }

  @override
  String get onboardingSlide1Title => 'Note the words you\'re learning';

  @override
  String get onboardingSlide1Body =>
      'Save each word with how it sounds, what it means, and notes of your own.';

  @override
  String get onboardingSlide2Title => 'Mark the sounds you find hard';

  @override
  String get onboardingSlide2Body =>
      'Colour the exact part of the IPA you keep getting wrong, so it catches your eye every time.';

  @override
  String get onboardingSlide3Title => 'Practise a little, every day';

  @override
  String get onboardingSlide3Body =>
      'Short sessions bring back the words you find hard. Everything stays on this phone: no account, no ads.';

  @override
  String get faqSearchHint => 'Search the answers';

  @override
  String faqCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count answers',
      one: '1 answer',
    );
    return '$_temp0';
  }

  @override
  String faqNoAnswers(String query) {
    return 'No answers mention “$query”.';
  }

  @override
  String get faqClear => 'Clear search';

  @override
  String get faqQ1 => 'Where are my words kept?';

  @override
  String get faqA1 =>
      'Only on this phone, in Schwa Notes\'s own private storage. There is no account and no server. To keep a copy anywhere else, make a backup.';

  @override
  String get faqQ2 => 'How do I move my words to a new phone?';

  @override
  String get faqA2 =>
      'Go to Settings → Backup & restore → Export backup, and save the file somewhere your new phone can reach. Then install Schwa Notes there and choose Import backup.';

  @override
  String get faqQ3 => 'Does Schwa Notes need the internet?';

  @override
  String get faqA3 =>
      'No. Everything works offline. Only Look up uses the internet, and all it sends is the word you are looking up.';

  @override
  String get faqQ4 => 'Why does the voice sound like a computer?';

  @override
  String get faqA4 =>
      'It is your phone\'s own text-to-speech: a good guide to stress and vowels, but not a native speaker. You can change the voice, speed and pitch in Settings → Pronunciation.';

  @override
  String get faqQ5 => 'My phone has no British English voice.';

  @override
  String get faqA5 =>
      'Add one in your phone\'s settings, under Text-to-speech on Android or Spoken Content on iPhone. Until then, Schwa Notes uses the closest voice it can find.';

  @override
  String get faqQ6 => 'How do I type IPA symbols?';

  @override
  String get faqA6 =>
      'Tap into an IPA field and a row of symbols appears above the keyboard. Tap a symbol to add it where the cursor is.';

  @override
  String get faqQ7 => 'What is IPA?';

  @override
  String get faqA7 =>
      'The International Phonetic Alphabet: one symbol for each sound, so a pronunciation is written down exactly - /kɒf/ rather than \"coff\".';

  @override
  String get faqQ8 => 'How do highlights work?';

  @override
  String get faqA8 =>
      'Open a word, tap Edit IPA highlights, choose the symbols you struggle with and pick a colour. A short label, like \"lips rounder\", helps too.';

  @override
  String get faqQ9 => 'How does practice decide what comes back?';

  @override
  String get faqA9 =>
      'Each word sits in a box. Know it and it moves up a box and waits longer; miss it and it comes back later the same day. You can change the gaps in Settings → Practice.';

  @override
  String get faqQ10 =>
      'What\'s the difference between Daily review and Quick test?';

  @override
  String get faqA10 =>
      'Daily review shows the words that are due, and your answers decide when each comes back. A quick test is just for practice: it never changes that.';

  @override
  String get faqQ11 => 'I deleted a word by mistake.';

  @override
  String get faqA11 =>
      'Tap Undo on the message that appears straight away. After that, importing a backup made before you deleted it will bring it back.';

  @override
  String get faqQ12 => 'Where do the definitions come from?';

  @override
  String get faqA12 =>
      'From Wiktionary, through FreeDictionaryAPI.com, shared under CC BY-SA 4.0. Offline pronunciations come from the CMU Pronouncing Dictionary. Settings → Data sources & licences has the details.';

  @override
  String get helpStillStuck => 'Still stuck?';

  @override
  String get feedbackSend => 'Send feedback';

  @override
  String get feedbackSendHint =>
      'Opens your email app. You\'ll see what\'s included first.';

  @override
  String get helpGitHub => 'Report a problem on GitHub';

  @override
  String get helpGitHubHint =>
      'Opens the project\'s issue page in your browser';

  @override
  String get helpErrorLog => 'View error log';

  @override
  String get helpErrorLogHint => 'Kept on this phone, never sent by itself';

  @override
  String get helpLinkFailed => 'Couldn\'t open that link.';

  @override
  String get feedbackPreviewTitle => 'Send feedback';

  @override
  String feedbackPreviewIntro(String address) {
    return 'Your email app will open with this, addressed to $address:';
  }

  @override
  String get feedbackSubject => 'Schwa Notes feedback';

  @override
  String get feedbackBodyPrompt => 'Write your message here.';

  @override
  String get feedbackBodyDivider => '—';

  @override
  String feedbackAppVersion(String version) {
    return 'App version: $version';
  }

  @override
  String feedbackOsVersion(String os) {
    return 'OS: $os';
  }

  @override
  String feedbackDeviceModel(String model) {
    return 'Device: $model';
  }

  @override
  String get feedbackUnknown => 'unknown';

  @override
  String get feedbackLogHeading => 'Error log (newest entries):';

  @override
  String get feedbackIncludeLog => 'Include the error log';

  @override
  String get feedbackNothingElse => 'Nothing else is included.';

  @override
  String get feedbackOpenEmail => 'Open email';

  @override
  String feedbackNoMailApp(String address) {
    return 'No email app opened. You can write to $address from any email account.';
  }

  @override
  String get errorLogTitle => 'Error log';

  @override
  String get errorLogIntro =>
      'Problems Schwa Notes ran into, kept only on this phone. Nothing here is ever sent by itself.';

  @override
  String get errorLogEmpty =>
      'Nothing has gone wrong. If something does, a short note appears here - it stays on this phone unless you attach it to feedback.';

  @override
  String get errorLogReading => 'Reading…';

  @override
  String get errorLogClear => 'Clear log';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get settingsPrivacyHint => 'What leaves your phone, and when';

  @override
  String get settingsSupport => 'Buy me a coffee';

  @override
  String get settingsSupportHint =>
      'Schwa Notes is free. A tip on Ko-fi is kind, unlocks nothing, and is never expected.';

  @override
  String get privacyHeading => 'Privacy';

  @override
  String get privacyNote =>
      'Schwa Notes has no account and no analytics. Your words never leave your phone unless you export them. Looking up a word sends only that word to freedictionaryapi.com.';

  @override
  String get privacyPoint1 => 'No account, no sign-in, and no server of ours.';

  @override
  String get privacyPoint2 =>
      'No analytics, no ads, no tracking, and no advertising ID.';

  @override
  String get privacyPoint3 =>
      'Schwa Notes reaches the internet only when you ask it to: to look up a word, or to open a link you tapped, in your browser.';

  @override
  String get privacyPoint4 =>
      'Feedback is written in your own email app. You see what it includes before it opens, and nothing else is attached unless you choose to add the error log.';

  @override
  String get privacyPoint5 =>
      'Your words, IPA, highlights, notes and practice history stay on this phone, and leave it only in a backup you export.';

  @override
  String get licencesDictionaryHeading => 'Dictionary look-up';

  @override
  String get licencesDictionaryBody =>
      'Definitions, examples and pronunciations you choose from Look up come from Wiktionary, shared under the CC BY-SA 4.0 licence through FreeDictionaryAPI.com. Each word keeps a link to its source page. Neither Wiktionary nor FreeDictionaryAPI.com endorses Schwa Notes.';

  @override
  String get licencesWiktionary => 'Wiktionary';

  @override
  String get licencesFreeDictionary => 'FreeDictionaryAPI.com';

  @override
  String get licencesCcBySa => 'CC BY-SA 4.0 licence';

  @override
  String get licencesOfflineHeading => 'Offline pronunciations';

  @override
  String get licencesOfflineBody =>
      'When there is no internet, US pronunciations come from the CMU Pronouncing Dictionary, made at Carnegie Mellon University and free for any use.';

  @override
  String get licencesCmudict => 'CMU Pronouncing Dictionary';

  @override
  String get licencesFontsHeading => 'Fonts';

  @override
  String get licencesFontsBody =>
      'Inter for the words on screen, and Charis SIL for IPA - both shared under the SIL Open Font License 1.1.';

  @override
  String get licencesInter => 'Inter';

  @override
  String get licencesCharis => 'Charis SIL';

  @override
  String get licencesOflName => 'SIL Open Font License 1.1';

  @override
  String get licencesViewLicence => 'View licence';

  @override
  String licencesViewLicenceFor(String font) {
    return 'View the licence for $font';
  }

  @override
  String get licencesLoading => 'Loading…';

  @override
  String get licencesPackagesHeading => 'Software';

  @override
  String get licencesPackagesBody =>
      'Schwa Notes is built with open-source packages, all under permissive licences.';

  @override
  String get licencesPackages => 'All package licences';

  @override
  String get recoveryExporting => 'Exporting…';

  @override
  String get recoveryExportFailed =>
      'Couldn\'t make the export just now. Your data is still on this phone, untouched.';

  @override
  String get settingsVersion => 'Version';

  @override
  String get summaryTitle => 'How that went';

  @override
  String get summaryMissedHeading => 'Worth another look';

  @override
  String get summaryAddMissed => 'Add these to a list';

  @override
  String get summaryDone => 'Done';

  @override
  String get summaryPractiseAgain => 'Practise again';

  @override
  String get summaryMissingTitle => 'That session has finished';

  @override
  String get summaryMissingBody =>
      'Your answers were saved as you went. Start another whenever you like.';

  @override
  String summaryScore(int correct, int total) {
    return 'Nice work - $correct of $total';
  }

  @override
  String summaryTime(int minutes, int seconds) {
    return '${minutes}m ${seconds}s';
  }

  @override
  String summaryAddedToList(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count words added to $name',
      one: '1 word added to $name',
    );
    return '$_temp0';
  }

  @override
  String get listsEmptyTitle => 'No lists yet';

  @override
  String get listsEmptyBody =>
      'Lists group words however you like - a course, a topic, the sounds you keep getting wrong.';

  @override
  String get newListAction => 'New list';

  @override
  String get createListTitle => 'New list';

  @override
  String get editListTitle => 'Edit list';

  @override
  String get listNameLabel => 'Name';

  @override
  String get listNameHint => 'IELTS speaking';

  @override
  String get listNameRequired => 'Give the list a name.';

  @override
  String get moveListUpAction => 'Move up';

  @override
  String get moveListDownAction => 'Move down';

  @override
  String get renameListAction => 'Rename or recolour';

  @override
  String get deleteListAction => 'Delete list';

  @override
  String get deleteListTitle => 'Delete this list?';

  @override
  String get deleteListBody =>
      'The list goes, but every word in it stays in your words.';

  @override
  String listActionsLabel(String name) {
    return 'Actions for $name';
  }

  @override
  String get practiseListAction => 'Practise this list';

  @override
  String get editNoteAction => 'Edit note';

  @override
  String get saveNoteAction => 'Save';

  @override
  String listWordCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count words',
      one: '1 word',
      zero: 'No words',
    );
    return '$_temp0';
  }

  @override
  String listDueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count due',
      one: '1 due',
    );
    return '$_temp0';
  }

  @override
  String filterCountLabel(String label, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count words',
      one: '1 word',
    );
    return '$label, $_temp0';
  }

  @override
  String wordNoteCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notes',
      one: '1 note',
    );
    return '$_temp0';
  }

  @override
  String wordFavouriteLabel(String word) {
    return 'Add $word to favourites';
  }

  @override
  String wordUnfavouriteLabel(String word) {
    return 'Remove $word from favourites';
  }

  @override
  String get wordsLoadFailedTitle => 'We could not load your words';

  @override
  String get wordsLoadFailedBody =>
      'Something went wrong reading your database. Nothing has been lost.';

  @override
  String get deleteWordAction => 'Delete';

  @override
  String wordDeletedSnack(String word) {
    return 'Deleted $word';
  }

  @override
  String get undoAction => 'Undo';

  @override
  String get editorTitleAdd => 'Add word';

  @override
  String get editorTitleEdit => 'Edit word';

  @override
  String get saveAction => 'Save';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get fieldWord => 'Word';

  @override
  String get fieldWordHint => 'The word you are studying';

  @override
  String get lookUpAction => 'Look up';

  @override
  String get lookUpHint => 'optional - typing it yourself helps you remember';

  @override
  String get fieldIpaUk => 'IPA (UK)';

  @override
  String get fieldIpaUs => 'IPA (US)';

  @override
  String get fieldPartOfSpeech => 'Part of speech';

  @override
  String get fieldDefinition => 'Definition';

  @override
  String get fieldExample => 'Example';

  @override
  String get fieldNote => 'Note';

  @override
  String get fieldNoteHint => 'Something to remind yourself';

  @override
  String get fieldLists => 'Add to lists';

  @override
  String get fieldListsEmpty => 'No lists yet';

  @override
  String get posNoun => 'noun';

  @override
  String get posVerb => 'verb';

  @override
  String get posAdjective => 'adjective';

  @override
  String get posAdverb => 'adverb';

  @override
  String get posOther => 'other';

  @override
  String get ipaKeyboardLabel => 'IPA symbols';

  @override
  String ipaSymbolLabel(String symbol) {
    return 'Insert $symbol';
  }

  @override
  String ipaSpokenPronunciation(String sounds) {
    return 'pronunciation: $sounds';
  }

  @override
  String get ipaSoundSeparator => ', ';

  @override
  String get ipaSoundP => 'p';

  @override
  String get ipaSoundB => 'b';

  @override
  String get ipaSoundT => 't';

  @override
  String get ipaSoundD => 'd';

  @override
  String get ipaSoundK => 'k';

  @override
  String get ipaSoundG => 'g';

  @override
  String get ipaSoundF => 'f';

  @override
  String get ipaSoundV => 'v';

  @override
  String get ipaSoundThVoiceless => 'th as in thin';

  @override
  String get ipaSoundThVoiced => 'th as in this';

  @override
  String get ipaSoundS => 's';

  @override
  String get ipaSoundZ => 'z';

  @override
  String get ipaSoundSh => 'sh';

  @override
  String get ipaSoundZh => 'zh as in measure';

  @override
  String get ipaSoundCh => 'ch';

  @override
  String get ipaSoundJudge => 'j';

  @override
  String get ipaSoundH => 'h';

  @override
  String get ipaSoundM => 'm';

  @override
  String get ipaSoundN => 'n';

  @override
  String get ipaSoundNg => 'ng as in sing';

  @override
  String get ipaSoundL => 'l';

  @override
  String get ipaSoundR => 'r';

  @override
  String get ipaSoundYes => 'y as in yes';

  @override
  String get ipaSoundW => 'w';

  @override
  String get ipaSoundFleece => 'long e as in see';

  @override
  String get ipaSoundHappy => 'e as in happy';

  @override
  String get ipaSoundKit => 'short i as in sit';

  @override
  String get ipaSoundDress => 'short e as in bed';

  @override
  String get ipaSoundTrap => 'short a as in cat';

  @override
  String get ipaSoundStrut => 'short u as in cup';

  @override
  String get ipaSoundPalm => 'a as in father';

  @override
  String get ipaSoundLot => 'short o as in hot';

  @override
  String get ipaSoundThought => 'aw as in saw';

  @override
  String get ipaSoundFoot => 'short oo as in book';

  @override
  String get ipaSoundGoose => 'long oo as in food';

  @override
  String get ipaSoundNurse => 'er as in her';

  @override
  String get ipaSoundComma => 'uh as in about';

  @override
  String get ipaSoundLetter => 'er as in butter';

  @override
  String get ipaSoundFace => 'ay as in day';

  @override
  String get ipaSoundPrice => 'long i as in my';

  @override
  String get ipaSoundChoice => 'oy as in boy';

  @override
  String get ipaSoundGoat => 'long o as in go';

  @override
  String get ipaSoundMouth => 'ow as in now';

  @override
  String get ipaSoundNear => 'ear as in near';

  @override
  String get ipaSoundSquare => 'air as in hair';

  @override
  String get ipaSoundCure => 'oor as in poor';

  @override
  String get ipaSoundPrimaryStress => 'stress';

  @override
  String get ipaSoundSecondaryStress => 'light stress';

  @override
  String get ipaSoundLong => 'long';

  @override
  String duplicateBanner(String word) {
    return 'You already have $word';
  }

  @override
  String get duplicateBannerOpen => 'Open it';

  @override
  String get duplicateBannerDismiss => 'Keep both';

  @override
  String lookupSearching(String word) {
    return 'Looking up $word...';
  }

  @override
  String get lookupResultsTitle => 'From the dictionary';

  @override
  String lookupNoResults(String word) {
    return 'No entry found for $word. You can still type it in yourself.';
  }

  @override
  String get lookupFailed =>
      'Could not reach the dictionary - you can still type it in.';

  @override
  String get lookupDismiss => 'Dismiss';

  @override
  String get lookupViewSource => 'View source';

  @override
  String lookupAttributionLine(String source, String license) {
    return '$source - $license';
  }

  @override
  String get lookupOfflineBadge => 'offline';

  @override
  String lookupApplyLabel(String value) {
    return 'Use $value';
  }

  @override
  String get overwriteTitle => 'Replace what you typed?';

  @override
  String overwriteBody(String current, String replacement) {
    return 'This will replace $current with $replacement.';
  }

  @override
  String get overwriteReplace => 'Replace';

  @override
  String get overwriteKeep => 'Keep mine';

  @override
  String get detailAccentUk => 'UK';

  @override
  String get detailAccentUs => 'US';

  @override
  String detailPlayLabel(String word, String accent) {
    return 'Play $word in $accent';
  }

  @override
  String detailPlaySlowLabel(String word, String accent) {
    return 'Play $word slowly in $accent';
  }

  @override
  String get detailStopLabel => 'Stop';

  @override
  String detailPlayingLabel(String word) {
    return 'Speaking $word';
  }

  @override
  String get detailSlowHint => 'Hold to hear it slowly';

  @override
  String get detailSpeechFailed => 'This device has no speech voice available.';

  @override
  String get detailSpeechSettingsAction => 'Voice settings';

  @override
  String get detailNoIpaTitle => 'No pronunciation yet';

  @override
  String get detailNoIpaBody =>
      'Add a transcription to hear this word and to colour the sounds you find hard.';

  @override
  String get detailAddIpaAction => 'Add pronunciation';

  @override
  String get detailEditHighlightsAction => 'Edit IPA highlights';

  @override
  String get detailNotesHeading => 'My notes';

  @override
  String get detailAddNoteAction => 'Add';

  @override
  String get detailNoNotesBody => 'No notes yet.';

  @override
  String get detailNoteDeleteAction => 'Delete note';

  @override
  String get detailNoteDeletedSnack => 'Note deleted';

  @override
  String get detailNoteHeading => 'Add a note';

  @override
  String get detailNotFoundTitle => 'This word is gone';

  @override
  String get detailNotFoundBody =>
      'It was deleted. You can undo a deletion from the words list for a few seconds.';

  @override
  String get detailLoadFailedTitle => 'Could not open this word';

  @override
  String get detailLoadFailedBody =>
      'Something went wrong reading it from your device.';

  @override
  String get detailEditAction => 'Edit';

  @override
  String get detailLegendHeading => 'Sounds you marked';

  @override
  String detailLegendEntry(String color, String label) {
    return '$color: $label';
  }

  @override
  String detailLegendJumpLabel(String label) {
    return 'Show $label in the transcription';
  }

  @override
  String get ipaColorAmber => 'amber';

  @override
  String get ipaColorCoral => 'coral';

  @override
  String get ipaColorViolet => 'violet';

  @override
  String get ipaColorTeal => 'teal';

  @override
  String get ipaColorBlue => 'blue';

  @override
  String get detailCambridgeAction => 'Open in Cambridge Dictionary';

  @override
  String get detailCambridgeFailed => 'Could not open your browser.';

  @override
  String get ipaEditorIntro =>
      'Tap a symbol, or drag across several, then choose a colour.';

  @override
  String ipaEditorSelectedLabel(String symbols) {
    return 'selected $symbols';
  }

  @override
  String get ipaEditorNothingSelected => 'Nothing selected yet';

  @override
  String get ipaEditorDoneAction => 'Done';

  @override
  String get ipaEditorUndoAction => 'Undo';

  @override
  String get ipaEditorColorHeading => 'Colour this sound';

  @override
  String get ipaEditorLabelHint => 'Why is it hard? (optional)';

  @override
  String get ipaEditorDeleteAction => 'Delete highlight';

  @override
  String ipaEditorColorLabel(String color) {
    return 'Use $color';
  }

  @override
  String get ipaEditorSaveFailed => 'Could not save your highlights.';

  @override
  String get ipaEditorNoIpaTitle => 'Nothing to highlight yet';

  @override
  String get ipaEditorNoIpaBody =>
      'Add a transcription first, then come back to colour the sounds you find hard.';

  @override
  String get ipaEditorDiscardTitle => 'Discard your colours?';

  @override
  String get ipaEditorDiscardBody =>
      'You have changes that have not been saved.';

  @override
  String get ipaEditorDiscardAction => 'Discard';

  @override
  String get ipaEditorKeepEditingAction => 'Keep editing';

  @override
  String get ipaRevalidateTitle => 'Some highlights no longer fit';

  @override
  String ipaRevalidateBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count coloured runs no longer match the new transcription and will be removed.',
      one: 'One coloured run no longer matches the new transcription and will be removed.',
    );
    return '$_temp0';
  }

  @override
  String get ipaRevalidateConfirm => 'Remove them';

  @override
  String get ipaRevalidateCancel => 'Keep editing';

  @override
  String get voiceFallbackNotice =>
      'This device has no British English voice, so words are spoken in the closest voice it does have. You can add voices in your device settings, under Text-to-speech.';

  @override
  String get voiceFallbackDismiss => 'Got it';
}
