import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zaka/data/cash_repository.dart';
import 'package:zaka/data/database.dart';
import 'package:zaka/features/advisor/advisor_service.dart';
import 'package:zaka/features/advisor/privacy_service.dart';

void main() {
  late AppDatabase database;
  late CashRepository repository;
  late _FakeStore store;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = CashRepository(database);
    store = _FakeStore();
  });

  tearDown(() async {
    await database.close();
  });

  test('deleteEverything empties every table and clears preferences', () async {
    final cash = (await database.select(database.accounts).get()).single;
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
      importKey: 'salary-key',
    );
    await repository.logSpend(
      amountCents: 3500,
      category: 'taxi',
      spentAt: DateTime(2026, 3, 2),
      accountId: bankId,
      note: "Sipho's tuckshop",
      importKey: 'taxi-key',
    );
    await repository.addTransfer(
      fromAccountId: bankId,
      toAccountId: cash.id,
      amountCents: 20000,
      transferredAt: DateTime(2026, 3, 3),
    );
    await database
        .into(database.recurringRules)
        .insert(
          RecurringRulesCompanion.insert(
            amountCents: 3500,
            category: 'taxi',
            daysOfWeek: '1,2,3,4,5',
            startsOn: DateTime(2026, 3, 2),
            accountId: Value(bankId),
          ),
        );

    await PrivacyService(database, store).deleteEverything();

    expect(await database.select(database.transfers).get(), isEmpty);
    expect(await database.select(database.spends).get(), isEmpty);
    expect(await database.select(database.withdrawals).get(), isEmpty);
    expect(await database.select(database.recurringRules).get(), isEmpty);
    expect(await database.select(database.accounts).get(), isEmpty);
    expect(store.cleared, isTrue);
  });

  test('a blank cash account can be recreated after deletion', () async {
    await PrivacyService(database, store).deleteEverything();
    await database.ensureDefaultAccount();

    final accounts = await database.select(database.accounts).get();
    expect(accounts, hasLength(1));
    expect(accounts.single.name, 'Cash');
    expect(accounts.single.kind, 'cash');
  });
}

class _FakeStore implements AdvisorConsentStore {
  bool cleared = false;

  @override
  Future<bool> hasConsent() async => false;

  @override
  Future<void> setConsent(bool value) async {}

  @override
  Future<String> installToken() async => 'token';

  @override
  Future<void> clear() async {
    cleared = true;
  }
}
