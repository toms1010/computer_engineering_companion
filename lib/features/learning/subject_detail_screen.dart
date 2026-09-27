import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/app_providers.dart';
import '../../core/widgets/ui.dart';
import '../../domain/entities/entities.dart';
import 'lesson_detail_screen.dart';

class SubjectDetailScreen extends ConsumerWidget {
  const SubjectDetailScreen({super.key, required this.subject});
  final Subject subject;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(subjectDetailProvider(subject.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(subject.name),
        actions: [
          _BookmarkButton(subject: subject),
        ],
      ),
      body: detailAsync.when(
        data: (detail) {
          final lessons = detail.lessons;
          if (lessons.isEmpty) {
            return const EmptyState(
              icon: Icons.menu_book_outlined,
              title: 'No lessons yet',
              subtitle: 'Lessons for this subject are coming soon.',
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(subject.description,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer)),
                      const SizedBox(height: 10),
                      ProgressLine(subject.progress),
                      const SizedBox(height: 8),
                      Text(
                        '${subject.completedLessons} of ${subject.totalLessons} lessons completed',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              for (var i = 0; i < lessons.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _LessonTile(
                    lesson: lessons[i],
                    index: i + 1,
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load lessons',
          subtitle: '$e',
        ),
      ),
    );
  }
}

class _BookmarkButton extends ConsumerWidget {
  const _BookmarkButton({required this.subject});
  final Subject subject;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksAsync = ref.watch(bookmarksProvider);
    final isBookmarked = bookmarksAsync.valueOrNull
            ?.any((b) => b.itemType == 'subject' && b.itemId == subject.id) ??
        false;
    return IconButton(
      icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
      onPressed: () async {
        final added = await ref
            .read(bookmarksProvider.notifier)
            .toggle('subject', subject.id, subject.name);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(added
                  ? 'Bookmarked ${subject.name}'
                  : 'Removed bookmark'),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({required this.lesson, required this.index});
  final Lesson lesson;
  final int index;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: lesson.isCompleted
              ? scheme.primaryContainer
              : scheme.surfaceContainerHighest,
          child: lesson.isCompleted
              ? Icon(Icons.check, color: scheme.onPrimaryContainer, size: 20)
              : Text('$index',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurfaceVariant)),
        ),
        title: Text(lesson.title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          lesson.concept,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: scheme.onSurfaceVariant),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => LessonDetailScreen(lessonId: lesson.id)),
        ),
      ),
    );
  }
}
