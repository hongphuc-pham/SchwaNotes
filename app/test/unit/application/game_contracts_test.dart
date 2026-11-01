import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/application/practice/game_contracts.dart';
import 'package:vocabnote/domain/entities/practice_session.dart';
import 'package:vocabnote/domain/entities/study_card.dart';
import 'package:vocabnote/domain/entities/word.dart';
import 'package:vocabnote/domain/repositories/practice_repository.dart';
import 'package:vocabnote/domain/value_objects/headword.dart';

import 'dummy_game.dart';

/// The practice contracts (`docs/GAMES.md` §2, F-062, F-067).
void main() {
  GameConfig quickTest({int limit = 10, int? seed}) => GameConfig(
    gameId: 'flashcard',
    mode: PracticeMode.quickTest,
    selection: CardSelection.random,
    limit: limit,
    seed: seed,
  );

  GameConfig daily({int limit = 20}) => GameConfig(
    gameId: 'flashcard',
    mode: PracticeMode.daily,
    selection: CardSelection.due,
    limit: limit,
  );

  group('how many cards (F-062, GAMES.md §4)', () {
    test('a quick test takes the size it is given', () {
      for (final size in <int>[1, 5, 31, 500]) {
        expect(quickTest(limit: size).limit, size);
      }
    });

    test('the full list is a limit like any other', () {
      expect(
        quickTest(limit: PracticeRepository.everyCard).limit,
        PracticeRepository.everyCard,
      );
    });

    test('daily review takes the goal', () {
      expect(daily(limit: 50).limit, 50);
    });
  });

  group('affectsScheduling (F-062 🔴)', () {
    test('daily review moves the schedule', () {
      expect(daily().affectsScheduling, isTrue);
    });

    test('a quick test never does', () {
      expect(quickTest().affectsScheduling, isFalse);
    });
  });

  group('config_json', () {
    test('round-trips every field', () {
      final before = GameConfig(
        gameId: 'flashcard',
        mode: PracticeMode.quickTest,
        selection: CardSelection.weakest,
        limit: 20,
        source: CardSourceKind.list,
        sourceId: 'list-1',
        promptSide: PromptSide.ipaFirst,
        ttsAutoPlay: false,
        seed: 4242,
      );

      final after = GameConfig.fromJson(before.toJson());

      expect(after.gameId, before.gameId);
      expect(after.mode, before.mode);
      expect(after.selection, before.selection);
      expect(after.limit, before.limit);
      expect(after.source, before.source);
      expect(after.sourceId, before.sourceId);
      expect(after.promptSide, before.promptSide);
      expect(after.ttsAutoPlay, before.ttsAutoPlay);
      expect(after.seed, before.seed);
    });

    test('tolerates a key it has never heard of', () {
      // GAMES.md §2: readers must tolerate unknown keys. A session written by
      // a later version has to still open here - stored history that cannot be
      // read is worse than history with a default in it.
      final json = quickTest().toJson()..['somethingFromV2'] = <String>['x'];

      expect(() => GameConfig.fromJson(json), returnsNormally);
      expect(GameConfig.fromJson(json).gameId, 'flashcard');
    });

    test('falls back rather than throwing on a corrupt value', () {
      final config = GameConfig.fromJson(const <String, dynamic>{
        'gameId': 'flashcard',
        'mode': 'telepathy',
        'selection': 'vibes',
        'promptSide': 'sideways',
      });

      expect(config.mode, PracticeMode.quickTest);
      expect(config.selection, CardSelection.random);
      expect(config.promptSide, PromptSide.wordFirst);
    });

    test('round-trips the mix choices', () {
      final before = GameConfig(
        gameId: 'flashcard',
        mode: PracticeMode.daily,
        selection: CardSelection.due,
        limit: 20,
        promptSide: PromptSide.mix,
        mixSides: const <PromptSide>{
          PromptSide.ipaFirst,
          PromptSide.meaningFirst,
        },
        mixOrder: MixOrder.rotate,
      );

      final after = GameConfig.fromJson(before.toJson());

      expect(after.promptSide, PromptSide.mix);
      expect(after.mixSides, before.mixSides);
      expect(after.mixOrder, MixOrder.rotate);
    });

    test('a config written before mix existed reads the mix defaults', () {
      final config = GameConfig.fromJson(const <String, dynamic>{
        'gameId': 'flashcard',
        'mode': 'daily',
        'selection': 'due',
        'limit': 20,
        'promptSide': 'wordFirst',
      });

      expect(config.mixSides, PromptSide.defaultMixSides);
      expect(config.mixOrder, MixOrder.random);
    });

    test('corrupt mix sides fall back to the defaults', () {
      // `mix` itself is not a face, and fewer than two faces is not a mix.
      final config = GameConfig.fromJson(const <String, dynamic>{
        'gameId': 'flashcard',
        'promptSide': 'mix',
        'mixSides': <String>['mix', 'sideways', 'ipaFirst'],
        'mixOrder': 'zigzag',
      });

      expect(config.mixSides, PromptSide.defaultMixSides);
      expect(config.mixOrder, MixOrder.random);
    });

    test('a re-read quick test keeps its size', () {
      final config = GameConfig.fromJson(const <String, dynamic>{
        'gameId': 'flashcard',
        'mode': 'quick_test',
        'selection': 'random',
        'limit': 500,
      });
      expect(config.limit, 500);
    });
  });

  group('GameRegistry (F-067 🔴)', () {
    late GameRegistry registry;

    setUp(() {
      registry = GameRegistry()..register(DummyGame());
    });

    test('a game is reachable by its id', () {
      expect(registry.byId(DummyGame.gameId), isA<DummyGame>());
    });

    test('an unknown id throws rather than guessing a substitute', () {
      // A stored session naming a game this build does not have is a real
      // situation - an uninstalled plugin, a downgrade. Silently running a
      // different game would grade the user against rules they never played by.
      expect(() => registry.byId('listen-and-choose'), throwsStateError);
    });

    test('registering the same id twice replaces rather than duplicates', () {
      registry.register(DummyGame());
      expect(registry.games.length, 1);
    });

    test('every registered game gets a hub card, locked or not', () {
      // F-060: a game the user cannot start yet still needs a card saying why.
      expect(registry.available(0), hasLength(1));
      expect(registry.available(100), hasLength(1));
    });

    test('availability is minCards against the word count', () {
      final descriptor = registry.available(0).single;
      expect(registry.isUnlocked(descriptor, descriptor.minCards - 1), isFalse);
      expect(registry.isUnlocked(descriptor, descriptor.minCards), isTrue);
    });
  });

  group('a game is pure (F-067 🔴)', () {
    PracticeCardData cardFor(String id) => PracticeCardData(
      word: Word(
        id: id,
        headword: Headword(id),
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      ),
      card: StudyCard(wordId: id, dueAt: DateTime.utc(2026)),
    );

    test('buildRounds turns a pool into rounds and nothing else', () {
      final game = DummyGame();
      final pool = <PracticeCardData>[cardFor('a'), cardFor('b'), cardFor('c')];

      final rounds = game.buildRounds(quickTest(seed: 1), pool);

      expect(rounds, hasLength(pool.length));
      expect(rounds.map((r) => r.index), <int>[
        0,
        1,
        2,
      ], reason: 'rounds are indexed in order');
    });

    test('the same seed builds the same order twice', () {
      // The seed is stored so a session can be replayed or debugged
      // (GAMES.md §4). That is only true if it actually determines the order.
      final pool = <PracticeCardData>[
        for (final id in <String>['a', 'b', 'c', 'd', 'e']) cardFor(id),
      ];

      final first = DummyGame().buildRounds(quickTest(seed: 99), pool);
      final second = DummyGame().buildRounds(quickTest(seed: 99), pool);

      expect(
        first.map((r) => r.card.word.id),
        second.map((r) => r.card.word.id),
      );
    });

    test('grade echoes the answer for a self-graded game', () {
      final game = DummyGame();
      final round = game.buildRounds(quickTest(), <PracticeCardData>[
        cardFor('a'),
      ]).single;

      expect(
        game.grade(
          round,
          const GameAnswer(
            result: ReviewOutcome.easy,
            elapsed: Duration(seconds: 1),
          ),
        ),
        ReviewOutcome.easy,
      );
    });

    testWidgets('buildRoundView calls onAnswer exactly once', (tester) async {
      final game = DummyGame();
      final round = game.buildRounds(quickTest(), <PracticeCardData>[
        cardFor('a'),
      ]).single;
      final answers = <GameAnswer>[];

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) => game.buildRoundView(
              context,
              round,
              GameRoundCallbacks(onAnswer: answers.add),
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(DummyGame.goodKey));
      await tester.pump();

      expect(answers, hasLength(1));
      expect(answers.single.result, ReviewOutcome.good);
    });
  });
}
