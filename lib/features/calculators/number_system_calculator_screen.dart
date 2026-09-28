import 'package:flutter/material.dart';

import '../../core/design/app_spacing.dart';
import '../../domain/services/number_system_service.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/cards.dart';
import '../../widgets/inputs.dart';
import '../../widgets/performance_watcher.dart';

/// Number-base converter.
///
/// The previous version called `setState` on *every keystroke* just to toggle
/// the clear button, which rebuilt the whole screen — inputs, dropdown,
/// buttons, result cards and history — per character. The clear button now
/// listens to the controller directly, so typing only repaints that icon.
class NumberSystemCalculatorScreen extends StatefulWidget {
  const NumberSystemCalculatorScreen({super.key});

  @override
  State<NumberSystemCalculatorScreen> createState() =>
      _NumberSystemCalculatorScreenState();
}

class _NumberSystemCalculatorScreenState
    extends State<NumberSystemCalculatorScreen> {
  final _inputController = TextEditingController();
  NumberBase _fromBase = NumberBase.binary;
  Map<NumberBase, String>? _results;
  String? _error;
  final _history = <String>[];

  static const _service = NumberSystemService();

  /// Bound so a long session cannot grow the list without limit.
  static const _maxHistory = 20;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _convert() {
    final input = _inputController.text.trim();
    if (input.isEmpty) {
      setState(() {
        _error = 'Enter a number';
        _results = null;
      });
      return;
    }
    if (!_service.isValid(input, _fromBase)) {
      setState(() {
        _error = 'Invalid ${_fromBase.label} number';
        _results = null;
      });
      return;
    }
    try {
      final results = _service.convertAll(input, _fromBase);
      setState(() {
        _results = results;
        _error = null;
        _history.insert(
          0,
          '$input (${_fromBase.label}) → '
          '${results[NumberBase.decimal]} (decimal)',
        );
        if (_history.length > _maxHistory) _history.removeLast();
      });
    } on Object catch (error) {
      setState(() {
        _error = 'Could not convert that value: $error';
        _results = null;
      });
    }
  }

  void _swap() {
    final results = _results;
    if (results == null) return;
    // One setState, one conversion. The previous version mutated the
    // controller inside setState and then called _convert, producing two full
    // rebuilds for a single tap.
    setState(() {
      _inputController.text = results[NumberBase.decimal]!;
      _fromBase = NumberBase.decimal;
    });
    _convert();
  }

  void _clear() {
    setState(() {
      _inputController.clear();
      _results = null;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenPerformanceWatcher(
      name: 'Number system',
      child: AppScaffold(
        title: 'Number system',
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.gutter),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _inputController,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _convert(),
                    decoration: InputDecoration(
                      labelText: 'Enter number',
                      hintText: 'e.g. 101101',
                      suffixIcon: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _inputController,
                        builder: (context, value, _) => value.text.isEmpty
                            ? const SizedBox.shrink()
                            : IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: _clear,
                                tooltip: 'Clear',
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  DropdownButtonFormField<NumberBase>(
                    initialValue: _fromBase,
                    decoration: const InputDecoration(labelText: 'Input base'),
                    items: [
                      for (final base in NumberBase.values)
                        DropdownMenuItem(
                          value: base,
                          child: Text(base.label),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _fromBase = value);
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          onPressed: _convert,
                          icon: const Icon(Icons.swap_horiz),
                          label: const Text('Convert'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _results == null ? null : _swap,
                          icon: const Icon(Icons.arrow_upward),
                          label: const Text('Swap'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      OutlinedButton(
                        onPressed: _clear,
                        child: const Icon(Icons.clear_all),
                      ),
                    ],
                  ),
                  if (_error != null) ErrorBanner(message: _error!),
                ],
              ),
            ),
          ),
          if (_results != null) ...[
            const SliverSectionHeader(title: 'Results'),
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
                child: Column(
                  children: [
                    for (final base in NumberBase.values)
                      ResultCard(
                        key: ValueKey('result:$base'),
                        label: base.label,
                        value: _results![base]!,
                        icon: Icons.tag,
                        onCopy: () => copyToClipboard(
                            context, _results![base]!, label: base.label),
                      ),
                  ],
                ),
              ),
            ),
          ],
          if (_history.isNotEmpty) ...[
            const SliverSectionHeader(title: 'History'),
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
                child: Column(
                  children: [
                    for (final entry in _history.take(10))
                      ListTile(
                        key: ValueKey(entry),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        leading: const Icon(Icons.history, size: 18),
                        title: Text(entry,
                            style: Theme.of(context).textTheme.bodySmall),
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
