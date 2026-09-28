import 'package:sqflite/sqflite.dart';

import 'database_indexes.dart';

/// Additive, data-preserving migrations.
///
/// Every step is idempotent and never drops a table or a column, so an
/// existing user database survives an upgrade untouched.
Future<void> migrateDatabase(Database db, int from, int to) async {
  if (from < 2) {
    await _addColumnIfMissing(db, 'lessons', 'order_index',
        'INTEGER NOT NULL DEFAULT 0');
    await _addColumnIfMissing(db, 'lessons', 'concept',
        'TEXT NOT NULL DEFAULT ""');
    await _addColumnIfMissing(db, 'lessons', 'definition',
        'TEXT NOT NULL DEFAULT ""');
    await _addColumnIfMissing(db, 'lessons', 'formula',
        'TEXT NOT NULL DEFAULT ""');
    await _addColumnIfMissing(db, 'lessons', 'explanation',
        'TEXT NOT NULL DEFAULT ""');
    await _addColumnIfMissing(db, 'lessons', 'worked_example',
        'TEXT NOT NULL DEFAULT ""');
    await _addColumnIfMissing(db, 'lessons', 'engineering_example',
        'TEXT NOT NULL DEFAULT ""');
    await _addColumnIfMissing(db, 'lessons', 'common_mistakes',
        'TEXT NOT NULL DEFAULT ""');
    await _addColumnIfMissing(db, 'quiz_questions', 'lesson_id',
        'INTEGER NOT NULL DEFAULT 0');
    await _addColumnIfMissing(db, 'quiz_questions', 'correct_answers',
        'TEXT NOT NULL DEFAULT ""');
    await _addColumnIfMissing(db, 'formulas', 'variables',
        'TEXT NOT NULL DEFAULT ""');
    await _addColumnIfMissing(db, 'formulas', 'application',
        'TEXT NOT NULL DEFAULT ""');
  }

  if (from < 3) {
    // Offline sync queue. Written on every local mutation so the user's work
    // is durable and replayable when a backend is reachable.
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        operation TEXT NOT NULL,
        payload TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL,
        attempts INTEGER NOT NULL DEFAULT 0,
        last_error TEXT,
        next_attempt_at TEXT
      )
    ''');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_sync_queue_entity ON sync_queue(entity_type, entity_id)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_sync_queue_pending ON sync_queue(next_attempt_at)');

    // Backfills for the indexes added in this version.
    for (final statement in DatabaseIndexes.statements) {
      await db.execute(statement);
    }
  }
}

Future<void> _addColumnIfMissing(
    Database db, String table, String column, String type) async {
  final columns = await db.rawQuery('PRAGMA table_info($table)');
  final exists = columns.any((c) => c['name'] == column);
  if (!exists) {
    await db.execute('ALTER TABLE $table ADD COLUMN $column $type');
  }
}
