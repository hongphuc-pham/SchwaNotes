import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabnote/application/settings/app_info.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/theme/app_metrics.dart';
import 'package:vocabnote/presentation/design/gap.dart';
import 'package:vocabnote/presentation/design/sheet_body.dart';

/// The privacy note (F-076).
///
/// Leads with F-076's sentence word for word, then the points of
/// `docs/DATA-SOURCES.md` §7 in the second person. Those two and the store
/// privacy declarations say the same thing; if one changes, all three change
/// in the same PR (§7).
///
/// Shown as a section of *Data sources & licences* and, from Settings →
/// About → Privacy, as a sheet - one widget, so the two cannot drift apart.
///
/// The feedback point describes the email a build with a feedback address
/// offers. A build without one (v1.0: GitHub Issues only) has no such email,
/// so the note does not claim it (M8).
class PrivacyNote extends ConsumerWidget {
  /// Creates the note.
  const new({super.key});

  /// Opens the note as a sheet.
  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => VnSheetBody(
      children: <Widget>[
        Text(
          AppL10n.of(context).privacyHeading,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const VnGap(VnSpace.md),
        const PrivacyNote(),
      ],
    ),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final metrics = context.metrics;
    final hasFeedbackEmail = ref.watch(feedbackAddressProvider) != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(l10n.privacyNote, style: theme.textTheme.bodyLarge),
        const VnGap(VnSpace.md),
        for (final point in <String>[
          l10n.privacyPoint1,
          l10n.privacyPoint2,
          l10n.privacyPoint3,
          if (hasFeedbackEmail) l10n.privacyPoint4,
          l10n.privacyPoint5,
        ])
          Padding(
            padding: EdgeInsets.only(bottom: metrics.spaceSm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: metrics.spaceSm,
              children: <Widget>[
                // Decorative: an Icon without a label is skipped by screen
                // readers, which read the point itself.
                Icon(
                  Icons.check_circle_outline,
                  color: theme.colorScheme.primary,
                ),
                Expanded(child: Text(point, style: theme.textTheme.bodyMedium)),
              ],
            ),
          ),
      ],
    );
  }
}
