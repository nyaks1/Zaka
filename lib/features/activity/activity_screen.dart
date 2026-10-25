import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dates.dart';
import '../../providers.dart';
import '../../widgets/common.dart';
import '../spending/quick_log_screen.dart';
import 'activity_tile.dart';

enum ActivityFilter { all, spends, moneyIn, transfers }

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  ActivityFilter _filter = ActivityFilter.all;

  void _openQuickLog() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const QuickLogScreen()));
  }

  Future<void> _delete(ActivityEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this entry?'),
        content: Text(
          '${entry.title} · ${entry.subtitle}. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final repository = ref.read(cashRepositoryProvider);
    if (entry.transfer != null) {
      await repository.deleteTransfer(entry.transfer!.id);
    } else if (entry.spend != null) {
      await repository.deleteSpend(entry.spend!.id);
    } else {
      await repository.deleteWithdrawal(entry.withdrawal!.id);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Entry deleted.')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spends = ref.watch(spendsProvider).value ?? const [];
    final withdrawals = ref.watch(withdrawalsProvider).value ?? const [];
    final transfers = ref.watch(transfersProvider).value ?? const [];
    final accounts = ref.watch(accountsProvider).value ?? const [];
    final accountNames = {
      for (final account in accounts) account.id: account.name,
    };

    final entries = <ActivityEntry>[
      if (_filter != ActivityFilter.moneyIn &&
          _filter != ActivityFilter.transfers)
        for (final spend in spends)
          ActivityEntry.spend(
            spend,
            accountName: accountNames[spend.accountId],
          ),
      if (_filter != ActivityFilter.spends &&
          _filter != ActivityFilter.transfers)
        for (final withdrawal in withdrawals)
          ActivityEntry.withdrawal(
            withdrawal,
            accountName: accountNames[withdrawal.accountId],
          ),
      if (_filter != ActivityFilter.spends && _filter != ActivityFilter.moneyIn)
        for (final transfer in transfers)
          ActivityEntry.transfer(
            transfer,
            accountName: accountNames[transfer.fromAccountId],
            toAccountName: accountNames[transfer.toAccountId],
          ),
    ]..sort((a, b) => b.date.compareTo(a.date));

    final grouped = <DateTime, List<ActivityEntry>>{};
    for (final entry in entries) {
      grouped.putIfAbsent(dateOnly(entry.date), () => []).add(entry);
    }
    final days = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    final hasAny =
        spends.isNotEmpty || withdrawals.isNotEmpty || transfers.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Activity')),
      floatingActionButton: FloatingActionButton(
        heroTag: 'activity-log-fab',
        onPressed: _openQuickLog,
        tooltip: 'Log cash',
        child: const Icon(Boxicons.bx_plus),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<ActivityFilter>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: ActivityFilter.all, label: Text('All')),
                  ButtonSegment(
                    value: ActivityFilter.spends,
                    label: Text('Spends'),
                  ),
                  ButtonSegment(
                    value: ActivityFilter.moneyIn,
                    label: Text('Money in'),
                  ),
                  ButtonSegment(
                    value: ActivityFilter.transfers,
                    label: Text('Cash moves'),
                  ),
                ],
                selected: {_filter},
                onSelectionChanged: (selection) =>
                    setState(() => _filter = selection.first),
              ),
            ),
          ),
          Expanded(
            child: entries.isEmpty
                ? EmptyState(
                    icon: Boxicons.bx_receipt,
                    title: hasAny
                        ? 'Nothing in this filter'
                        : 'No activity yet',
                    message: hasAny
                        ? 'Try another filter, or log a new cash spend.'
                        : 'Log a cash spend or import a bank statement. It all '
                              'appears here.',
                    action: hasAny
                        ? null
                        : FilledButton.icon(
                            onPressed: _openQuickLog,
                            icon: const Icon(Boxicons.bx_bolt_circle),
                            label: const Text('Log your first spend'),
                          ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                    children: [
                      for (final day in days) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
                          child: Row(
                            children: [
                              Text(
                                dayLabel(day),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${grouped[day]!.length} '
                                '${grouped[day]!.length == 1 ? 'entry' : 'entries'}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Card(
                          child: Column(
                            children: [
                              for (
                                var i = 0;
                                i < grouped[day]!.length;
                                i++
                              ) ...[
                                ActivityTile(
                                  entry: grouped[day]![i],
                                  onDelete: () => _delete(grouped[day]![i]),
                                ),
                                if (i != grouped[day]!.length - 1)
                                  const Divider(indent: 16, endIndent: 16),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
