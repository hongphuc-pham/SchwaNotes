import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/repositories/practice_repository_impl.dart';
import 'package:vocabnote/domain/entities/study_card.dart';
import 'package:vocabnote/domain/entities/word_overview.dart';

import 'db_fixtures.dart';

/// The numbers behind the home screen's overview.
void main() {
  late AppDatabase db;
  // Local, because days on the chart are the user's own days.
  final now = DateTime(2026, 9, 9, 12);

  setUp(() async {
    db = AppDatabase.memory();
    await seedSession(db, id: 's1');
  });

  tearDown(() => db.close());

  Future<WordOverview> overview() async => (await PracticeRepositoryImpl(
    db,
    now: () => now,
  ).watchOverview().first).valueOrNull!;

  group('stages', () {
    test('every Leitner box lands on its stage', () {
      expect(
        <int>[0, 1, 2, 3, 4, 5, 6].map(KnowledgeStage.ofBox),
        <KnowledgeStage>[
          KnowledgeStage.fresh,
          KnowledgeStage.learning,
          KnowledgeStage.learning,
          KnowledgeStage.familiar,
          KnowledgeStage.familiar,
          KnowledgeStage.strong,
          KnowledgeStage.strong,
        ],
      );
    });

    test('counts live words only', () async {
      await seedWord(db, id: 'a', headword: 'a');
      await seedWord(db, id: 'b', headword: 'b', box: 1);
      await seedWord(db, id: 'c', headword: 'c', box: 2);
      await seedWord(db, id: 'd', headword: 'd', box: 6);
      await seedWord(db, id: 'e', headword: 'e', box: 6, isArchived: true);

      final stages = (await overview()).stages;

      expect(stages[KnowledgeStage.fresh], 1);
      expect(stages[KnowledgeStage.learning], 2);
      expect(stages[KnowledgeStage.familiar], isNull);
      expect(stages[KnowledgeStage.strong], 1, reason: 'the archived one out');
    });
  });

  group('activity', () {
    setUp(() => seedWord(db, id: 'w', headword: 'cough'));

    Future<void> answer(
      String id,
      DateTime at, {
      ReviewOutcome result = ReviewOutcome.good,
    }) => seedAnswer(
      db,
      id: id,
      sessionId: 's1',
      wordId: 'w',
      result: result,
      answeredAt: at,
    );

    test('covers fourteen days, oldest first, today last', () async {
      final days = (await overview()).days;

      expect(days, hasLength(WordOverview.windowDays));
      expect(days.first.date, DateTime(2026, 8, 27));
      expect(days.last.date, DateTime(2026, 9, 9));
    });

    test('puts each answer on its local day', () async {
      await answer('a1', DateTime(2026, 9, 9, 8));
      await answer('a2', DateTime(2026, 9, 9, 0, 1));
      await answer('a3', DateTime(2026, 9, 8, 23, 59));

      final days = (await overview()).days;

      expect(days.last.answers, 2);
      expect(days[days.length - 2].answers, 1);
    });

    test('leaves out what is older than the window', () async {
      await answer('old', DateTime(2026, 8, 26, 23, 59));
      await answer('new', DateTime(2026, 8, 27, 0, 1));

      expect((await overview()).answers, 1);
    });

    test('the share counts good and easy, and skipped not at all', () async {
      await answer('a', DateTime(2026, 9, 9, 8));
      await answer('b', DateTime(2026, 9, 9, 8, 1), result: ReviewOutcome.easy);
      await answer(
        'c',
        DateTime(2026, 9, 9, 8, 2),
        result: ReviewOutcome.again,
      );
      await answer(
        'd',
        DateTime(2026, 9, 9, 8, 3),
        result: ReviewOutcome.skipped,
      );
      await answer(
        'e',
        DateTime(2026, 9, 9, 8, 4),
        result: ReviewOutcome.again,
      );

      final result = await overview();

      expect(result.answers, 4);
      expect(result.remembered, 2);
      expect(result.rememberedShare, 0.5);
    });

    test('with no answers there is no share to report', () async {
      final result = await overview();

      expect(result.rememberedShare, isNull);
      expect(result.busiestDay, 0);
    });
  });

  test('new this week means the last seven days', () async {
    await seedWord(
      db,
      id: 'in',
      headword: 'in',
      createdAt: DateTime(2026, 9, 3, 0, 1),
    );
    await seedWord(
      db,
      id: 'out',
      headword: 'out',
      createdAt: DateTime(2026, 9, 2, 23, 59),
    );

    expect((await overview()).addedThisWeek, 1);
  });
}
