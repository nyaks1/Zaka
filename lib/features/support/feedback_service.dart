import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/platform_info.dart';
import '../advisor/advisor_service.dart';

class FeedbackException implements Exception {
  const FeedbackException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Sends one feedback message to the Worker's `/feedback` route. The Worker
/// forwards it to a webhook and stores nothing. No money data is included.
class FeedbackService {
  FeedbackService(this._preferences, this._client, this._proxyUrl);

  final AdvisorConsentStore _preferences;
  final http.Client _client;

  /// Base Worker URL, for example `https://zaka-advisor.example.workers.dev`.
  final String _proxyUrl;

  bool get isConfigured => _proxyUrl.trim().isNotEmpty;

  Future<void> send({
    required String message,
    bool includeDiagnostics = false,
    String? replyTo,
  }) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) {
      throw const FeedbackException('Write a message first.');
    }
    if (trimmed.length > 2000) {
      throw const FeedbackException('Keep the message under 2,000 characters.');
    }

    final rawUrl = _proxyUrl.trim();
    if (rawUrl.isEmpty) {
      throw const FeedbackException(
        'The feedback service is not configured in this build. Copy the '
        'contact above instead.',
      );
    }

    final base = Uri.tryParse(rawUrl);
    if (base == null ||
        !base.hasScheme ||
        (base.scheme != 'https' &&
            base.host != 'localhost' &&
            base.host != '127.0.0.1' &&
            base.host != '::1')) {
      throw const FeedbackException('The feedback service must use HTTPS.');
    }

    final uri = base.replace(
      path: '${base.path.replaceAll(RegExp(r'/$'), '')}/feedback',
    );

    final body = <String, String>{'message': trimmed};
    if (includeDiagnostics) {
      body['appVersion'] = _appVersion;
      body['androidVersion'] = androidVersionLabel;
    }
    final email = (replyTo ?? '').trim();
    if (email.isNotEmpty) body['replyTo'] = email;

    try {
      final token = await _preferences.installToken();
      final response = await _client
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'X-Install-Token': token,
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200 && response.statusCode != 202) {
        throw FeedbackException(
          'The feedback service returned ${response.statusCode}.',
        );
      }
    } on FeedbackException {
      rethrow;
    } catch (error) {
      throw FeedbackException('Could not send feedback: $error');
    }
  }

  static const _appVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '0.1.0+1',
  );
}
