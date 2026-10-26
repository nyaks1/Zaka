import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/database.dart';
import '../../providers.dart';
import '../support/about_screen.dart';
import '../support/feedback_contact_tile.dart';
import '../support/privacy_policy_screen.dart';
import '../security/app_lock_service.dart';
import 'admin_users_screen.dart';
import 'auth_screen.dart';
import 'auth_service.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  void _openAuth(BuildContext context, AuthMode mode) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AuthScreen(initialMode: mode),
      ),
    );
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(authServiceProvider).signOut();
    ref.invalidate(currentUserProvider);
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Signed out.')));
  }

  Future<void> _claimCreator(
    BuildContext context,
    WidgetRef ref,
    String ownerEmail,
  ) async {
    final controller = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Claim creator access'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This account matches the creator email $ownerEmail. Enter the '
              'OWNER_ACCESS_CODE from the build to unlock lifetime access.',
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              obscureText: true,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Creator code'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Unlock'),
          ),
        ],
      ),
    );
    if (code == null || !context.mounted) return;

    try {
      await ref.read(authServiceProvider).claimCreatorAccess(code);
      ref.invalidate(currentUserProvider);
      ref.invalidate(localUsersProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Creator access unlocked.')),
      );
    } on AuthException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final current = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: current.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Could not load: $error')),
        data: (user) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            if (user == null)
              _SignedOutCard(
                onCreate: () => _openAuth(context, AuthMode.signUp),
                onSignIn: () => _openAuth(context, AuthMode.signIn),
              )
            else
              _ProfileCard(
                user: user,
                onSignOut: () => _signOut(context, ref),
              ),
            if (user != null && user.isOwner) ...[
              const SizedBox(height: 14),
              Card(
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  contentPadding: const EdgeInsets.fromLTRB(18, 8, 14, 8),
                  leading: const Icon(Boxicons.bx_group),
                  title: const Text('Users'),
                  subtitle: const Text(
                    'See every account on this device and change a plan.',
                  ),
                  trailing: const Icon(Boxicons.bx_chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const AdminUsersScreen(),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),
            _TrialExplainer(user: user),
            const SizedBox(height: 14),
            const _AppLockCard(),
            const SizedBox(height: 14),
            const FeedbackContactCard(),
            const SizedBox(height: 14),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Boxicons.bx_shield),
                    title: const Text('Privacy policy'),
                    subtitle: const Text(
                      'What stays on the phone, retention and your rights',
                    ),
                    trailing: const Icon(Boxicons.bx_chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const PrivacyPolicyScreen(),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Boxicons.bx_info_circle),
                    title: const Text('About Zaka'),
                    subtitle: const Text('Version, licences and credit'),
                    trailing: const Icon(Boxicons.bx_chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AboutScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (user != null &&
                !user.isLifetime &&
                user.email == ref.read(authServiceProvider).ownerEmail &&
                ref.read(authServiceProvider).ownerAccessCode.isNotEmpty) ...[
              const SizedBox(height: 14),
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Creator email detected',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'This is the configured creator email. Enter the '
                        'creator code from the build to switch on lifetime '
                        'access and the user console.',
                        style: theme.textTheme.bodySmall?.copyWith(height: 1.45),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => _claimCreator(
                          context,
                          ref,
                          ref.read(authServiceProvider).ownerEmail,
                        ),
                        icon: const Icon(Boxicons.bx_key, size: 16),
                        label: const Text('Unlock creator access'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Text(
              'Zaka accounts are local to this device in this build. Creating '
              'an account does not upload your money data. A central user '
              'directory, email verification and Google sign-in need a small '
              'backend; see docs/accounts.md.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignedOutCard extends StatelessWidget {
  const _SignedOutCard({required this.onCreate, required this.onSignIn});

  final VoidCallback onCreate;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Boxicons.bx_user_circle, size: 32),
          const SizedBox(height: 14),
          Text(
            'Start your 3-month trial',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create an account to keep your plan in one place. You can still '
            'use Zaka without one; your cash data stays on this phone either '
            'way.',
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Boxicons.bx_user_plus),
            label: const Text('Create free account'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onSignIn,
            icon: const Icon(Boxicons.bx_log_in),
            label: const Text('Sign in'),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.user, required this.onSignOut});

  final LocalUser user;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: theme.colorScheme.onSurface,
                child: Text(
                  _initials(user.displayName),
                  style: TextStyle(
                    color: theme.colorScheme.surface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Pill(label: user.planLabel, strong: user.isLifetime),
              _Pill(
                label: user.authProvider == 'google'
                    ? 'Google account'
                    : 'Email account',
              ),
              if (user.isOwner) const _Pill(label: 'Creator', strong: true),
            ],
          ),
          if (user.trialEndsAt != null) ...[
            const SizedBox(height: 12),
            Text(
              user.isTrialActive
                  ? 'Trial ends ${DateFormat('d MMM yyyy').format(user.trialEndsAt!)}.'
                  : 'Trial ended ${DateFormat('d MMM yyyy').format(user.trialEndsAt!)}. You are on the free plan.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onSignOut,
            icon: const Icon(Boxicons.bx_log_out, size: 16),
            label: const Text('Sign out'),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}

class _TrialExplainer extends StatelessWidget {
  const _TrialExplainer({required this.user});

  final LocalUser? user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = user == null
        ? 'Every new account gets 3 months of Zaka Plus features free. No card '
              'is needed for the trial.'
        : user!.isLifetime
        ? 'Lifetime access is active. No renewal, no card, no expiry.'
        : user!.isTrialActive
        ? 'Your 3-month trial is running. After it ends the free cash tracker '
              'keeps working; paid Plus features are not switched on yet.'
        : 'Your trial has ended. The free cash tracker still works; paid Plus '
              'features are not switched on yet.';

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              user?.isLifetime ?? false
                  ? Boxicons.bx_badge_check
                  : Boxicons.bx_time_five,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, this.strong = false});

  final String label;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: strong
            ? theme.colorScheme.onSurface
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: strong
              ? theme.colorScheme.surface
              : theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _AppLockCard extends ConsumerStatefulWidget {
  const _AppLockCard();

  @override
  ConsumerState<_AppLockCard> createState() => _AppLockCardState();
}

class _AppLockCardState extends ConsumerState<_AppLockCard> {
  bool? _hasPin;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final hasPin = await ref.read(appLockServiceProvider).hasPin();
    if (!mounted) return;
    setState(() => _hasPin = hasPin);
  }

  Future<String?> _askPin({
    required String title,
    required String action,
    String? helper,
  }) async {
    final controller = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (helper != null) ...[
              Text(helper),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: controller,
              autofocus: true,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 8,
              decoration: const InputDecoration(
                labelText: 'PIN',
                counterText: '',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text(action),
          ),
        ],
      ),
    );
    controller.dispose();
    return value;
  }

  Future<bool> _confirmCurrentPin() async {
    final pin = await _askPin(
      title: 'Enter your current PIN',
      action: 'Continue',
    );
    if (pin == null) return false;
    final ok = await ref.read(appLockServiceProvider).verifyPin(pin);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('That PIN is not correct.')),
      );
    }
    return ok;
  }

  Future<void> _setPin() async {
    if (_hasPin == true && !await _confirmCurrentPin()) return;

    final first = await _askPin(
      title: 'Set an app-lock PIN',
      action: 'Next',
      helper: 'Use 4 to 8 digits. Zaka stores only a salted hash, never the '
          'PIN. If you forget it, clearing app data also removes your money '
          'data.',
    );
    if (first == null || !mounted) return;
    if (!AppLockService.isValidPin(first)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Use 4 to 8 digits.')),
      );
      return;
    }

    final second = await _askPin(
      title: 'Confirm the PIN',
      action: 'Save',
    );
    if (second == null || !mounted) return;
    if (first != second) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The PINs did not match.')),
      );
      return;
    }

    await ref.read(appLockServiceProvider).setPin(first);
    if (!mounted) return;
    setState(() => _hasPin = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('App lock is on.')),
    );
  }

  Future<void> _disable() async {
    if (!await _confirmCurrentPin()) return;
    await ref.read(appLockServiceProvider).clearPin();
    if (!mounted) return;
    setState(() => _hasPin = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('App lock is off.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasPin = _hasPin;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              hasPin == true ? Boxicons.bx_lock_alt : Boxicons.bx_lock_open_alt,
            ),
            title: const Text('App lock'),
            subtitle: Text(
              hasPin == null
                  ? 'Checking…'
                  : hasPin
                  ? 'On. Zaka asks for your PIN after you leave the app.'
                  : 'Off. Add a 4–8 digit PIN so balances are not visible '
                        'when someone picks up your phone.',
            ),
            trailing: Switch(
              value: hasPin ?? false,
              onChanged: hasPin == null
                  ? null
                  : (value) => value ? _setPin() : _disable(),
            ),
          ),
          if (hasPin == true)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'PIN only in this build. Biometrics are roadmap. The '
                      'Android recents preview is hidden with FLAG_SECURE.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: _setPin,
                    child: const Text('Change'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
