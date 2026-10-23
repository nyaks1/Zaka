import 'package:flutter_test/flutter_test.dart';
import 'package:zaka/core/dates.dart';
import 'package:zaka/core/forecast.dart';

DatedAmount spend(DateTime day, int cents) => DatedAmount(day, cents);

void main() {
  // Friday 23 October 2026.
  final asOf = DateTime(2026, 10, 23, 18);

  group('daily burn rate', () {
    test('averages spends over the days observed', () {
      final result = projectCashRunway(
        balanceCents: 100000,
        recentSpends: [
          spend(DateTime(2026, 10, 20), 4000),
          spend(DateTime(2026, 10, 21), 4000),
          spend(DateTime(2026, 10, 22), 4000),
          spend(DateTime(2026, 10, 23), 4000),
        ],
        asOf: asOf,
      );

      expect(result.hasHistory, isTrue);
      expect(result.dailyBurnCents, 4000);
    });

    test('ignores spends older than the lookback window', () {
      final result = projectCashRunway(
        balanceCents: 100000,
        recentSpends: [
          spend(DateTime(2026, 9, 1), 50000),
          spend(DateTime(2026, 10, 23), 2000),
        ],
        asOf: asOf,
        lookbackDays: 7,
      );

      expect(result.dailyBurnCents, 2000);
    });
  });

  group('runway projection', () {
    test('finds the day cash runs out', () {
      // R1,000 cash, R100/day burn -> empty on day 10.
      final result = projectCashRunway(
        balanceCents: 100000,
        recentSpends: [
          for (var i = 4; i >= 0; i--)
            spend(asOf.subtract(Duration(days: i)), 10000),
        ],
        asOf: asOf,
        lookbackDays: 5,
      );

      expect(result.daysRemaining, 10);
      expect(result.runsOutOn, dateOnly(asOf).add(const Duration(days: 10)));
      expect(result.lastsBeyondHorizon, isFalse);
    });

    test('counts recurring commitments even with no spend history', () {
      final upcoming = <DateTime, int>{
        for (var i = 1; i <= 5; i++)
          dateOnly(asOf).add(Duration(days: i)): 20000,
      };

      final result = projectCashRunway(
        balanceCents: 100000,
        recentSpends: const [],
        upcomingRecurring: upcoming,
        asOf: asOf,
      );

      expect(result.hasHistory, isFalse);
      expect(result.hasCommitments, isTrue);
      expect(result.daysRemaining, 5);
      expect(result.dailyBurnCents, 0);
      expect(result.recurringUpcomingCents, 100000);
    });

    test('reports zero days when cash is already finished', () {
      final result = projectCashRunway(
        balanceCents: -500,
        recentSpends: [spend(asOf, 2000)],
        asOf: asOf,
      );

      expect(result.daysRemaining, 0);
      expect(result.runsOutOn, dateOnly(asOf));
    });

    test('caps at the horizon when cash lasts longer', () {
      final result = projectCashRunway(
        balanceCents: 10000000,
        recentSpends: [spend(asOf, 1000)],
        asOf: asOf,
        horizonDays: 60,
      );

      expect(result.daysRemaining, isNull);
      expect(result.lastsBeyondHorizon, isTrue);
      expect(result.points.length, 61);
    });

    test('has no forecast without history or commitments', () {
      final result = projectCashRunway(
        balanceCents: 50000,
        recentSpends: const [],
        asOf: asOf,
      );

      expect(result.hasData, isFalse);
      expect(result.daysRemaining, isNull);
      expect(result.points.length, 1);
    });

    test('recurring due dates reduce the projected balance', () {
      final tomorrow = dateOnly(asOf).add(const Duration(days: 1));
      final result = projectCashRunway(
        balanceCents: 10000,
        recentSpends: [spend(asOf, 1000)],
        upcomingRecurring: {tomorrow: 5000},
        asOf: asOf,
      );

      expect(result.points.last.balanceCents, lessThan(10000 - 5000));
    });
  });
}
