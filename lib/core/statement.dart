import 'package:csv/csv.dart';
import 'package:intl/intl.dart';

/// A single row from a bank statement. Amounts are signed: positive means
/// money arrived in the account, negative means money left it.
class StatementRow {
  const StatementRow({
    required this.lineNumber,
    required this.date,
    required this.description,
    required this.amountCents,
    this.balanceCents,
    this.occurrence = 1,
  });

  final int lineNumber;
  final DateTime date;
  final String description;
  final int amountCents;
  final int? balanceCents;

  /// Distinguishes two identical transactions on the same day in one file.
  final int occurrence;

  bool get isCredit => amountCents > 0;
}

class StatementParseResult {
  const StatementParseResult({required this.rows, required this.warnings});

  final List<StatementRow> rows;
  final List<String> warnings;

  int get creditCents => rows
      .where((row) => row.isCredit)
      .fold<int>(0, (sum, row) => sum + row.amountCents);

  int get debitCents => rows
      .where((row) => !row.isCredit)
      .fold<int>(0, (sum, row) => sum + row.amountCents.abs());
}

class StatementFormatException implements Exception {
  const StatementFormatException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Parses a CSV exported by a South African bank. It looks for a header row
/// containing a date and an amount (or separate debit/credit) column, so it
/// works with FNB's `Date, Description, Amount, Balance` export and with
/// statements that use `Debit`/`Credit` columns.
StatementParseResult parseStatementCsv(String content) {
  final clean = content.replaceFirst('\uFEFF', '').trim();
  if (clean.isEmpty) {
    throw const StatementFormatException('The file is empty.');
  }

  final rows = const CsvDecoder(skipEmptyLines: true).convert(clean);
  if (rows.isEmpty) {
    throw const StatementFormatException('No rows found in the file.');
  }

  final headerIndex = _findHeaderRow(rows);
  if (headerIndex == -1) {
    throw const StatementFormatException(
      'Could not find a header row with a date and amount column. '
      'Export the statement as CSV from your bank.',
    );
  }

  final header = rows[headerIndex].map((cell) => _normalise('$cell')).toList();
  final columns = _StatementColumns.fromHeader(header);
  if (columns.date == null) {
    throw const StatementFormatException(
      'Could not find a date column in the statement.',
    );
  }
  if (!columns.hasAmount) {
    throw const StatementFormatException(
      'Could not find an amount, debit or credit column in the statement.',
    );
  }

  final parsed = <StatementRow>[];
  final warnings = <String>[];
  final seenKeys = <String, int>{};

  for (var i = headerIndex + 1; i < rows.length; i++) {
    final row = rows[i];
    final line = i + 1;
    if (row.every((cell) => '$cell'.trim().isEmpty)) continue;

    final dateText = _cell(row, columns.date);
    final description = _cell(row, columns.description);
    final amountText = _cell(row, columns.amount);

    // Some exports wrap a long description onto the next line with no date
    // or amount. Append it to the previous transaction.
    if (dateText.isEmpty &&
        amountText.isEmpty &&
        _cell(row, columns.debit).isEmpty &&
        _cell(row, columns.credit).isEmpty) {
      if (parsed.isNotEmpty && description.isNotEmpty) {
        final previous = parsed.removeLast();
        parsed.add(
          StatementRow(
            lineNumber: previous.lineNumber,
            date: previous.date,
            description: '${previous.description} $description'.trim(),
            amountCents: previous.amountCents,
            balanceCents: previous.balanceCents,
            occurrence: previous.occurrence,
          ),
        );
      }
      continue;
    }

    final date = parseStatementDate(dateText);
    if (date == null) {
      warnings.add('Line $line: could not read the date "$dateText".');
      continue;
    }

    final debit = parseStatementAmountCents(_cell(row, columns.debit));
    final credit = parseStatementAmountCents(_cell(row, columns.credit));
    int? amount;
    if (debit != null && debit != 0) {
      amount = -debit.abs();
    } else if (credit != null && credit != 0) {
      amount = credit.abs();
    } else {
      amount = parseStatementAmountCents(amountText);
      if (amount != null) amount = _applyType(amount, _cell(row, columns.type));
    }

    if (amount == null || amount == 0) {
      warnings.add('Line $line: could not read a non-zero amount.');
      continue;
    }

    final cleanDescription = description.isEmpty
        ? 'Imported transaction'
        : description;

    // Keep genuine same-day duplicates distinct within one file, while
    // re-importing the same file produces the same keys.
    final baseKey = '${_isoDate(date)}|$amount|${_normalise(cleanDescription)}';
    final occurrence = (seenKeys[baseKey] ?? 0) + 1;
    seenKeys[baseKey] = occurrence;

    parsed.add(
      StatementRow(
        lineNumber: line,
        date: date,
        description: cleanDescription,
        amountCents: amount,
        balanceCents: parseStatementAmountCents(_cell(row, columns.balance)),
        occurrence: occurrence,
      ),
    );
  }

  if (parsed.isEmpty) {
    throw const StatementFormatException(
      'No transactions could be read from this file.',
    );
  }

  return StatementParseResult(rows: parsed, warnings: warnings);
}

/// Builds the key used to skip rows that were already imported. The row's
/// occurrence distinguishes two identical transactions on the same day.
String statementImportKey(StatementRow row) {
  final base =
      '${_isoDate(row.date)}|${row.amountCents}|'
      '${_normalise(row.description)}';
  return row.occurrence == 1 ? base : '$base|${row.occurrence}';
}

int? parseStatementAmountCents(String raw) {
  var text = raw.trim();
  if (text.isEmpty) return null;

  var negative = false;
  if (text.startsWith('(') && text.endsWith(')')) {
    negative = true;
    text = text.substring(1, text.length - 1);
  }

  final upper = text.toUpperCase();
  if (upper.endsWith('DR') || RegExp(r'\bDR\b').hasMatch(upper)) {
    negative = true;
  }
  if (upper.endsWith('CR') || RegExp(r'\bCR\b').hasMatch(upper)) {
    negative = false;
  }

  text = text.replaceAll(RegExp(r'[^0-9.,+\-]'), '');
  if (text.startsWith('-')) {
    negative = true;
    text = text.substring(1);
  }
  text = text.replaceAll('+', '');
  if (text.isEmpty) return null;

  final lastDot = text.lastIndexOf('.');
  final lastComma = text.lastIndexOf(',');

  String integerPart;
  String fractionPart;

  if (lastDot != -1 && lastComma != -1) {
    final decimalIndex = lastDot > lastComma ? lastDot : lastComma;
    integerPart = text
        .substring(0, decimalIndex)
        .replaceAll(RegExp(r'[.,]'), '');
    fractionPart = text.substring(decimalIndex + 1);
  } else if (lastComma != -1) {
    final parts = text.split(',');
    final last = parts.last;
    if (parts.length == 2 && last.length <= 2) {
      integerPart = parts.first;
      fractionPart = last;
    } else {
      integerPart = text.replaceAll(',', '');
      fractionPart = '';
    }
  } else if (lastDot != -1) {
    final parts = text.split('.');
    final last = parts.last;
    if (parts.length == 2 && last.length <= 2) {
      integerPart = parts.first;
      fractionPart = last;
    } else {
      integerPart = text.replaceAll('.', '');
      fractionPart = '';
    }
  } else {
    integerPart = text;
    fractionPart = '';
  }

  if (integerPart.isEmpty) integerPart = '0';
  final whole = int.tryParse(integerPart);
  if (whole == null) return null;

  final fraction = fractionPart.isEmpty
      ? 0
      : int.tryParse(fractionPart.padRight(2, '0').substring(0, 2));
  if (fraction == null) return null;

  final cents = whole * 100 + fraction;
  return negative ? -cents : cents;
}

DateTime? parseStatementDate(String raw) {
  final text = raw.trim();
  if (text.isEmpty) return null;

  final iso = DateTime.tryParse(text);
  if (iso != null) return DateTime(iso.year, iso.month, iso.day);

  const patterns = <String>[
    'dd/MM/yyyy',
    'd/M/yyyy',
    'dd-MM-yyyy',
    'd-M-yyyy',
    'yyyy/MM/dd',
    'yyyy-MM-dd',
    'dd MMM yyyy',
    'd MMM yyyy',
    'dd MMM yy',
    'd MMM yy',
    'yyyyMMdd',
  ];

  for (final pattern in patterns) {
    try {
      final parsed = DateFormat(pattern).parseStrict(text);
      return DateTime(parsed.year, parsed.month, parsed.day);
    } on FormatException {
      // Try the next pattern.
    }
  }
  return null;
}

int _applyType(int amount, String type) {
  final normalised = type.trim().toUpperCase();
  if (normalised.contains('DR') || normalised.contains('DEBIT')) {
    return -amount.abs();
  }
  if (normalised.contains('CR') || normalised.contains('CREDIT')) {
    return amount.abs();
  }
  return amount;
}

int _findHeaderRow(List<List<dynamic>> rows) {
  final limit = rows.length < 20 ? rows.length : 20;
  for (var i = 0; i < limit; i++) {
    final header = rows[i].map((cell) => _normalise('$cell')).toList();
    final hasDate = header.any(_isDateHeader);
    final hasAmount = header.any(_isAmountHeader);
    if (hasDate && hasAmount) return i;
  }
  return -1;
}

bool _isDateHeader(String value) {
  return value == 'date' ||
      value == 'transactiondate' ||
      value == 'postingdate' ||
      value == 'posteddate' ||
      value == 'valuedate' ||
      value == 'dateposted' ||
      value == 'effectivedate' ||
      value.contains('date');
}

bool _isAmountHeader(String value) {
  return value == 'amount' ||
      value == 'transactionamount' ||
      value == 'value' ||
      value == 'debit' ||
      value == 'debitamount' ||
      value == 'credit' ||
      value == 'creditamount' ||
      value == 'moneyin' ||
      value == 'moneyout' ||
      value == 'paidin' ||
      value == 'paidout' ||
      value == 'withdrawal' ||
      value == 'withdrawals' ||
      value == 'deposit' ||
      value == 'deposits' ||
      value.contains('amount');
}

class _StatementColumns {
  const _StatementColumns({
    required this.date,
    required this.description,
    required this.amount,
    required this.debit,
    required this.credit,
    required this.balance,
    required this.type,
  });

  final int? date;
  final int? description;
  final int? amount;
  final int? debit;
  final int? credit;
  final int? balance;
  final int? type;

  bool get hasAmount => amount != null || debit != null || credit != null;

  static _StatementColumns fromHeader(List<String> header) {
    int? find(
      List<String> exact,
      List<String> contains, {
      Set<int> exclude = const {},
    }) {
      for (var i = 0; i < header.length; i++) {
        if (exclude.contains(i)) continue;
        if (exact.contains(header[i])) return i;
      }
      for (var i = 0; i < header.length; i++) {
        if (exclude.contains(i)) continue;
        if (contains.any(header[i].contains)) return i;
      }
      return null;
    }

    final debit = find(
      const [
        'debit',
        'debitamount',
        'moneyout',
        'paidout',
        'withdrawal',
        'withdrawals',
      ],
      const ['debit', 'moneyout', 'paidout'],
    );
    final credit = find(
      const [
        'credit',
        'creditamount',
        'moneyin',
        'paidin',
        'deposit',
        'deposits',
      ],
      const ['credit', 'moneyin', 'paidin'],
      exclude: {?debit},
    );
    final amount = find(
      const ['amount', 'transactionamount', 'value'],
      const ['amount'],
      exclude: {?debit, ?credit},
    );
    final date = find(
      const [
        'date',
        'transactiondate',
        'postingdate',
        'posteddate',
        'valuedate',
        'dateposted',
        'effectivedate',
      ],
      const ['date'],
    );
    final description = find(
      const [
        'description',
        'details',
        'narrative',
        'transactiondescription',
        'reference',
        'memo',
        'payee',
        'particulars',
      ],
      const ['descr', 'detail', 'narrat', 'reference', 'memo'],
      exclude: {?date},
    );
    final balance = find(
      const ['balance', 'runningbalance', 'closingbalance', 'availablebalance'],
      const ['balance'],
    );
    final type = find(
      const ['type', 'debitcredit', 'drcr', 'transactiontype'],
      const ['type', 'drcr'],
    );

    return _StatementColumns(
      date: date,
      description: description,
      amount: amount,
      debit: debit,
      credit: credit,
      balance: balance,
      type: type,
    );
  }
}

String _cell(List<dynamic> row, int? index) {
  if (index == null || index < 0 || index >= row.length) return '';
  return '${row[index]}'.trim();
}

String _normalise(String value) =>
    value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

String _isoDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';
