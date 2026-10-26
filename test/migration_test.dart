import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:zaka/data/database.dart';

void main() {
  test('upgrades a v1 cash-only database without losing entries', () async {
    final raw = sqlite3.openInMemory();
    raw.execute('''
      CREATE TABLE withdrawals (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        amount_cents INTEGER NOT NULL,
        withdrawn_at INTEGER NOT NULL,
        note TEXT,
        created_at INTEGER NOT NULL DEFAULT 0
      );
    ''');
    raw.execute('''
      CREATE TABLE spends (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        amount_cents INTEGER NOT NULL,
        category TEXT NOT NULL,
        spent_at INTEGER NOT NULL,
        note TEXT,
        recurring_rule_id INTEGER,
        created_at INTEGER NOT NULL DEFAULT 0
      );
    ''');
    raw.execute('''
      CREATE TABLE recurring_rules (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        amount_cents INTEGER NOT NULL,
        category TEXT NOT NULL,
        note TEXT,
        days_of_week TEXT NOT NULL,
        starts_on INTEGER NOT NULL,
        ends_on INTEGER,
        active INTEGER NOT NULL DEFAULT 1,
        last_posted_on INTEGER,
        created_at INTEGER NOT NULL DEFAULT 0
      );
    ''');

    final when = DateTime(2026, 3, 1).millisecondsSinceEpoch ~/ 1000;
    raw.execute(
      'INSERT INTO withdrawals (amount_cents, withdrawn_at) VALUES (?, ?)',
      [50000, when],
    );
    raw.execute(
      'INSERT INTO spends (amount_cents, category, spent_at) '
      'VALUES (?, ?, ?)',
      [3500, 'taxi', when],
    );
    raw.execute(
      'INSERT INTO recurring_rules '
      '(amount_cents, category, days_of_week, starts_on) '
      'VALUES (?, ?, ?, ?)',
      [4000, 'taxi', '1,2,3,4,5', when],
    );
    raw.execute('PRAGMA user_version = 1');

    final database = AppDatabase.forTesting(NativeDatabase.opened(raw));
    addTearDown(database.close);

    final accounts = await database.select(database.accounts).get();
    final withdrawals = await database.select(database.withdrawals).get();
    final spends = await database.select(database.spends).get();
    final rules = await database.select(database.recurringRules).get();
    final users = await database.select(database.localUsers).get();

    expect(accounts, hasLength(1));
    expect(users, isEmpty);
    expect(accounts.single.name, 'Cash');
    expect(withdrawals.single.amountCents, 50000);
    expect(withdrawals.single.accountId, accounts.single.id);
    expect(spends.single.amountCents, 3500);
    expect(spends.single.accountId, accounts.single.id);
    expect(rules.single.accountId, accounts.single.id);
  });
}
