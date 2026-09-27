import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/app_providers.dart';
import '../../core/widgets/ui.dart';
import '../../domain/entities/entities.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final name = ref.watch(profileNameProvider);
    final notes = ref.watch(notesProvider);
    return PageFrame(
        title: 'Settings',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle('Profile'),
          Card(
              child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(name),
                  subtitle: const Text('Local study profile'),
                  trailing: const Icon(Icons.edit),
                  onTap: () => _editProfile(context, ref, name))),
          const SectionTitle('Appearance'),
          Card(
              child: Column(
                  children: ThemeMode.values
                      .map((value) => ListTile(
                          title: Text(value == ThemeMode.system
                              ? 'System'
                              : value == ThemeMode.light
                                  ? 'Light'
                                  : 'Dark'),
                          leading: Icon(mode == value
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off),
                          selected: mode == value,
                          onTap: () =>
                              ref.read(themeModeProvider.notifier).set(value)))
                      .toList())),
          const SectionTitle('Learning'),
          Card(
              child: ListTile(
                  leading: const Icon(Icons.bookmark_outline),
                  title: const Text('Notes & bookmarks'),
                  subtitle: Text('${notes.length} local notes'),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const NotesPage())))),
          const SectionTitle('Data'),
          Card(
              child: Column(children: [
            ListTile(
                leading: const Icon(Icons.upload_outlined),
                title: const Text('Export'),
                subtitle: const Text('Prepare your local study data')),
            ListTile(
                leading: const Icon(Icons.download_outlined),
                title: const Text('Import'),
                subtitle: const Text('Restore a study backup')),
            ListTile(
                leading: Icon(Icons.restart_alt,
                    color: Theme.of(context).colorScheme.error),
                title: Text('Reset progress',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
                onTap: () => _confirm(context, 'Reset progress?',
                    'Your completed lessons and quiz statistics will be removed.'))
          ])),
          const SectionTitle('About'),
          const Card(
              child: ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Computer Engineering Companion'),
                  subtitle:
                      Text('Offline-first study and engineering toolkit')))
        ]));
  }

  void _editProfile(BuildContext context, WidgetRef ref, String name) {
    final controller = TextEditingController(text: name);
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
                        ref
                            .read(profileNameProvider.notifier)
                            .set(controller.text);
                        Navigator.pop(context);
                      },
                      child: const Text('Save'))
                ]));
  }

  void _confirm(BuildContext context, String title, String content) {
    showDialog(
        context: context,
        builder: (_) =>
            AlertDialog(title: Text(title), content: Text(content), actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel')),
              FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Reset'))
            ]));
  }
}

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider);
    return Scaffold(
        appBar: AppBar(title: const Text('Notes & bookmarks')),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _edit(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('New note')),
        body: notes.isEmpty
            ? const Center(
                child: Text('No notes yet. Capture an idea from any lesson.'))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: notes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final note = notes[i];
                  return Card(
                      child: ListTile(
                          title: Text(note.title),
                          subtitle: Text(note.content,
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                          onTap: () => _edit(context, ref, note),
                          trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => ref
                                  .read(notesProvider.notifier)
                                  .remove(note.id!))));
                }));
  }

  void _edit(BuildContext context, WidgetRef ref, [Note? note]) {
    final title = TextEditingController(text: note?.title);
    final content = TextEditingController(text: note?.content);
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (modalContext) => Padding(
            padding: EdgeInsets.fromLTRB(
                20, 8, 20, MediaQuery.viewInsetsOf(modalContext).bottom + 20),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                  controller: title,
                  decoration: const InputDecoration(labelText: 'Title')),
              const SizedBox(height: 10),
              TextField(
                  controller: content,
                  maxLines: 5,
                  decoration: const InputDecoration(labelText: 'Your note')),
              const SizedBox(height: 14),
              Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                      onPressed: () {
                        if (title.text.trim().isNotEmpty) {
                          ref.read(notesProvider.notifier).save(Note(
                              id: note?.id,
                              title: title.text,
                              content: content.text,
                              updatedAt: DateTime.now()));
                          Navigator.pop(modalContext);
                        }
                      },
                      child: const Text('Save')))
            ])));
  }
}
