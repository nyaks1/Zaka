import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zaka/data/database.dart';
import 'package:zaka/features/auth/auth_service.dart';

void main() {
  late AppDatabase database;
  late AuthService auth;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    database = AppDatabase.forTesting(NativeDatabase.memory());
    auth = AuthService(
      database,
      trialDays: 90,
      pbkdf2Iterations: 400,
      ownerEmail: 'creator@zaka.test',
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('a new email account gets a 90-day trial and signs in', () async {
    final user = await auth.register(
      email: '  Thandi@Example.com ',
      password: 'correct horse battery',
      displayName: 'Thandi Mokoena',
    );

    expect(user.email, 'thandi@example.com');
    expect(user.displayName, 'Thandi Mokoena');
    expect(user.authProvider, 'email');
    expect(user.role, 'user');
    expect(user.plan, 'trial');
    expect(user.isTrialActive, isTrue);
    expect(user.trialDaysLeft, inInclusiveRange(89, 90));
    expect(user.passwordHash, startsWith('pbkdf2_sha256\$'));
    expect(user.passwordHash, isNot(contains('correct horse battery')));
    expect((await auth.currentUser())?.id, user.id);
  });

  test('duplicate emails are rejected', () async {
    await auth.register(
      email: 'thandi@example.com',
      password: 'correct horse battery',
      displayName: 'Thandi',
    );

    await expectLater(
      auth.register(
        email: 'THANDI@example.com',
        password: 'another password',
        displayName: 'Someone else',
      ),
      throwsA(isA<AuthException>()),
    );
  });

  test('sign-in checks the password and updates last sign-in', () async {
    await auth.register(
      email: 'thandi@example.com',
      password: 'correct horse battery',
      displayName: 'Thandi',
    );
    await auth.signOut();

    expect(await auth.currentUser(), isNull);
    await expectLater(
      auth.signIn(email: 'thandi@example.com', password: 'wrong password'),
      throwsA(isA<AuthException>()),
    );

    final signedIn = await auth.signIn(
      email: 'thandi@example.com',
      password: 'correct horse battery',
    );
    expect(signedIn.lastSignInAt, isNotNull);
    expect((await auth.currentUser())?.email, 'thandi@example.com');
  });

  test('the configured creator email gets lifetime access automatically', () async {
    final owner = await auth.register(
      email: 'creator@zaka.test',
      password: 'correct horse battery',
      displayName: 'Nyakallo',
    );

    expect(owner.role, 'owner');
    expect(owner.plan, 'lifetime');
    expect(owner.isLifetime, isTrue);
    expect(owner.trialEndsAt, isNull);
    expect(owner.planLabel, contains('lifetime'));
  });

  test('when a creator code is set, email alone is not enough', () async {
    final locked = AuthService(
      database,
      trialDays: 90,
      pbkdf2Iterations: 400,
      ownerEmail: 'creator@zaka.test',
      ownerAccessCode: 'opensesame',
    );

    final user = await locked.register(
      email: 'creator@zaka.test',
      password: 'correct horse battery',
      displayName: 'Nyakallo',
    );
    expect(user.role, 'user');
    expect(user.plan, 'trial');

    await expectLater(
      locked.claimCreatorAccess('wrong'),
      throwsA(isA<AuthException>()),
    );

    final owner = await locked.claimCreatorAccess('opensesame');
    expect(owner.role, 'owner');
    expect(owner.plan, 'lifetime');
    expect(owner.isLifetime, isTrue);
  });

  test('only the creator can grant a plan', () async {
    final owner = await auth.register(
      email: 'creator@zaka.test',
      password: 'correct horse battery',
      displayName: 'Nyakallo',
    );
    final member = await auth.register(
      email: 'thandi@example.com',
      password: 'correct horse battery',
      displayName: 'Thandi',
    );

    await expectLater(
      auth.grantPlan(owner.id, 'free'),
      throwsA(isA<AuthException>()),
    );

    await auth.signOut();
    await auth.signIn(
      email: 'creator@zaka.test',
      password: 'correct horse battery',
    );

    final updated = await auth.grantPlan(member.id, 'lifetime');
    expect(updated, isNotNull);
    expect(updated!.plan, 'lifetime');
    expect(updated.isLifetime, isTrue);
  });

  test('an expired trial falls back to the free plan, not a lockout', () async {
    final expired = AuthService(
      database,
      trialDays: -1,
      pbkdf2Iterations: 400,
      ownerEmail: 'creator@zaka.test',
    );

    final user = await expired.register(
      email: 'thandi@example.com',
      password: 'correct horse battery',
      displayName: 'Thandi',
    );

    expect(user.isTrialActive, isFalse);
    expect(user.hasTrialEnded, isTrue);
    expect(user.trialDaysLeft, 0);
    expect(user.planLabel, 'Free plan');
  });
}
