import 'package:flutter_test/flutter_test.dart';
import 'package:computer_engineering_companion/domain/services/electronics_calculator_service.dart';

void main() {
  const service = ElectronicsCalculatorService();

  group('Ohm\'s Law', () {
    test('calculates current from V and R', () {
      final result = service.ohmsLaw(v: 12, r: 6);
      expect(result.current!, 2.0);
    });

    test('calculates voltage from I and R', () {
      final result = service.ohmsLaw(i: 2, r: 6);
      expect(result.voltage!, 12.0);
    });

    test('calculates resistance from V and I', () {
      final result = service.ohmsLaw(v: 12, i: 2);
      expect(result.resistance!, 6.0);
    });

    test('calculates power', () {
      final result = service.ohmsLaw(v: 12, i: 2);
      expect(result.power!, 24.0);
    });
  });

  group('Power', () {
    test('P = VI', () {
      expect(service.power(v: 12, i: 2), 24.0);
    });

    test('P = I²R', () {
      expect(service.power(i: 2, r: 6), 24.0);
    });

    test('P = V²/R', () {
      expect(service.power(v: 12, r: 6), 24.0);
    });

    test('throws with insufficient data', () {
      expect(() => service.power(v: 12), throwsArgumentError);
    });
  });

  group('Voltage Divider', () {
    test('equal resistors halve voltage', () {
      expect(service.voltageDivider(10, 1000, 1000), 5.0);
    });

    test('unequal resistors divide proportionally', () {
      expect(service.voltageDivider(12, 1000, 2000), 8.0);
    });

    test('throws on zero total resistance', () {
      expect(() => service.voltageDivider(10, 0, 0), throwsArgumentError);
    });
  });

  group('LED Resistor', () {
    test('calculates resistor for typical LED', () {
      final r = service.ledResistor(5, 2, 20);
      expect(r, 150.0);
    });

    test('throws when Vf >= Vsupply', () {
      expect(() => service.ledResistor(1.5, 2, 20), throwsArgumentError);
    });

    test('throws on zero current', () {
      expect(() => service.ledResistor(5, 2, 0), throwsArgumentError);
    });
  });

  group('Series Resistance', () {
    test('sums resistances', () {
      expect(service.seriesResistance([100, 200, 300]), 600);
    });

    test('empty list returns zero', () {
      expect(service.seriesResistance([]), 0);
    });
  });

  group('Parallel Resistance', () {
    test('two equal resistors halve', () {
      expect(service.parallelResistance([100, 100]), 50.0);
    });

    test('two different resistors', () {
      final r = service.parallelResistance([100, 200]);
      expect(r, closeTo(66.667, 0.01));
    });

    test('three resistors', () {
      final r = service.parallelResistance([100, 200, 300]);
      expect(r, closeTo(54.545, 0.01));
    });
  });

  group('RC Circuit', () {
    test('time constant', () {
      expect(service.rcTimeConstant(1000, 0.001), 1.0);
    });

    test('cutoff frequency', () {
      final fc = service.rcCutoffFrequency(1000, 0.000001);
      expect(fc, closeTo(159.15, 0.1));
    });
  });

  group('Resistance Color Bands', () {
    test('1kΩ 5% gives brown black red gold', () {
      final bands = service.resistanceToColorBands(1000);
      expect(bands, contains('Brown'));
      expect(bands, contains('Black'));
      expect(bands, contains('Red'));
    });

    test('throws on negative resistance', () {
      expect(() => service.resistanceToColorBands(-100), throwsArgumentError);
    });
  });
}
