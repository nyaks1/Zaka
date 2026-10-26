import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';
import 'contact.dart';
import 'feedback_service.dart';

class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  final _message = TextEditingController();
  final _replyTo = TextEditingController();
  bool _includeDiagnostics = false;
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _message.dispose();
    _replyTo.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await ref
          .read(feedbackServiceProvider)
          .send(
            message: _message.text,
            includeDiagnostics: _includeDiagnostics,
            replyTo: _replyTo.text,
          );
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Feedback sent. Thank you.')),
      );
    } on FeedbackException catch (error) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _error = error.message;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _error = '$error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final configured = ref.watch(feedbackServiceProvider).isConfigured;

    return Scaffold(
      appBar: AppBar(title: const Text('Send feedback')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Boxicons.bx_message_rounded_dots),
                      const SizedBox(width: 8),
                      Text(
                        'Tell us what went wrong or what to improve',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Do not include bank details, card numbers, ID numbers, '
                    'account numbers, statements or anything you do not want '
                    'a stranger to read.',
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
          TextField(
            controller: _message,
            minLines: 5,
            maxLines: 10,
            maxLength: 2000,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Your message',
              hintText: 'What happened, and which screen were you on?',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: _replyTo,
            keyboardType: TextInputType.emailAddress,
            maxLength: 254,
            decoration: const InputDecoration(
              labelText: 'Your email (optional, for a reply)',
              counterText: '',
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: CheckboxListTile(
              value: _includeDiagnostics,
              onChanged: (value) =>
                  setState(() => _includeDiagnostics = value ?? false),
              title: const Text('Include app version and Android version'),
              subtitle: const Text(
                'Off by default. Only the Zaka version and the Android build '
                'are added. No money data, notes, accounts or device id.',
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),
          if (!configured) ...[
            const SizedBox(height: 12),
            Card(
              color: theme.colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  'This build has no feedback endpoint. Copy the contact '
                  'below and send it through GitHub Issues or the configured '
                  'email alias.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ),
          ],
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
          FilledButton.icon(
            onPressed: _sending ? null : _send,
            icon: _sending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Boxicons.bx_send),
            label: const Text('Send feedback'),
          ),
          const SizedBox(height: 12),
          Text(
            'The Worker forwards the message to the project webhook and does '
            'not store it. The receiving service may keep it. If you prefer, '
            'copy $feedbackContactLabel and contact us directly.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          SelectableText(
            feedbackContactLabel,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
