import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabnote/application/repositories.dart';
import 'package:vocabnote/application/settings/app_info.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/theme/app_metrics.dart';
import 'package:vocabnote/core/utils/bundled_licences.dart';
import 'package:vocabnote/core/utils/external_links.dart';
import 'package:vocabnote/presentation/design/gap.dart';
import 'package:vocabnote/presentation/design/section.dart';
import 'package:vocabnote/presentation/design/sheet_body.dart';
import 'package:vocabnote/presentation/settings/privacy_note.dart';

/// Data sources & licences (F-075) and the privacy note (F-076).
///
/// RULES §14: any bundled or displayed third-party content carries in-app
/// attribution and its licence. Each source is named, its licence named, and
/// linked back to - the three things CC BY-SA 4.0 asks
/// (`docs/DATA-SOURCES.md` §1).
///
/// Cambridge Dictionary is deliberately absent: DATA-SOURCES §3 allows its
/// name only as the text of its link, so even a "not affiliated" line here
/// would break the rule it means to honour.
class LicencesScreen extends ConsumerWidget {
  /// Creates the screen.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    // Null only in the moment before the platform answers (F-092); the
    // licence page then simply shows no version line.
    final version = ref.watch(appVersionProvider).value;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.licencesTitle)),
      body: ListView(
        padding: EdgeInsets.all(context.metrics.spaceLg),
        children: <Widget>[
          VnSection(heading: l10n.privacyHeading, child: const PrivacyNote()),
          VnSection(
            heading: l10n.licencesDictionaryHeading,
            child: _Source(
              body: l10n.licencesDictionaryBody,
              links: <(String, Uri)>[
                (l10n.licencesWiktionary, SourceLinks.wiktionary),
                (l10n.licencesFreeDictionary, SourceLinks.freeDictionary),
                (l10n.licencesCcBySa, SourceLinks.ccBySa),
              ],
            ),
          ),
          VnSection(
            heading: l10n.licencesOfflineHeading,
            child: _Source(
              body: l10n.licencesOfflineBody,
              links: <(String, Uri)>[
                (l10n.licencesCmudict, SourceLinks.cmudict),
              ],
            ),
          ),
          VnSection(
            heading: l10n.licencesFontsHeading,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(l10n.licencesFontsBody),
                _FontRow(
                  name: l10n.licencesInter,
                  path: BundledLicences.interPath,
                ),
                _FontRow(
                  name: l10n.licencesCharis,
                  path: BundledLicences.charisPath,
                ),
              ],
            ),
          ),
          VnSection(
            heading: l10n.licencesPackagesHeading,
            padded: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(l10n.licencesPackagesBody),
                const VnGap(VnSpace.sm),
                OutlinedButton(
                  onPressed: () => showLicensePage(
                    context: context,
                    applicationName: l10n.appTitle,
                    applicationVersion: version,
                  ),
                  child: Text(l10n.licencesPackages),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A source: what it provides, and links back to it.
class _Source extends ConsumerWidget {
  const new({required this.body, required this.links});

  final String body;
  final List<(String, Uri)> links;

  Future<void> _open(BuildContext context, WidgetRef ref, Uri uri) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppL10n.of(context);
    if (!await ref.read(linkOpenerProvider).open(uri)) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.helpLinkFailed)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(body),
        const VnGap(VnSpace.xs),
        Wrap(
          spacing: context.metrics.spaceXs,
          children: <Widget>[
            for (final (label, uri) in links)
              TextButton.icon(
                onPressed: () => unawaited(_open(context, ref, uri)),
                icon: const Icon(Icons.open_in_new),
                label: Text(label),
              ),
          ],
        ),
      ],
    );
  }
}

/// A bundled font, its licence named, and its licence text a tap away.
class _FontRow extends StatelessWidget {
  const new({required this.name, required this.path});

  final String name;
  final String path;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    // Reflows to a column when the name and the button cannot share a line
    // (UI-UX §6). A ListTile's trailing button took the whole width at 200%
    // text on 320dp, and the tile could not lay out at all.
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.metrics.spaceSm),
      child: OverflowBar(
        alignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(name, style: Theme.of(context).textTheme.bodyLarge),
              VnQuietText(l10n.licencesOflName),
            ],
          ),
          TextButton(
            onPressed: () => unawaited(
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                builder: (context) => _LicenceText(title: name, path: path),
              ),
            ),
            child: Text(
              l10n.licencesViewLicence,
              semanticsLabel: l10n.licencesViewLicenceFor(name),
            ),
          ),
        ],
      ),
    );
  }
}

/// A bundled licence file, in full.
class _LicenceText extends StatefulWidget {
  const new({required this.title, required this.path});

  final String title;
  final String path;

  @override
  State<_LicenceText> createState() => _LicenceTextState();
}

class _LicenceTextState extends State<_LicenceText> {
  String? _text;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final text = await rootBundle.loadString(widget.path);
    if (mounted) setState(() => _text = text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = _text;

    return VnSheetBody(
      children: <Widget>[
        Text(widget.title, style: theme.textTheme.titleLarge),
        const VnGap(VnSpace.md),
        // Words, not a spinner, while it loads: a spinner never settles.
        if (text == null)
          Text(AppL10n.of(context).licencesLoading)
        else
          SelectableText(text, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
