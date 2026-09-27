import 'package:flutter/material.dart';
import '../../core/widgets/ui.dart';
import '../calculators/number_system_calculator_screen.dart';
import '../calculators/binary_calculator_screen.dart';
import '../calculators/bitwise_calculator_screen.dart';
import '../calculators/electronics_calculator_screen.dart';
import '../calculators/physics_calculator_screen.dart';
import '../calculators/calculus_calculator_screen.dart';
import '../calculators/networking_calculator_screen.dart';
import '../simulators/cpu_scheduling_screen.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageFrame(
      title: 'Tools',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Category(
            title: 'Number Systems',
            items: [
              _ToolItem(
                'Number System Calculator',
                Icons.numbers_outlined,
                'Binary, decimal, octal, hex',
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const NumberSystemCalculatorScreen())),
              ),
              _ToolItem(
                'Binary Calculator',
                Icons.calculate_outlined,
                'Add, subtract, multiply, divide, logic',
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const BinaryCalculatorScreen())),
              ),
              _ToolItem(
                'Bitwise Calculator',
                Icons.grid_on_outlined,
                'AND, OR, XOR, NOT, shifts',
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const BitwiseCalculatorScreen())),
              ),
            ],
          ),
          _Category(
            title: 'Electronics',
            items: [
              _ToolItem(
                'Electronics Calculators',
                Icons.bolt_outlined,
                'Ohm\'s law, dividers, LED, RC',
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ElectronicsCalculatorScreen())),
              ),
            ],
          ),
          _Category(
            title: 'Physics',
            items: [
              _ToolItem(
                'Physics Calculators',
                Icons.science_outlined,
                'Motion, force, energy, waves',
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PhysicsCalculatorScreen())),
              ),
            ],
          ),
          _Category(
            title: 'Calculus',
            items: [
              _ToolItem(
                'Calculus Calculators',
                Icons.functions_outlined,
                'Derivatives, integrals, limits',
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CalculusCalculatorScreen())),
              ),
            ],
          ),
          _Category(
            title: 'Networking',
            items: [
              _ToolItem(
                'Networking Calculators',
                Icons.lan_outlined,
                'IPv4, CIDR, subnet, data rate',
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const NetworkingCalculatorScreen())),
              ),
            ],
          ),
          _Category(
            title: 'Simulators',
            items: [
              _ToolItem(
                'CPU Scheduling Simulator',
                Icons.timeline_outlined,
                'FCFS, SJF, SRTF, RR, Priority',
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CpuSchedulingScreen())),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Category extends StatelessWidget {
  const _Category({required this.title, required this.items});
  final String title;
  final List<_ToolItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title),
        for (final item in items)
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    Theme.of(context).colorScheme.primaryContainer,
                child: Icon(item.icon,
                    color:
                        Theme.of(context).colorScheme.onPrimaryContainer),
              ),
              title: Text(item.title,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(item.subtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: item.onTap,
            ),
          ),
      ],
    );
  }
}

class _ToolItem {
  const _ToolItem(this.title, this.icon, this.subtitle, this.onTap);
  final String title, subtitle;
  final IconData icon;
  final VoidCallback onTap;
}
