import 'package:flutter/foundation.dart';
import 'package:pdf_cos/pdf_cos.dart';
import 'package:pdf_document/pdf_document.dart';
import 'package:pdf_graphics/pdf_graphics.dart';

import '../core/statement.dart';

/// The PDF is encrypted and the supplied password did not open it.
class PdfPasswordException implements Exception {
  const PdfPasswordException();

  @override
  String toString() => 'This PDF needs a password.';
}

/// Extracts selectable text from a PDF statement and turns it into the same
/// rows the CSV importer uses.
///
/// This works for text-based PDFs. A scanned statement (a photograph inside a
/// PDF) has no text layer and needs OCR, so it is rejected with a clear error
/// rather than silently importing nothing.
Future<StatementParseResult> parsePdfStatement(
  Uint8List bytes, {
  DateTime? now,
  String password = '',
}) async {
  final result = await compute(_extractPdfTextIsolate, {
    'bytes': bytes,
    'password': password,
  });
  if (result['needsPassword'] == true) {
    throw const PdfPasswordException();
  }
  final text = result['text'] as String?;
  if (text == null) {
    throw StatementFormatException(
      'Could not read this PDF. If it is a scanned image, export a CSV '
      'statement instead. (${result['error']})',
    );
  }

  if (text.trim().length < 20) {
    throw const StatementFormatException(
      'This PDF has no selectable text. It may be a scanned image. Export a '
      'CSV statement from Online Banking instead.',
    );
  }

  return parseStatementText(text, now: now);
}

Map<String, Object?> _extractPdfTextIsolate(Map<String, Object?> request) {
  try {
    return {
      'text': extractPdfText(
        request['bytes']! as Uint8List,
        password: request['password']! as String,
      ),
    };
  } on CosPasswordException {
    return {'needsPassword': true};
  } catch (error) {
    return {'error': '$error'};
  }
}

/// Pure-Dart text extraction so it also works in unit tests and on the web.
String extractPdfText(Uint8List bytes, {String password = ''}) {
  final document = PdfDocument.open(bytes, password: password);
  final buffer = StringBuffer();
  for (var page = 0; page < document.pageCount; page++) {
    final text = PdfTextExtractor.extract(document, page).text;
    if (text.trim().isNotEmpty) {
      buffer.writeln(text);
    }
  }
  return buffer.toString();
}
