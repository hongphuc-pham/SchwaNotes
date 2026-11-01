import 'package:meta/meta.dart';

/// How far along a word is, for reading rather than for scheduling.
///
/// Four plain steps over the seven Leitner boxes (`docs/GAMES.md` §5). Only
/// Daily review moves a word between them: a quick test never touches the
/// schedule.
enum KnowledgeStage {
  /// Box 0: not reviewed yet, or sent back to the start.
  fresh,

  /// Boxes 1-2.
  learning,

  /// Boxes 3-4.
  familiar,

  /// Boxes 5-6.
  strong;

  /// The stage a Leitner [box] belongs to.
  static KnowledgeStage ofBox(int box) => switch (box) {
    <= 0 => fresh,
    <= 2 => learning,
    <= 4 => familiar,
    _ => strong,
  };
}

/// How many answers were given on one local date.
@immutable
class DayActivity {
  /// Creates one day of activity.
  const new({required this.date, required this.answers});

  /// The local date, at midnight.
  final DateTime date;

  /// How many rounds were answered, skipped ones not counting.
  final int answers;
}

/// What the home screen shows about the user's words and practice.
@immutable
class WordOverview {
  /// Creates an overview.
  const new({
    required this.addedThisWeek,
    required this.stages,
    required this.days,
    required this.remembered,
  });

  /// How many days [days] covers, today included.
  static const int windowDays = 14;

  /// Live words added in the last seven days, today included.
  final int addedThisWeek;

  /// Live words at each stage. A stage with no words may be missing.
  final Map<KnowledgeStage, int> stages;

  /// The last [windowDays] days, oldest first, today last.
  final List<DayActivity> days;

  /// How many of those answers were `good` or `easy`.
  final int remembered;

  /// Every answer in [days].
  int get answers => days.fold(0, (sum, day) => sum + day.answers);

  /// The most answers on one day.
  int get busiestDay =>
      days.fold(0, (most, day) => day.answers > most ? day.answers : most);

  /// The share of answers remembered, or null with no answers to judge by.
  double? get rememberedShare => answers == 0 ? null : remembered / answers;
}
