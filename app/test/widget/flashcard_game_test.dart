import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/application/practice/game_contracts.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/theme/app_theme.dart';
import 'package:vocabnote/domain/entities/practice_session.dart';
import 'package:vocabnote/domain/entities/study_card.dart';
import 'package:vocabnote/domain/entities/word.dart';
import 'package:vocabnote/domain/repositories/practice_repository.dart';
import 'package:vocabnote/domain/value_objects/headword.dart';
import 'package:vocabnote/domain/value_objects/ipa.dart';
import 'package:vocabnote/presentation/practice/games/flashcard/flashcard_game.dart';

/// The flashcard game (`docs/GAMES.md` §6, `docs/UI-UX.md` §4.7, F-063).
void main() {
  PracticeCardData card({
    String id = 'w1',
    String headword = 'cough',
    String? ipaUk = 'kɒf',
    String? definition = 'To expel air from the lungs',
    String? firstNote,
  }) => PracticeCardData(
    word: Word(
      id: id,
      headword: Headword(headword),
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
      ipaUk: ipaUk == null ? null : Ipa.fromStorage(ipaUk),
      definition: definition,
    ),
    card: StudyCard(wordId: id, dueAt: DateTime.utc(2026)),
    firstNote: firstNote,
  );

  GameConfig config({
    PromptSide promptSide = PromptSide.wordFirst,
    PracticeMode mode = PracticeMode.daily,
    Set<PromptSide> mixSides = PromptSide.defaultMixSides,
    MixOrder mixOrder = MixOrder.random,
    int? seed,
  }) => GameConfig(
    gameId: FlashcardGame.gameId,
    mode: mode,
    selection: CardSelection.due,
    limit: 20,
    promptSide: promptSide,
    mixSides: mixSides,
    mixOrder: mixOrder,
    seed: seed,
  );

  FlashcardRound roundFor(
    PracticeCardData data, {
    PromptSide promptSide = PromptSide.wordFirst,
    bool isFirstRound = false,
    bool autoPlayOnReveal = true,
  }) => FlashcardRound(
    index: 0,
    card: data,
    promptSide: promptSide,
    isFirstRound: isFirstRound,
    autoPlayOnReveal: autoPlayOnReveal,
  );

  Future<void> pumpRound(
    WidgetTester tester,
    FlashcardRound round, {
    required void Function(GameAnswer) onAnswer,
    String? Function(ReviewOutcome)? intervalLabel,
    VoidCallback? onSpeak,
    bool reduceMotion = false,
    int position = 0,
    double textScale = 1,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppL10n.localizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        home: MediaQuery(
          data: MediaQueryData(
            disableAnimations: reduceMotion,
            textScaler: TextScaler.linear(textScale),
          ),
          child: Scaffold(
            body: Builder(
              builder: (context) => const FlashcardGame().buildRoundView(
                context,
                round,
                GameRoundCallbacks(
                  onAnswer: onAnswer,
                  onSpeak: onSpeak,
                  intervalLabel: intervalLabel,
                  position: position,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('buildRounds', () {
    test('makes one round per card, in order', () {
      final rounds = const FlashcardGame().buildRounds(
        config(),
        <PracticeCardData>[card(id: 'a'), card(id: 'b'), card(id: 'c')],
      );

      expect(rounds.map((r) => r.index), <int>[0, 1, 2]);
      expect(rounds.map((r) => r.card.word.id), <String>['a', 'b', 'c']);
    });

    test('only the first round carries the reveal hint', () {
      // UI-UX §4.7: "Tap to reveal" on round 1 only. A hint on every card is
      // noise by card three.
      final rounds = const FlashcardGame().buildRounds(
        config(),
        <PracticeCardData>[card(id: 'a'), card(id: 'b')],
      );

      expect(rounds.first.isFirstRound, isTrue);
      expect(rounds.last.isFirstRound, isFalse);
    });

    test('without a seed the pool order is kept', () {
      // A daily review arrives already ordered by due date. Re-shuffling it
      // would throw that ordering away.
      final pool = <PracticeCardData>[
        for (final id in <String>['a', 'b', 'c', 'd', 'e']) card(id: id),
      ];
      final rounds = const FlashcardGame().buildRounds(config(), pool);

      expect(rounds.map((r) => r.card.word.id), pool.map((c) => c.word.id));
    });

    test('the same seed shuffles the same way twice', () {
      final pool = <PracticeCardData>[
        for (final id in <String>['a', 'b', 'c', 'd', 'e']) card(id: id),
      ];

      final first = const FlashcardGame().buildRounds(config(seed: 5), pool);
      final second = const FlashcardGame().buildRounds(config(seed: 5), pool);

      expect(
        first.map((r) => r.card.word.id),
        second.map((r) => r.card.word.id),
      );
    });
  });

  group('the prompt side', () {
    test('wordFirst shows the headword', () {
      expect(roundFor(card()).frontText, 'cough');
    });

    test('ipaFirst shows the transcription', () {
      final round = roundFor(card(), promptSide: PromptSide.ipaFirst);
      expect(round.frontText, 'kɒf');
      expect(round.frontIsIpa, isTrue);
    });

    test('meaningFirst shows the definition', () {
      final round = roundFor(card(), promptSide: PromptSide.meaningFirst);
      expect(round.frontText, 'To expel air from the lungs');
    });

    test('falls back to the headword when the chosen side is empty', () {
      // A word with no definition is exactly a word worth practising, so it
      // must not be shown as a blank card or skipped.
      final round = roundFor(
        card(definition: null),
        promptSide: PromptSide.meaningFirst,
      );
      expect(round.frontIsFallback, isTrue);
      expect(round.frontText, 'cough');
      expect(round.frontIsIpa, isFalse);
    });
  });

  group('mix', () {
    List<PracticeCardData> pool(int n, {String? ipaUk = 'kɒf'}) =>
        <PracticeCardData>[
          for (var i = 0; i < n; i++) card(id: 'w$i', ipaUk: ipaUk),
        ];

    test('no round is left as mix: every round gets a real face', () {
      final rounds = const FlashcardGame().buildRounds(
        config(promptSide: PromptSide.mix, seed: 1),
        pool(30),
      );

      expect(rounds.map((r) => r.promptSide), isNot(contains(PromptSide.mix)));
    });

    test('random only uses the ticked faces, and uses all of them', () {
      final rounds = const FlashcardGame().buildRounds(
        config(
          promptSide: PromptSide.mix,
          mixSides: const <PromptSide>{
            PromptSide.ipaFirst,
            PromptSide.meaningFirst,
          },
          seed: 7,
        ),
        pool(30),
      );

      expect(rounds.map((r) => r.promptSide).toSet(), <PromptSide>{
        PromptSide.ipaFirst,
        PromptSide.meaningFirst,
      });
    });

    test('random with the same seed picks the same faces twice', () {
      final c = config(
        promptSide: PromptSide.mix,
        mixSides: PromptSide.mixableSides,
        seed: 99,
      );
      final first = const FlashcardGame().buildRounds(c, pool(20));
      final second = const FlashcardGame().buildRounds(c, pool(20));

      expect(first.map((r) => r.promptSide), second.map((r) => r.promptSide));
    });

    test('take turns rotates word, sounds, meaning in that order', () {
      final rounds = const FlashcardGame().buildRounds(
        config(
          promptSide: PromptSide.mix,
          mixSides: PromptSide.mixableSides,
          mixOrder: MixOrder.rotate,
        ),
        pool(5),
      );

      expect(rounds.map((r) => r.promptSide), <PromptSide>[
        PromptSide.wordFirst,
        PromptSide.ipaFirst,
        PromptSide.meaningFirst,
        PromptSide.wordFirst,
        PromptSide.ipaFirst,
      ]);
    });

    test('a card without a ticked face opens on another ticked face', () {
      // No transcription: a sounds-or-meaning mix must open on the meaning,
      // never on an empty card or a silent fallback to the word.
      final rounds = const FlashcardGame().buildRounds(
        config(
          promptSide: PromptSide.mix,
          mixSides: const <PromptSide>{
            PromptSide.ipaFirst,
            PromptSide.meaningFirst,
          },
          mixOrder: MixOrder.rotate,
        ),
        pool(4, ipaUk: null),
      );

      expect(
        rounds.map((r) => r.promptSide),
        everyElement(PromptSide.meaningFirst),
      );
      expect(rounds.map((r) => r.frontIsFallback), everyElement(isFalse));
    });

    test('a card with none of the ticked faces falls back to the word', () {
      final rounds = const FlashcardGame().buildRounds(
        config(
          promptSide: PromptSide.mix,
          mixSides: const <PromptSide>{
            PromptSide.ipaFirst,
            PromptSide.meaningFirst,
          },
        ),
        <PracticeCardData>[card(ipaUk: null, definition: null)],
      );

      expect(rounds.single.frontText, 'cough');
    });

    test('mix is ignored when the prompt side is not mix', () {
      final rounds = const FlashcardGame().buildRounds(
        config(
          promptSide: PromptSide.ipaFirst,
          mixSides: PromptSide.mixableSides,
          mixOrder: MixOrder.rotate,
        ),
        pool(3),
      );

      expect(
        rounds.map((r) => r.promptSide),
        everyElement(PromptSide.ipaFirst),
      );
    });
  });

  group('revealing', () {
    testWidgets('the back is hidden until the card is tapped', (tester) async {
      await pumpRound(tester, roundFor(card()), onAnswer: (_) {});

      expect(find.text('To expel air from the lungs'), findsNothing);
      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();
      expect(find.text('To expel air from the lungs'), findsOneWidget);
    });

    testWidgets('a swipe up reveals as well as a tap', (tester) async {
      // UI-UX §1: a gesture may be a shortcut, never the only way.
      await pumpRound(tester, roundFor(card()), onAnswer: (_) {});

      await tester.fling(find.byType(Card), const Offset(0, -200), 1000);
      await tester.pumpAndSettle();
      expect(find.text('To expel air from the lungs'), findsOneWidget);
    });

    testWidgets('there is nothing to grade before the card is revealed', (
      tester,
    ) async {
      // Recording an answer to a question the user never saw would be worse
      // than useless - it would move their schedule.
      await pumpRound(tester, roundFor(card()), onAnswer: (_) {});

      expect(find.byKey(const ValueKey<String>('grade-good')), findsNothing);
    });

    testWidgets('the Show answer button reveals without answering', (
      tester,
    ) async {
      final answers = <GameAnswer>[];
      await pumpRound(tester, roundFor(card()), onAnswer: answers.add);

      await tester.tap(find.text('Show answer'));
      await tester.pumpAndSettle();

      expect(find.text('To expel air from the lungs'), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('grade-good')), findsOneWidget);
      expect(answers, isEmpty);
    });

    testWidgets('the back shows word, IPA, definition and the first note', (
      tester,
    ) async {
      await pumpRound(
        tester,
        roundFor(card(firstNote: 'jaw lower')),
        onAnswer: (_) {},
      );
      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();

      expect(find.text('cough'), findsOneWidget);
      expect(find.textContaining('kɒf', findRichText: true), findsOneWidget);
      expect(find.text('To expel air from the lungs'), findsOneWidget);
      expect(find.text('jaw lower'), findsOneWidget);
    });
  });

  group('grading', () {
    testWidgets('each button reports its own outcome exactly once', (
      tester,
    ) async {
      for (final outcome in <ReviewOutcome>[
        ReviewOutcome.again,
        ReviewOutcome.good,
        ReviewOutcome.easy,
      ]) {
        final answers = <GameAnswer>[];
        await pumpRound(tester, roundFor(card()), onAnswer: answers.add);
        await tester.tap(find.byType(Card));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(ValueKey<String>('grade-${outcome.name}')));
        await tester.pumpAndSettle();

        expect(answers, hasLength(1), reason: outcome.name);
        expect(answers.single.result, outcome, reason: outcome.name);
      }
    });

    test('grade echoes the tap, because the game has no opinion', () {
      final round = roundFor(card());
      expect(
        const FlashcardGame().grade(
          round,
          const GameAnswer(result: ReviewOutcome.again, elapsed: Duration.zero),
        ),
        ReviewOutcome.again,
      );
    });

    testWidgets('shows the next interval on each button when given one', (
      tester,
    ) async {
      // UI-UX §4.7: each button shows its next interval, so the schedule is
      // never mysterious.
      await pumpRound(
        tester,
        roundFor(card()),
        onAnswer: (_) {},
        intervalLabel: (outcome) => switch (outcome) {
          ReviewOutcome.again => '10m',
          ReviewOutcome.good => '2d',
          ReviewOutcome.easy => '4d',
          ReviewOutcome.skipped => '',
        },
      );
      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();

      expect(find.text('10m'), findsOneWidget);
      expect(find.text('2d'), findsOneWidget);
      expect(find.text('4d'), findsOneWidget);
    });

    testWidgets('shows no interval when there is none to show', (tester) async {
      // A quick test does not move the schedule, so an interval on its buttons
      // would be a lie. The runner passes null and the buttons stay bare.
      await pumpRound(tester, roundFor(card()), onAnswer: (_) {});
      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey<String>('grade-good')), findsOneWidget);
      expect(find.text('10m'), findsNothing);
      expect(find.text('2d'), findsNothing);
    });
  });

  group('found on the emulator', () {
    testWidgets('the reveal hint is for the first round, not a repeat', (
      tester,
    ) async {
      // UI-UX §4.7: "Tap to reveal" on round 1 only. A repeat is built as a
      // one-card session, so it believes it is round 1 as well; the runner's
      // position is what knows better.
      await pumpRound(
        tester,
        roundFor(card(), isFirstRound: true),
        onAnswer: (_) {},
      );
      expect(find.text('Tap to reveal, swipe to skip'), findsOneWidget);

      await pumpRound(
        tester,
        roundFor(card(), isFirstRound: true),
        onAnswer: (_) {},
        position: 4,
      );
      expect(find.text('Tap to reveal, swipe to skip'), findsNothing);
    });

    testWidgets('at 200% text on 320dp the grades stack, not break words', (
      tester,
    ) async {
      // Three equal buttons at that size broke "Again" into "Agai / n".
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await pumpRound(tester, roundFor(card()), onAnswer: (_) {}, textScale: 2);
      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();

      final again = tester.getRect(
        find.byKey(const ValueKey<String>('grade-again')),
      );
      final good = tester.getRect(
        find.byKey(const ValueKey<String>('grade-good')),
      );
      expect(good.top, greaterThan(again.bottom - 0.5), reason: 'stacked');
    });
  });

  group('answering once', () {
    testWidgets('a double tap reports one answer, not two', (tester) async {
      // `onAnswer` is "exactly once" per round, and the round is only swapped
      // after the runner has saved - so a second tap lands on the same round.
      final answers = <GameAnswer>[];
      await pumpRound(tester, roundFor(card()), onAnswer: answers.add);
      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey<String>('grade-good')));
      await tester.tap(find.byKey(const ValueKey<String>('grade-good')));
      await tester.pumpAndSettle();

      expect(answers, hasLength(1));
    });

    testWidgets('a new round opens fresh even at the same index', (
      tester,
    ) async {
      // A repeat is built as a one-card session, so two repeats in a row are
      // both index 0. Keyed on the index, the second opened already revealed
      // and - once answering was guarded - could not be answered at all.
      final answers = <GameAnswer>[];
      await pumpRound(tester, roundFor(card(id: 'a')), onAnswer: answers.add);
      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey<String>('grade-again')));
      await tester.pumpAndSettle();

      await pumpRound(
        tester,
        roundFor(card(id: 'b', definition: 'The second card')),
        onAnswer: answers.add,
      );
      expect(find.text('The second card'), findsNothing, reason: 'the front');
      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey<String>('grade-good')));
      await tester.pumpAndSettle();

      expect(answers.map((answer) => answer.result), <ReviewOutcome>[
        ReviewOutcome.again,
        ReviewOutcome.good,
      ]);
    });
  });

  group('swiping to grade (UI-UX §4.7)', () {
    Future<List<ReviewOutcome>> swipe(
      WidgetTester tester,
      Offset offset, {
      bool reveal = true,
      double speed = 1000,
    }) async {
      final answers = <GameAnswer>[];
      await pumpRound(tester, roundFor(card()), onAnswer: answers.add);
      if (reveal) {
        await tester.tap(find.byType(Card));
        await tester.pumpAndSettle();
      }
      await tester.fling(find.byType(Card), offset, speed);
      await tester.pumpAndSettle();
      return answers.map((answer) => answer.result).toList();
    }

    testWidgets('a slow sideways drag is not a swipe', (tester) async {
      // 150 px/s is already a fling to Flutter (anything over 50), and about
      // what a thumb nudging the card while reading the back produces. It
      // must not grade the card.
      expect(await swipe(tester, const Offset(300, 0), speed: 150), isEmpty);
    });

    testWidgets('left is Again', (tester) async {
      expect(await swipe(tester, const Offset(-300, 0)), <ReviewOutcome>[
        ReviewOutcome.again,
      ]);
    });

    testWidgets('right is Good', (tester) async {
      expect(await swipe(tester, const Offset(300, 0)), <ReviewOutcome>[
        ReviewOutcome.good,
      ]);
    });

    testWidgets('a sideways swipe on the front skips, either way', (
      tester,
    ) async {
      // Never a grade for a question the user has not seen the answer to, so
      // the direction that means Good on the back must not mean it here.
      for (final offset in <Offset>[
        const Offset(300, 0),
        const Offset(-300, 0),
      ]) {
        expect(await swipe(tester, offset, reveal: false), <ReviewOutcome>[
          ReviewOutcome.skipped,
        ]);
      }
    });

    testWidgets('a slow drag on the front does not skip', (tester) async {
      expect(
        await swipe(tester, const Offset(300, 0), reveal: false, speed: 150),
        isEmpty,
      );
    });

    testWidgets('the buttons still work, so a swipe is never the only way', (
      tester,
    ) async {
      final answers = <GameAnswer>[];
      await pumpRound(tester, roundFor(card()), onAnswer: answers.add);
      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey<String>('grade-easy')));
      await tester.pumpAndSettle();

      expect(answers.single.result, ReviewOutcome.easy);
    });
  });

  group('skipping', () {
    testWidgets('Skip moves on from the front without a grade', (tester) async {
      final answers = <GameAnswer>[];
      await pumpRound(tester, roundFor(card()), onAnswer: answers.add);

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(answers.map((a) => a.result), <ReviewOutcome>[
        ReviewOutcome.skipped,
      ]);
    });

    testWidgets('Skip moves on from the back without a grade', (tester) async {
      final answers = <GameAnswer>[];
      await pumpRound(tester, roundFor(card()), onAnswer: answers.add);
      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(answers.map((a) => a.result), <ReviewOutcome>[
        ReviewOutcome.skipped,
      ]);
    });

    testWidgets('a double tap on Skip skips once', (tester) async {
      final answers = <GameAnswer>[];
      await pumpRound(tester, roundFor(card()), onAnswer: answers.add);

      await tester.tap(find.text('Skip'));
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(answers, hasLength(1));
    });

    test('the game echoes a skip, so it never schedules', () {
      expect(
        const FlashcardGame().grade(
          roundFor(card()),
          const GameAnswer(
            result: ReviewOutcome.skipped,
            elapsed: Duration.zero,
          ),
        ),
        ReviewOutcome.skipped,
      );
    });
  });

  group('typing an answer', () {
    final field = find.byKey(const ValueKey<String>('flashcard-answer'));
    final check = find.byKey(const ValueKey<String>('flashcard-check'));

    bool checkEnabled(WidgetTester tester) =>
        tester.widget<FilledButton>(check).onPressed != null;

    test('the word is the answer when the front hides it', () {
      for (final side in <PromptSide>[
        PromptSide.ipaFirst,
        PromptSide.meaningFirst,
      ]) {
        final round = roundFor(card(), promptSide: side);
        expect(round.expectedAnswer, 'cough', reason: side.name);
        expect(round.asksForWord, isTrue, reason: side.name);
      }
    });

    test('the meaning is the answer when the front shows the word', () {
      final round = roundFor(card());
      expect(round.expectedAnswer, 'To expel air from the lungs');
      expect(round.asksForWord, isFalse);
    });

    test('a front that fell back to the word asks for the meaning', () {
      final round = roundFor(
        card(ipaUk: null),
        promptSide: PromptSide.ipaFirst,
      );
      expect(round.expectedAnswer, 'To expel air from the lungs');
    });

    test('a word with no definition has no answer to type', () {
      expect(roundFor(card(definition: '  ')).expectedAnswer, isNull);
    });

    testWidgets('the field asks for what the card is asking for', (
      tester,
    ) async {
      await pumpRound(tester, roundFor(card()), onAnswer: (_) {});
      expect(find.text('Type the meaning'), findsOneWidget);

      await pumpRound(
        tester,
        roundFor(card(), promptSide: PromptSide.meaningFirst),
        onAnswer: (_) {},
      );
      expect(find.text('Type the word'), findsOneWidget);
    });

    testWidgets('with no answer to type there is no field, only Show answer', (
      tester,
    ) async {
      await pumpRound(
        tester,
        roundFor(card(definition: null)),
        onAnswer: (_) {},
      );

      expect(field, findsNothing);
      expect(check, findsNothing);
      await tester.tap(find.text('Show answer'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey<String>('grade-good')), findsOneWidget);
    });

    testWidgets('Check needs something typed', (tester) async {
      await pumpRound(tester, roundFor(card()), onAnswer: (_) {});
      expect(checkEnabled(tester), isFalse);

      await tester.enterText(field, '   ');
      await tester.pump();
      expect(checkEnabled(tester), isFalse);

      await tester.enterText(field, 'air');
      await tester.pump();
      expect(checkEnabled(tester), isTrue);
    });

    testWidgets('Check flips the card and shows how close it was', (
      tester,
    ) async {
      final answers = <GameAnswer>[];
      await pumpRound(tester, roundFor(card()), onAnswer: answers.add);

      await tester.enterText(field, 'air');
      await tester.pump();
      await tester.tap(check);
      await tester.pumpAndSettle();

      expect(find.text('50% match'), findsOneWidget);
      expect(find.text('You wrote: air'), findsOneWidget);
      expect(find.text('To expel air from the lungs'), findsOneWidget);
      expect(answers, isEmpty, reason: 'the user still grades it');
    });

    testWidgets('a word typed for a meaning-first card is marked on spelling', (
      tester,
    ) async {
      await pumpRound(
        tester,
        roundFor(card(), promptSide: PromptSide.meaningFirst),
        onAnswer: (_) {},
      );

      await tester.enterText(field, 'Cough');
      await tester.pump();
      await tester.tap(check);
      await tester.pumpAndSettle();

      expect(find.text('100% match'), findsOneWidget);
    });

    testWidgets('the keyboard Done key checks as well', (tester) async {
      await pumpRound(tester, roundFor(card()), onAnswer: (_) {});

      await tester.enterText(field, 'air');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text('50% match'), findsOneWidget);
    });

    testWidgets('a checked card can be graded, once, by the user', (
      tester,
    ) async {
      // A low match must not lapse the card by itself: the answer may be right
      // in other words.
      final answers = <GameAnswer>[];
      await pumpRound(tester, roundFor(card()), onAnswer: answers.add);
      await tester.enterText(field, 'it means to clear the throat');
      await tester.pump();
      await tester.tap(check);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey<String>('grade-good')));
      await tester.pumpAndSettle();

      expect(answers.single.result, ReviewOutcome.good);
    });

    testWidgets('revealing without Check shows no percentage', (tester) async {
      await pumpRound(tester, roundFor(card()), onAnswer: (_) {});
      await tester.enterText(field, 'air');
      await tester.pump();

      await tester.tap(find.text('Show answer'));
      await tester.pumpAndSettle();

      expect(find.textContaining('% match'), findsNothing);
    });

    testWidgets('the next card opens with an empty field and no result', (
      tester,
    ) async {
      // The State is reused between rounds, so one card's answer would
      // otherwise be sitting on the next.
      await pumpRound(tester, roundFor(card(id: 'a')), onAnswer: (_) {});
      await tester.enterText(field, 'air');
      await tester.pump();
      await tester.tap(check);
      await tester.pumpAndSettle();

      await pumpRound(tester, roundFor(card(id: 'b')), onAnswer: (_) {});

      expect(find.textContaining('% match'), findsNothing);
      expect(tester.widget<TextField>(field).controller?.text, isEmpty);
      expect(checkEnabled(tester), isFalse);
    });

    testWidgets('it does not raise the keyboard by itself', (tester) async {
      await pumpRound(tester, roundFor(card()), onAnswer: (_) {});

      expect(tester.widget<TextField>(field).autofocus, isFalse);
      expect(tester.testTextInput.isVisible, isFalse);
    });

    testWidgets('the keyboard does not correct the spelling being practised', (
      tester,
    ) async {
      await pumpRound(tester, roundFor(card()), onAnswer: (_) {});

      expect(tester.widget<TextField>(field).autocorrect, isFalse);
    });

    testWidgets('the field takes any language the keyboard can type', (
      tester,
    ) async {
      // Reported on a device: Vietnamese could not be typed. On Android
      // `enableSuggestions: false` also sets the visible-password variation,
      // which stops Telex and VNI composing accents.
      await pumpRound(tester, roundFor(card()), onAnswer: (_) {});

      final input = tester.widget<TextField>(field);
      expect(input.enableSuggestions, isTrue);
      expect(input.obscureText, isFalse);
      expect(input.keyboardType, anyOf(isNull, TextInputType.text));
    });

    testWidgets('an answer in Vietnamese can be typed and checked', (
      tester,
    ) async {
      await pumpRound(
        tester,
        roundFor(card(definition: 'hòn đảo')),
        onAnswer: (_) {},
      );

      await tester.enterText(field, 'hòn đảo');
      await tester.pump();
      await tester.tap(check);
      await tester.pumpAndSettle();

      expect(find.text('100% match'), findsOneWidget);
      expect(find.text('You wrote: hòn đảo'), findsOneWidget);
    });

    testWidgets('fits at 200% text with the keyboard taking the height', (
      tester,
    ) async {
      // 320dp wide, with what a keyboard leaves of a small phone.
      tester.view.physicalSize = const Size(320, 320);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await pumpRound(
        tester,
        roundFor(card(), isFirstRound: true),
        onAnswer: (_) {},
        onSpeak: () {},
        textScale: 2,
      );
      expect(tester.takeException(), isNull, reason: 'the front');

      await tester.enterText(field, 'air');
      await tester.pump();
      await tester.ensureVisible(check);
      await tester.pumpAndSettle();
      await tester.tap(check);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'the back');
      expect(find.text('50% match', skipOffstage: false), findsOneWidget);
    });
  });

  group('accessibility', () {
    testWidgets('the card announces which side is showing', (tester) async {
      // UI-UX §6: the flip card announces its state rather than silently
      // changing what it says.
      final handle = tester.ensureSemantics();
      await pumpRound(tester, roundFor(card()), onAnswer: (_) {});

      expect(
        find.bySemanticsLabel('Card front. Tap to reveal the answer.'),
        findsOneWidget,
      );

      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel('Card back. Choose how well you knew it.'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('reduce motion removes the flip animation', (tester) async {
      // F-093. A single `pump` would still find the old side mid-animation;
      // with animations disabled the switch is immediate.
      await pumpRound(
        tester,
        roundFor(card()),
        onAnswer: (_) {},
        reduceMotion: true,
      );

      await tester.tap(find.byType(Card));
      await tester.pump();

      expect(find.text('To expel air from the lungs'), findsOneWidget);
    });
  });

  group('speech (F-063)', () {
    testWidgets('the front offers a play button whenever speech is wired', (
      tester,
    ) async {
      // Missing entirely until the card was looked at on a device: the run
      // screen never passed `onSpeak`, so `UI-UX.md` §4.7's play button did
      // not exist.
      var spoken = 0;
      await pumpRound(
        tester,
        roundFor(card()),
        onAnswer: (_) {},
        onSpeak: () => spoken++,
      );

      await tester.tap(find.byIcon(Icons.volume_up));
      await tester.pumpAndSettle();
      expect(spoken, 1);
    });

    testWidgets('revealing speaks when autoplay is on', (tester) async {
      var spoken = 0;
      await pumpRound(
        tester,
        roundFor(card()),
        onAnswer: (_) {},
        onSpeak: () => spoken++,
      );

      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();
      expect(spoken, 1);
    });

    testWidgets('revealing stays silent when autoplay is off', (tester) async {
      var spoken = 0;
      await pumpRound(
        tester,
        roundFor(card(), autoPlayOnReveal: false),
        onAnswer: (_) {},
        onSpeak: () => spoken++,
      );

      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();
      expect(spoken, 0, reason: 'autoplay off means silent on reveal');
    });

    testWidgets('a meaning-first front does not offer to say the answer', (
      tester,
    ) async {
      // The word is what this card is asking for. The button spoke it, and
      // its label named it to a screen reader.
      await pumpRound(
        tester,
        roundFor(card(), promptSide: PromptSide.meaningFirst),
        onAnswer: (_) {},
        onSpeak: () {},
      );

      expect(find.byIcon(Icons.volume_up), findsNothing);
      expect(find.byTooltip('Play cough in UK'), findsNothing);
    });

    testWidgets('a meaning-first back can be heard with autoplay off', (
      tester,
    ) async {
      // Hiding the front's button must not leave this card with no way to
      // hear the word at all.
      var spoken = 0;
      await pumpRound(
        tester,
        roundFor(
          card(),
          promptSide: PromptSide.meaningFirst,
          autoPlayOnReveal: false,
        ),
        onAnswer: (_) {},
        onSpeak: () => spoken++,
      );

      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();
      expect(spoken, 0);

      await tester.tap(find.byIcon(Icons.volume_up));
      await tester.pumpAndSettle();
      expect(spoken, 1);
    });

    testWidgets('a meaning-first card with no meaning keeps its button', (
      tester,
    ) async {
      // It fell back to showing the word, so there is nothing to give away.
      await pumpRound(
        tester,
        roundFor(card(definition: null), promptSide: PromptSide.meaningFirst),
        onAnswer: (_) {},
        onSpeak: () {},
      );

      expect(find.byIcon(Icons.volume_up), findsOneWidget);
    });

    testWidgets('an IPA front plays the sound without naming the word', (
      tester,
    ) async {
      // Hearing the transcription is fair; reading the word out in the
      // button's label is not.
      var spoken = 0;
      await pumpRound(
        tester,
        roundFor(card(), promptSide: PromptSide.ipaFirst),
        onAnswer: (_) {},
        onSpeak: () => spoken++,
      );

      final button = tester.widget<IconButton>(find.byType(IconButton));
      expect(button.tooltip, isNot(contains('cough')));

      await tester.tap(find.byIcon(Icons.volume_up));
      await tester.pumpAndSettle();
      expect(spoken, 1);
    });

    testWidgets('a word-first back adds no second button', (tester) async {
      await pumpRound(
        tester,
        roundFor(card()),
        onAnswer: (_) {},
        onSpeak: () {},
      );

      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.volume_up), findsNothing);
    });

    testWidgets('the play button still works when autoplay is off', (
      tester,
    ) async {
      // Autoplay decides whether the word is spoken *without being asked*, not
      // whether asking works. Gating both on one flag made the button dead.
      var spoken = 0;
      await pumpRound(
        tester,
        roundFor(card(), autoPlayOnReveal: false),
        onAnswer: (_) {},
        onSpeak: () => spoken++,
      );

      await tester.tap(find.byIcon(Icons.volume_up));
      await tester.pumpAndSettle();
      expect(spoken, 1);
    });
  });
}
