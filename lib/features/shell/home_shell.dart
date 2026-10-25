import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';

import '../accounts/accounts_screen.dart';
import '../activity/activity_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../recurring/recurring_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          DashboardScreen(),
          ActivityScreen(),
          AccountsScreen(),
          RecurringScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Boxicons.bx_home),
            selectedIcon: Icon(Boxicons.bxs_home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Boxicons.bx_receipt),
            selectedIcon: Icon(Boxicons.bxs_receipt),
            label: 'Activity',
          ),
          NavigationDestination(
            icon: Icon(Boxicons.bx_wallet),
            selectedIcon: Icon(Boxicons.bxs_wallet),
            label: 'Accounts',
          ),
          NavigationDestination(
            icon: Icon(Boxicons.bx_repeat),
            selectedIcon: Icon(Boxicons.bx_repeat),
            label: 'Recurring',
          ),
        ],
      ),
    );
  }
}
