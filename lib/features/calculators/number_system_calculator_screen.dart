import 'package:flutter/material.dart';
import '../../core/widgets/ui.dart';
import '../../domain/services/number_system_service.dart';

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

  final _service = const NumberSystemService();

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
            0, '${input} (${_fromBase.label}) → ${results[NumberBase.decimal]} (decimal)');
        if (_history.length > 20) _history.removeLast();
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _results = null;
      });
    }
  }

  void _swap() {
    if (_results == null) return;
    final decimal = _results![NumberBase.decimal]!;
    setState(() {
      _inputController.text = decimal;
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
    return Scaffold(
      appBar: AppBar(title: const Text('Number System Calculator')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _inputController,
            decoration: InputDecoration(
              labelText: 'Enter number',
              hintText: 'e.g. 101101',
              suffixIcon: _inputController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clear,
                    )
                  : null,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<NumberBase>(
            initialValue: _fromBase,
            decoration: const InputDecoration(labelText: 'Input base'),
            items: [
              for (final base in NumberBase.values)
                DropdownMenuItem(
                    value: base, child: Text(base.label)),
            ],
            onChanged: (v) {
              if (v != null) setState(() => _fromBase = v);
            },
          ),
          const SizedBox(height: 20),
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
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _swap,
                  icon: const Icon(Icons.arrow_upward),
                  label: const Text('Swap'),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: _clear,
                child: const Icon(Icons.clear_all),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(_error!,
                    style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onErrorContainer)),
              ),
            ),
          ],
          if (_results != null) ...[
            const SizedBox(height: 20),
            Text('Results',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            for (final base in NumberBase.values)
              ResultCard(
                label: base.label,
                value: _results![base]!,
                icon: Icons.tag,
              ),
          ],
          if (_history.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('History',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            for (final entry in _history.take(10))
              Card(
                child: ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(entry,
                      style: Theme.of(context).textTheme.bodySmall),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
