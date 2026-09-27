import 'package:flutter/material.dart';
import '../../core/widgets/ui.dart';
import '../../domain/services/number_system_service.dart';

class BitwiseCalculatorScreen extends StatefulWidget {
  const BitwiseCalculatorScreen({super.key});

  @override
  State<BitwiseCalculatorScreen> createState() =>
      _BitwiseCalculatorScreenState();
}

class _BitwiseCalculatorScreenState extends State<BitwiseCalculatorScreen> {
  final _aController = TextEditingController();
  final _bController = TextEditingController();
  BitwiseOperation _op = BitwiseOperation.and;
  BitwiseResult? _result;
  String? _error;

  final _service = const BitwiseCalculatorService();

  @override
  void dispose() {
    _aController.dispose();
    _bController.dispose();
    super.dispose();
  }

  bool get _needsB => _op != BitwiseOperation.not;

  void _calculate() {
    final a = int.tryParse(_aController.text.trim());
    if (a == null || a < 0) {
      setState(() {
        _error = 'Enter a valid non-negative integer for A';
        _result = null;
      });
      return;
    }
    int? b;
    if (_needsB) {
      b = int.tryParse(_bController.text.trim());
      if (b == null || b < 0) {
        setState(() {
          _error = 'Enter a valid non-negative integer for B';
          _result = null;
        });
        return;
      }
    }
    try {
      setState(() {
        _result = _service.compute(_op, a, b ?? 0);
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _result = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bitwise Calculator')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _aController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Value A (decimal)',
              hintText: 'e.g. 170',
            ),
          ),
          const SizedBox(height: 12),
          if (_needsB)
            TextField(
              controller: _bController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Value B (decimal)',
                hintText: 'e.g. 204',
              ),
            ),
          const SizedBox(height: 16),
          DropdownButtonFormField<BitwiseOperation>(
            initialValue: _op,
            decoration: const InputDecoration(labelText: 'Operation'),
            items: [
              for (final op in BitwiseOperation.values)
                DropdownMenuItem(
                    value: op, child: Text('${op.label} (${op.symbol})')),
            ],
            onChanged: (v) {
              if (v != null) setState(() => _op = v);
            },
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _calculate,
            icon: const Icon(Icons.calculate),
            label: const Text('Calculate'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(_error!,
                    style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onErrorContainer)),
              ),
            ),
          ],
          if (_result != null) ...[
            const SizedBox(height: 20),
            Text('Result',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            ResultCard(
                label: 'Binary', value: _result!.result, icon: Icons.code),
            ResultCard(
                label: 'Decimal', value: '${_result!.decimalResult}', icon: Icons.tag),
            ResultCard(
                label: 'Hexadecimal', value: _result!.hexResult, icon: Icons.hexagon_outlined),
            const SizedBox(height: 16),
            Text('Inputs',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ResultCard(
                label: 'A (binary)', value: _result!.inputA, icon: Icons.looks_one_outlined),
            ResultCard(
                label: 'A (decimal)', value: '${_result!.decimalA}', icon: Icons.looks_one_outlined),
            ResultCard(
                label: 'B (binary)', value: _result!.inputB, icon: Icons.looks_two_outlined),
            ResultCard(
                label: 'B (decimal)', value: '${_result!.decimalB}', icon: Icons.looks_two_outlined),
          ],
        ],
      ),
    );
  }
}
