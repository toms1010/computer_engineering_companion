import 'dart:math' as math;

class OhmsLawResult {
  const OhmsLawResult({
    required this.voltage,
    required this.current,
    required this.resistance,
    required this.power,
  });

  final double? voltage, current, resistance, power;
}

class ElectronicsCalculatorService {
  const ElectronicsCalculatorService();

  OhmsLawResult ohmsLaw({double? v, double? i, double? r}) {
    if (v != null && i != null && i != 0) {
      return OhmsLawResult(
          voltage: v,
          current: i,
          resistance: v / i,
          power: v * i);
    }
    if (v != null && r != null && r != 0) {
      return OhmsLawResult(
          voltage: v,
          current: v / r,
          resistance: r,
          power: (v * v) / r);
    }
    if (i != null && r != null) {
      return OhmsLawResult(
          voltage: i * r,
          current: i,
          resistance: r,
          power: (i * i) * r);
    }
    return const OhmsLawResult(
        voltage: null, current: null, resistance: null, power: null);
  }

  // Ohm's law, solved for one unknown. These three are the canonical
  // implementations: `PhysicsCalculatorService` delegates to them so the
  // formula is not defined twice.
  double ohmsLawVoltage(double current, double resistance) =>
      current * resistance;

  double ohmsLawCurrent(double voltage, double resistance) {
    if (resistance == 0) throw ArgumentError('Resistance cannot be zero');
    return voltage / resistance;
  }

  double ohmsLawResistance(double voltage, double current) {
    if (current == 0) throw ArgumentError('Current cannot be zero');
    return voltage / current;
  }

  double power({double? v, double? i, double? r}) {
    if (v != null && i != null) return v * i;
    if (v != null && r != null && r != 0) return (v * v) / r;
    if (i != null && r != null) return (i * i) * r;
    throw ArgumentError('Provide two of: voltage, current, resistance');
  }

  double voltageDivider(double vin, double r1, double r2) {
    if (r1 + r2 == 0) throw ArgumentError('Total resistance cannot be zero');
    return vin * r2 / (r1 + r2);
  }

  double currentDivider(double itotal, double r1, double r2) {
    if (r1 + r2 == 0) throw ArgumentError('Total resistance cannot be zero');
    return itotal * r2 / (r1 + r2);
  }

  double ledResistor(double supplyVoltage, double forwardVoltage,
      double forwardCurrentMa) {
    if (forwardCurrentMa <= 0) {
      throw ArgumentError('Forward current must be positive');
    }
    if (forwardVoltage >= supplyVoltage) {
      throw ArgumentError(
          'Forward voltage must be less than supply voltage');
    }
    return (supplyVoltage - forwardVoltage) / (forwardCurrentMa / 1000.0);
  }

  double seriesResistance(List<double> resistances) =>
      resistances.fold(0.0, (sum, r) => sum + r);

  double parallelResistance(List<double> resistances) {
    if (resistances.isEmpty) return 0;
    final reciprocalSum =
        resistances.fold(0.0, (sum, r) => sum + (r == 0 ? 0 : 1 / r));
    if (reciprocalSum == 0) {
      throw ArgumentError('At least one resistance must be non-zero');
    }
    return 1 / reciprocalSum;
  }

  double rcTimeConstant(double resistance, double capacitance) =>
      resistance * capacitance;

  double rcVoltage(double v0, double t, double resistance, double capacitance) =>
      v0 * (1 - math.exp(-t / (resistance * capacitance)));

  double rcCurrent(double v0, double t, double resistance, double capacitance) =>
      (v0 / resistance) * math.exp(-t / (resistance * capacitance));

  double rcCutoffFrequency(double resistance, double capacitance) =>
      1 / (2 * math.pi * resistance * capacitance);

  double capacitorEnergy(double capacitance, double voltage) =>
      0.5 * capacitance * voltage * voltage;

  double inductorEnergy(double inductance, double current) =>
      0.5 * inductance * current * current;

  double resonantFrequency(double inductance, double capacitance) =>
      1 / (2 * math.pi * math.sqrt(inductance * capacitance));

  String resistanceToColorBands(double ohms, {int tolerance = 5}) {
    if (ohms <= 0) throw ArgumentError('Resistance must be positive');
    final digits = ohms.toStringAsFixed(0).replaceAll('.', '');
    final first = int.parse(digits[0]);
    final second = digits.length > 1 ? int.parse(digits[1]) : 0;
    final multiplier = digits.length - 2;
    const bandColors = [
      'Black',
      'Brown',
      'Red',
      'Orange',
      'Yellow',
      'Green',
      'Blue',
      'Violet',
      'Grey',
      'White'
    ];
    final toleranceColor = switch (tolerance) {
      1 => 'Brown',
      2 => 'Red',
      0.5 => 'Green',
      0.25 => 'Blue',
      0.1 => 'Violet',
      5 => 'Gold',
      10 => 'Silver',
      _ => 'Gold',
    };
    return '${bandColors[first]} ${bandColors[second]} '
        '${bandColors[multiplier.clamp(0, 9)]} $toleranceColor';
  }
}
