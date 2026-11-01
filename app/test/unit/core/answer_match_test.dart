import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/core/utils/answer_match.dart';

/// How close a typed answer is to the card's (`docs/GAMES.md` §6).
void main() {
  const definition = 'To expel air from the lungs';

  group('a word', () {
    test('ignores case, spaces and punctuation', () {
      expect(answerMatchPercent('cough', 'cough'), 100);
      expect(answerMatchPercent('  Cough!  ', 'cough'), 100);
    });

    test('a typo costs what the letters cost', () {
      expect(answerMatchPercent('cogh', 'cough'), 80);
      expect(answerMatchPercent('coff', 'cough'), 40);
    });

    test('nothing in common is zero', () {
      expect(answerMatchPercent('xyz', 'cough'), 0);
    });

    test('a word made only of little words can still match', () {
      // Dropping filler must not leave "the" with nothing to compare.
      expect(answerMatchPercent('the', 'the'), 100);
    });
  });

  group('a definition', () {
    test('filler words do not count', () {
      expect(answerMatchPercent('expel air lungs', definition), 100);
    });

    test('word order does not count', () {
      expect(answerMatchPercent('lungs expel air', definition), 100);
    });

    test('part of the meaning scores part of the marks', () {
      expect(answerMatchPercent('air', definition), 50);
    });

    test('a typo in one word does not lose the whole word', () {
      expect(answerMatchPercent('expell air lungs', definition), 94);
    });

    test('padding an answer with other words lowers it', () {
      final padded = answerMatchPercent(
        'expel air lungs cats dogs horses',
        definition,
      );
      expect(padded, lessThan(100));
      expect(padded, greaterThan(50));
    });

    test('any one of several meanings is a full answer', () {
      expect(answerMatchPercent('joyful', 'happy; joyful'), 100);
      expect(answerMatchPercent('glad', 'happy / glad'), 100);
    });
  });

  group('edges', () {
    test('an empty answer scores nothing', () {
      expect(answerMatchPercent('', 'cough'), 0);
      expect(answerMatchPercent(' ?! ', 'cough'), 0);
    });

    test('an answer with nothing to compare against scores nothing', () {
      expect(answerMatchPercent('cough', '...'), 0);
    });

    test('accents do not count: meanings get typed without them', () {
      // Found on the emulator with a real card: "dao" scored 14% against
      // "hòn đảo", and the whole meaning typed plainly lost marks too.
      expect(answerMatchPercent('hon dao', 'hòn đảo'), 100);
      expect(answerMatchPercent('hòn đảo', 'hon dao'), 100);
      expect(answerMatchPercent('dao', 'hòn đảo'), 67);
      expect(answerMatchPercent('pho', 'phở'), 100);
      expect(answerMatchPercent('dan hop xuong', 'dàn hợp xướng'), 100);
      expect(answerMatchPercent('cafe', 'café'), 100);
    });

    test('accents typed as combining marks fold the same way', () {
      expect(answerMatchPercent('cafe', 'café'), 100);
    });

    test('marks that are vowels in other scripts are kept', () {
      expect(answerMatchPercent('कि', 'की'), lessThan(100));
      expect(answerMatchPercent('की', 'की'), 100);
    });

    test('100 means it matched: a near miss never rounds up to it', () {
      final long = 'a' * 400;
      expect(answerMatchPercent('${long}b', long), 99);
    });
  });
}
