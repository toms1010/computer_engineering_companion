import 'package:flutter/material.dart';
import '../../core/widgets/ui.dart';
import '../simulators/cpu_scheduling_screen.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});
  @override
  Widget build(BuildContext context) => PageFrame(
      title: 'Tools',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Engineering tools',
            style: TextStyle(fontWeight: FontWeight.w700)),
        const SectionTitle('Electronics'),
        ListTile(
            leading: const Icon(Icons.bolt_outlined),
            title: const Text('Ohm’s Law'),
            subtitle:
                const Text('Calculate resistance from voltage and current'),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const OhmsLawScreen()))),
        const SectionTitle('Computer Systems'),
        ListTile(
            leading: const Icon(Icons.timeline_outlined),
            title: const Text('CPU Scheduling'),
            subtitle: const Text(
                'Run FCFS, SJF, SRTF, Round Robin, and Priority simulations'),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const CpuSchedulingScreen()))),
      ]));
}

class OhmsLawScreen extends StatefulWidget {
  const OhmsLawScreen({super.key});
  @override
  State<OhmsLawScreen> createState() => _OhmsLawScreenState();
}

class _OhmsLawScreenState extends State<OhmsLawScreen> {
  final voltage = TextEditingController();
  final current = TextEditingController();
  String result = 'Enter voltage and current.';
  @override
  void dispose() {
    voltage.dispose();
    current.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Ohm’s Law')),
      body: Padding(
          padding: const EdgeInsets.all(20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('R = V ÷ I'),
            const SizedBox(height: 16),
            TextField(
                controller: voltage,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Voltage (V)')),
            const SizedBox(height: 12),
            TextField(
                controller: current,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Current (A)')),
            const SizedBox(height: 16),
            FilledButton(
                onPressed: () {
                  final v = double.tryParse(voltage.text);
                  final i = double.tryParse(current.text);
                  setState(() => result = v == null || i == null || i == 0
                      ? 'Enter valid values; current cannot be zero.'
                      : 'Resistance: ${(v / i).toStringAsFixed(2)} Ω');
                },
                child: const Text('Calculate')),
            const SizedBox(height: 16),
            Text(result, style: Theme.of(context).textTheme.titleMedium),
          ])));
}
