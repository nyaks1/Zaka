import 'package:flutter_test/flutter_test.dart';
import 'package:zaka/core/money.dart';

void main() {
  group('parseRandToCents', () {
    test('parses whole rands', () {
      expect(parseRandToCents('35'), 3500);
    });

    test('parses rands and cents', () {
      expect(parseRandToCents('35.50'), 3550);
      expect(parseRandToCents('35,50'), 3550);
    });

    test('strips currency symbols and thousands separators', () {
      expect(parseRandToCents('R 1,234.50'), 123450);
      expect(parseRandToCents('R 1 234,50'), 123450);
    });

    test('rejects empty, zero and junk input', () {
      expect(parseRandToCents(''), isNull);
      expect(parseRandToCents('0'), isNull);
      expect(parseRandToCents('abc'), isNull);
      expect(parseRandToCents('.'), isNull);
    });
  });

  group('formatCents', () {
    test('formats cents as rands', () {
      expect(formatCents(123450), 'R1,234.50');
      expect(formatCents(0), 'R0.00');
    });
  });
}
