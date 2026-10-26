import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/database.dart';
import '../../providers.dart';
import 'auth_service.dart';

class AdminUsersScreen extends ConsumerWidget {
  const AdminUsersScreen({super.key});

  Future<void> _changePlan(
    BuildContext context,
    WidgetRef ref,
    LocalUser user,
    String plan,
  ) async {
    try {
      await ref.read(authServiceProvider).grantPlan(user.id, plan);
      ref.invalidate(currentUserProvider);
      ref.invalidate(localUsersProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${user.email}: ${_planLabel(plan)}.')),
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
    final current = ref.watch(currentUserProvider).value;
    final users = ref.watch(localUsersProvider);

    if (current == null || !current.isOwner) {
      return Scaffold(
        appBar: AppBar(title: const Text('Users')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Text(
              'The user console is only available to the creator account.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: users.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Could not load users: $error')),
        data: (items) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Text(
              '${items.length} ${items.length == 1 ? 'account' : 'accounts'} '
              'on this device',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'This build has no central user database. Accounts created on '
              'this phone appear here; accounts on another phone do not. The '
              'backend plan in docs/accounts.md is the fix.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            for (final user in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _UserCard(
                  user: user,
                  isCurrent: user.id == current.id,
                  onGrantLifetime: () =>
                      _changePlan(context, ref, user, 'lifetime'),
                  onResetTrial: () => _changePlan(context, ref, user, 'trial'),
                  onMoveToFree: () => _changePlan(context, ref, user, 'free'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static String _planLabel(String plan) => switch (plan) {
    'lifetime' => 'lifetime access',
    'trial' => '3-month trial reset',
    'free' => 'free plan',
    _ => plan,
  };
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.user,
    required this.isCurrent,
    required this.onGrantLifetime,
    required this.onResetTrial,
    required this.onMoveToFree,
  });

  final LocalUser user;
  final bool isCurrent;
  final VoidCallback onGrantLifetime;
  final VoidCallback onResetTrial;
  final VoidCallback onMoveToFree;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final created = DateFormat('d MMM yyyy').format(user.createdAt);
    final trial = user.trialEndsAt == null
        ? null
        : DateFormat('d MMM yyyy').format(user.trialEndsAt!);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 14, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              user.displayName,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (isCurrent) ...[
                            const SizedBox(width: 6),
                            Text(
                              '(you)',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
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
                PopupMenuButton<String>(
                  tooltip: 'Change plan',
                  onSelected: (value) {
                    switch (value) {
                      case 'lifetime':
                        onGrantLifetime();
                        break;
                      case 'trial':
                        onResetTrial();
                        break;
                      case 'free':
                        onMoveToFree();
                        break;
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'lifetime',
                      child: Text('Give lifetime access'),
                    ),
                    PopupMenuItem(
                      value: 'trial',
                      child: Text('Reset 3-month trial'),
                    ),
                    PopupMenuItem(
                      value: 'free',
                      child: Text('Move to free plan'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Badge(
                  label: user.isOwner ? 'Creator' : 'User',
                  strong: user.isOwner,
                ),
                _Badge(label: user.planLabel),
                _Badge(
                  label: user.authProvider == 'google' ? 'Google' : 'Email',
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Joined $created'
              '${trial == null ? '' : ' · trial ends $trial'}'
              '${user.lastSignInAt == null ? '' : ' · last in ${DateFormat('d MMM').format(user.lastSignInAt!)}'}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, this.strong = false});

  final String label;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
