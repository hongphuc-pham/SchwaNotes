/// Facts about this build of the app.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vocabnote/core/utils/external_links.dart';

part 'app_info.g.dart';

/// The app's version as the platform reports it, e.g. `1.0.0`.
///
/// Started by `bootstrap` and **never waited for there**: it is a
/// platform-channel call, and on the emulator at M7 it was 4.9s of a 5.2s cold
/// start (F-092). Whatever shows it reads the value once it has arrived.
/// Supplied by the composition root, and declared here like the repositories
/// for the same reason: nothing above `data/` may name `package_info_plus`.
@Riverpod(keepAlive: true)
Future<String> appVersion(Ref ref) => throw UnimplementedError(
  'appVersionProvider must be overridden in bootstrap() or in a test.',
);

/// Whether this launch opens on onboarding (F-077).
///
/// Decided once in `bootstrap`, before the first frame, so the router knows
/// its first location synchronously and the words tab never flashes up
/// before a redirect. False unless bootstrap says otherwise - so a test that
/// is not about onboarding starts where every other launch does.
@Riverpod(keepAlive: true)
bool showOnboarding(Ref ref) => false;

/// Where *Send feedback* writes to, or null when this build has no address.
///
/// Set with `--dart-define=FEEDBACK_EMAIL=…` at release (M8). Until then Help
/// offers GitHub Issues only: an address baked into the app is public, and
/// it is the owner's to choose (`plan.md`, decided 11 Sep).
@Riverpod(keepAlive: true)
String? feedbackAddress(Ref ref) =>
    FeedbackEmail.address.isEmpty ? null : FeedbackEmail.address;

/// Where *Buy me a coffee* goes, or null when there is nowhere yet - which
/// hides the row. A provider rather than the constant itself so a test can
/// show the row without a real page.
@Riverpod(keepAlive: true)
Uri? supportLink(Ref ref) => ProjectLinks.support;
