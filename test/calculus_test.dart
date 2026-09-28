import 'package:flutter_test/flutter_test.dart';
import 'package:computer_engineering_companion/domain/services/calculus_calculator_service.dart';

void main() {
  const service = CalculusCalculatorService();

  group('Polynomial parsing', () {
    test('parses simple polynomial', () {
      final p = Polynomial.parse('3x^2 + 2x - 5');
      expect(p.terms[2], 3.0);
      expect(p.terms[1], 2.0);
      expect(p.terms[0], -5.0);
    });

    test('parses x without coefficient', () {
      final p = Polynomial.parse('x^3');
      expect(p.terms[3], 1.0);
    });

    test('parses constant', () {
      final p = Polynomial.parse('42');
      expect(p.terms[0], 42.0);
    });

    test('evaluates correctly', () {
      final p = Polynomial.parse('2x^2 + 3x + 1');
      expect(p.evaluate(2), 15.0);
    });
  });

  group('Derivative', () {
    test('power rule', () {
      final d = service.derivative('x^3');
      expect(d.toString(), '3x^2');
    });

    test('constant derivative is zero', () {
      final d = service.derivative('5');
      expect(d.toString(), '0');
    });

    test('linear term', () {
      final d = service.derivative('3x + 2');
      expect(d.toString(), '3');
    });

    test('product of terms', () {
      final d = service.derivative('2x^2 + 3x');
      expect(d.toString(), '4x + 3');
    });
  });

  group('Integral', () {
    test('power rule', () {
      final i = service.indefiniteIntegral('x^2');
      expect(i.toString(), contains('x^3'));
    });

    test('constant integral', () {
      final i = service.indefiniteIntegral('5');
      expect(i.toString(), '5x');
    });

    test('sum of terms', () {
      final i = service.indefiniteIntegral('3x^2 + 2x');
      expect(i.toString(), contains('x^3'));
      expect(i.toString(), contains('x^2'));
    });
  });

  group('Definite Integral', () {
    test('integrates x from 0 to 2', () {
      final result = service.definiteIntegral('x', 0, 2);
      expect(result, closeTo(2.0, 0.001));
    });

    test('integrates x^2 from 0 to 3', () {
      final result = service.definiteIntegral('x^2', 0, 3);
      expect(result, closeTo(9.0, 0.001));
    });

    test('constant function', () {
      final result = service.definiteIntegral('5', 0, 3);
      expect(result, closeTo(15.0, 0.001));
    });
  });

  group('Limit', () {
    test('limit of x^2 at x=2', () {
      final result = service.limit('x^2', 2);
      expect(result, closeTo(4.0, 0.01));
    });

    test('limit of polynomial', () {
      final result = service.limit('3x + 1', 5);
      expect(result, closeTo(16.0, 0.01));
    });
  });

  group('Slope', () {
    test('slope between two points', () {
      expect(service.slope(0, 0, 2, 4), 2.0);
    });

    test('negative slope', () {
      expect(service.slope(0, 4, 2, 0), -2.0);
    });

    test('throws on vertical line', () {
      expect(() => service.slope(2, 0, 2, 4), throwsArgumentError);
    });
  });

  group('Average Rate of Change', () {
    test('linear function', () {
      final result = service.averageRateOfChange('2x', 0, 5);
      expect(result, closeTo(2.0, 0.001));
    });

    test('quadratic function', () {
      final result = service.averageRateOfChange('x^2', 0, 2);
      expect(result, closeTo(2.0, 0.001));
    });
  });

  group('Riemann Sum', () {
    test('right sum approximates integral', () {
      final sum = service.riemannSum('x', 0, 2, 1000);
      expect(sum, closeTo(2.0, 0.01));
    });

    test('left sum approximates integral', () {
      final sum = service.riemannSum('x', 0, 2, 1000, method: 'left');
      expect(sum, closeTo(2.0, 0.01));
    });

    test('midpoint sum approximates integral', () {
      final sum = service.riemannSum('x', 0, 2, 100, method: 'midpoint');
      expect(sum, closeTo(2.0, 0.001));
    });
  });

  group('Newton-Raphson', () {
    test('finds square root of 4', () {
      final root = service.newtonRaphson('x^2 - 4', 3);
      expect(root, closeTo(2.0, 0.0001));
    });

    test('finds square root of 9', () {
      final root = service.newtonRaphson('x^2 - 9', 5);
      expect(root, closeTo(3.0, 0.0001));
    });
  });

  group('Trapezoidal Rule', () {
    test('approximates integral', () {
      final result = service.trapezoidalRule('x', 0, 2);
      expect(result, closeTo(2.0, 0.001));
    });
  });
}
