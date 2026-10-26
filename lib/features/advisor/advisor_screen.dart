import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';
import '../support/contact.dart';
import '../support/feedback_contact_tile.dart';
import '../support/privacy_policy_screen.dart';
import 'advisor_service.dart';
import 'advisor_summary.dart';

class AdvisorScreen extends ConsumerStatefulWidget {
  const AdvisorScreen({super.key});

  @override
  ConsumerState<AdvisorScreen> createState() => _AdvisorScreenState();
}

class _AdvisorScreenState extends ConsumerState<AdvisorScreen> {
  bool _asking = false;
  bool _changingConsent = false;
  bool _deleting = false;
  AdvisorReply? _reply;
  String? _error;

  Future<void> _setConsent(bool value) async {
    setState(() => _changingConsent = true);
    try {
      await ref.read(advisorPreferencesProvider).setConsent(value);
      if (!mounted) return;
      ref.invalidate(advisorConsentProvider);
      setState(() {
        _changingConsent = false;
        if (!value) {
          _reply = null;
          _error = null;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? 'Ask Zaka is on. You can switch it off any time.'
                : 'Ask Zaka is off. Nothing will be sent.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _changingConsent = false;
        _error = 'Could not save that setting: $error';
      });
    }
  }

  Future<void> _ask(AdvisorSummary summary) async {
    setState(() {
      _asking = true;
      _error = null;
      _reply = null;
    });
    try {
      final reply = await ref.read(advisorServiceProvider).askAdvisor(summary);
      if (!mounted) return;
      setState(() {
        _reply = reply;
        _asking = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _asking = false;
        _error = '$error';
      });
    }
  }

  Future<void> _deleteEverything() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete everything?'),
        content: const Text(
          'This deletes every account, entry, recurring rule and import key, '
          'your local Zaka account and sign-in, the app-lock PIN, and the Ask '
          'Zaka consent from this phone. It cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete everything'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);
    try {
      await ref.read(privacyServiceProvider).deleteEverything();
      await ref.read(databaseProvider).ensureDefaultAccount();
      if (!mounted) return;
      ref.invalidate(advisorConsentProvider);
      ref.invalidate(currentUserProvider);
      ref.invalidate(localUsersProvider);
      setState(() {
        _deleting = false;
        _reply = null;
        _error = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Everything deleted. You are signed out. A blank Cash account is '
            'ready if you want to start again.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _deleting = false;
        _error = 'Could not delete everything: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summary = ref.watch(advisorSummaryProvider);
    final consent = ref.watch(advisorConsentProvider);
    final consented = consent.value ?? false;
    final consentLoading = consent.isLoading;
    final busy = _asking || _changingConsent || _deleting;

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & Ask Zaka')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Boxicons.bx_star,
                        color: theme.colorScheme.onSurface,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'What Ask Zaka does',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Ask Zaka turns your cash-flow numbers into short, '
                    'practical tips. It is optional and off by default. When '
                    'it is on, only the summary below is sent to a Zaka proxy, '
                    'which calls Google Gemini. Google may process it outside '
                    'South Africa.',
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'These are tips and insights, not financial advice. Zaka '
                    'does not recommend loans, insurance, investments, or any '
                    'financial product or provider.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          _SummaryCard(summary: summary),
          const SizedBox(height: 14),
          _SectionCard(
            icon: Boxicons.bx_block,
            title: 'What is never sent',
            children: const [
              _Bullet('Spend notes or transaction descriptions'),
              _Bullet('Account names, bank names, or institutions'),
              _Bullet('Import keys or exact timestamps'),
              _Bullet('Individual transactions or account balances'),
              _Bullet('Anything that identifies you'),
            ],
          ),
          const SizedBox(height: 14),
          _SectionCard(
            icon: Boxicons.bx_shield,
            title: 'How the proxy protects it',
            children: const [
              _Bullet('Only POST requests are accepted.'),
              _Bullet('The body is capped at 1 KB and 1,000 characters.'),
              _Bullet(
                'Only the four fields above are allowed; extra fields '
                'are rejected.',
              ),
              _Bullet('The Gemini key stays on the proxy, never in the app.'),
              _Bullet(
                'The proxy supports per-install daily rate limiting and a '
                'budget alert.',
              ),
            ],
          ),
          const SizedBox(height: 18),
          Card(
            child: SwitchListTile.adaptive(
              value: consented,
              onChanged: busy || consentLoading ? null : _setConsent,
              secondary: Icon(
                consented
                    ? Boxicons.bx_lock_open_alt
                    : Boxicons.bx_lock_alt,
                color: theme.colorScheme.onSurface,
              ),
              title: const Text('Allow Ask Zaka'),
              subtitle: Text(
                consented
                    ? 'On. You can switch this off at any time.'
                    : 'Off. Nothing leaves this phone.',
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Card(
              color: theme.colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  _error!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          if (summary.value != null) _OfflineTipCard(summary: summary.value!),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: busy || consentLoading || summary.value == null
                ? null
                : consented
                ? () => _ask(summary.value!)
                : () => _setConsent(true),
            icon: _asking
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    consented
                        ? Boxicons.bx_star
                        : Boxicons.bx_lock_open_alt,
                  ),
            label: Text(
              consented ? 'Get tips from Gemini' : 'Turn on Ask Zaka',
            ),
          ),
          if (_reply != null) ...[
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Boxicons.bx_bulb,
                          color: theme.colorScheme.onSurface,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _reply!.offline ? 'Offline tip' : 'Zaka tips',
                          style: theme.textTheme.titleSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _reply!.text,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                    ),
                    if (_reply!.offline) ...[
                      const SizedBox(height: 8),
                      Text(
                        'The network or proxy was unavailable, so this is the '
                        'deterministic fallback.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 28),
          const Divider(),
          const SizedBox(height: 12),
          Text('Your data', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Delete every account, entry, rule and import key from this phone, '
            'your local Zaka account and sign-in, the app-lock PIN, and the '
            'Ask Zaka consent flag. This is the fastest way to exercise your '
            'POPIA deletion right for data on this phone.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
              side: BorderSide(color: theme.colorScheme.error),
            ),
            onPressed: busy ? null : _deleteEverything,
            icon: _deleting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Boxicons.bx_trash),
            label: const Text('Delete everything'),
          ),
          const SizedBox(height: 18),
          Card(
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              leading: const Icon(Boxicons.bx_shield),
              title: const Text('Read the full privacy policy'),
              subtitle: const Text(
                'Responsible party, retention, cross-border processing and '
                'complaints',
              ),
              trailing: const Icon(Boxicons.bx_chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const PrivacyPolicyScreen(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const FeedbackContactCard(),
          const SizedBox(height: 16),
          Text(
            'To delete your data, use Delete everything above. To ask us about '
            'data we hold, contact us at $feedbackContactLabel. The Worker '
            'stores no personal data; its rate-limit keys expire after 2 days.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Ask Zaka gives tips and insights, not financial advice.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final AsyncValue<AdvisorSummary> summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Boxicons.bx_code_alt,
                  color: theme.colorScheme.onSurface,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'The live summary, verbatim',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'This is the exact JSON that may be sent. It has no names, '
              'notes, accounts, banks, import keys, or exact timestamps.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: summary.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, _) => Text(
                  'Could not build the summary: $error',
                  style: theme.textTheme.bodySmall,
                ),
                data: (value) => SelectableText(
                  jsonEncode(value.toJson()),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfflineTipCard extends StatelessWidget {
  const _OfflineTipCard({required this.summary});

  final AdvisorSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Boxicons.bx_bolt_circle,
                  color: theme.colorScheme.onSurface,
                ),
                const SizedBox(width: 8),
                Text('Offline preview', style: theme.textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              offlineTip(summary),
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 6),
            Text(
              'This tip is generated on the phone and never needs the network.',
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.onSurface),
                const SizedBox(width: 8),
                Text(title, style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}
