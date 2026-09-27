import 'dart:math' as math;

class Polynomial {
  final Map<int, double> terms;

  const Polynomial(this.terms);

  static final _termPattern = RegExp(
      r'([+-]?)\s*(\d*\.?\d*)\s*(x(?:\s*\^\s*(\d+))?)?');

  static Polynomial parse(String input) {
    final normalized = input
        .replaceAll(' ', '')
        .replaceAll('-', '+-')
        .replaceAll('−', '-')
        .replaceAll('*', '');
    final terms = <int, double>{};
    if (normalized.isEmpty) return const Polynomial({});
    for (final match in _termPattern.allMatches(normalized)) {
      final sign = match.group(1);
      final coeffText = match.group(2) ?? '';
      final hasX = match.group(3) != null;
      final expText = match.group(4);
      if (!hasX && coeffText.isEmpty) continue;
      double coeff;
      if (hasX) {
        coeff = coeffText.isEmpty ? 1.0 : double.parse(coeffText);
      } else {
        if (coeffText.isEmpty) continue;
        coeff = double.parse(coeffText);
      }
      if (sign == '-') coeff = -coeff;
      final exp = hasX ? (expText == null ? 1 : int.parse(expText)) : 0;
      terms[exp] = (terms[exp] ?? 0) + coeff;
    }
    final cleaned = <int, double>{
      for (final e in terms.entries)
        if (e.value != 0) e.key: e.value,
    };
    return Polynomial(cleaned);
  }

  double evaluate(double x) {
    var sum = 0.0;
    for (final entry in terms.entries) {
      sum += entry.value * math.pow(x, entry.key);
    }
    return sum;
  }

  Polynomial derivative() {
    final result = <int, double>{};
    for (final entry in terms.entries) {
      if (entry.key == 0) continue;
      result[entry.key - 1] = entry.value * entry.key;
    }
    return Polynomial(result);
  }

  Polynomial integral() {
    final result = <int, double>{};
    for (final entry in terms.entries) {
      result[entry.key + 1] = entry.value / (entry.key + 1);
    }
    return Polynomial(result);
  }

  @override
  String toString() {
    if (terms.isEmpty) return '0';
    final parts = <String>[];
    final sorted = terms.keys.toList()..sort((a, b) => b.compareTo(a));
    for (final exp in sorted) {
      final coeff = terms[exp]!;
      final sign = coeff < 0 ? '- ' : (parts.isEmpty ? '' : '+ ');
      final absCoeff = coeff.abs();
      final coeffStr = (absCoeff == 1 && exp != 0)
          ? ''
          : _formatNumber(absCoeff);
      final varPart = exp == 0
          ? ''
          : exp == 1
              ? 'x'
              : 'x^$exp';
      parts.add('$sign$coeffStr$varPart');
    }
    return parts.join(' ');
  }

  static String _formatNumber(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(4).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }
}

class CalculusCalculatorService {
  const CalculusCalculatorService();

  Polynomial derivative(String expression) =>
      Polynomial.parse(expression).derivative();

  Polynomial indefiniteIntegral(String expression) =>
      Polynomial.parse(expression).integral();

  double definiteIntegral(String expression, double a, double b,
      {int intervals = 1000}) {
    final poly = Polynomial.parse(expression);
    if (intervals % 2 != 0) intervals++;
    final h = (b - a) / intervals;
    var sum = poly.evaluate(a) + poly.evaluate(b);
    for (var i = 1; i < intervals; i++) {
      final x = a + i * h;
      sum += poly.evaluate(x) * (i % 2 == 0 ? 2 : 4);
    }
    return sum * h / 3;
  }

  double? limit(String expression, double point, {double epsilon = 1e-7}) {
    final poly = Polynomial.parse(expression);
    final left = poly.evaluate(point - epsilon);
    final right = poly.evaluate(point + epsilon);
    final atPoint = poly.evaluate(point);
    if ((left - right).abs() < 1e-4) return atPoint;
    if (left.isInfinite || right.isInfinite) return null;
    if ((left - right).abs() > 1e3) return null;
    return (left + right) / 2;
  }

  double slope(double x1, double y1, double x2, double y2) {
    if (x2 == x1) throw ArgumentError('x values must differ');
    return (y2 - y1) / (x2 - x1);
  }

  double averageRateOfChange(String expression, double a, double b) {
    if (b == a) throw ArgumentError('Interval endpoints must differ');
    final poly = Polynomial.parse(expression);
    return (poly.evaluate(b) - poly.evaluate(a)) / (b - a);
  }

  double riemannSum(String expression, double a, double b, int rectangles,
      {String method = 'right'}) {
    if (rectangles <= 0) throw ArgumentError('Rectangles must be positive');
    final poly = Polynomial.parse(expression);
    final dx = (b - a) / rectangles;
    var sum = 0.0;
    for (var i = 0; i < rectangles; i++) {
      final x = switch (method) {
        'left' => a + i * dx,
        'midpoint' => a + (i + 0.5) * dx,
        _ => a + (i + 1) * dx,
      };
      sum += poly.evaluate(x) * dx;
    }
    return sum;
  }

  double newtonRaphson(String expression, double initialGuess,
      {int maxIterations = 100, double tolerance = 1e-10}) {
    final poly = Polynomial.parse(expression);
    final deriv = poly.derivative();
    var x = initialGuess;
    for (var i = 0; i < maxIterations; i++) {
      final fx = poly.evaluate(x);
      final dfx = deriv.evaluate(x);
      if (dfx.abs() < 1e-15) return double.nan;
      final next = x - fx / dfx;
      if ((next - x).abs() < tolerance) return next;
      x = next;
    }
    return x;
  }

  double trapezoidalRule(String expression, double a, double b,
      {int intervals = 1000}) {
    final poly = Polynomial.parse(expression);
    final h = (b - a) / intervals;
    var sum = (poly.evaluate(a) + poly.evaluate(b)) / 2;
    for (var i = 1; i < intervals; i++) {
      sum += poly.evaluate(a + i * h);
    }
    return sum * h;
  }
}
