import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:zaka/core/forecast.dart';
import 'package:zaka/data/database.dart';
import 'package:zaka/features/advisor/advisor_service.dart';
import 'package:zaka/features/advisor/advisor_summary.dart';

void main() {
  group('AdvisorSummary', () {
    test('contains only the four allowed fields', () {
      final summary = _summary();

      expect(
        summary.toJson().keys,
        unorderedEquals([
          'runwayDays',
          'dailyBurnRand',
          'categoryPercent',
          'periodDays',
        ]),
      );
    });

    test('never includes a spend note, import key, or account name', () {
      final json = jsonEncode(_summary().toJson());

      expect(json, isNot(contains("Sipho's tuckshop")));
      expect(json, isNot(contains('import-key-secret')));
      expect(json, isNot(contains('Capitec')));
      expect(json, isNot(contains('account')));
      expect(json, contains('Taxi'));
    });

    test('uses the requested period and ignores old or negative spends', () {
      final summary = AdvisorSummary.build(
        _forecast(),
        [
          _spend(1, 4800, 'taxi', DateTime(2026, 3, 2)),
          _spend(2, 5200, 'food', DateTime(2026, 3, 1)),
          _spend(3, 9999, 'other', DateTime(2026, 2, 1)),
          _spend(4, -500, 'other', DateTime(2026, 3, 2)),
        ],
        DateTime(2026, 3, 2, 12),
        days: 7,
      );

      expect(summary.periodDays, 7);
      expect(summary.categoryPercent, {'Food': 52, 'Taxi': 48});
    });

    test('keeps runway unknown when cash lasts past the forecast', () {
      final summary = AdvisorSummary.build(
        _forecast(daysRemaining: null),
        const [],
        DateTime(2026, 3, 2),
      );

      expect(summary.runwayDays, isNull);
      expect(summary.dailyBurnRand, 90);
      expect(summary.categoryPercent, isEmpty);
    });
  });

  group('offlineTip', () {
    test('matches the deterministic demo sentence', () {
      final tip = offlineTip(_summary(), now: DateTime(2026, 3, 2));

      expect(tip, contains('R90 a day'));
      expect(tip, contains('Thursday'));
      expect(tip, contains('Food is 52% of your spend.'));
    });

    test('handles a missing runway and missing categories', () {
      final tip = offlineTip(
        const AdvisorSummary(
          runwayDays: null,
          dailyBurnRand: 90,
          categoryPercent: {},
          periodDays: 14,
        ),
        now: DateTime(2026, 3, 2),
      );

      expect(tip, contains('beyond the forecast window'));
      expect(tip, contains('Log a few spends'));
    });
  });

  group('AdvisorService consent gate', () {
    test('throws before any HTTP call when consent is off', () async {
      final store = _FakeStore(consent: false);
      var called = false;
      final client = MockClient((request) async {
        called = true;
        return http.Response('{}', 200);
      });
      final service = AdvisorService(store, client, 'https://example.test');

      await expectLater(
        service.askAdvisor(_summary()),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'No consent',
          ),
        ),
      );
      expect(called, isFalse);
      expect(store.tokenCalls, 0);
    });

    test('uses the offline tip when no proxy is configured', () async {
      final store = _FakeStore(consent: true);
      var called = false;
      final client = MockClient((request) async {
        called = true;
        return http.Response('{}', 200);
      });
      final service = AdvisorService(store, client, '');

      final reply = await service.askAdvisor(_summary());

      expect(reply.offline, isTrue);
      expect(reply.text, offlineTip(_summary()));
      expect(called, isFalse);
    });

    test('refuses a non-HTTPS proxy before creating a token', () async {
      final store = _FakeStore(consent: true);
      var called = false;
      final client = MockClient((request) async {
        called = true;
        return http.Response('{}', 200);
      });
      final service = AdvisorService(store, client, 'http://example.test');

      final reply = await service.askAdvisor(_summary());

      expect(reply.offline, isTrue);
      expect(reply.error, contains('HTTPS'));
      expect(called, isFalse);
      expect(store.tokenCalls, 0);
    });

    test('sends exactly the summary JSON and the install token', () async {
      final store = _FakeStore(consent: true, token: 'install-token-123');
      late http.Request captured;
      final client = MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({
            'tips': ['Watch the food spend.', 'Keep taxi fares steady.'],
          }),
          200,
        );
      });
      final service = AdvisorService(
        store,
        client,
        'https://advisor.example.test/tips',
      );
      final summary = _summary();

      final reply = await service.askAdvisor(summary);

      expect(captured.method, 'POST');
      expect(captured.headers['X-Install-Token'], 'install-token-123');
      expect(captured.headers['Content-Type'], startsWith('application/json'));
      expect(captured.body, jsonEncode(summary.toJson()));
      expect(reply.offline, isFalse);
      expect(reply.text, contains('Watch the food spend.'));
    });

    test('falls back to the offline tip when the proxy fails', () async {
      final store = _FakeStore(consent: true);
      final client = MockClient((request) async {
        throw const AdvisorException('network down');
      });
      final service = AdvisorService(store, client, 'https://example.test');

      final reply = await service.askAdvisor(_summary());

      expect(reply.offline, isTrue);
      expect(reply.text, offlineTip(_summary()));
      expect(reply.error, contains('network down'));
    });
  });
}

AdvisorSummary _summary() => AdvisorSummary.build(_forecast(), [
  _spend(1, 4800, 'taxi', DateTime(2026, 3, 2), note: "Sipho's tuckshop"),
  _spend(2, 5200, 'food', DateTime(2026, 3, 1), note: 'Lunch'),
], DateTime(2026, 3, 2, 12));

ForecastResult _forecast({int? daysRemaining = 3}) => ForecastResult(
  startingBalanceCents: 100000,
  dailyBurnCents: 9000,
  recurringUpcomingCents: 0,
  daysRemaining: daysRemaining,
  runsOutOn: daysRemaining == null ? null : DateTime(2026, 3, 5),
  points: const [],
  hasHistory: true,
  hasCommitments: false,
  horizonDays: 60,
);

Spend _spend(
  int id,
  int amountCents,
  String category,
  DateTime spentAt, {
  String? note,
}) => Spend(
  id: id,
  amountCents: amountCents,
  category: category,
  spentAt: spentAt,
  note: note,
  accountId: 1,
  importKey: 'import-key-secret',
  source: 'import',
  createdAt: spentAt,
);

class _FakeStore implements AdvisorConsentStore {
  _FakeStore({required this.consent, this.token = 'token'});

  bool consent;
  String token;
  int tokenCalls = 0;

  @override
  Future<bool> hasConsent() async => consent;

  @override
  Future<void> setConsent(bool value) async => consent = value;

  @override
  Future<String> installToken() async {
    tokenCalls++;
    return token;
  }

  @override
  Future<void> clear() async {
    consent = false;
  }
}
