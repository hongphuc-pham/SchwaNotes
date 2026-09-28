/// The URLs the app links out to.
///
/// Built in one place and tested, because a malformed one fails silently: the
/// browser opens on a 404 and the user is left thinking the app is broken.
///
/// `docs/RULES.md` §13 is the reason there is nothing else here for Cambridge.
/// Linking out is the **only** allowed integration — no scraping, no embedded
/// webview of their content, no parsing what comes back.
library;

/// Where the app's third-party content comes from (F-075, RULES §14).
///
/// CC BY-SA 4.0 asks for a link back and the licence named; these are the
/// links *Data sources & licences* offers.
abstract final class SourceLinks {
  /// Wiktionary, where the dictionary text is written.
  static final Uri wiktionary = Uri.parse('https://en.wiktionary.org/');

  /// FreeDictionaryAPI.com, the API look-up calls.
  static final Uri freeDictionary = Uri.parse('https://freedictionaryapi.com/');

  /// The CC BY-SA 4.0 licence the dictionary text is shared under.
  static final Uri ccBySa = Uri.parse(
    'https://creativecommons.org/licenses/by-sa/4.0/',
  );

  /// The CMU Pronouncing Dictionary, behind the offline pronunciations.
  static final Uri cmudict = Uri.parse('https://github.com/cmusphinx/cmudict');
}

/// The project's own pages.
abstract final class ProjectLinks {
  /// Where problems are reported (F-072). Opened in the browser; nothing is
  /// sent from the app.
  static final Uri issues = Uri.parse(
    'https://github.com/hongphuc-pham/SchwaNotes/issues',
  );

  /// The owner's Ko-fi page, behind *Buy me a coffee* in Settings (M8).
  /// `supportLinkProvider` reads it and may be null, which hides the row.
  ///
  /// A tip there unlocks nothing in the app. That is what keeps it outside
  /// Google Play Billing: Play treats a tip that goes wholly to the creator and
  /// grants no digital content as a peer-to-peer payment (Payments policy,
  /// support.google.com/googleplay/android-developer/answer/10281818).
  static final Uri support = Uri.parse('https://ko-fi.com/williamphucpham');
}

/// The *Send feedback* email (F-072).
///
/// Built here, and tested, because both ways it goes wrong are silent:
/// `Uri(queryParameters:)` encodes a space as `+`, which mail apps show as a
/// literal plus (dart-lang/sdk#43838); and some mail apps cut off or refuse a
/// link much past ~2,000 characters.
abstract final class FeedbackEmail {
  /// The address, set at build time with `--dart-define=FEEDBACK_EMAIL=…`.
  /// Empty hides *Send feedback*. v1.0 leaves it empty on purpose: feedback is
  /// GitHub Issues only (owner, M8).
  static const String address = String.fromEnvironment('FEEDBACK_EMAIL');

  /// The longest `mailto:` link built - under the ~2,000 characters every
  /// common mail app accepts (`plan.md` research for slice 6).
  static const int maxLength = 1900;

  /// The `mailto:` link, with spaces as `%20` and new lines as `%0A`.
  static Uri uri({
    required String to,
    required String subject,
    required String body,
  }) => Uri.parse(
    'mailto:$to'
    '?subject=${Uri.encodeComponent(subject)}'
    '&body=${Uri.encodeComponent(body)}',
  );

  /// The newest whole entries of [log] that fit after [body] - separated by a
  /// blank line - while the link stays within [maxLength]. Empty when none
  /// fit.
  ///
  /// Whole entries, so a frame is never shown without the error it belongs
  /// to; newest, because they are the ones worth reading.
  static String fitLog({
    required String to,
    required String subject,
    required String body,
    required String log,
  }) {
    final entries = <String>[];
    for (final line in log.trim().split('\n')) {
      if (line.isEmpty) continue;
      if (line.startsWith('[') || entries.isEmpty) {
        entries.add(line);
      } else {
        entries[entries.length - 1] = '${entries.last}\n$line';
      }
    }

    final kept = <String>[];
    for (final entry in entries.reversed) {
      final candidate = <String>[entry, ...kept].join('\n');
      final length = uri(
        to: to,
        subject: subject,
        body: '$body\n\n$candidate',
      ).toString().length;
      if (length > maxLength) break;
      kept.insert(0, entry);
    }
    return kept.join('\n');
  }
}

/// dictionary.cambridge.org, as a link only (F-025).
abstract final class CambridgeDictionary {
  /// Where an entry lives.
  static const String _base =
      'https://dictionary.cambridge.org/dictionary/english';

  /// The page for [normalisedHeadword], or null when there is nothing to look
  /// up.
  ///
  /// Takes the **normalised** headword (`Headword.normalized`): already
  /// trimmed, lowercased and with inner whitespace collapsed. Cambridge slugs
  /// multi-word entries with hyphens — `/english/look-up`, not `/english/look%20up`
  /// — so spaces become hyphens before the segment is percent-encoded.
  ///
  /// Returns null rather than a URL to a blank entry when the headword is
  /// empty, so the caller hides the button instead of offering a dead link.
  static Uri? entryFor(String normalisedHeadword) {
    final slug = normalisedHeadword.trim().replaceAll(RegExp(r'\s+'), '-');
    if (slug.isEmpty) return null;
    return Uri.parse('$_base/${Uri.encodeComponent(slug)}');
  }
}
