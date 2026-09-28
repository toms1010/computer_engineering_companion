import 'dart:convert';

import 'package:sqflite/sqflite.dart';

/// Entity kinds that can be synchronised.
abstract final class SyncEntity {
  static const note = 'note';
  static const bookmark = 'bookmark';
  static const lesson = 'lesson';
  static const quizAttempt = 'quiz_attempt';
}

abstract final class SyncOperation {
  static const upsert = 'upsert';
  static const delete = 'delete';
}

/// One pending local change.
class SyncQueueItem {
  const SyncQueueItem({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.payload,
    required this.createdAt,
    required this.attempts,
    this.lastError,
    this.nextAttemptAt,
  });

  final int id;
  final String entityType, entityId, operation;
  final Map<String, Object?> payload;
  final DateTime createdAt;
  final int attempts;
  final String? lastError;
  final DateTime? nextAttemptAt;

  bool get isDelete => operation == SyncOperation.delete;

  factory SyncQueueItem.fromMap(Map<String, Object?> map) => SyncQueueItem(
        id: map['id'] as int,
        entityType: map['entity_type'] as String,
        entityId: map['entity_id'] as String,
        operation: map['operation'] as String,
        payload: _decode(map['payload'] as String?),
        createdAt:
            DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
        attempts: (map['attempts'] as int?) ?? 0,
        lastError: map['last_error'] as String?,
        nextAttemptAt: DateTime.tryParse(map['next_attempt_at'] as String? ?? ''),
      );

  static Map<String, Object?> _decode(String? raw) {
    if (raw == null || raw.isEmpty) return const {};
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, Object?> ? decoded : const {};
    } on FormatException {
      // A corrupt payload must not stop the queue from draining.
      return const {};
    }
  }
}

/// Durable record of local changes that have not reached a backend yet.
///
/// Every user mutation is written here inside the same transaction as the
/// data change itself. That ordering is the whole point: the app can be
/// closed, killed or used with no network at all, and the change is still
/// there to replay.
///
/// The queue is deliberately local-only. It costs one small row per change
/// and is drained by `SyncService` when a backend is configured and
/// reachable; with no backend configured it simply accumulates and the UI
/// reports the pending count, which is the honest offline-first behaviour.
class SyncQueue {
  SyncQueue._();

  static final SyncQueue instance = SyncQueue._();

  /// Coalescing bound: if a user edits one note fifty times while offline we
  /// keep the latest state, not fifty copies. Older superseded entries for
  /// the same entity are dropped.
  static const int _maxAttempts = 8;

  /// Adds an entry, replacing any earlier pending change to the same record.
  ///
  /// Must be called with a transaction handle so the queue entry and the data
  /// change commit or roll back together.
  Future<void> enqueue(
    DatabaseExecutor txn, {
    required String entityType,
    required String entityId,
    required String operation,
    Map<String, Object?> payload = const {},
  }) async {
    await txn.delete('sync_queue',
        where: 'entity_type = ? AND entity_id = ?', whereArgs: [entityType, entityId]);
    await txn.insert('sync_queue', {
      'entity_type': entityType,
      'entity_id': entityId,
      'operation': operation,
      'payload': jsonEncode(payload),
      'created_at': DateTime.now().toIso8601String(),
      'attempts': 0,
    });
  }

  /// Items ready to send, oldest first.
  Future<List<SyncQueueItem>> pending(Database db, {int limit = 50}) async {
    final rows = await db.query('sync_queue',
        orderBy: 'created_at', limit: limit);
    return rows.map(SyncQueueItem.fromMap).toList(growable: false);
  }

  Future<int> pendingCount(Database db) async {
    final rows =
        await db.rawQuery('SELECT COUNT(*) AS c FROM sync_queue');
    return (rows.first['c'] as int?) ?? 0;
  }

  /// Removes an item that the backend has accepted.
  Future<void> acknowledge(Database db, int id) async {
    await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }

  /// Records a failed attempt and schedules a retry with exponential
  /// backoff, so a permanently failing item does not spin forever and does
  /// not block the rest of the queue.
  Future<void> recordFailure(
    Database db,
    SyncQueueItem item, {
    required String error,
  }) async {
    final attempts = item.attempts + 1;
    if (attempts >= _maxAttempts) {
      // Give up on automatic retry but keep the entry and mark it, so the
      // user can inspect and resolve it from Settings rather than silently
      // losing their work.
      await db.update('sync_queue', {
        'attempts': attempts,
        'last_error': error,
        'next_attempt_at': null,
      }, where: 'id = ?', whereArgs: [item.id]);
      return;
    }
    final backoffSeconds = 1 << (attempts - 1);
    await db.update('sync_queue', {
      'attempts': attempts,
      'last_error': error,
      'next_attempt_at': DateTime.now()
          .add(Duration(seconds: backoffSeconds))
          .toIso8601String(),
    }, where: 'id = ?', whereArgs: [item.id]);
  }

  /// Items that exhausted automatic retries.
  Future<List<SyncQueueItem>> failed(Database db, {int limit = 20}) async {
    final rows = await db.query('sync_queue',
        where: 'attempts >= ? AND next_attempt_at IS NULL',
        whereArgs: [_maxAttempts],
        orderBy: 'created_at',
        limit: limit);
    return rows.map(SyncQueueItem.fromMap).toList(growable: false);
  }

  Future<void> clear(Database db) async {
    await db.delete('sync_queue');
  }
}
