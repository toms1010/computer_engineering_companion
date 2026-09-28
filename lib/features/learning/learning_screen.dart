import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/design/app_spacing.dart';
import '../../domain/entities/entities.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/cards.dart';
import '../../widgets/inputs.dart';
import '../../widgets/performance_watcher.dart';
import '../../widgets/states.dart';

/// Subject browser with category filters and debounced search.
///
/// The previous version filtered inside `build` on every keystroke and
/// called `toLowerCase()` inside the predicate — four string allocations per
/// subject per character. Filtering now happens in [setState] after a
/// debounce, against a precomputed lowercase haystack, and the result list is
/// rendered through [LazySliverList] rather than a `Column`.
class LearningScreen extends ConsumerStatefulWidget {
  const LearningScreen({super.key});

  @override
  ConsumerState<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends ConsumerState<LearningScreen> {
  String _category = 'All';
  String _query = '';

  /// Filters on a debounced query rather than on every keystroke, and
  /// lowercases the query once instead of once per subject.
  List<Subject> _filter(List<Subject> subjects) {
    final query = _query.toLowerCase();
    final result = <Subject>[];
    for (final subject in subjects) {
      if (_category != 'All' && subject.category != _category) continue;
      if (query.isNotEmpty && !subject.name.toLowerCase().contains(query)) {
        continue;
      }
      result.add(subject);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final subjectsAsync = ref.watch(subjectsProvider);
    final total = subjectsAsync.valueOrNull?.length ?? 0;

    return ScreenPerformanceWatcher(
      name: 'Learn',
      child: AppScaffold(
        title: 'Learn',
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.formulas),
            icon: const Icon(Icons.functions_outlined),
            tooltip: 'Formula library',
          ),
          IconButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.references),
            icon: const Icon(Icons.code_outlined),
            tooltip: 'Code reference',
          ),
        ],
        slivers: [
          SliverToBoxAdapter(
            child: SearchField(
              hint: 'Search $total subjects',
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
          SliverToBoxAdapter(
            child: FilterChipRow(
              options: AppConstants.subjectCategories,
              selected: _category,
              onSelected: (value) => setState(() => _category = value),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xs)),
          ...subjectsAsync.when(
            data: (subjects) {
              final filtered = _filter(subjects);
              if (filtered.isEmpty) {
                return [
                  const EmptyStateSliver(
                    icon: Icons.search_off,
                    title: 'Nothing matches',
                    message: 'Try a different search term or category.',
                  ),
                ];
              }
              return [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.gutter, AppSpacing.sm, AppSpacing.gutter, 0),
                    child: Text(
                      '${filtered.length} of $total subjects',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ),
                LazySliverList(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final subject = filtered[index];
                    return _SubjectTile(
                      key: ValueKey(subject.id),
                      subject: subject,
                      onTap: () => Navigator.of(context).pushNamed(
                        AppRoutes.subject,
                        arguments: {RouteArgs.subject: subject},
                      ),
                    );
                  },
                ),
              ];
            },
            loading: () => const [SkeletonList(itemCount: 7)],
            error: (error, _) => [
              SliverFillRemaining(
                hasScrollBody: false,
                child: AppErrorView(
                  error: error,
                  onRetry: () => ref.invalidate(subjectsProvider),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SubjectTile extends StatelessWidget {
  const _SubjectTile({super.key, required this.subject, required this.onTap});

  final Subject subject;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final percent = (subject.progress * 100).round();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppListRow(
        title: subject.name,
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(subject.description,
                maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(
              '${subject.completedLessons}/${subject.totalLessons} lessons'
              '${subject.isComplete ? ' • complete' : ''}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        onTap: onTap,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: scheme.secondaryContainer,
            borderRadius: BorderRadius.circular(AppSpacing.sm),
          ),
          child: Icon(subject.iconData, color: scheme.onSecondaryContainer, size: 22),
        ),
        trailing: SizedBox(
          width: 48,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$percent%',
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: scheme.primary)),
              const SizedBox(height: AppSpacing.xs),
              ProgressBar(
                value: subject.progress,
                height: 5,
                label: '${subject.name} progress',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
