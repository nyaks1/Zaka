import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zaka/core/accounting.dart';
import 'package:zaka/core/forecast.dart';
import 'package:zaka/data/cash_repository.dart';
import 'package:zaka/data/database.dart';
import 'package:zaka/data/sample_data.dart';
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

  test('sample data uses the R900 piece-job payment, not a salary', () async {
    final csv = buildSampleStatementCsv(DateTime(2026, 10, 26));

    expect(csv, contains('PIECE JOB PAYMENT,900.00,900.00'));
    expect(csv, isNot(contains('SALARY')));
    expect(csv, isNot(contains('18500')));
  });

  test('sample import leaves about five days of runway', () async {
    final today = DateTime(2026, 10, 26);
    final bankId = await repository.addAccount(
      name: 'FNB Cheque',
      institution: 'FNB',
      kind: 'cheque',
    );

    final result = await importer.import(
      accountId: bankId,
      content: buildSampleStatementCsv(today),
    );

    expect(result.imported, 4);
    expect(result.transfers, 1);

    final balances = computeAccountBalances(
      accounts: await database.select(database.accounts).get(),
      withdrawals: await database.select(database.withdrawals).get(),
      spends: await database.select(database.spends).get(),
      transfers: await database.select(database.transfers).get(),
    );
    final total = balances.fold<int>(
      0,
      (sum, balance) => sum + balance.balanceCents,
    );

    // R125 left in the bank + R500 withdrawn into the cash wallet.
    expect(total, 62500);

    final spends = await database.select(database.spends).get();
    final forecast = projectCashRunway(
      balanceCents: total,
      recentSpends: [
        for (final spend in spends)
          DatedAmount(spend.spentAt, spend.amountCents),
      ],
      asOf: today,
    );

    expect(forecast.dailyBurnCents, 13750);
    expect(forecast.daysRemaining, 5);
  });
}
