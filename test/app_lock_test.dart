import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zaka/features/security/app_lock_gate.dart';
import 'package:zaka/features/security/app_lock_service.dart';
import 'package:zaka/providers.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('a PIN is hashed, verified and cleared', () async {
    final service = AppLockService();
    expect(await service.hasPin(), isFalse);
    expect(AppLockService.isValidPin('123'), isFalse);
    expect(AppLockService.isValidPin('1234'), isTrue);

    await service.setPin('1234');
    expect(await service.hasPin(), isTrue);
    expect(await service.verifyPin('1234'), isTrue);
    expect(await service.verifyPin('9999'), isFalse);

    await service.clearPin();
    expect(await service.hasPin(), isFalse);
  });

  testWidgets('the gate asks for the PIN and opens on success', (tester) async {
    final service = AppLockService();
    await service.setPin('1234');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appLockServiceProvider.overrideWithValue(service)],
        child: const MaterialApp(
          home: AppLockGate(child: Scaffold(body: Text('home'))),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Zaka is locked'), findsOneWidget);
    expect(find.text('home'), findsNothing);

    await tester.enterText(find.byType(TextField), '9999');
    await tester.tap(find.text('Unlock'));
    await tester.pumpAndSettle();
    expect(find.text('That PIN is not correct.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '1234');
    await tester.tap(find.text('Unlock'));
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
  });
}
