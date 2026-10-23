import 'package:flutter/material.dart';

import '../../core/categories.dart';
import '../../core/dates.dart';
import '../../core/money.dart';
import '../../data/database.dart';
import '../../widgets/common.dart';

class ActivityEntry {
  const ActivityEntry.spend(Spend this.spend) : withdrawal = null;
  const ActivityEntry.withdrawal(Withdrawal this.withdrawal) : spend = null;

  final Spend? spend;
  final Withdrawal? withdrawal;

  bool get isWithdrawal => withdrawal != null;

  DateTime get date => spend?.spentAt ?? withdrawal!.withdrawnAt;

  int get amountCents => spend?.amountCents ?? withdrawal!.amountCents;

  SpendCategory get category => spend == null
      ? SpendCategory.other
      : SpendCategory.fromName(spend!.category);

  String get title {
    if (isWithdrawal) {
      final note = withdrawal!.note;
      return note == null || note.isEmpty ? 'ATM withdrawal' : note;
    }
    final note = spend!.note;
    return note == null || note.isEmpty ? category.label : note;
  }

  String get subtitle {
    final day = dayLabel(date);
    return '$day · ${timeOfDay(date)}';
  }
}

class ActivityTile extends StatelessWidget {
  const ActivityTile({super.key, required this.entry, this.onDelete});

  final ActivityEntry entry;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amountColor = entry.isWithdrawal
        ? const Color(0xFF1B8A5A)
        : theme.colorScheme.onSurface;
    final sign = entry.isWithdrawal ? '+' : '−';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: entry.isWithdrawal
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
