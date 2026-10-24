import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'core/accounting.dart';
import 'core/categories.dart';
import 'core/dates.dart';
import 'core/forecast.dart';
import 'core/recurrence.dart';
import 'data/cash_repository.dart';
import 'data/database.dart';
import 'data/recurring_service.dart';
import 'data/statement_importer.dart';
import 'features/advisor/advisor_service.dart';
import 'features/advisor/advisor_summary.dart';
import 'features/advisor/privacy_service.dart';

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

final statementImporterProvider = Provider<StatementImporter>(
  (ref) => StatementImporter(
    ref.watch(databaseProvider),
    ref.watch(cashRepositoryProvider),
  ),
);

final accountsProvider = StreamProvider<List<Account>>(
  (ref) => ref.watch(cashRepositoryProvider).watchAccounts(),
);

final withdrawalsProvider = StreamProvider<List<Withdrawal>>(
  (ref) => ref.watch(cashRepositoryProvider).watchWithdrawals(),
);

final spendsProvider = StreamProvider<List<Spend>>(
  (ref) => ref.watch(cashRepositoryProvider).watchSpends(),
);

final transfersProvider = StreamProvider<List<Transfer>>(
  (ref) => ref.watch(cashRepositoryProvider).watchTransfers(),
);

final recurringRulesProvider = StreamProvider<List<RecurringRule>>(
  (ref) => ref.watch(cashRepositoryProvider).watchRecurringRules(),
);

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

final accountBalancesProvider = Provider<AsyncValue<List<AccountBalance>>>((
  ref,
) {
  final accounts = ref.watch(accountsProvider);
  final withdrawals = ref.watch(withdrawalsProvider);
  final spends = ref.watch(spendsProvider);
  final transfers = ref.watch(transfersProvider);

  final pending = _pending<List<AccountBalance>>([
    accounts,
    withdrawals,
    spends,
    transfers,
  ]);
  if (pending != null) return pending;

  return AsyncValue.data(
    computeAccountBalances(
      accounts: accounts.requireValue,
      withdrawals: withdrawals.requireValue,
      spends: spends.requireValue,
      transfers: transfers.requireValue,
    ),
  );
});

final totalBalanceProvider = Provider<AsyncValue<int>>(
  (ref) => ref
      .watch(accountBalancesProvider)
      .whenData(
        (balances) =>
            balances.fold<int>(0, (sum, balance) => sum + balance.balanceCents),
      ),
);

class CashSummary {
  const CashSummary({
    required this.balanceCents,
    required this.moneyInCents,
    required this.moneyOutCents,
    required this.accountCount,
  });

  final int balanceCents;
  final int moneyInCents;
  final int moneyOutCents;
  final int accountCount;
}

final cashSummaryProvider = Provider<AsyncValue<CashSummary>>((ref) {
  final balances = ref.watch(accountBalancesProvider);
  final withdrawals = ref.watch(withdrawalsProvider);
  final spends = ref.watch(spendsProvider);

  final pending = _pending<CashSummary>([balances, withdrawals, spends]);
  if (pending != null) return pending;

  final moneyIn = withdrawals.requireValue.fold<int>(
    0,
    (sum, item) => sum + item.amountCents,
  );
  final moneyOut = spends.requireValue.fold<int>(
    0,
    (sum, item) => sum + item.amountCents,
  );

  return AsyncValue.data(
    CashSummary(
      balanceCents: balances.requireValue.fold<int>(
        0,
        (sum, balance) => sum + balance.balanceCents,
      ),
      moneyInCents: moneyIn,
      moneyOutCents: moneyOut,
      accountCount: balances.requireValue.length,
    ),
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

final advisorPreferencesProvider = Provider<AdvisorConsentStore>(
  (ref) => AdvisorPreferences(),
);

final advisorConsentProvider = FutureProvider<bool>(
  (ref) => ref.watch(advisorPreferencesProvider).hasConsent(),
);

final advisorServiceProvider = Provider<AdvisorService>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return AdvisorService(
    ref.watch(advisorPreferencesProvider),
    client,
    const String.fromEnvironment('ADVISOR_PROXY_URL'),
  );
});

final advisorSummaryProvider = Provider<AsyncValue<AdvisorSummary>>((ref) {
  final forecast = ref.watch(forecastProvider);
  final spends = ref.watch(spendsProvider);

  final pending = _pending<AdvisorSummary>([forecast, spends]);
  if (pending != null) return pending;

  return AsyncValue.data(
    AdvisorSummary.build(
      forecast.requireValue,
      spends.requireValue,
      DateTime.now(),
    ),
  );
});

final privacyServiceProvider = Provider<PrivacyService>(
  (ref) => PrivacyService(
    ref.watch(databaseProvider),
    ref.watch(advisorPreferencesProvider),
  ),
);
