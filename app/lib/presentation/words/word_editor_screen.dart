import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vocabnote/application/lists/list_controller.dart';
import 'package:vocabnote/application/words/highlight_revalidation.dart';
import 'package:vocabnote/application/words/lookup_controller.dart';
import 'package:vocabnote/application/words/word_draft.dart';
import 'package:vocabnote/application/words/word_editor_controller.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/router/routes.dart';
import 'package:vocabnote/core/theme/app_metrics.dart';
import 'package:vocabnote/core/theme/app_theme.dart';
import 'package:vocabnote/domain/entities/ipa_highlight.dart';
import 'package:vocabnote/domain/entities/word.dart';
import 'package:vocabnote/domain/entities/word_list.dart';
import 'package:vocabnote/domain/entities/word_suggestion.dart';
import 'package:vocabnote/presentation/design/gap.dart';
import 'package:vocabnote/presentation/words/ipa_keyboard_row.dart';
import 'package:vocabnote/presentation/words/lookup_card.dart';

/// The add / edit word form (`docs/UI-UX.md` §4.2).
///
/// One scrolling form; **Save** in the app bar, enabled once the headword is
/// non-empty. Everything the dictionary can fill is typeable by hand, because
/// manual entry is the first-class path (`docs/RULES.md` §3).
class WordEditorScreen extends ConsumerStatefulWidget {
  /// Edits [wordId], or adds a new word when it is null.
  const new({this.wordId, super.key});

  /// The word being edited.
  final String? wordId;

  @override
  ConsumerState<WordEditorScreen> createState() => _WordEditorScreenState();
}

class _WordEditorScreenState extends ConsumerState<WordEditorScreen> {
  final _headword = TextEditingController();
  final _ipaUk = TextEditingController();
  final _ipaUs = TextEditingController();
  final _definition = TextEditingController();
  final _example = TextEditingController();
  final _note = TextEditingController();

  final _ipaUkFocus = FocusNode();
  final _ipaUsFocus = FocusNode();

  Word? _duplicate;
  bool _duplicateDismissed = false;
  bool _seeded = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // The IPA symbol row (F-002) lives in `bottomNavigationBar` and is chosen
    // by which transcription field has focus. A FocusNode does not rebuild
    // anything on its own, so without these listeners `hasFocus` changes and
    // nothing repaints - the row simply never appears, and the only way to
    // type ɒ is a keyboard the user does not have.
    _ipaUkFocus.addListener(_onIpaFocusChanged);
    _ipaUsFocus.addListener(_onIpaFocusChanged);
  }

  void _onIpaFocusChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _ipaUkFocus.removeListener(_onIpaFocusChanged);
    _ipaUsFocus.removeListener(_onIpaFocusChanged);
    for (final c in <TextEditingController>[
      _headword,
      _ipaUk,
      _ipaUs,
      _definition,
      _example,
      _note,
    ]) {
      c.dispose();
    }
    _ipaUkFocus.dispose();
    _ipaUsFocus.dispose();
    super.dispose();
  }

  /// Fills the controllers once, when the draft first loads.
  ///
  /// Only once: re-seeding on every rebuild would fight the user's cursor.
  void _seed(WordDraft draft) {
    if (_seeded) return;
    _seeded = true;
    _headword.text = draft.headword;
    _ipaUk.text = draft.ipaUk;
    _ipaUs.text = draft.ipaUs;
    _definition.text = draft.definition;
    _example.text = draft.example;
  }

  WordEditor get _controller =>
      ref.read(wordEditorProvider(widget.wordId).notifier);

  Future<void> _checkDuplicate(String headword) async {
    final existing = await _controller.findDuplicate(headword);
    if (!mounted) return;
    setState(() {
      _duplicate = existing;
      if (existing == null) _duplicateDismissed = false;
    });
  }

  /// Accepts a suggestion, confirming first if it would overwrite typed text.
  ///
  /// The promise in F-004: a chip never replaces something the user wrote
  /// without asking.
  Future<void> _accept(
    FieldSuggestion suggestion,
    WordSuggestions results,
    WordDraft draft,
  ) async {
    if (draft.wouldOverwrite(suggestion.field, suggestion.value)) {
      final replace = await _confirmOverwrite(
        current: draft.valueOf(suggestion.field),
        replacement: suggestion.value,
      );
      if (replace != true) return;
    }

    _controller.acceptSuggestion(suggestion, results);

    // Keep the text controllers in step with the draft.
    switch (suggestion.field) {
      case SuggestionField.ipaUk:
        _ipaUk.text = suggestion.value;
      case SuggestionField.ipaUs:
        _ipaUs.text = suggestion.value;
      case SuggestionField.definition:
        _definition.text = suggestion.value;
      case SuggestionField.example:
        _example.text = suggestion.value;
      case SuggestionField.partOfSpeech:
        break;
    }
  }

  Future<bool?> _confirmOverwrite({
    required String current,
    required String replacement,
  }) {
    final l10n = AppL10n.of(context);
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.overwriteTitle),
        content: Text(l10n.overwriteBody(current, replacement)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.overwriteKeep),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.overwriteReplace),
          ),
        ],
      ),
    );
  }

  /// Asks before dropping highlights an IPA edit has invalidated (F-023).
  ///
  /// Returns the split to apply after the word is saved, or null when the user
  /// backed out. `Ok` with no losses is the ordinary case and asks nothing.
  Future<HighlightRevalidation?> _confirmHighlightLosses(
    WordDraft draft,
  ) async {
    // A new word has no stored highlights to lose.
    final id = draft.id;
    if (id == null) {
      return const HighlightRevalidation(
        kept: <IpaHighlight>[],
        dropped: <IpaHighlight>[],
      );
    }

    final checked = await ref
        .read(highlightRevalidatorProvider.notifier)
        .check(
          wordId: id,
          ipaUk: draft.ipaUk.trim().isEmpty ? null : draft.ipaUk.trim(),
          ipaUs: draft.ipaUs.trim().isEmpty ? null : draft.ipaUs.trim(),
        );

    // A failed check must not silently destroy anything: fall back to changing
    // no highlights at all, which leaves them to be re-validated on read.
    final revalidation = checked.valueOrNull;
    if (revalidation == null || !revalidation.hasLosses) return revalidation;

    if (!mounted) return null;
    final l10n = AppL10n.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.ipaRevalidateTitle),
        content: Text(l10n.ipaRevalidateBody(revalidation.dropped.length)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.ipaRevalidateCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.ipaRevalidateConfirm),
          ),
        ],
      ),
    );

    return (confirmed ?? false) ? revalidation : null;
  }

  Future<void> _save(WordDraft draft) async {
    // Asked *before* the word is written, so a user who changes their mind
    // still has both the old transcription and their colours (F-023).
    final revalidation = await _confirmHighlightLosses(draft);
    if (revalidation == null || !mounted) return;

    setState(() => _saving = true);
    final result = await _controller.save();
    if (!mounted) return;
    setState(() => _saving = false);

    await result.fold(
      (saved) async {
        // Pruned after the word is saved, so the highlights are measured
        // against a transcription that is actually on disk.
        if (revalidation.hasLosses) {
          await ref
              .read(highlightRevalidatorProvider.notifier)
              .prune(wordId: saved.id, revalidation: revalidation);
        }
        if (mounted) context.pop();
      },
      (failure) async => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppL10n.of(context).wordsLoadFailedBody)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final async = ref.watch(wordEditorProvider(widget.wordId));
    final lookup = ref.watch(lookupProvider);

    return async.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.wordsLoadFailedTitle)),
      ),
      data: (draft) {
        _seed(draft);

        return Scaffold(
          appBar: AppBar(
            title: Text(
              draft.isEditing ? l10n.editorTitleEdit : l10n.editorTitleAdd,
            ),
            actions: <Widget>[
              TextButton(
                // Enabled only once the headword is non-empty (§4.2).
                onPressed: draft.canSave && !_saving
                    ? () => _save(draft)
                    : null,
                child: Text(l10n.saveAction),
              ),
            ],
          ),
          body: ListView(
            padding: EdgeInsets.all(context.metrics.spaceLg),
            children: <Widget>[
              _HeadwordField(
                controller: _headword,
                onChanged: (value) {
                  _controller.edit((d) => d.copyWith(headword: value));
                  unawaited(_checkDuplicate(value));
                },
              ),
              if (_duplicate != null && !_duplicateDismissed)
                _DuplicateBanner(
                  word: _duplicate!,
                  onOpen: () => context.pushReplacement(
                    Routes.wordDetailOf(_duplicate!.id),
                  ),
                  onDismiss: () => setState(() => _duplicateDismissed = true),
                ),
              const VnGap(VnSpace.sm),
              _LookUpButton(
                headword: _headword.text,
                onPressed: () =>
                    ref.read(lookupProvider.notifier).lookup(_headword.text),
              ),
              const VnGap(VnSpace.md),
              _LookupSection(
                state: lookup,
                onAccept: (suggestion, results) =>
                    _accept(suggestion, results, draft),
              ),
              const VnGap(VnSpace.lg),
              _IpaField(
                label: l10n.fieldIpaUk,
                controller: _ipaUk,
                focusNode: _ipaUkFocus,
                onChanged: (value) {
                  _controller
                    ..edit((d) => d.copyWith(ipaUk: value))
                    ..markFieldManual(SuggestionField.ipaUk);
                },
              ),
              const VnGap(VnSpace.lg),
              _IpaField(
                label: l10n.fieldIpaUs,
                controller: _ipaUs,
                focusNode: _ipaUsFocus,
                onChanged: (value) {
                  _controller
                    ..edit((d) => d.copyWith(ipaUs: value))
                    ..markFieldManual(SuggestionField.ipaUs);
                },
              ),
              const VnGap(VnSpace.xl),
              _PartOfSpeechChips(
                selected: draft.partOfSpeech,
                onSelected: (value) {
                  _controller
                    ..edit((d) => d.copyWith(partOfSpeech: value))
                    ..markFieldManual(SuggestionField.partOfSpeech);
                },
              ),
              const VnGap(VnSpace.lg),
              _MultilineField(
                label: l10n.fieldDefinition,
                controller: _definition,
                onChanged: (value) {
                  _controller
                    ..edit((d) => d.copyWith(definition: value))
                    ..markFieldManual(SuggestionField.definition);
                },
              ),
              const VnGap(VnSpace.lg),
              _MultilineField(
                label: l10n.fieldExample,
                controller: _example,
                onChanged: (value) {
                  _controller
                    ..edit((d) => d.copyWith(example: value))
                    ..markFieldManual(SuggestionField.example);
                },
              ),
              if (!draft.isEditing) ...<Widget>[
                const VnGap(VnSpace.lg),
                _MultilineField(
                  label: l10n.fieldNote,
                  hint: l10n.fieldNoteHint,
                  controller: _note,
                  onChanged: (value) =>
                      _controller.edit((d) => d.copyWith(firstNote: value)),
                ),
              ],
              const VnGap(VnSpace.lg),
              _ListChips(
                selected: draft.listIds,
                onToggle: (id) => _controller.edit(
                  (d) => d.copyWith(
                    listIds: d.listIds.contains(id)
                        ? (<String>[...d.listIds]..remove(id))
                        : <String>[...d.listIds, id],
                  ),
                ),
              ),
              const VnGap(VnSpace.xxl),
            ],
          ),
          // Docked above the keyboard, and only while an IPA field has focus.
          bottomNavigationBar: _ipaUkFocus.hasFocus || _ipaUsFocus.hasFocus
              ? SafeArea(
                  child: IpaKeyboardRow(
                    controller: _ipaUkFocus.hasFocus ? _ipaUk : _ipaUs,
                  ),
                )
              : null,
        );
      },
    );
  }
}

class _HeadwordField extends StatelessWidget {
  const new({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return TextField(
      controller: controller,
      onChanged: onChanged,
      // Autofocus: the whole screen exists to capture this one field (§4.2).
      autofocus: true,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: l10n.fieldWord,
        hintText: l10n.fieldWordHint,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

/// The non-blocking duplicate warning (F-001).
///
/// A banner, never a dialog: "You already have cough - open it?" must not stop
/// the user saving a second entry if that is what they meant.
class _DuplicateBanner extends StatelessWidget {
  const new({
    required this.word,
    required this.onOpen,
    required this.onDismiss,
  });

  final Word word;
  final VoidCallback onOpen;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(top: context.metrics.spaceSm),
      padding: EdgeInsets.all(context.metrics.spaceMd),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: context.metrics.cardBorder,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              l10n.duplicateBanner(word.headword.value),
              style: theme.textTheme.bodyMedium,
            ),
          ),
          TextButton(
            onPressed: onDismiss,
            child: Text(l10n.duplicateBannerDismiss),
          ),
          TextButton(onPressed: onOpen, child: Text(l10n.duplicateBannerOpen)),
        ],
      ),
    );
  }
}

class _LookUpButton extends StatelessWidget {
  const new({required this.headword, required this.onPressed});

  final String headword;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);

    return Row(
      children: <Widget>[
        OutlinedButton.icon(
          onPressed: headword.trim().isEmpty ? null : onPressed,
          icon: const Icon(Icons.search),
          label: Text(l10n.lookUpAction),
        ),
        const VnGap(VnSpace.md, axis: Axis.horizontal),
        Expanded(
          child: Text(
            l10n.lookUpHint,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _LookupSection extends ConsumerWidget {
  const new({required this.state, required this.onAccept});

  final LookupState state;
  final void Function(FieldSuggestion, WordSuggestions) onAccept;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dismiss = ref.read(lookupProvider.notifier).dismiss;

    return switch (state) {
      LookupIdle() => const SizedBox.shrink(),
      LookupLoading(:final headword) => Padding(
        padding: EdgeInsets.symmetric(vertical: context.metrics.spaceMd),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: context.metrics.spaceLg,
              height: context.metrics.spaceLg,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
            const VnGap(VnSpace.md, axis: Axis.horizontal),
            Text(AppL10n.of(context).lookupSearching(headword)),
          ],
        ),
      ),
      LookupResults(:final suggestions) => LookupCard(
        suggestions: suggestions,
        onAccept: (s) => onAccept(s, suggestions),
        onDismiss: dismiss,
      ),
      // Quiet and inline. The form stays completely usable (F-006).
      LookupFailed() => LookupFailureNotice(onDismiss: dismiss),
    };
  }
}

class _IpaField extends StatelessWidget {
  const new({
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      style: context.type.ipaInline.copyWith(fontSize: 18),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        // The slashes are fixed affixes drawn by the field, never typed and
        // never part of the stored value (§4.2).
        prefixText: '/',
        suffixText: '/',
      ),
    );
  }
}

class _PartOfSpeechChips extends StatelessWidget {
  const new({required this.selected, required this.onSelected});

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);

    final options = <String>[
      l10n.posNoun,
      l10n.posVerb,
      l10n.posAdjective,
      l10n.posAdverb,
      l10n.posOther,
      // A value none of the five matches - a dictionary's "preposition", say -
      // is what will be saved, so it gets a chip of its own: shown selected,
      // and tappable to clear. Otherwise accepting it lit nothing and looked
      // like it had not worked (M8, found on the emulator).
      if (selected.isNotEmpty &&
          !<String>[
            l10n.posNoun,
            l10n.posVerb,
            l10n.posAdjective,
            l10n.posAdverb,
            l10n.posOther,
          ].contains(selected))
        selected,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(l10n.fieldPartOfSpeech, style: theme.textTheme.labelLarge),
        const VnGap(VnSpace.sm),
        Wrap(
          spacing: context.metrics.spaceSm,
          children: <Widget>[
            for (final option in options)
              ChoiceChip(
                label: Text(option),
                selected: selected == option,
                // Tapping the selected chip clears it - the field is optional.
                onSelected: (on) => onSelected(on ? option : ''),
              ),
          ],
        ),
      ],
    );
  }
}

class _MultilineField extends StatelessWidget {
  const new({
    required this.label,
    required this.controller,
    required this.onChanged,
    this.hint,
  });

  final String label;
  final String? hint;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      minLines: 2,
      maxLines: 5,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
    );
  }
}

class _ListChips extends ConsumerWidget {
  const new({required this.selected, required this.onToggle});

  final List<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final lists =
        ref.watch(listSummariesProvider).value ?? const <WordListSummary>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(l10n.fieldLists, style: theme.textTheme.labelLarge),
        const VnGap(VnSpace.sm),
        if (lists.isEmpty)
          Text(
            l10n.fieldListsEmpty,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          )
        else
          Wrap(
            spacing: context.metrics.spaceSm,
            children: <Widget>[
              for (final summary in lists)
                FilterChip(
                  label: Text(summary.list.name),
                  selected: selected.contains(summary.list.id),
                  onSelected: (_) => onToggle(summary.list.id),
                ),
            ],
          ),
      ],
    );
  }
}
