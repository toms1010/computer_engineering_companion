import 'package:flutter/material.dart';

import '../core/design/app_breakpoints.dart';
import '../core/design/app_spacing.dart';
import '../core/error/app_exception.dart';
import 'app_scaffold.dart';
import 'cards.dart';
import 'inputs.dart';
import 'performance_watcher.dart';

/// One numeric input.
class CalculatorField {
  const CalculatorField({
    required this.label,
    this.hint,
    this.initial = '',
    this.allowNegative = false,
    this.optional = false,
  });

  final String label;
  final String? hint;
  final String initial;

  /// Negative values are valid for some formulas (angle, delta) and invalid
  /// for others (resistance, counts).
  final bool allowNegative;

  /// When true the field may be left blank, and is then simply absent from
  /// the input map. Needed for "any two of these three" formulas such as
  /// Ohm's law or P = VI = I²R = V²/R.
  final bool optional;
}

/// One computed output.
class CalculatorResult {
  const CalculatorResult({
    required this.label,
    required this.value,
    this.unit = '',
    this.note,
    this.icon,
  });

  final String label, value, unit;
  final String? note;
  final IconData? icon;

  /// Formats value + unit, keeping the value selectable on its own.
  String get display => unit.isEmpty ? value : '$value $unit';
}

/// Generic formula calculator screen.
///
/// Twenty-one of the calculator screens in this app were near-identical
/// copies: a formula banner, two or three numeric fields, a Calculate button
/// and a stack of result cards. They are collapsed here into one widget
/// configured by data, which removes the duplication and means a layout or
/// accessibility fix applies everywhere at once.
///
/// The computation itself stays a plain Dart function, so it is directly
/// unit-testable without pumping a widget.
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({
    super.key,
    required this.title,
    required this.formula,
    required this.fields,
    required this.compute,
    this.description,
    this.inputLabel = 'Calculate',
  });

  final String title;

  /// The formula shown at the top, e.g. `V = I × R`.
  final String formula;

  final List<CalculatorField> fields;

  /// Computes the outputs, or throws [ValidationException] with a message the
  /// user can act on.
  final List<CalculatorResult> Function(Map<String, double> input) compute;

  final String? description;
  final String inputLabel;

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  late final List<TextEditingController> _controllers = [
    for (final field in widget.fields) TextEditingController(text: field.initial),
  ];

  List<CalculatorResult>? _results;
  String? _error;

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _calculate() {
    final input = <String, double>{};
    for (var i = 0; i < widget.fields.length; i++) {
      final field = widget.fields[i];
      final raw = _controllers[i].text.trim();
      if (raw.isEmpty && field.optional) continue;
      if (raw.isEmpty) {
        setState(() {
          _error = 'Enter ${field.label.toLowerCase()}';
          _results = null;
        });
        return;
      }
      final value = double.tryParse(raw);
      if (value == null) {
        setState(() {
          _error = '${field.label} must be a number';
          _results = null;
        });
        return;
      }
      if (!field.allowNegative && value < 0) {
        setState(() {
          _error = '${field.label} cannot be negative';
          _results = null;
        });
        return;
      }
      input[field.label] = value;
    }

    try {
      final results = widget.compute(input);
      setState(() {
        _results = results;
        _error = null;
      });
    } on ValidationException catch (error) {
      setState(() {
        _error = error.message;
        _results = null;
      });
    } on Object catch (error) {
      setState(() {
        _error = 'Could not compute that: $error';
        _results = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;

    return ScreenPerformanceWatcher(
      name: widget.title,
      child: AppScaffold(
        title: widget.title,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.gutter),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FormulaPanel(formula: widget.formula, label: 'Formula'),
                  if (widget.description != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      widget.description!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  for (var i = 0; i < widget.fields.length; i++) ...[
                    TextField(
                      key: ValueKey('${widget.title}:${widget.fields[i].label}'),
                      controller: _controllers[i],
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                        signed: widget.fields[i].allowNegative,
                      ),
                      decoration: InputDecoration(
                        labelText: widget.fields[i].optional
                            ? '${widget.fields[i].label} (optional)'
                            : widget.fields[i].label,
                        hintText: widget.fields[i].hint,
                      ),
                      onSubmitted: (_) => _calculate(),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  FilledButton.icon(
                    onPressed: _calculate,
                    icon: const Icon(Icons.calculate_outlined),
                    label: Text(widget.inputLabel),
                  ),
                  if (_error != null) ErrorBanner(message: _error!),
                ],
              ),
            ),
          ),
          if (results != null) ...[
            const SliverSectionHeader(title: 'Result'),
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
                child: Column(
                  children: [
                    for (var i = 0; i < results.length; i++)
                      ResultCard(
                        key: ValueKey('${widget.title}:out:$i'),
                        label: results[i].label,
                        value: results[i].display,
                        subtitle: results[i].note,
                        icon: results[i].icon,
                        onCopy: () =>
                            copyToClipboard(context, results[i].display),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Index screen listing a group of calculators.
///
/// Rows go through a lazy sliver list, and on wide screens the list is laid
/// out in two columns so a tablet does not show a single very wide row.
class CalculatorIndexScreen extends StatelessWidget {
  const CalculatorIndexScreen({
    super.key,
    required this.title,
    required this.description,
    required this.entries,
  });

  final String title;
  final String? description;
  final List<CalculatorEntry> entries;

  @override
  Widget build(BuildContext context) {
    return ScreenPerformanceWatcher(
      name: title,
      child: AppScaffold(
        title: title,
        slivers: [
          if (description != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.gutter, AppSpacing.sm, AppSpacing.gutter, 0),
                child: Text(
                  description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ),
          SliverLayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.crossAxisExtent >= Breakpoints.large;
              if (!wide) {
                return LazySliverList(
                  itemCount: entries.length,
                  itemBuilder: (context, index) => _Entry(
                    key: ValueKey(entries[index].title),
                    entry: entries[index],
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.gutter),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 460,
                    mainAxisExtent: 88,
                    crossAxisSpacing: AppSpacing.sm,
                    mainAxisSpacing: AppSpacing.sm,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _Entry(
                      key: ValueKey(entries[index].title),
                      entry: entries[index],
                    ),
                    childCount: entries.length,
                    addRepaintBoundaries: true,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class CalculatorEntry {
  const CalculatorEntry({
    required this.title,
    required this.formula,
    required this.icon,
    required this.fields,
    required this.compute,
    this.description,
  });

  final String title, formula;
  final IconData icon;
  final List<CalculatorField> fields;
  final List<CalculatorResult> Function(Map<String, double>) compute;
  final String? description;
}

class _Entry extends StatelessWidget {
  const _Entry({super.key, required this.entry});

  final CalculatorEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Card(
        child: ListTile(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CalculatorScreen(
                title: entry.title,
                formula: entry.formula,
                fields: entry.fields,
                compute: entry.compute,
                description: entry.description,
              ),
            ),
          ),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppSpacing.sm),
            ),
            child: Icon(entry.icon, size: 20, color: scheme.onPrimaryContainer),
          ),
          title: Text(entry.title),
          subtitle: Text(entry.formula),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}
