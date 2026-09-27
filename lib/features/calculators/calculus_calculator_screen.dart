import 'package:flutter/material.dart';
import '../../core/widgets/ui.dart';
import '../../domain/services/calculus_calculator_service.dart';

class CalculusCalculatorScreen extends StatelessWidget {
  const CalculusCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calculus Calculators')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Educational calculators for calculus. Supports polynomial expressions like 3x^2 + 2x - 5.',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _CalcItem('Derivative', Icons.trending_up_outlined, 'd/dx of a polynomial', () => _push(context, const _DerivativeCalc())),
          _CalcItem('Basic Integral', Icons.functions_outlined, 'Indefinite integral', () => _push(context, const _IntegralCalc())),
          _CalcItem('Definite Integral', Icons.space_bar_outlined, 'Numerical integration', () => _push(context, const _DefiniteIntegralCalc())),
          _CalcItem('Limit', Icons.linear_scale_outlined, 'Numerical limit', () => _push(context, const _LimitCalc())),
          _CalcItem('Slope', Icons.show_chart_outlined, 'Slope between two points', () => _push(context, const _SlopeCalc())),
          _CalcItem('Average Rate of Change', Icons.trending_flat_outlined, 'Over an interval', () => _push(context, const _AverageRateCalc())),
          _CalcItem('Numerical Approximation', Icons.bar_chart_outlined, 'Riemann sum', () => _push(context, const _RiemannSumCalc())),
        ],
      ),
    );
  }

  static void _push(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}

class _CalcItem extends StatelessWidget {
  const _CalcItem(this.title, this.icon, this.subtitle, this.onTap);
  final String title, subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(icon, color: Theme.of(context).colorScheme.onPrimaryContainer),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      ),
    );
  }
}

Widget _resultSection(BuildContext context, List<Widget> cards) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      Text('Result', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 10),
      ...cards,
    ],
  );
}

class _ExpressionField extends StatelessWidget {
  const _ExpressionField({required this.controller, this.hint});
  final TextEditingController controller;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Expression',
        hintText: hint ?? 'e.g. 3x^2 + 2x - 5',
        helperText: 'Use x as variable, ^ for powers, * optional',
        helperMaxLines: 2,
      ),
    );
  }
}

class _DerivativeCalc extends StatefulWidget {
  const _DerivativeCalc();
  @override
  State<_DerivativeCalc> createState() => _DerivativeCalcState();
}

class _DerivativeCalcState extends State<_DerivativeCalc> {
  final _expr = TextEditingController();
  Polynomial? _result;
  String? _error;
  final _service = const CalculusCalculatorService();

  @override
  void dispose() {
    _expr.dispose();
    super.dispose();
  }

  void _calculate() {
    try {
      setState(() {
        _result = _service.derivative(_expr.text);
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = 'Invalid expression. Use format like 3x^2 + 2x - 5';
        _result = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Derivative')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const FormulaBlock('d/dx'),
          const SizedBox(height: 16),
          _ExpressionField(controller: _expr),
          const SizedBox(height: 20),
          FilledButton(onPressed: _calculate, child: const Text('Differentiate')),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
              ),
            ),
          ],
          if (_result != null)
            _resultSection(context, [
              ResultCard(label: 'Derivative', value: _result!.toString(), icon: Icons.trending_up_outlined),
            ]),
        ],
      ),
    );
  }
}

class _IntegralCalc extends StatefulWidget {
  const _IntegralCalc();
  @override
  State<_IntegralCalc> createState() => _IntegralCalcState();
}

class _IntegralCalcState extends State<_IntegralCalc> {
  final _expr = TextEditingController();
  Polynomial? _result;
  String? _error;
  final _service = const CalculusCalculatorService();

  @override
  void dispose() {
    _expr.dispose();
    super.dispose();
  }

  void _calculate() {
    try {
      setState(() {
        _result = _service.indefiniteIntegral(_expr.text);
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = 'Invalid expression. Use format like 3x^2 + 2x - 5';
        _result = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Basic Integral')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const FormulaBlock('∫ f(x) dx'),
          const SizedBox(height: 16),
          _ExpressionField(controller: _expr),
          const SizedBox(height: 20),
          FilledButton(onPressed: _calculate, child: const Text('Integrate')),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
              ),
            ),
          ],
          if (_result != null)
            _resultSection(context, [
              ResultCard(label: 'Integral', value: '${_result!} + C', icon: Icons.functions_outlined),
            ]),
        ],
      ),
    );
  }
}

class _DefiniteIntegralCalc extends StatefulWidget {
  const _DefiniteIntegralCalc();
  @override
  State<_DefiniteIntegralCalc> createState() => _DefiniteIntegralCalcState();
}

class _DefiniteIntegralCalcState extends State<_DefiniteIntegralCalc> {
  final _expr = TextEditingController();
  final _a = TextEditingController();
  final _b = TextEditingController();
  double? _result;
  String? _error;
  final _service = const CalculusCalculatorService();

  @override
  void dispose() {
    _expr.dispose();
    _a.dispose();
    _b.dispose();
    super.dispose();
  }

  void _calculate() {
    final a = double.tryParse(_a.text);
    final b = double.tryParse(_b.text);
    if (a == null || b == null) {
      setState(() {
        _error = 'Enter valid limits';
        _result = null;
      });
      return;
    }
    try {
      setState(() {
        _result = _service.definiteIntegral(_expr.text, a, b);
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = 'Invalid expression or limits';
        _result = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Definite Integral')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const FormulaBlock('∫[a,b] f(x) dx'),
          const SizedBox(height: 16),
          _ExpressionField(controller: _expr),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: TextField(controller: _a, keyboardType: const TextInputType.numberWithOptions(decimal: true, decoration: const InputDecoration(labelText: 'Lower limit (a)'))),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: _b, keyboardType: const TextInputType.numberWithOptions(decimal: true, decoration: const InputDecoration(labelText: 'Upper limit (b)'))),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton(onPressed: _calculate, child: const Text('Integrate')),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
              ),
            ),
          ],
          if (_result != null)
            _resultSection(context, [
              ResultCard(label: 'Definite integral', value: _result!.toStringAsFixed(6), icon: Icons.space_bar_outlined),
            ]),
        ],
      ),
    );
  }
}

class _LimitCalc extends StatefulWidget {
  const _LimitCalc();
  @override
  State<_LimitCalc> createState() => _LimitCalcState();
}

class _LimitCalcState extends State<_LimitCalc> {
  final _expr = TextEditingController();
  final _point = TextEditingController();
  double? _result;
  String? _error;
  final _service = const CalculusCalculatorService();

  @override
  void dispose() {
    _expr.dispose();
    _point.dispose();
    super.dispose();
  }

  void _calculate() {
    final point = double.tryParse(_point.text);
    if (point == null) {
      setState(() {
        _error = 'Enter a valid point';
        _result = null;
      });
      return;
    }
    try {
      final result = _service.limit(_expr.text, point);
      setState(() {
        _result = result;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = 'Invalid expression';
        _result = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Limit')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const FormulaBlock('lim x→a f(x)'),
          const SizedBox(height: 16),
          _ExpressionField(controller: _expr),
          const SizedBox(height: 12),
          TextField(controller: _point, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Approach point (a)')),
          const SizedBox(height: 20),
          FilledButton(onPressed: _calculate, child: const Text('Evaluate')),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
              ),
            ),
          ],
          if (_result != null)
            _resultSection(context, [
              ResultCard(label: 'Limit', value: _result!.toStringAsFixed(6), icon: Icons.linear_scale_outlined),
            ]),
        ],
      ),
    );
  }
}

class _SlopeCalc extends StatefulWidget {
  const _SlopeCalc();
  @override
  State<_SlopeCalc> createState() => _SlopeCalcState();
}

class _SlopeCalcState extends State<_SlopeCalc> {
  final _x1 = TextEditingController();
  final _y1 = TextEditingController();
  final _x2 = TextEditingController();
  final _y2 = TextEditingController();
  double? _result;
  String? _error;
  final _service = const CalculusCalculatorService();

  @override
  void dispose() {
    for (final c in [_x1, _y1, _x2, _y2]) {
      c.dispose();
    }
    super.dispose();
  }

  void _calculate() {
    final x1 = double.tryParse(_x1.text);
    final y1 = double.tryParse(_y1.text);
    final x2 = double.tryParse(_x2.text);
    final y2 = double.tryParse(_y2.text);
    if (x1 == null || y1 == null || x2 == null || y2 == null) {
      setState(() {
        _error = 'Enter all four values';
        _result = null;
      });
      return;
    }
    try {
      setState(() {
        _result = _service.slope(x1, y1, x2, y2);
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
      appBar: AppBar(title: const Text('Slope')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const FormulaBlock('m = (y₂ − y₁) / (x₂ − x₁)'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: TextField(controller: _x1, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'x₁'))),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: _y1, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'y₁'))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: TextField(controller: _x2, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'x₂'))),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: _y2, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'y₂'))),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton(onPressed: _calculate, child: const Text('Calculate')),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
              ),
            ),
          ],
          if (_result != null)
            _resultSection(context, [
              ResultCard(label: 'Slope', value: _result!.toStringAsFixed(4), icon: Icons.show_chart_outlined),
            ]),
        ],
      ),
    );
  }
}

class _AverageRateCalc extends StatefulWidget {
  const _AverageRateCalc();
  @override
  State<_AverageRateCalc> createState() => _AverageRateCalcState();
}

class _AverageRateCalcState extends State<_AverageRateCalc> {
  final _expr = TextEditingController();
  final _a = TextEditingController();
  final _b = TextEditingController();
  double? _result;
  String? _error;
  final _service = const CalculusCalculatorService();

  @override
  void dispose() {
    _expr.dispose();
    _a.dispose();
    _b.dispose();
    super.dispose();
  }

  void _calculate() {
    final a = double.tryParse(_a.text);
    final b = double.tryParse(_b.text);
    if (a == null || b == null) {
      setState(() {
        _error = 'Enter valid limits';
        _result = null;
      });
      return;
    }
    try {
      setState(() {
        _result = _service.averageRateOfChange(_expr.text, a, b);
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = 'Invalid expression or limits';
        _result = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Average Rate of Change')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const FormulaBlock('(f(b) − f(a)) / (b − a)'),
          const SizedBox(height: 16),
          _ExpressionField(controller: _expr),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: TextField(controller: _a, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'a'))),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: _b, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'b'))),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton(onPressed: _calculate, child: const Text('Calculate')),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
              ),
            ),
          ],
          if (_result != null)
            _resultSection(context, [
              ResultCard(label: 'Average rate of change', value: _result!.toStringAsFixed(6), icon: Icons.trending_flat_outlined),
            ]),
        ],
      ),
    );
  }
}

class _RiemannSumCalc extends StatefulWidget {
  const _RiemannSumCalc();
  @override
  State<_RiemannSumCalc> createState() => _RiemannSumCalcState();
}

class _RiemannSumCalcState extends State<_RiemannSumCalc> {
  final _expr = TextEditingController();
  final _a = TextEditingController();
  final _b = TextEditingController();
  final _n = TextEditingController(text: '100');
  String _method = 'right';
  double? _result;
  String? _error;
  final _service = const CalculusCalculatorService();

  @override
  void dispose() {
    _expr.dispose();
    _a.dispose();
    _b.dispose();
    _n.dispose();
    super.dispose();
  }

  void _calculate() {
    final a = double.tryParse(_a.text);
    final b = double.tryParse(_b.text);
    final n = int.tryParse(_n.text) ?? 100;
    if (a == null || b == null) {
      setState(() {
        _error = 'Enter valid limits';
        _result = null;
      });
      return;
    }
    try {
      setState(() {
        _result = _service.riemannSum(_expr.text, a, b, n, method: _method);
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = 'Invalid input';
        _result = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Numerical Approximation')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const FormulaBlock('Σ f(xᵢ) Δx'),
          const SizedBox(height: 16),
          _ExpressionField(controller: _expr),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: TextField(controller: _a, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'a'))),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: _b, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'b'))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: TextField(controller: _n, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Rectangles'))),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _method,
                  decoration: const InputDecoration(labelText: 'Method'),
                  items: const [
                    DropdownMenuItem(value: 'left', child: Text('Left')),
                    DropdownMenuItem(value: 'right', child: Text('Right')),
                    DropdownMenuItem(value: 'midpoint', child: Text('Midpoint')),
                  ],
                  onChanged: (v) => setState(() => _method = v ?? 'right'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton(onPressed: _calculate, child: const Text('Approximate')),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
              ),
            ),
          ],
          if (_result != null)
            _resultSection(context, [
              ResultCard(label: 'Approximation', value: _result!.toStringAsFixed(6), icon: Icons.bar_chart_outlined),
            ]),
        ],
      ),
    );
  }
}
