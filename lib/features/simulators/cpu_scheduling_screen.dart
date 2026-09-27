import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/ui.dart';
import '../../domain/services/cpu_scheduling_service.dart';

class CpuSchedulingScreen extends ConsumerStatefulWidget {
  const CpuSchedulingScreen({super.key});

  @override
  ConsumerState<CpuSchedulingScreen> createState() => _CpuSchedulingScreenState();
}

class _CpuSchedulingScreenState extends ConsumerState<CpuSchedulingScreen> {
  SchedulingAlgorithm _algorithm = SchedulingAlgorithm.fcfs;
  final _processes = <Process>[
    Process(id: 1, name: 'P1', arrivalTime: 0, burstTime: 5, priority: 1),
    Process(id: 2, name: 'P2', arrivalTime: 1, burstTime: 3, priority: 2),
    Process(id: 3, name: 'P3', arrivalTime: 2, burstTime: 8, priority: 3),
    Process(id: 4, name: 'P4', arrivalTime: 3, burstTime: 2, priority: 1),
  ];
  final _arrival = TextEditingController();
  final _burst = TextEditingController();
  final _priority = TextEditingController(text: '1');
  final _quantum = TextEditingController(text: '2');
  SchedulingResult? _result;

  final _service = const CpuSchedulingService();

  @override
  void dispose() {
    _arrival.dispose();
    _burst.dispose();
    _priority.dispose();
    _quantum.dispose();
    super.dispose();
  }

  void _run() {
    try {
      setState(() {
        _result = _service.schedule(
          _algorithm,
          _processes,
          quantum: int.tryParse(_quantum.text) ?? 2,
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CPU Scheduling Simulator')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          DropdownButtonFormField<SchedulingAlgorithm>(
            initialValue: _algorithm,
            decoration: const InputDecoration(labelText: 'Algorithm'),
            items: [
              for (final algo in SchedulingAlgorithm.values)
                DropdownMenuItem(
                    value: algo,
                    child: Text('${algo.label} — ${algo.description}')),
            ],
            onChanged: (v) {
              if (v != null) setState(() => _algorithm = v);
            },
          ),
          if (_algorithm == SchedulingAlgorithm.roundRobin) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _quantum,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Time quantum'),
            ),
          ],
          const SizedBox(height: 16),
          Text('Processes',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          for (var i = 0; i < _processes.length; i++)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(child: Text('P${i + 1}')),
                title: Text('Arrival: ${_processes[i].arrivalTime} • Burst: ${_processes[i].burstTime}'),
                subtitle: Text('Priority: ${_processes[i].priority}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => setState(() => _processes.removeAt(i)),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _arrival,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Arrival'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _burst,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Burst'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _priority,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Priority'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: () {
                  final a = int.tryParse(_arrival.text) ?? 0;
                  final b = int.tryParse(_burst.text) ?? 1;
                  final p = int.tryParse(_priority.text) ?? 1;
                  if (b <= 0) return;
                  setState(() {
                    _processes.add(Process(
                      id: _processes.length + 1,
                      name: 'P${_processes.length + 1}',
                      arrivalTime: a,
                      burstTime: b,
                      priority: p,
                    ));
                  });
                },
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _run,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Run simulation'),
          ),
          if (_result != null) ...[
            const SizedBox(height: 24),
            Text('Gantt chart',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            _GanttChart(gantt: _result!.gantt),
            const SizedBox(height: 16),
            Text('Results',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Process')),
                  DataColumn(label: Text('Completion')),
                  DataColumn(label: Text('Turnaround')),
                  DataColumn(label: Text('Waiting')),
                  DataColumn(label: Text('Response')),
                ],
                rows: [
                  for (final r in _result!.processes)
                    DataRow(cells: [
                      DataCell(Text(r.processName)),
                      DataCell(Text('${r.completionTime}')),
                      DataCell(Text('${r.turnaroundTime}')),
                      DataCell(Text('${r.waitingTime}')),
                      DataCell(Text('${r.responseTime}')),
                    ]),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ResultCard(
                  label: 'Avg waiting',
                  value: '${_result!.averageWaitingTime.toStringAsFixed(2)}',
                  icon: Icons.hourglass_bottom,
                ),
                ResultCard(
                  label: 'Avg turnaround',
                  value: '${_result!.averageTurnaroundTime.toStringAsFixed(2)}',
                  icon: Icons.loop,
                ),
                ResultCard(
                  label: 'Avg response',
                  value: '${_result!.averageResponseTime.toStringAsFixed(2)}',
                  icon: Icons.bolt_outlined,
                ),
                ResultCard(
                  label: 'CPU utilization',
                  value: '${_result!.cpuUtilization.toStringAsFixed(1)}%',
                  icon: Icons.memory,
                ),
                ResultCard(
                  label: 'Throughput',
                  value: _result!.throughput.toStringAsFixed(3),
                  icon: Icons.trending_up_outlined,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _GanttChart extends StatelessWidget {
  const _GanttChart({required this.gantt});
  final List<GanttEntry> gantt;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (gantt.isEmpty) return const SizedBox.shrink();
    final maxTime = gantt.last.end;
    return SizedBox(
      height: 60,
      child: Row(
        children: [
          for (final entry in gantt)
            Expanded(
              flex: entry.end - entry.start,
              child: Container(
                margin: const EdgeInsets.only(right: 1),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    entry.processName,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
