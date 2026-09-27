import 'package:flutter/material.dart';
import '../../core/widgets/ui.dart';
import '../../domain/services/number_system_service.dart';

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

class BinaryCalculatorScreen extends StatefulWidget {
  const BinaryCalculatorScreen({super.key});

  @override
  State<BinaryCalculatorScreen> createState() =>
      _BinaryCalculatorScreenState();
}

class _BinaryCalculatorScreenState extends State<BinaryCalculatorScreen> {
  final _aController = TextEditingController();
  final _bController = TextEditingController();
  final _shiftController = TextEditingController(text: '1');
  BinaryOp _op = BinaryOp.add;
  String? _result;
  String? _error;

  final _service = const BinaryCalculatorService();

  @override
  void dispose() {
    _aController.dispose();
    _bController.dispose();
    _shiftController.dispose();
    super.dispose();
  }

  bool get _needsB =>
      _op != BinaryOp.not && _op != BinaryOp.shiftLeft && _op != BinaryOp.shiftRight;

  void _calculate() {
    final a = _aController.text.trim();
    if (a.isEmpty || !_service.isValidBinary(a)) {
      setState(() {
        _error = 'Enter a valid binary number for A';
        _result = null;
      });
      return;
    }
    String? result;
    try {
      if (_op == BinaryOp.not) {
        result = _service.not(a);
      } else if (_op == BinaryOp.shiftLeft || _op == BinaryOp.shiftRight) {
        final n = int.tryParse(_shiftController.text) ?? 0;
        result = _op == BinaryOp.shiftLeft
            ? _service.shiftLeft(a, n)
            : _service.shiftRight(a, n);
      } else {
        final b = _bController.text.trim();
        if (b.isEmpty || !_service.isValidBinary(b)) {
          setState(() {
            _error = 'Enter a valid binary number for B';
            _result = null;
          });
          return;
        }
        result = switch (_op) {
          BinaryOp.add => _service.add(a, b),
          BinaryOp.subtract => _service.subtract(a, b),
          BinaryOp.multiply => _service.multiply(a, b),
          BinaryOp.divide => _service.divide(a, b),
          BinaryOp.and => _service.and(a, b),
          BinaryOp.or => _service.or(a, b),
          BinaryOp.xor => _service.xor(a, b),
          _ => null,
        };
        if (result == null) {
          setState(() {
            _error = 'Cannot divide by zero';
            _result = null;
          });
          return;
        }
      }
      setState(() {
        _result = result;
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
      appBar: AppBar(title: const Text('Binary Calculator')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _aController,
            decoration: const InputDecoration(
              labelText: 'Value A (binary)',
              hintText: 'e.g. 101101',
            ),
          ),
          const SizedBox(height: 12),
          if (_needsB)
            TextField(
              controller: _bController,
              decoration: const InputDecoration(
                labelText: 'Value B (binary)',
                hintText: 'e.g. 001011',
              ),
            ),
          if (_op == BinaryOp.shiftLeft || _op == BinaryOp.shiftRight)
            TextField(
              controller: _shiftController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Positions'),
            ),
          const SizedBox(height: 16),
          DropdownButtonFormField<BinaryOp>(
            initialValue: _op,
            decoration: const InputDecoration(labelText: 'Operation'),
            items: [
              for (final op in BinaryOp.values)
                DropdownMenuItem(value: op, child: Text('${op.label} (${op.symbol})')),
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
            ResultCard(label: 'Binary', value: _result!, icon: Icons.code),
            ResultCard(
              label: 'Decimal',
              value: _service.toDecimal(_result!).toString(),
              icon: Icons.tag,
            ),
            ResultCard(
              label: 'Hexadecimal',
              value: _service.toDecimal(_result!).toRadixString(16).toUpperCase(),
              icon: Icons.hexagon_outlined,
            ),
          ],
        ],
      ),
    );
  }
}
