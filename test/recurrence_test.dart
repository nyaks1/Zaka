import 'package:flutter_test/flutter_test.dart';
import 'package:zaka/core/dates.dart';
import 'package:zaka/core/recurrence.dart';

void main() {
  // Monday 19 October 2026.
  final monday = DateTime(2026, 10, 19);

  group('occurrenceDates', () {
    test('expands a Monday to Friday taxi across a weekend', () {
      final dates = occurrenceDates(
        startsOn: monday,
        weekdays: const {1, 2, 3, 4, 5},
        after: monday.subtract(const Duration(days: 1)),
        through: DateTime(2026, 10, 26),
      );

      expect(dates, [
        DateTime(2026, 10, 19),
        DateTime(2026, 10, 20),
        DateTime(2026, 10, 21),
        DateTime(2026, 10, 22),
        DateTime(2026, 10, 23),
        DateTime(2026, 10, 26),
      ]);
    });

    test('never repeats the day after which it starts', () {
      final dates = occurrenceDates(
        startsOn: monday,
        weekdays: const {1, 2, 3, 4, 5},
        after: DateTime(2026, 10, 21),
        through: DateTime(2026, 10, 23),
      );

      expect(dates, [DateTime(2026, 10, 22), DateTime(2026, 10, 23)]);
    });

    test('stops at the end date', () {
      final dates = occurrenceDates(
        startsOn: monday,
        weekdays: const {1, 2, 3, 4, 5},
        after: monday.subtract(const Duration(days: 1)),
        through: DateTime(2026, 10, 30),
        endsOn: DateTime(2026, 10, 21),
      );

      expect(dates, [
        DateTime(2026, 10, 19),
        DateTime(2026, 10, 20),
        DateTime(2026, 10, 21),
      ]);
    });

    test('returns nothing for an empty weekday set', () {
      final dates = occurrenceDates(
        startsOn: monday,
        weekdays: const {},
        after: monday,
        through: DateTime(2026, 10, 30),
      );

      expect(dates, isEmpty);
    });
  });

  group('weekday encoding', () {
    test('round-trips a set of weekdays', () {
      expect(parseWeekdays(encodeWeekdays({5, 1, 3})), {1, 3, 5});
    });

    test('ignores invalid values', () {
      expect(parseWeekdays('1,9,x,7'), {1, 7});
    });

    test('describes common patterns', () {
      expect(describeWeekdays({1, 2, 3, 4, 5}), 'Mon–Fri');
      expect(describeWeekdays({6, 7}), 'Sat–Sun');
      expect(describeWeekdays({1, 2, 3, 4, 5, 6, 7}), 'Every day');
      expect(describeWeekdays({1, 3, 5}), 'Mon, Wed, Fri');
    });
  });

  group('nextOccurrence', () {
    test('moves from Friday to the next Monday', () {
      final next = nextOccurrence(
        weekdays: const {1, 2, 3, 4, 5},
        startsOn: monday,
        after: DateTime(2026, 10, 23),
      );

      expect(next, DateTime(2026, 10, 26));
    });

    test('returns null after the end date', () {
      final next = nextOccurrence(
        weekdays: const {1, 2, 3, 4, 5},
        startsOn: monday,
        after: DateTime(2026, 10, 23),
        endsOn: DateTime(2026, 10, 23),
      );

      expect(next, isNull);
    });
  });

  group('upcomingRecurringByDay', () {
    test('groups due amounts inside the horizon', () {
      final totals = upcomingRecurringByDay(
        [
          RecurringCommitment(
            amountCents: 4000,
            weekdays: const {1, 2, 3, 4, 5},
            startsOn: _octoberFirst,
          ),
        ],
        DateTime(2026, 10, 23, 18),
        horizonDays: 4,
      );

      // Fri 23 is today, so the next dues are Mon 26 and Tue 27.
      expect(totals, {
        DateTime(2026, 10, 26): 4000,
        DateTime(2026, 10, 27): 4000,
      });
    });

    test('ignores paused rules', () {
      final totals = upcomingRecurringByDay([
        RecurringCommitment(
          amountCents: 4000,
          weekdays: const {1, 2, 3, 4, 5},
          startsOn: _octoberFirst,
          active: false,
        ),
      ], DateTime(2026, 10, 23));

      expect(totals, isEmpty);
    });
  });
}

final DateTime _octoberFirst = DateTime(2026, 10, 1);
