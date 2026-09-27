import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/companion_repository.dart';
import '../domain/entities/entities.dart';
import '../domain/services/progress_service.dart';

final repositoryProvider = Provider<CompanionRepository>((ref) {
  final repository = CompanionRepository();
  ref.onDispose(repository.close);
  return repository;
});

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

final themeModeProvider =
    AsyncNotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends AsyncNotifier<ThemeMode> {
  @override
  Future<ThemeMode> build() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    return switch (prefs.getString('theme_mode')) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> set(ThemeMode mode) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString('theme_mode', switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    });
    state = AsyncData(mode);
  }
}

final profileNameProvider =
    AsyncNotifierProvider<ProfileNameNotifier, String>(ProfileNameNotifier.new);

class ProfileNameNotifier extends AsyncNotifier<String> {
  @override
  Future<String> build() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    return prefs.getString('profile_name') ?? 'Student';
  }

  Future<void> set(String value) async {
    final name = value.trim().isEmpty ? 'Student' : value.trim();
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString('profile_name', name);
    state = AsyncData(name);
  }
}

final subjectsProvider =
    FutureProvider<List<Subject>>((ref) async {
  final repository = ref.watch(repositoryProvider);
  return repository.loadSubjects();
});

final subjectDetailProvider =
    FutureProvider.family<SubjectDetail, int>((ref, subjectId) async {
  final repository = ref.watch(repositoryProvider);
  final subjects = await repository.loadSubjects();
  final subject = subjects.firstWhere((s) => s.id == subjectId);
  final lessons = await repository.loadLessons(subjectId);
  return SubjectDetail(subject: subject, lessons: lessons);
});

class SubjectDetail {
  const SubjectDetail({required this.subject, required this.lessons});
  final Subject subject;
  final List<Lesson> lessons;
}

final lessonDetailProvider =
    FutureProvider.family<LessonDetail, int>((ref, lessonId) async {
  final repository = ref.watch(repositoryProvider);
  final lesson = await repository.loadLesson(lessonId);
  final topics = await repository.loadTopics(lessonId);
  return LessonDetail(lesson: lesson, topics: topics);
});

class LessonDetail {
  const LessonDetail({required this.lesson, required this.topics});
  final Lesson? lesson;
  final List<Topic> topics;
}

final activitiesProvider =
    FutureProvider<List<ActivityItem>>((ref) async {
  final repository = ref.watch(repositoryProvider);
  return repository.loadActivities();
});

final quizAttemptsProvider =
    FutureProvider<List<QuizAttempt>>((ref) async {
  final repository = ref.watch(repositoryProvider);
  return repository.loadQuizAttempts();
});

final notesProvider = AsyncNotifierProvider<NotesNotifier, List<Note>>(NotesNotifier.new);

class NotesNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() async {
    final repository = ref.watch(repositoryProvider);
    return repository.loadNotes();
  }

  Future<void> save(Note note) async {
    final repository = ref.read(repositoryProvider);
    await repository.saveNote(note);
    state = AsyncData(await repository.loadNotes());
  }

  Future<void> remove(int id) async {
    final repository = ref.read(repositoryProvider);
    await repository.deleteNote(id);
    state = AsyncData(await repository.loadNotes());
  }
}

final bookmarksProvider =
    AsyncNotifierProvider<BookmarksNotifier, List<Bookmark>>(BookmarksNotifier.new);

class BookmarksNotifier extends AsyncNotifier<List<Bookmark>> {
  @override
  Future<List<Bookmark>> build() async {
    final repository = ref.watch(repositoryProvider);
    return repository.loadBookmarks();
  }

  Future<bool> toggle(String itemType, int itemId, String label) async {
    final repository = ref.read(repositoryProvider);
    final wasBookmarked = await repository.isBookmarked(itemType, itemId);
    await repository.toggleBookmark(itemType, itemId, label);
    state = AsyncData(await repository.loadBookmarks());
    return !wasBookmarked;
  }
}

final progressServiceProvider = Provider<ProgressService>((ref) {
  return const ProgressService();
});

final progressStatsProvider =
    FutureProvider<ProgressStats>((ref) async {
  final repository = ref.watch(repositoryProvider);
  final subjects = await repository.loadSubjects();
  final lessons = <Lesson>[];
  for (final subject in subjects) {
    lessons.addAll(await repository.loadLessons(subject.id));
  }
  final attempts = await repository.loadQuizAttempts();
  final sessions = await repository.loadStudySessions();
  return ref.read(progressServiceProvider).computeStats(
        subjects: subjects,
        allLessons: lessons,
        attempts: attempts,
        sessions: sessions,
      );
});

final formulasProvider =
    FutureProvider.family<List<Formula>, String?>((ref, category) async {
  final repository = ref.watch(repositoryProvider);
  return repository.loadFormulas(category: category);
});

final referencesProvider =
    FutureProvider.family<List<ProgrammingReference>, String?>((ref, language) async {
  final repository = ref.watch(repositoryProvider);
  return repository.loadReferences(language: language);
});
