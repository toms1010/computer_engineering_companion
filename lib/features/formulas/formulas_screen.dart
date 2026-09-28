import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/constants/app_constants.dart';
import '../../core/design/app_spacing.dart';
import '../../domain/entities/entities.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/cards.dart';
import '../../widgets/inputs.dart';
import '../../widgets/performance_watcher.dart';
import '../../widgets/states.dart';

/// Searchable, bookmarkable formula library.
///
/// All 39 formulas are loaded once and cached in the repository, then
/// filtered locally. The previous implementation rebuilt all 39 cards inside
/// a `Column` on every keystroke, and each card ran a linear bookmark scan —
/// the worst per-keystroke cost in the app. Both are gone: filtering happens
/// in [setState] on a debounced query, and bookmark state is a single `Set`
/// lookup.
class FormulasScreen extends ConsumerStatefulWidget {
  const FormulasScreen({super.key});

  @override
  ConsumerState<FormulasScreen> createState() => _FormulasScreenState();
}

class _FormulasScreenState extends ConsumerState<FormulasScreen> {
  String _category = 'All';
  String _query = '';

  static const _categories = ['All', ...AppConstants.formulaCategories];

  static List<Formula> _filter(List<Formula> formulas, String category, String query) {
    final needle = query.toLowerCase();
    if (category == 'All' && needle.isEmpty) return formulas;
    return [
      for (final formula in formulas)
        if (category == 'All' || formula.category == category)
          if (needle.isEmpty ||
              formula.name.toLowerCase().contains(needle) ||
              formula.expression.toLowerCase().contains(needle))
            formula,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final formulasAsync = ref.watch(formulasProvider(null));
    final bookmarkKeys = ref.watch(bookmarkKeysProvider);

    return ScreenPerformanceWatcher(
      name: 'Formulas',
      child: AppScaffold(
        title: 'Formulas',
        slivers: [
          SliverToBoxAdapter(
            child: SearchField(
              hint: 'Search formulas',
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
          SliverToBoxAdapter(
            child: FilterChipRow(
              options: _categories,
              selected: _category,
              onSelected: (value) => setState(() => _category = value),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
          ...formulasAsync.when(
            data: (all) {
              final filtered = _filter(all, _category, _query);
              if (filtered.isEmpty) {
                return const [
                  EmptyStateSliver(
                    icon: Icons.search_off,
                    title: 'No matching formulas',
                    message: 'Try a different term or category.',
                  ),
                ];
              }
              return [
                LazySliverList(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final formula = filtered[index];
                    return _FormulaCard(
                      key: ValueKey(formula.id),
                      formula: formula,
                      isBookmarked:
                          bookmarkKeys.contains('formula:${formula.id}'),
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
                  onRetry: () => ref.invalidate(formulasProvider(null)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FormulaCard extends ConsumerWidget {
  const _FormulaCard({
    super.key,
    required this.formula,
    required this.isBookmarked,
  });

  final Formula formula;
  final bool isBookmarked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: ContentCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(formula.name, style: theme.textTheme.titleMedium),
                ),
                IconButton(
                  onPressed: () => ref
                      .read(bookmarksProvider.notifier)
                      .toggle('formula', formula.id, formula.name),
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                  ),
                  tooltip: isBookmarked ? 'Remove bookmark' : 'Bookmark',
                ),
              ],
            ),
            FormulaPanel(
              formula: formula.expression,
              onCopy: () => copyToClipboard(context,
                  '${formula.name}: ${formula.expression}',
                  label: 'formula'),
            ),
            if (formula.variables.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text('Variables', style: theme.textTheme.labelMedium),
              Text(formula.variables, style: theme.textTheme.bodySmall),
            ],
            if (formula.application.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text('Applied to', style: theme.textTheme.labelMedium),
              Text(formula.application, style: theme.textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}
