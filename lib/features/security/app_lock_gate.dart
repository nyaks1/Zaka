import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';
import 'lock_screen.dart';

/// Shows the home shell, or a PIN screen when an app lock is configured and the
/// app has just launched or come back from the background.
///
/// Pushed sub-screens are closed on lock so they cannot sit above the PIN
/// screen when the app is resumed.
class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate>
    with WidgetsBindingObserver {
  bool _checking = true;
  bool _hasPin = false;
  bool _locked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLock();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _lockIfConfigured();
    }
  }

  Future<void> _checkLock() async {
    final hasPin = await ref.read(appLockServiceProvider).hasPin();
    if (!mounted) return;
    setState(() {
      _checking = false;
      _hasPin = hasPin;
      _locked = hasPin;
    });
  }

  Future<void> _lockIfConfigured() async {
    final hasPin = await ref.read(appLockServiceProvider).hasPin();
    if (!mounted) return;
    if (!hasPin) return;
    // Sub-screens are pushed on the root navigator, above this gate. Close
    // them so the lock screen is what the user sees when they come back.
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.popUntil((route) => route.isFirst);
    }
    setState(() {
      _hasPin = true;
      _locked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!_hasPin || !_locked) return widget.child;

    return LockScreen(
      onVerify: (pin) => ref.read(appLockServiceProvider).verifyPin(pin),
      onUnlocked: () => setState(() => _locked = false),
    );
  }
}
