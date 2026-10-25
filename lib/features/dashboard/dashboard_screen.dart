import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/accounting.dart';
import '../../core/categories.dart';
import '../../core/dates.dart';
import '../../core/forecast.dart';
import '../../core/money.dart';
import '../../providers.dart';
import '../../widgets/common.dart';
import '../../widgets/runway_sparkline.dart';
import '../activity/activity_tile.dart';
import '../advisor/advisor_screen.dart';
import '../advisor/advisor_service.dart';
import '../advisor/advisor_summary.dart';
import '../spending/quick_log_screen.dart';
import '../withdrawals/add_withdrawal_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  void _openQuickLog(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const QuickLogScreen()));
  }

  void _openWithdrawal(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AddWithdrawalScreen()),
    );
  }

  void _openAdvisor(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const AdvisorScreen()));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final summary = ref.watch(cashSummaryProvider);
    final forecast = ref.watch(forecastProvider).value;
    final advisorSummary = ref.watch(advisorSummaryProvider);
    final advisorConsent = ref.watch(advisorConsentProvider).value ?? false;
    final categoryTotals =
        ref.watch(weeklyCategoryTotalsProvider).value ??
        const <SpendCategory, int>{};
    final spends = ref.watch(spendsProvider).value ?? const [];
    final withdrawals = ref.watch(withdrawalsProvider).value ?? const [];
    final transfers = ref.watch(transfersProvider).value ?? const [];
    final accountBalances =
        ref.watch(accountBalancesProvider).value ?? const [];
    final accountNames = {
      for (final balance in accountBalances)
        balance.account.id: balance.account.name,
    };

    final entries = <ActivityEntry>[
      for (final spend in spends)
        ActivityEntry.spend(spend, accountName: accountNames[spend.accountId]),
      for (final withdrawal in withdrawals)
        ActivityEntry.withdrawal(
          withdrawal,
          accountName: accountNames[withdrawal.accountId],
        ),
      for (final transfer in transfers)
        ActivityEntry.transfer(
          transfer,
          accountName: accountNames[transfer.fromAccountId],
          toAccountName: accountNames[transfer.toAccountId],
        ),
    ]..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Zaka'),
            Text(
              DateFormat('EEEE · d MMMM').format(DateTime.now()).toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                letterSpacing: 1.0,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Privacy & Ask Zaka',
            onPressed: () => _openAdvisor(context),
            icon: const Icon(Boxicons.bx_cog),
          ),
          IconButton(
            tooltip: 'Add money',
            onPressed: () => _openWithdrawal(context),
            icon: const Icon(Boxicons.bx_plus),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'log-cash-fab',
        onPressed: () => _openQuickLog(context),
        icon: const Icon(Boxicons.bx_bolt_circle),
        label: const Text('Log cash'),
      ),
      body: summary.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Boxicons.bx_error_circle,
                  size: 40,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 12),
                const Text('Could not open your money data'),
                const SizedBox(height: 8),
                Text(
                  '$error',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        data: (cash) => RefreshIndicator(
          onRefresh: () =>
              ref.read(recurringServiceProvider).postDue(DateTime.now()),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            children: [
              _CapitalOverview(
                summary: cash,
                accounts: accountBalances,
                onAddCash: () => _openWithdrawal(context),
              ),
              const SizedBox(height: 14),
              _RunwayTelemetry(forecast: forecast),
              const SizedBox(height: 14),
              _AdvisorDispatch(
                summary: advisorSummary,
                consented: advisorConsent,
                onOpen: () => _openAdvisor(context),
              ),
              const SizedBox(height: 24),
              SectionHeader(
                title: 'Where money went',
                trailing: Text(
                  'Last 7 days',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              _CategoryBreakdown(totals: categoryTotals),
              const SizedBox(height: 24),
              const SectionHeader(title: 'Recent activity'),
              _RecentActivity(entries: entries.take(6).toList()),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Boxicons.bx_lock_alt,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Your money data stays on this device.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Architectural Capital Ledger layout.
/// High contrast, razor 1px borders, zero gradients or shadows.
class _CapitalOverview extends StatelessWidget {
  const _CapitalOverview({
    required this.summary,
    required this.accounts,
    required this.onAddCash,
  });

  final CashSummary summary;
  final List<AccountBalance> accounts;
  final VoidCallback onAddCash;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final border = isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final bg = isDark ? const Color(0xFF09090B) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'TOTAL MONEY',
                      style: theme.textTheme.labelSmall?.copyWith(
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      summary.accountCount == 1
                          ? 'Across 1 account'
                          : 'Across ${summary.accountCount} accounts',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    formatCents(summary.balanceCents),
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 42,
                      letterSpacing: -1.2,
                      height: 1.1,
                    ),
                  ),
                ),
                if (accounts.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final balance in accounts.take(3))
                        _AccountChip(
                          name: balance.account.name,
                          amountCents: balance.balanceCents,
                        ),
                      if (accounts.length > 3)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            '+${accounts.length - 3} more',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: border),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MONEY IN',
                          style: theme.textTheme.labelSmall?.copyWith(
                            letterSpacing: 1.0,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formatCents(summary.moneyInCents),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                VerticalDivider(width: 1, thickness: 1, color: border),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MONEY OUT',
                          style: theme.textTheme.labelSmall?.copyWith(
                            letterSpacing: 1.0,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formatCents(summary.moneyOutCents),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: border),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(42),
                ),
                onPressed: onAddCash,
                icon: const Icon(Boxicons.bx_plus, size: 16),
                label: const Text('Add money'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountChip extends StatelessWidget {
  const _AccountChip({required this.name, required this.amountCents});

  final String name;
  final int amountCents;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final border = isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final bg = isDark ? const Color(0xFF18181B) : const Color(0xFFF4F4F5);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatCents(amountCents),
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

/// Asymmetric Runway Telemetry layout.
/// Displays days remaining, daily burn rate, commitments, and crisp sparkline.
class _RunwayTelemetry extends StatelessWidget {
  const _RunwayTelemetry({required this.forecast});

  final ForecastResult? forecast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final border = isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final bg = isDark ? const Color(0xFF09090B) : Colors.white;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Boxicons.bx_line_chart,
                size: 18,
                color: theme.colorScheme.onSurface,
              ),
              const SizedBox(width: 8),
              Text(
                'MONEY RUNWAY',
                style: theme.textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              if (forecast != null && forecast!.hasData)
                _TagBadge(
                  label: forecast!.lastsBeyondHorizon
                      ? '${forecast!.horizonDays}+ DAYS'
                      : '${forecast!.daysRemaining} DAYS',
                  alert:
                      forecast!.daysRemaining != null &&
                      forecast!.daysRemaining! <= 7,
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (forecast == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (!forecast!.hasData)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                'Log a spend or set a repeating fare and Zaka will show '
                'the day your money runs out.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            )
          else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  forecast!.daysRemaining == null
                      ? '${forecast!.horizonDays}+'
                      : '${forecast!.daysRemaining}',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1.0,
                    height: 1.0,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    forecast!.daysRemaining == 1
                        ? 'day of money left'
                        : 'days of money left',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _runwayMessage(forecast!),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            RunwaySparkline(
              points: forecast!.points.take(31).toList(growable: false),
              color:
                  forecast!.daysRemaining != null &&
                      forecast!.daysRemaining! <= 7
                  ? theme.colorScheme.error
                  : theme.colorScheme.onSurface,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _TelemetryChip(
                  icon: Boxicons.bxs_flame,
                  label: '${formatCents(forecast!.dailyBurnCents)} / day',
                ),
                if (forecast!.hasCommitments)
                  _TelemetryChip(
                    icon: Boxicons.bx_repeat,
                    label:
                        '${formatCents(forecast!.recurringUpcomingCents)} scheduled',
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _runwayMessage(ForecastResult result) {
    if (result.daysRemaining == 0) {
      return 'Your balance is finished. Add money to keep going.';
    }
    if (result.runsOutOn != null) {
      return 'At this burn rate, money runs out on '
          '${longDate(result.runsOutOn!)}.';
    }
    return 'At ${formatCents(result.dailyBurnCents)} a day, your money lasts '
        'beyond the ${result.horizonDays}-day forecast.';
  }
}

/// Editorial Intelligence Dispatch layout.
/// Features a crisp 3px accent border on the left, clear typography, and discrete actions.
class _AdvisorDispatch extends StatelessWidget {
  const _AdvisorDispatch({
    required this.summary,
    required this.consented,
    required this.onOpen,
  });

  final AsyncValue<AdvisorSummary> summary;
  final bool consented;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final border = isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final bg = isDark ? const Color(0xFF09090B) : Colors.white;
    final fg = theme.colorScheme.onSurface;

    final tip = summary.value == null
        ? 'Log a few spends and Zaka will turn them into a plain-language '
              'cash-flow tip.'
        : offlineTip(summary.value!);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border, width: 1),
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Boxicons.bx_star, size: 18, color: fg),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ask Zaka',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _TagBadge(
                label: consented ? 'ONLINE' : 'OFFLINE',
                alert: false,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            tip,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
              color: fg,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Tips, not financial advice.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              TextButton(
                onPressed: onOpen,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  minimumSize: const Size(0, 36),
                ),
                child: Text(consented ? 'Get tips' : 'Set up'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TagBadge extends StatelessWidget {
  const _TagBadge({required this.label, required this.alert});

  final String label;
  final bool alert;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final color = alert
        ? theme.colorScheme.error
        : (isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A));
    final borderColor = alert
        ? theme.colorScheme.error
        : (isDark ? const Color(0xFF3F3F46) : const Color(0xFFD4D4D8));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _TelemetryChip extends StatelessWidget {
  const _TelemetryChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final border = isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final bg = isDark ? const Color(0xFF141416) : const Color(0xFFF4F4F5);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  const _CategoryBreakdown({required this.totals});

  final Map<SpendCategory, int> totals;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final entries = totals.entries.where((entry) => entry.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (entries.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Text(
            'No spends in the last 7 days. Logged and imported spends show '
            'up here.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ),
      );
    }

    final maxAmount = entries.first.value;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
        child: Column(
          children: [
            for (final entry in entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    CategoryAvatar(category: entry.key, size: 36),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  entry.key.label,
                                  style: theme.textTheme.titleSmall,
                                ),
                              ),
                              Text(
                                formatCents(entry.value),
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: entry.value / maxAmount,
                              minHeight: 4,
                              backgroundColor: isDark
                                  ? const Color(0xFF27272A)
                                  : const Color(0xFFE4E4E7),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RecentActivity extends StatelessWidget {
  const _RecentActivity({required this.entries});

  final List<ActivityEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (entries.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Text(
            'Nothing yet. Tap “Log cash” whenever you spend, or import a bank '
            'statement from Accounts.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: [
          for (var i = 0; i < entries.length; i++) ...[
            ActivityTile(entry: entries[i]),
            if (i != entries.length - 1)
              const Divider(indent: 16, endIndent: 16),
          ],
        ],
      ),
    );
  }
}
