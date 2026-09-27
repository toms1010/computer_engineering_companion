import 'dart:math' as math;

class PhysicsCalculatorService {
  const PhysicsCalculatorService();

  double velocity(double distance, double time) {
    if (time == 0) throw ArgumentError('Time cannot be zero');
    return distance / time;
  }

  double acceleration(double deltaV, double time) {
    if (time == 0) throw ArgumentError('Time cannot be zero');
    return deltaV / time;
  }

  double force(double mass, double acceleration) => mass * acceleration;

  double work(double force, double distance, {double angleDegrees = 0}) =>
      force * distance * math.cos(angleDegrees * math.pi / 180);

  double kineticEnergy(double mass, double velocity) =>
      0.5 * mass * velocity * velocity;

  double potentialEnergy(double mass, double height,
      {double gravity = 9.81}) =>
      mass * gravity * height;

  double power(double work, double time) {
    if (time == 0) throw ArgumentError('Time cannot be zero');
    return work / time;
  }

  double momentum(double mass, double velocity) => mass * velocity;

  double impulse(double force, double time) => force * time;

  double frequency(double period) {
    if (period == 0) throw ArgumentError('Period cannot be zero');
    return 1 / period;
  }

  double period(double frequency) {
    if (frequency == 0) throw ArgumentError('Frequency cannot be zero');
    return 1 / frequency;
  }

  double waveSpeed(double frequency, double wavelength) =>
      frequency * wavelength;

  double wavelength(double speed, double frequency) {
    if (frequency == 0) throw ArgumentError('Frequency cannot be zero');
    return speed / frequency;
  }

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

  double electricalPower({double? v, double? i, double? r}) {
    if (v != null && i != null) return v * i;
    if (v != null && r != null && r != 0) return (v * v) / r;
    if (i != null && r != null) return (i * i) * r;
    throw ArgumentError('Provide two of: voltage, current, resistance');
  }

  double gravitationalForce(double m1, double m2, double distance) {
    const g = 6.674e-11;
    if (distance == 0) throw ArgumentError('Distance cannot be zero');
    return g * m1 * m2 / (distance * distance);
  }

  double centripetalAcceleration(double velocity, double radius) {
    if (radius == 0) throw ArgumentError('Radius cannot be zero');
    return (velocity * velocity) / radius;
  }

  double density(double mass, double volume) {
    if (volume == 0) throw ArgumentError('Volume cannot be zero');
    return mass / volume;
  }

  double pressure(double force, double area) {
    if (area == 0) throw ArgumentError('Area cannot be zero');
    return force / area;
  }

  double springForce(double springConstant, double displacement) =>
      -springConstant * displacement;

  double springEnergy(double springConstant, double displacement) =>
      0.5 * springConstant * displacement * displacement;

  double projectileRange(double velocity, double angleDegrees,
      {double gravity = 9.81}) {
    final angle = angleDegrees * math.pi / 180;
    return (velocity * velocity * math.sin(2 * angle)) / gravity;
  }

  double projectileMaxHeight(double velocity, double angleDegrees,
      {double gravity = 9.81}) {
    final angle = angleDegrees * math.pi / 180;
    final vy = velocity * math.sin(angle);
    return (vy * vy) / (2 * gravity);
  }
}
