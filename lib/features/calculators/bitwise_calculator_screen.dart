import 'package:flutter/material.dart';

import '../../core/design/app_spacing.dart';
import '../../domain/services/number_system_service.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/cards.dart';
import '../../widgets/inputs.dart';
import '../../widgets/performance_watcher.dart';

/// Bitwise operations on decimal integers, with binary and hex read-outs.
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

  static const _service = BitwiseCalculatorService();

  static const _operations = [
    DropdownMenuItem(value: BitwiseOperation.and, child: Text('AND (&)')),
    DropdownMenuItem(value: BitwiseOperation.or, child: Text('OR (|)')),
    DropdownMenuItem(value: BitwiseOperation.xor, child: Text('XOR (^)')),
    DropdownMenuItem(
        value: BitwiseOperation.nand, child: Text('NAND (⊼)')),
    DropdownMenuItem(value: BitwiseOperation.nor, child: Text('NOR (⊽)')),
    DropdownMenuItem(
        value: BitwiseOperation.shiftLeft, child: Text('Shift left (<<)')),
    DropdownMenuItem(
        value: BitwiseOperation.shiftRight, child: Text('Shift right (>>)')),
    DropdownMenuItem(value: BitwiseOperation.not, child: Text('NOT (~)')),
  ];

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
      // Computed outside setState: the work happens once, and only the
      // assignments are inside the rebuild.
      final computed = _service.compute(_op, a, b ?? 0);
      setState(() {
        _result = computed;
        _error = null;
      });
    } on Object catch (error) {
      setState(() {
        _error = 'Could not compute that: $error';
        _result = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;

    return ScreenPerformanceWatcher(
      name: 'Bitwise calculator',
      child: AppScaffold(
        title: 'Bitwise calculator',
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.gutter),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _aController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Value A (decimal)',
                      hintText: 'e.g. 170',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (_needsB)
                    TextField(
                      key: const ValueKey('field-b'),
                      controller: _bController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Value B (decimal)',
                        hintText: 'e.g. 204',
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                  DropdownButtonFormField<BitwiseOperation>(
                    initialValue: _op,
                    decoration: const InputDecoration(labelText: 'Operation'),
                    items: _operations,
                    onChanged: (value) {
                      if (value != null) setState(() => _op = value);
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton.icon(
                    onPressed: _calculate,
                    icon: const Icon(Icons.calculate),
                    label: const Text('Calculate'),
                  ),
                  if (_error != null) ErrorBanner(message: _error!),
                ],
              ),
            ),
          ),
          if (result != null) ...[
            const SliverSectionHeader(title: 'Result'),
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
                child: Column(
                  children: [
                    ResultCard(
                      label: 'Binary',
                      value: result.result,
                      icon: Icons.code,
                      onCopy: () => copyToClipboard(context, result.result),
                    ),
                    ResultCard(
                      label: 'Decimal',
                      value: '${result.decimalResult}',
                      icon: Icons.tag,
                    ),
                    ResultCard(
                      label: 'Hexadecimal',
                      value: result.hexResult,
                      icon: Icons.hexagon_outlined,
                    ),
                  ],
                ),
              ),
            ),
            const SliverSectionHeader(title: 'Inputs'),
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
                child: Column(
                  children: [
                    ResultCard(
                      label: 'A (binary)',
                      value: result.inputA,
                      icon: Icons.looks_one_outlined,
                    ),
                    ResultCard(
                      label: 'A (decimal)',
                      value: '${result.decimalA}',
                      icon: Icons.looks_one_outlined,
                    ),
                    ResultCard(
                      label: 'B (binary)',
                      value: result.inputB,
                      icon: Icons.looks_two_outlined,
                    ),
                    ResultCard(
                      label: 'B (decimal)',
                      value: '${result.decimalB}',
                      icon: Icons.looks_two_outlined,
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
