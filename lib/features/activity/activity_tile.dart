import 'package:flutter/material.dart';

import '../../core/categories.dart';
import '../../core/dates.dart';
import '../../core/money.dart';
import '../../data/database.dart';
import '../../widgets/common.dart';

class ActivityEntry {
  const ActivityEntry.spend(Spend this.spend, {this.accountName})
    : withdrawal = null,
      transfer = null,
      toAccountName = null;

  const ActivityEntry.withdrawal(Withdrawal this.withdrawal, {this.accountName})
    : spend = null,
      transfer = null,
      toAccountName = null;

  const ActivityEntry.transfer(
    Transfer this.transfer, {
    this.accountName,
    this.toAccountName,
  }) : spend = null,
       withdrawal = null;

  final Spend? spend;
  final Withdrawal? withdrawal;
  final Transfer? transfer;
  final String? accountName;
  final String? toAccountName;

  bool get isWithdrawal => withdrawal != null;
  bool get isTransfer => transfer != null;

  DateTime get date =>
      spend?.spentAt ?? withdrawal?.withdrawnAt ?? transfer!.transferredAt;

  int get amountCents =>
      spend?.amountCents ?? withdrawal?.amountCents ?? transfer!.amountCents;

  SpendCategory get category => spend == null
      ? SpendCategory.other
      : SpendCategory.fromName(spend!.category);

  String get title {
    if (isTransfer) {
      final note = transfer!.note;
      if (note != null && note.isNotEmpty) return note;
      return 'Transfer to ${toAccountName ?? 'account'}';
    }
    if (isWithdrawal) {
      final note = withdrawal!.note;
      return note == null || note.isEmpty ? 'Money in' : note;
    }
    final note = spend!.note;
    return note == null || note.isEmpty ? category.label : note;
  }

  String get subtitle {
    final day = dayLabel(date);
    final time = timeOfDay(date);
    if (isTransfer) {
      return '$day · $time · ${accountName ?? 'Account'} → '
          '${toAccountName ?? 'account'}';
    }
    if (accountName == null || accountName!.isEmpty) {
      return '$day · $time';
    }
    return '$day · $time · $accountName';
  }
}

class ActivityTile extends StatelessWidget {
  const ActivityTile({super.key, required this.entry, this.onDelete});

  final ActivityEntry entry;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amountColor = entry.isTransfer
        ? theme.colorScheme.onSurfaceVariant
        : entry.isWithdrawal
        ? const Color(0xFF1B8A5A)
        : theme.colorScheme.onSurface;
    final sign = entry.isTransfer
        ? ''
        : entry.isWithdrawal
        ? '+'
        : '−';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: entry.isTransfer
          ? Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.swap_horiz_rounded,
                color: theme.colorScheme.onSecondaryContainer,
                size: 22,
              ),
            )
          : entry.isWithdrawal
          ? Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF1B8A5A).withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.south_west_rounded,
                color: Color(0xFF1B8A5A),
                size: 22,
              ),
            )
          : CategoryAvatar(category: entry.category),
      title: Text(
        entry.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleSmall,
      ),
      subtitle: Text(
        entry.subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$sign${formatCents(entry.amountCents)}',
            style: theme.textTheme.titleSmall?.copyWith(
              color: amountColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (onDelete != null)
            PopupMenuButton<String>(
              tooltip: 'More',
              icon: const Icon(Icons.more_vert_rounded, size: 20),
              onSelected: (value) {
                if (value == 'delete') onDelete!();
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded, size: 20),
                      SizedBox(width: 10),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
