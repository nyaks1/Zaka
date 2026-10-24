import '../../data/database.dart';
import 'advisor_service.dart';

/// Deletes all local money data in one transaction, then clears settings and
/// the consent flag.
class PrivacyService {
  PrivacyService(this._database, this._preferences);

  final AppDatabase _database;
  final AdvisorConsentStore _preferences;

  Future<void> deleteEverything() async {
    await _database.deleteEverything();
    await _database.compact();
    await _preferences.clear();
  }
}
