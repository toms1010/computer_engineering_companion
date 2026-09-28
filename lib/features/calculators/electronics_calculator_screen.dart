import 'package:flutter/material.dart';

import '../../core/error/app_exception.dart';
import '../../domain/services/electronics_calculator_service.dart';
import '../../widgets/calculator.dart';

/// Electronics calculators: Ohm's law, series and parallel networks, RC
/// circuits and LED resistors.
///
/// Eight near-identical screens collapse into a static table of
/// [CalculatorEntry] values feeding the shared [CalculatorScreen]. The
/// arithmetic still lives in [ElectronicsCalculatorService], which is
/// unchanged and still unit-tested directly.
class ElectronicsCalculatorScreen extends StatelessWidget {
  const ElectronicsCalculatorScreen({super.key, this.initial});

  /// Optional entry id to open immediately, used by the Home quick tool.
  final String? initial;

  /// The whole catalogue as data. `const` so nothing is rebuilt per frame.
  static const _entries = <CalculatorEntry>[
    CalculatorEntry(
      title: "Ohm's law",
      formula: 'V = I × R',
      icon: Icons.bolt_outlined,
      fields: [
        CalculatorField(label: 'Voltage (V)'),
        CalculatorField(label: 'Current (A)'),
        CalculatorField(label: 'Resistance (Ω)'),
      ],
      compute: _ohmsLaw,
    ),
    CalculatorEntry(
      title: 'Series resistance',
      formula: 'Rtotal = R₁ + R₂ + R₃',
      icon: Icons.add_circle_outline,
      fields: [
        CalculatorField(label: 'R1 (Ω)'),
        CalculatorField(label: 'R2 (Ω)'),
        CalculatorField(label: 'R3 (Ω)'),
      ],
      compute: _series,
    ),
    CalculatorEntry(
      title: 'Parallel resistance',
      formula: '1/Rtotal = 1/R₁ + 1/R₂ + 1/R₃',
      icon: Icons.account_tree_outlined,
      fields: [
        CalculatorField(label: 'R1 (Ω)'),
        CalculatorField(label: 'R2 (Ω)'),
        CalculatorField(label: 'R3 (Ω)'),
      ],
      compute: _parallel,
    ),
    CalculatorEntry(
      title: 'Voltage divider',
      formula: 'Vout = Vin × R2 / (R1 + R2)',
      icon: Icons.vertical_align_center,
      fields: [
        CalculatorField(label: 'Input voltage (V)'),
        CalculatorField(label: 'R1 (Ω)'),
        CalculatorField(label: 'R2 (Ω)'),
      ],
      compute: _voltageDivider,
    ),
    CalculatorEntry(
      title: 'Current divider',
      formula: 'I₁ = Itotal × R₂ / (R₁ + R₂)',
      icon: Icons.electric_bolt,
      fields: [
        CalculatorField(label: 'Total current (A)'),
        CalculatorField(label: 'R1 (Ω)'),
        CalculatorField(label: 'R2 (Ω)'),
      ],
      compute: _currentDivider,
    ),
    CalculatorEntry(
      title: 'LED resistor',
      formula: 'R = (Vsupply − Vf) / If',
      icon: Icons.electrical_services,
      fields: [
        CalculatorField(label: 'Supply voltage (V)'),
        CalculatorField(label: 'Forward voltage (V)'),
        CalculatorField(label: 'Forward current (mA)'),
      ],
      compute: _led,
    ),
    CalculatorEntry(
      title: 'RC time constant',
      formula: 'τ = R × C,  fc = 1 / (2πRC)',
      icon: Icons.timer_outlined,
      fields: [
        CalculatorField(label: 'Resistance (Ω)'),
        // A capacitor value is legitimately positive; the sign is not.
        CalculatorField(label: 'Capacitance (F)'),
      ],
      compute: _rc,
    ),
    CalculatorEntry(
      title: 'Resistance colour bands',
      formula: 'Ohms → band colours',
      icon: Icons.palette_outlined,
      fields: [CalculatorField(label: 'Resistance (Ω)')],
      compute: _bands,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (initial != null) {
      final match = _entries
          .where((e) => e.title.toLowerCase().contains(initial!.toLowerCase()))
          .firstOrNull;
      if (match != null) {
        return CalculatorScreen(
          title: match.title,
          formula: match.formula,
          fields: match.fields,
          compute: match.compute,
        );
      }
    }
    return CalculatorIndexScreen(
      title: 'Electronics',
      description:
          'Solve for the unknown from any two known values. Every result is '
          'computed on this device.',
      entries: _entries,
    );
  }
}

/// Shared, stateless service instance. `const`, so there is nothing to
/// allocate and nothing to dispose.
const _service = ElectronicsCalculatorService();

// ---------------------------------------------------------------------------
// Computations. Pure functions over the parsed inputs, so they are trivially
// unit-testable and contain no widget concerns.
// ---------------------------------------------------------------------------

List<CalculatorResult> _ohmsLaw(Map<String, double> input) {
  final v = input['Voltage (V)'];
  final i = input['Current (A)'];
  final r = input['Resistance (Ω)'];
  final filled = [v, i, r].where((x) => x != null).length;
  if (filled != 2) {
    throw const ValidationException(
        'Enter exactly two of voltage, current and resistance.');
  }
  if (r != null && r == 0) {
    throw const ValidationException('Resistance cannot be zero.');
  }
  return [
    if (v == null)
      CalculatorResult(
        label: 'Voltage',
        value: _service.ohmsLawVoltage(i!, r!).toStringAsFixed(3),
        unit: 'V',
        icon: Icons.bolt_outlined,
      ),
    if (i == null)
      CalculatorResult(
        label: 'Current',
        value: _service.ohmsLawCurrent(v!, r!).toStringAsFixed(4),
        unit: 'A',
        icon: Icons.electric_bolt,
      ),
    if (r == null)
      CalculatorResult(
        label: 'Resistance',
        value: _service.ohmsLawResistance(v!, i!).toStringAsFixed(3),
        unit: 'Ω',
        icon: Icons.tag,
      ),
  ];
}

List<CalculatorResult> _series(Map<String, double> input) => [
      CalculatorResult(
        label: 'Total resistance',
        value: _service
            .seriesResistance([input['R1 (Ω)']!, input['R2 (Ω)']!, input['R3 (Ω)']!])
            .toStringAsFixed(3),
        unit: 'Ω',
        icon: Icons.add_circle_outline,
      ),
    ];

List<CalculatorResult> _parallel(Map<String, double> input) => [
      CalculatorResult(
        label: 'Total resistance',
        value: _service
            .parallelResistance(
                [input['R1 (Ω)']!, input['R2 (Ω)']!, input['R3 (Ω)']!])
            .toStringAsFixed(3),
        unit: 'Ω',
        icon: Icons.account_tree_outlined,
      ),
    ];

List<CalculatorResult> _voltageDivider(Map<String, double> input) => [
      CalculatorResult(
        label: 'Output voltage',
        value: _service
            .voltageDivider(input['Input voltage (V)']!, input['R1 (Ω)']!,
                input['R2 (Ω)']!)
            .toStringAsFixed(3),
        unit: 'V',
        icon: Icons.bolt_outlined,
      ),
    ];

List<CalculatorResult> _currentDivider(Map<String, double> input) {
  final total = input['Total current (A)']!;
  final r1 = input['R1 (Ω)']!;
  final r2 = input['R2 (Ω)']!;
  return [
    CalculatorResult(
      label: 'Current through R1',
      value: _service.currentDivider(total, r1, r2).toStringAsFixed(4),
      unit: 'A',
      icon: Icons.electric_bolt,
    ),
    CalculatorResult(
      label: 'Current through R2',
      value: _service.currentDivider(total, r2, r1).toStringAsFixed(4),
      unit: 'A',
      icon: Icons.electric_bolt,
    ),
  ];
}

List<CalculatorResult> _led(Map<String, double> input) {
  final value = _service.ledResistor(
    input['Supply voltage (V)']!,
    input['Forward voltage (V)']!,
    input['Forward current (mA)']!,
  );
  return [
    CalculatorResult(
      label: 'Resistor value',
      value: '${value.round()}',
      unit: 'Ω',
      note: 'Use the nearest standard value.',
      icon: Icons.electrical_services,
    ),
  ];
}

List<CalculatorResult> _rc(Map<String, double> input) {
  final r = input['Resistance (Ω)']!;
  final c = input['Capacitance (F)']!;
  return [
    CalculatorResult(
      label: 'Time constant (τ)',
      value: _service.rcTimeConstant(r, c).toStringAsFixed(6),
      unit: 's',
      icon: Icons.timer_outlined,
    ),
    CalculatorResult(
      label: 'Cutoff frequency (fc)',
      value: _service.rcCutoffFrequency(r, c).toStringAsFixed(3),
      unit: 'Hz',
      icon: Icons.graphic_eq,
    ),
  ];
}

List<CalculatorResult> _bands(Map<String, double> input) => [
      CalculatorResult(
        label: 'Colour bands',
        value: _service.resistanceToColorBands(input['Resistance (Ω)']!),
        icon: Icons.palette_outlined,
      ),
    ];

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
