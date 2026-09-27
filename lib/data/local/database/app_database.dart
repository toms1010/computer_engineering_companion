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
    _db = await openDatabase(join(dir.path, AppConstants.databaseName),
        version: AppConstants.databaseVersion, onCreate: (db, _) async {
      for (final s in DatabaseTables.statements) {
        await db.execute(s);
      }
      for (final subject in seededSubjects()) {
        await db.insert('subjects', subject);
      }
    }, onUpgrade: migrateDatabase);
    return _db!;
  }
}
