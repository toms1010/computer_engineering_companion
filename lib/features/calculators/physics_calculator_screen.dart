import 'package:flutter/material.dart';
import '../../core/widgets/ui.dart';
import '../../domain/services/physics_calculator_service.dart';

class PhysicsCalculatorScreen extends StatelessWidget {
  const PhysicsCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Physics Calculators')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Educational calculators for mechanics, electricity, and waves. Enter known values and solve for the unknown.',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _CalcItem('Velocity', Icons.speed_outlined, 'v = d/t', () => _push(context, const _VelocityCalc())),
          _CalcItem('Acceleration', Icons.trending_up_outlined, 'a = Δv/Δt', () => _push(context, const _AccelerationCalc())),
          _CalcItem('Force', Icons.fitness_center_outlined, 'F = ma', () => _push(context, const _ForceCalc())),
          _CalcItem('Work', Icons.construction_outlined, 'W = Fd cos(θ)', () => _push(context, const _WorkCalc())),
          _CalcItem('Kinetic Energy', Icons.local_fire_department_outlined, 'KE = ½mv²', () => _push(context, const _KineticEnergyCalc())),
          _CalcItem('Potential Energy', Icons.arrow_upward_outlined, 'PE = mgh', () => _push(context, const _PotentialEnergyCalc())),
          _CalcItem('Power', Icons.power_outlined, 'P = W/t', () => _push(context, const _PowerCalc())),
          _CalcItem('Momentum', Icons.sports_baseball_outlined, 'p = mv', () => _push(context, const _MomentumCalc())),
          _CalcItem('Ohm\'s Law', Icons.bolt_outlined, 'V = IR', () => _push(context, const _OhmsLawCalc())),
          _CalcItem('Electrical Power', Icons.electric_bolt, 'P = VI', () => _push(context, const _ElectricalPowerCalc())),
          _CalcItem('Frequency', Icons.graphic_eq_outlined, 'f = 1/T', () => _push(context, const _FrequencyCalc())),
          _CalcItem('Wavelength', Icons.waves_outlined, 'λ = v/f', () => _push(context, const _WavelengthCalc())),
          _CalcItem('Wave Speed', Icons.water_outlined, 'v = fλ', () => _push(context, const _WaveSpeedCalc())),
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

class _VelocityCalc extends StatefulWidget {
  const _VelocityCalc();
  @override
  State<_VelocityCalc> createState() => _VelocityCalcState();
}

class _VelocityCalcState extends State<_VelocityCalc> {
  final _d = TextEditingController();
  final _t = TextEditingController();
  double? _result;
  String? _error;
  final _service = const PhysicsCalculatorService();

  @override
  void dispose() {
    _d.dispose();
    _t.dispose();
    super.dispose();
  }

  void _calculate() {
    final d = double.tryParse(_d.text);
    final t = double.tryParse(_t.text);
    if (d == null || t == null) {
      setState(() {
        _error = 'Enter distance and time';
        _result = null;
      });
      return;
    }
    try {
      setState(() {
        _result = _service.velocity(d, t);
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
      appBar: AppBar(title: const Text('Velocity')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const FormulaBlock('v = d / t'),
          const SizedBox(height: 16),
          TextField(controller: _d, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Distance (m)')),
          const SizedBox(height: 12),
          TextField(controller: _t, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Time (s)')),
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
              ResultCard(label: 'Velocity', value: '${_result!.toStringAsFixed(3)} m/s', icon: Icons.speed_outlined),
            ]),
        ],
      ),
    );
  }
}

class _AccelerationCalc extends StatefulWidget {
  const _AccelerationCalc();
  @override
  State<_AccelerationCalc> createState() => _AccelerationCalcState();
}

class _AccelerationCalcState extends State<_AccelerationCalc> {
  final _dv = TextEditingController();
  final _t = TextEditingController();
  double? _result;
  String? _error;
  final _service = const PhysicsCalculatorService();

  @override
  void dispose() {
    _dv.dispose();
    _t.dispose();
    super.dispose();
  }

  void _calculate() {
    final dv = double.tryParse(_dv.text);
    final t = double.tryParse(_t.text);
    if (dv == null || t == null) {
      setState(() {
        _error = 'Enter velocity change and time';
        _result = null;
      });
      return;
    }
    try {
      setState(() {
        _result = _service.acceleration(dv, t);
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
      appBar: AppBar(title: const Text('Acceleration')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const FormulaBlock('a = Δv / Δt'),
          const SizedBox(height: 16),
          TextField(controller: _dv, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Change in velocity (m/s)')),
          const SizedBox(height: 12),
          TextField(controller: _t, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Time (s)')),
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
              ResultCard(label: 'Acceleration', value: '${_result!.toStringAsFixed(3)} m/s²', icon: Icons.trending_up_outlined),
            ]),
        ],
      ),
    );
  }
}

class _ForceCalc extends StatefulWidget {
  const _ForceCalc();
  @override
  State<_ForceCalc> createState() => _ForceCalcState();
}

class _ForceCalcState extends State<_ForceCalc> {
  final _m = TextEditingController();
  final _a = TextEditingController();
  double? _result;
  String? _error;
  final _service = const PhysicsCalculatorService();

  @override
  void dispose() {
    _m.dispose();
    _a.dispose();
    super.dispose();
  }

  void _calculate() {
    final m = double.tryParse(_m.text);
    final a = double.tryParse(_a.text);
    if (m == null || a == null) {
      setState(() {
        _error = 'Enter mass and acceleration';
        _result = null;
      });
      return;
    }
    setState(() {
      _result = _service.force(m, a);
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Force')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const FormulaBlock('F = m × a'),
          const SizedBox(height: 16),
          TextField(controller: _m, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Mass (kg)')),
          const SizedBox(height: 12),
          TextField(controller: _a, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Acceleration (m/s²)')),
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
              ResultCard(label: 'Force', value: '${_result!.toStringAsFixed(3)} N', icon: Icons.fitness_center_outlined),
            ]),
        ],
      ),
    );
  }
}

class _WorkCalc extends StatefulWidget {
  const _WorkCalc();
  @override
  State<_WorkCalc> createState() => _WorkCalcState();
}

class _WorkCalcState extends State<_WorkCalc> {
  final _f = TextEditingController();
  final _d = TextEditingController();
  final _angle = TextEditingController(text: '0');
  double? _result;
  String? _error;
  final _service = const PhysicsCalculatorService();

  @override
  void dispose() {
    _f.dispose();
    _d.dispose();
    _angle.dispose();
    super.dispose();
  }

  void _calculate() {
    final f = double.tryParse(_f.text);
    final d = double.tryParse(_d.text);
    final angle = double.tryParse(_angle.text) ?? 0;
    if (f == null || d == null) {
      setState(() {
        _error = 'Enter force and distance';
        _result = null;
      });
      return;
    }
    setState(() {
      _result = _service.work(f, d, angleDegrees: angle);
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Work')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const FormulaBlock('W = F × d × cos(θ)'),
          const SizedBox(height: 16),
          TextField(controller: _f, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Force (N)')),
          const SizedBox(height: 12),
          TextField(controller: _d, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Distance (m)')),
          const SizedBox(height: 12),
          TextField(controller: _angle, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Angle (degrees)')),
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
              ResultCard(label: 'Work', value: '${_result!.toStringAsFixed(3)} J', icon: Icons.construction_outlined),
            ]),
        ],
      ),
    );
  }
}

class _KineticEnergyCalc extends StatefulWidget {
  const _KineticEnergyCalc();
  @override
  State<_KineticEnergyCalc> createState() => _KineticEnergyCalcState();
}

class _KineticEnergyCalcState extends State<_KineticEnergyCalc> {
  final _m = TextEditingController();
  final _v = TextEditingController();
  double? _result;
  String? _error;
  final _service = const PhysicsCalculatorService();

  @override
  void dispose() {
    _m.dispose();
    _v.dispose();
    super.dispose();
  }

  void _calculate() {
    final m = double.tryParse(_m.text);
    final v = double.tryParse(_v.text);
    if (m == null || v == null) {
      setState(() {
        _error = 'Enter mass and velocity';
        _result = null;
      });
      return;
    }
    setState(() {
      _result = _service.kineticEnergy(m, v);
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kinetic Energy')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const FormulaBlock('KE = ½ × m × v²'),
          const SizedBox(height: 16),
          TextField(controller: _m, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Mass (kg)')),
          const SizedBox(height: 12),
          TextField(controller: _v, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Velocity (m/s)')),
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
              ResultCard(label: 'Kinetic energy', value: '${_result!.toStringAsFixed(3)} J', icon: Icons.local_fire_department_outlined),
            ]),
        ],
      ),
    );
  }
}

class _PotentialEnergyCalc extends StatefulWidget {
  const _PotentialEnergyCalc();
  @override
  State<_PotentialEnergyCalc> createState() => _PotentialEnergyCalcState();
}

class _PotentialEnergyCalcState extends State<_PotentialEnergyCalc> {
  final _m = TextEditingController();
  final _h = TextEditingController();
  double? _result;
  String? _error;
  final _service = const PhysicsCalculatorService();

  @override
  void dispose() {
    _m.dispose();
    _h.dispose();
    super.dispose();
  }

  void _calculate() {
    final m = double.tryParse(_m.text);
    final h = double.tryParse(_h.text);
    if (m == null || h == null) {
      setState(() {
        _error = 'Enter mass and height';
        _result = null;
      });
      return;
    }
    setState(() {
      _result = _service.potentialEnergy(m, h);
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Potential Energy')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const FormulaBlock('PE = m × g × h'),
          const SizedBox(height: 16),
          TextField(controller: _m, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Mass (kg)')),
          const SizedBox(height: 12),
          TextField(controller: _h, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Height (m)')),
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
              ResultCard(label: 'Potential energy', value: '${_result!.toStringAsFixed(3)} J', icon: Icons.arrow_upward_outlined),
            ]),
        ],
      ),
    );
  }
}

class _PowerCalc extends StatefulWidget {
  const _PowerCalc();
  @override
  State<_PowerCalc> createState() => _PowerCalcState();
}

class _PowerCalcState extends State<_PowerCalc> {
  final _w = TextEditingController();
  final _t = TextEditingController();
  double? _result;
  String? _error;
  final _service = const PhysicsCalculatorService();

  @override
  void dispose() {
    _w.dispose();
    _t.dispose();
    super.dispose();
  }

  void _calculate() {
    final w = double.tryParse(_w.text);
    final t = double.tryParse(_t.text);
    if (w == null || t == null) {
      setState(() {
        _error = 'Enter work and time';
        _result = null;
      });
      return;
    }
    try {
      setState(() {
        _result = _service.power(w, t);
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
      appBar: AppBar(title: const Text('Power')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const FormulaBlock('P = W / t'),
          const SizedBox(height: 16),
          TextField(controller: _w, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Work (J)')),
          const SizedBox(height: 12),
          TextField(controller: _t, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Time (s)')),
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
              ResultCard(label: 'Power', value: '${_result!.toStringAsFixed(3)} W', icon: Icons.power_outlined),
            ]),
        ],
      ),
    );
  }
}

class _MomentumCalc extends StatefulWidget {
  const _MomentumCalc();
  @override
  State<_MomentumCalc> createState() => _MomentumCalcState();
}

class _MomentumCalcState extends State<_MomentumCalc> {
  final _m = TextEditingController();
  final _v = TextEditingController();
  double? _result;
  String? _error;
  final _service = const PhysicsCalculatorService();

  @override
  void dispose() {
    _m.dispose();
    _v.dispose();
    super.dispose();
  }

  void _calculate() {
    final m = double.tryParse(_m.text);
    final v = double.tryParse(_v.text);
    if (m == null || v == null) {
      setState(() {
        _error = 'Enter mass and velocity';
        _result = null;
      });
      return;
    }
    setState(() {
      _result = _service.momentum(m, v);
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Momentum')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const FormulaBlock('p = m × v'),
          const SizedBox(height: 16),
          TextField(controller: _m, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Mass (kg)')),
          const SizedBox(height: 12),
          TextField(controller: _v, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Velocity (m/s)')),
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
              ResultCard(label: 'Momentum', value: '${_result!.toStringAsFixed(3)} kg·m/s', icon: Icons.sports_baseball_outlined),
            ]),
        ],
      ),
    );
  }
}

class _OhmsLawCalc extends StatefulWidget {
  const _OhmsLawCalc();
  @override
  State<_OhmsLawCalc> createState() => _OhmsLawCalcState();
}

class _OhmsLawCalcState extends State<_OhmsLawCalc> {
  final _v = TextEditingController();
  final _i = TextEditingController();
  final _r = TextEditingController();
  Map<String, double>? _results;
  String? _error;
  final _service = const PhysicsCalculatorService();

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
        _results = null;
      });
      return;
    }
    try {
      setState(() {
        _results = {
          if (v == null) 'Voltage': _service.ohmsLawVoltage(i!, r!),
          if (i == null) 'Current': _service.ohmsLawCurrent(v!, r!),
          if (r == null) 'Resistance': _service.ohmsLawResistance(v!, i!),
        };
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
          if (_results != null)
            _resultSection(context, [
              for (final entry in _results!.entries)
                ResultCard(label: entry.key, value: '${entry.value.toStringAsFixed(3)} ${entry.key == 'Voltage' ? 'V' : entry.key == 'Current' ? 'A' : 'Ω'}', icon: Icons.bolt_outlined),
            ]),
        ],
      ),
    );
  }
}

class _ElectricalPowerCalc extends StatefulWidget {
  const _ElectricalPowerCalc();
  @override
  State<_ElectricalPowerCalc> createState() => _ElectricalPowerCalcState();
}

class _ElectricalPowerCalcState extends State<_ElectricalPowerCalc> {
  final _v = TextEditingController();
  final _i = TextEditingController();
  final _r = TextEditingController();
  double? _result;
  String? _error;
  final _service = const PhysicsCalculatorService();

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
        _result = _service.electricalPower(v: v, i: i, r: r);
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
      appBar: AppBar(title: const Text('Electrical Power')),
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
            _resultSection(context, [
              ResultCard(label: 'Power', value: '${_result!.toStringAsFixed(3)} W', icon: Icons.electric_bolt),
            ]),
        ],
      ),
    );
  }
}

class _FrequencyCalc extends StatefulWidget {
  const _FrequencyCalc();
  @override
  State<_FrequencyCalc> createState() => _FrequencyCalcState();
}

class _FrequencyCalcState extends State<_FrequencyCalc> {
  final _t = TextEditingController();
  double? _result;
  String? _error;
  final _service = const PhysicsCalculatorService();

  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  void _calculate() {
    final t = double.tryParse(_t.text);
    if (t == null) {
      setState(() {
        _error = 'Enter period';
        _result = null;
      });
      return;
    }
    try {
      setState(() {
        _result = _service.frequency(t);
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
      appBar: AppBar(title: const Text('Frequency')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const FormulaBlock('f = 1 / T'),
          const SizedBox(height: 16),
          TextField(controller: _t, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Period (s)')),
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
              ResultCard(label: 'Frequency', value: '${_result!.toStringAsFixed(3)} Hz', icon: Icons.graphic_eq_outlined),
            ]),
        ],
      ),
    );
  }
}

class _WavelengthCalc extends StatefulWidget {
  const _WavelengthCalc();
  @override
  State<_WavelengthCalc> createState() => _WavelengthCalcState();
}

class _WavelengthCalcState extends State<_WavelengthCalc> {
  final _v = TextEditingController();
  final _f = TextEditingController();
  double? _result;
  String? _error;
  final _service = const PhysicsCalculatorService();

  @override
  void dispose() {
    _v.dispose();
    _f.dispose();
    super.dispose();
  }

  void _calculate() {
    final v = double.tryParse(_v.text);
    final f = double.tryParse(_f.text);
    if (v == null || f == null) {
      setState(() {
        _error = 'Enter speed and frequency';
        _result = null;
      });
      return;
    }
    try {
      setState(() {
        _result = _service.wavelength(v, f);
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
      appBar: AppBar(title: const Text('Wavelength')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const FormulaBlock('λ = v / f'),
          const SizedBox(height: 16),
          TextField(controller: _v, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Wave speed (m/s)')),
          const SizedBox(height: 12),
          TextField(controller: _f, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Frequency (Hz)')),
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
              ResultCard(label: 'Wavelength', value: '${_result!.toStringAsFixed(3)} m', icon: Icons.waves_outlined),
            ]),
        ],
      ),
    );
  }
}

class _WaveSpeedCalc extends StatefulWidget {
  const _WaveSpeedCalc();
  @override
  State<_WaveSpeedCalc> createState() => _WaveSpeedCalcState();
}

class _WaveSpeedCalcState extends State<_WaveSpeedCalc> {
  final _f = TextEditingController();
  final _lambda = TextEditingController();
  double? _result;
  String? _error;
  final _service = const PhysicsCalculatorService();

  @override
  void dispose() {
    _f.dispose();
    _lambda.dispose();
    super.dispose();
  }

  void _calculate() {
    final f = double.tryParse(_f.text);
    final lambda = double.tryParse(_lambda.text);
    if (f == null || lambda == null) {
      setState(() {
        _error = 'Enter frequency and wavelength';
        _result = null;
      });
      return;
    }
    setState(() {
      _result = _service.waveSpeed(f, lambda);
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wave Speed')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const FormulaBlock('v = f × λ'),
          const SizedBox(height: 16),
          TextField(controller: _f, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Frequency (Hz)')),
          const SizedBox(height: 12),
          TextField(controller: _lambda, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Wavelength (m)')),
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
              ResultCard(label: 'Wave speed', value: '${_result!.toStringAsFixed(3)} m/s', icon: Icons.water_outlined),
            ]),
        ],
      ),
    );
  }
}
