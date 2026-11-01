import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabnote/application/lists/list_actions_controller.dart';
import 'package:vocabnote/application/lists/list_controller.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/domain/entities/word_list.dart';
import 'package:vocabnote/domain/value_objects/ipa_color_token.dart';
import 'package:vocabnote/presentation/design/gap.dart';
import 'package:vocabnote/presentation/design/sheet_body.dart';

/// The chosen lists or tags on the word form, and the way to add more.
///
/// Only what is chosen is on the form. Everything else is behind the search
/// in [WordLabelPicker]: a deck can bring dozens of tags, and laying them all
/// out to tick pushed the rest of the form off the screen.
class WordLabelsField extends ConsumerWidget {
  /// Creates the field.
  const new({
    required this.kind,
    required this.selected,
    required this.onToggle,
    super.key,
  });

  /// Lists or tags.
  final ListKind kind;

  /// The ids chosen so far. May hold ids of the other kind, which are ignored.
  final List<String> selected;

  /// Adds or removes one id.
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final all = _labels(ref, kind);
    final chosen = <WordListSummary>[
      for (final summary in all)
        if (selected.contains(summary.list.id)) summary,
    ];
    final isTag = kind == ListKind.tag;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          isTag ? l10n.fieldTags : l10n.fieldLists,
          style: theme.textTheme.labelLarge,
        ),
        const VnGap(VnSpace.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            for (final summary in chosen)
              InputChip(
                label: Text(summary.list.name),
                deleteButtonTooltipMessage: l10n.labelRemove(summary.list.name),
                onDeleted: () => onToggle(summary.list.id),
              ),
            ActionChip(
              avatar: const Icon(Icons.add),
              label: Text(isTag ? l10n.addTagAction : l10n.addListAction),
              onPressed: () => WordLabelPicker.show(
                context,
                kind: kind,
                selected: selected,
                onToggle: onToggle,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

List<WordListSummary> _labels(WidgetRef ref, ListKind kind) =>
    ref.watch(switch (kind) {
      ListKind.list => listSummariesProvider,
      ListKind.tag => tagSummariesProvider,
    }).value ??
    const <WordListSummary>[];

/// Search and choose, or create what isn't there yet.
class WordLabelPicker extends ConsumerStatefulWidget {
  /// Creates the picker.
  const new({
    required this.kind,
    required this.selected,
    required this.onToggle,
    super.key,
  });

  /// How many labels show before anything is typed.
  static const int suggestions = 8;

  /// Lists or tags.
  final ListKind kind;

  /// The ids chosen when the sheet opened.
  final List<String> selected;

  /// Adds or removes one id, as it is tapped.
  final ValueChanged<String> onToggle;

  /// Opens the sheet.
  static Future<void> show(
    BuildContext context, {
    required ListKind kind,
    required List<String> selected,
    required ValueChanged<String> onToggle,
  }) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) =>
        WordLabelPicker(kind: kind, selected: selected, onToggle: onToggle),
  );

  @override
  ConsumerState<WordLabelPicker> createState() => _WordLabelPickerState();
}

class _WordLabelPickerState extends ConsumerState<WordLabelPicker> {
  final TextEditingController _search = TextEditingController();
  final FocusNode _focus = FocusNode();
  late final Set<String> _selected = widget.selected.toSet();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    _focus.dispose();
    super.dispose();
  }

  static String _key(String name) => name.trim().toLowerCase();

  /// Ready for the next one: tagging a word is rarely one tag.
  void _clear() {
    _search.clear();
    setState(() => _query = '');
    _focus.requestFocus();
  }

  void _toggle(String id) {
    setState(() {
      if (!_selected.remove(id)) _selected.add(id);
    });
    widget.onToggle(id);
    _clear();
  }

  Future<void> _create(int existing) async {
    final messenger = ScaffoldMessenger.of(context);
    final failed = AppL10n.of(context).listSaveFailed;
    final actions = ref.read(listActionsProvider.notifier);
    final result = await actions.create(
      name: _query.trim(),
      color: IpaColorToken.values[existing % IpaColorToken.values.length],
      kind: widget.kind,
    );
    if (!mounted) return;
    result.fold(
      (created) => _toggle(created.id),
      (_) => messenger.showSnackBar(SnackBar(content: Text(failed))),
    );
  }

  /// With nothing typed, the most used. Otherwise whatever matches, names
  /// that start with the query first.
  List<WordListSummary> _shown(List<WordListSummary> all) {
    final needle = _key(_query);
    if (needle.isEmpty) {
      final byUse = List<WordListSummary>.of(all)
        ..sort((a, b) => b.wordCount.compareTo(a.wordCount));
      return byUse.take(WordLabelPicker.suggestions).toList();
    }
    final matches =
        all.where((s) => _key(s.list.name).contains(needle)).toList()
          ..sort((a, b) {
            final aKey = _key(a.list.name);
            final bKey = _key(b.list.name);
            final aStart = aKey.startsWith(needle) ? 0 : 1;
            final bStart = bKey.startsWith(needle) ? 0 : 1;
            return aStart != bStart
                ? aStart.compareTo(bStart)
                : aKey.compareTo(bKey);
          });
    return matches;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final isTag = widget.kind == ListKind.tag;
    final all = _labels(ref, widget.kind);
    final shown = _shown(all);
    final typed = _query.trim();
    final canCreate =
        typed.isNotEmpty &&
        !all.any((summary) => _key(summary.list.name) == _key(typed));

    return VnSheetBody(
      children: <Widget>[
        Text(
          isTag ? l10n.addTagAction : l10n.addListAction,
          style: theme.textTheme.titleLarge,
        ),
        const VnGap(VnSpace.md),
        TextField(
          controller: _search,
          focusNode: _focus,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            hintText: isTag ? l10n.labelSearchTags : l10n.labelSearchLists,
            prefixIcon: const Icon(Icons.search),
          ),
          onChanged: (text) => setState(() => _query = text),
        ),
        const VnGap(VnSpace.sm),
        if (canCreate)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.add),
            title: Text(
              isTag ? l10n.labelCreateTag(typed) : l10n.labelCreateList(typed),
            ),
            onTap: () => _create(all.length),
          ),
        for (final summary in shown)
          ListTile(
            contentPadding: EdgeInsets.zero,
            selected: _selected.contains(summary.list.id),
            leading: Icon(
              _selected.contains(summary.list.id)
                  ? Icons.check_circle
                  : Icons.circle_outlined,
            ),
            title: Text(summary.list.name),
            trailing: Text(l10n.listWordCount(summary.wordCount)),
            onTap: () => _toggle(summary.list.id),
          ),
        const VnGap(VnSpace.sm),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.labelPickerDone),
          ),
        ),
      ],
    );
  }
}
