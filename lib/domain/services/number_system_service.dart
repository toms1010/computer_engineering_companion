import 'dart:math' as math;

enum NumberBase {
  binary(2, 'Binary', '01'),
  decimal(10, 'Decimal', '0123456789'),
  octal(8, 'Octal', '01234567'),
  hexadecimal(16, 'Hexadecimal', '0123456789ABCDEF');

  const NumberBase(this.radix, this.label, this.validDigits);
  final int radix;
  final String label;
  final String validDigits;

  static NumberBase fromLabel(String label) =>
      NumberBase.values.firstWhere((b) => b.label == label,
          orElse: () => NumberBase.decimal);
}

class NumberSystemService {
  const NumberSystemService();

  bool isValid(String value, NumberBase base) {
    if (value.isEmpty) return false;
    final upper = value.toUpperCase();
    if (base == NumberBase.hexadecimal && upper.startsWith('0X')) {
      return upper.length > 2 &&
          upper.substring(2).split('').every((c) => base.validDigits.contains(c));
    }
    return upper.split('').every((c) => base.validDigits.contains(c));
  }

  int toDecimal(String value, NumberBase base) {
    if (!isValid(value, base)) {
      throw FormatException('Invalid ${base.label} value: $value');
    }
    var v = value.toUpperCase();
    if (base == NumberBase.hexadecimal && v.startsWith('0X')) {
      v = v.substring(2);
    }
    return int.parse(v, radix: base.radix);
  }

  String fromDecimal(int value, NumberBase base) {
    if (value < 0) return '-${fromDecimal(-value, base)}';
    return value.toRadixString(base.radix).toUpperCase();
  }

  String convert(String value, NumberBase from, NumberBase to) =>
      fromDecimal(toDecimal(value, from), to);

  Map<NumberBase, String> convertAll(String value, NumberBase from) {
    final decimal = toDecimal(value, from);
    return {
      for (final base in NumberBase.values) base: fromDecimal(decimal, base),
    };
  }

  String add(String a, String b, NumberBase base) =>
      fromDecimal(toDecimal(a, base) + toDecimal(b, base), base);

  String subtract(String a, String b, NumberBase base) =>
      fromDecimal(toDecimal(a, base) - toDecimal(b, base), base);

  String multiply(String a, String b, NumberBase base) =>
      fromDecimal(toDecimal(a, base) * toDecimal(b, base), base);

  String? divide(String a, String b, NumberBase base) {
    final divisor = toDecimal(b, base);
    if (divisor == 0) return null;
    return fromDecimal(toDecimal(a, base) ~/ divisor, base);
  }

  String? modulo(String a, String b, NumberBase base) {
    final divisor = toDecimal(b, base);
    if (divisor == 0) return null;
    return fromDecimal(toDecimal(a, base) % divisor, base);
  }

  String twosComplement(String value, int bits) {
    final decimal = toDecimal(value, NumberBase.binary);
    final max = 1 << bits;
    final masked = decimal & (max - 1);
    return fromDecimal(masked, NumberBase.binary).padLeft(bits, '0');
  }

  int bitLength(String value, NumberBase base) =>
      toDecimal(value, base).bitLength;
}

class ConversionHistoryEntry {
  const ConversionHistoryEntry({
    required this.input,
    required this.fromBase,
    required this.toBase,
    required this.result,
    required this.timestamp,
  });

  final String input, result;
  final NumberBase fromBase, toBase;
  final DateTime timestamp;
}

class ConversionHistory {
  final _entries = <ConversionHistoryEntry>[];

  List<ConversionHistoryEntry> get entries => List.unmodifiable(_entries);

  void add(ConversionHistoryEntry entry) {
    _entries.insert(0, entry);
    if (_entries.length > 50) _entries.removeLast();
  }

  void clear() => _entries.clear();
}

class BinaryCalculatorService {
  const BinaryCalculatorService();

  static final _binaryPattern = RegExp(r'^[01]+$');

  bool isValidBinary(String value) =>
      value.isNotEmpty && _binaryPattern.hasMatch(value);

  int toDecimal(String binary) {
    if (!isValidBinary(binary)) {
      throw FormatException('Invalid binary value: $binary');
    }
    return int.parse(binary, radix: 2);
  }

  String toBinary(int value) {
    if (value < 0) return '-${(-value).toRadixString(2)}';
    return value.toRadixString(2);
  }

  String add(String a, String b) => toBinary(toDecimal(a) + toDecimal(b));

  String subtract(String a, String b) => toBinary(toDecimal(a) - toDecimal(b));

  String multiply(String a, String b) =>
      toBinary(toDecimal(a) * toDecimal(b));

  String? divide(String a, String b) {
    final divisor = toDecimal(b);
    if (divisor == 0) return null;
    return toBinary(toDecimal(a) ~/ divisor);
  }

  String? modulo(String a, String b) {
    final divisor = toDecimal(b);
    if (divisor == 0) return null;
    return toBinary(toDecimal(a) % divisor);
  }

  String and(String a, String b) =>
      toBinary(toDecimal(a) & toDecimal(b));

  String or(String a, String b) => toBinary(toDecimal(a) | toDecimal(b));

  String xor(String a, String b) =>
      toBinary(toDecimal(a) ^ toDecimal(b));

  String not(String a, {int? bits}) {
    final value = toDecimal(a);
    final width = bits ?? math.max(a.length, 1);
    final mask = (1 << width) - 1;
    return toBinary((~value) & mask).padLeft(width, '0');
  }

  String shiftLeft(String a, int positions) =>
      toBinary(toDecimal(a) << positions);

  String shiftRight(String a, int positions) =>
      toBinary(toDecimal(a) >> positions);

  String onesComplement(String a) => not(a);

  String twosComplement(String a, {int? bits}) {
    final width = bits ?? a.length;
    final value = toDecimal(a);
    final mask = (1 << width) - 1;
    return toBinary(((~value) + 1) & mask).padLeft(width, '0');
  }
}

enum BitwiseOperation {
  and('AND', '&'),
  or('OR', '|'),
  xor('XOR', '^'),
  not('NOT', '~'),
  nand('NAND', '⊼'),
  nor('NOR', '⊽'),
  shiftLeft('SHIFT LEFT', '<<'),
  shiftRight('SHIFT RIGHT', '>>');

  const BitwiseOperation(this.label, this.symbol);
  final String label, symbol;
}

class BitwiseResult {
  const BitwiseResult({
    required this.operation,
    required this.inputA,
    required this.inputB,
    required this.result,
    required this.decimalA,
    required this.decimalB,
    required this.decimalResult,
    required this.hexResult,
  });

  final BitwiseOperation operation;
  final String inputA, inputB, result;
  final int decimalA, decimalB, decimalResult;
  final String hexResult;
}

class BitwiseCalculatorService {
  const BitwiseCalculatorService();

  BitwiseResult compute(BitwiseOperation op, int a, int b, {int bits = 8}) {
    final mask = bits >= 64 ? -1 : ((1 << bits) - 1);
    final aMasked = a & mask;
    final bMasked = b & mask;
    int result;
    switch (op) {
      case BitwiseOperation.and:
        result = aMasked & bMasked;
      case BitwiseOperation.or:
        result = aMasked | bMasked;
      case BitwiseOperation.xor:
        result = aMasked ^ bMasked;
      case BitwiseOperation.not:
        result = (~aMasked) & mask;
      case BitwiseOperation.nand:
        result = (~(aMasked & bMasked)) & mask;
      case BitwiseOperation.nor:
        result = (~(aMasked | bMasked)) & mask;
      case BitwiseOperation.shiftLeft:
        result = (aMasked << b) & mask;
      case BitwiseOperation.shiftRight:
        result = (aMasked >> b) & mask;
    }
    final width = (bits + 3) ~/ 4;
    return BitwiseResult(
      operation: op,
      inputA: aMasked.toRadixString(2).padLeft(bits, '0'),
      inputB: bMasked.toRadixString(2).padLeft(bits, '0'),
      result: result.toRadixString(2).padLeft(bits, '0'),
      decimalA: aMasked,
      decimalB: bMasked,
      decimalResult: result,
      hexResult:
          '0x${result.toRadixString(16).toUpperCase().padLeft(width, '0')}',
    );
  }
}
