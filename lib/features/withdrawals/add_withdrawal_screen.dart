import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dates.dart';
import '../../core/money.dart';
import '../../providers.dart';
import '../../widgets/amount_field.dart';

class AddWithdrawalScreen extends ConsumerStatefulWidget {
  const AddWithdrawalScreen({super.key});

  @override
  ConsumerState<AddWithdrawalScreen> createState() =>
      _AddWithdrawalScreenState();
}

class _AddWithdrawalScreenState extends ConsumerState<AddWithdrawalScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  late DateTime _when = DateTime.now();
  int? _accountId;
  bool _saving = false;

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

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
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

  Future<void> _save() async {
    final cents = parseRandToCents(_amountController.text);
    final accountId = _resolveAccountId();
    if (cents == null || accountId == null) return;

    setState(() => _saving = true);
    try {
      await ref
          .read(cashRepositoryProvider)
          .addWithdrawal(
            amountCents: cents,
            withdrawnAt: _when,
            accountId: accountId,
            note: _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${formatCents(cents)} added to your balance.')),
      );
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
    final cents = parseRandToCents(_amountController.text);
    final accounts = ref.watch(accountsProvider).value ?? const [];
    final accountId = _resolveAccountId();

    return Scaffold(
      appBar: AppBar(title: const Text('Add money')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(
            'Record money arriving in an account: cash from the ATM, a salary, '
            'or money added to an account. For an ATM withdrawal, add the cash '
            'here after you take it out.',
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
          if (accounts.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.fromLTRB(18, 2, 12, 2),
                leading: const Icon(Icons.account_balance_wallet_rounded),
                title: Text('Add to', style: theme.textTheme.titleSmall),
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
            decoration: const InputDecoration(
              labelText: 'Note (optional)',
              hintText: 'e.g. FNB ATM, Mbabane',
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
          onPressed: cents == null || accountId == null || _saving
              ? null
              : _save,
          icon: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.add_rounded),
          label: Text(
            cents == null ? 'Add money' : 'Add ${formatCents(cents)}',
          ),
        ),
      ),
    );
  }
}
