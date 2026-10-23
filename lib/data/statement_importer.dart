import 'package:drift/drift.dart';

import '../core/categories.dart';
import '../core/statement.dart';
import 'cash_repository.dart';
import 'database.dart';

class StatementPreviewRow {
  const StatementPreviewRow({
    required this.row,
    required this.duplicate,
    required this.transferToCash,
  });

  final StatementRow row;
  final bool duplicate;
  final bool transferToCash;

  bool get isIncome => row.amountCents > 0;
  int get displayCents => row.amountCents.abs();
}

class StatementImportPreview {
  const StatementImportPreview({
    required this.account,
    required this.rows,
    required this.warnings,
  });

  final Account account;
  final List<StatementPreviewRow> rows;
  final List<String> warnings;

  int get duplicateCount => rows.where((row) => row.duplicate).length;
  int get newCount => rows.where((row) => !row.duplicate).length;
  int get incomeCount =>
      rows.where((row) => !row.duplicate && row.isIncome).length;
  int get spendCount => rows
      .where((row) => !row.duplicate && !row.isIncome && !row.transferToCash)
      .length;
  int get transferCount =>
      rows.where((row) => !row.duplicate && row.transferToCash).length;

  int get incomeCents => rows
      .where((row) => !row.duplicate && row.isIncome)
      .fold<int>(0, (sum, row) => sum + row.row.amountCents);
  int get spendCents => rows
      .where((row) => !row.duplicate && !row.isIncome && !row.transferToCash)
      .fold<int>(0, (sum, row) => sum + row.row.amountCents.abs());
  int get transferCents => rows
      .where((row) => !row.duplicate && row.transferToCash)
      .fold<int>(0, (sum, row) => sum + row.row.amountCents.abs());
}

class StatementImportResult {
  const StatementImportResult({
    required this.imported,
    required this.skipped,
    required this.transfers,
  });

  final int imported;
  final int skipped;
  final int transfers;
}

/// Turns a bank CSV into Zaka entries. Debits become spends, credits become
/// money in, and ATM/cash withdrawals become transfers to the cash account
/// so the same money is not counted twice.
class StatementImporter {
  StatementImporter(this._db, this._repository);

  final AppDatabase _db;
  final CashRepository _repository;

  Future<StatementImportPreview> preview({
    required int accountId,
    required String content,
  }) async {
    final account = await (_db.select(
      _db.accounts,
    )..where((table) => table.id.equals(accountId))).getSingleOrNull();
    if (account == null) {
      throw const StatementFormatException('Choose an account first.');
    }

    final parsed = parseStatementCsv(content);
    final existing = await _existingKeys(accountId);
    final cashAccountId = await _cashAccountId(excluding: accountId);
    final seen = <String>{};

    final rows = <StatementPreviewRow>[];
    for (final row in parsed.rows) {
      final key = statementImportKey(row);
      final duplicate = existing.contains(key) || !seen.add(key);
      final transfer =
          cashAccountId != null &&
          row.amountCents < 0 &&
          _looksLikeCashWithdrawal(row.description);
      rows.add(
        StatementPreviewRow(
          row: row,
          duplicate: duplicate,
          transferToCash: transfer,
        ),
      );
    }

    return StatementImportPreview(
      account: account,
      rows: rows,
      warnings: parsed.warnings,
    );
  }

  Future<StatementImportResult> import({
    required int accountId,
    required String content,
  }) async {
    final preview = await this.preview(accountId: accountId, content: content);
    final cashAccountId = await _cashAccountId(excluding: accountId);

    var imported = 0;
    var skipped = 0;
    var transfers = 0;

    await _db.transaction(() async {
      for (final item in preview.rows) {
        if (item.duplicate) {
          skipped++;
          continue;
        }

        final row = item.row;
        final key = statementImportKey(row);

        if (row.amountCents > 0) {
          await _repository.addWithdrawal(
            amountCents: row.amountCents,
            withdrawnAt: row.date,
            accountId: accountId,
            note: row.description,
            importKey: key,
            source: 'import',
          );
          imported++;
        } else if (item.transferToCash && cashAccountId != null) {
          await _repository.addTransfer(
            fromAccountId: accountId,
            toAccountId: cashAccountId,
            amountCents: row.amountCents.abs(),
            transferredAt: row.date,
            note: row.description,
            importKey: key,
          );
          transfers++;
          imported++;
        } else {
          await _repository.logSpend(
            amountCents: row.amountCents.abs(),
            category: guessStatementCategory(row.description).name,
            spentAt: row.date,
            accountId: accountId,
            note: row.description,
            importKey: key,
            source: 'import',
          );
          imported++;
        }
      }
    });

    return StatementImportResult(
      imported: imported,
      skipped: skipped,
      transfers: transfers,
    );
  }

  Future<Set<String>> _existingKeys(int accountId) async {
    final keys = <String>{};

    final withdrawalQuery = _db.selectOnly(_db.withdrawals)
      ..addColumns([_db.withdrawals.importKey])
      ..where(
        _db.withdrawals.accountId.equals(accountId) &
            _db.withdrawals.importKey.isNotNull(),
      );
    for (final row in await withdrawalQuery.get()) {
      final key = row.read(_db.withdrawals.importKey);
      if (key != null) keys.add(key);
    }

    final spendQuery = _db.selectOnly(_db.spends)
      ..addColumns([_db.spends.importKey])
      ..where(
        _db.spends.accountId.equals(accountId) &
            _db.spends.importKey.isNotNull(),
      );
    for (final row in await spendQuery.get()) {
      final key = row.read(_db.spends.importKey);
      if (key != null) keys.add(key);
    }

    final transferQuery = _db.selectOnly(_db.transfers)
      ..addColumns([_db.transfers.importKey])
      ..where(
        _db.transfers.fromAccountId.equals(accountId) &
            _db.transfers.importKey.isNotNull(),
      );
    for (final row in await transferQuery.get()) {
      final key = row.read(_db.transfers.importKey);
      if (key != null) keys.add(key);
    }

    return keys;
  }

  Future<int?> _cashAccountId({required int excluding}) async {
    final accounts = await _db.select(_db.accounts).get();
    for (final account in accounts) {
      if (account.id != excluding && account.kind == 'cash') return account.id;
    }
    return null;
  }
}

bool _looksLikeCashWithdrawal(String description) {
  final text = description.toLowerCase();
  return RegExp(r'atm|cash\s*withdraw|cash\s*w/drawal|cash\s*withdrawal')
      .hasMatch(text);
}

SpendCategory guessStatementCategory(String description) {
  final text = description.toLowerCase();
  if (RegExp(r'taxi|uber|bolt|ride|transport').hasMatch(text)) {
    return SpendCategory.taxi;
  }
  if (RegExp(
    r'airtime|vodacom|mtn|telkom|cell\s*c|data\s*bundle|prepaid\s*airtime',
  ).hasMatch(text)) {
    return SpendCategory.airtime;
  }
  if (RegExp(r'eskom|electric|prepaid\s*power|electricity').hasMatch(text)) {
    return SpendCategory.electricity;
  }
  if (RegExp(r'vendor|spaza|street\s*seller').hasMatch(text)) {
    return SpendCategory.vendor;
  }
  if (RegExp(
    r'food|restaurant|kfc|nando|steers|spar|checkers|shoprite|'
    r'pick\s*n\s*pay|woolworths|mcdonald|burger|coffee|cafe|bakery|'
    r'butcher|grocer',
  ).hasMatch(text)) {
    return SpendCategory.food;
  }
  return SpendCategory.other;
}
