import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/categories.dart';
import '../../core/dates.dart';
import '../../core/money.dart';
import '../../core/recurrence.dart';
import '../../data/database.dart';
import '../../providers.dart';
import '../../widgets/common.dart';
import '../spending/quick_log_screen.dart';

class RecurringScreen extends ConsumerWidget {
  const RecurringScreen({super.key});

  void _openNew(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const QuickLogScreen(startWithRepeat: true),
      ),
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    RecurringRule rule,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stop repeating this spend?'),
        content: const Text(
          'Past entries stay in your activity. Zaka just stops adding new ones.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Stop'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(cashRepositoryProvider).deleteRule(rule.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final rules = ref.watch(recurringRulesProvider);
    final accounts = ref.watch(accountsProvider).value ?? const [];
    final accountNames = {
      for (final account in accounts) account.id: account.name,
    };
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: const Text('Recurring')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'new-recurring-fab',
        onPressed: () => _openNew(context),
        icon: const Icon(Icons.repeat_rounded),
        label: const Text('New'),
      ),
      body: rules.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Could not load: $error')),
        data: (items) {
          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.local_taxi_rounded,
              title: 'Set a fare once, not every morning',
              message:
                  'Take a taxi Monday to Friday? Log it once with “Repeat” '
                  'turned on. Zaka adds it automatically on the days you choose.',
              action: FilledButton.icon(
                onPressed: () => _openNew(context),
                icon: const Icon(Icons.repeat_rounded),
                label: const Text('Set up a weekday taxi'),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
            children: [
              Card(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.45,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Zaka posts these when they are due, the next time '
                          'you open the app. You only log the first one.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            height: 1.4,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              for (final rule in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _RuleCard(
                    rule: rule,
                    accountName: accountNames[rule.accountId],
                    now: now,
                    onToggle: (active) => ref
                        .read(cashRepositoryProvider)
                        .setRuleActive(rule.id, active),
                    onDelete: () => _delete(context, ref, rule),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  const _RuleCard({
    required this.rule,
    required this.now,
    required this.onToggle,
    required this.onDelete,
    this.accountName,
  });

  final RecurringRule rule;
  final String? accountName;
  final DateTime now;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = SpendCategory.fromName(rule.category);
    final weekdays = parseWeekdays(rule.daysOfWeek);
    final next = rule.active
        ? nextOccurrence(
            weekdays: weekdays,
            startsOn: rule.startsOn,
            after: dateOnly(now),
            endsOn: rule.endsOn,
          )
        : null;

    final status = !rule.active
        ? 'Paused'
        : next == null
        ? 'Finished'
        : 'Next ${dayLabel(next, now: now)}';
    final accountSuffix = accountName == null ? '' : ' · $accountName';

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
        child: Row(
          children: [
            CategoryAvatar(category: category, size: 46),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${formatCents(rule.amountCents)} '
                    '${category.label.toLowerCase()}',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${describeWeekdays(weekdays)} · $status$accountSuffix',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (rule.note != null && rule.note!.isNotEmpty)
                    Text(
                      rule.note!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
            Switch.adaptive(value: rule.active, onChanged: onToggle),
            PopupMenuButton<String>(
              tooltip: 'More',
              icon: const Icon(Icons.more_vert_rounded, size: 20),
              onSelected: (value) {
                if (value == 'delete') onDelete();
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded, size: 20),
                      SizedBox(width: 10),
                      Text('Stop repeating'),
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
