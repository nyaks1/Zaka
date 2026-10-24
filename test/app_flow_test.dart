import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zaka/app.dart';
import 'package:zaka/data/database.dart';
import 'package:zaka/providers.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> disposeApp(WidgetTester tester) async {
    // Unmount the providers before the database closes so drift can cancel
    // its stream queries cleanly.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const ZakaApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('adds money and logs a spend with the live balance', (
    tester,
  ) async {
    await pumpApp(tester);

    // Tap the in-card Add money button (not the app-bar shortcut) so the
    // dashboard's primary call to action is covered too.
    await tester.tap(find.text('Add money'));
    await settle(tester);
    await tester.enterText(find.byType(TextField).first, '500');
    await settle(tester);
    await tester.tap(find.textContaining('Add R500.00'));
    await settle(tester);
    // The floating snackbar must stay clear of the FAB, so a quick second tap
    // should still reach Log cash.
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('R500.00'), findsWidgets);

    // Log a taxi fare from the preset.
    await tester.tap(find.text('Log cash'));
    await settle(tester);
    await tester.enterText(find.byType(TextField).first, '35');
    await settle(tester);
    await tester.tap(find.textContaining('Log R35.00 taxi'));
    await settle(tester);

    expect(find.text('R465.00'), findsWidgets);

    // Recent activity sits below the balance, runway and category cards.
    await tester.scrollUntilVisible(
      find.text('−R35.00'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await settle(tester);
    expect(find.text('−R35.00'), findsWidgets);

    final spends = await database.select(database.spends).get();
    expect(spends.single.amountCents, 3500);
    expect(spends.single.category, 'taxi');

    await disposeApp(tester);
  });

  testWidgets('adds a bank account and shows it in the total balance', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('Accounts'));
    await settle(tester);
    await tester.tap(find.byTooltip('Add account'));
    await settle(tester);

    await tester.enterText(find.byType(TextField).first, 'FNB Cheque');
    await tester.enterText(find.byType(TextField).last, '1000');
    await settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Add account'));
    await settle(tester);

    expect(find.text('FNB Cheque'), findsOneWidget);
    expect(find.text('R1,000.00'), findsWidgets);

    await tester.tap(find.text('Home'));
    await settle(tester);
    expect(find.text('Across 2 accounts'), findsOneWidget);
    expect(find.text('R1,000.00'), findsWidgets);

    await disposeApp(tester);
  });

  testWidgets('logs a weekday taxi once and shows it under Recurring', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('Log cash'));
    await settle(tester);
    await tester.enterText(find.byType(TextField).first, '40');
    await tester.tap(find.text('Repeat this spend'));
    await settle(tester);
    expect(find.text('Weekdays'), findsOneWidget);
    await tester.tap(find.textContaining('Log R40.00 taxi'));
    await settle(tester);

    final rules = await database.select(database.recurringRules).get();
    expect(rules.single.amountCents, 4000);
    expect(rules.single.daysOfWeek, '1,2,3,4,5');

    // The bottom navigation opens the recurring rules screen.
    await tester.tap(find.text('Recurring'));
    await settle(tester);
    expect(find.textContaining('Mon–Fri'), findsWidgets);
    expect(find.textContaining('R40.00 taxi'), findsWidgets);

    await disposeApp(tester);
  });
}
