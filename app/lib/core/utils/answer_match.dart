import 'dart:math';

/// How close [typed] is to [expected], from 0 to 100.
///
/// A flashcard's answer is either a word, where spelling is the whole question,
/// or a definition, where the same meaning can be put many ways. So two
/// measures run and the better one counts: the letters of the whole answer,
/// and how many of the words that carry the meaning were given, in any order
/// and forgiving a typo in each. Both only count what is on the card - nothing
/// here knows that "cough" and "hack" mean the same thing, which is why the
/// number advises the user's own grade rather than replacing it.
///
/// Case, punctuation, spacing and accents never count: "hon dao" is a full
/// answer to "hòn đảo", because people type meanings without diacritics.
/// [expected] may list meanings split by `;`, `/` or a new line, and any one of
/// them is a full answer.
int answerMatchPercent(String typed, String expected) {
  final answer = _normalise(typed);
  if (answer.isEmpty) return 0;

  var best = 0.0;
  for (final candidate in <String>[
    expected,
    ...expected.split(RegExp(r'[;/\n]')),
  ]) {
    final target = _normalise(candidate);
    if (target.isEmpty) continue;
    best = max(best, _similarity(answer, target));
    best = max(best, _wordOverlap(answer, target));
  }

  // Rounding must not call a near miss a match: 100 has to mean it matched.
  return best >= 1 ? 100 : min((best * 100).round(), 99);
}

/// The words too common to say anything about a meaning.
const Set<String> _fillers = <String>{
  'a',
  'an',
  'and',
  'are',
  'as',
  'at',
  'be',
  'by',
  'for',
  'from',
  'in',
  'is',
  'it',
  'of',
  'on',
  'or',
  'that',
  'the',
  'this',
  'to',
  'with',
};

/// How alike two words must be to count as the same word misspelled.
const double _sameWord = 0.75;

/// Each plain letter and the accented letters that fold to it: Vietnamese, and
/// the Latin letters that turn up in English loanwords.
const Map<String, String> _accented = <String, String>{
  'a': 'àáảãạăằắẳẵặâầấẩẫậäåāą',
  'c': 'çć',
  'd': 'đ',
  'e': 'èéẻẽẹêềếểễệëēę',
  'i': 'ìíỉĩịîïī',
  'n': 'ñń',
  'o': 'òóỏõọôồốổỗộơờớởỡợöøō',
  's': 'šś',
  'u': 'ùúủũụưừứửữựûüū',
  'y': 'ỳýỷỹỵÿ',
  'z': 'žź',
};

final Map<int, int> _folded = <int, int>{
  for (final MapEntry(key: plain, value: letters) in _accented.entries)
    for (final letter in letters.runes) letter: plain.codeUnitAt(0),
};

/// Lower case, without accents, and with anything but letters and digits
/// reduced to single spaces.
///
/// Combining accents are only dropped in their own block. `\p{M}` stays allowed
/// beyond it: in Devanagari, say, those marks are the vowels.
String _normalise(String text) {
  final bare = text.toLowerCase().replaceAll(RegExp('[̀-ͯ]'), '');
  return String.fromCharCodes(bare.runes.map((rune) => _folded[rune] ?? rune))
      .replaceAll(RegExp(r'[^\p{L}\p{M}\p{N}]+', unicode: true), ' ')
      .trim();
}

/// The words of [text] that carry meaning, or all of them if none do.
List<String> _meaningWords(String text) {
  final words = text.split(' ');
  final meaningful = words.where((word) => !_fillers.contains(word)).toList();
  return meaningful.isEmpty ? words : meaningful;
}

/// A Dice score over the meaning words, so that both leaving words out and
/// padding the answer with others cost marks.
double _wordOverlap(String answer, String target) {
  final given = _meaningWords(answer);
  final wanted = _meaningWords(target);
  final unused = List<String>.of(given);

  var matched = 0.0;
  for (final word in wanted) {
    var closest = 0.0;
    var closestIndex = -1;
    for (var i = 0; i < unused.length; i++) {
      final score = _similarity(word, unused[i]);
      if (score > closest) {
        closest = score;
        closestIndex = i;
      }
    }
    if (closest >= _sameWord) {
      matched += closest;
      unused.removeAt(closestIndex);
    }
  }
  return 2 * matched / (given.length + wanted.length);
}

/// One minus the edit distance, as a share of the longer string.
double _similarity(String a, String b) {
  final left = a.runes.toList();
  final right = b.runes.toList();
  final longest = max(left.length, right.length);
  if (longest == 0) return 1;

  var previous = List<int>.generate(right.length + 1, (i) => i);
  for (var i = 1; i <= left.length; i++) {
    final current = List<int>.filled(right.length + 1, 0)..[0] = i;
    for (var j = 1; j <= right.length; j++) {
      final substitution =
          previous[j - 1] + (left[i - 1] == right[j - 1] ? 0 : 1);
      current[j] = min(substitution, min(previous[j], current[j - 1]) + 1);
    }
    previous = current;
  }
  return 1 - previous[right.length] / longest;
}
