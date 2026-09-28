import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/error/error_reporter.dart';
import '../../../services/performance/app_logger.dart';
import '../../../services/performance/performance_logger.dart';
import '../../../services/performance/performance_metrics.dart';
import 'database_indexes.dart';
import 'database_migrations.dart';
import 'database_seed.dart';
import 'database_tables.dart';

/// Progress of the one-time first-run setup.
class DatabaseBootstrap {
  const DatabaseBootstrap({
    required this.isPreparing,
    required this.progress,
    this.isReady = false,
  });

  const DatabaseBootstrap.ready()
      : isPreparing = false,
        progress = 1,
        isReady = true;

  /// True while the database is being created for the first time.
  final bool isPreparing;

  /// 0..1 while preparing.
  final double progress;

  final bool isReady;
}

/// Owns the SQLite handle and the one-time first-run setup.
///
/// Design notes:
///  * Opening is lazy and guarded, so several providers can ask at once
///    during startup without opening the database twice.
///  * First run **copies a prebuilt database asset** rather than inserting
///    3 758 curriculum rows. Inserting them at launch measured ~15 s on a
///    low-end emulator — long enough to trip Android's ANR watchdog — while
///    the copy is a few hundred milliseconds and cannot jank the UI thread.
///    The row-by-row seeder remains as a fallback if the asset is missing,
///    and is used by "reset all data".
///  * Every phase is timed, because a slow first launch is the most common
///    complaint about a seeded offline app.
class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  /// Prebuilt database shipped as an asset.
  static const seedAsset = 'assets/seed/engineering_companion_seed.db';

  Database? _db;
  Future<Database>? _initializing;
  DatabaseBootstrap _bootstrap =
      const DatabaseBootstrap(isPreparing: false, progress: 0);

  DatabaseBootstrap get bootstrap => _bootstrap;

  Future<Database> get database {
    final existing = _db;
    if (existing != null) return Future.value(existing);
    // Guard against concurrent first access (providers resolve in parallel).
    return _initializing ??= _open();
  }

  /// True once the handle exists, without opening it.
  bool get isOpen => _db != null;

  Future<Database> _open() async {
    final trace =
        PerformanceLogger.instance.start('DB open', PerfCategory.database);
    try {
      final dir = await getApplicationDocumentsDirectory();
      final path = p.join(dir.path, AppConstants.databaseName);

      // The copy happens before `openDatabase` so the very first open sees a
      // complete, correctly-versioned file and skips both onCreate and the
      // seed.
      await _installSeedIfMissing(dir.path, path, trace);

      final db = await openDatabase(
        path,
        version: AppConstants.databaseVersion,
        onConfigure: _configure,
        onCreate: (db, version) async {
          for (final statement in DatabaseTables.statements) {
            await db.execute(statement);
          }
          for (final statement in DatabaseIndexes.statements) {
            await db.execute(statement);
          }
        },
        onUpgrade: migrateDatabase,
      );
      trace.stop(extra: {'phase': 'open'});

      // A database that exists but has no curriculum can only happen if the
      // asset was missing and seeding failed partway.
      await _seedIfEmpty(db);
      _db = db;
      _bootstrap = const DatabaseBootstrap.ready();
      return db;
    } catch (error, stackTrace) {
      _initializing = null;
      _bootstrap =
          const DatabaseBootstrap(isPreparing: false, progress: 0);
      throw ErrorReporter.instance.report(
        error,
        stackTrace: stackTrace,
        operation: 'database_open',
        context: {'path_name': AppConstants.databaseName},
      );
    }
  }

  /// Copies the prebuilt asset into place on first run.
  ///
  /// Falls back to the row-by-row seeder if the asset is unavailable, so a
  /// packaging mistake degrades to slow rather than broken.
  Future<void> _installSeedIfMissing(
      String directory, String path, PerfTrace trace) async {
    if (File(path).existsSync()) return;

    _bootstrap =
        const DatabaseBootstrap(isPreparing: true, progress: 0.1);
    final assetTrace = PerformanceLogger.instance
        .start('DB install seed', PerfCategory.database);

    try {
      final bytes = await rootBundle.load(seedAsset);
      // Write to a temporary name and rename, so a process death mid-write
      // cannot leave a truncated database that then fails to open.
      final staging = File('$path.staging');
      await staging.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
      await staging.rename(path);
      assetTrace.stop(extra: {'bytes': bytes.lengthInBytes});
      AppLogger.instance.info('Installed prebuilt curriculum',
          context: {'kb': bytes.lengthInBytes ~/ 1024});
      return;
    } catch (error) {
      // Not fatal: fall through to the row seeder.
      AppLogger.instance.warn('Seed asset unavailable, using row seeder',
          context: {'type': error.runtimeType.toString()});
      trace.stop(succeeded: false, extra: {'phase': 'seed_asset'});
      await _seedByRows(File(path));
    }
  }

  /// Creates the schema and inserts the curriculum row by row.
  ///
  /// Used only when the prebuilt asset is unavailable. Chunked with an
  /// explicit yield between chunks so the event loop keeps painting.
  Future<void> _seedByRows(File file) async {
    if (file.existsSync()) await file.delete();
    final db = await openDatabase(
      file.path,
      version: AppConstants.databaseVersion,
      onConfigure: _configure,
      onCreate: (db, version) async {
        for (final statement in DatabaseTables.statements) {
          await db.execute(statement);
        }
        for (final statement in DatabaseIndexes.statements) {
          await db.execute(statement);
        }
      },
    );
    await seedDatabase(db, onProgress: (progress) {
      _bootstrap = DatabaseBootstrap(isPreparing: true, progress: progress);
    });
    await db.close();
  }

  /// Applied on every open.
  ///
  /// `foreign_keys` is off by default in SQLite and must be enabled per
  /// connection. `busy_timeout` stops concurrent writers (a sync pass and a
  /// user write) from failing instantly.
  ///
  /// `busy_timeout` must go through [Database.rawQuery]: on Android it returns
  /// the new value, and `execute` rejects any statement that produces a
  /// result set.
  Future<void> _configure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
    await db.rawQuery('PRAGMA busy_timeout = 5000');
  }

  /// Seeds curriculum content when the database exists but is empty.
  Future<void> _seedIfEmpty(Database db) async {
    final existing = await db.query('subjects', limit: 1);
    if (existing.isNotEmpty) return;

    final trace = PerformanceLogger.instance.start('DB seed', PerfCategory.database);
    _bootstrap = const DatabaseBootstrap(isPreparing: true, progress: 0);
    AppLogger.instance.warn('Curriculum missing, seeding rows');
    await seedDatabase(db, onProgress: (progress) {
      if (isOpen) return;
      _bootstrap = DatabaseBootstrap(isPreparing: true, progress: progress);
    });
    trace.stop();
  }

  /// Clears user data and restores the bundled curriculum.
  ///
  /// Restores by re-copying the prebuilt asset when it is available, which
  /// keeps "reset all data" as fast as a first launch; otherwise it falls
  /// back to deleting and re-seeding row by row. Runs as a single
  /// transaction on the delete so a failure cannot leave a half-empty
  /// database.
  Future<void> reset() async {
    final db = await database;
    final trace =
        PerformanceLogger.instance.start('DB reset', PerfCategory.database);
    await db.transaction((txn) async {
      for (final table in AppConstants.resettableTables) {
        await txn.delete(table);
      }
    });

    try {
      final bytes = await rootBundle.load(seedAsset);
      await db.close();
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, AppConstants.databaseName));
      final staging = File('${file.path}.staging');
      await staging.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
      await staging.rename(file.path);
    } on Object {
      // No asset: rebuild in place.
      await seedDatabase(db);
    }

    _db = null;
    _initializing = null;
    _bootstrap = const DatabaseBootstrap(isPreparing: false, progress: 0);
    trace.stop();
  }
}
