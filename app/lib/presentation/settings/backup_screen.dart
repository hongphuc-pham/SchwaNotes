import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:vocabnote/application/backup/backup_actions.dart';
import 'package:vocabnote/application/backup/word_import_actions.dart';
import 'package:vocabnote/core/failure.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/theme/app_metrics.dart';
import 'package:vocabnote/domain/entities/backup.dart';
import 'package:vocabnote/domain/entities/word_import.dart';
import 'package:vocabnote/domain/repositories/backup_files.dart';
import 'package:vocabnote/presentation/common/typed_confirm_dialog.dart';
import 'package:vocabnote/presentation/design/gap.dart';
import 'package:vocabnote/presentation/design/section.dart';
import 'package:vocabnote/presentation/settings/import_preview_sheet.dart';
import 'package:vocabnote/presentation/settings/import_report_dialog.dart';
import 'package:vocabnote/presentation/settings/word_import_sheet.dart';

/// Backup & restore (F-073, F-074, `docs/UI-UX.md` §4.9).
///
/// One primary action: make a backup. There is no cloud, so this file is how
/// a user moves their words to a new phone - the screen says what is in it,
/// when the last one was made, and that nothing is uploaded. Bringing one in
/// is the second button, and shows what a file holds before anything changes.
class BackupScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const new({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _exporting = false;
  bool _importing = false;
  bool _bringingIn = false;
  bool _importingCsv = false;

  bool get _busy => _exporting || _importing || _importingCsv;

  Future<void> _importCsv() async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppL10n.of(context);
    final actions = ref.read(wordImportActionsProvider.notifier);

    setState(() => _importingCsv = true);
    try {
      final picked = await actions.pickDeck();
      if (!mounted) return;
      final WordImportPreview preview;
      switch (picked) {
        case DeckPickCancelled():
          return;
        case DeckPickRefused(:final problem):
          messenger.showSnackBar(
            SnackBar(content: Text(_csvProblemText(l10n, problem))),
          );
          return;
        case DeckPickReady(preview: final ready):
          preview = ready;
      }

      final fallback = await WordImportSheet.show(context, preview);
      if (fallback == null || !mounted) return;
      final report = await actions.importDeck(preview, fallbackList: fallback);
      if (!mounted) return;
      if (report == null) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.csvImportFailed)));
        return;
      }
      await showWordImportReport(context, report);
    } finally {
      if (mounted) setState(() => _importingCsv = false);
    }
  }

  static String _csvProblemText(AppL10n l10n, WordImportProblem? problem) =>
      switch (problem) {
        WordImportProblem.notText => l10n.csvProblemNotText,
        WordImportProblem.tooLarge => l10n.csvProblemTooLarge,
        WordImportProblem.tooManyRows => l10n.csvProblemTooManyRows,
        WordImportProblem.noWords => l10n.csvProblemNoWords,
        null => l10n.importProblemUnreadable,
      };

  Future<void> _export(BuildContext buttonContext) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppL10n.of(context);
    final anchor = _anchorOf(buttonContext);

    setState(() => _exporting = true);
    final outcome = await ref
        .read(backupActionsProvider.notifier)
        .export(anchor: anchor);
    if (!mounted) return;
    setState(() => _exporting = false);

    switch (outcome) {
      case ExportOutcome.shared:
        messenger.showSnackBar(SnackBar(content: Text(l10n.backupExportDone)));
      case ExportOutcome.notShared:
        // The user closed the sheet; they know. Nothing to add.
        break;
      case ExportOutcome.failed:
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.backupExportFailed)),
        );
    }
  }

  Future<void> _import() async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppL10n.of(context);
    final actions = ref.read(backupActionsProvider.notifier);

    setState(() => _importing = true);
    try {
      final picked = await actions.pickBackup();
      if (!mounted) return;
      final PickedBackup backup;
      switch (picked) {
        case PickCancelled():
          return;
        case PickRefused(:final problem):
          messenger.showSnackBar(
            SnackBar(content: Text(_problemText(l10n, problem))),
          );
          return;
        case PickReady(backup: final ready):
          backup = ready;
      }

      final mode = await ImportPreviewSheet.show(context, backup.manifest);
      if (mode == null || !mounted) return;
      if (mode == ImportMode.replace &&
          !await showTypedConfirmation(
            context,
            title: l10n.replaceConfirmTitle,
            body: l10n.replaceConfirmBody,
            word: l10n.replaceConfirmWord,
            action: l10n.replaceConfirmAction,
          )) {
        return;
      }

      setState(() => _bringingIn = true);
      final report = await actions.importBackup(backup, mode);
      if (!mounted) return;
      if (report == null) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.importFailed)));
        return;
      }
      await showImportReport(context, report, mode);
    } finally {
      if (mounted) {
        setState(() {
          _importing = false;
          _bringingIn = false;
        });
      }
    }
  }

  /// Why a file cannot be brought in, as advice rather than a diagnosis.
  static String _problemText(AppL10n l10n, BackupProblem? problem) =>
      switch (problem) {
        BackupProblem.notABackup => l10n.importProblemNotABackup,
        BackupProblem.tooLarge => l10n.importProblemTooLarge,
        BackupProblem.damaged => l10n.importProblemDamaged,
        null => l10n.importProblemUnreadable,
      };

  /// Where the button is, for the iPad's share popover.
  static ShareAnchor? _anchorOf(BuildContext context) {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    final origin = box.localToGlobal(Offset.zero);
    return ShareAnchor(
      left: origin.dx,
      top: origin.dy,
      width: box.size.width,
      height: box.size.height,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final last = ref.watch(lastBackupAtProvider).value;
    final locale = Localizations.localeOf(context).toString();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.backupTitle)),
      body: ListView(
        padding: EdgeInsets.all(context.metrics.spaceLg),
        children: <Widget>[
          Text(l10n.backupIntro, style: theme.textTheme.bodyLarge),
          const VnGap(VnSpace.lg),
          Text(
            last == null
                ? l10n.backupNever
                : l10n.backupLast(
                    DateFormat.yMMMd(locale).add_jm().format(last.toLocal()),
                  ),
            style: theme.textTheme.titleSmall,
          ),
          const VnGap(VnSpace.xl),
          Builder(
            builder: (buttonContext) => FilledButton.icon(
              onPressed: _busy ? null : () => unawaited(_export(buttonContext)),
              icon: const Icon(Icons.ios_share),
              label: Text(
                _exporting ? l10n.backupPreparing : l10n.backupExport,
              ),
            ),
          ),
          const VnGap(VnSpace.sm),
          VnQuietText(l10n.backupExportHint),
          const VnGap(VnSpace.xl),
          OutlinedButton.icon(
            onPressed: _busy ? null : () => unawaited(_import()),
            icon: const Icon(Icons.file_open_outlined),
            label: Text(_bringingIn ? l10n.backupImporting : l10n.backupImport),
          ),
          const VnGap(VnSpace.sm),
          VnQuietText(l10n.backupImportHint),
          const VnGap(VnSpace.xl),
          OutlinedButton.icon(
            onPressed: _busy ? null : () => unawaited(_importCsv()),
            icon: const Icon(Icons.table_view_outlined),
            label: Text(_importingCsv ? l10n.csvImporting : l10n.csvImport),
          ),
          const VnGap(VnSpace.sm),
          VnQuietText(l10n.csvImportHint),
        ],
      ),
    );
  }
}
