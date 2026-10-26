import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zaka/data/cash_repository.dart';
import 'package:zaka/data/database.dart';
import 'package:zaka/features/advisor/advisor_service.dart';
import 'package:zaka/features/advisor/privacy_service.dart';
import 'package:zaka/features/auth/auth_service.dart';
import 'package:zaka/features/security/app_lock_service.dart';

void main() {
  late AppDatabase database;
  late CashRepository repository;
  late _FakeStore store;
  late AuthService auth;
  late AppLockService appLock;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = CashRepository(database);
    store = _FakeStore();
    auth = AuthService(database, pbkdf2Iterations: 1);
    appLock = AppLockService();
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

    final user = await auth.register(
      email: 'tester@zaka.test',
      password: 'correct horse battery',
      displayName: 'Tester',
    );
    expect(user.email, 'tester@zaka.test');
    await appLock.setPin('1234');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt(AuthService.currentUserKey) != null, isTrue);

    await PrivacyService(database, store, auth, appLock).deleteEverything();

    expect(await database.select(database.transfers).get(), isEmpty);
    expect(await database.select(database.spends).get(), isEmpty);
    expect(await database.select(database.withdrawals).get(), isEmpty);
    expect(await database.select(database.recurringRules).get(), isEmpty);
    expect(await database.select(database.accounts).get(), isEmpty);
    expect(await database.select(database.localUsers).get(), isEmpty);
    expect(await appLock.hasPin(), isFalse);
    expect(prefs.getInt(AuthService.currentUserKey) == null, isTrue);
    expect(store.cleared, isTrue);
  });

  test('a blank cash account can be recreated after deletion', () async {
    await PrivacyService(database, store, auth, appLock).deleteEverything();
    await database.ensureDefaultAccount();

    final accounts = await database.select(database.accounts).get();
    expect(accounts, hasLength(1));
    expect(accounts.single.name, 'Cash');
    expect(accounts.single.kind, 'cash');
  });

  test('recreating the cash account updates account streams', () async {
    final events = <List<Account>>[];
    final subscription = database.select(database.accounts).watch().listen(
      events.add,
    );
    await Future<void>.delayed(const Duration(milliseconds: 10));

    await PrivacyService(database, store, auth, appLock).deleteEverything();
    await database.ensureDefaultAccount();
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(events.last, hasLength(1));
    expect(events.last.single.name, 'Cash');
    await subscription.cancel();
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
