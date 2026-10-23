import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dates.dart';
import '../../core/money.dart';
import '../../data/database.dart';
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
  String? _content;
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
        extensions: ['csv', 'txt'],
        mimeTypes: ['text/csv', 'text/plain'],
      );
      final file = await openFile(acceptedTypeGroups: [group]);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      final content = _decode(bytes);
      if (!mounted) return;
      await _load(content, file.name, accountId);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = 'Could not read that file: $error');
    }
  }

  String _decode(List<int> bytes) {
    try {
      return utf8.decode(bytes);
    } on FormatException {
      return latin1.decode(bytes);
    }
  }

  Future<void> _load(String content, String label, int accountId) async {
    setState(() {
      _busy = true;
      _error = null;
      _content = content;
      _fileName = label;
      _preview = null;
    });

    try {
      final preview = await ref
          .read(statementImporterProvider)
          .preview(accountId: accountId, content: content);
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
    final content = _content;
    if (content == null) return;

    setState(() => _busy = true);
    try {
      final result = await ref
          .read(statementImporterProvider)
          .import(accountId: accountId, content: content);
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
        appBar: AppBar(title: const Text('Import statement')),
        body: const EmptyState(
          icon: Icons.account_balance_rounded,
          title: 'Add an account first',
          message:
              'Create the bank account you want to import into, then '
              'come back with its CSV statement.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Import statement')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(
            'Export a CSV from FNB Online Banking, then choose it here. '
            'Imported rows are matched against what you already have, so '
            're-importing the same statement is safe.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.account_balance_rounded),
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
                  final content = _content;
                  if (content != null) {
                    _load(content, _fileName ?? 'statement.csv', value);
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
            icon: const Icon(Icons.upload_file_rounded),
            label: const Text('Choose CSV file'),
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
                : () => _load(
                    _pasteController.text,
                    'Pasted statement',
                    accountId,
                  ),
            icon: const Icon(Icons.preview_rounded),
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
              : const Icon(Icons.download_done_rounded),
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
