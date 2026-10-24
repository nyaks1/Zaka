import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:zaka/core/statement.dart';
import 'package:zaka/data/pdf_statement.dart';

void main() {
  test('extracts text and transactions from a text PDF', () async {
    final bytes = _buildPdf([
      '01 Mar 2026 SALARY DEPOSIT 28,500.00 29,500.00',
      '02 Mar 2026 TAXI - BREE -35.00 29,465.00',
      '03 Mar 2026 PICK N PAY, ROSEBANK 345.99- 29,119.01',
    ]);

    final text = extractPdfText(bytes);
    expect(text, contains('TAXI - BREE'));

    final parsed = await parsePdfStatement(bytes);
    expect(parsed.rows, hasLength(3));
    expect(parsed.rows.first.amountCents, 2850000);
    expect(parsed.rows[1].amountCents, -3500);
    expect(parsed.rows[2].amountCents, -34599);
  });

  test('rejects a PDF with no selectable text', () async {
    final bytes = _buildPdf(const []);

    expect(
      () => parsePdfStatement(bytes),
      throwsA(isA<StatementFormatException>()),
    );
  });
}

Uint8List _buildPdf(List<String> lines) {
  final content = StringBuffer()
    ..writeln('BT')
    ..writeln('/F1 12 Tf')
    ..writeln('72 720 Td');
  for (var i = 0; i < lines.length; i++) {
    if (i > 0) content.writeln('0 -20 Td');
    content.writeln('(${lines[i]}) Tj');
  }
  content.writeln('ET');
  final stream = content.toString();

  final objects = <String>[
    '<< /Type /Catalog /Pages 2 0 R >>',
    '<< /Type /Pages /Kids [3 0 R] /Count 1 >>',
    '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] '
        '/Resources << /Font << /F1 4 0 R >> >> /Contents 5 0 R >>',
    '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>',
    '<< /Length ${stream.length} >>\nstream\n$stream'
        'endstream',
  ];

  final buffer = StringBuffer('%PDF-1.4\n');
  final offsets = <int>[];
  for (var i = 0; i < objects.length; i++) {
    offsets.add(utf8.encode(buffer.toString()).length);
    buffer
      ..writeln('${i + 1} 0 obj')
      ..writeln(objects[i])
      ..writeln('endobj');
  }

  final xrefOffset = utf8.encode(buffer.toString()).length;
  buffer
    ..writeln('xref')
    ..writeln('0 ${objects.length + 1}')
    ..writeln('0000000000 65535 f ');
  for (final offset in offsets) {
    buffer.writeln('${offset.toString().padLeft(10, '0')} 00000 n ');
  }
  buffer
    ..writeln('trailer')
    ..writeln('<< /Size ${objects.length + 1} /Root 1 0 R >>')
    ..writeln('startxref')
    ..writeln('$xrefOffset')
    ..writeln('%%EOF');

  return Uint8List.fromList(utf8.encode(buffer.toString()));
}
