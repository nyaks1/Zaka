import 'dart:io';

/// A short, non-identifying platform string for an opt-in feedback report.
/// On Android this is typically `Android 16 (SDK 36)`.
String get androidVersionLabel {
  final value = Platform.operatingSystemVersion.trim();
  if (value.isEmpty) return 'unknown';
  return value.length <= 80 ? value : value.substring(0, 80);
}
