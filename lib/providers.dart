import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/categories.dart';
import 'core/dates.dart';
import 'core/forecast.dart';
import 'core/recurrence.dart';
import 'data/cash_repository.dart';
import 'data/database.dart';
import 'data/recurring_service.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final cashRepositoryProvider = Provider<CashRepository>(
  (ref) => CashRepository(ref.watch(databaseProvider)),
);

final recurringServiceProvider = Provider<RecurringService>(
  (ref) => RecurringService(ref.watch(databaseProvider)),
);

final withdrawalsProvider = StreamProvider<List<Withdrawal>>(
  (ref) => ref.watch(cashRepositoryProvider).watchWithdrawals(),
);

final spendsProvider = StreamProvider<List<Spend>>(
  (ref) => ref.watch(cashRepositoryProvider).watchSpends(),
);

final recurringRulesProvider = StreamProvider<List<RecurringRule>>(
  (ref) => ref.watch(cashRepositoryProvider).watchRecurringRules(),
);

class CashSummary {
  const CashSummary({required this.withdrawnCents, required this.spentCents});

  final int withdrawnCents;
  final int spentCents;

  int get balanceCents => withdrawnCents - spentCents;
}

AsyncValue<T>? _pending<T>(List<AsyncValue<Object?>> values) {
  for (final value in values) {
    if (value.hasError) {
      return AsyncValue<T>.error(
        value.error!,
        value.stackTrace ?? StackTrace.empty,
      );
    }
  }
  if (values.any((value) => value.isLoading)) {
    return AsyncValue<T>.loading();
  }
  return null;
}

final cashSummaryProvider = Provider<AsyncValue<CashSummary>>((ref) {
  final withdrawals = ref.watch(withdrawalsProvider);
  final spends = ref.watch(spendsProvider);

  final pending = _pending<CashSummary>([withdrawals, spends]);
  if (pending != null) return pending;

  final withdrawn = withdrawals.requireValue.fold<int>(
    0,
    (sum, item) => sum + item.amountCents,
  );
  final spent = spends.requireValue.fold<int>(
    0,
    (sum, item) => sum + item.amountCents,
  );

  return AsyncValue.data(
    CashSummary(withdrawnCents: withdrawn, spentCents: spent),
  );
});

final balanceProvider = Provider<AsyncValue<int>>(
  (ref) => ref
      .watch(cashSummaryProvider)
      .whenData((summary) => summary.balanceCents),
);

final forecastProvider = Provider<AsyncValue<ForecastResult>>((ref) {
  final summary = ref.watch(cashSummaryProvider);
  final spends = ref.watch(spendsProvider);
  final rules = ref.watch(recurringRulesProvider);

  final pending = _pending<ForecastResult>([summary, spends, rules]);
  if (pending != null) return pending;

  final now = DateTime.now();
  final recentSpends = spends.requireValue
      .map((spend) => DatedAmount(spend.spentAt, spend.amountCents))
      .toList(growable: false);

  final commitments = rules.requireValue
      .map(
        (rule) => RecurringCommitment(
          amountCents: rule.amountCents,
          weekdays: parseWeekdays(rule.daysOfWeek),
          startsOn: rule.startsOn,
          endsOn: rule.endsOn,
          active: rule.active,
        ),
      )
      .toList(growable: false);

  return AsyncValue.data(
    projectCashRunway(
      balanceCents: summary.requireValue.balanceCents,
      recentSpends: recentSpends,
      upcomingRecurring: upcomingRecurringByDay(commitments, now),
      asOf: now,
    ),
  );
});

/// Category totals for the last seven days, used by the dashboard breakdown.
final weeklyCategoryTotalsProvider =
    Provider<AsyncValue<Map<SpendCategory, int>>>((ref) {
      final spends = ref.watch(spendsProvider);
      final pending = _pending<Map<SpendCategory, int>>([spends]);
      if (pending != null) return pending;

      final cutoff = dateOnly(DateTime.now()).subtract(const Duration(days: 6));
      final totals = <SpendCategory, int>{};

      for (final spend in spends.requireValue) {
        if (dateOnly(spend.spentAt).isBefore(cutoff)) continue;
        final category = SpendCategory.fromName(spend.category);
        totals[category] = (totals[category] ?? 0) + spend.amountCents;
      }

      return AsyncValue.data(totals);
    });
