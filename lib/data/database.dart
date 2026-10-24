import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// Where money lives: the cash in your wallet, a bank account, a savings
/// account, or a credit facility (a negative opening balance means you owe).
@DataClassName('Account')
class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 60)();
  TextColumn get institution => text().withDefault(const Constant(''))();

  /// One of `cash`, `cheque`, `savings`, `credit`.
  TextColumn get kind => text().withDefault(const Constant('cash'))();

  /// The balance before Zaka started tracking this account.
  IntColumn get openingBalanceCents =>
      integer().withDefault(const Constant(0))();

  BoolColumn get archived => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Money added to an account: a salary, a transfer in, or an ATM withdrawal
/// into the cash pot. This is not necessarily income — it is money arriving
/// in a tracked account.
@DataClassName('Withdrawal')
class Withdrawals extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get amountCents => integer()();
  DateTimeColumn get withdrawnAt => dateTime()();
  TextColumn get note => text().nullable()();
  IntColumn get accountId => integer().nullable().references(
    Accounts,
    #id,
    onDelete: KeyAction.setNull,
  )();

  /// Stable key used to skip a statement row that was already imported.
  TextColumn get importKey => text().nullable()();

  /// `manual`, `import`, or `sync` (a future bank feed).
  TextColumn get source => text().withDefault(const Constant('manual'))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<String> get customConstraints => const [
    'UNIQUE (account_id, import_key)',
  ];
}

@DataClassName('Spend')
class Spends extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get amountCents => integer()();
  TextColumn get category => text()();
  DateTimeColumn get spentAt => dateTime()();
  TextColumn get note => text().nullable()();
  IntColumn get accountId => integer().nullable().references(
    Accounts,
    #id,
    onDelete: KeyAction.setNull,
  )();

  /// Set when this spend was generated from a recurring rule.
  IntColumn get recurringRuleId => integer().nullable().references(
    RecurringRules,
    #id,
    onDelete: KeyAction.setNull,
  )();

  TextColumn get importKey => text().nullable()();
  TextColumn get source => text().withDefault(const Constant('manual'))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// Makes recurring posting idempotent: a rule can only produce one spend
  /// per posted day, even if the sync runs twice. The import key makes
  /// statement imports idempotent too.
  @override
  List<String> get customConstraints => const [
    'UNIQUE (recurring_rule_id, spent_at)',
    'UNIQUE (account_id, import_key)',
  ];
}

/// A move between two accounts you already track, such as an ATM withdrawal
/// (bank → cash). Transfers are not spending, so they never affect the
/// income/expense totals.
@DataClassName('Transfer')
class Transfers extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get fromAccountId =>
      integer().references(Accounts, #id, onDelete: KeyAction.cascade)();
  IntColumn get toAccountId =>
      integer().references(Accounts, #id, onDelete: KeyAction.cascade)();
  IntColumn get amountCents => integer()();
  DateTimeColumn get transferredAt => dateTime()();
  TextColumn get note => text().nullable()();
  TextColumn get importKey => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<String> get customConstraints => const [
    'UNIQUE (from_account_id, import_key)',
    'CHECK (from_account_id != to_account_id)',
    'CHECK (amount_cents > 0)',
  ];
}

/// A repeating cash spend, e.g. a taxi fare every Monday to Friday.
@DataClassName('RecurringRule')
class RecurringRules extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get amountCents => integer()();
  TextColumn get category => text()();
  TextColumn get note => text().nullable()();
  IntColumn get accountId => integer().nullable().references(
    Accounts,
    #id,
    onDelete: KeyAction.setNull,
  )();

  /// ISO weekdays, comma separated: 1 = Monday ... 7 = Sunday.
  TextColumn get daysOfWeek => text()();

  DateTimeColumn get startsOn => dateTime()();
  DateTimeColumn get endsOn => dateTime().nullable()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();

  /// The last day this rule generated a spend for. Prevents duplicates.
  DateTimeColumn get lastPostedOn => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(
  tables: [Accounts, Withdrawals, Spends, Transfers, RecurringRules],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Used by tests with an in-memory executor.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(accounts);
        await m.createTable(transfers);
        await m.addColumn(withdrawals, withdrawals.accountId);
        await m.addColumn(withdrawals, withdrawals.importKey);
        await m.addColumn(withdrawals, withdrawals.source);
        await m.addColumn(spends, spends.accountId);
        await m.addColumn(spends, spends.importKey);
        await m.addColumn(spends, spends.source);
        await m.addColumn(recurringRules, recurringRules.accountId);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await ensureDefaultAccount();
    },
  );

  /// Removes every row from every table. Callers that also store settings must
  /// clear those separately; [PrivacyService] does both.
  Future<void> deleteEverything() {
    return transaction(() async {
      await delete(transfers).go();
      await delete(spends).go();
      await delete(withdrawals).go();
      await delete(recurringRules).go();
      await delete(accounts).go();
    });
  }

  /// Best-effort rebuild after a delete-all so SQLite does not keep old rows
  /// in free pages. It cannot run inside the delete transaction.
  Future<void> compact() async {
    try {
      await customStatement('VACUUM');
    } catch (_) {
      // The rows are already gone; compaction is defence in depth.
    }
  }

  /// Every database has a cash account. Existing v1 rows are attached to it
  /// when upgrading, so balances keep working without a manual step.
  Future<void> ensureDefaultAccount() async {
    final count = await customSelect('SELECT COUNT(*) AS count FROM accounts')
        .getSingle();
    if (count.read<int>('count') == 0) {
      await customStatement(
        'INSERT INTO accounts '
        '(name, institution, kind, opening_balance_cents, archived) '
        "VALUES ('Cash', 'Cash', 'cash', 0, 0)",
      );
    }

    const defaultAccount = '(SELECT id FROM accounts ORDER BY id LIMIT 1)';
    await customStatement(
      'UPDATE withdrawals SET account_id = $defaultAccount '
      'WHERE account_id IS NULL',
    );
    await customStatement(
      'UPDATE spends SET account_id = $defaultAccount '
      'WHERE account_id IS NULL',
    );
    await customStatement(
      'UPDATE recurring_rules SET account_id = $defaultAccount '
      'WHERE account_id IS NULL',
    );
  }

  static QueryExecutor _openConnection() => driftDatabase(
    name: 'zaka',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  );
}
