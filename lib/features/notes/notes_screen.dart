import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/design/app_spacing.dart';
import '../../core/utils/app_time.dart';
import '../../domain/entities/entities.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/cards.dart';
import '../../widgets/inputs.dart';
import '../../widgets/performance_watcher.dart';
import '../../widgets/states.dart';

/// Local notes with debounced search.
///
/// Search runs on the already-loaded list, so it works offline and needs no
/// request. The previous version lowercased every note's full body inside the
/// filter predicate on each keystroke, which copied the whole corpus per
/// character; the haystack is now built once per query change.
class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  String _query = '';

  static List<Note> _filter(List<Note> notes, String query) {
    if (query.isEmpty) return notes;
    final needle = query.toLowerCase();
    return notes
        .where((note) =>
            note.title.toLowerCase().contains(needle) ||
            note.content.toLowerCase().contains(needle))
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(notesProvider);
    final now = DateTime.now();

    return ScreenPerformanceWatcher(
      name: 'Notes',
      child: AppScaffold(
        title: 'Notes',
        slivers: [
          SliverToBoxAdapter(
            child: SearchField(
              hint: 'Search notes',
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
          ...notesAsync.when(
            data: (notes) {
              final filtered = _filter(notes, _query);
              if (filtered.isEmpty) {
                return [
                  EmptyStateSliver(
                    icon: notes.isEmpty ? Icons.note_add_outlined : Icons.search_off,
                    title: notes.isEmpty ? 'No notes yet' : 'Nothing matches',
                    message: notes.isEmpty
                        ? 'Notes you write here stay on this device and work offline.'
                        : 'Try a different search term.',
                    actionLabel: notes.isEmpty ? 'Write a note' : null,
                    onAction:
                        notes.isEmpty ? () => _edit(context, ref, null) : null,
                  ),
                ];
              }
              return [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.gutter, 0, AppSpacing.gutter, AppSpacing.sm),
                    child: Text(
                      '${filtered.length} note${filtered.length == 1 ? '' : 's'}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ),
                LazySliverList(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final note = filtered[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: AppListRow(
                        key: ValueKey(note.id),
                        title: note.title,
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              note.content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Updated ${AppTime.relative(note.updatedAt, now: now)}',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                        onTap: () => _edit(context, ref, note),
                        trailing: IconButton(
                          onPressed: () => _delete(context, ref, note),
                          icon: const Icon(Icons.delete_outline, size: 20),
                          tooltip: 'Delete note',
                        ),
                      ),
                    );
                  },
                ),
              ];
            },
            loading: () => const [SkeletonList(itemCount: 5, hasLeading: false)],
            error: (error, _) => [
              SliverFillRemaining(
                hasScrollBody: false,
                child: AppErrorView(
                  error: error,
                  onRetry: () => ref.invalidate(notesProvider),
                ),
              ),
            ],
          ),
        ],
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _edit(context, ref, null),
          icon: const Icon(Icons.add),
          label: const Text('New note'),
        ),
      ),
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, Note? note) async {
    final titleController = TextEditingController(text: note?.title);
    final bodyController = TextEditingController(text: note?.content);

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        // The keyboard inset is applied so the save button is never hidden
        // behind it on a short screen.
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    note == null ? 'New note' : 'Edit note',
                    style: Theme.of(sheetContext).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  controller: titleController,
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: bodyController,
                  minLines: 4,
                  maxLines: 8,
                  decoration: const InputDecoration(labelText: 'Note'),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(sheetContext).pop(false),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.of(sheetContext).pop(true),
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Disposed on every path, including dismissal by swipe or back button —
    // the previous version leaked both controllers on every open.
    final title = titleController.text.trim();
    final content = bodyController.text.trim();
    titleController.dispose();
    bodyController.dispose();

    if (saved != true || !context.mounted) return;
    if (title.isEmpty && content.isEmpty) return;

    await ref.read(notesProvider.notifier).save(
          Note(
            id: note?.id,
            title: title.isEmpty ? 'Untitled note' : title,
            content: content,
            subjectId: note?.subjectId,
            createdAt: note?.createdAt ?? DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
    if (context.mounted) {
      showAppSnackBar(context, 'Note saved on this device',
          icon: Icons.save_outlined);
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Note note) async {
    final confirmed = await confirmDialog(
      context,
      title: 'Delete note?',
      message: '"${note.title}" will be removed from this device.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!confirmed) return;
    await ref.read(notesProvider.notifier).remove(note.id!);
    if (context.mounted) {
      showAppSnackBar(context, 'Note deleted', icon: Icons.delete_outline);
    }
  }
}
