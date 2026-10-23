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

  Stream<List<RecurringRule>> watchRecurringRules() {
    final query = _db.select(_db.recurringRules)
      ..orderBy([(table) => OrderingTerm.desc(table.createdAt)]);
    return query.watch();
  }

  Future<int> addWithdrawal({
    required int amountCents,
    required DateTime withdrawnAt,
    String? note,
  }) {
    return _db
        .into(_db.withdrawals)
        .insert(
          WithdrawalsCompanion.insert(
            amountCents: amountCents,
            withdrawnAt: withdrawnAt,
            note: Value(note),
          ),
        );
  }

  /// Logs a cash spend. When [recurrence] is provided the spend also becomes
  /// a recurring rule, and the rule is marked as posted for today so the
  /// first entry is not duplicated.
  Future<void> logSpend({
    required int amountCents,
    required String category,
    required DateTime spentAt,
    String? note,
    RecurringDraft? recurrence,
  }) async {
    await _db.transaction(() async {
      await _db
          .into(_db.spends)
          .insert(
            SpendsCompanion.insert(
              amountCents: amountCents,
              category: category,
              spentAt: spentAt,
              note: Value(note),
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
                daysOfWeek: encodeWeekdays(recurrence.weekdays),
                startsOn: dateOnly(spentAt),
                endsOn: Value(recurrence.endsOn),
                lastPostedOn: Value(dateOnly(spentAt)),
              ),
            );
      }
    });
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
}
