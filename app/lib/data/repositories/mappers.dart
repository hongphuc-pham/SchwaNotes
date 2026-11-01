/// Mapping between Drift rows and domain entities.
///
/// The boundary `docs/RULES.md` §25 draws: repositories hand out entities,
/// never row classes, so a schema change cannot ripple into the UI.
///
/// Reading is defensive throughout. A row written by a newer build, or one
/// corrupted by a bad restore, must degrade to something renderable rather than
/// throw - the alternative is a screen that cannot open at all.
library;

import 'package:drift/drift.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/domain/entities/app_settings.dart';
import 'package:vocabnote/domain/entities/ipa_highlight.dart';
import 'package:vocabnote/domain/entities/practice_session.dart';
import 'package:vocabnote/domain/entities/study_card.dart';
import 'package:vocabnote/domain/entities/word.dart';
import 'package:vocabnote/domain/entities/word_list.dart';
import 'package:vocabnote/domain/entities/word_note.dart';
import 'package:vocabnote/domain/value_objects/grapheme_range.dart';
import 'package:vocabnote/domain/value_objects/headword.dart';
import 'package:vocabnote/domain/value_objects/ipa.dart';

/// Row to entity for `words`.
extension WordRowMapper on WordRow {
  /// Builds the domain entity.
  Word toEntity() => Word(
    id: id,
    headword: Headword.fromStorage(
      headword: headword,
      normalized: headwordNormalized,
    ),
    createdAt: createdAt,
    updatedAt: updatedAt,
    partOfSpeech: partOfSpeech,
    ipaUk: ipaUk == null ? null : Ipa.fromStorage(ipaUk!),
    ipaUs: ipaUs == null ? null : Ipa.fromStorage(ipaUs!),
    definition: definition,
    example: example,
    source: source,
    sourceAttribution: sourceAttribution,
    isFavourite: isFavourite,
    isArchived: isArchived,
    deletedAt: deletedAt,
  );
}

/// Entity to companion for `words`.
extension WordEntityMapper on Word {
  /// Builds a companion for insert or update.
  WordsCompanion toCompanion() => WordsCompanion(
    id: Value(id),
    headword: Value(headword.value),
    headwordNormalized: Value(headword.normalized),
    partOfSpeech: Value(partOfSpeech),
    ipaUk: Value(ipaUk?.value),
    ipaUs: Value(ipaUs?.value),
    definition: Value(definition),
    example: Value(example),
    source: Value(source),
    sourceAttribution: Value(sourceAttribution),
    isFavourite: Value(isFavourite),
    isArchived: Value(isArchived),
    createdAt: Value(createdAt),
    updatedAt: Value(updatedAt),
    deletedAt: Value(deletedAt),
  );
}

/// Row to entity for `word_notes`.
extension WordNoteRowMapper on WordNoteRow {
  /// Builds the domain entity.
  WordNote toEntity() => WordNote(
    id: id,
    wordId: wordId,
    body: body,
    createdAt: createdAt,
    updatedAt: updatedAt,
    pinned: pinned,
  );
}

/// Entity to companion for `word_notes`.
extension WordNoteEntityMapper on WordNote {
  /// Builds a companion for insert or update.
  WordNotesCompanion toCompanion() => WordNotesCompanion(
    id: Value(id),
    wordId: Value(wordId),
    body: Value(body),
    createdAt: Value(createdAt),
    updatedAt: Value(updatedAt),
    pinned: Value(pinned),
  );
}

/// Row to entity for `ipa_highlights`.
extension IpaHighlightRowMapper on IpaHighlightRow {
  /// Builds the domain entity, or null if the stored range is nonsense.
  ///
  /// Nullable on purpose (F-023 requires validating on read): a highlight whose
  /// offsets are reversed or negative cannot be painted, and one bad row must
  /// not take down the word screen that lists it. Callers use
  /// `whereType<IpaHighlight>()` to drop them.
  IpaHighlight? toEntityOrNull() {
    final range = GraphemeRange.tryCreate(startGrapheme, endGrapheme);
    if (range == null) return null;
    return IpaHighlight(
      id: id,
      wordId: wordId,
      target: target,
      range: range,
      color: colorToken,
      createdAt: createdAt,
      label: label,
    );
  }
}

/// Entity to companion for `ipa_highlights`.
extension IpaHighlightEntityMapper on IpaHighlight {
  /// Builds a companion for insert.
  IpaHighlightsCompanion toCompanion() => IpaHighlightsCompanion(
    id: Value(id),
    wordId: Value(wordId),
    target: Value(target),
    startGrapheme: Value(range.start),
    endGrapheme: Value(range.end),
    colorToken: Value(color),
    label: Value(label),
    createdAt: Value(createdAt),
  );
}

/// Row to entity for `word_lists`.
extension WordListRowMapper on WordListRow {
  /// Builds the domain entity.
  WordList toEntity() => WordList(
    id: id,
    name: name,
    color: colorToken,
    sortOrder: sortOrder,
    createdAt: createdAt,
    updatedAt: updatedAt,
    iconKey: iconKey,
    kind: kind,
  );
}

/// Entity to companion for `word_lists`.
extension WordListEntityMapper on WordList {
  /// Builds a companion for insert or update.
  WordListsCompanion toCompanion() => WordListsCompanion(
    id: Value(id),
    name: Value(name),
    kind: Value(kind),
    colorToken: Value(color),
    iconKey: Value(iconKey),
    sortOrder: Value(sortOrder),
    createdAt: Value(createdAt),
    updatedAt: Value(updatedAt),
  );
}

/// Row to entity for `study_cards`.
extension StudyCardRowMapper on StudyCardRow {
  /// Builds the domain entity.
  StudyCard toEntity() => StudyCard(
    wordId: wordId,
    dueAt: dueAt,
    box: box,
    intervalDays: intervalDays,
    easeFactor: easeFactor,
    repetitions: repetitions,
    lapses: lapses,
    lastReviewedAt: lastReviewedAt,
    lastResult: lastResult,
    suspended: suspended,
  );
}

/// Entity to companion for `study_cards`.
extension StudyCardEntityMapper on StudyCard {
  /// Builds a companion for insert or update.
  StudyCardsCompanion toCompanion() => StudyCardsCompanion(
    wordId: Value(wordId),
    box: Value(box),
    dueAt: Value(dueAt),
    intervalDays: Value(intervalDays),
    easeFactor: Value(easeFactor),
    repetitions: Value(repetitions),
    lapses: Value(lapses),
    lastReviewedAt: Value(lastReviewedAt),
    lastResult: Value(lastResult),
    suspended: Value(suspended),
  );
}

/// Row to entity for `practice_sessions`.
extension PracticeSessionRowMapper on PracticeSessionRow {
  /// Builds the domain entity.
  PracticeSession toEntity() => PracticeSession(
    id: id,
    gameId: gameId,
    mode: mode,
    sourceKind: sourceKind,
    configJson: configJson,
    startedAt: startedAt,
    affectsScheduling: affectsScheduling,
    sourceId: sourceId,
    endedAt: endedAt,
    totalRounds: totalRounds,
    correctRounds: correctRounds,
  );
}

/// Entity to companion for `practice_sessions`.
extension PracticeSessionEntityMapper on PracticeSession {
  /// Builds a companion for insert.
  PracticeSessionsCompanion toCompanion() => PracticeSessionsCompanion(
    id: Value(id),
    gameId: Value(gameId),
    mode: Value(mode),
    sourceKind: Value(sourceKind),
    sourceId: Value(sourceId),
    configJson: Value(configJson),
    startedAt: Value(startedAt),
    endedAt: Value(endedAt),
    totalRounds: Value(totalRounds),
    correctRounds: Value(correctRounds),
    affectsScheduling: Value(affectsScheduling),
  );
}

/// Row to entity for `practice_answers`.
extension PracticeAnswerRowMapper on PracticeAnswerRow {
  /// Builds the domain entity.
  PracticeAnswer toEntity() => PracticeAnswer(
    id: id,
    sessionId: sessionId,
    wordId: wordId,
    roundIndex: roundIndex,
    result: result,
    answeredAt: answeredAt,
    responseMs: responseMs,
  );
}

/// Entity to companion for `practice_answers`.
extension PracticeAnswerEntityMapper on PracticeAnswer {
  /// Builds a companion for insert.
  PracticeAnswersCompanion toCompanion() => PracticeAnswersCompanion(
    id: Value(id),
    sessionId: Value(sessionId),
    wordId: Value(wordId),
    roundIndex: Value(roundIndex),
    result: Value(result),
    responseMs: Value(responseMs),
    answeredAt: Value(answeredAt),
  );
}

/// Row to entity for `settings`.
extension SettingsRowMapper on SettingsRow {
  /// Builds the domain entity.
  AppSettings toEntity() => AppSettings(
    themeMode: themeMode,
    ttsLocale: ttsLocale,
    ttsRate: ttsRate,
    ttsPitch: ttsPitch,
    autoplayOnOpen: autoplayOnOpen,
    dailyGoal: dailyGoal,
    reminderEnabled: reminderEnabled,
    reminderTimeMinutes: reminderTimeMinutes,
    promptSide: promptSide,
    mixSides: PromptSide.decodeMix(mixSides),
    mixOrder: mixOrder,
    lookupEnabled: lookupEnabled,
    reviewScheduleJson: reviewSchedule,
    againRepeats: againRepeats,
  );
}

/// Entity to companion for `settings`.
extension AppSettingsEntityMapper on AppSettings {
  /// Builds a companion for the single settings row.
  SettingsCompanion toCompanion() => SettingsCompanion(
    id: const Value(1),
    themeMode: Value(themeMode),
    ttsLocale: Value(ttsLocale),
    ttsRate: Value(ttsRate),
    ttsPitch: Value(ttsPitch),
    autoplayOnOpen: Value(autoplayOnOpen),
    dailyGoal: Value(dailyGoal),
    reminderEnabled: Value(reminderEnabled),
    reminderTimeMinutes: Value(reminderTimeMinutes),
    promptSide: Value(promptSide),
    mixSides: Value(PromptSide.encodeMix(mixSides)),
    mixOrder: Value(mixOrder),
    lookupEnabled: Value(lookupEnabled),
    reviewSchedule: Value(reviewScheduleJson),
    againRepeats: Value(againRepeats),
  );
}
