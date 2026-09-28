import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/design/app_breakpoints.dart';
import '../../core/design/app_spacing.dart';
import '../../services/performance/performance_monitor.dart';
import '../../widgets/performance_watcher.dart';
import '../../widgets/states.dart';
import '../home/home_screen.dart';
import '../learning/learning_screen.dart';
import '../practice/practice_screen.dart';
import '../settings/settings_screen.dart';
import '../tools/tools_screen.dart';

/// Destination metadata, declared once for both layouts.
class _Tab {
  const _Tab({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.build,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget Function() build;
}

/// Tab host for the five primary destinations.
///
/// Two things were wrong with the previous shell and both are fixed here:
///
///  * it used a `static const` list of five screens inside an
///    `IndexedStack`, so all five were constructed and built on the first
///    frame — every tab's providers fired at launch, not when opened. Tabs
///    are now built on first visit and kept alive afterwards, so state is
///    preserved but nothing is built until it is needed;
///  * the destination widgets were re-allocated on every tab switch. They
///    are now `const` lists built once.
class NavigationShell extends ConsumerStatefulWidget {
  const NavigationShell({super.key});

  @override
  ConsumerState<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends ConsumerState<NavigationShell> {
  int _index = 0;

  /// Null until a tab has been opened. This is what makes the tabs lazy.
  final List<Widget?> _screens = List<Widget?>.filled(_tabs.length, null);

  static const List<_Tab> _tabs = [
    _Tab(
      label: 'Home',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      build: _buildHome,
    ),
    _Tab(
      label: 'Learn',
      icon: Icons.menu_book_outlined,
      selectedIcon: Icons.menu_book,
      build: _buildLearn,
    ),
    _Tab(
      label: 'Practice',
      icon: Icons.quiz_outlined,
      selectedIcon: Icons.quiz,
      build: _buildPractice,
    ),
    _Tab(
      label: 'Tools',
      icon: Icons.handyman_outlined,
      selectedIcon: Icons.handyman,
      build: _buildTools,
    ),
    _Tab(
      label: 'Settings',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      build: _buildSettings,
    ),
  ];

  static Widget _buildHome() => const HomeScreen();
  static Widget _buildLearn() => const LearningScreen();
  static Widget _buildPractice() => const PracticeScreen();
  static Widget _buildTools() => const ToolsScreen();
  static Widget _buildSettings() => const SettingsScreen();

  void _select(int index) {
    if (index == _index) return;
    final trace = PerformanceMonitor.instance
        .trackNavigation('tab ${_tabs[_index].label} → ${_tabs[index].label}');
    setState(() {
      _index = index;
      // First visit builds the tab; later switches reuse it, which is what
      // preserves scroll position and form state.
      _screens[index] ??= _tabs[index].build();
    });
    trace.stop();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= Breakpoints.medium;
    // The current tab is always materialised, even on first frame.
    _screens[_index] ??= _tabs[_index].build();

    final content = ScreenPerformanceWatcher(
      name: _tabs[_index].label,
      child: Stack(
        children: [
          for (var i = 0; i < _screens.length; i++)
            if (_screens[i] != null)
              // Only the selected tab is painted. `IndexedStack` keeps every
              // built tab alive while painting one, which is what preserves
              // each tab's state.
              Offstage(
                offstage: i != _index,
                child: TickerMode(enabled: i == _index, child: _screens[i]!),
              ),
        ],
      ),
    );

    if (!isWide) {
      return Scaffold(
        body: content,
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _select,
          destinations: _barDestinations(),
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: width >= Breakpoints.tablet,
            selectedIndex: _index,
            onDestinationSelected: _select,
            leading: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.xl),
              child: width >= Breakpoints.tablet
                  ? const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.memory, size: 28),
                        SizedBox(height: AppSpacing.sm),
                        Text('CEC',
                            style: TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 16)),
                      ],
                    )
                  : const Icon(Icons.memory, size: 28),
            ),
            destinations: _railDestinations(),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: content),
        ],
      ),
    );
  }

  static List<NavigationDestination> _barDestinations() => [
        for (final tab in _tabs)
          NavigationDestination(
            icon: Icon(tab.icon),
            selectedIcon: Icon(tab.selectedIcon),
            label: tab.label,
          ),
      ];

  static List<NavigationRailDestination> _railDestinations() => [
        for (final tab in _tabs)
          NavigationRailDestination(
            icon: Icon(tab.icon),
            selectedIcon: Icon(tab.selectedIcon),
            label: Text(tab.label),
          ),
      ];
}

/// Compact status strip shown above the bottom navigation bar.
///
/// Only renders when there is something to say, so the common case costs
/// nothing: no offline banner on a healthy connected device, a pending
/// count when changes are waiting.
class SyncStatusStrip extends ConsumerWidget {
  const SyncStatusStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncStatusProvider).valueOrNull;
    if (status == null) return const SizedBox.shrink();

    final showOffline = !status.isOnline;
    final showPending = status.pendingCount > 0;
    if (!showOffline && !showPending) return const SizedBox.shrink();

    final message = showOffline
        ? 'Offline — everything still works from this device'
        : '${status.pendingCount} change${status.pendingCount == 1 ? '' : 's'} waiting to sync';

    return StatusBanner(
      message: message,
      icon: showOffline ? Icons.wifi_off_rounded : Icons.cloud_queue_rounded,
      color: Theme.of(context).colorScheme.tertiaryContainer,
    );
  }
}

/// Exposed for the diagnostics screen: the tab list must stay in one place.
List<String> get tabLabels => _NavigationShellState._tabs.map((t) => t.label).toList();
