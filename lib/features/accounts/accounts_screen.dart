import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/accounting.dart';
import '../../core/money.dart';
import '../../providers.dart';
import '../../widgets/common.dart';
import 'add_account_screen.dart';
import 'import_statement_screen.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  void _openAdd(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const AddAccountScreen()));
  }

  void _openImport(BuildContext context, int accountId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ImportStatementScreen(initialAccountId: accountId),
      ),
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    AccountBalance balance,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove ${balance.account.name}?'),
        content: const Text(
          'Only an account with no entries can be removed. Past transactions '
          'stay in your records.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final removed = await ref
        .read(cashRepositoryProvider)
        .deleteAccount(balance.account.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          removed ? '${balance.account.name} removed.' : 'Keep at least one account, and delete its entries first.',
        ),
      ),
    );
  }

  void _showBankSyncInfo(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Automatic bank sync', style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                Text(
                  'Live FNB sync is not switched on yet. It needs a bank-data '
                  'provider such as Stitch and a small backend, so your '
                  'banking tokens and the provider secret never sit inside the '
                  'app.',
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
                const SizedBox(height: 12),
                Text(
                  'Today you can export a CSV from FNB Online Banking and '
                  'import it here. Zaka remembers which rows it has already '
                  'seen, so importing the same statement twice is safe.',
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Got it'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final balances = ref.watch(accountBalancesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
        actions: [
          IconButton.filledTonal(
            tooltip: 'Add account',
            onPressed: () => _openAdd(context),
            icon: const Icon(Icons.add_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: balances.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Could not load: $error')),
        data: (items) {
          final total = items.fold<int>(
            0,
            (sum, balance) => sum + balance.balanceCents,
          );

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
            children: [
              _TotalCard(totalCents: total, accountCount: items.length),
              const SizedBox(height: 22),
              SectionHeader(
                title: 'Your accounts',
                trailing: Text(
                  '${items.length}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              for (final balance in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _AccountCard(
                    balance: balance,
                    onImport: () => _openImport(context, balance.account.id),
                    onDelete: () => _delete(context, ref, balance),
                  ),
                ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _openAdd(context),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add account'),
                ),
              ),
              const SizedBox(height: 22),
              Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.fromLTRB(18, 8, 14, 8),
                  leading: Icon(
                    Icons.account_balance_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Automatic bank sync'),
                  subtitle: const Text(
                    'Import an FNB CSV today. Live sync needs Stitch and a '
                    'backend.',
                  ),
                  trailing: const Icon(Icons.info_outline_rounded),
                  onTap: () => _showBankSyncInfo(context),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.totalCents, required this.accountCount});

  final int totalCents;
  final int accountCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF127A5A), Color(0xFF074434)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOTAL ACROSS ALL ACCOUNTS',
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white70,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatCents(totalCents),
              style: theme.textTheme.displaySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 44,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            accountCount == 1 ? '1 account' : '$accountCount accounts',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.balance,
    required this.onImport,
    required this.onDelete,
  });

  final AccountBalance balance;
  final VoidCallback onImport;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final account = balance.account;
    final negative = balance.balanceCents < 0;
    final subtitle = [
      if (account.institution.isNotEmpty) account.institution,
      _kindLabel(account.kind),
    ].join(' · ');

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 6, 10),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.55,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                _kindIcon(account.kind),
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(account.name, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              formatCents(balance.balanceCents),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: negative ? theme.colorScheme.error : null,
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Account actions',
              icon: const Icon(Icons.more_vert_rounded, size: 20),
              onSelected: (value) {
                switch (value) {
                  case 'import':
                    onImport();
                  case 'delete':
                    onDelete();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'import',
                  child: Row(
                    children: [
                      Icon(Icons.upload_file_rounded, size: 20),
                      SizedBox(width: 10),
                      Text('Import statement'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded, size: 20),
                      SizedBox(width: 10),
                      Text('Remove account'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

IconData _kindIcon(String kind) => switch (kind) {
  'cash' => Icons.account_balance_wallet_rounded,
  'savings' => Icons.savings_rounded,
  'credit' => Icons.credit_card_rounded,
  _ => Icons.account_balance_rounded,
};

String _kindLabel(String kind) => switch (kind) {
  'cash' => 'Cash',
  'savings' => 'Savings',
  'credit' => 'Credit',
  _ => 'Cheque',
};
