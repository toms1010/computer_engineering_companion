import 'package:flutter/material.dart';
import '../../app/router.dart';
import '../../core/design/app_spacing.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/cards.dart';
import '../../widgets/performance_watcher.dart';
import '../navigation/navigation_shell.dart';

/// Entry point for every calculator and simulator.
///
/// Declared as a static table so the whole list is one `const` value, and each
/// row is lazily built. Routes are named rather than inline
/// `MaterialPageRoute`s, so the central route table stays authoritative.
class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  static const _categories = <_ToolCategory>[
    _ToolCategory('Assistant', [
      _Tool('Study assistant', Icons.auto_awesome_outlined,
          'Ask the offline curriculum', AppRoutes.assistant),
    ]),
    _ToolCategory('Number systems', [
      _Tool('Number system converter', Icons.numbers_outlined,
          'Binary, decimal, octal, hex', AppRoutes.numberSystem),
      _Tool('Binary calculator', Icons.calculate_outlined,
          'Add, subtract, multiply, divide, logic', AppRoutes.binary),
      _Tool('Bitwise calculator', Icons.grid_on_outlined,
          'AND, OR, XOR, NOT, shifts', AppRoutes.bitwise),
    ]),
    _ToolCategory('Electronics', [
      _Tool('Ohm’s law & circuits', Icons.bolt_outlined,
          'V = IR, series and parallel networks', AppRoutes.electronics,
          toolId: 'ohms'),
      _Tool('Physics calculator', Icons.science_outlined,
          'Kinematics, waves, power, momentum', AppRoutes.physics),
    ]),
    _ToolCategory('Networking', [
      _Tool('Subnetting & CIDR', Icons.lan_outlined,
          'Mask, hosts, ranges, data rates', AppRoutes.networking),
    ]),
    _ToolCategory('Mathematics', [
      _Tool('Calculus', Icons.functions_outlined,
          'Derivatives, integrals, limits, series', AppRoutes.calculus),
    ]),
    _ToolCategory('Simulation', [
      _Tool('CPU scheduling', Icons.timeline_outlined,
          'FCFS, SJF, SRTF, round robin, priority', AppRoutes.cpuScheduling),
    ]),
    _ToolCategory('Reference', [
      _Tool('Formula library', Icons.functions_outlined,
          '39 searchable formulas', AppRoutes.formulas),
      _Tool('Code reference', Icons.code_outlined,
          'C, C++, Python, Java, Dart', AppRoutes.references),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    final slivers = <Widget>[];

    for (final category in _categories) {
      slivers.add(SliverSectionHeader(title: category.title));
      slivers.add(LazySliverList(
        itemCount: category.items.length,
        itemBuilder: (context, index) {
          final tool = category.items[index];
          return _ToolRow(
            key: ValueKey(tool.route),
            tool: tool,
            onTap: () => Navigator.of(context).pushNamed(
              tool.route,
              arguments:
                  tool.toolId == null ? null : {RouteArgs.toolId: tool.toolId},
            ),
          );
        },
      ));
    }

    return ScreenPerformanceWatcher(
      name: 'Tools',
      child: AppScaffold(
        title: 'Tools',
        slivers: [
          const SliverToBoxAdapter(child: SyncStatusStrip()),
          ...slivers,
        ],
      ),
    );
  }
}

class _ToolRow extends StatelessWidget {
  const _ToolRow({super.key, required this.tool, required this.onTap});

  final _Tool tool;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppListRow(
        title: tool.title,
        subtitle: Text(tool.subtitle),
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(AppSpacing.sm),
          ),
          child: Icon(tool.icon, size: 20, color: scheme.onPrimaryContainer),
        ),
      ),
    );
  }
}

class _ToolCategory {
  const _ToolCategory(this.title, this.items);
  final String title;
  final List<_Tool> items;
}

class _Tool {
  const _Tool(this.title, this.icon, this.subtitle, this.route,
      {this.toolId});

  final String title, subtitle, route;
  final IconData icon;
  final String? toolId;
}
