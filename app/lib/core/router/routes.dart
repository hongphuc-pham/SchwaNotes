/// Every route in the app, named once.
///
/// Paths are the ones listed in `docs/UI-UX.md` §3. Nothing else may write a
/// path as a string literal — navigation changes need a doc update first
/// (`docs/RULES.md` §42), and a typo'd literal would only fail at runtime.
library;

/// Path segments and full paths for `go_router`.
abstract final class Routes {
  /// The overview of the user's words — the app's home.
  static const String words = '/words';

  /// Every word, with search, filters and sort.
  ///
  /// A segment beside `:wordId`, so it is declared first. A uuid can never
  /// collide with it, as with [newWordId].
  static const String wordsAll = '$words/all';

  /// [wordsAll] with its search field already open.
  static const String wordsSearch = '$wordsAll?$searchParam=1';

  /// A single word.
  static const String wordDetail = '$words/:$wordIdParam';

  /// Add or edit a word.
  static const String wordEdit = '$wordDetail/edit';

  /// The IPA highlight editor for a word.
  static const String wordIpa = '$wordDetail/ipa';

  /// The lists (decks) grid.
  static const String lists = '/lists';

  /// A single list.
  static const String listDetail = '$lists/:$listIdParam';

  /// The practice hub.
  static const String practice = '/practice';

  /// A running practice session for one game.
  static const String practiceRun = '$practice/:$gameIdParam/run';

  /// The summary for a finished session.
  static const String practiceSummary = '$practice/summary/:$sessionIdParam';

  /// Settings.
  static const String settings = '/settings';

  /// The six-card "How to use" guide. Always reachable (`docs/RULES.md` §4).
  static const String guide = '$settings/guide';

  /// Help & feedback. Always reachable (`docs/RULES.md` §4).
  static const String help = '$settings/help';

  /// Backup export and import.
  static const String backup = '$settings/backup';

  /// Data sources, licences and the privacy note.
  static const String licences = '$settings/licences';

  /// First-run onboarding.
  static const String onboarding = '/onboarding';

  /// The placeholder id used by the add form.
  ///
  /// `/words/new/edit` opens an empty form; every other id edits that word.
  /// A uuid can never collide with it.
  static const String newWordId = 'new';

  /// Query parameter that opens the words list's search.
  static const String searchParam = 'search';

  /// Path parameter holding a word id.
  static const String wordIdParam = 'wordId';

  /// Path parameter holding a list id.
  static const String listIdParam = 'listId';

  /// Path parameter holding a game id, e.g. `flashcard`.
  static const String gameIdParam = 'gameId';

  /// Path parameter holding a practice session id.
  static const String sessionIdParam = 'sessionId';

  /// Builds the path to one word.
  static String wordDetailOf(String id) => '$words/$id';

  /// Builds the path to a word's editor.
  static String wordEditOf(String id) => '$words/$id/edit';

  /// The path that opens an empty add form.
  static String get wordAdd => '$words/$newWordId/edit';

  /// Builds the path to a word's IPA highlight editor.
  static String wordIpaOf(String id) => '$words/$id/ipa';

  /// Builds the path to one list.
  static String listDetailOf(String id) => '$lists/$id';

  /// Builds the path that runs [gameId].
  static String practiceRunOf(String gameId) => '$practice/$gameId/run';

  /// Builds the path to a session summary.
  static String practiceSummaryOf(String sessionId) =>
      '$practice/summary/$sessionId';
}

/// Route names, used with `goNamed` so call sites never repeat a path.
abstract final class RouteNames {
  /// See [Routes.words].
  static const String words = 'words';

  /// See [Routes.wordsAll].
  static const String wordsAll = 'wordsAll';

  /// See [Routes.wordDetail].
  static const String wordDetail = 'wordDetail';

  /// See [Routes.wordEdit].
  static const String wordEdit = 'wordEdit';

  /// See [Routes.wordIpa].
  static const String wordIpa = 'wordIpa';

  /// See [Routes.lists].
  static const String lists = 'lists';

  /// See [Routes.listDetail].
  static const String listDetail = 'listDetail';

  /// See [Routes.practice].
  static const String practice = 'practice';

  /// See [Routes.practiceRun].
  static const String practiceRun = 'practiceRun';

  /// See [Routes.practiceSummary].
  static const String practiceSummary = 'practiceSummary';

  /// See [Routes.settings].
  static const String settings = 'settings';

  /// See [Routes.guide].
  static const String guide = 'guide';

  /// See [Routes.help].
  static const String help = 'help';

  /// See [Routes.backup].
  static const String backup = 'backup';

  /// See [Routes.licences].
  static const String licences = 'licences';

  /// See [Routes.onboarding].
  static const String onboarding = 'onboarding';
}
