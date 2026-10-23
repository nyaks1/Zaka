import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zaka/core/accounting.dart';
import 'package:zaka/data/cash_repository.dart';
import 'package:zaka/data/database.dart';
import 'package:zaka/data/recurring_service.dart';
import 'package:zaka/data/statement_importer.dart';

void main() {
  late AppDatabase database;
  late CashRepository repository;
  late StatementImporter importer;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = CashRepository(database);
    importer = StatementImporter(database, repository);
  });

  tearDown(() async {
    await database.close();
  });

  test('every new database starts with a cash account', () async {
    final accounts = await database.select(database.accounts).get();

    expect(accounts, hasLength(1));
    expect(accounts.single.name, 'Cash');
    expect(accounts.single.kind, 'cash');
  });

  test('transfers move value without counting as income or spending', () async {
    final bankId = await repository.addAccount(
      name: 'FNB Cheque',
      institution: 'FNB',
      kind: 'cheque',
      openingBalanceCents: 100000,
    );

    await repository.addWithdrawal(
      amountCents: 50000,
      withdrawnAt: DateTime(2026, 3, 1),
      accountId: bankId,
      note: 'Salary',
    );
    await repository.logSpend(
      amountCents: 3500,
      category: 'taxi',
      spentAt: DateTime(2026, 3, 2),
      accountId: bankId,
    );
    await repository.addTransfer(
      fromAccountId: bankId,
      toAccountId: (await database.select(database.accounts).get()).first.id,
      amountCents: 20000,
      transferredAt: DateTime(2026, 3, 3),
      note: 'ATM',
    );

    final balances = computeAccountBalances(
      accounts: await database.select(database.accounts).get(),
      withdrawals: await database.select(database.withdrawals).get(),
      spends: await database.select(database.spends).get(),
      transfers: await database.select(database.transfers).get(),
    );

    final bank = balances.firstWhere((balance) => balance.account.id == bankId);
    final cash = balances.firstWhere(
      (balance) => balance.account.kind == 'cash',
    );

    expect(bank.balanceCents, 100000 + 50000 - 3500 - 20000);
    expect(cash.balanceCents, 20000);
    expect(
      balances.fold<int>(0, (sum, balance) => sum + balance.balanceCents),
      146500,
    );
  });

  test(
    'imports a statement, classifies ATM cash, and skips duplicates',
    () async {
      final bankId = await repository.addAccount(
        name: 'FNB Cheque',
        institution: 'FNB',
        kind: 'cheque',
      );
      const csv = '''
Date,Description,Amount,Balance
01/03/2026,SALARY DEPOSIT,28500.00,29000.00
02/03/2026,TAXI - BREE,-35.00,28965.00
03/03/2026,ATM CASH WITHDRAWAL,-500.00,28465.00
''';

      final preview = await importer.preview(accountId: bankId, content: csv);
      expect(preview.newCount, 3);
      expect(preview.incomeCount, 1);
      expect(preview.spendCount, 1);
      expect(preview.transferCount, 1);

      final result = await importer.import(accountId: bankId, content: csv);
      expect(result.imported, 3);
      expect(result.transfers, 1);
      expect(result.skipped, 0);

      final withdrawals = await database.select(database.withdrawals).get();
      final spends = await database.select(database.spends).get();
      final transfers = await database.select(database.transfers).get();

      expect(withdrawals.single.amountCents, 2850000);
      expect(withdrawals.single.accountId, bankId);
      expect(withdrawals.single.source, 'import');

      expect(spends.single.amountCents, 3500);
      expect(spends.single.category, 'taxi');
      expect(spends.single.accountId, bankId);

      expect(transfers.single.amountCents, 50000);
      expect(transfers.single.fromAccountId, bankId);
      expect(transfers.single.toAccountId, isNot(bankId));

      final second = await importer.import(accountId: bankId, content: csv);
      expect(second.imported, 0);
      expect(second.skipped, 3);

      final balances = computeAccountBalances(
        accounts: await database.select(database.accounts).get(),
        withdrawals: await database.select(database.withdrawals).get(),
        spends: await database.select(database.spends).get(),
        transfers: await database.select(database.transfers).get(),
      );
      final bank = balances.firstWhere(
        (balance) => balance.account.id == bankId,
      );
      expect(bank.balanceCents, 2850000 - 3500 - 50000);
    },
  );

  test('the last account cannot be deleted', () async {
    final cash = (await database.select(database.accounts).get()).single;
    expect(await repository.deleteAccount(cash.id), isFalse);
  });

  test('recurring spends post to the account they were logged from', () async {
    final bankId = await repository.addAccount(
      name: 'FNB Cheque',
      institution: 'FNB',
      kind: 'cheque',
    );

    await repository.logSpend(
      amountCents: 4000,
      category: 'taxi',
      spentAt: DateTime(2026, 3, 2, 7),
      accountId: bankId,
      recurrence: const RecurringDraft(weekdays: {1, 2, 3, 4, 5}),
    );

    final rule = (await database.select(database.recurringRules).get()).single;
    expect(rule.accountId, bankId);

    await RecurringService(database).postDue(DateTime(2026, 3, 3, 20));
    final spends = await database.select(database.spends).get();

    expect(spends, hasLength(2));
    expect(spends.every((spend) => spend.accountId == bankId), isTrue);
  });

  test('an account with entries cannot be deleted', () async {
    final bankId = await repository.addAccount(
      name: 'FNB Cheque',
      institution: 'FNB',
      kind: 'cheque',
    );
    await repository.addWithdrawal(
      amountCents: 10000,
      withdrawnAt: DateTime(2026, 3, 1),
      accountId: bankId,
    );

    expect(await repository.deleteAccount(bankId), isFalse);

    final emptyId = await repository.addAccount(
      name: 'Savings',
      institution: 'FNB',
      kind: 'savings',
    );
    expect(await repository.deleteAccount(emptyId), isTrue);
  });
}
