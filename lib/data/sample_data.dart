import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/dates.dart';
import '../providers.dart';

Future<void> loadSampleData(WidgetRef ref) async {
  final repo = ref.read(cashRepositoryProvider);
  final importer = ref.read(statementImporterProvider);
  final now = DateTime.now();
  final d0 = dateOnly(now);
  final d1 = d0.subtract(const Duration(days: 1));
  final d2 = d0.subtract(const Duration(days: 2));
  final d3 = d0.subtract(const Duration(days: 3));

  final bankId = await repo.addAccount(
    name: 'FNB Cheque',
    institution: 'FNB',
    kind: 'cheque',
  );

  final csv = '''Date,Description,Amount,Balance
${d3.day.toString().padLeft(2, '0')}/${d3.month.toString().padLeft(2, '0')}/${d3.year},SALARY DEPOSIT,18500.00,19000.00
${d2.day.toString().padLeft(2, '0')}/${d2.month.toString().padLeft(2, '0')}/${d2.year},ATM CASH WITHDRAWAL,-500.00,18500.00
${d1.day.toString().padLeft(2, '0')}/${d1.month.toString().padLeft(2, '0')}/${d1.year},TAXI - BREE,-35.00,18465.00
${d0.day.toString().padLeft(2, '0')}/${d0.month.toString().padLeft(2, '0')}/${d0.year},PICK N PAY GROCERIES,-240.00,18225.00
''';

  await importer.import(accountId: bankId, content: csv);
}
