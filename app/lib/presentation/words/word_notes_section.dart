import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:vocabnote/application/words/word_notes_controller.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/theme/app_metrics.dart';
import 'package:vocabnote/domain/entities/word_note.dart';
import 'package:vocabnote/presentation/design/gap.dart';
import 'package:vocabnote/presentation/design/sheet_body.dart';

/// The *My notes* block on word detail (`docs/UI-UX.md` §4.3, F-003).
///
/// Notes are the user's own writing: they carry no attribution and are never
/// filled in from a dictionary. Adding one is deliberately two taps from the
/// word — it is the thing people actually come back to.
class WordNotesSection extends ConsumerWidget {
  /// Creates the notes block for [wordId].
  const new({required this.wordId, required this.notes, super.key});

  /// The word the notes belong to.
  final String wordId;

  /// Its notes, pinned first.
  final List<WordNote> notes;

  Future<void> _addNote(BuildContext context, WidgetRef ref) async {
    final body = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const _AddNoteSheet(),
    );

    final trimmed = body?.trim() ?? '';
    if (trimmed.isEmpty) return;

    await ref
        .read(wordNotesProvider.notifier)
        .add(wordId: wordId, body: trimmed);
  }

  Future<void> _editNote(
    BuildContext context,
    WidgetRef ref,
    WordNote note,
  ) async {
    // The notifier is read before the await: a WidgetRef is only good for the
    // build that produced it, and this runs after the sheet closes.
    final notes = ref.read(wordNotesProvider.notifier);
    final body = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _AddNoteSheet(existing: note.body),
    );

    final trimmed = body?.trim() ?? '';
    // An emptied note is a cancel, not a delete. Deleting has its own button
    // and its own undo; clearing the field must not destroy anything.
    if (trimmed.isEmpty || trimmed == note.body) return;

    await notes.update(note.copyWith(body: trimmed));
  }

  Future<void> _deleteNote(
    BuildContext context,
    WidgetRef ref,
    WordNote note,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppL10n.of(context);

    await ref.read(wordNotesProvider.notifier).delete(note.id);

    messenger.showSnackBar(
      SnackBar(content: Text(l10n.detailNoteDeletedSnack)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                l10n.detailNotesHeading,
                style: theme.textTheme.titleMedium,
              ),
            ),
            TextButton.icon(
              onPressed: () => _addNote(context, ref),
              icon: const Icon(Icons.add),
              label: Text(l10n.detailAddNoteAction),
            ),
          ],
        ),
        if (notes.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: context.metrics.spaceSm),
            child: Text(
              l10n.detailNoNotesBody,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          )
        else
          for (final note in notes)
            _NoteRow(
              note: note,
              onEdit: () => unawaited(_editNote(context, ref, note)),
              onDelete: () => _deleteNote(context, ref, note),
            ),
      ],
    );
  }
}

/// One note: its date and body, with a delete button.
class _NoteRow extends StatelessWidget {
  const new({required this.note, required this.onEdit, required this.onDelete});

  final WordNote note;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    // "3 Sep" — the spec's format. Localised, so a second locale gets its own.
    // In the phone's own time zone: stored instants come back as UTC,
    // and a note written at breakfast in Adelaide would be dated the day
    // before (M8).
    final date = DateFormat.MMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(note.createdAt.toLocal());

    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.metrics.spaceXs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: context.metrics.spaceXs),
            child: Icon(
              Icons.circle,
              size: context.metrics.spaceSm,
              color: theme.colorScheme.outlineVariant,
            ),
          ),
          const VnGap(VnSpace.sm, axis: Axis.horizontal),
          Expanded(
            child: InkWell(
              onTap: onEdit,
              child: Text.rich(
                TextSpan(
                  children: <InlineSpan>[
                    TextSpan(
                      text: '$date — ',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    TextSpan(text: note.body),
                  ],
                ),
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            iconSize: context.metrics.spaceLg,
            tooltip: l10n.editNoteAction,
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.close),
            iconSize: context.metrics.spaceLg,
            tooltip: l10n.detailNoteDeleteAction,
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

/// The sheet that writes a new note.
class _AddNoteSheet extends StatefulWidget {
  const new({this.existing});

  /// The note being edited, or null when writing a new one.
  final String? existing;

  @override
  State<_AddNoteSheet> createState() => _AddNoteSheetState();
}

class _AddNoteSheetState extends State<_AddNoteSheet> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.existing ?? '',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);

    return VnSheetBody(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          widget.existing == null
              ? l10n.detailNoteHeading
              : l10n.editNoteAction,
          style: theme.textTheme.titleMedium,
        ),
        const VnGap(VnSpace.md),
        TextField(
          controller: _controller,
          autofocus: true,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: l10n.fieldNoteHint,
            border: const OutlineInputBorder(),
          ),
        ),
        const VnGap(VnSpace.md),
        // Reflows to a column when the two cannot share a line (UI-UX §6).
        OverflowBar(
          alignment: MainAxisAlignment.end,
          spacing: context.metrics.spaceSm,
          overflowAlignment: OverflowBarAlignment.end,
          children: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancelAction),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(_controller.text),
              child: Text(l10n.saveAction),
            ),
          ],
        ),
      ],
    );
  }
}
