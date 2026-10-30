/// Column converters (`docs/ARCHITECTURE.md` §2, `data/db/converters/`).
///
/// Two jobs, both about not letting Dart identifiers leak into the file on
/// disk:
///
/// * enums are stored as their documented [StorageEnum.storageValue], never as
///   `EnumValue.name` - which rules out Drift's `textEnum()`;
/// * timestamps are stored as **epoch milliseconds UTC** in an INTEGER column,
///   as `docs/DATABASE.md` §2 requires - which rules out Drift's `dateTime()`,
///   whose default is unix *seconds*.
///
/// Reading is always total. An unrecognised value falls back to a documented,
/// deliberately harmless default rather than throwing: a database written by a
/// newer build must still open, and one odd row must never take down the
/// screen that lists it.
library;

import 'package:drift/drift.dart';
import 'package:vocabnote/domain/entities/app_settings.dart';
import 'package:vocabnote/domain/entities/ipa_highlight.dart';
import 'package:vocabnote/domain/entities/practice_session.dart';
import 'package:vocabnote/domain/entities/study_card.dart';
import 'package:vocabnote/domain/entities/word.dart';
import 'package:vocabnote/domain/value_objects/ipa_color_token.dart';
import 'package:vocabnote/domain/value_objects/storage_enum.dart';

/// Maps a [StorageEnum] to and from its stored string.
///
/// [fallback] is returned for any value this build does not recognise. Choose
/// it so that being wrong is boring - see the call sites below.
class StorageEnumConverter<T extends StorageEnum>
    extends TypeConverter<T, String> {
  /// Creates a converter over [values], defaulting to [fallback].
  const new(this.values, this.fallback);

  /// Every member of the enum.
  final List<T> values;

  /// Returned when the stored string is not recognised.
  final T fallback;

  @override
  T fromSql(String fromDb) {
    for (final value in values) {
      if (value.storageValue == fromDb) return value;
    }
    return fallback;
  }

  @override
  String toSql(T value) => value.storageValue;
}

/// `words.source`. Falls back to `manual`, which claims no attribution - so an
/// unreadable source can never make the app credit someone falsely.
const wordSourceConverter = StorageEnumConverter<WordSource>(
  WordSource.values,
  WordSource.manual,
);

/// `ipa_highlights.target`. Falls back to `ipa_uk`; the highlight is then
/// re-validated against that string on read, so a mismatch simply drops it.
const highlightTargetConverter = StorageEnumConverter<HighlightTarget>(
  HighlightTarget.values,
  HighlightTarget.ipaUk,
);

/// `ipa_highlights.color_token` and `word_lists.color_token`. Falls back to
/// `amber`; a highlight painted the wrong colour is a cosmetic problem, a
/// crash is not.
const ipaColorTokenConverter = StorageEnumConverter<IpaColorToken>(
  IpaColorToken.values,
  IpaColorToken.amber,
);

/// `practice_answers.result`. Falls back to `skipped`, which counts as neither
/// right nor wrong, so an unreadable row cannot inflate a score.
const reviewOutcomeConverter = StorageEnumConverter<ReviewOutcome>(
  ReviewOutcome.values,
  ReviewOutcome.skipped,
);

/// `study_cards.last_result`, which is nullable.
const nullableReviewOutcomeConverter =
    NullAwareTypeConverter<ReviewOutcome, String>.wrap(reviewOutcomeConverter);

/// `practice_sessions.mode`. Falls back to `quick_test`, the mode that does
/// **not** touch the schedule - the conservative reading of an ambiguous row.
const practiceModeConverter = StorageEnumConverter<PracticeMode>(
  PracticeMode.values,
  PracticeMode.quickTest,
);

/// `practice_sessions.source_kind`. Falls back to `all`.
const cardSourceKindConverter = StorageEnumConverter<CardSourceKind>(
  CardSourceKind.values,
  CardSourceKind.all,
);

/// `settings.prompt_side`. Falls back to `word_first`, the documented default.
const promptSideConverter = StorageEnumConverter<PromptSide>(
  PromptSide.values,
  PromptSide.wordFirst,
);

/// `settings.mix_order`. Falls back to `random`.
const mixOrderConverter = StorageEnumConverter<MixOrder>(
  MixOrder.values,
  MixOrder.random,
);

/// `settings.theme_mode`. Falls back to `system`.
const themePreferenceConverter = StorageEnumConverter<ThemePreference>(
  ThemePreference.values,
  ThemePreference.system,
);

/// `settings.tts_locale`. Falls back to `en-GB`, matching the startup voice
/// preference order in `docs/DATA-SOURCES.md` §4.
const ttsLocaleConverter = StorageEnumConverter<TtsLocale>(
  TtsLocale.values,
  TtsLocale.enGb,
);

/// Maps an INTEGER column of epoch milliseconds UTC to a [DateTime].
///
/// Drift's own `dateTime()` stores unix **seconds** by default, which would
/// silently truncate every timestamp in the app. `docs/DATABASE.md` §2 is
/// explicit that these are milliseconds, so the mapping is spelled out here.
///
/// [fromSql] always returns a UTC [DateTime]. Callers that want local time
/// convert at the edge; storing local time would break the moment a user
/// travels or the clocks change.
class EpochMillisConverter extends TypeConverter<DateTime, int> {
  /// Creates the converter.
  const new();

  @override
  DateTime fromSql(int fromDb) =>
      DateTime.fromMillisecondsSinceEpoch(fromDb, isUtc: true);

  @override
  int toSql(DateTime value) => value.toUtc().millisecondsSinceEpoch;
}

/// Epoch milliseconds for a NOT NULL timestamp column.
const epochMillisConverter = EpochMillisConverter();

/// Epoch milliseconds for a nullable timestamp column, such as
/// `words.deleted_at` or `practice_sessions.ended_at`.
const nullableEpochMillisConverter = NullAwareTypeConverter<DateTime, int>.wrap(
  epochMillisConverter,
);
