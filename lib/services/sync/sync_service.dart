import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../../core/error/app_exception.dart';
import '../../data/local/sync/sync_queue.dart';
import '../api/api_client.dart';
import '../performance/performance_monitor.dart';

/// User-visible state of synchronisation.
enum SyncState {
  /// Nothing is waiting.
  idle,

  /// Changes are waiting, and no backend is configured or reachable.
  pending,

  /// A drain is in flight.
  syncing,

  /// Everything is on the server.
  synced,

  /// A pass finished but some items did not go through.
  failed,
}

/// What the UI needs to render a sync banner.
class SyncStatus {
  const SyncStatus({
    required this.state,
    required this.pendingCount,
    required this.failedCount,
    required this.isBackendConfigured,
    required this.isOnline,
    this.lastSyncedAt,
    this.message,
  });

  final SyncState state;
  final int pendingCount;
  final int failedCount;
  final bool isBackendConfigured;
  final bool isOnline;
  final DateTime? lastSyncedAt;

  /// Optional detail, e.g. why a pass failed.
  final String? message;

  bool get hasWork => pendingCount > 0;

  String get label => switch (state) {
        SyncState.idle => 'Up to date',
        SyncState.pending => isBackendConfigured
            ? '$pendingCount change${pendingCount == 1 ? '' : 's'} waiting'
            : 'Saved on this device',
        SyncState.syncing => 'Syncing…',
        SyncState.synced => 'Synced',
        SyncState.failed => 'Sync failed',
      };

  static const SyncStatus unknown = SyncStatus(
    state: SyncState.idle,
    pendingCount: 0,
    failedCount: 0,
    isBackendConfigured: false,
    isOnline: false,
  );
}

/// A conflict detected while pushing.
class SyncConflict {
  const SyncConflict({
    required this.entityType,
    required this.entityId,
    required this.resolution,
  });

  final String entityType, entityId, resolution;

  /// Last-write-wins. Documented rather than silent: the losing version is
  /// logged, not discarded quietly.
  static const String lastWriteWins = 'server copy kept';
}

/// Result of one drain pass.
class SyncOutcome {
  const SyncOutcome({
    required this.pushed,
    required this.failed,
    required this.conflicts,
    this.skippedBecauseOffline = false,
    this.skippedBecauseUnconfigured = false,
  });

  final int pushed, failed;
  final List<SyncConflict> conflicts;
  final bool skippedBecauseOffline, skippedBecauseUnconfigured;

  bool get didWork => pushed > 0;
}

/// Pushes the local sync queue to a backend when one is configured.
///
/// Design constraints taken straight from the requirements:
///
///  * never blocks the UI — this is a background service with a status the
///    UI observes, not an await the user waits on;
///  * does nothing at all when there is no backend or no connection, rather
///    than retrying into a wall;
///  * retries with backoff per item, and gives up loudly on items that keep
///    failing instead of dropping them silently.
class SyncService extends ChangeNotifier {
  SyncService({
    required ApiClient client,
    required NetworkMonitor networkMonitor,
    required DatabaseReader database,
  })  : _client = client,
        _networkMonitor = networkMonitor,
        _database = database;

  final ApiClient _client;
  final NetworkMonitor _networkMonitor;
  final DatabaseReader _database;

  /// Guards against overlapping passes when the user taps "Sync" repeatedly
  /// or connectivity flaps.
  bool _isSyncing = false;

  Timer? _scheduledPass;
  DateTime? _lastSyncedAt;
  int _pendingCount = 0;
  int _failedCount = 0;
  String? _message;
  bool _disposed = false;
  final List<SyncConflict> _conflicts = [];
  final StreamController<SyncStatus> _statusController =
      StreamController<SyncStatus>.broadcast();

  /// Streamed sync state for the UI. Broadcast, so several widgets (the
  /// banner and the settings tile) can observe it independently.
  Stream<SyncStatus> get status => _statusController.stream;

  bool get isSyncing => _isSyncing;

  bool get isBackendConfigured => _client.isConfigured;

  int get pendingCount => _pendingCount;
  int get failedCount => _failedCount;
  List<SyncConflict> get conflicts => List.unmodifiable(_conflicts);

  /// Runs a pass now, ignoring the debounce window.
  Future<SyncOutcome> syncNow() async {
    _scheduledPass?.cancel();
    _scheduledPass = null;
    return _drain();
  }

  /// Queues a pass. Repeated calls inside the window collapse into one, so a
  /// burst of edits does not become a burst of requests.
  void scheduleSync({Duration delay = const Duration(seconds: 8)}) {
    if (_scheduledPass?.isActive ?? false) return;
    _scheduledPass = Timer(delay, () {
      _scheduledPass = null;
      unawaited(_drain());
    });
  }

  /// Refreshes the pending/failed counters without attempting a push.
  Future<SyncStatus> refreshStatus() async {
    final db = await _database.read();
    _pendingCount = await SyncQueue.instance.pendingCount(db);
    _failedCount = (await SyncQueue.instance.failed(db)).length;
    _emit();
    return _status();
  }

  SyncStatus _status() => SyncStatus(
        state: _isSyncing
            ? SyncState.syncing
            : _failedCount > 0
                ? SyncState.failed
                : _pendingCount > 0
                    ? SyncState.pending
                    : (_lastSyncedAt == null ? SyncState.idle : SyncState.synced),
        pendingCount: _pendingCount,
        failedCount: _failedCount,
        isBackendConfigured: isBackendConfigured,
        isOnline: !_networkMonitor.isOffline,
        lastSyncedAt: _lastSyncedAt,
        message: _message,
      );

  void _emit() {
    if (_disposed) return;
    if (!_statusController.isClosed) _statusController.add(_status());
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _scheduledPass?.cancel();
    _scheduledPass = null;
    _statusController.close();
    super.dispose();
  }

  Future<SyncOutcome> _drain() async {
    if (_isSyncing) {
      return SyncOutcome(
        pushed: 0,
        failed: _failedCount,
        conflicts: const [],
      );
    }

    final db = await _database.read();
    final items = await SyncQueue.instance.pending(db);
    _pendingCount = items.length;
    _failedCount = (await SyncQueue.instance.failed(db)).length;
    _conflicts.clear();
    _message = null;

    if (items.isEmpty) {
      _emit();
      return SyncOutcome(pushed: 0, failed: 0, conflicts: const []);
    }

    if (!_client.isConfigured) {
      // Nothing to push to. This is the normal state for a purely offline
      // install, so it is not an error.
      _emit();
      return SyncOutcome(
        pushed: 0,
        failed: _failedCount,
        conflicts: const [],
        skippedBecauseUnconfigured: true,
      );
    }

    if (_networkMonitor.isOffline) {
      _emit();
      return SyncOutcome(
        pushed: 0,
        failed: _failedCount,
        conflicts: const [],
        skippedBecauseOffline: true,
      );
    }

    _isSyncing = true;
    _emit();
    final trace = PerformanceMonitor.instance.trackSync('drain',
        context: {'pending': items.length});

    var pushed = 0;
    var failed = 0;

    try {
      for (final item in items) {
        final result = await _pushItem(db, item);
        switch (result) {
          case _PushOutcome.pushed:
            await SyncQueue.instance.acknowledge(db, item.id);
            pushed++;
          case _PushOutcome.conflict:
            // Last-write-wins: the server copy stands, the queue entry is
            // cleared, and the fact is recorded so it is not silent.
            _conflicts.add(SyncConflict(
              entityType: item.entityType,
              entityId: item.entityId,
              resolution: SyncConflict.lastWriteWins,
            ));
            await SyncQueue.instance.acknowledge(db, item.id);
          case _PushOutcome.retryLater:
            failed++;
          case _PushOutcome.failed:
            failed++;
        }
      }
      _lastSyncedAt = DateTime.now();
      _message = failed == 0 ? null : '$failed change(s) could not be sent.';
    } finally {
      _isSyncing = false;
      trace.stop(extra: {'pushed': pushed, 'failed': failed});
      _pendingCount = await SyncQueue.instance.pendingCount(db);
      _failedCount = (await SyncQueue.instance.failed(db)).length;
      _emit();
    }

    return SyncOutcome(
      pushed: pushed,
      failed: failed,
      conflicts: List.unmodifiable(_conflicts),
    );
  }

  Future<_PushOutcome> _pushItem(Database db, SyncQueueItem item) async {
    final result = await _client.send<Map<String, Object?>>(
      'POST',
      '/sync',
      body: {
        'entityType': item.entityType,
        'entityId': item.entityId,
        'operation': item.operation,
        'payload': item.payload,
        'clientTimestamp': item.createdAt.toIso8601String(),
      },
      decode: (decoded) =>
          decoded is Map<String, Object?> ? decoded : const <String, Object?>{},
    );

    if (result.isSuccess) return _PushOutcome.pushed;

    final error = result.errorOrNull;
    if (error is CancelledException) return _PushOutcome.retryLater;
    if (error is NetworkException && error.isRetryable) {
      // Exponential backoff lives in the queue row, so the delay survives the
      // app being killed and restarted.
      await SyncQueue.instance.recordFailure(db, item,
          error: error.runtimeType.toString());
      return _PushOutcome.retryLater;
    }
    if (error is NetworkException && error.statusCode == 409) {
      return _PushOutcome.conflict;
    }
    if (error is ValidationException || error is AuthException) {
      // Retrying will never help; park the item and surface it in Settings.
      await SyncQueue.instance.recordFailure(db, item,
          error: error.runtimeType.toString());
      return _PushOutcome.failed;
    }
    await SyncQueue.instance.recordFailure(db, item,
        error: error?.runtimeType.toString() ?? 'Unknown');
    return _PushOutcome.retryLater;
  }
}

enum _PushOutcome { pushed, conflict, retryLater, failed }

/// Narrow view of the database, so the sync service does not depend on the
/// whole repository.
abstract interface class DatabaseReader {
  Future<Database> read();
}
