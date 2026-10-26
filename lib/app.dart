import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme.dart';
import 'features/security/app_lock_gate.dart';
import 'features/shell/home_shell.dart';
import 'providers.dart';

class ZakaApp extends ConsumerStatefulWidget {
  const ZakaApp({super.key});

  @override
  ConsumerState<ZakaApp> createState() => _ZakaAppState();
}

class _ZakaAppState extends ConsumerState<ZakaApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Catch up on recurring spends in the background; the app shell renders
    // immediately and the streams update when the database is ready.
    _syncRecurring();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _syncRecurring();
  }

  void _syncRecurring() {
    unawaited(
      ref.read(recurringServiceProvider).postDue(DateTime.now()).catchError((
        Object error,
        StackTrace stackTrace,
      ) {
        debugPrint('Could not sync recurring spends: $error\n$stackTrace');
        return 0;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zaka',
      debugShowCheckedModeBanner: false,
      theme: ZakaTheme.light(),
      darkTheme: ZakaTheme.dark(),
      themeMode: ThemeMode.system,
      home: const AppLockGate(child: HomeShell()),
    );
  }
}
