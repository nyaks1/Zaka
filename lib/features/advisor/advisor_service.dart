import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/dates.dart';
import '../../core/money.dart';
import 'advisor_summary.dart';

/// Small seam so the consent gate and the network call can be tested without
/// a real preferences plugin.
abstract class AdvisorConsentStore {
  Future<bool> hasConsent();
  Future<void> setConsent(bool value);
  Future<String> installToken();
  Future<void> clear();
}

class AdvisorPreferences implements AdvisorConsentStore {
  static const consentKey = 'consentAdvisor';
  static const installTokenKey = 'advisorInstallToken';

  @override
  Future<bool> hasConsent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(consentKey) ?? false;
  }

  @override
  Future<void> setConsent(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(consentKey, value);
  }

  @override
  Future<String> installToken() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(installTokenKey);
    if (existing != null && existing.isNotEmpty) return existing;

    final random = Random.secure();
    final bytes = List<int>.generate(24, (_) => random.nextInt(256));
    final token = base64UrlEncode(bytes).replaceAll('=', '');
    await prefs.setString(installTokenKey, token);
    return token;
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

class AdvisorReply {
  const AdvisorReply({required this.text, required this.offline, this.error});

  final String text;
  final bool offline;
  final String? error;
}

bool _isLocalHost(String host) =>
    host == 'localhost' || host == '127.0.0.1' || host == '::1';

class AdvisorException implements Exception {
  const AdvisorException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// The consent gate is the first statement in [askAdvisor]. No HTTP request can
/// happen before the stored consent flag is checked.
class AdvisorService {
  AdvisorService(this._preferences, this._client, this._proxyUrl);

  final AdvisorConsentStore _preferences;
  final http.Client _client;
  final String _proxyUrl;

  Future<AdvisorReply> askAdvisor(AdvisorSummary summary) async {
    if (!await _preferences.hasConsent()) {
      throw StateError('No consent');
    }

    final url = _proxyUrl.trim();
    if (url.isEmpty) {
      return AdvisorReply(
        text: offlineTip(summary),
        offline: true,
        error: 'No advisor proxy is configured.',
      );
    }

    final uri = Uri.tryParse(url);
    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'https' && !_isLocalHost(uri.host))) {
      return AdvisorReply(
        text: offlineTip(summary),
        offline: true,
        error: 'The advisor proxy must use HTTPS.',
      );
    }

    try {
      final token = await _preferences.installToken();
      final response = await _client
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'X-Install-Token': token,
            },
            body: jsonEncode(summary.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw AdvisorException(
          'The advisor proxy returned ${response.statusCode}.',
        );
      }

      return AdvisorReply(
        text: _extractTips(jsonDecode(response.body)),
        offline: false,
      );
    } catch (error) {
      return AdvisorReply(
        text: offlineTip(summary),
        offline: true,
        error: '$error',
      );
    }
  }

  String _extractTips(Object? body) {
    if (body is! Map<String, dynamic>) {
      throw const AdvisorException('The advisor reply was not an object.');
    }

    final tips = body['tips'];
    if (tips is String && tips.trim().isNotEmpty) return tips.trim();
    if (tips is List) {
      final text = tips
          .whereType<String>()
          .map((tip) => tip.trim())
          .where((tip) => tip.isNotEmpty)
          .join('\n\n');
      if (text.isNotEmpty) return text;
    }

    final text = body['text'];
    if (text is String && text.trim().isNotEmpty) return text.trim();

    throw const AdvisorException('The advisor reply had no tips.');
  }
}

/// A deterministic, network-free tip. This is what the card shows before
/// consent and what the app falls back to if the proxy is unavailable.
String offlineTip(AdvisorSummary summary, {DateTime? now}) {
  final burnCents = (summary.dailyBurnRand * 100).round();
  final runwayDays = summary.runwayDays;

  if (burnCents <= 0) {
    return 'Log a few spends and Zaka will show your daily burn and where your '
        'money goes.';
  }

  final String runway;
  if (runwayDays == null) {
    runway =
        'At ${formatCentsCompact(burnCents)} a day, your cash lasts beyond '
        'the forecast window.';
  } else if (runwayDays <= 0) {
    runway =
        'At ${formatCentsCompact(burnCents)} a day, your cash runs out today.';
  } else {
    final date = dateOnly(now ?? DateTime.now())
        .add(Duration(days: runwayDays));
    final day = runwayDays == 1 ? 'tomorrow' : DateFormat('EEEE').format(date);
    runway =
        'At ${formatCentsCompact(burnCents)} a day, your cash runs out '
        '$day.';
  }

  final top = summary.categoryPercent.entries.isEmpty
      ? null
      : summary.categoryPercent.entries.first;
  final category = top == null
      ? 'Log a few spends so I can show where most of your money goes.'
      : '${top.key} is ${top.value}% of your spend.';

  return '$runway $category';
}
