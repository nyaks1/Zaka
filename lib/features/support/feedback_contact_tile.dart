import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';

import 'contact.dart';
import 'feedback_screen.dart';

class FeedbackContactCard extends StatelessWidget {
  const FeedbackContactCard({super.key, this.showFormButton = true});

  final bool showFormButton;

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: feedbackContact));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contact copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(18, 8, 14, 8),
            leading: const Icon(Boxicons.bx_message_rounded_dots),
            title: const Text('Send feedback or a complaint'),
            subtitle: Text(feedbackContactLabel),
            trailing: const Icon(Boxicons.bx_copy),
            onTap: () => _copy(context),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
            child: Text(
              'Please don’t send bank details or statements.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (showFormButton)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const FeedbackScreen(),
                  ),
                ),
                icon: const Icon(Boxicons.bx_edit_alt, size: 16),
                label: const Text('Open the feedback form'),
              ),
            ),
        ],
      ),
    );
  }
}
