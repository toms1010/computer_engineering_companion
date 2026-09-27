import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../../../core/constants/app_constants.dart';
import 'database_migrations.dart';
import 'database_seed.dart';
import 'database_tables.dart';

class AppDatabase {
  AppDatabase._();
  static final instance = AppDatabase._();
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    _db = await openDatabase(
      join(dir.path, AppConstants.databaseName),
      version: AppConstants.databaseVersion,
      onCreate: (db, version) async {
        for (final statement in DatabaseTables.statements) {
          await db.execute(statement);
        }
        await seedDatabase(db);
      },
      onUpgrade: migrateDatabase,
    );
    return _db!;
  }

  Future<void> reset() async {
    final db = await database;
    await db.transaction((txn) async {
      for (final table in [
        'subjects',
        'lessons',
        'topics',
        'quiz_questions',
        'quiz_options',
        'quiz_attempts',
        'quiz_answers',
        'progress',
        'bookmarks',
        'notes',
        'recent_activity',
        'study_sessions',
        'programming_references',
        'formulas',
      ]) {
        await txn.delete(table);
      }
    });
    await seedDatabase(db);
  }
}
