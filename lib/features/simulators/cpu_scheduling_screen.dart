import 'package:flutter/material.dart';

import '../../core/design/app_spacing.dart';
import '../../domain/services/cpu_scheduling_service.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/cards.dart';
import '../../widgets/inputs.dart';
import '../../widgets/performance_watcher.dart';

/// CPU scheduling simulator: FCFS, SJF, SRTF, round robin and priority.
///
/// The scheduling maths is unchanged and stays in
/// [CpuSchedulingService]. What changed here is the shell: the process list is
/// a lazy sliver list with stable keys, the add-process row wraps instead of
/// forcing three fields plus a button onto a 320dp screen, and results use
/// the shared stat components.
class CpuSchedulingScreen extends StatefulWidget {
  const CpuSchedulingScreen({super.key});

  @override
  State<CpuSchedulingScreen> createState() => _CpuSchedulingScreenState();
}

class _CpuSchedulingScreenState extends State<CpuSchedulingScreen> {
  SchedulingAlgorithm _algorithm = SchedulingAlgorithm.fcfs;
  final List<Process> _processes = [
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
  String? _error;

  static const _service = CpuSchedulingService();

  /// A hard bound so a mistyped arrival time cannot make the simulator spin.
  static const _maxProcesses = 60;

  static const _algorithms = [
    DropdownMenuItem(
      value: SchedulingAlgorithm.fcfs,
      child: Text('FCFS — first come, first served'),
    ),
    DropdownMenuItem(
      value: SchedulingAlgorithm.sjf,
      child: Text('SJF — shortest job first'),
    ),
    DropdownMenuItem(
      value: SchedulingAlgorithm.srtf,
      child: Text('SRTF — shortest remaining time first'),
    ),
    DropdownMenuItem(
      value: SchedulingAlgorithm.roundRobin,
      child: Text('Round robin'),
    ),
    DropdownMenuItem(
      value: SchedulingAlgorithm.priority,
      child: Text('Priority'),
    ),
  ];

  @override
  void dispose() {
    _arrival.dispose();
    _burst.dispose();
    _priority.dispose();
    _quantum.dispose();
    super.dispose();
  }

  void _run() {
    if (_processes.isEmpty) {
      setState(() {
        _error = 'Add at least one process to simulate.';
        _result = null;
      });
      return;
    }
    try {
      final outcome = _service.schedule(
        _algorithm,
        _processes,
        quantum: int.tryParse(_quantum.text.trim()) ?? 2,
      );
      setState(() {
        _result = outcome;
        _error = null;
      });
    } on Object catch (error) {
      setState(() {
        _error = 'The simulation could not run: $error';
        _result = null;
      });
    }
  }

  void _addProcess() {
    final burst = int.tryParse(_burst.text.trim()) ?? 0;
    if (burst <= 0) {
      showAppSnackBar(context, 'Burst time must be at least 1',
          icon: Icons.error_outline);
      return;
    }
    if (_processes.length >= _maxProcesses) {
      showAppSnackBar(context, 'Up to $_maxProcesses processes are supported',
          icon: Icons.info_outline);
      return;
    }
    setState(() {
      _processes.add(Process(
        id: _processes.length + 1,
        name: 'P${_processes.length + 1}',
        arrivalTime: int.tryParse(_arrival.text.trim()) ?? 0,
        burstTime: burst,
        priority: int.tryParse(_priority.text.trim()) ?? 1,
      ));
      // The result belongs to the previous process set; showing it against a
      // new list would be misleading.
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;

    return ScreenPerformanceWatcher(
      name: 'CPU scheduling',
      child: AppScaffold(
        title: 'CPU scheduling',
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.gutter),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<SchedulingAlgorithm>(
                    initialValue: _algorithm,
                    decoration: const InputDecoration(labelText: 'Algorithm'),
                    items: _algorithms,
                    onChanged: (value) {
                      if (value != null) setState(() => _algorithm = value);
                    },
                  ),
                  if (_algorithm == SchedulingAlgorithm.roundRobin) ...[
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _quantum,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Time quantum'),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SliverSectionHeader(title: 'Processes'),
          if (_processes.isEmpty)
            const EmptyStateSliver(
              icon: Icons.memory,
              title: 'No processes',
              message: 'Add a process below to run a simulation.',
            )
          else
            LazySliverList(
              itemCount: _processes.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xs),
              itemBuilder: (context, index) {
                final process = _processes[index];
                return Card(
                  key: ValueKey('process:${process.id}'),
                  child: ListTile(
                    leading: CircleAvatar(child: Text(process.name)),
                    title: Text(
                        'Arrival ${process.arrivalTime} • Burst ${process.burstTime}'),
                    subtitle: Text('Priority ${process.priority}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Remove ${process.name}',
                      onPressed: () => setState(() {
                        _processes.removeAt(index);
                        _result = null;
                      }),
                    ),
                  ),
                );
              },
            ),

          const SliverSectionHeader(title: 'Add process'),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
              child: Column(
                children: [
                  // Wrapping rather than a single Row: three numeric fields
                  // plus a button do not fit a 320dp phone in one line.
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 420;
                      final fields = [
                        TextField(
                          controller: _arrival,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Arrival'),
                        ),
                        TextField(
                          controller: _burst,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Burst'),
                        ),
                        TextField(
                          controller: _priority,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Priority'),
                        ),
                      ];
                      if (compact) {
                        return Column(
                          children: [
                            for (final field in fields) ...[
                              field,
                              const SizedBox(height: AppSpacing.sm),
                            ],
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.tonalIcon(
                                onPressed: _addProcess,
                                icon: const Icon(Icons.add),
                                label: const Text('Add process'),
                              ),
                            ),
                          ],
                        );
                      }
                      return Row(
                        children: [
                          for (var i = 0; i < fields.length; i++) ...[
                            if (i > 0) const SizedBox(width: AppSpacing.sm),
                            Expanded(child: fields[i]),
                          ],
                          const SizedBox(width: AppSpacing.sm),
                          IconButton.filledTonal(
                            onPressed: _addProcess,
                            icon: const Icon(Icons.add),
                            tooltip: 'Add process',
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton.icon(
                    onPressed: _run,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Run simulation'),
                  ),
                  if (_error != null) ErrorBanner(message: _error!),
                ],
              ),
            ),
          ),

          if (result != null) ...[
            const SliverSectionHeader(title: 'Gantt chart'),
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
                child: GanttChart(gantt: result.gantt),
              ),
            ),
            const SliverSectionHeader(title: 'Per-process results'),
            // Lazily built: with 60 processes a DataTable would lay out every
            // cell at once and is wider than a phone.
            LazySliverList(
              itemCount: result.processes.length,
              itemBuilder: (context, index) {
                final row = result.processes[index];
                return Card(
                  key: ValueKey('result:${row.processName}'),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 44,
                          child: Text(row.processName,
                              style: Theme.of(context).textTheme.titleSmall),
                        ),
                        Expanded(
                          child: Wrap(
                            spacing: AppSpacing.lg,
                            runSpacing: AppSpacing.xs,
                            children: [
                              _Metric(
                                  label: 'Completion', value: row.completionTime),
                              _Metric(
                                  label: 'Turnaround',
                                  value: row.turnaroundTime),
                              _Metric(label: 'Waiting', value: row.waitingTime),
                              _Metric(label: 'Response', value: row.responseTime),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(
                child: SectionHeader(title: 'Averages')),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.gutter),
                child: Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _stat(context, 'Avg waiting',
                        result.averageWaitingTime.toStringAsFixed(2),
                        Icons.hourglass_bottom),
                    _stat(context, 'Avg turnaround',
                        result.averageTurnaroundTime.toStringAsFixed(2), Icons.loop),
                    _stat(context, 'Avg response',
                        result.averageResponseTime.toStringAsFixed(2),
                        Icons.bolt_outlined),
                    _stat(context, 'CPU utilisation',
                        '${result.cpuUtilization.toStringAsFixed(1)}%',
                        Icons.memory),
                    _stat(context, 'Throughput',
                        result.throughput.toStringAsFixed(3),
                        Icons.trending_up_outlined),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _stat(
      BuildContext context, String label, String value, IconData icon) {
    final width = (MediaQuery.sizeOf(context).width - AppSpacing.gutter * 2 -
            AppSpacing.sm) /
        2;
    return SizedBox(
      width: width,
      child: StatCard(label: label, value: value, icon: icon),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        Text('$value', style: Theme.of(context).textTheme.titleSmall),
      ],
    );
  }
}

/// Gantt chart: each segment is flexed by its duration, so the bar is a true
/// proportion picture of the schedule at any screen width.
class GanttChart extends StatelessWidget {
  const GanttChart({super.key, required this.gantt});

  final List<GanttEntry> gantt;

  static const _palette = [
    Color(0xFF3B82F6),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF8B5CF6),
    Color(0xFF06B6D4),
  ];

  @override
  Widget build(BuildContext context) {
    if (gantt.isEmpty) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    // Distinct colours are only part of the signal: each segment is also
    // labelled, so the chart does not rely on colour alone.
    Color colourFor(String name) =>
        _palette[name.hashCode.abs() % _palette.length];

    return Semantics(
      label: 'Gantt chart: '
          '${gantt.map((e) => '${e.processName} from ${e.start} to ${e.end}').join(', ')}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 56,
            child: Row(
              children: [
                for (final entry in gantt)
                  Expanded(
                    flex: (entry.end - entry.start).clamp(1, 1 << 20),
                    child: Container(
                      margin: const EdgeInsets.only(right: 1),
                      decoration: BoxDecoration(
                        color: colourFor(entry.processName),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        entry.processName,
                        overflow: TextOverflow.clip,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('t = 0', style: Theme.of(context).textTheme.labelSmall),
              Text('t = ${gantt.last.end}',
                  style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('${gantt.length} time slices', style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
