import 'dates.dart';

class DatedAmount {
  const DatedAmount(this.date, this.amountCents);

  final DateTime date;
  final int amountCents;
}

class ForecastPoint {
  const ForecastPoint(this.date, this.balanceCents);

  final DateTime date;
  final int balanceCents;
}

class ForecastResult {
  const ForecastResult({
    required this.startingBalanceCents,
    required this.dailyBurnCents,
    required this.recurringUpcomingCents,
    required this.daysRemaining,
    required this.runsOutOn,
    required this.points,
    required this.hasHistory,
    required this.hasCommitments,
    required this.horizonDays,
  });

  final int startingBalanceCents;

  /// Average variable spend per day over the lookback window.
  final int dailyBurnCents;

  /// Total of recurring spends due inside the forecast horizon.
  final int recurringUpcomingCents;

  /// Whole days until the projected balance reaches zero. 0 means today.
  /// Null means either there is not enough data or cash lasts past the
  /// horizon.
  final int? daysRemaining;
  final DateTime? runsOutOn;
  final List<ForecastPoint> points;
  final bool hasHistory;
  final bool hasCommitments;
  final int horizonDays;

  /// True when there is something to project from: spend history or a
  /// recurring commitment.
  bool get hasData => hasHistory || hasCommitments;

  /// True when cash lasts beyond the projection window.
  bool get lastsBeyondHorizon => hasData && daysRemaining == null;
}

/// Projects cash day by day:
///
///   tomorrow's cash = today's cash - average daily burn - recurring due
///
/// The burn rate is the average of actual spends over [lookbackDays], which
/// keeps it responsive to a change in habits (e.g. fewer taxis this week).
ForecastResult projectCashRunway({
  required int balanceCents,
  required List<DatedAmount> recentSpends,
  Map<DateTime, int> upcomingRecurring = const {},
  required DateTime asOf,
  int lookbackDays = 14,
  int horizonDays = 60,
}) {
  assert(lookbackDays > 0, 'lookbackDays must be positive');
  assert(horizonDays > 0, 'horizonDays must be positive');

  final today = dateOnly(asOf);
  final windowStart = today.subtract(Duration(days: lookbackDays - 1));

  var windowTotal = 0;
  DateTime? earliest;
  for (final spend in recentSpends) {
    final day = dateOnly(spend.date);
    if (day.isBefore(windowStart) || day.isAfter(today)) continue;
    windowTotal += spend.amountCents;
    if (earliest == null || day.isBefore(earliest)) earliest = day;
  }

  final observedDays = earliest == null
      ? lookbackDays
      : (today.difference(earliest).inDays + 1).clamp(1, lookbackDays);
  final dailyBurn = windowTotal == 0 ? 0 : (windowTotal / observedDays).round();

  final recurringTotal = upcomingRecurring.values.fold<int>(
    0,
    (sum, amount) => sum + amount,
  );
  final hasHistory = windowTotal > 0;
  final hasCommitments = recurringTotal > 0;

  final points = <ForecastPoint>[ForecastPoint(today, balanceCents)];

  int? daysRemaining;
  DateTime? runsOutOn;

  if (balanceCents <= 0) {
    daysRemaining = 0;
    runsOutOn = today;
  } else if (hasHistory || hasCommitments) {
    var projected = balanceCents;
    for (var day = 1; day <= horizonDays; day++) {
      final date = today.add(Duration(days: day));
      final outflow = dailyBurn + (upcomingRecurring[date] ?? 0);
      projected -= outflow;
      points.add(ForecastPoint(date, projected));
      if (projected <= 0 && daysRemaining == null) {
        daysRemaining = day;
        runsOutOn = date;
      }
    }
  }

  return ForecastResult(
    startingBalanceCents: balanceCents,
    dailyBurnCents: dailyBurn,
    recurringUpcomingCents: recurringTotal,
    daysRemaining: daysRemaining,
    runsOutOn: runsOutOn,
    points: points,
    hasHistory: hasHistory,
    hasCommitments: hasCommitments,
    horizonDays: horizonDays,
  );
}
