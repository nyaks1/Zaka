import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:zaka/core/statement.dart';

void main() {
  test('the synthetic demo CSV parses and keeps its ATM rows', () {
    final csv = File('demo/synthetic-fnb-statement.csv').readAsStringSync();

    final result = parseStatementCsv(csv);

    expect(result.rows, hasLength(21));
    expect(result.rows.first.date, DateTime(2026, 9, 1));
    expect(result.creditCents, 1500000);
    expect(
      result.rows.where((row) => row.description.contains('ATM')),
      hasLength(2),
    );
    expect(result.warnings, isEmpty);
  });
}
