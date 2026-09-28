import 'dart:io';

import 'package:computer_engineering_companion/core/constants/app_constants.dart';
import 'package:computer_engineering_companion/data/local/database/curriculum_data.dart';
import 'package:computer_engineering_companion/data/local/database/database_indexes.dart';
import 'package:computer_engineering_companion/data/local/database/database_tables.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Builds and verifies the prebuilt seed database shipped as an app asset.
///
/// Inserting 3 758 curriculum rows at runtime took long enough on a low-end
/// device to trip Android's ANR watchdog, so first launch now copies a
/// prepared file instead.
///
/// This lives in `test/` because `sqflite` requires the Flutter VM, and a
/// build step that the test suite runs is a build step that cannot silently
/// rot. It reads the same schema and data constants the app uses, so there is
/// exactly one source of truth, and it rewrites the asset whenever the
/// bundled data changes.
void main() {
  const assetPath = 'assets/seed/engineering_companion_seed.db';

  setUpAll(sqfliteFfiInit);

  test('the prebuilt seed database matches the bundled curriculum', () async {
    final scratch = File('${Directory.systemTemp.path}'
        '/cec_seed_${DateTime.now().microsecondsSinceEpoch}.db');
    final db = await databaseFactoryFfi.openDatabase(scratch.path);

    try {
      // Schema, from the same statements the app runs on create.
      for (final statement in DatabaseTables.statements) {
        await db.execute(statement);
      }
      for (final statement in DatabaseIndexes.statements) {
        await db.execute(statement);
      }
      // Created by the v3 migration, so a copied file needs it too.
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
      await db.execute('CREATE INDEX IF NOT EXISTS idx_sync_queue_entity '
          'ON sync_queue(entity_type, entity_id)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_sync_queue_pending '
          'ON sync_queue(next_attempt_at)');

      final seed = <String, List<Map<String, Object>>>{
        'subjects': curriculumSubjects,
        'lessons': curriculumLessons,
        'topics': curriculumTopics,
        'quiz_questions': curriculumQuizQuestions,
        'quiz_options': curriculumQuizOptions,
        'formulas': curriculumFormulas,
        'programming_references': curriculumProgrammingReferences,
      };
      for (final entry in seed.entries) {
        final batch = db.batch();
        for (final row in entry.value) {
          batch.insert(entry.key, row);
        }
        await batch.commit(noResult: true);
      }

      // Pin the version so the copied file opens without a migration, and
      // leave no WAL sidecar to copy.
      await db.execute('PRAGMA user_version = ${AppConstants.databaseVersion}');
      await db.execute('PRAGMA journal_mode = DELETE');
      await db.execute('VACUUM');
    } finally {
      await db.close();
    }

    // Publish it as the app asset. Paths are made absolute because
    // sqflite_common_ffi resolves relative paths against its own working
    // directory, which would otherwise create a second, empty database.
    final target = File('${Directory.current.path}/$assetPath');
    await target.parent.create(recursive: true);
    target.writeAsBytesSync(scratch.readAsBytesSync(), flush: true);
    scratch.deleteSync();

    // Verify what was published, not what was intended.
    final verify = await databaseFactoryFfi.openDatabase(target.path);
    try {
      Future<int> count(String table) async =>
          (await verify.rawQuery('SELECT COUNT(*) AS c FROM $table'))
              .first['c'] as int;

      expect(await count('subjects'), curriculumSubjects.length);
      expect(await count('lessons'), curriculumLessons.length);
      expect(await count('quiz_questions'), curriculumQuizQuestions.length);
      expect(await count('quiz_options'), curriculumQuizOptions.length);
      expect(await count('formulas'), curriculumFormulas.length);
      expect(
          await count('programming_references'),
          curriculumProgrammingReferences.length);
      expect(await count('lessons'), 340);
      expect(await count('quiz_questions'), 665);

      // The indexes must travel with the file, or every query regresses to a
      // table scan. Each statement names its own index, so extract the name
      // and check for it rather than restating the list here.
      final rows = await verify.rawQuery(
          "SELECT name FROM sqlite_master WHERE type = 'index'");
      final present = rows.map((r) => r['name'] as String).toSet();
      for (final statement in DatabaseIndexes.statements) {
        final match =
            RegExp(r'INDEX IF NOT EXISTS (\w+)').firstMatch(statement);
        expect(match, isNotNull,
            reason: 'could not read an index name from: \$statement');
        expect(present, contains(match!.group(1)),
            reason: 'index \${match.group(1)} is missing from the seed asset');
      }

      final version = await verify.rawQuery('PRAGMA user_version');
      expect(version.first.values.first, AppConstants.databaseVersion);
    } finally {
      await verify.close();
    }
  });

  test('the seed asset is declared in pubspec so it ships with the app',
      () async {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('assets/seed/'));
  });
}
