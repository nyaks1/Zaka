import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zaka/data/cash_repository.dart';
import 'package:zaka/data/database.dart';
import 'package:zaka/data/recurring_service.dart';

void main() {
  late AppDatabase database;
  late CashRepository repository;
  late RecurringService recurring;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = CashRepository(database);
    recurring = RecurringService(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('logs a withdrawal and a spend into the live balance', () async {
    await repository.addWithdrawal(
      amountCents: 50000,
      withdrawnAt: DateTime(2026, 10, 23, 8),
    );
    await repository.logSpend(
      amountCents: 4000,
      category: 'taxi',
      spentAt: DateTime(2026, 10, 23, 9),
    );

    final withdrawals = await database.select(database.withdrawals).get();
    final spends = await database.select(database.spends).get();

    expect(withdrawals.single.amountCents, 50000);
    expect(spends.single.amountCents, 4000);
    expect(spends.single.category, 'taxi');
  });

  test('a Mon–Fri taxi posts once per weekday and never duplicates', () async {
    await repository.logSpend(
      amountCents: 4000,
      category: 'taxi',
      spentAt: DateTime(2026, 10, 19, 7),
      recurrence: const RecurringDraft(weekdays: {1, 2, 3, 4, 5}),
    );

    // Friday evening: Tuesday to Friday are due, Monday was the first entry.
    final posted = await recurring.postDue(DateTime(2026, 10, 23, 20));
    expect(posted, 4);

    var spends = await database.select(database.spends).get();
    expect(spends.length, 5);

    // Running the sync again on the same day must not duplicate anything.
    expect(await recurring.postDue(DateTime(2026, 10, 23, 21)), 0);
    spends = await database.select(database.spends).get();
    expect(spends.length, 5);

    // The following Monday posts exactly one more fare.
    expect(await recurring.postDue(DateTime(2026, 10, 26, 7)), 1);
    spends = await database.select(database.spends).get();
    expect(spends.length, 6);
    expect(
      spends.where((spend) => spend.spentAt.weekday == DateTime.monday).length,
      2, // the initial entry and the next Monday
    );
  });

  test('paused rules do not post', () async {
    await repository.logSpend(
      amountCents: 2500,
      category: 'airtime',
      spentAt: DateTime(2026, 10, 19, 7),
      recurrence: const RecurringDraft(weekdays: {1, 2, 3, 4, 5}),
    );
    final rule = (await database.select(database.recurringRules).get()).single;
    await repository.setRuleActive(rule.id, false);

    expect(await recurring.postDue(DateTime(2026, 10, 23, 20)), 0);
  });
}
