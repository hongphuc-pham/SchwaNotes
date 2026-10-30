import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/theme/app_theme.dart';
import 'package:vocabnote/domain/entities/practice_session.dart';
import 'package:vocabnote/presentation/practice/mix_options.dart';

/// The Mix choices shared by Settings and the quick-test sheet.
void main() {
  late Set<PromptSide> sides;
  late MixOrder order;

  Future<void> pump(WidgetTester tester, Set<PromptSide> initial) async {
    sides = initial;
    order = MixOrder.random;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppL10n.localizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => MixOptions(
              sides: sides,
              order: order,
              onSidesChanged: (value) => setState(() => sides = value),
              onOrderChanged: (value) => setState(() => order = value),
            ),
          ),
        ),
      ),
    );
  }

  FilterChip chip(WidgetTester tester, String label) => tester.widget(
    find.ancestor(of: find.text(label), matching: find.byType(FilterChip)),
  );

  testWidgets('ticking a face adds it, and only it', (tester) async {
    await pump(tester, PromptSide.defaultMixSides);

    await tester.tap(find.text('The sounds'));
    await tester.pump();

    expect(sides, PromptSide.mixableSides);
  });

  testWidgets('unticking a face removes it while three are ticked', (
    tester,
  ) async {
    await pump(tester, PromptSide.mixableSides);

    await tester.tap(find.text('The word'));
    await tester.pump();

    expect(sides, <PromptSide>{PromptSide.ipaFirst, PromptSide.meaningFirst});
  });

  testWidgets('the last two faces cannot be unticked, and it says why', (
    tester,
  ) async {
    await pump(tester, PromptSide.defaultMixSides);

    expect(chip(tester, 'The word').onSelected, isNull);
    expect(chip(tester, 'The meaning').onSelected, isNull);
    expect(chip(tester, 'The sounds').onSelected, isNotNull);
    expect(find.text('Pick at least two.'), findsOneWidget);

    await tester.tap(find.text('The word'));
    await tester.pump();
    expect(sides, PromptSide.defaultMixSides);
  });

  testWidgets('the order can be switched to take turns', (tester) async {
    await pump(tester, PromptSide.defaultMixSides);

    await tester.tap(find.text('Take turns'));
    await tester.pump();

    expect(order, MixOrder.rotate);
  });
}
