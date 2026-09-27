import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/companion_repository.dart';
import '../domain/entities/entities.dart';

final repositoryProvider = Provider((ref) => CompanionRepository());
final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;
  void set(ThemeMode mode) => state = mode;
}

final profileNameProvider =
    NotifierProvider<ProfileNameNotifier, String>(ProfileNameNotifier.new);

class ProfileNameNotifier extends Notifier<String> {
  @override
  String build() => 'Student';
  void set(String value) =>
      state = value.trim().isEmpty ? 'Tommy' : value.trim();
}

final subjectsProvider =
    NotifierProvider<SubjectsNotifier, List<Subject>>(SubjectsNotifier.new);

class SubjectsNotifier extends Notifier<List<Subject>> {
  @override
  List<Subject> build() => ref.read(repositoryProvider).subjects();
  Future<void> complete(Subject subject) async {
    await ref.read(repositoryProvider).completeLesson(subject);
    state = ref.read(repositoryProvider).subjects();
    ref.invalidate(activityProvider);
  }
}

final activityProvider = Provider<List<ActivityItem>>(
    (ref) => ref.read(repositoryProvider).activities());
final notesProvider =
    NotifierProvider<NotesNotifier, List<Note>>(NotesNotifier.new);

class NotesNotifier extends Notifier<List<Note>> {
  @override
  List<Note> build() => ref.read(repositoryProvider).notes();
  Future<void> save(Note note) async {
    await ref.read(repositoryProvider).saveNote(note);
    state = ref.read(repositoryProvider).notes();
  }

  Future<void> remove(int id) async {
    await ref.read(repositoryProvider).deleteNote(id);
    state = ref.read(repositoryProvider).notes();
  }
}

final bookmarkProvider =
    NotifierProvider<BookmarksNotifier, Set<String>>(BookmarksNotifier.new);

class BookmarksNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => ref.read(repositoryProvider).bookmarks();
  Future<void> toggle(String key) async {
    await ref.read(repositoryProvider).toggleBookmark(key);
    final next = {...state};
    next.contains(key) ? next.remove(key) : next.add(key);
    state = next;
  }
}
