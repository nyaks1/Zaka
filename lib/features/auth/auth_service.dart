import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/dates.dart';
import '../../data/database.dart';

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

extension LocalUserPlan on LocalUser {
  bool get isOwner => role == 'owner';

  bool get isLifetime => isOwner || plan == 'lifetime';

  DateTime? get trialEnd => trialEndsAt;

  bool get isTrialActive {
    final end = trialEndsAt;
    if (plan != 'trial' || end == null) return false;
    return end.isAfter(DateTime.now());
  }

  bool get hasTrialEnded {
    final end = trialEndsAt;
    return plan == 'trial' && end != null && !end.isAfter(DateTime.now());
  }

  int get trialDaysLeft {
    final end = trialEndsAt;
    if (end == null) return 0;
    final today = dateOnly(DateTime.now());
    final last = dateOnly(end);
    final days = last.difference(today).inDays;
    return days < 0 ? 0 : days;
  }

  String get planLabel {
    if (isOwner) return 'Creator · lifetime';
    if (plan == 'lifetime') return 'Lifetime';
    if (isTrialActive) {
      final days = trialDaysLeft;
      return days == 1 ? 'Trial · 1 day left' : 'Trial · $days days left';
    }
    if (hasTrialEnded) return 'Free plan';
    return plan == 'free' ? 'Free plan' : 'Trial';
  }
}

/// Local-first accounts.
///
/// There is no central Zaka user database yet. An account is a row in the
/// on-device SQLite database, the password is PBKDF2-HMAC-SHA256 hashed, and
/// the signed-in user id lives in shared preferences. That keeps the existing
/// privacy promise: money data never leaves the phone.
///
/// The creator is the email in `--dart-define=OWNER_EMAIL=...` (defaulting to
/// the project author). If `OWNER_ACCESS_CODE` is set, the creator must also
/// enter that code once to claim lifetime access. Production roles must live
/// on a server; a local role is a demo convenience, not a security boundary.
class AuthService {
  AuthService(
    this._db, {
    this.trialDays = 90,
    this.pbkdf2Iterations = 60000,
    String? ownerEmail,
    String? ownerAccessCode,
  }) : ownerEmail =
           (ownerEmail ?? defaultOwnerEmail).trim().toLowerCase(),
       ownerAccessCode = ownerAccessCode ?? defaultOwnerAccessCode;

  static const defaultOwnerEmail = String.fromEnvironment(
    'OWNER_EMAIL',
    defaultValue: 'nyakallomasiu@gmail.com',
  );
  static const defaultOwnerAccessCode = String.fromEnvironment(
    'OWNER_ACCESS_CODE',
  );
  static const currentUserKey = 'zaka.currentUserId';

  final AppDatabase _db;
  final int trialDays;
  final int pbkdf2Iterations;
  final String ownerEmail;
  final String ownerAccessCode;

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  String normalizeEmail(String raw) => raw.trim().toLowerCase();

  Future<LocalUser?> currentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(currentUserKey);
    if (id == null) return null;

    final user = await (_db.select(
      _db.localUsers,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    if (user == null) {
      await prefs.remove(currentUserKey);
      return null;
    }
    return user;
  }

  Stream<List<LocalUser>> watchUsers() {
    final query = _db.select(_db.localUsers)
      ..orderBy([
        (table) => OrderingTerm.desc(table.createdAt),
        (table) => OrderingTerm.desc(table.id),
      ]);
    return query.watch();
  }

  Future<LocalUser> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final normalized = normalizeEmail(email);
    _validateEmail(normalized);
    _validatePassword(password);

    final name = displayName.trim().isEmpty
        ? normalized.split('@').first
        : displayName.trim();
    if (name.length > 80) {
      throw const AuthException('Keep your name under 80 characters.');
    }

    final existing = await (_db.select(
      _db.localUsers,
    )..where((table) => table.email.equals(normalized))).getSingleOrNull();
    if (existing != null) {
      throw const AuthException(
        'An account with that email already exists. Sign in instead.',
      );
    }

    final now = DateTime.now();
    final ownerByEmail = ownerEmail.isNotEmpty && normalized == ownerEmail;
    final canAutoClaimOwner = ownerByEmail && ownerAccessCode.isEmpty;
    final trialEnd = now.add(Duration(days: trialDays));

    final id = await _db
        .into(_db.localUsers)
        .insert(
          LocalUsersCompanion.insert(
            email: normalized,
            displayName: name,
            passwordHash: Value(_hashPassword(password)),
            role: Value(canAutoClaimOwner ? 'owner' : 'user'),
            plan: Value(canAutoClaimOwner ? 'lifetime' : 'trial'),
            trialEndsAt: Value(canAutoClaimOwner ? null : trialEnd),
            lastSignInAt: Value(now),
          ),
        );

    await _setCurrentUserId(id);
    return _requireUser(id);
  }

  Future<LocalUser> signIn({
    required String email,
    required String password,
  }) async {
    final normalized = normalizeEmail(email);
    final user = await (_db.select(
      _db.localUsers,
    )..where((table) => table.email.equals(normalized))).getSingleOrNull();

    if (user == null || user.passwordHash == null) {
      throw const AuthException('Email or password is incorrect.');
    }
    if (!_verifyPassword(password, user.passwordHash!)) {
      throw const AuthException('Email or password is incorrect.');
    }

    await _touch(user.id);
    await _setCurrentUserId(user.id);
    return _requireUser(user.id);
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(currentUserKey);
  }

  /// The bridge a real Google sign-in would call after the backend has
  /// verified the Google ID token. It is deliberately not wired to a fake
  /// popup: without a Google OAuth client id there is nothing trustworthy to
  /// verify, so the UI explains the missing configuration instead.
  Future<LocalUser> signInWithVerifiedGoogle({
    required String email,
    required String displayName,
  }) async {
    final normalized = normalizeEmail(email);
    _validateEmail(normalized);

    final existing = await (_db.select(
      _db.localUsers,
    )..where((table) => table.email.equals(normalized))).getSingleOrNull();
    if (existing != null) {
      await _touch(existing.id);
      await _setCurrentUserId(existing.id);
      return _requireUser(existing.id);
    }

    final now = DateTime.now();
    final ownerByEmail = ownerEmail.isNotEmpty && normalized == ownerEmail;
    final id = await _db
        .into(_db.localUsers)
        .insert(
          LocalUsersCompanion.insert(
            email: normalized,
            displayName: displayName.trim().isEmpty
                ? normalized.split('@').first
                : displayName.trim(),
            authProvider: const Value('google'),
            role: Value(ownerByEmail ? 'owner' : 'user'),
            plan: Value(ownerByEmail ? 'lifetime' : 'trial'),
            trialEndsAt: Value(
              ownerByEmail ? null : now.add(Duration(days: trialDays)),
            ),
            lastSignInAt: Value(now),
          ),
        );

    await _setCurrentUserId(id);
    return _requireUser(id);
  }

  /// Lets the creator claim lifetime access on a build where
  /// `OWNER_ACCESS_CODE` was set. Email alone is never enough when a code is
  /// configured.
  Future<LocalUser> claimCreatorAccess(String code) async {
    final user = await currentUser();
    if (user == null) {
      throw const AuthException('Sign in first.');
    }
    if (ownerEmail.isEmpty || user.email != ownerEmail) {
      throw const AuthException(
        'This account is not the configured creator email.',
      );
    }
    if (ownerAccessCode.isEmpty) {
      throw const AuthException(
        'No OWNER_ACCESS_CODE was set for this build. Rebuild with '
        '--dart-define=OWNER_ACCESS_CODE=... to require a code.',
      );
    }
    if (code.trim() != ownerAccessCode) {
      throw const AuthException('That creator code is not correct.');
    }

    await (_db.update(_db.localUsers)..where(
          (table) => table.id.equals(user.id),
        ))
        .write(
          const LocalUsersCompanion(
            role: Value('owner'),
            plan: Value('lifetime'),
            trialEndsAt: Value(null),
          ),
        );
    return _requireUser(user.id);
  }

  Future<LocalUser?> grantPlan(int userId, String plan) async {
    final actor = await currentUser();
    if (actor == null || !actor.isOwner) {
      throw const AuthException('Only the creator can change a plan.');
    }
    if (!const {'trial', 'lifetime', 'free'}.contains(plan)) {
      throw const AuthException('Unknown plan.');
    }

    final now = DateTime.now();
    await (_db.update(
      _db.localUsers,
    )..where((table) => table.id.equals(userId))).write(
      LocalUsersCompanion(
        plan: Value(plan),
        trialEndsAt: Value(
          plan == 'trial' ? now.add(Duration(days: trialDays)) : null,
        ),
      ),
    );
    return _requireUser(userId);
  }

  Future<void> _setCurrentUserId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(currentUserKey, id);
  }

  Future<void> _touch(int id) {
    return (_db.update(
      _db.localUsers,
    )..where((table) => table.id.equals(id))).write(
      LocalUsersCompanion(lastSignInAt: Value(DateTime.now())),
    );
  }

  Future<LocalUser> _requireUser(int id) async {
    final user = await (_db.select(
      _db.localUsers,
    )..where((table) => table.id.equals(id))).getSingle();
    return user;
  }

  void _validateEmail(String email) {
    if (!_emailPattern.hasMatch(email) || email.length > 254) {
      throw const AuthException('Enter a valid email address.');
    }
  }

  void _validatePassword(String password) {
    if (password.length < 8) {
      throw const AuthException('Use at least 8 characters for your password.');
    }
    if (password.length > 200) {
      throw const AuthException('That password is too long.');
    }
  }

  String _hashPassword(String password) {
    final salt = _randomBytes(16);
    final digest = _pbkdf2(
      password: password,
      salt: salt,
      iterations: pbkdf2Iterations,
      keyLength: 32,
    );
    return 'pbkdf2_sha256\$$pbkdf2Iterations\$'
        '${base64UrlEncode(salt)}\$${base64UrlEncode(digest)}';
  }

  bool _verifyPassword(String password, String stored) {
    final parts = stored.split(r'$');
    if (parts.length != 4 || parts.first != 'pbkdf2_sha256') return false;

    final iterations = int.tryParse(parts[1]);
    if (iterations == null || iterations < 1) return false;

    try {
      final salt = base64Url.decode(parts[2]);
      final expected = base64Url.decode(parts[3]);
      final actual = _pbkdf2(
        password: password,
        salt: salt,
        iterations: iterations,
        keyLength: expected.length,
      );
      return _constantTimeEquals(actual, expected);
    } on FormatException {
      return false;
    }
  }

  static List<int> _randomBytes(int length) {
    final random = Random.secure();
    return List<int>.generate(length, (_) => random.nextInt(256));
  }

  /// PBKDF2-HMAC-SHA256, implemented here so account creation works on every
  /// Flutter target without a native dependency.
  static List<int> _pbkdf2({
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

  static List<int> _intToBytes(int value) => [
    (value >> 24) & 0xff,
    (value >> 16) & 0xff,
    (value >> 8) & 0xff,
    value & 0xff,
  ];

  static bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}
