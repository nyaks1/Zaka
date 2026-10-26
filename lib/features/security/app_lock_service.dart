import 'package:shared_preferences/shared_preferences.dart';

import '../../core/passwords.dart';

/// Optional PIN lock for the app. It stores only a salted PBKDF2 hash, never
/// the PIN itself. Biometrics are not wired in this build: that needs a native
/// plugin and an extra permission.
class AppLockService {
  static const pinKey = 'zaka.appLockPin';

  Future<bool> hasPin() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(pinKey);
    return stored != null && stored.isNotEmpty;
  }

  Future<void> setPin(String pin) async {
    final value = pin.trim();
    if (!isValidPin(value)) {
      throw const FormatException('Use a PIN of 4 to 8 digits.');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(pinKey, hashPassword(value));
  }

  Future<bool> verifyPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(pinKey);
    if (stored == null || stored.isEmpty) return false;
    return verifyPassword(pin.trim(), stored);
  }

  Future<void> clearPin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(pinKey);
  }

  static bool isValidPin(String pin) =>
      RegExp(r'^\d{4,8}$').hasMatch(pin.trim());
}
