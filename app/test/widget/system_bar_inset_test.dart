import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/presentation/design/system_bar_inset.dart';

/// Android draws the app behind its navigation bar. Everything must end above
/// that bar, however tall it is on this phone (found on a real device).
void main() {
  const barHeight = 48.0;
  const screenHeight = 600.0;

  void systemBar(
    WidgetTester tester, {
    double bottom = barHeight,
    double left = 0,
    double right = 0,
    double keyboard = 0,
  }) {
    final ratio = tester.view.devicePixelRatio;
    final bar = FakeViewPadding(
      bottom: bottom * ratio,
      left: left * ratio,
      right: right * ratio,
    );
    tester.view.viewPadding = bar;
    // Android reports the keyboard as covering the bar, which is why the bar
    // leaves `padding` while it stays in `viewPadding`.
    tester.view.padding = keyboard > 0
        ? FakeViewPadding(left: left * ratio, right: right * ratio)
        : bar;
    tester.view.viewInsets = FakeViewPadding(bottom: keyboard * ratio);
    addTearDown(tester.view.reset);
  }

  Widget app(Widget home) => MaterialApp(
    builder: (context, child) => VnSystemBarInset(child: child!),
    home: home,
  );

  testWidgets('a screen with fixed padding ends above the bar', (tester) async {
    systemBar(tester);
    await tester.pumpWidget(
      app(
        Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(8),
            children: const <Widget>[SizedBox(height: 900), Text('last')],
          ),
        ),
      ),
    );

    await tester.drag(find.byType(ListView), const Offset(0, -2000));
    await tester.pumpAndSettle();

    expect(
      tester.getBottomLeft(find.text('last')).dy,
      lessThanOrEqualTo(screenHeight - barHeight),
    );
  });

  testWidgets('a bottom sheet ends above the bar', (tester) async {
    // `useSafeArea` does not help here: it guards the top of a sheet only.
    systemBar(tester);
    await tester.pumpWidget(
      app(
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                useSafeArea: true,
                builder: (_) => const Text('sheet action'),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(
      tester.getBottomLeft(find.text('sheet action')).dy,
      lessThanOrEqualTo(screenHeight - barHeight),
    );
  });

  testWidgets('the keyboard gets no gap above it from the bar', (tester) async {
    // The bar is hidden behind the keyboard, so counting both would float
    // whatever sits on the keyboard 48 logical pixels too high.
    const keyboard = 300.0;
    systemBar(tester, keyboard: keyboard);
    await tester.pumpWidget(
      app(const Scaffold(body: SizedBox.expand(key: Key('body')))),
    );

    expect(
      tester.getBottomLeft(find.byKey(const Key('body'))).dy,
      screenHeight - keyboard,
    );
  });

  testWidgets('with no bar, nothing moves', (tester) async {
    systemBar(tester, bottom: 0);
    await tester.pumpWidget(
      app(const Scaffold(body: SizedBox.expand(key: Key('body')))),
    );

    expect(
      tester.getBottomLeft(find.byKey(const Key('body'))).dy,
      screenHeight,
    );
  });

  testWidgets('a bar on the side, in landscape, is cleared too', (
    tester,
  ) async {
    systemBar(tester, bottom: 0, right: barHeight);
    await tester.pumpWidget(
      app(const Scaffold(body: SizedBox.expand(key: Key('body')))),
    );

    expect(
      tester.getTopRight(find.byKey(const Key('body'))).dx,
      tester.view.physicalSize.width / tester.view.devicePixelRatio - barHeight,
    );
  });

  testWidgets('nothing below it adds the same bar a second time', (
    tester,
  ) async {
    systemBar(tester);
    late EdgeInsets seen;
    await tester.pumpWidget(
      app(
        Builder(
          builder: (context) {
            seen = MediaQuery.paddingOf(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(seen.bottom, 0);
  });
}
