import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/design/app_spacing.dart';
import '../../core/utils/app_time.dart';
import '../../domain/entities/entities.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/cards.dart';
import '../../widgets/performance_watcher.dart';
import '../../widgets/states.dart';

/// Saved subjects, lessons and formulas, grouped by kind.
///
/// The previous version built a `ListView(children: [...])` over a list that
/// grows with every bookmark — 340 lessons alone are bookmarkable — so
/// hundreds of rows were constructed and laid out at once. Grouping now
/// happens once per data change in [ref.watch] rather than inside `build`,
/// and rows render through a lazy sliver list with stable keys.
class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarks = ref.watch(bookmarksProvider);

    return ScreenPerformanceWatcher(
      name: 'Bookmarks',
      child: AppScaffold(
        title: 'Bookmarks',
        slivers: bookmarks.when(
          data: (items) {
            if (items.isEmpty) {
              return const [
                EmptyStateSliver(
                  icon: Icons.bookmark_border,
                  title: 'No bookmarks yet',
                  message:
                      'Bookmark a subject, lesson or formula and it will appear here.',
                ),
              ];
            }

            final grouped = <String, List<Bookmark>>{};
            for (final bookmark in items) {
              grouped.putIfAbsent(bookmark.itemType, () => []).add(bookmark);
            }

            // Flatten to headers + rows so one lazy delegate covers the whole
            // screen instead of nesting a list per group.
            final rows = <_Row>[];
            for (final entry in grouped.entries) {
              rows.add(_Row.header(_labelFor(entry.key)));
              for (final bookmark in entry.value) {
                rows.add(_Row.item(bookmark));
              }
            }

            return [
              LazySliverList(
                itemCount: rows.length,
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.gutter, AppSpacing.sm, AppSpacing.gutter, 0),
                itemBuilder: (context, index) {
                  final row = rows[index];
                  if (row.isHeader) {
                    return SectionHeader(title: row.label!);
                  }
                  final bookmark = row.bookmark!;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: AppListRow(
                      key: ValueKey(bookmark.id),
                      title: bookmark.label,
                      subtitle: Text(
                          'Added ${AppTime.relative(bookmark.createdAt)}'),
                      leading: Icon(_iconFor(bookmark.itemType)),
                      trailing: IconButton(
                        onPressed: () => ref
                            .read(bookmarksProvider.notifier)
                            .toggle(
                                bookmark.itemType,
                                bookmark.itemId,
                                bookmark.label),
                        icon: const Icon(Icons.bookmark_remove_outlined),
                        tooltip: 'Remove bookmark',
                      ),
                    ),
                  );
                },
              ),
            ];
          },
          loading: () => const [SkeletonList(itemCount: 6, hasLeading: false)],
          error: (error, _) => [
            SliverFillRemaining(
              hasScrollBody: false,
              child: AppErrorView(
                error: error,
                onRetry: () => ref.invalidate(bookmarksProvider),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _labelFor(String type) => switch (type) {
        'subject' => 'Subjects',
        'lesson' => 'Lessons',
        'formula' => 'Formulas',
        _ => 'Other',
      };

  static IconData _iconFor(String type) => switch (type) {
        'subject' => Icons.folder_outlined,
        'lesson' => Icons.menu_book_outlined,
        'formula' => Icons.functions_outlined,
        _ => Icons.bookmark_border,
      };
}

/// A flattened list row: either a group header or a bookmark.
class _Row {
  const _Row._({this.label, this.bookmark});

  factory _Row.header(String label) => _Row._(label: label);
  factory _Row.item(Bookmark bookmark) => _Row._(bookmark: bookmark);

  final String? label;
  final Bookmark? bookmark;

  bool get isHeader => label != null;
}
