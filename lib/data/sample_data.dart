import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/dates.dart';
import '../providers.dart';

/// The sample statement is a small, realistic cash-flow story: a R900 piece
/// job lands in the bank, R500 comes out at the ATM, then a taxi fare and
/// groceries are spent. The imports leave R125 in the bank and R500 in cash,
/// so the R625 total burns down in about five days at the recent burn rate.
String buildSampleStatementCsv(DateTime now) {
  final d0 = dateOnly(now);
  final d1 = d0.subtract(const Duration(days: 1));
  final d2 = d0.subtract(const Duration(days: 2));
  final d3 = d0.subtract(const Duration(days: 3));

  String row(DateTime day, String description, String amount, String balance) {
    final date =
        '${day.day.toString().padLeft(2, '0')}/'
        '${day.month.toString().padLeft(2, '0')}/${day.year}';
    return '$date,$description,$amount,$balance\n';
  }

  return 'Date,Description,Amount,Balance\n'
      '${row(d3, 'PIECE JOB PAYMENT', '900.00', '900.00')}'
      '${row(d2, 'ATM CASH WITHDRAWAL', '-500.00', '400.00')}'
      '${row(d1, 'TAXI - BREE', '-35.00', '365.00')}'
      '${row(d0, 'PICK N PAY GROCERIES', '-240.00', '125.00')}';
}

Future<void> loadSampleData(WidgetRef ref) async {
  final repo = ref.read(cashRepositoryProvider);
  final importer = ref.read(statementImporterProvider);

  final bankId = await repo.addAccount(
    name: 'FNB Cheque',
    institution: 'FNB',
    kind: 'cheque',
  );

  await importer.import(
    accountId: bankId,
    content: buildSampleStatementCsv(DateTime.now()),
  );
}
