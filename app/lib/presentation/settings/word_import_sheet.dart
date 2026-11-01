import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabnote/application/lists/list_controller.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/domain/entities/word_import.dart';
import 'package:vocabnote/domain/entities/word_list.dart';
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
class WordImportSheet extends ConsumerStatefulWidget {
  /// Creates the sheet.
  const new({required this.preview, super.key});

  /// What the file holds.
  final WordImportPreview preview;

  /// Opens the sheet. Resolves to the list for words with no category, or
  /// null if the user did not import.
  static Future<String?> show(
    BuildContext context,
    WordImportPreview preview,
  ) => showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => WordImportSheet(preview: preview),
  );

  @override
  ConsumerState<WordImportSheet> createState() => _WordImportSheetState();
}

class _WordImportSheetState extends ConsumerState<WordImportSheet> {
  /// What the user picked; until then, General.
  String? _picked;

  WordImportPreview get preview => widget.preview;

  /// The user's lists, with General first and added if it isn't one yet.
  static List<String> _choices(AppL10n l10n, List<WordListSummary> lists) {
    final names = lists.map((s) => s.list.name).toList();
    final general = l10n.listGeneral.toLowerCase();
    final existing = names.where((n) => n.trim().toLowerCase() == general);
    final first = existing.isEmpty ? l10n.listGeneral : existing.first;
    return <String>[first, ...names.where((n) => n != first)];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final choices = _choices(
      l10n,
      ref.watch(listSummariesProvider).value ?? const <WordListSummary>[],
    );
    final fallback = _picked ?? choices.first;

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
        if (preview.newTagNames.isNotEmpty)
          Text(
            l10n.csvPreviewNewTags(
              preview.newTagNames.join(l10n.listSeparator),
            ),
            style: theme.textTheme.bodyMedium,
          ),
        if (preview.skippedLines > 0)
          Text(
            l10n.csvPreviewSkipped(preview.skippedLines),
            style: theme.textTheme.bodyMedium,
          ),
        if (preview.needsFallbackList) ...<Widget>[
          const VnGap(VnSpace.md),
          DropdownButtonFormField<String>(
            // Keyed so a list arriving late re-reads the value.
            key: ValueKey<int>(choices.length),
            initialValue: fallback,
            isExpanded: true,
            decoration: InputDecoration(labelText: l10n.csvPreviewFallback),
            items: <DropdownMenuItem<String>>[
              for (final name in choices)
                DropdownMenuItem<String>(
                  value: name,
                  child: Text(name, overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: (name) => setState(() => _picked = name),
          ),
        ],
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
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancelAction),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(fallback),
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
    final labels = <String>[?row.category, ...row.tagNames];
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
          if (labels.isNotEmpty)
            Text(
              labels.join(l10n.listSeparator),
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
    if (report.tagsCreated > 0) l10n.csvReportTags(report.tagsCreated),
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
