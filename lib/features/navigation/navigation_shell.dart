import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../learning/learning_screen.dart';
import '../practice/practice_screen.dart';
import '../tools/tools_screen.dart';
import '../settings/settings_screen.dart';

class NavigationShell extends StatefulWidget {
  const NavigationShell({super.key});

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    LearningScreen(),
    PracticeScreen(),
    ToolsScreen(),
    SettingsScreen(),
  ];

  static const _destinations = [
    _NavItem('Home', Icons.home_outlined, Icons.home),
    _NavItem('Learn', Icons.menu_book_outlined, Icons.menu_book),
    _NavItem('Practice', Icons.quiz_outlined, Icons.quiz),
    _NavItem('Tools', Icons.handyman_outlined, Icons.handyman),
    _NavItem('Settings', Icons.settings_outlined, Icons.settings),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 600;
    final content = IndexedStack(index: _index, children: _screens);

    if (!isWide) {
      return Scaffold(
        body: content,
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (value) => setState(() => _index = value),
          destinations: [
            for (final d in _destinations)
              NavigationDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.selectedIcon),
                label: d.label,
              ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: width >= 1024,
            selectedIndex: _index,
            onDestinationSelected: (value) => setState(() => _index = value),
            leading: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
              child: width >= 1024
                  ? const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.memory, size: 28),
                        SizedBox(height: 8),
                        Text('CEC',
                            style: TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 16)),
                      ],
                    )
                  : const Icon(Icons.memory, size: 28),
            ),
            destinations: [
              for (final d in _destinations)
                NavigationRailDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.selectedIcon),
                  label: Text(d.label),
                ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: content),
        ],
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.icon, this.selectedIcon);
  final String label;
  final IconData icon, selectedIcon;
}
