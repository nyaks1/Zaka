/// The seam for a future live bank feed.
///
/// A real implementation (for example Stitch) needs a small backend to hold
/// the provider secret and exchange consent codes for tokens. The Flutter app
/// only ever sees the normalised models below, never a bank password or a
/// provider secret.
library;

class LinkedBankAccount {
  const LinkedBankAccount({
    required this.providerAccountId,
    required this.name,
    required this.institution,
    required this.kind,
    this.maskedNumber,
    this.currency = 'ZAR',
  });

  final String providerAccountId;
  final String name;
  final String institution;
  final String kind;
  final String? maskedNumber;
  final String currency;
}

class BankTransaction {
  const BankTransaction({
    required this.providerTransactionId,
    required this.providerAccountId,
    required this.postedAt,
    required this.description,
    required this.amountCents,
    this.pending = false,
  });

  final String providerTransactionId;
  final String providerAccountId;
  final DateTime postedAt;
  final String description;

  /// Positive for money in, negative for money out.
  final int amountCents;
  final bool pending;
}

class BankConsent {
  const BankConsent({
    required this.connectionId,
    required this.institution,
    required this.expiresAt,
  });

  final String connectionId;
  final String institution;
  final DateTime expiresAt;
}

/// Implement this against a provider's backend. Keep the app-side API small
/// and stable so the local statement importer and a live feed can share the
/// same normalisation and deduplication code.
abstract interface class BankProvider {
  String get id;
  String get displayName;

  /// Opens the provider's consent screen. The backend creates the link and
  /// returns the URL the app should open in a secure browser.
  Future<Uri> startLink({required Uri redirectUri, required String state});

  /// Completes the callback on the backend and returns the stored connection.
  Future<BankConsent> completeLink({required Uri callbackUri});

  Future<List<LinkedBankAccount>> accounts(String connectionId);

  Future<List<BankTransaction>> transactions({
    required String connectionId,
    required String providerAccountId,
    DateTime? since,
  });

  Future<void> revoke(String connectionId);
}
