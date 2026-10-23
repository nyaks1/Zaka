import 'dates.dart';

/// A repeating spend, decoupled from the database so it can be unit tested
/// and fed into the forecast without opening SQLite.
class RecurringCommitment {
  const RecurringCommitment({
    required this.amountCents,
    required this.weekdays,
    required this.startsOn,
    this.endsOn,
    this.active = true,
  });

  final int amountCents;

  /// ISO weekdays: 1 = Monday ... 7 = Sunday.
  final Set<int> weekdays;
  final DateTime startsOn;
  final DateTime? endsOn;
  final bool active;
}

Set<int> parseWeekdays(String csv) => csv
    .split(',')
    .map((part) => int.tryParse(part.trim()))
    .whereType<int>()
    .where((day) => day >= 1 && day <= 7)
    .toSet();

String encodeWeekdays(Iterable<int> days) =>
    (days.where((day) => day >= 1 && day <= 7).toSet().toList()..sort()).join(
      ',',
    );

/// Every date this rule is due on, after [after] and up to [through]
/// (both date-only). [after] is exclusive so a posted day is never repeated.
List<DateTime> occurrenceDates({
  required DateTime startsOn,
  required Set<int> weekdays,
  required DateTime after,
  required DateTime through,
  DateTime? endsOn,
}) {
  if (weekdays.isEmpty) return const [];
  final start = dateOnly(startsOn);
  final end = endsOn == null ? null : dateOnly(endsOn);
  final limit = dateOnly(through);
  var cursor = dateOnly(after).add(const Duration(days: 1));
  if (cursor.isBefore(start)) cursor = start;

  final dates = <DateTime>[];
  while (!cursor.isAfter(limit)) {
    if (end != null && cursor.isAfter(end)) break;
    if (weekdays.contains(cursor.weekday)) dates.add(cursor);
    cursor = cursor.add(const Duration(days: 1));
  }
  return dates;
}

/// The first due date strictly after [after], or null if the rule has ended.
DateTime? nextOccurrence({
  required Set<int> weekdays,
  required DateTime startsOn,
  required DateTime after,
  DateTime? endsOn,
}) {
  final horizon = dateOnly(after).add(const Duration(days: 366));
  final dates = occurrenceDates(
    startsOn: startsOn,
    weekdays: weekdays,
    after: after,
    through: horizon,
    endsOn: endsOn,
  );
  return dates.isEmpty ? null : dates.first;
}

/// Total recurring outflow per future day, used by the cash-runway forecast.
Map<DateTime, int> upcomingRecurringByDay(
  Iterable<RecurringCommitment> rules,
  DateTime asOf, {
  int horizonDays = 60,
}) {
  final today = dateOnly(asOf);
  final totals = <DateTime, int>{};
  for (final rule in rules) {
    if (!rule.active) continue;
    final dates = occurrenceDates(
      startsOn: rule.startsOn,
      weekdays: rule.weekdays,
      after: today,
      through: today.add(Duration(days: horizonDays)),
      endsOn: rule.endsOn,
    );
    for (final date in dates) {
      totals[date] = (totals[date] ?? 0) + rule.amountCents;
    }
  }
  return totals;
}
