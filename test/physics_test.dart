import 'package:flutter_test/flutter_test.dart';
import 'package:computer_engineering_companion/domain/services/physics_calculator_service.dart';

void main() {
  const service = PhysicsCalculatorService();

  group('Velocity', () {
    test('v = d/t', () {
      expect(service.velocity(100, 10), 10.0);
    });

    test('throws on zero time', () {
      expect(() => service.velocity(100, 0), throwsArgumentError);
    });
  });

  group('Acceleration', () {
    test('a = Δv/Δt', () {
      expect(service.acceleration(20, 5), 4.0);
    });

    test('throws on zero time', () {
      expect(() => service.acceleration(20, 0), throwsArgumentError);
    });
  });

  group('Force', () {
    test('F = ma', () {
      expect(service.force(2, 3), 6.0);
    });
  });

  group('Work', () {
    test('W = Fd', () {
      expect(service.work(10, 5), 50.0);
    });

    test('W = Fd cos(θ)', () {
      expect(service.work(10, 5, angleDegrees: 60), closeTo(25.0, 0.01));
    });
  });

  group('Kinetic Energy', () {
    test('KE = ½mv²', () {
      expect(service.kineticEnergy(2, 3), 9.0);
    });
  });

  group('Potential Energy', () {
    test('PE = mgh', () {
      expect(service.potentialEnergy(2, 5), closeTo(98.1, 0.01));
    });
  });

  group('Power', () {
    test('P = W/t', () {
      expect(service.power(100, 10), 10.0);
    });

    test('throws on zero time', () {
      expect(() => service.power(100, 0), throwsArgumentError);
    });
  });

  group('Momentum', () {
    test('p = mv', () {
      expect(service.momentum(2, 3), 6.0);
    });
  });

  group('Impulse', () {
    test('J = FΔt', () {
      expect(service.impulse(10, 5), 50.0);
    });
  });

  group('Frequency', () {
    test('f = 1/T', () {
      expect(service.frequency(0.5), 2.0);
    });

    test('throws on zero period', () {
      expect(() => service.frequency(0), throwsArgumentError);
    });
  });

  group('Wave', () {
    test('v = fλ', () {
      expect(service.waveSpeed(10, 2), 20.0);
    });

    test('λ = v/f', () {
      expect(service.wavelength(20, 10), 2.0);
    });

    test('throws on zero frequency', () {
      expect(() => service.wavelength(20, 0), throwsArgumentError);
    });
  });

  group('Electrical', () {
    test('V = IR', () {
      expect(service.ohmsLawVoltage(2, 6), 12.0);
    });

    test('I = V/R', () {
      expect(service.ohmsLawCurrent(12, 6), 2.0);
    });

    test('R = V/I', () {
      expect(service.ohmsLawResistance(12, 2), 6.0);
    });

    test('P = VI', () {
      expect(service.electricalPower(v: 12, i: 2), 24.0);
    });
  });

  group('Projectile', () {
    test('range at 45°', () {
      final r = service.projectileRange(10, 45);
      expect(r, closeTo(10.19, 0.01));
    });

    test('max height at 90°', () {
      final h = service.projectileMaxHeight(10, 90);
      expect(h, closeTo(5.09, 0.01));
    });
  });
}
