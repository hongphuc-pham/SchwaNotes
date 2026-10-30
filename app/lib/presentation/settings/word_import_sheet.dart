import 'package:flutter/material.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/domain/entities/word_import.dart';
import 'package:vocabnote/presentation/common/ipa_text.dart';
import 'package:vocabnote/presentation/design/button_row.dart';
import 'package:vocabnote/presentation/design/gap.dart';
import 'package:vocabnote/presentation/design/section.dart';
import 'package:vocabnote/presentation/design/sheet_body.dart';

/// What a CSV deck holds, before anything is written (F-010).
///
/// Counts first, then the rule for words the user already has, said before
/// they press Import rather than discovered afterwards, then the first few
/// lines as the app read them, so a file with its columns in the wrong order
/// is caught here.
class WordImportSheet extends StatelessWidget {
  /// Creates the sheet.
  const new({required this.preview, super.key});

  /// What the file holds.
  final WordImportPreview preview;

  /// Opens the sheet; resolves to true when the user chose Import.
  static Future<bool> show(BuildContext context, WordImportPreview preview) =>
      showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (context) => WordImportSheet(preview: preview),
      ).then((go) => go ?? false);

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);

    return VnSheetBody(
      children: <Widget>[
        Text(l10n.csvPreviewTitle, style: theme.textTheme.titleLarge),
        const VnGap(VnSpace.sm),
        Text(
          l10n.csvPreviewNew(preview.newWords),
          style: theme.textTheme.titleSmall,
        ),
        if (preview.existingWords > 0)
          Text(
            l10n.csvPreviewExisting(preview.existingWords),
            style: theme.textTheme.titleSmall,
          ),
        if (preview.newListNames.isNotEmpty)
          Text(
            l10n.csvPreviewNewLists(
              preview.newListNames.join(l10n.listSeparator),
            ),
            style: theme.textTheme.bodyMedium,
          ),
        if (preview.skippedLines > 0)
          Text(
            l10n.csvPreviewSkipped(preview.skippedLines),
            style: theme.textTheme.bodyMedium,
          ),
        if (preview.existingWords > 0) ...<Widget>[
          const VnGap(VnSpace.sm),
          VnQuietText(l10n.csvPreviewRule),
        ],
        const VnGap(VnSpace.lg),
        Text(l10n.csvPreviewSample, style: theme.textTheme.labelLarge),
        const VnGap(VnSpace.xs),
        for (final row in preview.rows.take(WordImportLimits.previewRows))
          _SampleRow(row: row),
        const VnGap(VnSpace.lg),
        VnButtonRow(
          labels: <String>[l10n.cancelAction, l10n.csvImportAction],
          children: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancelAction),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.csvImportAction),
            ),
          ],
        ),
      ],
    );
  }
}

class _SampleRow extends StatelessWidget {
  const new({required this.row});

  final WordImportRow row;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final ipa = row.ipa;
    final meaning = row.meaning;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Text(row.headword, style: theme.textTheme.titleSmall),
              if (ipa != null)
                IpaText(ipa: ipa, style: theme.textTheme.bodyMedium),
            ],
          ),
          if (meaning != null) Text(meaning, style: theme.textTheme.bodyMedium),
          if (row.listNames.isNotEmpty)
            Text(
              row.listNames.join(l10n.listSeparator),
              style: theme.textTheme.bodySmall,
            ),
        ],
      ),
    );
  }
}

/// What a CSV import did: plain counts, new words first.
Future<void> showWordImportReport(
  BuildContext context,
  WordImportReport report,
) {
  final l10n = AppL10n.of(context);
  final lines = <String>[
    l10n.csvReportAdded(report.added),
    if (report.filled > 0) l10n.csvReportFilled(report.filled),
    if (report.unchanged > 0) l10n.csvReportUnchanged(report.unchanged),
    if (report.listsCreated > 0) l10n.csvReportLists(report.listsCreated),
    if (report.skipped > 0) l10n.csvReportSkipped(report.skipped),
  ];
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.csvReportTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (final (index, line) in lines.indexed) ...<Widget>[
              if (index > 0) const VnGap(VnSpace.xs),
              Text(line),
            ],
          ],
        ),
      ),
      actions: <Widget>[
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.importReportDone),
        ),
      ],
    ),
  );
}
