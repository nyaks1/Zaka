import 'package:intl/intl.dart';

final NumberFormat _rand = NumberFormat.currency(
  locale: 'en_US',
  symbol: 'R',
  decimalDigits: 2,
);

final NumberFormat _randCompact = NumberFormat.currency(
  locale: 'en_US',
  symbol: 'R',
  decimalDigits: 0,
);

/// R1,234.50
String formatCents(int cents) => _rand.format(cents / 100);

/// R1,235 (used for axis labels and summary chips).
String formatCentsCompact(int cents) => _randCompact.format(cents / 100);

/// Parses user input like "35", "35.50" or "R 35,50" into cents.
/// Returns null for empty, zero or invalid input.
int? parseRandToCents(String raw) {
  final cents = parseSignedRandToCents(raw);
  if (cents == null || cents <= 0) return null;
  return cents;
}

/// Like [parseRandToCents], but allows a negative opening balance for a
/// credit account or loan. Zero is valid here.
int? parseSignedRandToCents(String raw) {
  var cleaned = raw.replaceAll(RegExp(r'[^0-9.,-]'), '');
  if (cleaned.isEmpty) return null;

  final negative = cleaned.startsWith('-');
  cleaned = cleaned.replaceAll('-', '');
  if (cleaned.isEmpty) return null;

  // Treat a lone comma as a decimal separator; drop thousands separators.
  if (cleaned.contains(',') && !cleaned.contains('.')) {
    cleaned = cleaned.replaceAll(',', '.');
  } else {
    cleaned = cleaned.replaceAll(',', '');
  }

  final value = double.tryParse(cleaned);
  if (value == null || !value.isFinite) return null;
  final cents = (value * 100).round();
  return negative ? -cents : cents;
}
