// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'practice_hub_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// How many cards are due right now — the "Daily review (7 due)" count.

@ProviderFor(dueCardCount)
final dueCardCountProvider = DueCardCountProvider._();

/// How many cards are due right now — the "Daily review (7 due)" count.

final class DueCardCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  /// How many cards are due right now — the "Daily review (7 due)" count.
  DueCardCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dueCardCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dueCardCountHash();

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    return dueCardCount(ref);
  }
}

String _$dueCardCountHash() => r'c55d217627d3592d12fcd52900d9f3d10f6b012a';

/// Today's words and the streak — the goal ring on the hub (F-065).

@ProviderFor(practiceProgress)
final practiceProgressProvider = PracticeProgressProvider._();

/// Today's words and the streak — the goal ring on the hub (F-065).

final class PracticeProgressProvider
    extends
        $FunctionalProvider<
          AsyncValue<PracticeProgress>,
          PracticeProgress,
          Stream<PracticeProgress>
        >
    with $FutureModifier<PracticeProgress>, $StreamProvider<PracticeProgress> {
  /// Today's words and the streak — the goal ring on the hub (F-065).
  PracticeProgressProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'practiceProgressProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$practiceProgressHash();

  @$internal
  @override
  $StreamProviderElement<PracticeProgress> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<PracticeProgress> create(Ref ref) {
    return practiceProgress(ref);
  }
}

String _$practiceProgressHash() => r'1bb6851f3ca5cc8ff49016b3760c086694391917';

/// The numbers behind the home screen's overview.

@ProviderFor(wordOverview)
final wordOverviewProvider = WordOverviewProvider._();

/// The numbers behind the home screen's overview.

final class WordOverviewProvider
    extends
        $FunctionalProvider<
          AsyncValue<WordOverview>,
          WordOverview,
          Stream<WordOverview>
        >
    with $FutureModifier<WordOverview>, $StreamProvider<WordOverview> {
  /// The numbers behind the home screen's overview.
  WordOverviewProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wordOverviewProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wordOverviewHash();

  @$internal
  @override
  $StreamProviderElement<WordOverview> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<WordOverview> create(Ref ref) {
    return wordOverview(ref);
  }
}

String _$wordOverviewHash() => r'ac1008955a393f5e66f5405e3dddc8a5c8f11872';
