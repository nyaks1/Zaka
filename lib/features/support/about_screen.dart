import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';

import 'contact.dart';
import 'feedback_contact_tile.dart';
import 'privacy_policy_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('About Zaka')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
              child: Column(
                children: [
                  Image.asset(
                    'assets/logo.png',
                    width: 56,
                    height: 56,
                    errorBuilder: (_, _, _) =>
                        const Icon(Boxicons.bx_wallet, size: 48),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Zaka',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Cash runway for irregular income',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SelectableText(
                    'Version $appVersion',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Built for the FNB App of the Year Hackathon 2026. '
                    'Android 7.0 and later. For people aged 18 and over.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Boxicons.bx_file),
                  title: const Text('Licences'),
                  subtitle: const Text(
                    'Zaka code (MIT), Boxicons (MIT) and other packages',
                  ),
                  trailing: const Icon(Boxicons.bx_chevron_right),
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: 'Zaka',
                    applicationVersion: appVersion,
                    applicationLegalese:
                        '© 2026 Nyakallo Masiu. Zaka source code is MIT '
                        'licensed. The Zaka name and Z logo are not covered by '
                        'the MIT licence.',
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Boxicons.bx_shield),
                  title: const Text('Privacy policy'),
                  subtitle: const Text(
                    'What stays on the phone, Ask Zaka, retention and rights',
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
                  leading: const Icon(Boxicons.bx_block),
                  title: const Text('No crash reporting'),
                  subtitle: const Text(
                    'Deliberate privacy choice: no analytics, ads or tracking '
                    'SDK is included.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FeedbackContactCard(),
          const SizedBox(height: 16),
          Text(
            'The Zaka name, the Z logo and the app icon are product marks of '
            'the project author and are not licensed for reuse under the MIT '
            'licence. Third-party notices are in THIRD_PARTY_NOTICES.md.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
