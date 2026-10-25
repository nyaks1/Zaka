import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dates.dart';
import '../../core/money.dart';
import '../../core/statement.dart';
import '../../data/database.dart';
import '../../data/pdf_statement.dart';
import '../../data/statement_importer.dart';
import '../../providers.dart';
import '../../widgets/common.dart';

class ImportStatementScreen extends ConsumerStatefulWidget {
  const ImportStatementScreen({super.key, this.initialAccountId});

  final int? initialAccountId;

  @override
  ConsumerState<ImportStatementScreen> createState() =>
      _ImportStatementScreenState();
}

class _ImportStatementScreenState extends ConsumerState<ImportStatementScreen> {
  final _pasteController = TextEditingController();
  int? _accountId;
  String? _fileName;
  StatementParseResult? _parsed;
  StatementImportPreview? _preview;
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _pasteController.dispose();
    super.dispose();
  }

  int? _resolveAccountId(List<Account> accounts) {
    if (accounts.isEmpty) return null;
    final preferred = _accountId ?? widget.initialAccountId;
    if (preferred != null &&
        accounts.any((account) => account.id == preferred)) {
      return preferred;
    }
    for (final account in accounts) {
      if (account.kind != 'cash') return account.id;
    }
    return accounts.first.id;
  }

  Future<void> _pickFile(int accountId) async {
    try {
      const group = XTypeGroup(
        label: 'Bank statement',
        extensions: ['pdf', 'csv', 'txt'],
        mimeTypes: ['application/pdf', 'text/csv', 'text/plain'],
      );
      final file = await openFile(acceptedTypeGroups: [group]);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      final isPdf =
          file.name.toLowerCase().endsWith('.pdf') || _looksLikePdf(bytes);
      if (!mounted) return;
      if (isPdf) {
        await _loadPdf(bytes, file.name, accountId);
      } else {
        await _loadContent(_decode(bytes), file.name, accountId);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = 'Could not read that file: $error');
    }
  }

  bool _looksLikePdf(Uint8List bytes) {
    if (bytes.length < 5) return false;
    return bytes[0] == 0x25 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x44 &&
        bytes[3] == 0x46;
  }

  String _decode(List<int> bytes) {
    try {
      return utf8.decode(bytes);
    } on FormatException {
      return latin1.decode(bytes);
    }
  }

  void _showHelp() {
    const template =
        'Date,Description,Amount,Balance\n'
        '01/03/2026,SALARY DEPOSIT,28500.00,29000.00\n'
        '02/03/2026,TAXI - BREE,-35.00,28965.00';

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Getting a bank statement',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                Text(
                  'Your bank app usually downloads a PDF. Choose that PDF '
                  'here and Zaka reads the transactions on this device. If it '
                  'asks for a password, enter the one your bank sent you. A '
                  'scanned image has no text layer, so use the CSV route below '
                  'for that.',
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                ),
                const SizedBox(height: 16),
                const _HelpStep(
                  number: '1',
                  text:
                      'Open your bank app and go to the account. Tap '
                      'Statements or Statement history.',
                ),
                const _HelpStep(
                  number: '2',
                  text:
                      'Pick the month you want, then download or share the '
                      'PDF to your phone.',
                ),
                const _HelpStep(
                  number: '3',
                  text:
                      'Come back here, choose the account, and select the PDF. '
                      'Check the preview before importing.',
                ),
                const SizedBox(height: 8),
                Text(
                  'CSV still works and is handy for other banks. A CSV needs '
                  'at least Date, Description and Amount. This template also '
                  'includes Balance:',
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SelectableText(
                    template,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'PDF text and CSV rows are parsed on this device and never '
                  'uploaded. If the preview looks wrong, cancel and use the '
                  'CSV export instead.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    FilledButton.icon(
                      onPressed: () {
                        Clipboard.setData(const ClipboardData(text: template));
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('CSV template copied.')),
                        );
                      },
                      icon: const Icon(Boxicons.bx_copy),
                      label: const Text('Copy template'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _loadContent(String content, String label, int accountId) async {
    setState(() {
      _busy = true;
      _error = null;
      _parsed = null;
      _preview = null;
      _fileName = label;
    });
    try {
      final parsed = parseStatementCsv(content);
      await _previewParsed(parsed, label, accountId);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = '$error';
      });
    }
  }

  Future<void> _loadPdf(
    Uint8List bytes,
    String label,
    int accountId, {
    String? password,
  }) async {
    setState(() {
      _busy = true;
      _error = null;
      _parsed = null;
      _preview = null;
      _fileName = label;
    });

    try {
      final parsed = await parsePdfStatement(bytes, password: password ?? '');
      if (!mounted) return;
      await _previewParsed(parsed, label, accountId);
    } on PdfPasswordException {
      if (!mounted) return;
      setState(() => _busy = false);
      if (password != null) {
        setState(() {
          _error =
              'That password did not open the PDF. Check it and try again, '
              'or export a CSV statement.';
        });
        return;
      }

      final entered = await _askPdfPassword(label);
      if (!mounted) return;
      if (entered == null) {
        setState(() {
          _error =
              'This PDF is password-protected. Enter its password, or export '
              'a CSV statement from Online Banking.';
        });
        return;
      }
      await _loadPdf(bytes, label, accountId, password: entered);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = '$error';
      });
    }
  }

  Future<String?> _askPdfPassword(String label) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('PDF password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$label is password-protected. Enter the password your bank '
              'sent you. It is used only on this phone and is not saved.',
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              autofocus: true,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) => Navigator.of(context).pop(value),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Open'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result == null || result.isEmpty) return null;
    return result;
  }

  Future<void> _previewParsed(
    StatementParseResult parsed,
    String label,
    int accountId,
  ) async {
    setState(() {
      _busy = true;
      _error = null;
      _parsed = parsed;
      _fileName = label;
      _preview = null;
    });

    try {
      final preview = await ref
          .read(statementImporterProvider)
          .previewParsed(accountId: accountId, parsed: parsed);
      if (!mounted) return;
      setState(() {
        _preview = preview;
        _busy = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = '$error';
        _busy = false;
      });
    }
  }

  Future<void> _import(int accountId) async {
    final parsed = _parsed;
    if (parsed == null) return;

    setState(() => _busy = true);
    try {
      final result = await ref
          .read(statementImporterProvider)
          .importParsed(accountId: accountId, parsed: parsed);
      if (!mounted) return;
      final parts = <String>[
        '${result.imported} imported',
        if (result.transfers > 0) '${result.transfers} to cash',
        if (result.skipped > 0) '${result.skipped} already there',
      ];
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(parts.join(' · '))));
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'Could not import: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accounts = ref.watch(accountsProvider).value ?? const [];
    final accountId = _resolveAccountId(accounts);

    if (accounts.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Import statement'),
          actions: [
            IconButton(
              tooltip: 'Where do I get this?',
              onPressed: _showHelp,
              icon: const Icon(Boxicons.bx_help_circle),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: const EmptyState(
          icon: Boxicons.bxs_bank,
          title: 'Add an account first',
          message:
              'Create the bank account you want to import into, then '
              'come back with its PDF or CSV statement.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Import statement'),
        actions: [
          IconButton(
            tooltip: 'Where do I get this?',
            onPressed: _showHelp,
            icon: const Icon(Boxicons.bx_help_circle),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(
            'Drop in a month-end PDF from your bank, or a CSV. Zaka reads it '
            'on this device, then matches the rows against what you already '
            'have so re-importing the same statement is safe.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              onPressed: _showHelp,
              icon: const Icon(Boxicons.bx_help_circle, size: 18),
              label: const Text('Where do I get this statement?'),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Boxicons.bxs_bank),
              title: Text('Import into', style: theme.textTheme.titleSmall),
              trailing: DropdownButton<int>(
                value: accountId,
                underline: const SizedBox.shrink(),
                items: [
                  for (final account in accounts)
                    DropdownMenuItem(
                      value: account.id,
                      child: Text(account.name),
                    ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _accountId = value);
                  final parsed = _parsed;
                  if (parsed != null) {
                    _previewParsed(parsed, _fileName ?? 'statement', value);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.tonalIcon(
            onPressed: accountId == null || _busy
                ? null
                : () => _pickFile(accountId),
            icon: const Icon(Boxicons.bx_upload),
            label: const Text('Choose PDF or CSV'),
          ),
          if (_fileName != null) ...[
            const SizedBox(height: 8),
            Text(
              _fileName!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'or paste CSV',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _pasteController,
            maxLines: 7,
            minLines: 4,
            style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
            decoration: const InputDecoration(
              hintText:
                  'Date,Description,Amount,Balance\n'
                  '01/03/2026,TAXI,-35.00,465.00',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: accountId == null || _busy
                ? null
                : () => _loadContent(
                    _pasteController.text,
                    'Pasted statement',
                    accountId,
                  ),
            icon: const Icon(Boxicons.bx_file),
            label: const Text('Preview pasted CSV'),
          ),
          if (_busy) ...[
            const SizedBox(height: 20),
            const Center(child: CircularProgressIndicator()),
          ],
          if (_error != null) ...[
            const SizedBox(height: 16),
            Card(
              color: theme.colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  _error!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ),
          ],
          if (_preview != null) ...[
            const SizedBox(height: 20),
            _PreviewCard(preview: _preview!),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: FilledButton.icon(
          onPressed:
              _preview == null ||
                  _preview!.newCount == 0 ||
                  accountId == null ||
                  _busy
              ? null
              : () => _import(accountId),
          icon: _busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Boxicons.bx_check),
          label: Text(
            _preview == null
                ? 'Import transactions'
                : 'Import ${_preview!.newCount} '
                      '${_preview!.newCount == 1 ? 'transaction' : 'transactions'}',
          ),
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.preview});

  final StatementImportPreview preview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rows = preview.rows.take(12).toList(growable: false);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ready to import into ${preview.account.name}',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Chip(label: '${preview.newCount} new'),
                if (preview.duplicateCount > 0)
                  _Chip(label: '${preview.duplicateCount} already imported'),
                if (preview.transferCount > 0)
                  _Chip(label: '${preview.transferCount} ATM → cash'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MoneyStat(
                    label: 'Money in',
                    value: formatCents(preview.incomeCents),
                    color: const Color(0xFF1B8A5A),
                  ),
                ),
                Expanded(
                  child: _MoneyStat(
                    label: 'Money out',
                    value: formatCents(preview.spendCents),
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            for (final row in rows) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 68,
                      child: Text(
                        shortDate(row.row.date),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            row.row.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall,
                          ),
                          if (row.duplicate || row.transferToCash)
                            Text(
                              [
                                if (row.duplicate) 'Already imported',
                                if (row.transferToCash) 'Transfer to cash',
                              ].join(' · '),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatCents(row.displayCents),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: row.isIncome
                            ? const Color(0xFF1B8A5A)
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (preview.rows.length > rows.length)
              Text(
                '+ ${preview.rows.length - rows.length} more rows',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            if (preview.warnings.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                preview.warnings.take(3).join('\n'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _HelpStep extends StatelessWidget {
  const _HelpStep({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoneyStat extends StatelessWidget {
  const _MoneyStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
