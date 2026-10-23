import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// Money is stored in cents (integers) everywhere to avoid floating-point
/// rounding errors. R12.50 is stored as 1250.
@DataClassName('Withdrawal')
class Withdrawals extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get amountCents => integer()();
  DateTimeColumn get withdrawnAt => dateTime()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('Spend')
class Spends extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get amountCents => integer()();
  TextColumn get category => text()();
  DateTimeColumn get spentAt => dateTime()();
  TextColumn get note => text().nullable()();

  /// Set when this spend was generated from a recurring rule.
  IntColumn get recurringRuleId => integer().nullable().references(
    RecurringRules,
    #id,
    onDelete: KeyAction.setNull,
  )();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// Makes recurring posting idempotent: a rule can only produce one spend
  /// per posted day, even if the sync runs twice.
  @override
  List<String> get customConstraints => const [
    'UNIQUE (recurring_rule_id, spent_at)',
  ];
}

/// A repeating cash spend, e.g. a taxi fare every Monday to Friday.
@DataClassName('RecurringRule')
class RecurringRules extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get amountCents => integer()();
  TextColumn get category => text()();
  TextColumn get note => text().nullable()();

  /// ISO weekdays, comma separated: 1 = Monday ... 7 = Sunday.
  TextColumn get daysOfWeek => text()();

  DateTimeColumn get startsOn => dateTime()();
  DateTimeColumn get endsOn => dateTime().nullable()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();

  /// The last day this rule generated a spend for. Prevents duplicates.
  DateTimeColumn get lastPostedOn => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Withdrawals, Spends, RecurringRules])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Used by tests with an in-memory executor.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() => driftDatabase(
    name: 'zaka',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  );
}
