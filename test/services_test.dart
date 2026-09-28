import 'package:flutter_test/flutter_test.dart';
import 'package:computer_engineering_companion/domain/services/number_system_service.dart';

void main() {
  const service = NumberSystemService();
  const binary = BinaryCalculatorService();
  const bitwise = BitwiseCalculatorService();

  group('NumberSystemService', () {
    test('converts binary to decimal', () {
      expect(service.toDecimal('101101', NumberBase.binary), 45);
    });

    test('converts decimal to binary', () {
      expect(service.fromDecimal(45, NumberBase.binary), '101101');
    });

    test('converts decimal to octal', () {
      expect(service.fromDecimal(45, NumberBase.octal), '55');
    });

    test('converts decimal to hexadecimal', () {
      expect(service.fromDecimal(45, NumberBase.hexadecimal), '2D');
    });

    test('convertAll returns all bases', () {
      final results = service.convertAll('101101', NumberBase.binary);
      expect(results[NumberBase.binary], '101101');
      expect(results[NumberBase.decimal], '45');
      expect(results[NumberBase.octal], '55');
      expect(results[NumberBase.hexadecimal], '2D');
    });

    test('validates binary input', () {
      expect(service.isValid('101101', NumberBase.binary), true);
      expect(service.isValid('102', NumberBase.binary), false);
    });

    test('validates hex input', () {
      expect(service.isValid('2D', NumberBase.hexadecimal), true);
      expect(service.isValid('2G', NumberBase.hexadecimal), false);
    });

    test('binary addition', () {
      expect(service.add('101', '011', NumberBase.binary), '1000');
    });

    test('binary subtraction', () {
      expect(service.subtract('1010', '0011', NumberBase.binary), '111');
    });

    test('binary multiplication', () {
      expect(service.multiply('101', '11', NumberBase.binary), '1111');
    });

    test('binary division', () {
      expect(service.divide('1100', '10', NumberBase.binary), '110');
    });

    test('division by zero returns null', () {
      expect(service.divide('1100', '0', NumberBase.binary), null);
    });
  });

  group('BinaryCalculatorService', () {
    test('adds binary numbers', () {
      expect(binary.add('101101', '001011'), '111000');
    });

    test('subtracts binary numbers', () {
      expect(binary.subtract('101101', '001011'), '100010');
    });

    test('multiplies binary numbers', () {
      expect(binary.multiply('101', '11'), '1111');
    });

    test('divides binary numbers', () {
      expect(binary.divide('1100', '10'), '110');
    });

    test('AND operation', () {
      expect(binary.and('1100', '1010'), '1000');
    });

    test('OR operation', () {
      expect(binary.or('1100', '1010'), '1110');
    });

    test('XOR operation', () {
      expect(binary.xor('1100', '1010'), '110');
    });

    test('NOT operation', () {
      expect(binary.not('1010', bits: 4), '0101');
    });

    test('shift left', () {
      expect(binary.shiftLeft('101', 2), '10100');
    });

    test('shift right', () {
      expect(binary.shiftRight('10100', 2), '101');
    });

    test('validates binary input', () {
      expect(binary.isValidBinary('101101'), true);
      expect(binary.isValidBinary('102'), false);
    });

    test('converts to decimal', () {
      expect(binary.toDecimal('101101'), 45);
    });
  });

  group('BitwiseCalculatorService', () {
    test('AND operation', () {
      final result = bitwise.compute(BitwiseOperation.and, 170, 204);
      expect(result.decimalResult, 136);
    });

    test('OR operation', () {
      final result = bitwise.compute(BitwiseOperation.or, 170, 204);
      expect(result.decimalResult, 238);
    });

    test('XOR operation', () {
      final result = bitwise.compute(BitwiseOperation.xor, 170, 204);
      expect(result.decimalResult, 102);
    });

    test('NOT operation', () {
      final result = bitwise.compute(BitwiseOperation.not, 170, 0);
      expect(result.decimalResult, 85);
    });

    test('shift left', () {
      final result = bitwise.compute(BitwiseOperation.shiftLeft, 1, 4);
      expect(result.decimalResult, 16);
    });

    test('shift right', () {
      final result = bitwise.compute(BitwiseOperation.shiftRight, 16, 4);
      expect(result.decimalResult, 1);
    });

    test('NAND operation', () {
      final result = bitwise.compute(BitwiseOperation.nand, 170, 204);
      expect(result.decimalResult, 119);
    });

    test('NOR operation', () {
      final result = bitwise.compute(BitwiseOperation.nor, 170, 204);
      expect(result.decimalResult, 17);
    });

    test('result includes hex', () {
      final result = bitwise.compute(BitwiseOperation.and, 170, 204);
      expect(result.hexResult, '0x88');
    });
  });
}
