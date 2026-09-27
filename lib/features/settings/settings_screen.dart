import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/app_providers.dart';
import '../../core/widgets/ui.dart';
import '../notes/notes_screen.dart';
import '../bookmarks/bookmarks_screen.dart';
import '../progress/progress_screen.dart';
import '../formulas/formulas_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeModeAsync = ref.watch(themeModeProvider);
    final nameAsync = ref.watch(profileNameProvider);
    final notesAsync = ref.watch(notesProvider);
    final bookmarksAsync = ref.watch(bookmarksProvider);

    return PageFrame(
      title: 'Settings',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('Profile'),
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(nameAsync.valueOrNull ?? 'Student'),
              subtitle: const Text('Local study profile'),
              trailing: const Icon(Icons.edit),
              onTap: () => _editProfile(context, ref),
            ),
          ),
          const SectionTitle('Appearance'),
          Card(
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  value: ThemeMode.system,
                  groupValue: themeModeAsync.valueOrNull ?? ThemeMode.system,
                  onChanged: (mode) {
                    if (mode != null) {
                      ref.read(themeModeProvider.notifier).set(mode);
                    }
                  },
                  secondary: const Icon(Icons.brightness_auto),
                  title: const Text('System'),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.light,
                  groupValue: themeModeAsync.valueOrNull ?? ThemeMode.system,
                  onChanged: (mode) {
                    if (mode != null) {
                      ref.read(themeModeProvider.notifier).set(mode);
                    }
                  },
                  secondary: const Icon(Icons.light_mode),
                  title: const Text('Light'),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.dark,
                  groupValue: themeModeAsync.valueOrNull ?? ThemeMode.system,
                  onChanged: (mode) {
                    if (mode != null) {
                      ref.read(themeModeProvider.notifier).set(mode);
                    }
                  },
                  secondary: const Icon(Icons.dark_mode),
                  title: const Text('Dark'),
                ),
              ],
            ),
          ),
          const SectionTitle('Learning'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.note_outlined),
                  title: const Text('Notes'),
                  subtitle: Text('${notesAsync.valueOrNull?.length ?? 0} local notes'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const NotesScreen())),
                ),
                ListTile(
                  leading: const Icon(Icons.bookmark_outline),
                  title: const Text('Bookmarks'),
                  subtitle:
                      Text('${bookmarksAsync.valueOrNull?.length ?? 0} bookmarks'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const BookmarksScreen())),
                ),
                ListTile(
                  leading: const Icon(Icons.trending_up_outlined),
                  title: const Text('Progress'),
                  subtitle: const Text('View your learning statistics'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ProgressScreen())),
                ),
                ListTile(
                  leading: const Icon(Icons.functions_outlined),
                  title: const Text('Formula Library'),
                  subtitle: const Text('Browse and bookmark formulas'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const FormulasScreen())),
                ),
              ],
            ),
          ),
          const SectionTitle('Data'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.restart_alt,
                      color: Theme.of(context).colorScheme.error),
                  title: Text('Reset all data',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error)),
                  subtitle: const Text(
                      'Clear all progress, notes, and bookmarks'),
                  onTap: () => _confirmReset(context, ref),
                ),
              ],
            ),
          ),
          const SectionTitle('About'),
          const Card(
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Computer Engineering Companion'),
              subtitle: Text(
                  'Offline-first study and engineering toolkit\nVersion 2.0.0'),
            ),
          ),
        ],
      ),
    );
  }

  void _editProfile(BuildContext context, WidgetRef ref) {
    final controller =
        TextEditingController(text: ref.read(profileNameProvider).valueOrNull);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Profile name'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              ref.read(profileNameProvider.notifier).set(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset all data?'),
        content: const Text(
            'This will permanently delete all progress, notes, bookmarks, and quiz history. This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () async {
              await ref.read(repositoryProvider).resetAll();
              ref.invalidate(subjectsProvider);
              ref.invalidate(activitiesProvider);
              ref.invalidate(quizAttemptsProvider);
              ref.invalidate(progressStatsProvider);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All data has been reset')),
                );
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
