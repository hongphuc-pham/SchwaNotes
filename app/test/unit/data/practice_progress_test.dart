import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/repositories/practice_repository_impl.dart';
import 'package:vocabnote/domain/entities/practice_progress.dart';
import 'package:vocabnote/domain/entities/practice_session.dart';
import 'package:vocabnote/domain/entities/study_card.dart';

import 'db_fixtures.dart';

/// Today's words and the days practised, read from real answers (F-065).
void main() {
  late AppDatabase db;
  late int answers;

  // Local midday: far from either midnight, so every expectation means the
  // same in whatever time zone the test runs.
  final now = DateTime(2026, 9, 11, 12);
  final today = DateTime(2026, 9, 11);

  setUp(() async {
    db = AppDatabase.memory();
    answers = 0;
    for (final id in <String>['w1', 'w2', 'w3']) {
      await seedWord(db, id: id, headword: id);
    }
    // A quick test: it counts towards the goal and the streak, because it is
    // practice - only the schedule ignores it.
    await seedSession(db, id: 's1', mode: PracticeMode.quickTest);
  });

  tearDown(() => db.close());

  Future<void> answer(
    String wordId,
    DateTime at, {
    ReviewOutcome result = ReviewOutcome.good,
  }) => seedAnswer(
    db,
    id: 'a${answers++}',
    sessionId: 's1',
    wordId: wordId,
    answeredAt: at,
    result: result,
  );

  Future<PracticeProgress> progress() async {
    final result = await PracticeRepositoryImpl(
      db,
      now: () => now,
    ).watchProgress().first;
    return result.valueOrNull!;
  }

  test('counts different words today, a repeated word once', () async {
    await answer('w1', DateTime(2026, 9, 11, 9));
    await answer('w1', DateTime(2026, 9, 11, 10));
    await answer('w2', DateTime(2026, 9, 11, 11));

    expect((await progress()).wordsToday, 2);
  });

  test(
    'an answer just before midnight belongs to the day it was given',
    () async {
      // The reason the query reads quarter-hours and not UTC days.
      await answer('w1', DateTime(2026, 9, 10, 23, 50));
      await answer('w2', DateTime(2026, 9, 11, 0, 10));

      final day = await progress();
      expect(day.wordsToday, 1, reason: 'only the 00:10 answer is today');
      expect(day.daysPractised, <DateTime>{today, DateTime(2026, 9, 10)});
    },
  );

  test('the streak comes from the days answered on', () async {
    await answer('w1', DateTime(2026, 9, 11, 8));
    await answer('w1', DateTime(2026, 9, 10, 20));
    await answer('w2', DateTime(2026, 9, 9, 7));
    // Nothing on the 8th, so the 7th is outside the run.
    await answer('w3', DateTime(2026, 9, 7, 7));

    expect((await progress()).streak, 3);
  });

  test('a skipped card is not a word practised today', () async {
    // Found on the emulator: five words graded and three skipped read
    // "8 of 20 today".
    await answer('w1', DateTime(2026, 9, 11, 9));
    await answer(
      'w2',
      DateTime(2026, 9, 11, 10),
      result: ReviewOutcome.skipped,
    );

    expect((await progress()).wordsToday, 1);
  });

  test('skipping every card does not keep a streak alive', () async {
    await answer('w1', DateTime(2026, 9, 10, 20));
    await answer(
      'w2',
      DateTime(2026, 9, 11, 10),
      result: ReviewOutcome.skipped,
    );

    final day = await progress();
    expect(day.wordsToday, 0);
    expect(day.daysPractised, <DateTime>{DateTime(2026, 9, 10)});
  });

  test('with no answers at all there is nothing, not an error', () async {
    final day = await progress();
    expect(day.wordsToday, 0);
    expect(day.streak, 0);
  });
}
