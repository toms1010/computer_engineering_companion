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

/// Offline code reference.
///
/// These 39 snippets were seeded into the database from the start but had no
/// screen, so the content was unreachable. This screen is the missing piece
/// that makes the bundled reference data actually usable.
class ReferencesScreen extends ConsumerStatefulWidget {
  const ReferencesScreen({super.key});

  @override
  ConsumerState<ReferencesScreen> createState() => _ReferencesScreenState();
}

class _ReferencesScreenState extends ConsumerState<ReferencesScreen> {
  String _language = 'All';
  String _query = '';

  static List<ProgrammingReference> _filter(
    List<ProgrammingReference> all,
    String language,
    String query,
  ) {
    final needle = query.toLowerCase();
    return [
      for (final reference in all)
        if (language == 'All' || reference.language == language)
          if (needle.isEmpty ||
              reference.title.toLowerCase().contains(needle) ||
              reference.topic.toLowerCase().contains(needle))
            reference,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final referencesAsync = ref.watch(referencesProvider(null));

    return ScreenPerformanceWatcher(
      name: 'Code reference',
      child: AppScaffold(
        title: 'Code reference',
        slivers: [
          SliverToBoxAdapter(
            child: SearchField(
              hint: 'Search snippets',
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
          SliverToBoxAdapter(
            child: FilterChipRow(
              options: const ['All', ...AppConstants.programmingLanguages],
              selected: _language,
              onSelected: (value) => setState(() => _language = value),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
          ...referencesAsync.when(
            data: (all) {
              final filtered = _filter(all, _language, _query);
              if (filtered.isEmpty) {
                return const [
                  EmptyStateSliver(
                    icon: Icons.code_off,
                    title: 'No matching snippets',
                    message: 'Try a different language or search term.',
                  ),
                ];
              }
              return [
                LazySliverList(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final reference = filtered[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Card(
                        key: ValueKey(reference.id),
                        child: ExpansionTile(
                          shape: const Border(),
                          collapsedShape: const Border(),
                          leading: Pill(
                            label: reference.language,
                            dense: true,
                          ),
                          title: Text(reference.title),
                          subtitle: Text(reference.topic),
                          childrenPadding: const EdgeInsets.fromLTRB(
                              AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
                          children: [
                            CodeBlock(
                              code: reference.code,
                              onCopy: () => copyToClipboard(
                                  context, reference.code,
                                  label: 'snippet'),
                            ),
                          ],
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
                  onRetry: () => ref.invalidate(referencesProvider(null)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
