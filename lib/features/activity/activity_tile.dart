import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';

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
    final isDark = theme.brightness == Brightness.dark;
    final amountColor = entry.isTransfer
        ? theme.colorScheme.onSurfaceVariant
        : theme.colorScheme.onSurface;
    final sign = entry.isTransfer
        ? ''
        : entry.isWithdrawal
        ? '+'
        : '−';

    final tileBorder = Border.all(
      color: isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
      width: 1,
    );
    final tileBg = isDark ? const Color(0xFF18181B) : const Color(0xFFF4F4F5);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: entry.isTransfer
          ? Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: tileBg,
                borderRadius: BorderRadius.circular(6),
                border: tileBorder,
              ),
              child: Icon(
                Boxicons.bx_transfer,
                color: theme.colorScheme.onSurface,
                size: 20,
              ),
            )
          : entry.isWithdrawal
          ? Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: tileBg,
                borderRadius: BorderRadius.circular(6),
                border: tileBorder,
              ),
              child: Icon(
                Boxicons.bx_down_arrow_alt,
                color: theme.colorScheme.onSurface,
                size: 20,
              ),
            )
          : CategoryAvatar(category: entry.category, size: 40),
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
              icon: Icon(
                Boxicons.bx_dots_vertical_rounded,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              onSelected: (value) {
                if (value == 'delete') onDelete!();
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Boxicons.bx_trash, size: 18),
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
