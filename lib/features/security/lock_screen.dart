import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({
    super.key,
    required this.onVerify,
    required this.onUnlocked,
  });

  final Future<bool> Function(String pin) onVerify;
  final VoidCallback onUnlocked;

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final _controller = TextEditingController();
  String? _error;
  bool _checking = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _unlock() async {
    final pin = _controller.text.trim();
    if (pin.isEmpty) {
      setState(() => _error = 'Enter your PIN.');
      return;
    }
    setState(() {
      _checking = true;
      _error = null;
    });
    final ok = await widget.onVerify(pin);
    if (!mounted) return;
    setState(() {
      _checking = false;
      if (!ok) _error = 'That PIN is not correct.';
    });
    if (ok) widget.onUnlocked();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Boxicons.bx_lock_alt,
                    size: 42,
                    color: theme.colorScheme.onSurface,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Zaka is locked',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your PIN to see your money. Nothing is uploaded '
                    'when the app is locked.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _controller,
                    autofocus: true,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 8,
                    onSubmitted: (_) => _unlock(),
                    decoration: const InputDecoration(
                      labelText: 'PIN',
                      counterText: '',
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _checking ? null : _unlock,
                    child: _checking
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Unlock'),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Forgot your PIN? Clearing Zaka app data in Android '
                    'settings removes the PIN and also removes the local money '
                    'data. Zaka cannot recover either for you.',
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
        ),
      ),
    );
  }
}
