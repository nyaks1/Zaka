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

  testWidgets('adds a withdrawal and logs a spend with the live balance', (
    tester,
  ) async {
    await pumpApp(tester);

    // Add cash.
    await tester.tap(find.byTooltip('Add ATM withdrawal'));
    await settle(tester);
    await tester.enterText(find.byType(TextField).first, '500');
    await settle(tester);
    await tester.tap(find.textContaining('Add R500.00 cash'));
    await settle(tester);
    // Let the confirmation snackbar finish exiting so it cannot cover the FAB.
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('R500.00'), findsWidgets);

    // Log a taxi fare from the preset.
    await tester.tap(find.text('Log cash'));
    await settle(tester);
    await tester.enterText(find.byType(TextField).first, '35');
    await settle(tester);
    await tester.tap(find.textContaining('Log R35.00 taxi'));
    await settle(tester);

    expect(find.text('R465.00'), findsWidgets);
    expect(find.text('−R35.00'), findsWidgets);

    final spends = await database.select(database.spends).get();
    expect(spends.single.amountCents, 3500);
    expect(spends.single.category, 'taxi');

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
