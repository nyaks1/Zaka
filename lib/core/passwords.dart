import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Shared PBKDF2-HMAC-SHA256 helpers for local account passwords and the
/// optional app-lock PIN. The stored format is:
///
/// `pbkdf2_sha256$iterations$base64UrlSalt$base64UrlHash`
const int defaultPbkdf2Iterations = 60000;

String hashPassword(
  String password, {
  int iterations = defaultPbkdf2Iterations,
}) {
  final salt = randomBytes(16);
  final digest = pbkdf2(
    password: password,
    salt: salt,
    iterations: iterations,
    keyLength: 32,
  );
  return 'pbkdf2_sha256\$$iterations\$'
      '${base64UrlEncode(salt)}\$${base64UrlEncode(digest)}';
}

bool verifyPassword(String password, String stored) {
  final parts = stored.split(r'$');
  if (parts.length != 4 || parts.first != 'pbkdf2_sha256') return false;

  final iterations = int.tryParse(parts[1]);
  if (iterations == null || iterations < 1) return false;

  try {
    final salt = base64Url.decode(parts[2]);
    final expected = base64Url.decode(parts[3]);
    final actual = pbkdf2(
      password: password,
      salt: salt,
      iterations: iterations,
      keyLength: expected.length,
    );
    return constantTimeEquals(actual, expected);
  } on FormatException {
    return false;
  }
}

List<int> randomBytes(int length) {
  final random = Random.secure();
  return List<int>.generate(length, (_) => random.nextInt(256));
}

/// PBKDF2-HMAC-SHA256, implemented here so account creation and the app lock
/// work on every Flutter target without a native dependency.
List<int> pbkdf2({
  required String password,
  required List<int> salt,
  required int iterations,
  required int keyLength,
}) {
  final hmac = Hmac(sha256, utf8.encode(password));
  final output = <int>[];
  var block = 1;

  while (output.length < keyLength) {
    var u = hmac.convert([...salt, ..._intToBytes(block)]).bytes;
    final t = List<int>.from(u);
    for (var i = 1; i < iterations; i++) {
      u = hmac.convert(u).bytes;
      for (var j = 0; j < t.length; j++) {
        t[j] ^= u[j];
      }
    }
    output.addAll(t);
    block++;
  }

  return output.sublist(0, keyLength);
}

bool constantTimeEquals(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  var diff = 0;
  for (var i = 0; i < a.length; i++) {
    diff |= a[i] ^ b[i];
  }
  return diff == 0;
}

List<int> _intToBytes(int value) => [
  (value >> 24) & 0xff,
  (value >> 16) & 0xff,
  (value >> 8) & 0xff,
  value & 0xff,
];
