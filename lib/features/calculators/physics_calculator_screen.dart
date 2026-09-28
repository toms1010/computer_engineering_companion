import 'package:flutter/material.dart';

import '../../core/error/app_exception.dart';
import '../../domain/services/physics_calculator_service.dart';
import '../../widgets/calculator.dart';

/// Physics calculators: mechanics, waves and electricity.
///
/// Thirteen near-identical screens become one static table of
/// [CalculatorEntry] values. All arithmetic stays in
/// [PhysicsCalculatorService], which is unchanged and directly unit-tested.
class PhysicsCalculatorScreen extends StatelessWidget {
  const PhysicsCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CalculatorIndexScreen(
      title: 'Physics',
      description:
          'Mechanics, waves and electricity. Enter the known values to solve '
          'for the unknown — everything is computed on this device.',
      entries: _entries,
    );
  }
}

const _service = PhysicsCalculatorService();

const _entries = <CalculatorEntry>[
  CalculatorEntry(
    title: 'Velocity',
    formula: 'v = d / t',
    icon: Icons.speed_outlined,
    fields: [
      CalculatorField(label: 'Distance (m)'),
      CalculatorField(label: 'Time (s)'),
    ],
    compute: _velocity,
  ),
  CalculatorEntry(
    title: 'Acceleration',
    formula: 'a = Δv / Δt',
    icon: Icons.trending_up_outlined,
    fields: [
      CalculatorField(label: 'Change in velocity (m/s)', allowNegative: true),
      CalculatorField(label: 'Time (s)'),
    ],
    compute: _acceleration,
  ),
  CalculatorEntry(
    title: 'Force',
    formula: 'F = m × a',
    icon: Icons.fitness_center_outlined,
    fields: [
      CalculatorField(label: 'Mass (kg)'),
      CalculatorField(label: 'Acceleration (m/s²)', allowNegative: true),
    ],
    compute: _force,
  ),
  CalculatorEntry(
    title: 'Work',
    formula: 'W = F × d × cos(θ)',
    icon: Icons.construction_outlined,
    fields: [
      CalculatorField(label: 'Force (N)', allowNegative: true),
      CalculatorField(label: 'Distance (m)'),
      CalculatorField(label: 'Angle (degrees)', initial: '0', allowNegative: true),
    ],
    compute: _work,
  ),
  CalculatorEntry(
    title: 'Kinetic energy',
    formula: 'KE = ½ × m × v²',
    icon: Icons.local_fire_department_outlined,
    fields: [
      CalculatorField(label: 'Mass (kg)'),
      CalculatorField(label: 'Velocity (m/s)', allowNegative: true),
    ],
    compute: _kineticEnergy,
  ),
  CalculatorEntry(
    title: 'Potential energy',
    formula: 'PE = m × g × h',
    icon: Icons.arrow_upward_outlined,
    fields: [
      CalculatorField(label: 'Mass (kg)'),
      CalculatorField(label: 'Height (m)', allowNegative: true),
    ],
    compute: _potentialEnergy,
  ),
  CalculatorEntry(
    title: 'Power',
    formula: 'P = W / t',
    icon: Icons.power_outlined,
    fields: [
      CalculatorField(label: 'Work (J)', allowNegative: true),
      CalculatorField(label: 'Time (s)'),
    ],
    compute: _power,
  ),
  CalculatorEntry(
    title: 'Momentum',
    formula: 'p = m × v',
    icon: Icons.sports_baseball_outlined,
    fields: [
      CalculatorField(label: 'Mass (kg)'),
      CalculatorField(label: 'Velocity (m/s)', allowNegative: true),
    ],
    compute: _momentum,
  ),
  CalculatorEntry(
    title: 'Impulse',
    formula: 'J = F × Δt',
    icon: Icons.bolt_outlined,
    fields: [
      CalculatorField(label: 'Force (N)', allowNegative: true),
      CalculatorField(label: 'Time (s)'),
    ],
    compute: _impulse,
  ),
  CalculatorEntry(
    title: "Ohm's law",
    formula: 'V = I × R',
    icon: Icons.electric_bolt,
    description: 'Enter any two values; the third is solved for.',
    fields: [
      CalculatorField(label: 'Voltage (V)', optional: true),
      CalculatorField(label: 'Current (A)', optional: true),
      CalculatorField(label: 'Resistance (Ω)', optional: true),
    ],
    compute: _ohmsLaw,
  ),
  CalculatorEntry(
    title: 'Electrical power',
    formula: 'P = V × I = I² × R = V² / R',
    icon: Icons.bolt_outlined,
    description: 'Enter any two values; the third is solved for.',
    fields: [
      CalculatorField(label: 'Voltage (V)', optional: true),
      CalculatorField(label: 'Current (A)', optional: true),
      CalculatorField(label: 'Resistance (Ω)', optional: true),
    ],
    compute: _electricalPower,
  ),
  CalculatorEntry(
    title: 'Frequency',
    formula: 'f = 1 / T',
    icon: Icons.graphic_eq_outlined,
    fields: [CalculatorField(label: 'Period (s)')],
    compute: _frequency,
  ),
  CalculatorEntry(
    title: 'Period',
    formula: 'T = 1 / f',
    icon: Icons.av_timer_outlined,
    fields: [CalculatorField(label: 'Frequency (Hz)')],
    compute: _period,
  ),
  CalculatorEntry(
    title: 'Wave speed',
    formula: 'v = f × λ',
    icon: Icons.water_outlined,
    fields: [
      CalculatorField(label: 'Frequency (Hz)'),
      CalculatorField(label: 'Wavelength (m)'),
    ],
    compute: _waveSpeed,
  ),
  CalculatorEntry(
    title: 'Wavelength',
    formula: 'λ = v / f',
    icon: Icons.waves_outlined,
    fields: [
      CalculatorField(label: 'Wave speed (m/s)', allowNegative: true),
      CalculatorField(label: 'Frequency (Hz)'),
    ],
    compute: _wavelength,
  ),
  CalculatorEntry(
    title: 'Projectile range',
    formula: 'R = v² sin(2θ) / g',
    icon: Icons.change_history_outlined,
    fields: [
      CalculatorField(label: 'Launch speed (m/s)'),
      CalculatorField(label: 'Angle (degrees)', initial: '45'),
    ],
    compute: _projectileRange,
  ),
  CalculatorEntry(
    title: 'Maximum height',
    formula: 'H = v² sin²(θ) / 2g',
    icon: Icons.vertical_align_top,
    fields: [
      CalculatorField(label: 'Launch speed (m/s)'),
      CalculatorField(label: 'Angle (degrees)', initial: '90'),
    ],
    compute: _projectileHeight,
  ),
  CalculatorEntry(
    title: 'Gravitational force',
    formula: 'F = G m₁ m₂ / r²',
    icon: Icons.public,
    fields: [
      CalculatorField(label: 'Mass 1 (kg)'),
      CalculatorField(label: 'Mass 2 (kg)'),
      CalculatorField(label: 'Distance (m)'),
    ],
    compute: _gravitationalForce,
  ),
  CalculatorEntry(
    title: 'Centripetal acceleration',
    formula: 'a = v² / r',
    icon: Icons.rotate_right,
    fields: [
      CalculatorField(label: 'Velocity (m/s)', allowNegative: true),
      CalculatorField(label: 'Radius (m)'),
    ],
    compute: _centripetal,
  ),
  CalculatorEntry(
    title: 'Density',
    formula: 'ρ = m / V',
    icon: Icons.scale_outlined,
    fields: [
      CalculatorField(label: 'Mass (kg)'),
      CalculatorField(label: 'Volume (m³)'),
    ],
    compute: _density,
  ),
  CalculatorEntry(
    title: 'Pressure',
    formula: 'P = F / A',
    icon: Icons.compress,
    fields: [
      CalculatorField(label: 'Force (N)', allowNegative: true),
      CalculatorField(label: 'Area (m²)'),
    ],
    compute: _pressure,
  ),
  CalculatorEntry(
    title: 'Spring force',
    formula: 'F = kx',
    icon: Icons.compress_outlined,
    fields: [
      CalculatorField(label: 'Spring constant (N/m)'),
      CalculatorField(label: 'Displacement (m)', allowNegative: true),
    ],
    compute: _springForce,
  ),
  CalculatorEntry(
    title: 'Spring energy',
    formula: 'E = ½ k x²',
    icon: Icons.energy_savings_leaf_outlined,
    fields: [
      CalculatorField(label: 'Spring constant (N/m)'),
      CalculatorField(label: 'Displacement (m)', allowNegative: true),
    ],
    compute: _springEnergy,
  ),
];

// ---------------------------------------------------------------------------
// Computations
// ---------------------------------------------------------------------------

CalculatorResult _out(String label, double value, String unit, IconData icon,
        {int decimals = 3}) =>
    CalculatorResult(
      label: label,
      value: value.toStringAsFixed(decimals),
      unit: unit,
      icon: icon,
    );

/// Wraps a service call so a divide-by-zero surfaces as a message the user can
/// act on rather than a raw `ArgumentError`.
CalculatorResult _guarded(
  String label,
  String unit,
  IconData icon,
  double Function() compute, {
  int decimals = 3,
}) {
  try {
    return _out(label, compute(), unit, icon, decimals: decimals);
  } on ArgumentError catch (error) {
    throw ValidationException(
        (error.message?.toString() ?? 'The values cannot be combined.')
            .replaceFirst('Invalid argument(s): ', ''));
  }
}

List<CalculatorResult> _velocity(Map<String, double> i) => [
      _guarded('Velocity', 'm/s', Icons.speed_outlined,
          () => _service.velocity(i['Distance (m)']!, i['Time (s)']!)),
    ];

List<CalculatorResult> _acceleration(Map<String, double> i) => [
      _guarded('Acceleration', 'm/s²', Icons.trending_up_outlined, () =>
          _service.acceleration(i['Change in velocity (m/s)']!, i['Time (s)']!)),
    ];

List<CalculatorResult> _force(Map<String, double> i) => [
      _out('Force', _service.force(i['Mass (kg)']!, i['Acceleration (m/s²)']!),
          'N', Icons.fitness_center_outlined),
    ];

List<CalculatorResult> _work(Map<String, double> i) => [
      _guarded(
          'Work',
          'J',
          Icons.construction_outlined,
          () => _service.work(i['Force (N)']!, i['Distance (m)']!,
              angleDegrees: i['Angle (degrees)']!)),
    ];

List<CalculatorResult> _kineticEnergy(Map<String, double> i) => [
      _out('Kinetic energy', _service.kineticEnergy(i['Mass (kg)']!, i['Velocity (m/s)']!),
          'J', Icons.local_fire_department_outlined),
    ];

List<CalculatorResult> _potentialEnergy(Map<String, double> i) => [
      _out('Potential energy',
          _service.potentialEnergy(i['Mass (kg)']!, i['Height (m)']!), 'J',
          Icons.arrow_upward_outlined),
    ];

List<CalculatorResult> _power(Map<String, double> i) => [
      _guarded('Power', 'W', Icons.power_outlined,
          () => _service.power(i['Work (J)']!, i['Time (s)']!)),
    ];

List<CalculatorResult> _momentum(Map<String, double> i) => [
      _out('Momentum', _service.momentum(i['Mass (kg)']!, i['Velocity (m/s)']!),
          'kg·m/s', Icons.sports_baseball_outlined),
    ];

List<CalculatorResult> _impulse(Map<String, double> i) => [
      _out('Impulse', _service.impulse(i['Force (N)']!, i['Time (s)']!),
          'N·s', Icons.bolt_outlined),
    ];

List<CalculatorResult> _ohmsLaw(Map<String, double> i) {
  final v = i['Voltage (V)'];
  final a = i['Current (A)'];
  final r = i['Resistance (Ω)'];
  final filled = [v, a, r].where((x) => x != null).length;
  if (filled != 2) {
    throw const ValidationException(
        "Enter exactly two of voltage, current and resistance.");
  }

  final results = <CalculatorResult>[
    if (v == null)
      _guarded('Voltage', 'V', Icons.bolt_outlined,
          () => _service.ohmsLawVoltage(a!, r!), decimals: 3),
    if (a == null)
      _guarded('Current', 'A', Icons.electric_bolt,
          () => _service.ohmsLawCurrent(v!, r!), decimals: 4),
    if (r == null)
      _guarded('Resistance', 'Ω', Icons.tag,
          () => _service.ohmsLawResistance(v!, a!)),
    // Power follows from whichever two were given, so the user sees the
    // electrical consequence, not just the solved-for value.
    _guarded('Power', 'W', Icons.flash_on, () => _service.electricalPower(
        v: v, i: a, r: r)),
  ];
  return results;
}

List<CalculatorResult> _electricalPower(Map<String, double> i) => [
      _guarded('Power', 'W', Icons.electric_bolt, () {
        final v = i['Voltage (V)'];
        final a = i['Current (A)'];
        final r = i['Resistance (Ω)'];
        return _service.electricalPower(v: v, i: a, r: r);
      }),
    ];

List<CalculatorResult> _frequency(Map<String, double> i) => [
      _guarded(
          'Frequency', 'Hz', Icons.graphic_eq_outlined, () => _service.frequency(i['Period (s)']!)),
    ];

List<CalculatorResult> _period(Map<String, double> i) => [
      _guarded('Period', 's', Icons.av_timer_outlined,
          () => _service.period(i['Frequency (Hz)']!)),
    ];

List<CalculatorResult> _waveSpeed(Map<String, double> i) => [
      _out('Wave speed',
          _service.waveSpeed(i['Frequency (Hz)']!, i['Wavelength (m)']!), 'm/s',
          Icons.water_outlined),
    ];

List<CalculatorResult> _wavelength(Map<String, double> i) => [
      _guarded('Wavelength', 'm', Icons.waves_outlined,
          () => _service.wavelength(i['Wave speed (m/s)']!, i['Frequency (Hz)']!)),
    ];

List<CalculatorResult> _projectileRange(Map<String, double> i) => [
      _out('Range',
          _service.projectileRange(i['Launch speed (m/s)']!, i['Angle (degrees)']!),
          'm', Icons.change_history_outlined),
    ];

List<CalculatorResult> _projectileHeight(Map<String, double> i) => [
      _out('Maximum height',
          _service.projectileMaxHeight(
              i['Launch speed (m/s)']!, i['Angle (degrees)']!),
          'm', Icons.vertical_align_top),
    ];

List<CalculatorResult> _gravitationalForce(Map<String, double> i) => [
      _guarded(
          'Gravitational force',
          'N',
          Icons.public,
          () => _service.gravitationalForce(
              i['Mass 1 (kg)']!, i['Mass 2 (kg)']!, i['Distance (m)']!),
          decimals: 6),
    ];

List<CalculatorResult> _centripetal(Map<String, double> i) => [
      _guarded(
          'Centripetal acceleration',
          'm/s²',
          Icons.rotate_right,
          () => _service.centripetalAcceleration(
              i['Velocity (m/s)']!, i['Radius (m)']!)),
    ];

List<CalculatorResult> _density(Map<String, double> i) => [
      _guarded('Density', 'kg/m³', Icons.scale_outlined,
          () => _service.density(i['Mass (kg)']!, i['Volume (m³)']!)),
    ];

List<CalculatorResult> _pressure(Map<String, double> i) => [
      _guarded('Pressure', 'Pa', Icons.compress,
          () => _service.pressure(i['Force (N)']!, i['Area (m²)']!)),
    ];

List<CalculatorResult> _springForce(Map<String, double> i) => [
      _out('Spring force',
          _service.springForce(i['Spring constant (N/m)']!, i['Displacement (m)']!),
          'N', Icons.compress_outlined),
    ];

List<CalculatorResult> _springEnergy(Map<String, double> i) => [
      _out('Spring energy',
          _service.springEnergy(i['Spring constant (N/m)']!, i['Displacement (m)']!),
          'J', Icons.energy_savings_leaf_outlined),
    ];
