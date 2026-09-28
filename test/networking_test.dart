import 'package:flutter_test/flutter_test.dart';
import 'package:computer_engineering_companion/domain/services/networking_calculator_service.dart';

void main() {
  const service = NetworkingCalculatorService();

  group('Subnet Calculator', () {
    test('calculates /24 subnet correctly', () {
      final info = service.calculateSubnet('192.168.1.10', cidr: 24);
      expect(info.networkAddress.dotted, '192.168.1.0');
      expect(info.broadcastAddress.dotted, '192.168.1.255');
      expect(info.firstHost.dotted, '192.168.1.1');
      expect(info.lastHost.dotted, '192.168.1.254');
      expect(info.usableHosts, 254);
      expect(info.subnetMask.dotted, '255.255.255.0');
      expect(info.wildcardMask.dotted, '0.0.0.255');
    });

    test('calculates /30 subnet', () {
      final info = service.calculateSubnet('10.0.0.5', cidr: 30);
      expect(info.networkAddress.dotted, '10.0.0.4');
      expect(info.broadcastAddress.dotted, '10.0.0.7');
      expect(info.usableHosts, 2);
    });

    test('identifies private addresses', () {
      expect(service.calculateSubnet('10.0.0.1', cidr: 8).isPrivate, true);
      expect(service.calculateSubnet('192.168.1.1', cidr: 24).isPrivate, true);
      expect(service.calculateSubnet('8.8.8.8', cidr: 24).isPrivate, false);
    });

    test('identifies class', () {
      expect(service.calculateSubnet('10.0.0.1', cidr: 8).ipClass, 'A');
      expect(service.calculateSubnet('172.16.0.1', cidr: 12).ipClass, 'B');
      expect(service.calculateSubnet('192.168.1.1', cidr: 24).ipClass, 'C');
    });
  });

  group('CIDR to Mask', () {
    test('/24 gives 255.255.255.0', () {
      expect(service.maskFromCidr(24).dotted, '255.255.255.0');
    });

    test('/8 gives 255.0.0.0', () {
      expect(service.maskFromCidr(8).dotted, '255.0.0.0');
    });

    test('/0 gives 0.0.0.0', () {
      expect(service.maskFromCidr(0).dotted, '0.0.0.0');
    });

    test('/32 gives 255.255.255.255', () {
      expect(service.maskFromCidr(32).dotted, '255.255.255.255');
    });

    test('throws on invalid CIDR', () {
      expect(() => service.maskFromCidr(33), throwsArgumentError);
    });
  });

  group('Mask to CIDR', () {
    test('255.255.255.0 gives /24', () {
      expect(service.cidrFromMask('255.255.255.0'), 24);
    });

    test('255.255.0.0 gives /16', () {
      expect(service.cidrFromMask('255.255.0.0'), 16);
    });

    test('throws on invalid mask', () {
      expect(() => service.cidrFromMask('255.0.255.0'), throwsFormatException);
    });
  });

  group('Subnet Splitting', () {
    test('splits /24 into /26 subnets', () {
      final subnets = service.subnetSplit('192.168.1.0', 24, 26);
      expect(subnets.length, 4);
      expect(subnets[0].networkAddress.dotted, '192.168.1.0');
      expect(subnets[1].networkAddress.dotted, '192.168.1.64');
    });
  });

  group('Data Rate Conversion', () {
    test('1 Gbps to Mbps', () {
      expect(service.convertDataRate(1, 'Gbps', 'Mbps'), 1000.0);
    });

    test('100 Mbps to Gbps', () {
      expect(service.convertDataRate(100, 'Mbps', 'Gbps'), 0.1);
    });

    test('1 MB to KB', () {
      expect(service.convertDataUnit(1, 'MB', 'KB'), 1024.0);
    });
  });

  group('Bandwidth', () {
    test('transfer time', () {
      expect(service.bandwidthTime(100, 10), 80.0);
    });

    test('throws on zero bandwidth', () {
      expect(() => service.bandwidthTime(100, 0), throwsArgumentError);
    });
  });

  group('Nyquist & Shannon', () {
    test('Nyquist rate doubles bandwidth', () {
      expect(service.nyquistRate(1000), 2000);
    });

    test('Shannon capacity increases with SNR', () {
      final c1 = service.shannonCapacity(1000, 10);
      final c2 = service.shannonCapacity(1000, 100);
      expect(c2, greaterThan(c1));
    });
  });

  group('Latency', () {
    test('calculates propagation delay', () {
      final ms = service.latency(1000);
      expect(ms, closeTo(5.0, 0.001));
    });

    test('RTT is double latency', () {
      expect(service.roundTripTime(10), 20);
    });
  });

  group('Binary IP', () {
    test('converts IP to binary', () {
      expect(service.ipToBinary('0.0.0.1'), '00000000000000000000000000000001');
    });

    test('converts binary to IP', () {
      expect(service.binaryToIp('00000000000000000000000000000001'), '0.0.0.1');
    });

    test('throws on invalid binary', () {
      expect(() => service.binaryToIp('12345'), throwsFormatException);
    });
  });
}
