import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/money.dart';
import '../../providers.dart';

class AddAccountScreen extends ConsumerStatefulWidget {
  const AddAccountScreen({super.key});

  @override
  ConsumerState<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends ConsumerState<AddAccountScreen> {
  final _nameController = TextEditingController();
  final _openingController = TextEditingController(text: '0.00');

  String _institution = 'FNB';
  String _kind = 'cheque';
  bool _saving = false;

  static const _institutions = [
    'FNB',
    'Capitec',
    'ABSA',
    'Standard Bank',
    'Nedbank',
    'TymeBank',
    'Other',
  ];

  static const _kinds = {
    'cheque': 'Cheque / current',
    'savings': 'Savings',
    'credit': 'Credit card / loan',
    'cash': 'Cash wallet',
  };

  @override
  void dispose() {
    _nameController.dispose();
    _openingController.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _nameController.text.trim().isNotEmpty &&
      parseSignedRandToCents(_openingController.text) != null &&
      !_saving;

  Future<void> _save() async {
    final opening = parseSignedRandToCents(_openingController.text);
    if (opening == null || _nameController.text.trim().isEmpty) return;

    setState(() => _saving = true);
    try {
      await ref
          .read(cashRepositoryProvider)
          .addAccount(
            name: _nameController.text,
            institution: _institution,
            kind: _kind,
            openingBalanceCents: opening,
          );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not add account: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Add account')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(
            'Track each bank account separately, then see one total across all '
            'of them. Zaka does not ask for your banking login.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            maxLength: 60,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Account name',
              hintText: 'e.g. FNB Cheque',
              counterText: '',
            ),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _institution,
            decoration: const InputDecoration(labelText: 'Bank'),
            items: [
              for (final institution in _institutions)
                DropdownMenuItem(value: institution, child: Text(institution)),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _institution = value);
            },
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _kind,
            decoration: const InputDecoration(labelText: 'Account type'),
            items: [
              for (final entry in _kinds.entries)
                DropdownMenuItem(value: entry.key, child: Text(entry.value)),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _kind = value);
            },
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _openingController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,-]')),
              LengthLimitingTextInputFormatter(14),
            ],
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Opening balance',
              prefixText: 'R ',
              helperText: _kind == 'credit'
                  ? 'Use a minus sign if you owe money, e.g. -2500.00'
                  : 'What the account held before you started using Zaka',
              helperMaxLines: 2,
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
              : const Icon(Boxicons.bx_plus),
          label: const Text('Add account'),
        ),
      ),
    );
  }
}
