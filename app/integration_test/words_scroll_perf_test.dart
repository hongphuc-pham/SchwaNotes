import 'dart:async';
import 'dart:io';
import 'dart:ui' show FrameTiming;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Riverpod 3 moved `Override` out of the main barrel file.
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:vocabnote/app.dart';
import 'package:vocabnote/core/router/app_router.dart';
import 'package:vocabnote/core/router/routes.dart';
import 'package:vocabnote/data/composition_root.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/db/database_provider.dart';
import 'package:vocabnote/presentation/words/word_tile.dart';

import '../test/unit/data/db_fixtures.dart';

/// PLAN.md M7's "5,000-word performance check", on a device.
///
/// `search_performance_test.dart` holds the *queries* to their budgets on the
/// build machine. This holds the thing the user actually feels: scrolling a
/// library of 5,000 words. Frame times come from the integration binding, so
/// what is reported is the device's own UI and raster threads, not a guess.
///
///     flutter test integration_test/words_scroll_perf_test.dart \
///       -d emulator-5554 --profile
///
/// **Read the numbers with the machine in mind.** A software-GPU emulator
/// rasterises far slower than a phone, so the raster figure is an upper bound
/// and the build figure is the useful one. `docs/PROGRESS.md` §5 records both
/// with that caveat.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('scrolling 5,000 words', (tester) async {
    final support = await getApplicationSupportDirectory();
    final folder = Directory(p.join(support.path, 'scroll_perf'));
    if (folder.existsSync()) folder.deleteSync(recursive: true);
    folder.createSync(recursive: true);
    final db = AppDatabase(
      NativeDatabase(File(p.join(folder.path, 'vocabnote.sqlite'))),
    );

    try {
      await seedManyWords(db, 5000);

      final container = ProviderContainer(
        overrides: <Override>[
          appDatabaseProvider.overrideWithValue(db),
          ...repositoryOverrides(db),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const VocabNoteApp(),
        ),
      );
      await tester.pumpAndSettle();
      unawaited(container.read(appRouterProvider).push(Routes.wordsAll));
      await tester.pumpAndSettle();
      // Not a headword: the default sort is `WordSort.recent` (updated_at
      // DESC), so `word0000` is the 5,000th row and a `ListView.builder`
      // never builds it. Asserting on the row widget says "the list is up"
      // without depending on which word happens to sort first.
      expect(find.byType(WordTile), findsWidgets, reason: 'the list is up');

      // Frame times are collected here rather than through `traceAction`,
      // whose timeline only reaches a file when the test is driven by
      // `flutter drive`. This way a plain run prints the numbers.
      final frames = <FrameTiming>[];
      void collect(List<FrameTiming> timings) => frames.addAll(timings);
      binding.addTimingsCallback(collect);
      addTearDown(() => binding.removeTimingsCallback(collect));

      final list = find.byType(Scrollable).first;
      for (var fling = 0; fling < 10; fling++) {
        await tester.fling(list, const Offset(0, -400), 4000);
        await tester.pumpAndSettle();
      }
      // The callback is delivered a frame late; give the last ones time.
      await tester.pump(const Duration(milliseconds: 100));

      expect(frames, isNotEmpty, reason: 'no frames were timed');
      int medianOf(Iterable<int> micros) {
        final sorted = micros.toList()..sort();
        return sorted[sorted.length ~/ 2];
      }

      final build = medianOf(frames.map((f) => f.buildDuration.inMicroseconds));
      final raster = medianOf(
        frames.map((f) => f.rasterDuration.inMicroseconds),
      );
      final worstBuild = frames
          .map((f) => f.buildDuration.inMicroseconds)
          .reduce((a, b) => a > b ? a : b);
      // Printed, not asserted: the budget is 16ms a frame on a phone, and this
      // runs on a software-GPU emulator where raster is nothing like a phone's.
      // `docs/PROGRESS.md` §5 records the figures with that caveat.
      debugPrint(
        'SCROLL 5000 words over ${frames.length} frames: '
        'build median ${build / 1000}ms, worst ${worstBuild / 1000}ms; '
        'raster median ${raster / 1000}ms',
      );
    } finally {
      await db.close();
      folder.deleteSync(recursive: true);
    }
  });
}
