import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/app_providers.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/ui.dart';
import '../../domain/entities/entities.dart';

class FormulasScreen extends ConsumerStatefulWidget {
  const FormulasScreen({super.key});

  @override
  ConsumerState<FormulasScreen> createState() => _FormulasScreenState();
}

class _FormulasScreenState extends ConsumerState<FormulasScreen> {
  String _query = '';
  String _category = 'All';

  @override
  Widget build(BuildContext context) {
    final formulasAsync = ref.watch(formulasProvider(null));
    final bookmarksAsync = ref.watch(bookmarksProvider);

    return PageFrame(
      title: 'Formulas',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search formulas',
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final c in ['All', ...AppConstants.formulaCategories])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(c),
                      selected: _category == c,
                      onSelected: (_) => setState(() => _category = c),
                    ),
                  ),
              ],
            ),
          ),
          const SectionTitle('Formula Library'),
          formulasAsync.when(
            data: (formulas) {
              final list = formulas
                  .where((f) =>
                      (_category == 'All' || f.category == _category) &&
                      (_query.isEmpty ||
                          f.name.toLowerCase().contains(_query.toLowerCase()) ||
                          f.expression.toLowerCase().contains(_query.toLowerCase())))
                  .toList();
              if (list.isEmpty) {
                return const EmptyState(
                  icon: Icons.functions_outlined,
                  title: 'No formulas found',
                  subtitle: 'Try a different search.',
                );
              }
              return Column(
                children: [
                  for (final f in list)
                    _FormulaCard(
                      formula: f,
                      isBookmarked: bookmarksAsync.valueOrNull
                              ?.any((b) =>
                                  b.itemType == 'formula' && b.itemId == f.id) ??
                          false,
                      onToggleBookmark: () => ref
                          .read(bookmarksProvider.notifier)
                          .toggle('formula', f.id, f.name),
                    ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => EmptyState(
              icon: Icons.error_outline,
              title: 'Could not load formulas',
              subtitle: '$e',
            ),
          ),
        ],
      ),
    );
  }
}

class _FormulaCard extends StatelessWidget {
  const _FormulaCard({
    required this.formula,
    required this.isBookmarked,
    required this.onToggleBookmark,
  });

  final Formula formula;
  final bool isBookmarked;
  final VoidCallback onToggleBookmark;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(formula.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 16)),
                ),
                IconButton(
                  icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border),
                  onPressed: onToggleBookmark,
                  iconSize: 20,
                ),
                IconButton(
                  icon: const Icon(Icons.copy_outlined),
                  onPressed: () {
                    Clipboard.setData(
                        ClipboardData(text: '${formula.name}: ${formula.expression}'));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Formula copied'),
                        duration: Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  iconSize: 20,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(formula.category,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: scheme.primary)),
            const SizedBox(height: 10),
            FormulaBlock(formula.expression),
            if (formula.variables.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text('Where:',
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(formula.variables,
                  style: Theme.of(context).textTheme.bodySmall),
            ],
            if (formula.application.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Application: ${formula.application}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant)),
            ],
          ],
        ),
      ),
    );
  }
}
