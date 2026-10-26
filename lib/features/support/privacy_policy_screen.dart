import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';

import 'feedback_contact_tile.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy policy')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _Section(
            icon: Boxicons.bx_building_house,
            title: 'Who is responsible',
            children: [
              Text(
                'Zaka is a solo project by Nyakallo Masiu, who is the '
                'responsible party and the Information Officer for this '
                'build. The Information Officer is the person to ask about '
                'access, correction, deletion or a complaint.',
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
              const SizedBox(height: 8),
              Text(
                'Under POPIA the head of a private body is its Information '
                'Officer. Registration with the Information Regulator is a '
                'pre-launch compliance step; this hackathon build is a '
                'pre-release and is not yet registered. Confirm the current '
                'registration and complaint process at '
                'inforegulator.org.za before a public launch.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _Section(
            icon: Boxicons.bx_data,
            title: 'What stays on your phone',
            children: [
              _Bullet(
                'Money records you enter or import: amounts, dates, categories, '
                'notes and account names.',
              ),
              _Bullet(
                'Your local Zaka account: display name, email and a salted '
                'PBKDF2 password hash. There is no central user directory.',
              ),
              _Bullet(
                'If you turn on app lock: a salted PBKDF2 hash of your PIN, '
                'never the PIN itself.',
              ),
              _Bullet(
                'Your settings, including the Ask Zaka consent flag and a '
                'random per-install token used for rate limiting.',
              ),
              Text(
                'This data is stored in a SQLite database in Zaka’s private '
                'app storage. It is not uploaded by signing in. Android backup '
                'is disabled for this build.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _Section(
            icon: Boxicons.bx_star,
            title: 'Ask Zaka and Google',
            children: [
              Text(
                'Ask Zaka is optional and off by default. When you turn it on '
                'and tap for tips, the app sends only runwayDays, '
                'dailyBurnRand, categoryPercent and periodDays to a Zaka '
                'Cloudflare Worker. The Worker sends those four fields to '
                'Google Gemini.',
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
              const SizedBox(height: 8),
              Text(
                'Google may process those four fields outside South Africa. '
                'By turning Ask Zaka on, you consent to that cross-border '
                'processing for the purpose of generating tips. The summary '
                'has no name, note, bank, account number, import key or exact '
                'timestamp. If the proxy is unavailable, Zaka shows a tip '
                'generated on the phone.',
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _Section(
            icon: Boxicons.bx_message_rounded_dots,
            title: 'Feedback and complaints',
            children: [
              Text(
                'If you use the in-app feedback form, the message you type is '
                'sent to the Zaka Worker and forwarded to the project webhook. '
                'The Worker does not store it. An optional reply email and the '
                'optional app/Android version are sent only when you provide '
                'or tick them. Do not put bank details, card numbers, ID '
                'numbers or statements in a message.',
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
              const SizedBox(height: 8),
              Text(
                'The public GitHub Issues page is also a support channel. It is '
                'public: never paste financial or identity information there. '
                'For a private data request, use the contact below and do not '
                'include money data in the first message.',
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _Section(
            icon: Boxicons.bx_time_five,
            title: 'How long we keep it',
            children: [
              _Bullet(
                'On-device money data, local account data and the app-lock PIN '
                'hash stay until you use Delete everything or uninstall Zaka. '
                'There is no server copy.',
              ),
              _Bullet(
                'Cloudflare KV rate-limit and usage keys expire after 2 days. '
                'The Worker stores no summary, feedback message or account '
                'data.',
              ),
              _Bullet(
                'A feedback message is forwarded, not stored by the Worker. '
                'The receiving webhook or email service may keep it under its '
                'own policy; ask us to delete it and we will pass the request '
                'on.',
              ),
              _Bullet(
                'GitHub Issues posts are public until deleted by the project '
                'or by you.',
              ),
            ],
          ),
          const SizedBox(height: 12),
          _Section(
            icon: Boxicons.bx_shield,
            title: 'Your POPIA rights',
            children: [
              Text(
                'You may ask what personal information we hold, ask for a '
                'correction, ask us to delete it, or object to processing. '
                'Because the money data is on your phone, the fastest access '
                'and deletion path is in the app: every entry is visible, and '
                'Delete everything removes the money tables, the local account '
                'and sign-in, the app-lock PIN and the Ask Zaka settings.',
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
              const SizedBox(height: 8),
              Text(
                'There is no encrypted export or backup yet. That is a known '
                'POPIA access gap: a lost or replaced phone loses the data, and '
                'we cannot hand you a portable file. An encrypted export is on '
                'the roadmap. Until it ships, contact us and we will help you '
                'read or capture what is on the phone.',
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _Section(
            icon: Boxicons.bx_error_circle,
            title: 'Complaints to the regulator',
            children: [
              Text(
                'If we do not resolve a complaint, you may complain to the '
                'Information Regulator (South Africa) at '
                'https://inforegulator.org.za/. The Regulator publishes the '
                'current complaint form, email address and postal address.',
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _Section(
            icon: Boxicons.bx_child,
            title: 'Age and children',
            children: [
              Text(
                'Zaka is for people aged 18 and over. It is not directed at '
                'children, and we do not knowingly collect a child’s personal '
                'information. If you believe a child has used Zaka, contact us '
                'so we can help remove the local data.',
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _Section(
            icon: Boxicons.bx_block,
            title: 'What we do not do',
            children: [
              _Bullet('No ads and no sale of personal information.'),
              _Bullet(
                'No crash reporting, analytics or behavioural tracking. That '
                'is a deliberate privacy choice, not an omission.',
              ),
              _Bullet(
                'No bank login, card number, OTP or statement upload to a '
                'server. PDF and CSV files are read on the phone.',
              ),
              _Bullet(
                'No central account directory, so we cannot see users on '
                'another phone.',
              ),
            ],
          ),
          const SizedBox(height: 18),
          FeedbackContactCard(showFormButton: false),
          const SizedBox(height: 18),
          Text(
            'This notice describes the hackathon build. It is not legal advice; '
            'get South African privacy review before a public launch or before '
            'adding payments, a central account service or live bank sync.',
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

class _Section extends StatelessWidget {
  const _Section({
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
                Expanded(
                  child: Text(title, style: theme.textTheme.titleMedium),
                ),
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
