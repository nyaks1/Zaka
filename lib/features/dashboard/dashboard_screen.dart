import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/categories.dart';
import '../../core/dates.dart';
import '../../core/forecast.dart';
import '../../core/money.dart';
import '../../providers.dart';
import '../../widgets/common.dart';
import '../../widgets/runway_sparkline.dart';
import '../activity/activity_tile.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final summary = ref.watch(cashSummaryProvider);
    final forecast = ref.watch(forecastProvider).value;
    final categoryTotals =
        ref.watch(weeklyCategoryTotalsProvider).value ??
        const <SpendCategory, int>{};
    final spends = ref.watch(spendsProvider).value ?? const [];
    final withdrawals = ref.watch(withdrawalsProvider).value ?? const [];

    final entries = <ActivityEntry>[
      for (final spend in spends) ActivityEntry.spend(spend),
      for (final withdrawal in withdrawals)
        ActivityEntry.withdrawal(withdrawal),
    ]..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Zaka'),
            Text(
              DateFormat('EEEE d MMMM').format(DateTime.now()),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton.filledTonal(
            tooltip: 'Add ATM withdrawal',
            onPressed: () => _openWithdrawal(context),
            icon: const Icon(Icons.add_card_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'log-cash-fab',
        onPressed: () => _openQuickLog(context),
        icon: const Icon(Icons.bolt_rounded),
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
                  Icons.error_outline_rounded,
                  size: 42,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 12),
                const Text('Could not open your cash data'),
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
              _BalanceCard(
                summary: cash,
                onAddCash: () => _openWithdrawal(context),
              ),
              const SizedBox(height: 16),
              _RunwayCard(forecast: forecast),
              const SizedBox(height: 26),
              SectionHeader(
                title: 'Where cash went',
                trailing: Text(
                  'Last 7 days',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              _CategoryBreakdown(totals: categoryTotals),
              const SizedBox(height: 26),
              const SectionHeader(title: 'Recent activity'),
              _RecentActivity(entries: entries.take(6).toList()),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Your cash data stays on this device.',
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

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.summary, required this.onAddCash});

  final CashSummary summary;
  final VoidCallback onAddCash;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spentRatio = summary.withdrawnCents == 0
        ? 0.0
        : (summary.spentCents / summary.withdrawnCents).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF127A5A), Color(0xFF074434)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF074434).withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'CASH ON HAND',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white70,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.white70,
                size: 22,
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
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 46,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _BalanceStat(
                label: 'Withdrawn',
                value: formatCents(summary.withdrawnCents),
              ),
              const SizedBox(width: 28),
              _BalanceStat(
                label: 'Spent',
                value: formatCents(summary.spentCents),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: spentRatio,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.18),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            summary.withdrawnCents == 0
                ? 'Add the cash in your wallet to start the countdown.'
                : '${(spentRatio * 100).round()}% of withdrawn cash spent',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
          if (summary.withdrawnCents == 0) ...[
            const SizedBox(height: 6),
            TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
              onPressed: onAddCash,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add cash'),
            ),
          ],
        ],
      ),
    );
  }
}

class _BalanceStat extends StatelessWidget {
  const _BalanceStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(color: Colors.white60),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _RunwayCard extends StatelessWidget {
  const _RunwayCard({required this.forecast});

  final ForecastResult? forecast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.speed_rounded,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text('Cash runway', style: theme.textTheme.titleMedium),
                const Spacer(),
                if (forecast != null && forecast!.hasData)
                  _Pill(
                    label: forecast!.lastsBeyondHorizon
                        ? '${forecast!.horizonDays}+ days'
                        : '${forecast!.daysRemaining} days',
                    color:
                        forecast!.daysRemaining != null &&
                            forecast!.daysRemaining! <= 7
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                  ),
              ],
            ),
            const SizedBox(height: 14),
            if (forecast == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (!forecast!.hasData)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'Log a spend or set a repeating fare and Zaka will show '
                  'the day your cash runs out.',
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
                      fontSize: 38,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      forecast!.daysRemaining == 1
                          ? 'day of cash left'
                          : 'days of cash left',
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
              const SizedBox(height: 14),
              RunwaySparkline(
                points: forecast!.points.take(31).toList(growable: false),
                color:
                    forecast!.daysRemaining != null &&
                        forecast!.daysRemaining! <= 7
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary,
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(
                    icon: Icons.local_fire_department_rounded,
                    label: '${formatCents(forecast!.dailyBurnCents)}/day',
                  ),
                  if (forecast!.hasCommitments)
                    _InfoChip(
                      icon: Icons.repeat_rounded,
                      label:
                          '${formatCents(forecast!.recurringUpcomingCents)} scheduled',
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _runwayMessage(ForecastResult result) {
    if (result.daysRemaining == 0) {
      return 'Your cash is finished. Add a withdrawal to keep going.';
    }
    if (result.runsOutOn != null) {
      return 'At this burn rate, cash runs out on '
          '${longDate(result.runsOutOn!)}.';
    }
    return 'At ${formatCents(result.dailyBurnCents)} a day, your cash lasts '
        'beyond the ${result.horizonDays}-day forecast.';
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 5),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
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
    final entries = totals.entries.where((entry) => entry.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (entries.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'No spends in the last 7 days. Your first log will show up here.',
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
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 6),
        child: Column(
          children: [
            for (final entry in entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    CategoryAvatar(category: entry.key, size: 38),
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
                                style: theme.textTheme.labelLarge,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: LinearProgressIndicator(
                              value: entry.value / maxAmount,
                              minHeight: 6,
                              backgroundColor: entry.key.color.withValues(
                                alpha: 0.12,
                              ),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                entry.key.color,
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
          padding: const EdgeInsets.all(20),
          child: Text(
            'Nothing logged yet. Tap “Log cash” whenever you spend.',
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
