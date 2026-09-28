enum SchedulingAlgorithm {
  fcfs('FCFS', 'First Come First Served'),
  sjf('SJF', 'Shortest Job First'),
  srtf('SRTF', 'Shortest Remaining Time First'),
  roundRobin('Round Robin', 'Round Robin'),
  priority('Priority', 'Priority Scheduling');

  const SchedulingAlgorithm(this.label, this.description);
  final String label, description;
}

class Process {
  Process({
    required this.id,
    required this.name,
    required this.arrivalTime,
    required this.burstTime,
    this.priority = 1,
  });

  final int id, arrivalTime, burstTime, priority;
  final String name;

  Process copyWith({int? arrivalTime, int? burstTime, int? priority}) =>
      Process(
        id: id,
        name: name,
        arrivalTime: arrivalTime ?? this.arrivalTime,
        burstTime: burstTime ?? this.burstTime,
        priority: priority ?? this.priority,
      );
}

class GanttEntry {
  const GanttEntry({
    required this.processId,
    required this.processName,
    required this.start,
    required this.end,
  });

  final int processId;
  final String processName;
  final int start, end;
}

class ProcessResult {
  const ProcessResult({
    required this.processId,
    required this.processName,
    required this.arrivalTime,
    required this.burstTime,
    required this.completionTime,
    required this.turnaroundTime,
    required this.waitingTime,
    required this.responseTime,
  });

  final int processId, arrivalTime, burstTime;
  final int completionTime, turnaroundTime, waitingTime, responseTime;
  final String processName;
}

class SchedulingResult {
  const SchedulingResult({
    required this.algorithm,
    required this.processes,
    required this.gantt,
    required this.averageWaitingTime,
    required this.averageTurnaroundTime,
    required this.averageResponseTime,
    required this.cpuUtilization,
    required this.throughput,
  });

  final SchedulingAlgorithm algorithm;
  final List<ProcessResult> processes;
  final List<GanttEntry> gantt;
  final double averageWaitingTime, averageTurnaroundTime;
  final double averageResponseTime;
  final double cpuUtilization;
  final double throughput;
}

class CpuSchedulingService {
  const CpuSchedulingService();

  SchedulingResult schedule(
    SchedulingAlgorithm algorithm,
    List<Process> processes, {
    int quantum = 2,
  }) {
    if (processes.isEmpty) {
      throw ArgumentError('At least one process is required');
    }
    return switch (algorithm) {
      SchedulingAlgorithm.fcfs => _fcfs(processes),
      SchedulingAlgorithm.sjf => _sjf(processes),
      SchedulingAlgorithm.srtf => _srtf(processes),
      SchedulingAlgorithm.roundRobin => _roundRobin(processes, quantum),
      SchedulingAlgorithm.priority => _priority(processes),
    };
  }

  List<ProcessResult> _buildResults(
    List<Process> original,
    Map<int, int> completionTimes,
    Map<int, int> firstResponse,
  ) {
    return original.map((p) {
      final completion = completionTimes[p.id]!;
      return ProcessResult(
        processId: p.id,
        processName: p.name,
        arrivalTime: p.arrivalTime,
        burstTime: p.burstTime,
        completionTime: completion,
        turnaroundTime: completion - p.arrivalTime,
        waitingTime: completion - p.arrivalTime - p.burstTime,
        responseTime: firstResponse[p.id]! - p.arrivalTime,
      );
    }).toList();
  }

  SchedulingResult _buildResult(
    SchedulingAlgorithm algorithm,
    List<Process> original,
    List<GanttEntry> gantt,
    Map<int, int> completionTimes,
    Map<int, int> firstResponse,
  ) {
    final results = _buildResults(original, completionTimes, firstResponse);
    final avgWait =
        results.fold<double>(0.0, (s, r) => s + r.waitingTime) / results.length;
    final avgTurn =
        results.fold<double>(0.0, (s, r) => s + r.turnaroundTime) / results.length;
    final avgResp =
        results.fold<double>(0.0, (s, r) => s + r.responseTime) / results.length;
    final totalBurst =
        original.fold(0, (s, p) => s + p.burstTime);
    final makespan = gantt.isEmpty ? 0 : gantt.last.end;
    final idleTime = gantt.fold(0, (s, e) => s + (e.end - e.start)) - totalBurst;
    final utilization =
        makespan == 0 ? 0.0 : ((makespan - idleTime.abs()) / makespan * 100);
    return SchedulingResult(
      algorithm: algorithm,
      processes: results,
      gantt: gantt,
      averageWaitingTime: avgWait,
      averageTurnaroundTime: avgTurn,
      averageResponseTime: avgResp,
      cpuUtilization: utilization.clamp(0, 100),
      throughput: makespan == 0 ? 0 : results.length / makespan,
    );
  }

  SchedulingResult _fcfs(List<Process> processes) {
    final ordered = [...processes]..sort((a, b) {
        final cmp = a.arrivalTime.compareTo(b.arrivalTime);
        return cmp != 0 ? cmp : a.id.compareTo(b.id);
      });
    final gantt = <GanttEntry>[];
    final completion = <int, int>{};
    final firstResponse = <int, int>{};
    var time = 0;
    for (final p in ordered) {
      if (time < p.arrivalTime) time = p.arrivalTime;
      firstResponse[p.id] = time;
      gantt.add(GanttEntry(
          processId: p.id, processName: p.name, start: time, end: time + p.burstTime));
      time += p.burstTime;
      completion[p.id] = time;
    }
    return _buildResult(
        SchedulingAlgorithm.fcfs, processes, gantt, completion, firstResponse);
  }

  SchedulingResult _sjf(List<Process> processes) {
    final remaining = processes
        .map((p) => p.copyWith())
        .toList();
    final gantt = <GanttEntry>[];
    final completion = <int, int>{};
    final firstResponse = <int, int>{};
    var time = 0;
    while (remaining.isNotEmpty) {
      final available =
          remaining.where((p) => p.arrivalTime <= time).toList();
      if (available.isEmpty) {
        time = remaining.map((p) => p.arrivalTime).reduce((a, b) => a < b ? a : b);
        continue;
      }
      available.sort((a, b) {
        final cmp = a.burstTime.compareTo(b.burstTime);
        return cmp != 0 ? cmp : a.arrivalTime.compareTo(b.arrivalTime);
      });
      final p = available.first;
      firstResponse[p.id] = time;
      gantt.add(GanttEntry(
          processId: p.id, processName: p.name, start: time, end: time + p.burstTime));
      time += p.burstTime;
      completion[p.id] = time;
      remaining.remove(p);
    }
    return _buildResult(
        SchedulingAlgorithm.sjf, processes, gantt, completion, firstResponse);
  }

  SchedulingResult _srtf(List<Process> processes) {
    final remaining = <_SrtfProcess>[
      for (final p in processes)
        _SrtfProcess(
            id: p.id,
            name: p.name,
            arrivalTime: p.arrivalTime,
            remainingTime: p.burstTime),
    ];
    final gantt = <GanttEntry>[];
    final completion = <int, int>{};
    final firstResponse = <int, int>{};
    var time = 0;
    while (remaining.isNotEmpty) {
      final available =
          remaining.where((p) => p.arrivalTime <= time).toList();
      if (available.isEmpty) {
        time =
            remaining.map((p) => p.arrivalTime).reduce((a, b) => a < b ? a : b);
        continue;
      }
      available.sort((a, b) {
        final cmp = a.remainingTime.compareTo(b.remainingTime);
        return cmp != 0 ? cmp : a.arrivalTime.compareTo(b.arrivalTime);
      });
      final p = available.first;
      if (!firstResponse.containsKey(p.id)) firstResponse[p.id] = time;
      var sliceEnd = time + p.remainingTime;
      final nextArrival = remaining
          .where((r) => r.arrivalTime > time)
          .map((r) => r.arrivalTime)
          .fold<int?>(null, (min, a) => min == null || a < min ? a : min);
      if (nextArrival != null && nextArrival < sliceEnd) {
        sliceEnd = nextArrival;
      }
      gantt.add(GanttEntry(
          processId: p.id, processName: p.name, start: time, end: sliceEnd));
      p.remainingTime -= sliceEnd - time;
      time = sliceEnd;
      if (p.remainingTime <= 0) {
        completion[p.id] = time;
        remaining.remove(p);
      }
    }
    return _buildResult(
        SchedulingAlgorithm.srtf, processes, gantt, completion, firstResponse);
  }

  SchedulingResult _roundRobin(List<Process> processes, int quantum) {
    if (quantum <= 0) throw ArgumentError('Quantum must be positive');
    final queue = <_RrProcess>[
      for (final p in processes)
        _RrProcess(
            id: p.id,
            name: p.name,
            arrivalTime: p.arrivalTime,
            remainingTime: p.burstTime),
    ];
    final ready = <_RrProcess>[];
    final gantt = <GanttEntry>[];
    final completion = <int, int>{};
    final firstResponse = <int, int>{};
    var time = 0;
    var index = 0;
    while (index < queue.length || ready.isNotEmpty) {
      while (index < queue.length && queue[index].arrivalTime <= time) {
        ready.add(queue[index]);
        index++;
      }
      if (ready.isEmpty) {
        if (index < queue.length) time = queue[index].arrivalTime;
        continue;
      }
      final p = ready.removeAt(0);
      if (!firstResponse.containsKey(p.id)) firstResponse[p.id] = time;
      final slice = p.remainingTime < quantum ? p.remainingTime : quantum;
      gantt.add(GanttEntry(
          processId: p.id, processName: p.name, start: time, end: time + slice));
      time += slice;
      p.remainingTime -= slice;
      while (index < queue.length && queue[index].arrivalTime <= time) {
        ready.add(queue[index]);
        index++;
      }
      if (p.remainingTime > 0) {
        ready.add(p);
      } else {
        completion[p.id] = time;
      }
    }
    return _buildResult(SchedulingAlgorithm.roundRobin, processes, gantt,
        completion, firstResponse);
  }

  SchedulingResult _priority(List<Process> processes) {
    final remaining = <_PriorityProcess>[
      for (final p in processes)
        _PriorityProcess(
            id: p.id,
            name: p.name,
            arrivalTime: p.arrivalTime,
            burstTime: p.burstTime,
            priority: p.priority),
    ];
    final gantt = <GanttEntry>[];
    final completion = <int, int>{};
    final firstResponse = <int, int>{};
    var time = 0;
    while (remaining.isNotEmpty) {
      final available =
          remaining.where((p) => p.arrivalTime <= time).toList();
      if (available.isEmpty) {
        time =
            remaining.map((p) => p.arrivalTime).reduce((a, b) => a < b ? a : b);
        continue;
      }
      available.sort((a, b) {
        final cmp = a.priority.compareTo(b.priority);
        return cmp != 0 ? cmp : a.arrivalTime.compareTo(b.arrivalTime);
      });
      final p = available.first;
      firstResponse[p.id] = time;
      gantt.add(GanttEntry(
          processId: p.id,
          processName: p.name,
          start: time,
          end: time + p.burstTime));
      time += p.burstTime;
      completion[p.id] = time;
      remaining.remove(p);
    }
    return _buildResult(
        SchedulingAlgorithm.priority, processes, gantt, completion, firstResponse);
  }
}

class _SrtfProcess {
  _SrtfProcess({
    required this.id,
    required this.name,
    required this.arrivalTime,
    required this.remainingTime,
  });
  final int id, arrivalTime;
  final String name;
  int remainingTime;
}

class _RrProcess {
  _RrProcess({
    required this.id,
    required this.name,
    required this.arrivalTime,
    required this.remainingTime,
  });
  final int id, arrivalTime;
  final String name;
  int remainingTime;
}

class _PriorityProcess {
  _PriorityProcess({
    required this.id,
    required this.name,
    required this.arrivalTime,
    required this.burstTime,
    required this.priority,
  });
  final int id, arrivalTime, burstTime, priority;
  final String name;
}
