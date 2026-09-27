import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/app_providers.dart';
import '../../core/widgets/ui.dart';
import '../../domain/entities/entities.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksAsync = ref.watch(bookmarksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks')),
      body: bookmarksAsync.when(
        data: (bookmarks) {
          if (bookmarks.isEmpty) {
            return const EmptyState(
              icon: Icons.bookmark_border,
              title: 'No bookmarks yet',
              subtitle:
                  'Bookmark lessons, formulas, and subjects to save them here.',
            );
          }
          final grouped = <String, List<Bookmark>>{};
          for (final b in bookmarks) {
            grouped.putIfAbsent(b.itemType, () => []).add(b);
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              for (final entry in grouped.entries) ...[
                Text(
                  _typeLabel(entry.key),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                for (final b in entry.value)
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(_typeIcon(b.itemType)),
                      title: Text(b.label,
                          style:
                              const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('Added ${_formatDate(b.createdAt)}',
                          style: Theme.of(context).textTheme.bodySmall),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => ref
                            .read(bookmarksProvider.notifier)
                            .toggle(b.itemType, b.itemId, b.label),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load bookmarks',
          subtitle: '$e',
        ),
      ),
    );
  }

  String _typeLabel(String type) {
    return switch (type) {
      'subject' => 'Subjects',
      'lesson' => 'Lessons',
      'formula' => 'Formulas',
      'question' => 'Questions',
      'reference' => 'References',
      _ => type,
    };
  }

  IconData _typeIcon(String type) {
    return switch (type) {
      'subject' => Icons.subject_outlined,
      'lesson' => Icons.menu_book_outlined,
      'formula' => Icons.functions_outlined,
      'question' => Icons.quiz_outlined,
      'reference' => Icons.code_outlined,
      _ => Icons.bookmark_outline,
    };
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
