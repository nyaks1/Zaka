import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zaka/features/advisor/advisor_screen.dart';
import 'package:zaka/features/advisor/advisor_summary.dart';
import 'package:zaka/providers.dart';

void main() {
  testWidgets('consent screen shows the live summary and the privacy limits', (
    tester,
  ) async {
    const summary = AdvisorSummary(
      runwayDays: 3,
      dailyBurnRand: 90,
      categoryPercent: {'Taxi': 48, 'Food': 52},
      periodDays: 14,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          advisorSummaryProvider.overrideWithValue(
            const AsyncValue.data(summary),
          ),
          advisorConsentProvider.overrideWith((ref) async => false),
        ],
        child: const MaterialApp(home: AdvisorScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('"runwayDays":3'), findsOneWidget);
    expect(
      find.text('Spend notes or transaction descriptions'),
      findsOneWidget,
    );
    expect(find.textContaining('outside South Africa'), findsOneWidget);

    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text('Allow Ask Zaka'),
      300,
      scrollable: scrollable,
    );
    expect(find.text('Allow Ask Zaka'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Delete everything'),
      300,
      scrollable: scrollable,
    );
    expect(find.text('Delete everything'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Send feedback or a complaint'),
      300,
      scrollable: scrollable,
    );
    expect(find.text('Send feedback or a complaint'), findsOneWidget);
    expect(
      find.text('Please don’t send bank details or statements.'),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.textContaining('not financial advice'),
      300,
      scrollable: scrollable,
    );
    expect(find.textContaining('not financial advice'), findsWidgets);
  });
}
