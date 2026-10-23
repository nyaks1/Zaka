import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/accounting.dart';
import '../../core/dates.dart';
import '../../core/money.dart';
import '../../providers.dart';
import '../../widgets/amount_field.dart';

class MoveMoneyScreen extends ConsumerStatefulWidget {
  const MoveMoneyScreen({super.key, this.initialFromAccountId});

  final int? initialFromAccountId;

  @override
  ConsumerState<MoveMoneyScreen> createState() => _MoveMoneyScreenState();
}

class _MoveMoneyScreenState extends ConsumerState<MoveMoneyScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  late DateTime _when = DateTime.now();
  int? _fromId;
  int? _toId;
  bool _saving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  int? _resolveFrom(List<AccountBalance> items) {
    if (items.isEmpty) return null;
    final preferred = _fromId ?? widget.initialFromAccountId;
    if (preferred != null &&
        items.any((item) => item.account.id == preferred)) {
      return preferred;
    }
    return items.first.account.id;
  }

  int? _resolveTo(List<AccountBalance> items, int? fromId) {
    if (items.length < 2) return null;
    if (_toId != null &&
        _toId != fromId &&
        items.any((item) => item.account.id == _toId)) {
      return _toId;
    }
    return items.firstWhere((item) => item.account.id != fromId).account.id;
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

  Future<void> _save(int fromId, int toId) async {
    final cents = parseRandToCents(_amountController.text);
    if (cents == null) return;

    setState(() => _saving = true);
    try {
      await ref
          .read(cashRepositoryProvider)
          .addTransfer(
            fromAccountId: fromId,
            toAccountId: toId,
            amountCents: cents,
            transferredAt: _when,
            note: _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${formatCents(cents)} moved between accounts.'),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not move money: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = ref.watch(accountBalancesProvider).value ?? const [];
    final fromId = _resolveFrom(items);
    final toId = _resolveTo(items, fromId);
    final cents = parseRandToCents(_amountController.text);
    final matching = items
        .where((item) => item.account.id == fromId)
        .map((item) => item.balanceCents);
    final fromBalance = matching.isEmpty ? null : matching.first;

    if (items.length < 2) {
      return Scaffold(
        appBar: AppBar(title: const Text('Move money')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(28),
            child: Text(
              'Add at least two accounts to move money between them.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Move money')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(
            'Moving money between your own accounts is not spending. Zaka '
            'takes it out of one balance and adds it to the other.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          AmountField(
            controller: _amountController,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 18),
          Card(
            child: ListTile(
              leading: const Icon(Icons.arrow_upward_rounded),
              title: Text('From', style: theme.textTheme.titleSmall),
              subtitle: fromBalance == null
                  ? null
                  : Text('Available ${formatCents(fromBalance)}'),
              trailing: DropdownButton<int>(
                value: fromId,
                underline: const SizedBox.shrink(),
                items: [
                  for (final item in items)
                    DropdownMenuItem(
                      value: item.account.id,
                      child: Text(item.account.name),
                    ),
                ],
                onChanged: (value) => setState(() {
                  _fromId = value;
                  if (_toId == value) _toId = null;
                }),
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.arrow_downward_rounded),
              title: Text('To', style: theme.textTheme.titleSmall),
              trailing: DropdownButton<int>(
                value: toId,
                underline: const SizedBox.shrink(),
                items: [
                  for (final item in items)
                    if (item.account.id != fromId)
                      DropdownMenuItem(
                        value: item.account.id,
                        child: Text(item.account.name),
                      ),
                ],
                onChanged: (value) => setState(() => _toId = value),
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _noteController,
            textCapitalization: TextCapitalization.sentences,
            maxLength: 80,
            decoration: const InputDecoration(
              labelText: 'Note (optional)',
              hintText: 'e.g. ATM withdrawal to wallet',
              counterText: '',
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.event_rounded),
              title: Text(
                '${dayLabel(_when)} · ${timeOfDay(_when)}',
                style: theme.textTheme.titleSmall,
              ),
              subtitle: const Text('Tap to change the date'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: _pickDate,
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: FilledButton.icon(
          onPressed: cents == null || fromId == null || toId == null || _saving
              ? null
              : () => _save(fromId, toId),
          icon: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.swap_horiz_rounded),
          label: Text(
            cents == null ? 'Move money' : 'Move ${formatCents(cents)}',
          ),
        ),
      ),
    );
  }
}
