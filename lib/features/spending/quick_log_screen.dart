import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/categories.dart';
import '../../core/dates.dart';
import '../../core/money.dart';
import '../../data/cash_repository.dart';
import '../../providers.dart';
import '../../widgets/amount_field.dart';

class QuickLogScreen extends ConsumerStatefulWidget {
  const QuickLogScreen({
    super.key,
    this.initialCategory = SpendCategory.taxi,
    this.startWithRepeat = false,
  });

  final SpendCategory initialCategory;
  final bool startWithRepeat;

  @override
  ConsumerState<QuickLogScreen> createState() => _QuickLogScreenState();
}

class _QuickLogScreenState extends ConsumerState<QuickLogScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  late SpendCategory _category = widget.initialCategory;
  late bool _repeat = widget.startWithRepeat;
  late DateTime _when = DateTime.now();
  Set<int> _days = {1, 2, 3, 4, 5};
  DateTime? _endsOn;
  int? _accountId;
  bool _saving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  int? get _amountCents => parseRandToCents(_amountController.text);

  bool get _canSave =>
      _amountCents != null &&
      _resolveAccountId() != null &&
      (!_repeat || _days.isNotEmpty) &&
      !_saving;

  int? _resolveAccountId() {
    final accounts = ref.read(accountsProvider).value ?? const [];
    if (accounts.isEmpty) return null;
    final current = _accountId;
    if (current != null && accounts.any((account) => account.id == current)) {
      return current;
    }
    return accounts
        .firstWhere(
          (account) => account.kind == 'cash',
          orElse: () => accounts.first,
        )
        .id;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _when,
      firstDate: DateTime(2020),
      lastDate: now,
    );
    if (picked == null) return;
    setState(() {
      _when = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _when.hour,
        _when.minute,
      );
    });
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _endsOn ?? now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
    if (picked != null) setState(() => _endsOn = dateOnly(picked));
  }

  Future<void> _save() async {
    final cents = _amountCents;
    final accountId = _resolveAccountId();
    if (cents == null || accountId == null) return;
    if (_repeat && _days.isEmpty) return;

    setState(() => _saving = true);
    try {
      await ref
          .read(cashRepositoryProvider)
          .logSpend(
            amountCents: cents,
            category: _category.name,
            spentAt: _when,
            accountId: accountId,
            note: _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
            recurrence: _repeat
                ? RecurringDraft(weekdays: _days, endsOn: _endsOn)
                : null,
          );

      if (!mounted) return;
      final message = _repeat
          ? '${formatCents(cents)} ${_category.label.toLowerCase()} logged — Zaka will repeat it ${describeWeekdays(_days).toLowerCase()}.'
          : '${formatCents(cents)} ${_category.label.toLowerCase()} logged.';

      if (_repeat) {
        // If the first entry was backdated, fill in any dues since then.
        // This is best-effort: the spend itself has already been saved.
        try {
          await ref.read(recurringServiceProvider).postDue(DateTime.now());
        } catch (error) {
          debugPrint('Could not backfill recurring spends: $error');
        }
      }
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not save: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cents = _amountCents;
    final accounts = ref.watch(accountsProvider).value ?? const [];
    final accountId = _resolveAccountId();

    return Scaffold(
      appBar: AppBar(title: const Text('Log spend')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          AmountField(
            controller: _amountController,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 24),
          Text('What did you spend on?', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final tileWidth = (constraints.maxWidth - 10) / 2;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final category in SpendCategory.values)
                    SizedBox(
                      width: tileWidth,
                      child: _CategoryTile(
                        category: category,
                        selected: category == _category,
                        onTap: () => setState(() => _category = category),
                      ),
                    ),
                ],
              );
            },
          ),
          if (accounts.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.fromLTRB(18, 2, 12, 2),
                leading: const Icon(Boxicons.bx_wallet),
                title: Text('Paid from', style: theme.textTheme.titleSmall),
                trailing: DropdownButton<int>(
                  value: accountId,
                  underline: const SizedBox.shrink(),
                  borderRadius: BorderRadius.circular(14),
                  items: [
                    for (final account in accounts)
                      DropdownMenuItem(
                        value: account.id,
                        child: Text(account.name),
                      ),
                  ],
                  onChanged: (value) => setState(() => _accountId = value),
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          TextField(
            controller: _noteController,
            textCapitalization: TextCapitalization.sentences,
            maxLength: 80,
            decoration: InputDecoration(
              labelText: 'Note (optional)',
              hintText: _category == SpendCategory.taxi
                  ? 'e.g. Bree taxi rank'
                  : 'Anything worth remembering',
              counterText: '',
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 6,
              ),
              leading: const Icon(Boxicons.bx_calendar),
              title: Text(
                '${dayLabel(_when)} · ${timeOfDay(_when)}',
                style: theme.textTheme.titleSmall,
              ),
              subtitle: const Text('Tap to change the date'),
              trailing: const Icon(Boxicons.bx_chevron_right),
              onTap: _pickDate,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 6, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Repeat this spend'),
                    subtitle: const Text(
                      'Log it once — Zaka adds it on the days you choose.',
                    ),
                    value: _repeat,
                    onChanged: (value) => setState(() => _repeat = value),
                  ),
                  if (_repeat) ...[
                    const Divider(),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _PresetDaysChip(
                          label: 'Weekdays',
                          days: const {1, 2, 3, 4, 5},
                          selectedDays: _days,
                          onSelected: (days) =>
                              setState(() => _days = Set.of(days)),
                        ),
                        _PresetDaysChip(
                          label: 'Every day',
                          days: const {1, 2, 3, 4, 5, 6, 7},
                          selectedDays: _days,
                          onSelected: (days) =>
                              setState(() => _days = Set.of(days)),
                        ),
                        _PresetDaysChip(
                          label: 'Weekends',
                          days: const {6, 7},
                          selectedDays: _days,
                          onSelected: (days) =>
                              setState(() => _days = Set.of(days)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (var day = 1; day <= 7; day++)
                          FilterChip(
                            label: Text(weekdayShortNames[day - 1]),
                            selected: _days.contains(day),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _days = {..._days, day};
                                } else {
                                  _days = {..._days}..remove(day);
                                }
                              });
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Ends',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: _pickEndDate,
                          child: Text(
                            _endsOn == null ? 'Never' : shortDate(_endsOn!),
                          ),
                        ),
                        if (_endsOn != null)
                          IconButton(
                            tooltip: 'Remove end date',
                            icon: const Icon(Boxicons.bx_x, size: 18),
                            onPressed: () => setState(() => _endsOn = null),
                          ),
                      ],
                    ),
                    Text(
                      'The first entry is saved now. Zaka fills in the rest '
                      'when the app opens on a due day.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: FilledButton.icon(
          onPressed: _canSave ? _save : null,
          icon: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Boxicons.bx_check),
          label: Text(
            cents == null
                ? 'Log spend'
                : 'Log ${formatCents(cents)} ${_category.label.toLowerCase()}',
          ),
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final SpendCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fg = theme.colorScheme.onSurface;
    final border = isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final bg = selected
        ? (isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5))
        : (isDark ? const Color(0xFF09090B) : Colors.white);

    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(
          color: selected ? fg : border,
          width: selected ? 1.5 : 1.0,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Icon(category.icon, color: fg, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                    Text(
                      category.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PresetDaysChip extends StatelessWidget {
  const _PresetDaysChip({
    required this.label,
    required this.days,
    required this.selectedDays,
    required this.onSelected,
  });

  final String label;
  final Set<int> days;
  final Set<int> selectedDays;
  final ValueChanged<Set<int>> onSelected;

  @override
  Widget build(BuildContext context) {
    final selected =
        selectedDays.length == days.length && selectedDays.containsAll(days);
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(days),
    );
  }
}
