import '../../data/database.dart';
import '../auth/auth_service.dart';
import '../security/app_lock_service.dart';
import 'advisor_service.dart';

/// Deletes all local money data in one transaction, then removes the local
/// Zaka accounts and sign-in, the app-lock PIN, and the Ask Zaka settings.
class PrivacyService {
  PrivacyService(
    this._database,
    this._preferences,
    this._auth,
    this._appLock,
  );

  final AppDatabase _database;
  final AdvisorConsentStore _preferences;
  final AuthService _auth;
  final AppLockService _appLock;

  Future<void> deleteEverything() async {
    await _database.deleteEverything();
    await _auth.deleteAllLocalUsers();
    await _appLock.clearPin();
    await _database.compact();
    await _preferences.clear();
  }
}
