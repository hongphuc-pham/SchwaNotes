/// What the practice hub needs to know (F-060, F-065).
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vocabnote/application/repositories.dart';
import 'package:vocabnote/domain/entities/practice_progress.dart';
import 'package:vocabnote/domain/entities/word_overview.dart';

part 'practice_hub_controller.g.dart';

/// How many cards are due right now — the "Daily review (7 due)" count.
@riverpod
Stream<int> dueCardCount(Ref ref) {
  return ref
      .watch(practiceRepositoryProvider)
      .watchDueCount()
      .map(
        (result) => result.fold((count) => count, (failure) => throw failure),
      );
}

/// Today's words and the streak — the goal ring on the hub (F-065).
@riverpod
Stream<PracticeProgress> practiceProgress(Ref ref) {
  return ref
      .watch(practiceRepositoryProvider)
      .watchProgress()
      .map(
        (result) =>
            result.fold((progress) => progress, (failure) => throw failure),
      );
}

/// The numbers behind the home screen's overview.
@riverpod
Stream<WordOverview> wordOverview(Ref ref) {
  return ref
      .watch(practiceRepositoryProvider)
      .watchOverview()
      .map(
        (result) =>
            result.fold((overview) => overview, (failure) => throw failure),
      );
}
