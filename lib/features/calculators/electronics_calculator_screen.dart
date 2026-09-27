import 'package:flutter/material.dart';
import '../../core/widgets/ui.dart';
import '../../domain/services/electronics_calculator_service.dart';

class ElectronicsCalculatorScreen extends StatelessWidget {
  const ElectronicsCalculatorScreen({super.key, this.initial});
  final String? initial;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Electronics Calculators')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Educational calculators for DC circuit analysis. Enter known values and solve for the unknown.',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _CalcItem(
            'Ohm\'s Law',
            Icons.bolt_outlined,
            'V = IR — solve for any variable',
            () => _push(context, const _OhmsLawCalculator()),
          ),
          _CalcItem(
            'Power',
            Icons.power_outlined,
            'P = VI = I²R = V²/R',
            () => _push(context, const _PowerCalculator()),
          ),
          _CalcItem(
            'Voltage Divider',
            Icons.linear_scale_outlined,
            'Vout = Vin × R2/(R1+R2)',
            () => _push(context, const _VoltageDividerCalculator()),
          ),
          _CalcItem(
            'Current Divider',
            Icons.call_split_outlined,
            'Current splits among parallel branches',
            () => _push(context, const _CurrentDividerCalculator()),
          ),
          _CalcItem(
            'LED Resistor',
            Icons.lightbulb_outline,
            'R = (Vsupply − Vf) / If',
            () => _push(context, const _LedResistorCalculator()),
          ),
          _CalcItem(
            'Series Resistance',
            Icons.add_circle_outline,
            'Rtotal = R1 + R2 + ...',
            () => _push(context, const _SeriesResistanceCalculator()),
          ),
          _CalcItem(
            'Parallel Resistance',
            Icons.account_tree_outlined,
            '1/Rtotal = 1/R1 + 1/R2 + ...',
            () => _push(context, const _ParallelResistanceCalculator()),
          ),
          _CalcItem(
            'RC Time Constant',
            Icons.timer_outlined,
            'τ = RC — charging and filtering',
            () => _push(context, const _RcCalculator()),
          ),
          _CalcItem(
            'Resistance Converter',
            Icons.straighten_outlined,
            'Color code to resistance value',
            () => _push(context, const _ResistanceConverterCalculator()),
          ),
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
            child: Icon(icon,
                color: Theme.of(context).colorScheme.onPrimaryContainer),
          ),
          title: Text(title,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      ),
    );
  }
}

Widget _buildResultSection(BuildContext context, List<Widget> cards) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      Text('Results',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 10),
      ...cards,
    ],
  );
}

class _OhmsLawCalculator extends StatefulWidget {
  const _OhmsLawCalculator();
  @override
  State<_OhmsLawCalculator> createState() => _OhmsLawCalculatorState();
}

class _OhmsLawCalculatorState extends State<_OhmsLawCalculator> {
  final _v = TextEditingController();
  final _i = TextEditingController();
  final _r = TextEditingController();
  OhmsLawResult? _result;
  String? _error;
  final _service = const ElectronicsCalculatorService();

  @override
  void dispose() {
    _v.dispose();
    _i.dispose();
    _r.dispose();
    super.dispose();
  }

  void _calculate() {
    final v = double.tryParse(_v.text);
    final i = double.tryParse(_i.text);
    final r = double.tryParse(_r.text);
    final filled = [v != null, i != null, r != null].where((x) => x).length;
    if (filled != 2) {
      setState(() {
        _error = 'Enter exactly two values';
        _result = null;
      });
      return;
    }
    final result = _service.ohmsLaw(v: v, i: i, r: r);
    if (result.voltage == null) {
      setState(() {
        _error = 'Cannot solve: current cannot be zero';
        _result = null;
      });
      return;
    }
    setState(() {
      _result = result;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ohm\'s Law')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const FormulaBlock('V = I × R'),
          const SizedBox(height: 16),
          TextField(controller: _v, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Voltage (V)')),
          const SizedBox(height: 12),
          TextField(controller: _i, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Current (A)')),
          const SizedBox(height: 12),
          TextField(controller: _r, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Resistance (Ω)')),
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
            _buildResultSection(context, [
              ResultCard(label: 'Voltage', value: '${_result!.voltage?.toStringAsFixed(3) ?? '—'} V', icon: Icons.bolt_outlined),
              ResultCard(label: 'Current', value: '${_result!.current?.toStringAsFixed(3) ?? '—'} A', icon: Icons.electric_bolt),
              ResultCard(label: 'Resistance', value: '${_result!.resistance?.toStringAsFixed(3) ?? '—'} Ω', icon: Icons.electrical_services),
              ResultCard(label: 'Power', value: '${_result!.power?.toStringAsFixed(3) ?? '—'} W', icon: Icons.power_outlined),
            ]),
        ],
      ),
    );
  }
}

class _PowerCalculator extends StatefulWidget {
  const _PowerCalculator();
  @override
  State<_PowerCalculator> createState() => _PowerCalculatorState();
}

class _PowerCalculatorState extends State<_PowerCalculator> {
  final _v = TextEditingController();
  final _i = TextEditingController();
  final _r = TextEditingController();
  double? _result;
  String? _error;
  final _service = const ElectronicsCalculatorService();

  @override
  void dispose() {
    _v.dispose();
    _i.dispose();
    _r.dispose();
    super.dispose();
  }

  void _calculate() {
    final v = double.tryParse(_v.text);
    final i = double.tryParse(_i.text);
    final r = double.tryParse(_r.text);
    try {
      setState(() {
        _result = _service.power(v: v, i: i, r: r);
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = 'Enter exactly two of: voltage, current, resistance';
        _result = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Power')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const FormulaBlock('P = V × I = I² × R = V² / R'),
          const SizedBox(height: 16),
          TextField(controller: _v, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Voltage (V)')),
          const SizedBox(height: 12),
          TextField(controller: _i, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Current (A)')),
          const SizedBox(height: 12),
          TextField(controller: _r, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Resistance (Ω)')),
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
            _buildResultSection(context, [
              ResultCard(label: 'Power', value: '${_result!.toStringAsFixed(3)} W', icon: Icons.power_outlined),
            ]),
        ],
      ),
    );
  }
}

class _VoltageDividerCalculator extends StatefulWidget {
  const _VoltageDividerCalculator();
  @override
  State<_VoltageDividerCalculator> createState() => _VoltageDividerCalculatorState();
}

class _VoltageDividerCalculatorState extends State<_VoltageDividerCalculator> {
  final _vin = TextEditingController();
  final _r1 = TextEditingController();
  final _r2 = TextEditingController();
  double? _result;
  String? _error;
  final _service = const ElectronicsCalculatorService();

  @override
  void dispose() {
    _vin.dispose();
    _r1.dispose();
    _r2.dispose();
    super.dispose();
  }

  void _calculate() {
    final vin = double.tryParse(_vin.text);
    final r1 = double.tryParse(_r1.text);
    final r2 = double.tryParse(_r2.text);
    if (vin == null || r1 == null || r2 == null) {
      setState(() {
        _error = 'Enter all three values';
        _result = null;
      });
      return;
    }
    try {
      setState(() {
        _result = _service.voltageDivider(vin, r1, r2);
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
      appBar: AppBar(title: const Text('Voltage Divider')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const FormulaBlock('Vout = Vin × R2 / (R1 + R2)'),
          const SizedBox(height: 16),
          TextField(controller: _vin, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Input voltage (Vin)')),
          const SizedBox(height: 12),
          TextField(controller: _r1, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'R1 (Ω)')),
          const SizedBox(height: 12),
          TextField(controller: _r2, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'R2 (Ω)')),
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
            _buildResultSection(context, [
              ResultCard(label: 'Output voltage', value: '${_result!.toStringAsFixed(3)} V', icon: Icons.bolt_outlined),
            ]),
        ],
      ),
    );
  }
}

class _CurrentDividerCalculator extends StatefulWidget {
  const _CurrentDividerCalculator();
  @override
  State<_CurrentDividerCalculator> createState() => _CurrentDividerCalculatorState();
}

class _CurrentDividerCalculatorState extends State<_CurrentDividerCalculator> {
  final _itotal = TextEditingController();
  final _r1 = TextEditingController();
  final _r2 = TextEditingController();
  List<double>? _results;
  String? _error;
  final _service = const ElectronicsCalculatorService();

  @override
  void dispose() {
    _itotal.dispose();
    _r1.dispose();
    _r2.dispose();
    super.dispose();
  }

  void _calculate() {
    final itotal = double.tryParse(_itotal.text);
    final r1 = double.tryParse(_r1.text);
    final r2 = double.tryParse(_r2.text);
    if (itotal == null || r1 == null || r2 == null) {
      setState(() {
        _error = 'Enter all three values';
        _results = null;
      });
      return;
    }
    try {
      setState(() {
        _results = [
          _service.currentDivider(itotal, r1, r2),
          _service.currentDivider(itotal, r2, r1),
        ];
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _results = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Current Divider')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const FormulaBlock('I₁ = Itotal × R₂ / (R₁ + R₂)'),
          const SizedBox(height: 16),
          TextField(controller: _itotal, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Total current (A)')),
          const SizedBox(height: 12),
          TextField(controller: _r1, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'R1 (Ω)')),
          const SizedBox(height: 12),
          TextField(controller: _r2, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'R2 (Ω)')),
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
          if (_results != null)
            _buildResultSection(context, [
              ResultCard(label: 'Current through R1', value: '${_results![0].toStringAsFixed(4)} A', icon: Icons.electric_bolt),
              ResultCard(label: 'Current through R2', value: '${_results![1].toStringAsFixed(4)} A', icon: Icons.electric_bolt),
            ]),
        ],
      ),
    );
  }
}

class _LedResistorCalculator extends StatefulWidget {
  const _LedResistorCalculator();
  @override
  State<_LedResistorCalculator> createState() => _LedResistorCalculatorState();
}

class _LedResistorCalculatorState extends State<_LedResistorCalculator> {
  final _vsupply = TextEditingController();
  final _vf = TextEditingController();
  final _if = TextEditingController();
  double? _result;
  String? _error;
  final _service = const ElectronicsCalculatorService();

  @override
  void dispose() {
    _vsupply.dispose();
    _vf.dispose();
    _if.dispose();
    super.dispose();
  }

  void _calculate() {
    final vsupply = double.tryParse(_vsupply.text);
    final vf = double.tryParse(_vf.text);
    final ifMa = double.tryParse(_if.text);
    if (vsupply == null || vf == null || ifMa == null) {
      setState(() {
        _error = 'Enter all three values';
        _result = null;
      });
      return;
    }
    try {
      setState(() {
        _result = _service.ledResistor(vsupply, vf, ifMa);
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
      appBar: AppBar(title: const Text('LED Resistor')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const FormulaBlock('R = (Vsupply − Vf) / If'),
          const SizedBox(height: 16),
          TextField(controller: _vsupply, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Supply voltage (V)')),
          const SizedBox(height: 12),
          TextField(controller: _vf, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'LED forward voltage (V)')),
          const SizedBox(height: 12),
          TextField(controller: _if, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Forward current (mA)')),
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
            _buildResultSection(context, [
              ResultCard(label: 'Resistor value', value: '${_result!.round()} Ω (use nearest standard)', icon: Icons.electrical_services),
            ]),
        ],
      ),
    );
  }
}

class _SeriesResistanceCalculator extends StatefulWidget {
  const _SeriesResistanceCalculator();
  @override
  State<_SeriesResistanceCalculator> createState() => _SeriesResistanceCalculatorState();
}

class _SeriesResistanceCalculatorState extends State<_SeriesResistanceCalculator> {
  final _r = [TextEditingController(), TextEditingController(), TextEditingController()];
  double? _result;
  final _service = const ElectronicsCalculatorService();

  @override
  void dispose() {
    for (final c in _r) {
      c.dispose();
    }
    super.dispose();
  }

  void _calculate() {
    final values = <double>[];
    for (final c in _r) {
      final v = double.tryParse(c.text);
      if (v != null) values.add(v);
    }
    if (values.isEmpty) return;
    setState(() => _result = _service.seriesResistance(values));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Series Resistance')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const FormulaBlock('Rtotal = R₁ + R₂ + R₃ + ...'),
          const SizedBox(height: 16),
          for (var i = 0; i < 3; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(controller: _r[i], keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: 'R${i + 1} (Ω)')),
            ),
          FilledButton(onPressed: _calculate, child: const Text('Calculate')),
          if (_result != null)
            _buildResultSection(context, [
              ResultCard(label: 'Total resistance', value: '${_result!.toStringAsFixed(3)} Ω', icon: Icons.add_circle_outline),
            ]),
        ],
      ),
    );
  }
}

class _ParallelResistanceCalculator extends StatefulWidget {
  const _ParallelResistanceCalculator();
  @override
  State<_ParallelResistanceCalculator> createState() => _ParallelResistanceCalculatorState();
}

class _ParallelResistanceCalculatorState extends State<_ParallelResistanceCalculator> {
  final _r = [TextEditingController(), TextEditingController(), TextEditingController()];
  double? _result;
  String? _error;
  final _service = const ElectronicsCalculatorService();

  @override
  void dispose() {
    for (final c in _r) {
      c.dispose();
    }
    super.dispose();
  }

  void _calculate() {
    final values = <double>[];
    for (final c in _r) {
      final v = double.tryParse(c.text);
      if (v != null) values.add(v);
    }
    if (values.isEmpty) return;
    try {
      setState(() {
        _result = _service.parallelResistance(values);
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
      appBar: AppBar(title: const Text('Parallel Resistance')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const FormulaBlock('1/Rtotal = 1/R₁ + 1/R₂ + 1/R₃ + ...'),
          const SizedBox(height: 16),
          for (var i = 0; i < 3; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(controller: _r[i], keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: 'R${i + 1} (Ω)')),
            ),
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
            _buildResultSection(context, [
              ResultCard(label: 'Total resistance', value: '${_result!.toStringAsFixed(3)} Ω', icon: Icons.account_tree_outlined),
            ]),
        ],
      ),
    );
  }
}

class _RcCalculator extends StatefulWidget {
  const _RcCalculator();
  @override
  State<_RcCalculator> createState() => _RcCalculatorState();
}

class _RcCalculatorState extends State<_RcCalculator> {
  final _r = TextEditingController();
  final _c = TextEditingController();
  double? _tau;
  double? _fc;
  String? _error;
  final _service = const ElectronicsCalculatorService();

  @override
  void dispose() {
    _r.dispose();
    _c.dispose();
    super.dispose();
  }

  void _calculate() {
    final r = double.tryParse(_r.text);
    final c = double.tryParse(_c.text);
    if (r == null || c == null) {
      setState(() {
        _error = 'Enter resistance and capacitance';
        _tau = null;
        _fc = null;
      });
      return;
    }
    setState(() {
      _tau = _service.rcTimeConstant(r, c);
      _fc = _service.rcCutoffFrequency(r, c);
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RC Time Constant')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const FormulaBlock('τ = R × C    fc = 1 / (2πRC)'),
          const SizedBox(height: 16),
          TextField(controller: _r, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Resistance (Ω)')),
          const SizedBox(height: 12),
          TextField(controller: _c, keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true), decoration: const InputDecoration(labelText: 'Capacitance (F)')),
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
          if (_tau != null)
            _buildResultSection(context, [
              ResultCard(label: 'Time constant (τ)', value: '${_tau!.toStringAsFixed(4)} s', icon: Icons.timer_outlined),
              ResultCard(label: 'Cutoff frequency (fc)', value: '${_fc!.toStringAsFixed(2)} Hz', icon: Icons.graphic_eq),
            ]),
        ],
      ),
    );
  }
}

class _ResistanceConverterCalculator extends StatefulWidget {
  const _ResistanceConverterCalculator();
  @override
  State<_ResistanceConverterCalculator> createState() => _ResistanceConverterCalculatorState();
}

class _ResistanceConverterCalculatorState extends State<_ResistanceConverterCalculator> {
  final _ohms = TextEditingController();
  String? _bands;
  String? _error;
  final _service = const ElectronicsCalculatorService();

  @override
  void dispose() {
    _ohms.dispose();
    super.dispose();
  }

  void _calculate() {
    final ohms = double.tryParse(_ohms.text);
    if (ohms == null || ohms <= 0) {
      setState(() {
        _error = 'Enter a valid positive resistance';
        _bands = null;
      });
      return;
    }
    setState(() {
      _bands = _service.resistanceToColorBands(ohms);
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resistance Converter')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(controller: _ohms, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Resistance (Ω)')),
          const SizedBox(height: 20),
          FilledButton(onPressed: _calculate, child: const Text('Convert')),
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
          if (_bands != null)
            _buildResultSection(context, [
              ResultCard(label: 'Color bands', value: _bands!, icon: Icons.palette_outlined),
            ]),
        ],
      ),
    );
  }
}
