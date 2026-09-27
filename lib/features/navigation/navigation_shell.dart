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
  int index = 0;
  final screens = const [
    HomeScreen(),
    LearningScreen(),
    PracticeScreen(),
    ToolsScreen(),
    SettingsScreen()
  ];
  final labels = ['Home', 'Learn', 'Practice', 'Tools', 'Settings'];
  final icons = [
    Icons.home_outlined,
    Icons.menu_book_outlined,
    Icons.assignment_outlined,
    Icons.handyman_outlined,
    Icons.settings_outlined
  ];
  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 600;
    final content = IndexedStack(index: index, children: screens);
    if (!wide)
      return Scaffold(
          body: content,
          bottomNavigationBar: NavigationBar(
              selectedIndex: index,
              onDestinationSelected: (value) => setState(() => index = value),
              destinations: List.generate(
                  5,
                  (i) => NavigationDestination(
                      icon: Icon(icons[i]),
                      selectedIcon: Icon(icons[i]),
                      label: labels[i]))));
    return Scaffold(
        body: Row(children: [
      NavigationRail(
          extended: MediaQuery.sizeOf(context).width > 1024,
          selectedIndex: index,
          onDestinationSelected: (value) => setState(() => index = value),
          leading: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
              child: MediaQuery.sizeOf(context).width > 1024
                  ? const Text('COMPUTER\nENGINEERING\nCOMPANION',
                      style: TextStyle(
                          fontWeight: FontWeight.w800, letterSpacing: 1.2))
                  : const Icon(Icons.memory)),
          destinations: List.generate(
              5,
              (i) => NavigationRailDestination(
                  icon: Icon(icons[i]),
                  selectedIcon: Icon(icons[i]),
                  label: Text(labels[i])))),
      const VerticalDivider(width: 1),
      Expanded(child: content)
    ]));
  }
}
