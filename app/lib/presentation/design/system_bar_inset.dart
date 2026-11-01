import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Keeps the whole app clear of the system navigation bar.
///
/// Android lays apps out behind that bar, so anything at the bottom of a
/// screen could end up under it: a `ListView` with its own padding ignores the
/// bar, and `useSafeArea` on a bottom sheet guards only the top. Rather than
/// have every screen and sheet remember, the app is laid out once above
/// whatever bar this phone has, three buttons or a gesture pill, and with none
/// nothing changes.
class VnSystemBarInset extends StatelessWidget {
  /// Creates the inset around [child], the whole app.
  const new({required this.child, super.key});

  /// What must stay clear of the bar.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    // `viewPadding`, not `padding`: `padding` drops to zero while the keyboard
    // is up, and the layout would jump as it opens.
    final bar = media.viewPadding;

    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: EdgeInsets.fromLTRB(bar.left, 0, bar.right, bar.bottom),
        child: MediaQuery(
          data: media.copyWith(
            padding: media.padding.copyWith(left: 0, right: 0, bottom: 0),
            viewPadding: bar.copyWith(left: 0, right: 0, bottom: 0),
            // The keyboard is measured from the bottom of the screen and
            // covers the bar, so that much of it is already accounted for.
            viewInsets: media.viewInsets.copyWith(
              bottom: math.max(0, media.viewInsets.bottom - bar.bottom),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
