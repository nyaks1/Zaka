import 'package:flutter_test/flutter_test.dart';
import 'package:zaka/core/statement.dart';

void main() {
  group('parseStatementCsv', () {
    test('reads an FNB-style date, description, amount, balance export', () {
      const csv = '''
Date,Description,Amount,Balance
01/03/2026,SALARY DEPOSIT,28500.00,29000.00
02/03/2026,TAXI - BREE,-35.00,28965.00
"03/03/2026","PICK N PAY, ROSEBANK",-345.99,28619.01
''';

      final result = parseStatementCsv(csv);

      expect(result.rows, hasLength(3));
      expect(result.rows.first.date, DateTime(2026, 3, 1));
      expect(result.rows.first.amountCents, 2850000);
      expect(result.rows.first.isCredit, isTrue);
      expect(result.rows[1].amountCents, -3500);
      expect(result.rows[2].description, 'PICK N PAY, ROSEBANK');
      expect(result.rows[2].balanceCents, 2861901);
      expect(result.creditCents, 2850000);
      expect(result.debitCents, 3500 + 34599);
    });

    test('reads separate debit and credit columns', () {
      const csv = '''
Transaction Date,Description,Debit,Credit,Balance
2026/03/01,Salary,,28500.00,28500.00
2026/03/02,ATM CASH WITHDRAWAL,500.00,,28000.00
''';

      final result = parseStatementCsv(csv);

      expect(result.rows, hasLength(2));
      expect(result.rows.first.amountCents, 2850000);
      expect(result.rows.last.amountCents, -50000);
    });

    test('skips preamble rows before the header', () {
      const csv = '''
FNB Statement
Account 123456789
Date,Description,Amount
01/03/2026,TAXI,-35.00
''';

      final result = parseStatementCsv(csv);

      expect(result.rows.single.description, 'TAXI');
      expect(result.rows.single.amountCents, -3500);
    });

    test('keeps identical same-day rows distinct and repeatable', () {
      const csv = '''
Date,Description,Amount
01/03/2026,TAXI,-35.00
01/03/2026,TAXI,-35.00
''';

      final result = parseStatementCsv(csv);
      final firstKey = statementImportKey(result.rows[0]);
      final secondKey = statementImportKey(result.rows[1]);

      expect(result.rows[0].occurrence, 1);
      expect(result.rows[1].occurrence, 2);
      expect(firstKey, isNot(secondKey));
    });

    test('rejects a file without a date and amount header', () {
      expect(
        () => parseStatementCsv('hello,world\n1,2'),
        throwsA(isA<StatementFormatException>()),
      );
    });
  });

  group('parseStatementAmountCents', () {
    test('handles Rand symbols, signs, thousands and parentheses', () {
      expect(parseStatementAmountCents('R 1,234.50'), 123450);
      expect(parseStatementAmountCents('-R 35.00'), -3500);
      expect(parseStatementAmountCents('(45.00)'), -4500);
      expect(parseStatementAmountCents('1.234,56'), 123456);
      expect(parseStatementAmountCents('35,50'), 3550);
      expect(parseStatementAmountCents('1,250'), 125000);
      expect(parseStatementAmountCents('35.00 DR'), -3500);
      expect(parseStatementAmountCents('35.00 CR'), 3500);
      expect(parseStatementAmountCents(''), isNull);
    });
  });

  group('parseStatementDate', () {
    test('reads common South African bank date formats', () {
      expect(parseStatementDate('01/03/2026'), DateTime(2026, 3, 1));
      expect(parseStatementDate('1/3/2026'), DateTime(2026, 3, 1));
      expect(parseStatementDate('2026/03/01'), DateTime(2026, 3, 1));
      expect(parseStatementDate('2026-03-01'), DateTime(2026, 3, 1));
      expect(parseStatementDate('01 Mar 2026'), DateTime(2026, 3, 1));
      expect(parseStatementDate('20260301'), DateTime(2026, 3, 1));
      expect(parseStatementDate('not a date'), isNull);
    });
  });
}
