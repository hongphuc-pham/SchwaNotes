import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vocabnote/application/lists/list_controller.dart';
import 'package:vocabnote/application/settings/settings_controller.dart';
import 'package:vocabnote/application/words/pronunciation_controller.dart';
import 'package:vocabnote/application/words/voice_notice_controller.dart';
import 'package:vocabnote/application/words/word_actions_controller.dart';
import 'package:vocabnote/application/words/word_detail_controller.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/router/routes.dart';
import 'package:vocabnote/core/theme/app_metrics.dart';
import 'package:vocabnote/core/theme/tokens.dart';
import 'package:vocabnote/core/utils/external_links.dart';
import 'package:vocabnote/domain/entities/app_settings.dart';
import 'package:vocabnote/domain/entities/ipa_highlight.dart';
import 'package:vocabnote/domain/entities/word.dart';
import 'package:vocabnote/domain/entities/word_list.dart';
import 'package:vocabnote/domain/value_objects/headword.dart';
import 'package:vocabnote/presentation/common/empty_state.dart';
import 'package:vocabnote/presentation/design/gap.dart';
import 'package:vocabnote/presentation/design/section.dart';
import 'package:vocabnote/presentation/words/highlight_legend.dart';
import 'package:vocabnote/presentation/words/pronunciation_row.dart';
import 'package:vocabnote/presentation/words/word_notes_section.dart';

/// One word, in full (`docs/UI-UX.md` §4.3, F-020, F-021, F-024, F-025).
///
/// One primary action: **hear this word**. Everything else on the screen —
/// highlights, notes, the dictionary link — supports coming back to it later.
class WordDetailScreen extends ConsumerStatefulWidget {
  /// Creates the detail screen for [wordId].
  const new({required this.wordId, super.key});

  /// The word being shown.
  final String wordId;

  @override
  ConsumerState<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends ConsumerState<WordDetailScreen> {
  /// Whether autoplay has already fired for this screen.
  ///
  /// Once per visit, never once per rebuild: the detail stream re-emits when a
  /// note is added, and a word that says itself again every time you write
  /// something down would be intolerable.
  bool _autoplayed = false;

  /// Speaks the word on open when the user has asked for that (F-020).
  ///
  /// [settings] is null while the row is still loading. Deliberately *not*
  /// defaulted: autoplay is off by default, so deciding before the real
  /// settings arrive would settle the question wrongly and — because this runs
  /// exactly once — never revisit it. The screen watches the settings, so a
  /// later build calls this again with a real value.
  void _maybeAutoplay(Word word, AppSettings? settings) {
    if (_autoplayed || settings == null) return;

    _autoplayed = true;
    if (!settings.autoplayOnOpen) return;
    if (word.preferredIpa == null) return;

    // After the frame: speaking from inside build would fire during a widget
    // tree that is still being assembled.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        ref
            .read(pronunciationProvider.notifier)
            .play(word.headword.value, locale: settings.ttsLocale),
      );
    });
  }

  Future<void> _delete(Word word) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppL10n.of(context);
    final router = GoRouter.of(context);
    final actions = ref.read(wordActionsProvider.notifier);

    final result = await actions.delete(word.id);
    if (result.isErr) return;

    // Back to the list: staying on the detail of a word that is now deleted
    // would only show the "this word is gone" state.
    if (router.canPop()) router.pop();

    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.wordDeletedSnack(word.headword.value)),
        action: SnackBarAction(
          label: l10n.undoAction,
          onPressed: () => actions.restore(word.id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final detail = ref.watch(wordDetailProvider(widget.wordId));
    // Watched, not read: autoplay has to be reconsidered once the settings row
    // arrives, and the play buttons want the current rate.
    final settings = ref.watch(appSettingsProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: Text(detail.value?.word.headword.value ?? l10n.wordDetailTitle),
        actions: <Widget>[
          if (detail.value case final WordDetail loaded) ...<Widget>[
            IconButton(
              icon: Icon(
                loaded.word.isFavourite ? Icons.star : Icons.star_border,
              ),
              tooltip: loaded.word.isFavourite
                  ? l10n.wordUnfavouriteLabel(loaded.word.headword.value)
                  : l10n.wordFavouriteLabel(loaded.word.headword.value),
              onPressed: () => ref
                  .read(wordActionsProvider.notifier)
                  .setFavourite(
                    loaded.word.id,
                    isFavourite: !loaded.word.isFavourite,
                  ),
            ),
            _OverflowMenu(
              onEdit: () => context.push(Routes.wordEditOf(loaded.word.id)),
              onDelete: () => _delete(loaded.word),
            ),
          ],
        ],
      ),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => EmptyState(
          icon: Icons.error_outline,
          title: l10n.detailLoadFailedTitle,
          body: l10n.detailLoadFailedBody,
          actionLabel: l10n.retryAction,
          onAction: () => ref.invalidate(wordDetailProvider(widget.wordId)),
        ),
        data: (loaded) {
          if (loaded == null) {
            return EmptyState(
              icon: Icons.delete_outline,
              title: l10n.detailNotFoundTitle,
              body: l10n.detailNotFoundBody,
              actionLabel: l10n.backLabel,
              onAction: () =>
                  context.canPop() ? context.pop() : context.go(Routes.words),
            );
          }

          _maybeAutoplay(loaded.word, settings);
          return _DetailBody(detail: loaded);
        },
      ),
    );
  }
}

/// Edit and delete, kept out of the app bar's limited width.
class _OverflowMenu extends StatelessWidget {
  const new({required this.onEdit, required this.onDelete});

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return PopupMenuButton<VoidCallback>(
      onSelected: (action) => action(),
      itemBuilder: (context) => <PopupMenuEntry<VoidCallback>>[
        PopupMenuItem<VoidCallback>(
          value: onEdit,
          child: Text(l10n.detailEditAction),
        ),
        PopupMenuItem<VoidCallback>(
          value: onDelete,
          child: Text(l10n.deleteWordAction),
        ),
      ],
    );
  }
}

/// Everything below the app bar, once the word has loaded.
class _DetailBody extends StatelessWidget {
  const new({required this.detail});

  final WordDetail detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final word = detail.word;

    return ListView(
      padding: EdgeInsets.all(context.metrics.spaceLg),
      children: <Widget>[
        Text(word.headword.value, style: theme.textTheme.headlineMedium),
        if (word.partOfSpeech case final String pos) ...<Widget>[
          const VnGap(VnSpace.xs),
          Text(
            pos,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
        const VnGap(VnSpace.lg),
        const _VoiceNotice(),
        _Pronunciation(detail: detail),
        const VnGap(VnSpace.lg),
        if (word.definition case final String definition)
          VnSection(
            heading: l10n.fieldDefinition,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(definition, style: theme.textTheme.bodyLarge),
                if (word.source.requiresAttribution &&
                    word.sourceAttribution != null) ...<Widget>[
                  const VnGap(VnSpace.xs),
                  VnQuietText(word.sourceAttribution!),
                ],
              ],
            ),
          ),
        if (word.example case final String example)
          VnSection(
            heading: l10n.fieldExample,
            child: Text(
              '"$example"',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        _WordLabels(wordId: word.id),
        const VnGap(VnSpace.sm),
        WordNotesSection(wordId: word.id, notes: detail.notes),
        const VnGap(VnSpace.xl),
        _CambridgeLink(headword: word.headword),
      ],
    );
  }
}

/// The word's lists, then its tags. Each opens the words that share it.
class _WordLabels extends ConsumerWidget {
  const new({required this.wordId});

  final String wordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ids =
        ref.watch(listIdsForWordProvider(wordId)).value ?? const <String>[];
    final labels = <WordListSummary>[
      ...?ref.watch(listSummariesProvider).value,
      ...?ref.watch(tagSummariesProvider).value,
    ].where((summary) => ids.contains(summary.list.id)).toList();
    if (labels.isEmpty) return const SizedBox.shrink();

    return VnSection(
      heading: AppL10n.of(context).detailLabels,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: <Widget>[
          for (final summary in labels)
            ActionChip(
              avatar: Icon(
                summary.list.kind == ListKind.tag
                    ? Icons.sell_outlined
                    : Icons.folder_outlined,
              ),
              label: Text(summary.list.name),
              onPressed: () =>
                  context.push(Routes.listDetailOf(summary.list.id)),
            ),
        ],
      ),
    );
  }
}

/// The UK and US rows, the legend, or an invitation to add a transcription.
class _Pronunciation extends StatefulWidget {
  const new({required this.detail});

  final WordDetail detail;

  @override
  State<_Pronunciation> createState() => _PronunciationState();
}

class _PronunciationState extends State<_Pronunciation> {
  /// The highlight the user last tapped in the legend (F-024).
  IpaHighlight? _emphasised;
  Timer? _clearEmphasis;

  /// How long a tapped legend line points at its run.
  ///
  /// Emphasis rather than movement, so reduce-motion has nothing to suppress
  /// (F-093). The length is a design value, not a number chosen here.
  static const Duration _emphasisDuration = AppTiming.legendEmphasis;

  @override
  void dispose() {
    _clearEmphasis?.cancel();
    super.dispose();
  }

  void _jumpTo(IpaHighlight highlight) {
    _clearEmphasis?.cancel();
    setState(() => _emphasised = highlight);
    _clearEmphasis = Timer(_emphasisDuration, () {
      if (mounted) setState(() => _emphasised = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final word = widget.detail.word;

    if (word.hasNoIpa) {
      return EmptyState(
        icon: Icons.record_voice_over_outlined,
        title: l10n.detailNoIpaTitle,
        body: l10n.detailNoIpaBody,
        actionLabel: l10n.detailAddIpaAction,
        onAction: () => context.push(Routes.wordEditOf(word.id)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (word.ipaUk case final ipa?)
          PronunciationRow(
            headword: word.headword.value,
            ipa: ipa.value,
            locale: TtsLocale.enGb,
            highlights: widget.detail.highlightsFor(HighlightTarget.ipaUk),
            emphasisedHighlightId: _emphasised?.id,
          ),
        if (word.ipaUs case final ipa?)
          PronunciationRow(
            headword: word.headword.value,
            ipa: ipa.value,
            locale: TtsLocale.enUs,
            highlights: widget.detail.highlightsFor(HighlightTarget.ipaUs),
            emphasisedHighlightId: _emphasised?.id,
          ),
        const VnGap(VnSpace.xs),
        Text(
          l10n.detailSlowHint,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        const VnGap(VnSpace.md),
        HighlightLegend(
          highlights: widget.detail.highlights,
          emphasised: _emphasised,
          onJumpTo: _jumpTo,
        ),
        const VnGap(VnSpace.md),
        OutlinedButton.icon(
          onPressed: () => context.push(Routes.wordIpaOf(word.id)),
          icon: const Icon(Icons.format_color_text),
          label: Text(l10n.detailEditHighlightsAction),
        ),
      ],
    );
  }
}

/// The one-time notice that this device has no British voice.
///
/// `docs/DATA-SOURCES.md` §4. Sits above the transcriptions because that is
/// where the user is about to press play and be surprised.
///
/// It names where to look in the OS rather than deep-linking there: opening
/// Android's text-to-speech settings needs a package that is not in the
/// dependency ledger, and `docs/RULES.md` §42 says to ask before adding one.
class _VoiceNotice extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final show = ref.watch(voiceNoticeProvider).value ?? false;
    if (!show) return const SizedBox.shrink();

    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      margin: EdgeInsets.only(bottom: context.metrics.spaceMd),
      child: Padding(
        padding: EdgeInsets.all(context.metrics.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(l10n.voiceFallbackNotice, style: theme.textTheme.bodyMedium),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () =>
                    ref.read(voiceNoticeProvider.notifier).dismiss(),
                child: Text(l10n.voiceFallbackDismiss),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The link out to Cambridge (F-025).
///
/// A link and nothing more. `docs/RULES.md` §13 allows linking out and forbids
/// every other integration - no scraping, no embedded webview of their pages.
class _CambridgeLink extends StatelessWidget {
  const new({required this.headword});

  final Headword headword;

  Future<void> _open(BuildContext context, Uri url) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppL10n.of(context);

    // Deliberately no `canLaunchUrl` gate: on Android 11+ it returns false in
    // cases where `launchUrl` works, and url_launcher's own README says to
    // launch and handle failure instead.
    final launched = await launchUrl(
      url,
      // The user's own browser, never an embedded view.
      mode: LaunchMode.externalApplication,
    );

    if (!launched && context.mounted) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailCambridgeFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final url = CambridgeDictionary.entryFor(headword.normalized);
    // No headword to look up means no dead button.
    if (url == null) return const SizedBox.shrink();

    return OutlinedButton.icon(
      onPressed: () => _open(context, url),
      icon: const Icon(Icons.open_in_new),
      label: Text(l10n.detailCambridgeAction),
    );
  }
}
