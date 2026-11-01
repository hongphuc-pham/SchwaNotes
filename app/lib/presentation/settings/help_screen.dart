import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabnote/application/repositories.dart';
import 'package:vocabnote/application/settings/app_info.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/theme/app_metrics.dart';
import 'package:vocabnote/core/utils/external_links.dart';
import 'package:vocabnote/presentation/design/section.dart';
import 'package:vocabnote/presentation/settings/error_log_sheet.dart';
import 'package:vocabnote/presentation/settings/feedback_preview.dart';
import 'package:vocabnote/presentation/settings/settings_tiles.dart';

/// Help & feedback (F-072, `docs/UI-UX.md` §4.11). Always in Settings
/// (RULES §4, P8).
///
/// One primary job: get the user unstuck. Answers first, searchable as they
/// type; then the ways to reach a person - each one a deliberate tap, and
/// nothing leaves the app without one.
class HelpScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const new({super.key});

  @override
  ConsumerState<HelpScreen> createState() => _HelpScreenState();
}

/// One question and its answer.
typedef _Faq = ({String question, String answer});

class _HelpScreenState extends ConsumerState<HelpScreen> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _clear() {
    _search.clear();
    setState(() => _query = '');
  }

  static List<_Faq> _faqs(AppL10n l10n) => <_Faq>[
    (question: l10n.faqQ1, answer: l10n.faqA1),
    (question: l10n.faqQ2, answer: l10n.faqA2),
    (question: l10n.faqQ13, answer: l10n.faqA13),
    (question: l10n.faqQ3, answer: l10n.faqA3),
    (question: l10n.faqQ4, answer: l10n.faqA4),
    (question: l10n.faqQ5, answer: l10n.faqA5),
    (question: l10n.faqQ6, answer: l10n.faqA6),
    (question: l10n.faqQ7, answer: l10n.faqA7),
    (question: l10n.faqQ8, answer: l10n.faqA8),
    (question: l10n.faqQ9, answer: l10n.faqA9),
    (question: l10n.faqQ10, answer: l10n.faqA10),
    (question: l10n.faqQ11, answer: l10n.faqA11),
    (question: l10n.faqQ12, answer: l10n.faqA12),
  ];

  /// The answers that mention [query], in the question or the answer.
  static List<_Faq> _matching(List<_Faq> all, String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return all;
    return <_Faq>[
      for (final faq in all)
        if (faq.question.toLowerCase().contains(needle) ||
            faq.answer.toLowerCase().contains(needle))
          faq,
    ];
  }

  Future<void> _openIssues() async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppL10n.of(context);
    if (!await ref.read(linkOpenerProvider).open(ProjectLinks.issues)) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.helpLinkFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final metrics = context.metrics;
    final address = ref.watch(feedbackAddressProvider);
    final shown = _matching(_faqs(l10n), _query);
    final gutter = EdgeInsets.symmetric(horizontal: metrics.spaceLg);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpTitle)),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: metrics.spaceMd),
        children: <Widget>[
          Padding(
            padding: gutter,
            child: TextField(
              controller: _search,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.faqSearchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: l10n.faqClear,
                        icon: const Icon(Icons.clear),
                        onPressed: _clear,
                      ),
              ),
              onChanged: (text) => setState(() => _query = text),
            ),
          ),
          // Read out as it changes, so a screen-reader user hears the search
          // do something without having to go looking.
          Padding(
            padding: gutter.copyWith(
              top: metrics.spaceSm,
              bottom: metrics.spaceSm,
            ),
            child: Semantics(
              liveRegion: true,
              child: VnQuietText(
                shown.isEmpty
                    ? l10n.faqNoAnswers(_query.trim())
                    : l10n.faqCount(shown.length),
              ),
            ),
          ),
          if (shown.isEmpty)
            Padding(
              padding: gutter,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton(
                  onPressed: _clear,
                  child: Text(l10n.faqClear),
                ),
              ),
            )
          else
            for (final faq in shown)
              ExpansionTile(
                title: Text(faq.question),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                childrenPadding: gutter.copyWith(bottom: metrics.spaceMd),
                children: <Widget>[Text(faq.answer)],
              ),
          SettingsHeader(l10n.helpStillStuck),
          if (address != null)
            ListTile(
              leading: const Icon(Icons.mail_outline),
              title: Text(l10n.feedbackSend),
              subtitle: Text(l10n.feedbackSendHint),
              onTap: () => unawaited(sendFeedback(context, ref, address)),
            ),
          ListTile(
            leading: const Icon(Icons.bug_report_outlined),
            title: Text(l10n.helpGitHub),
            subtitle: Text(l10n.helpGitHubHint),
            onTap: () => unawaited(_openIssues()),
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long_outlined),
            title: Text(l10n.helpErrorLog),
            subtitle: Text(l10n.helpErrorLogHint),
            onTap: () => unawaited(ErrorLogSheet.show(context)),
          ),
        ],
      ),
    );
  }
}
