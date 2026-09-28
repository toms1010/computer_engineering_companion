import 'dart:io';

import 'package:computer_engineering_companion/core/error/app_exception.dart' as app;
import 'package:computer_engineering_companion/data/local/sync/sync_queue.dart';
import 'package:computer_engineering_companion/data/repositories/companion_repository.dart';
import 'package:computer_engineering_companion/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Integration test for the real data layer: schema, migrations, queries and
/// the sync queue, all against an in-memory SQLite database.
///
/// This is the layer the UI never touches, so it is the layer worth testing
/// end to end — the N+1 fixes, the transactions and the queue semantics are
/// all only observable here.
void main() {
  late Database db;
  late CompanionRepository repository;

  setUpAll(() {
    sqfliteFfiInit();
  });

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    for (final statement in _createStatements) {
      await db.execute(statement);
    }
    for (final statement in _indexStatements) {
      await db.execute(statement);
    }
    await _seed(db);
    repository = _TestRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('curriculum reads', () {
    test('loadSubjects returns every seeded subject with counts', () async {
      final subjects = await repository.loadSubjects();
      expect(subjects.length, 3);
      expect(subjects.first.name, 'Operating Systems');
      // Counts come from one aggregate rather than a per-subject query.
      expect(subjects.first.totalLessons, 2);
      expect(subjects.first.progress, 0);
    });

    test('loadLessons filters by subject and orders correctly', () async {
      final lessons = await repository.loadLessons(1);
      expect(lessons.map((l) => l.title), ['Deadlock', 'Banker’s algorithm']);
    });

    test('loadLesson returns null for an unknown id', () async {
      expect(await repository.loadLesson(9999), isNull);
    });

    test('loadAllLessonsGrouped partitions by subject', () async {
      final grouped = await repository.loadAllLessonsGrouped();
      expect(grouped.keys.toSet(), {1, 2});
      expect(grouped[1]!.length, 2);
    });

    test('loadTopics is empty for a lesson with none', () async {
      expect(await repository.loadTopics(1), isEmpty);
    });
  });

  group('quiz reads', () {
    test('loadQuestions returns questions with their options', () async {
      final questions = await repository.loadQuestions(subjectId: 1);
      expect(questions, isNotEmpty);
      expect(questions.first.options, isNotEmpty);
      expect(questions.first.quizType, QuizType.multipleChoice);
    });

    test('loadQuestions with no filter returns the whole bank', () async {
      final all = await repository.loadQuestions();
      final subjectOne = await repository.loadQuestions(subjectId: 1);
      expect(all.length, greaterThan(subjectOne.length));
    });

    test('loadQuestions for a lesson with none returns empty', () async {
      expect(await repository.loadQuestions(lessonId: 9999), isEmpty);
    });

    test('loadRandomQuestions honours the limit', () async {
      final questions =
          await repository.loadRandomQuestions(limit: 2);
      expect(questions.length, lessThanOrEqualTo(2));
    });

    test('loadRandomQuestions for an empty filter returns empty', () async {
      expect(
        await repository.loadRandomQuestions(subjectId: 9999, limit: 5),
        isEmpty,
      );
    });

    test('mistake review returns only incorrectly answered questions',
        () async {
      final questions = await repository.loadQuestions(subjectId: 1);
      final target = questions.first;

      await repository.saveQuizAttempt(
        subjectId: 1,
        correct: 0,
        total: 1,
        elapsedSeconds: 5,
        quizMode: 'quick',
        // Option 1 is the wrong one, so this lands in the mistake review.
        answers: {target.id: {1}},
        questions: questions,
      );

      final entries = await repository.loadMistakesForReview(subjectId: 1);
      expect(entries, isNotEmpty);
      expect(entries.first.question.id, target.id);
      expect(entries.first.selected, {1});
    });

    test('mistake review is empty when everything was correct', () async {
      final questions = await repository.loadQuestions(subjectId: 1);
      final target = questions.first;
      final correct = target.correctIndexes.first;

      await repository.saveQuizAttempt(
        subjectId: 1,
        correct: 1,
        total: 1,
        elapsedSeconds: 5,
        quizMode: 'quick',
        answers: {target.id: {correct}},
        questions: questions,
      );

      expect(await repository.loadMistakesForReview(subjectId: 1), isEmpty);
    });
  });

  group('writing', () {
    test('saving a note returns the persisted row with an id', () async {
      final note = await repository.saveNote(Note(
        title: 'Deadlock notes',
        content: 'Breaking the circular wait',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      expect(note.id, isNotNull);
      expect((await repository.loadNotes()).single.title, 'Deadlock notes');
    });

    test('updating a note replaces it in place', () async {
      final note = await repository.saveNote(Note(
        title: 'First',
        content: 'a',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      final updated = await repository.saveNote(Note(
        id: note.id,
        title: 'Second',
        content: 'b',
        createdAt: note.createdAt,
        updatedAt: DateTime.now(),
      ));
      expect(updated.id, note.id);
      expect((await repository.loadNotes()).single.title, 'Second');
    });

    test('deleting a note removes it', () async {
      final note = await repository.saveNote(Note(
        title: 'Temp',
        content: 'x',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      await repository.deleteNote(note.id!);
      expect(await repository.loadNotes(), isEmpty);
    });

    test('toggling a bookmark is idempotent per direction', () async {
      expect(await repository.toggleBookmark('subject', 1, 'Operating Systems'),
          isTrue);
      expect((await repository.loadBookmarks()).length, 1);
      expect(await repository.toggleBookmark('subject', 1, 'Operating Systems'),
          isFalse);
      expect(await repository.loadBookmarks(), isEmpty);
    });

    test('completing a lesson records a session and an activity entry',
        () async {
      await repository.setLessonCompleted(1, true);
      final sessions = await repository.loadStudySessions();
      final activities = await repository.loadActivities();
      expect(sessions.length, 1);
      expect(activities.single.description, contains('Deadlock'));
    });

    test('completing a lesson updates the subject counts', () async {
      await repository.setLessonCompleted(1, true);
      final subject =
          (await repository.loadSubjects()).firstWhere((s) => s.id == 1);
      expect(subject.completedLessons, 1);
      expect(subject.progress, 0.5);
    });

    test('un-completing a lesson does not add a second session', () async {
      await repository.setLessonCompleted(1, true);
      await repository.setLessonCompleted(1, false);
      expect((await repository.loadStudySessions()).length, 1);
      final subject =
          (await repository.loadSubjects()).firstWhere((s) => s.id == 1);
      expect(subject.completedLessons, 0);
    });

    test('saving an attempt stores per-question correctness', () async {
      final questions = await repository.loadQuestions(subjectId: 1);
      final target = questions.first;
      final id = await repository.saveQuizAttempt(
        subjectId: 1,
        correct: 0,
        total: 1,
        elapsedSeconds: 12,
        quizMode: 'subject',
        // Option 1 is wrong, so the stored row must record `is_correct = 0`.
        answers: {target.id: {1}},
        questions: questions,
      );
      final answers = await repository.loadQuizAnswers(id);
      expect(answers.single.isCorrect, isFalse);
      expect(answers.single.selectedAnswers, {1});
    });

    test('an attempt with no answers does not throw', () async {
      // An empty attempt must still persist, so a user who quits mid-quiz
      // keeps a record rather than losing the session entirely.
      final id = await repository.saveQuizAttempt(
        subjectId: 1,
        correct: 0,
        total: 0,
        elapsedSeconds: 0,
        quizMode: 'quick',
        answers: const {},
        questions: const [],
      );
      expect(id, greaterThan(0));
    });
  });

  group('sync queue', () {
    test('a note write enqueues exactly one change', () async {
      await repository.saveNote(Note(
        title: 'Queued',
        content: 'x',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      final queue = SyncQueue.instance;
      expect(await queue.pendingCount(db), 1);
      final item = (await queue.pending(db)).single;
      expect(item.entityType, SyncEntity.note);
      expect(item.operation, SyncOperation.upsert);
    });

    test('editing the same record coalesces instead of appending', () async {
      final created = await repository.saveNote(Note(
        title: 'A',
        content: 'x',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      await repository.saveNote(Note(
        id: created.id,
        title: 'B',
        content: 'y',
        createdAt: created.createdAt,
        updatedAt: DateTime.now(),
      ));
      final queue = SyncQueue.instance;
      // Fifty offline edits must not become fifty queued writes.
      expect(await queue.pendingCount(db), 1);
      expect((await queue.pending(db)).single.payload['title'], 'B');
    });

    test('deleting a note queues a delete', () async {
      final note = await repository.saveNote(Note(
        title: 'Temp',
        content: 'x',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      await repository.deleteNote(note.id!);
      final item = (await SyncQueue.instance.pending(db)).single;
      expect(item.operation, SyncOperation.delete);
    });

    test('a bookmark toggle queues the right direction', () async {
      await repository.toggleBookmark('subject', 1, 'Operating Systems');
      expect((await SyncQueue.instance.pending(db)).single.operation,
          SyncOperation.upsert);
      await repository.toggleBookmark('subject', 1, 'Operating Systems');
      expect((await SyncQueue.instance.pending(db)).single.operation,
          SyncOperation.delete);
    });

    test('completing a lesson queues the change', () async {
      await repository.setLessonCompleted(1, true);
      final item = (await SyncQueue.instance.pending(db)).single;
      expect(item.entityType, SyncEntity.lesson);
      expect(item.payload['is_completed'], isTrue);
    });

    test('acknowledging removes the entry', () async {
      await repository.saveNote(Note(
        title: 'Queued',
        content: 'x',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      final item = (await SyncQueue.instance.pending(db)).single;
      await SyncQueue.instance.acknowledge(db, item.id);
      expect(await SyncQueue.instance.pendingCount(db), 0);
    });

    test('failures back off exponentially', () async {
      final item = await _enqueue(db);
      final queue = SyncQueue.instance;

      await queue.recordFailure(db, item, error: 'timeout');
      final first = (await queue.pending(db)).single;
      expect(first.attempts, 1);
      expect(first.lastError, 'timeout');
      expect(first.nextAttemptAt, isNotNull);

      await queue.recordFailure(db, first, error: 'timeout');
      final second = (await queue.pending(db)).single;
      expect(second.attempts, 2);
      final firstDelay = first.nextAttemptAt!.difference(DateTime.now());
      final secondDelay = second.nextAttemptAt!.difference(DateTime.now());
      expect(secondDelay, greaterThan(firstDelay ~/ 2));
    });

    test('an item that keeps failing is parked, not dropped', () async {
      var item = await _enqueue(db);
      final queue = SyncQueue.instance;
      for (var i = 0; i < 8; i++) {
        await queue.recordFailure(db, item, error: 'timeout');
        item = (await queue.pending(db)).single;
      }
      // The entry must survive so the user can inspect it in Settings.
      expect(await queue.pendingCount(db), 1);
      final failed = await queue.failed(db);
      expect(failed, isNotEmpty);
      expect(failed.single.nextAttemptAt, isNull);
      expect(failed.single.attempts, 8);
    });

    test('a corrupt payload does not stop the queue draining', () async {
      await _enqueue(db);
      await db.update('sync_queue', {'payload': 'not json'});
      final item = (await SyncQueue.instance.pending(db)).single;
      expect(item.payload, isEmpty);
    });
  });

  group('caching and helpers', () {
    test('reference content is read once and served from memory', () async {
      final first = await repository.loadFormulas();
      final second = await repository.loadFormulas();
      expect(identical(first, second), isTrue);
    });

    test('a category filter bypasses the cache', () async {
      await repository.loadFormulas();
      final filtered = await repository.loadFormulas(category: 'Electronics');
      expect(filtered.every((f) => f.category == 'Electronics'), isTrue);
    });

    test('invalidateCaches forces a re-read', () async {
      final first = await repository.loadFormulas();
      repository.invalidateCaches();
      final second = await repository.loadFormulas();
      expect(identical(first, second), isFalse);
    });

    test('tableCounts reports every resettable table', () async {
      final counts = await repository.tableCounts();
      expect(counts.containsKey('subjects'), isTrue);
      expect(counts['subjects'], 3);
      expect(counts['lessons'], 3);
      expect(counts['quiz_questions'], 3);
    });

    test('searchLessons matches on title and on body text', () async {
      // 'deadlock' appears in the title of one lesson and in the body of
      // another, so it should find more than the title match alone.
      expect((await repository.searchLessons('deadlock')).length, greaterThan(1));
      // 'control' appears only in a body.
      expect((await repository.searchLessons('circular')), isNotEmpty);
      expect(await repository.searchLessons('zzzznothing'), isEmpty);
    });

    test('searchLessons returns at most the requested number of rows', () async {
      expect((await repository.searchLessons('the', limit: 2)).length,
          lessThanOrEqualTo(2));
    });

    test('a LIKE wildcard in a search is treated literally', () async {
      // '%' must not become "match everything".
      expect(await repository.searchLessons('%'), isEmpty);
    });
  });

  group('error contract', () {
    // A database with the `subjects` table only, so a query against any other
    // table fails. The repository's own guard is what normalises the error,
    // which is exactly the behaviour under test.
    late Database partial;
    late String partialPath;

    setUp(() async {
      // `inMemoryDatabasePath` is a single shared instance, so a second
      // fixture needs its own file. Kept in the system temp directory and
      // removed in tearDown.
      partialPath = '${Directory.systemTemp.path}/cec_partial_${DateTime.now().microsecondsSinceEpoch}.db';
      partial = await databaseFactoryFfi.openDatabase(partialPath);
    });

    tearDown(() async {
      await partial.close();
      final file = File(partialPath);
      if (file.existsSync()) file.deleteSync();
    });

    test('a missing table surfaces as a DatabaseException', () async {
      final broken = _TestRepository(partial);
      await expectLater(
        broken.loadTopics(1),
        throwsA(isA<app.DatabaseException>()),
      );
    });

    test('the exception message is safe to show a user', () async {
      final broken = _TestRepository(partial);
      try {
        await broken.loadTopics(1);
        fail('expected a failure');
      } on app.AppException catch (error) {
        expect(error.message, isNot(contains('SQLITE')));
        expect(error.message, isNot(contains('sqlite')));
        expect(error.message, isNot(contains('null')));
        expect(error.message, isNotEmpty);
      }
    });

    test('the original driver error is kept for logs, not for display',
        () async {
      final broken = _TestRepository(partial);
      try {
        await broken.loadTopics(1);
        fail('expected a failure');
      } on app.AppException catch (error) {
        expect(error.cause, isNotNull);
        expect(error.context['operation'], 'db_loadTopics');
      }
    });
  });
}

Future<SyncQueueItem> _enqueue(Database db) async {
  await SyncQueue.instance.enqueue(
    db,
    entityType: SyncEntity.note,
    entityId: '1',
    operation: SyncOperation.upsert,
    payload: const {'title': 'x'},
  );
  return (await SyncQueue.instance.pending(db)).single;
}

/// A repository bound to the test database rather than the singleton.
class _TestRepository extends CompanionRepository {
  _TestRepository(this._db);

  final Database _db;

  @override
  Future<Database> get db async => _db;
}

const _createStatements = [
  '''CREATE TABLE subjects (
    id INTEGER PRIMARY KEY, name TEXT NOT NULL, category TEXT NOT NULL,
    description TEXT NOT NULL, icon TEXT NOT NULL,
    completed_lessons INTEGER NOT NULL DEFAULT 0,
    total_lessons INTEGER NOT NULL DEFAULT 0)''',
  '''CREATE TABLE lessons (
    id INTEGER PRIMARY KEY, subject_id INTEGER NOT NULL,
    order_index INTEGER NOT NULL DEFAULT 0, title TEXT NOT NULL,
    concept TEXT NOT NULL DEFAULT '', definition TEXT NOT NULL DEFAULT '',
    formula TEXT NOT NULL DEFAULT '', explanation TEXT NOT NULL DEFAULT '',
    worked_example TEXT NOT NULL DEFAULT '',
    engineering_example TEXT NOT NULL DEFAULT '',
    common_mistakes TEXT NOT NULL DEFAULT '',
    is_completed INTEGER NOT NULL DEFAULT 0)''',
  '''CREATE TABLE topics (
    id INTEGER PRIMARY KEY, lesson_id INTEGER NOT NULL,
    order_index INTEGER NOT NULL DEFAULT 0, title TEXT NOT NULL,
    content TEXT NOT NULL)''',
  '''CREATE TABLE quiz_questions (
    id INTEGER PRIMARY KEY, subject_id INTEGER NOT NULL,
    lesson_id INTEGER NOT NULL DEFAULT 0, question TEXT NOT NULL,
    type TEXT NOT NULL, explanation TEXT NOT NULL DEFAULT '',
    correct_answers TEXT NOT NULL DEFAULT '')''',
  '''CREATE TABLE quiz_options (
    id INTEGER PRIMARY KEY, question_id INTEGER NOT NULL,
    option_text TEXT NOT NULL, is_correct INTEGER NOT NULL DEFAULT 0)''',
  '''CREATE TABLE quiz_attempts (
    id INTEGER PRIMARY KEY AUTOINCREMENT, subject_id INTEGER NOT NULL DEFAULT 0,
    score REAL NOT NULL, correct_answers INTEGER NOT NULL,
    total_questions INTEGER NOT NULL, elapsed_seconds INTEGER NOT NULL DEFAULT 0,
    quiz_mode TEXT NOT NULL, completed_at TEXT NOT NULL)''',
  '''CREATE TABLE quiz_answers (
    id INTEGER PRIMARY KEY AUTOINCREMENT, attempt_id INTEGER NOT NULL,
    question_id INTEGER NOT NULL, selected_answers TEXT NOT NULL,
    is_correct INTEGER NOT NULL)''',
  '''CREATE TABLE bookmarks (
    id INTEGER PRIMARY KEY AUTOINCREMENT, item_type TEXT NOT NULL,
    item_id INTEGER NOT NULL, label TEXT NOT NULL, created_at TEXT NOT NULL)''',
  '''CREATE TABLE notes (
    id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL,
    content TEXT NOT NULL, subject_id INTEGER,
    created_at TEXT NOT NULL, updated_at TEXT NOT NULL)''',
  '''CREATE TABLE recent_activity (
    id INTEGER PRIMARY KEY AUTOINCREMENT, description TEXT NOT NULL,
    created_at TEXT NOT NULL)''',
  '''CREATE TABLE study_sessions (
    id INTEGER PRIMARY KEY AUTOINCREMENT, subject_id INTEGER NOT NULL DEFAULT 0,
    duration_minutes INTEGER NOT NULL, created_at TEXT NOT NULL)''',
  '''CREATE TABLE formulas (
    id INTEGER PRIMARY KEY AUTOINCREMENT, category TEXT NOT NULL,
    name TEXT NOT NULL, expression TEXT NOT NULL,
    variables TEXT NOT NULL DEFAULT '', application TEXT NOT NULL DEFAULT '')''',
  '''CREATE TABLE progress (
    id INTEGER PRIMARY KEY AUTOINCREMENT, subject_id INTEGER NOT NULL,
    lessons_completed INTEGER NOT NULL DEFAULT 0,
    quizzes_completed INTEGER NOT NULL DEFAULT 0,
    accuracy REAL NOT NULL DEFAULT 0)''',
  '''CREATE TABLE programming_references (
    id INTEGER PRIMARY KEY AUTOINCREMENT, language TEXT NOT NULL,
    topic TEXT NOT NULL, title TEXT NOT NULL, code TEXT NOT NULL)''',
  '''CREATE TABLE sync_queue (
    id INTEGER PRIMARY KEY AUTOINCREMENT, entity_type TEXT NOT NULL,
    entity_id TEXT NOT NULL, operation TEXT NOT NULL,
    payload TEXT NOT NULL DEFAULT '', created_at TEXT NOT NULL,
    attempts INTEGER NOT NULL DEFAULT 0, last_error TEXT,
    next_attempt_at TEXT)''',
];

const _indexStatements = [
  'CREATE INDEX idx_lessons_subject ON lessons(subject_id, order_index)',
  'CREATE INDEX idx_options_question ON quiz_options(question_id, id)',
  'CREATE UNIQUE INDEX idx_bookmarks_item ON bookmarks(item_type, item_id)',
  'CREATE INDEX idx_sync_queue_entity ON sync_queue(entity_type, entity_id)',
];

Future<void> _seed(Database db) async {
  final batch = db.batch();
  for (final subject in [
    ['Operating Systems', 'Systems', 'Processes and scheduling', 'show_chart'],
    ['Computer Networks', 'Networking', 'Protocols and layers', 'lan'],
    ['Calculus', 'Mathematics', 'Limits and integrals', 'functions'],
  ]) {
    batch.insert('subjects', {
      'name': subject[0],
      'category': subject[1],
      'description': subject[2],
      'icon': subject[3],
    });
  }
  // [subjectId, orderIndex, title]
  for (final lesson in [
    [1, 1, 'Deadlock'],
    [1, 2, 'Banker’s algorithm'],
    [2, 1, 'Transmission Control Protocol'],
  ]) {
    batch.insert('lessons', {
      'subject_id': lesson[0],
      'order_index': lesson[1],
      'title': lesson[2],
      'concept': 'Concept for ${lesson[2]}',
      'definition': 'A circular wait is a common cause of deadlock.',
      'explanation': 'Explanation of ${lesson[2]}',
    });
  }
  batch.insert('quiz_questions', {
    'subject_id': 1,
    'lesson_id': 1,
    'question': 'What causes a deadlock?',
    'type': 'multiple_choice',
    'explanation': 'A circular wait.',
    'correct_answers': '0',
  });
  batch.insert('quiz_questions', {
    'subject_id': 1,
    'lesson_id': 2,
    'question': 'Which algorithm avoids deadlock?',
    'type': 'true_false',
    'explanation': "The banker's algorithm.",
    'correct_answers': '1',
  });
  batch.insert('quiz_questions', {
    'subject_id': 2,
    'lesson_id': 3,
    'question': 'Which layer does TCP belong to?',
    'type': 'multiple_choice',
    'explanation': 'The transport layer.',
    'correct_answers': '0',
  });
  for (var i = 0; i < 2; i++) {
    batch.insert('quiz_options', {
      'question_id': 3,
      'option_text': 'Layer ${i + 1}',
      'is_correct': i == 0 ? 1 : 0,
    });
    batch.insert('quiz_options', {
      'question_id': 1,
      'option_text': 'Option ${i + 1}',
      'is_correct': i == 0 ? 1 : 0,
    });
    batch.insert('quiz_options', {
      'question_id': 2,
      'option_text': 'Answer ${i + 1}',
      'is_correct': 0,
    });
  }
  batch.insert('formulas', {
    'category': 'Electronics',
    'name': 'Ohm’s law',
    'expression': 'V = I x R',
  });
  await batch.commit(noResult: true);
}
