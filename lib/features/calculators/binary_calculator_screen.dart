import 'package:flutter/material.dart';

import '../../core/design/app_spacing.dart';
import '../../domain/services/number_system_service.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/cards.dart';
import '../../widgets/inputs.dart';
import '../../widgets/performance_watcher.dart';

enum BinaryOp {
  add('Addition', '+'),
  subtract('Subtraction', '−'),
  multiply('Multiplication', '×'),
  divide('Division', '÷'),
  and('AND', '&'),
  or('OR', '|'),
  xor('XOR', '^'),
  not('NOT', '~'),
  shiftLeft('Shift Left', '<<'),
  shiftRight('Shift Right', '>>');

  const BinaryOp(this.label, this.symbol);
  final String label, symbol;
}

/// Binary arithmetic and bitwise operations.
///
/// Two fixes over the previous version: the operation dropdown items are a
/// `static const` list instead of being rebuilt on every keystroke, and
/// `toDecimal` is computed once per build instead of twice.
class BinaryCalculatorScreen extends StatefulWidget {
  const BinaryCalculatorScreen({super.key});

  @override
  State<BinaryCalculatorScreen> createState() => _BinaryCalculatorScreenState();
}

class _BinaryCalculatorScreenState extends State<BinaryCalculatorScreen> {
  final _aController = TextEditingController();
  final _bController = TextEditingController();
  final _shiftController = TextEditingController(text: '1');
  BinaryOp _op = BinaryOp.add;
  String? _result;
  String? _error;

  static const _service = BinaryCalculatorService();

  /// Static: the option list never changes, so it is built once rather than
  /// ten times per rebuild.
  static const _operations = [
    DropdownMenuItem(value: BinaryOp.add, child: Text('Addition (+)')),
    DropdownMenuItem(value: BinaryOp.subtract, child: Text('Subtraction (−)')),
    DropdownMenuItem(value: BinaryOp.multiply, child: Text('Multiplication (×)')),
    DropdownMenuItem(value: BinaryOp.divide, child: Text('Division (÷)')),
    DropdownMenuItem(value: BinaryOp.and, child: Text('AND (&)')),
    DropdownMenuItem(value: BinaryOp.or, child: Text('OR (|)')),
    DropdownMenuItem(value: BinaryOp.xor, child: Text('XOR (^)')),
    DropdownMenuItem(value: BinaryOp.not, child: Text('NOT (~)')),
    DropdownMenuItem(value: BinaryOp.shiftLeft, child: Text('Shift Left (<<)')),
    DropdownMenuItem(value: BinaryOp.shiftRight, child: Text('Shift Right (>>)')),
  ];

  @override
  void dispose() {
    _aController.dispose();
    _bController.dispose();
    _shiftController.dispose();
    super.dispose();
  }

  bool get _needsB => switch (_op) {
        BinaryOp.not || BinaryOp.shiftLeft || BinaryOp.shiftRight => false,
        _ => true,
      };

  bool get _isShift =>
      _op == BinaryOp.shiftLeft || _op == BinaryOp.shiftRight;

  void _calculate() {
    final a = _aController.text.trim();
    if (a.isEmpty || !_service.isValidBinary(a)) {
      setState(() {
        _error = 'Enter a valid binary number for A';
        _result = null;
      });
      return;
    }
    try {
      final String result;
      if (_op == BinaryOp.not) {
        result = _service.not(a);
      } else if (_isShift) {
        final positions = int.tryParse(_shiftController.text.trim()) ?? 0;
        result = _op == BinaryOp.shiftLeft
            ? _service.shiftLeft(a, positions)
            : _service.shiftRight(a, positions);
      } else {
        final b = _bController.text.trim();
        if (b.isEmpty || !_service.isValidBinary(b)) {
          setState(() {
            _error = 'Enter a valid binary number for B';
            _result = null;
          });
          return;
        }
        final computed = switch (_op) {
          BinaryOp.add => _service.add(a, b),
          BinaryOp.subtract => _service.subtract(a, b),
          BinaryOp.multiply => _service.multiply(a, b),
          BinaryOp.divide => _service.divide(a, b),
          BinaryOp.and => _service.and(a, b),
          BinaryOp.or => _service.or(a, b),
          BinaryOp.xor => _service.xor(a, b),
          _ => null,
        };
        if (computed == null) {
          setState(() {
            _error = 'Cannot divide by zero';
            _result = null;
          });
          return;
        }
        result = computed;
      }
      setState(() {
        _result = result;
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
    // One conversion per build, shared by the decimal and hex rows.
    final decimal = result == null ? null : _service.toDecimal(result);

    return ScreenPerformanceWatcher(
      name: 'Binary calculator',
      child: AppScaffold(
        title: 'Binary calculator',
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.gutter),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _aController,
                    decoration: const InputDecoration(
                      labelText: 'Value A (binary)',
                      hintText: 'e.g. 101101',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Keyed so switching operations moves the field's
                  // selection state rather than leaving a stale caret.
                  if (_needsB)
                    TextField(
                      key: const ValueKey('field-b'),
                      controller: _bController,
                      decoration: const InputDecoration(
                        labelText: 'Value B (binary)',
                        hintText: 'e.g. 001011',
                      ),
                    ),
                  if (_isShift)
                    TextField(
                      key: const ValueKey('field-shift'),
                      controller: _shiftController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Positions'),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                  DropdownButtonFormField<BinaryOp>(
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
          if (result != null && decimal != null) ...[
            const SliverSectionHeader(title: 'Result'),
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
                child: Column(
                  children: [
                    ResultCard(
                      label: 'Binary',
                      value: result,
                      icon: Icons.code,
                      onCopy: () => copyToClipboard(context, result),
                    ),
                    ResultCard(
                      label: 'Decimal',
                      value: '$decimal',
                      icon: Icons.tag,
                      onCopy: () => copyToClipboard(context, '$decimal'),
                    ),
                    ResultCard(
                      label: 'Hexadecimal',
                      value: decimal.toRadixString(16).toUpperCase(),
                      icon: Icons.hexagon_outlined,
                      onCopy: () => copyToClipboard(
                          context, decimal.toRadixString(16).toUpperCase()),
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
