import 'package:drift/drift.dart';

import '../core/dates.dart';
import '../core/recurrence.dart';
import 'database.dart';

/// Posts due recurring spends the first time the app is opened on or after
/// their scheduled day. This is what lets a commuter set a Mon–Fri taxi once
/// instead of logging it every morning.
class RecurringService {
  RecurringService(this._db);

  final AppDatabase _db;

  /// Returns the number of scheduled spends that were due.
  Future<int> postDue(DateTime asOf) async {
    final today = dateOnly(asOf);

    return _db.transaction(() async {
      final rules = await _db.select(_db.recurringRules).get();
      var posted = 0;

      for (final rule in rules) {
        if (!rule.active) continue;

        final weekdays = parseWeekdays(rule.daysOfWeek);
        if (weekdays.isEmpty) continue;

        final start = dateOnly(rule.startsOn);
        final last = rule.lastPostedOn == null
            ? null
            : dateOnly(rule.lastPostedOn!);
        final after = last ?? start.subtract(const Duration(days: 1));

        final due = occurrenceDates(
          startsOn: start,
          weekdays: weekdays,
          after: after,
          through: today,
          endsOn: rule.endsOn,
        );
        if (due.isEmpty) continue;

        for (final date in due) {
          await _db
              .into(_db.spends)
              .insert(
                SpendsCompanion.insert(
                  amountCents: rule.amountCents,
                  category: rule.category,
                  spentAt: atNoon(date),
                  note: Value(rule.note),
                  accountId: Value(rule.accountId),
                  recurringRuleId: Value(rule.id),
                ),
                mode: InsertMode.insertOrIgnore,
              );
          posted++;
        }

        await (_db.update(_db.recurringRules)
              ..where((table) => table.id.equals(rule.id)))
            .write(RecurringRulesCompanion(lastPostedOn: Value(due.last)));
      }

      return posted;
    });
  }
}
