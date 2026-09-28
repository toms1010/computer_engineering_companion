import 'package:sqflite/sqflite.dart' show Database;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/error/app_exception.dart';
import '../../core/error/error_reporter.dart';
import '../../data/local/database/app_database.dart';
import '../../data/repositories/companion_repository.dart';
import '../../domain/entities/entities.dart';
import '../../domain/services/progress_service.dart';
import '../../services/ai/ai_models.dart';
import '../../services/ai/ai_service.dart';
import '../../services/ai/local_ai_engine.dart';
import '../../services/ai/remote_ai_engine.dart';
import '../../services/api/api_client.dart';
import '../../services/performance/app_logger.dart';
import '../../services/storage/secure_key_store.dart';
import '../../services/sync/sync_service.dart';

// ---------------------------------------------------------------------------
// Infrastructure
// ---------------------------------------------------------------------------

/// The data source. Overridden at startup with the already-open instance so
/// the whole app shares one database handle.
final repositoryProvider = Provider<CompanionRepository>((ref) {
  final repository = CompanionRepository();
  ref.onDispose(repository.close);
  return repository;
});

/// Bootstrap state: whether the database is open, and how far the one-time
/// first-run seed has got.
///
/// Drives the boot screen so a first launch shows real progress instead of an
/// indefinite spinner.
/// Emits the current bootstrap state, then the running seed progress, then
/// ready. A stream rather than a future so the boot screen can show real
/// first-run progress instead of an indefinite spinner.
final databaseBootstrapProvider = StreamProvider<DatabaseBootstrap>((ref) {
  return _bootstrapStream();
});

Stream<DatabaseBootstrap> _bootstrapStream() async* {
  yield AppDatabase.instance.bootstrap;
  // Opening is lazy: this triggers the first-run seed if it has not run yet.
  await guard(() => AppDatabase.instance.database,
      operation: 'db_bootstrap');
  yield AppDatabase.instance.bootstrap;
  yield const DatabaseBootstrap.ready();
}

final sharedPreferencesProvider = FutureProvider<SharedPreferences>(
  (ref) => SharedPreferences.getInstance(),
);

final progressServiceProvider =
    Provider<ProgressService>((ref) => const ProgressService());

// ---------------------------------------------------------------------------
// Networking, sync
// ---------------------------------------------------------------------------

final networkMonitorProvider = Provider<NetworkMonitor>((ref) {
  final monitor = NetworkMonitor();
  // Provider disposal is tied to the container, so the notifier is released
  // with the app rather than leaking.
  ref.onDispose(monitor.dispose);
  return monitor;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  // Empty base URL: there is no cloud service unless the user configures
  // one, and nothing in the app depends on one existing.
  final client = ApiClient(networkMonitor: ref.watch(networkMonitorProvider));
  ref.onDispose(client.close);
  return client;
});

final syncServiceProvider = Provider<SyncService>((ref) {
  final service = SyncService(
    client: ref.watch(apiClientProvider),
    networkMonitor: ref.watch(networkMonitorProvider),
    database: _RepositoryDatabaseReader(ref.watch(repositoryProvider)),
  );
  ref.onDispose(service.dispose);
  return service;
});

/// Bridges the repository to the narrow interface the sync service wants.
class _RepositoryDatabaseReader implements DatabaseReader {
  _RepositoryDatabaseReader(this._repository);

  final CompanionRepository _repository;

  @override
  Future<Database> read() => _repository.db;
}

/// Live sync state. Reads the current counters first so the very first frame
/// is not blank, then follows the service.
final syncStatusProvider = StreamProvider<SyncStatus>((ref) async* {
  final service = ref.watch(syncServiceProvider);
  final initial = await service.refreshStatus();
  yield initial;
  yield* service.status;
});

// ---------------------------------------------------------------------------
// Settings
// ---------------------------------------------------------------------------

final themeModeProvider =
    AsyncNotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends AsyncNotifier<ThemeMode> {
  static const _key = 'theme_mode';

  @override
  Future<ThemeMode> build() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    return switch (prefs.getString(_key)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> set(ThemeMode mode) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString(
        _key,
        switch (mode) {
          ThemeMode.light => 'light',
          ThemeMode.dark => 'dark',
          ThemeMode.system => 'system',
        });
    // No `ref.invalidate`: writing the new value directly keeps the app bar
    // from flashing a spinner while the write completes.
    state = AsyncData(mode);
  }
}

final profileNameProvider =
    AsyncNotifierProvider<ProfileNameNotifier, String>(ProfileNameNotifier.new);

class ProfileNameNotifier extends AsyncNotifier<String> {
  static const _key = 'profile_name';
  static const fallback = 'Student';

  @override
  Future<String> build() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    return prefs.getString(_key)?.trim().isNotEmpty == true
        ? prefs.getString(_key)!
        : fallback;
  }

  Future<void> set(String value) async {
    final name = value.trim().isEmpty ? fallback : value.trim();
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString(_key, name);
    state = AsyncData(name);
  }
}

/// Diagnostics/performance screen visibility. Off by default in release.
final diagnosticsEnabledProvider = StateProvider<bool>((ref) {
  return AppLogger.instance.isDebugBuild;
});

// ---------------------------------------------------------------------------
// Curriculum
// ---------------------------------------------------------------------------

final subjectsProvider = FutureProvider<List<Subject>>((ref) {
  return ref.watch(repositoryProvider).loadSubjects();
});

/// A subject plus its lessons.
class SubjectDetail {
  const SubjectDetail({required this.subject, required this.lessons});
  final Subject subject;
  final List<Lesson> lessons;
}

final subjectDetailProvider =
    FutureProvider.family<SubjectDetail, int>((ref, subjectId) async {
  final repository = ref.watch(repositoryProvider);
  // Watch the cached subject list rather than re-querying all 15 subjects:
  // the previous version issued a second full subjects query on every open.
  final subjects = await ref.watch(subjectsProvider.future);
  final subject = subjects.firstWhere(
    (s) => s.id == subjectId,
    orElse: () => throw NotFoundException('That subject is no longer available.'),
  );
  final lessons = await repository.loadLessons(subjectId);
  return SubjectDetail(subject: subject, lessons: lessons);
});

/// A lesson plus its topics, and records it as the most recently viewed
/// lesson so the assistant can recommend what comes next.
class LessonDetail {
  const LessonDetail({required this.lesson, required this.topics});
  final Lesson? lesson;
  final List<Topic> topics;
}

final lessonDetailProvider =
    FutureProvider.family<LessonDetail, int>((ref, lessonId) async {
  final repository = ref.watch(repositoryProvider);
  final lesson = await repository.loadLesson(lessonId);
  final topics = await repository.loadTopics(lessonId);
  return LessonDetail(lesson: lesson, topics: topics);
});

/// The lesson the user looked at most recently. Not persisted: a hint, not
/// data.
final lastViewedLessonProvider = StateProvider<int?>((ref) => null);

final activitiesProvider = FutureProvider<List<ActivityItem>>((ref) {
  return ref.watch(repositoryProvider).loadActivities();
});

final quizAttemptsProvider = FutureProvider<List<QuizAttempt>>((ref) {
  return ref.watch(repositoryProvider).loadQuizAttempts();
});

// ---------------------------------------------------------------------------
// Progress
// ---------------------------------------------------------------------------

final progressStatsProvider = FutureProvider<ProgressStats>((ref) async {
  final repository = ref.watch(repositoryProvider);
  // Four queries total, independent, so they run concurrently. The previous
  // version issued 17 sequential ones and recomputed the whole derivation.
  final results = await Future.wait([
    repository.loadSubjects(),
    repository.loadAllLessons(),
    repository.loadQuizAttempts(),
    _studySummary(repository),
  ]);

  final subjects = results[0] as List<Subject>;
  final lessons = results[1] as List<Lesson>;
  final attempts = results[2] as List<QuizAttempt>;
  final study = results[3] as ({int minutes, List<DateTime> days});

  return ref.read(progressServiceProvider).computeStatsFromDays(
        subjects: subjects,
        allLessons: lessons,
        attempts: attempts,
        totalStudyMinutes: study.minutes,
        studyDays: study.days,
      );
});

Future<({int minutes, List<DateTime> days})> _studySummary(
    CompanionRepository repository) async {
  final sessions = await repository.loadStudySessions();
  return (
    minutes: sessions.fold(0, (sum, s) => sum + s.durationMinutes),
    days: sessions
        .map((s) =>
            DateTime(s.createdAt.year, s.createdAt.month, s.createdAt.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a)),
  );
}

// ---------------------------------------------------------------------------
// Notes and bookmarks
// ---------------------------------------------------------------------------

final notesProvider = AsyncNotifierProvider<NotesNotifier, List<Note>>(
    NotesNotifier.new);

class NotesNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() => ref.watch(repositoryProvider).loadNotes();

  Future<void> save(Note note) async {
    final repository = ref.read(repositoryProvider);
    // The write returns the persisted row, so the list is patched in place
    // instead of re-reading the whole table. With many notes the old
    // re-read-after-write was a visible hitch.
    final saved = await repository.saveNote(note);
    final current = state.valueOrNull ?? const <Note>[];
    final index = current.indexWhere((n) => n.id == saved.id);
    final next = [...current];
    if (index >= 0) {
      next[index] = saved;
    } else {
      next.insert(0, saved);
    }
    state = AsyncData(next);
    ref.read(syncServiceProvider).scheduleSync();
  }

  Future<void> remove(int id) async {
    final repository = ref.read(repositoryProvider);
    await repository.deleteNote(id);
    state = AsyncData(
        (state.valueOrNull ?? const <Note>[]).where((n) => n.id != id).toList());
    ref.read(syncServiceProvider).scheduleSync();
  }
}

final bookmarksProvider =
    AsyncNotifierProvider<BookmarksNotifier, List<Bookmark>>(
        BookmarksNotifier.new);

class BookmarksNotifier extends AsyncNotifier<List<Bookmark>> {
  @override
  Future<List<Bookmark>> build() => ref.watch(repositoryProvider).loadBookmarks();

  /// Set of `type:id` keys.
  ///
  /// Watched by every bookmark button in the app. Previously each button
  /// watched the whole list and ran a linear scan, so 39 formula cards each
  /// scanned the full list on every rebuild.
  Set<String> get keys =>
      state.valueOrNull?.map((b) => b.key).toSet() ?? const <String>{};

  bool isBookmarked(String type, int id) => keys.contains('$type:$id');

  Future<bool> toggle(String itemType, int itemId, String label) async {
    final repository = ref.read(repositoryProvider);
    final nowBookmarked = await repository.toggleBookmark(itemType, itemId, label);
    final current = state.valueOrNull ?? <Bookmark>[];
    state = AsyncData(
      nowBookmarked
          ? [
              Bookmark(
                id: -itemId,
                itemType: itemType,
                itemId: itemId,
                label: label,
                createdAt: DateTime.now(),
              ),
              ...current,
            ]
          : current
              .where((b) => !(b.itemType == itemType && b.itemId == itemId))
              .toList(),
    );
    ref.read(syncServiceProvider).scheduleSync();
    return nowBookmarked;
  }
}

/// Narrow bookmark state for a single button.
final isBookmarkedProvider = Provider.family<bool, ({String type, int id})>(
    (ref, key) {
  return ref
          .watch(bookmarksProvider
              .select((async) => async.valueOrNull?.map((b) => b.key).toSet()))
          ?.contains('${key.type}:${key.id}') ??
      false;
});

final bookmarkKeysProvider = Provider<Set<String>>((ref) {
  return ref
          .watch(bookmarksProvider.select((async) => async.valueOrNull))
          ?.map((b) => b.key)
          .toSet() ??
      const <String>{};
});

// ---------------------------------------------------------------------------
// Reference content
// ---------------------------------------------------------------------------

final formulasProvider =
    FutureProvider.family<List<Formula>, String?>((ref, category) {
  return ref.watch(repositoryProvider).loadFormulas(category: category);
});

final referencesProvider =
    FutureProvider.family<List<ProgrammingReference>, String?>(
        (ref, language) {
  return ref.watch(repositoryProvider).loadReferences(language: language);
});

// ---------------------------------------------------------------------------
// Assistant
// ---------------------------------------------------------------------------

final secureKeyStoreProvider =
    Provider<SecureKeyStore>((ref) => SecureKeyStore());

final remoteAiEnabledProvider = StateProvider<bool>((ref) {
  final client = ref.watch(remoteAiEngineProvider);
  return client.isEnabled;
});

final remoteAiEngineProvider = Provider<RemoteAiEngine>((ref) {
  final engine = RemoteAiEngine(
    keyStore: ref.watch(secureKeyStoreProvider),
    networkMonitor: ref.watch(networkMonitorProvider),
  );
  ref.onDispose(engine.close);
  return engine;
});

final aiServiceProvider = Provider<AiService>((ref) {
  return AiService(
    repository: ref.watch(repositoryProvider),
    local: LocalAiEngine(),
    remote: ref.watch(remoteAiEngineProvider),
  );
});

/// True once the on-device index is built. The assistant screen shows a
/// skeleton until this flips, rather than blocking on a spinner.
final aiIndexReadyProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(aiServiceProvider);
  await service.warmUp();
  return service.isIndexReady;
});

/// Study recommendations, derived from progress and the last viewed lesson.
final recommendationsProvider = FutureProvider<List<StudyRecommendation>>(
    (ref) async {
  final subjects = await ref.watch(subjectsProvider.future);
  final lastViewed = ref.watch(lastViewedLessonProvider);
  return ref.read(aiServiceProvider).recommend(
        subjects: subjects,
        lastViewedLessonId: lastViewed,
      );
});
