import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Large cash amount input used by both the withdrawal and quick-log screens.
class AmountField extends StatelessWidget {
  const AmountField({
    super.key,
    required this.controller,
    this.autofocus = true,
    this.onChanged,
  });

  final TextEditingController controller;
  final bool autofocus;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
        LengthLimitingTextInputFormatter(12),
      ],
      onChanged: onChanged,
      style: theme.textTheme.displaySmall,
      decoration: InputDecoration(
        labelText: 'Amount',
        prefixText: 'R ',
        prefixStyle: theme.textTheme.displaySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        hintText: '0.00',
        hintStyle: theme.textTheme.displaySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 24,
        ),
      ),
    );
  }
}
