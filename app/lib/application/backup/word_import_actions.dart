/// Choosing a CSV deck and bringing its words in (F-010).
library;

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vocabnote/application/backup/backup_actions.dart';
import 'package:vocabnote/application/repositories.dart';
import 'package:vocabnote/application/settings/settings_controller.dart';
import 'package:vocabnote/core/failure.dart';
import 'package:vocabnote/core/result.dart';
import 'package:vocabnote/domain/entities/word_import.dart';

part 'word_import_actions.g.dart';

/// What choosing a deck file came to.
@immutable
sealed class DeckPick {
  const new();
}

/// The picker was closed without choosing.
final class DeckPickCancelled extends DeckPick {
  /// Creates the outcome.
  const new();
}

/// The file cannot be used; [problem] says why, or is null when it could not
/// be opened at all.
final class DeckPickRefused extends DeckPick {
  /// Creates the outcome.
  const new(this.problem);

  /// Why it was refused.
  final WordImportProblem? problem;
}

/// A usable deck, read and compared with the library. Nothing is written.
final class DeckPickReady extends DeckPick {
  /// Creates the outcome.
  const new(this.preview);

  /// What the file holds.
  final WordImportPreview preview;
}

/// The write side of a CSV import.
@Riverpod(keepAlive: true)
class WordImportActions extends _$WordImportActions {
  @override
  void build() {}

  /// Lets the user choose a file and reads it. Writes nothing.
  Future<DeckPick> pickDeck() async {
    final picked = await ref.read(backupFilesProvider).pick();
    final Uint8List bytes;
    switch (picked) {
      case Err(:final failure):
        return DeckPickRefused(
          failure is InvalidBackupFailure ? WordImportProblem.tooLarge : null,
        );
      case Ok(value: null):
        return const DeckPickCancelled();
      case Ok(:final Uint8List value):
        bytes = value;
    }

    final preview = await ref.read(wordImportRepositoryProvider).preview(bytes);
    return switch (preview) {
      Ok(value: final ready) when ready.problem != null => DeckPickRefused(
        ready.problem,
      ),
      Ok(value: final ready) => DeckPickReady(ready),
      Err() => const DeckPickRefused(null),
    };
  }

  /// Brings [preview]'s words in, or returns null if it could not - in which
  /// case nothing changed. The IPA goes in the field for the user's accent.
  Future<WordImportReport?> importDeck(WordImportPreview preview) async {
    final accent = ref.read(appSettingsOrDefaultsProvider).ttsLocale;
    final report =
        (await ref
                .read(wordImportRepositoryProvider)
                .import(preview, accent: accent))
            .valueOrNull;
    if (report != null) ref.invalidate(storageUsedProvider);
    return report;
  }
}
