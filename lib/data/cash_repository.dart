import 'package:drift/drift.dart';

import '../core/dates.dart';
import '../core/recurrence.dart';
import 'database.dart';

/// Optional repeat settings when logging a spend for the first time.
class RecurringDraft {
  const RecurringDraft({required this.weekdays, this.endsOn});

  final Set<int> weekdays;
  final DateTime? endsOn;
}

class CashRepository {
  CashRepository(this._db);

  final AppDatabase _db;

  Stream<List<Account>> watchAccounts() {
    final query = _db.select(_db.accounts)
      ..orderBy([(table) => OrderingTerm.asc(table.createdAt)]);
    return query.watch();
  }

  Stream<List<Withdrawal>> watchWithdrawals() {
    final query = _db.select(_db.withdrawals)
      ..orderBy([(table) => OrderingTerm.desc(table.withdrawnAt)]);
    return query.watch();
  }

  Stream<List<Spend>> watchSpends() {
    final query = _db.select(_db.spends)
      ..orderBy([(table) => OrderingTerm.desc(table.spentAt)]);
    return query.watch();
  }

  Stream<List<Transfer>> watchTransfers() {
    final query = _db.select(_db.transfers)
      ..orderBy([(table) => OrderingTerm.desc(table.transferredAt)]);
    return query.watch();
  }

  Stream<List<RecurringRule>> watchRecurringRules() {
    final query = _db.select(_db.recurringRules)
      ..orderBy([(table) => OrderingTerm.desc(table.createdAt)]);
    return query.watch();
  }

  Future<int> addAccount({
    required String name,
    required String institution,
    required String kind,
    int openingBalanceCents = 0,
  }) {
    return _db
        .into(_db.accounts)
        .insert(
          AccountsCompanion.insert(
            name: name.trim(),
            institution: Value(institution.trim()),
            kind: Value(kind),
            openingBalanceCents: Value(openingBalanceCents),
          ),
        );
  }

  /// Returns false when this is the last account, or when the account still
  /// has entries or rules attached.
  Future<bool> deleteAccount(int accountId) async {
    final allAccounts = await _db.select(_db.accounts).get();
    if (allAccounts.length <= 1) return false;

    final withdrawal =
        await (_db.select(_db.withdrawals)
              ..where((table) => table.accountId.equals(accountId))
              ..limit(1))
            .getSingleOrNull();
    final spend =
        await (_db.select(_db.spends)
              ..where((table) => table.accountId.equals(accountId))
              ..limit(1))
            .getSingleOrNull();
    final transfer =
        await (_db.select(_db.transfers)
              ..where(
                (table) =>
                    table.fromAccountId.equals(accountId) |
                    table.toAccountId.equals(accountId),
              )
              ..limit(1))
            .getSingleOrNull();
    final rule =
        await (_db.select(_db.recurringRules)
              ..where((table) => table.accountId.equals(accountId))
              ..limit(1))
            .getSingleOrNull();

    if (withdrawal != null ||
        spend != null ||
        transfer != null ||
        rule != null) {
      return false;
    }

    await (_db.delete(
      _db.accounts,
    )..where((table) => table.id.equals(accountId))).go();
    return true;
  }

  Future<int> addWithdrawal({
    required int amountCents,
    required DateTime withdrawnAt,
    int? accountId,
    String? note,
    String? importKey,
    String source = 'manual',
  }) async {
    final account = accountId ?? await _defaultAccountId();
    return _db
        .into(_db.withdrawals)
        .insert(
          WithdrawalsCompanion.insert(
            amountCents: amountCents,
            withdrawnAt: withdrawnAt,
            note: Value(note),
            accountId: Value(account),
            importKey: Value(importKey),
            source: Value(source),
          ),
        );
  }

  /// Logs a spend. When [recurrence] is provided the spend also becomes
  /// a recurring rule, and the rule is marked as posted for today so the
  /// first entry is not duplicated.
  Future<void> logSpend({
    required int amountCents,
    required String category,
    required DateTime spentAt,
    int? accountId,
    String? note,
    String? importKey,
    String source = 'manual',
    RecurringDraft? recurrence,
  }) async {
    final account = accountId ?? await _defaultAccountId();

    await _db.transaction(() async {
      await _db
          .into(_db.spends)
          .insert(
            SpendsCompanion.insert(
              amountCents: amountCents,
              category: category,
              spentAt: spentAt,
              note: Value(note),
              accountId: Value(account),
              importKey: Value(importKey),
              source: Value(source),
            ),
          );

      if (recurrence != null && recurrence.weekdays.isNotEmpty) {
        await _db
            .into(_db.recurringRules)
            .insert(
              RecurringRulesCompanion.insert(
                amountCents: amountCents,
                category: category,
                note: Value(note),
                accountId: Value(account),
                daysOfWeek: encodeWeekdays(recurrence.weekdays),
                startsOn: dateOnly(spentAt),
                endsOn: Value(recurrence.endsOn),
                lastPostedOn: Value(dateOnly(spentAt)),
              ),
            );
      }
    });
  }

  Future<int> addTransfer({
    required int fromAccountId,
    required int toAccountId,
    required int amountCents,
    required DateTime transferredAt,
    String? note,
    String? importKey,
  }) {
    return _db
        .into(_db.transfers)
        .insert(
          TransfersCompanion.insert(
            fromAccountId: fromAccountId,
            toAccountId: toAccountId,
            amountCents: amountCents,
            transferredAt: transferredAt,
            note: Value(note),
            importKey: Value(importKey),
          ),
        );
  }

  Future<void> setRuleActive(int ruleId, bool active) {
    // Resuming should start from today, not back-fill the days the rule was
    // paused for.
    return (_db.update(
      _db.recurringRules,
    )..where((table) => table.id.equals(ruleId))).write(
      RecurringRulesCompanion(
        active: Value(active),
        lastPostedOn: active
            ? Value(dateOnly(DateTime.now()))
            : const Value.absent(),
      ),
    );
  }

  Future<void> deleteRule(int ruleId) {
    return (_db.delete(
      _db.recurringRules,
    )..where((table) => table.id.equals(ruleId))).go();
  }

  Future<void> deleteSpend(int spendId) {
    return (_db.delete(
      _db.spends,
    )..where((table) => table.id.equals(spendId))).go();
  }

  Future<void> deleteWithdrawal(int withdrawalId) {
    return (_db.delete(
      _db.withdrawals,
    )..where((table) => table.id.equals(withdrawalId))).go();
  }

  Future<void> deleteTransfer(int transferId) {
    return (_db.delete(
      _db.transfers,
    )..where((table) => table.id.equals(transferId))).go();
  }

  Future<int> _defaultAccountId() async {
    final account =
        await (_db.select(_db.accounts)
              ..orderBy([(table) => OrderingTerm.asc(table.id)])
              ..limit(1))
            .getSingleOrNull();
    if (account == null) {
      throw StateError('No accounts exist. Add an account first.');
    }
    return account.id;
  }
}
