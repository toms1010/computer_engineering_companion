import 'package:sqflite/sqflite.dart';

/// Additive, data-preserving migrations.
Future<void> migrateDatabase(Database db, int from, int to) async {
  if (from < 2) {
    await db.execute(
        'ALTER TABLE lessons ADD COLUMN order_index INTEGER NOT NULL DEFAULT 0');
    await db.execute(
        'ALTER TABLE lessons ADD COLUMN concept TEXT NOT NULL DEFAULT ""');
    await db.execute(
        'ALTER TABLE lessons ADD COLUMN definition TEXT NOT NULL DEFAULT ""');
    await db.execute(
        'ALTER TABLE lessons ADD COLUMN formula TEXT NOT NULL DEFAULT ""');
    await db.execute(
        'ALTER TABLE lessons ADD COLUMN explanation TEXT NOT NULL DEFAULT ""');
    await db.execute(
        'ALTER TABLE lessons ADD COLUMN worked_example TEXT NOT NULL DEFAULT ""');
    await db.execute(
        'ALTER TABLE lessons ADD COLUMN engineering_example TEXT NOT NULL DEFAULT ""');
    await db.execute(
        'ALTER TABLE lessons ADD COLUMN common_mistakes TEXT NOT NULL DEFAULT ""');
    await db.execute(
        'ALTER TABLE quiz_questions ADD COLUMN lesson_id INTEGER NOT NULL DEFAULT 0');
    await db.execute(
        'ALTER TABLE quiz_questions ADD COLUMN correct_answers TEXT NOT NULL DEFAULT ""');
    await db.execute(
        'ALTER TABLE formulas ADD COLUMN variables TEXT NOT NULL DEFAULT ""');
    await db.execute(
        'ALTER TABLE formulas ADD COLUMN application TEXT NOT NULL DEFAULT ""');
  }
}
