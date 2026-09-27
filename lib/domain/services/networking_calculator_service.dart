import 'dart:math' as math;

class IpAddress {
  final int value;
  const IpAddress(this.value);

  factory IpAddress.parse(String ip) {
    final parts = ip.split('.');
    if (parts.length != 4) throw const FormatException('Invalid IPv4 address');
    var value = 0;
    for (final part in parts) {
      final octet = int.tryParse(part);
      if (octet == null || octet < 0 || octet > 255) {
        throw const FormatException('Invalid IPv4 address');
      }
      value = (value << 8) | octet;
    }
    return IpAddress(value);
  }

  factory IpAddress.fromValue(int value) => IpAddress(value & 0xFFFFFFFF);

  int get octet1 => (value >> 24) & 0xFF;
  int get octet2 => (value >> 16) & 0xFF;
  int get octet3 => (value >> 8) & 0xFF;
  int get octet4 => value & 0xFF;

  String get dotted => '$octet1.$octet2.$octet3.$octet4';

  String get binary =>
      value.toRadixString(2).padLeft(32, '0');

  IpAddress operator &(IpAddress other) => IpAddress(value & other.value);
  IpAddress operator |(IpAddress other) => IpAddress(value | other.value);
  IpAddress operator ~() => IpAddress(~value & 0xFFFFFFFF);

  @override
  String toString() => dotted;
}

class SubnetInfo {
  const SubnetInfo({
    required this.networkAddress,
    required this.broadcastAddress,
    required this.firstHost,
    required this.lastHost,
    required this.usableHosts,
    required this.subnetMask,
    required this.wildcardMask,
    required this.cidr,
    required this.ipClass,
    required this.isPrivate,
  });

  final IpAddress networkAddress, broadcastAddress, firstHost, lastHost;
  final int usableHosts, cidr;
  final IpAddress subnetMask, wildcardMask;
  final String ipClass;
  final bool isPrivate;
}

class NetworkingCalculatorService {
  const NetworkingCalculatorService();

  IpAddress maskFromCidr(int cidr) {
    if (cidr < 0 || cidr > 32) {
      throw ArgumentError('CIDR must be between 0 and 32');
    }
    if (cidr == 0) return const IpAddress(0);
    return IpAddress((0xFFFFFFFF << (32 - cidr)) & 0xFFFFFFFF);
  }

  int cidrFromMask(String mask) {
    final m = IpAddress.parse(mask);
    var cidr = 0;
    var bits = m.value;
    while (bits != 0) {
      if ((bits & 0x80000000) == 0) break;
      cidr++;
      bits = (bits << 1) & 0xFFFFFFFF;
    }
    final expected = maskFromCidr(cidr);
    if (expected.value != m.value) {
      throw const FormatException('Invalid subnet mask');
    }
    return cidr;
  }

  SubnetInfo calculateSubnet(String ip, {int? cidr, String? mask}) {
    final address = IpAddress.parse(ip);
    final prefix = cidr ?? (mask != null ? cidrFromMask(mask) : 24);
    final subnetMask = maskFromCidr(prefix);
    final wildcard = ~subnetMask;
    final network = address & subnetMask;
    final broadcast = network | wildcard;
    final usable = math.pow(2, 32 - prefix).toInt() - 2;
    final firstHost = usable > 0
        ? IpAddress.fromValue(network.value + 1)
        : network;
    final lastHost = usable > 0
        ? IpAddress.fromValue(broadcast.value - 1)
        : broadcast;
    return SubnetInfo(
      networkAddress: network,
      broadcastAddress: broadcast,
      firstHost: firstHost,
      lastHost: lastHost,
      usableHosts: usable > 0 ? usable : 0,
      subnetMask: subnetMask,
      wildcardMask: wildcard,
      cidr: prefix,
      ipClass: _ipClass(address),
      isPrivate: _isPrivate(address),
    );
  }

  String _ipClass(IpAddress ip) {
    final first = ip.octet1;
    if (first < 128) return 'A';
    if (first < 192) return 'B';
    if (first < 224) return 'C';
    if (first < 240) return 'D (Multicast)';
    return 'E (Experimental)';
  }

  bool _isPrivate(IpAddress ip) {
    if (ip.octet1 == 10) return true;
    if (ip.octet1 == 172 && ip.octet2 >= 16 && ip.octet2 <= 31) return true;
    if (ip.octet1 == 192 && ip.octet2 == 168) return true;
    if (ip.octet1 == 127) return true;
    if (ip.octet1 == 169 && ip.octet2 == 254) return true;
    return false;
  }

  List<SubnetInfo> subnetSplit(String ip, int cidr, int newCidr) {
    if (newCidr <= cidr || newCidr > 32) {
      throw ArgumentError('New CIDR must be greater than current and ≤ 32');
    }
    final base = calculateSubnet(ip, cidr: cidr);
    final count = math.pow(2, newCidr - cidr).toInt();
    final subnets = <SubnetInfo>[];
    final increment = math.pow(2, 32 - newCidr).toInt();
    for (var i = 0; i < count; i++) {
      final networkValue = base.networkAddress.value + i * increment;
      final networkIp = IpAddress.fromValue(networkValue);
      subnets.add(calculateSubnet(networkIp.dotted, cidr: newCidr));
    }
    return subnets;
  }

  List<String> ipRange(String startIp, String endIp) {
    final start = IpAddress.parse(startIp).value;
    final end = IpAddress.parse(endIp).value;
    if (end < start) throw ArgumentError('End IP must be ≥ start IP');
    if (end - start > 65536) {
      throw ArgumentError('Range too large (max 65536 addresses)');
    }
    return [
      for (var v = start; v <= end; v++) IpAddress.fromValue(v).dotted,
    ];
  }

  String binaryToIp(String binary) {
    if (binary.length != 32 || !RegExp(r'^[01]+$').hasMatch(binary)) {
      throw const FormatException('Binary IP must be 32 bits');
    }
    final octets = [
      for (var i = 0; i < 4; i++) int.parse(binary.substring(i * 8, i * 8 + 8), radix: 2),
    ];
    return octets.join('.');
  }

  String ipToBinary(String ip) => IpAddress.parse(ip).binary;

  double dataRate(double bits, String unit) {
    final multiplier = switch (unit.toUpperCase()) {
      'BPS' => 1.0,
      'KBPS' => 1e3,
      'MBPS' => 1e6,
      'GBPS' => 1e9,
      'TBPS' => 1e12,
      _ => throw ArgumentError('Unknown unit: $unit'),
    };
    return bits / multiplier;
  }

  double convertDataRate(double value, String from, String to) {
    final inBps = value * switch (from.toUpperCase()) {
      'BPS' => 1.0,
      'KBPS' => 1e3,
      'MBPS' => 1e6,
      'GBPS' => 1e9,
      'TBPS' => 1e12,
      _ => throw ArgumentError('Unknown unit: $from'),
    };
    return inBps / switch (to.toUpperCase()) {
      'BPS' => 1.0,
      'KBPS' => 1e3,
      'MBPS' => 1e6,
      'GBPS' => 1e9,
      'TBPS' => 1e12,
      _ => throw ArgumentError('Unknown unit: $to'),
    };
  }

  double convertDataUnit(double value, String from, String to) {
    final inBytes = value * switch (from.toUpperCase()) {
      'B' => 1.0,
      'KB' => 1024.0,
      'MB' => 1024.0 * 1024,
      'GB' => 1024.0 * 1024 * 1024,
      'TB' => 1024.0 * 1024 * 1024 * 1024,
      _ => throw ArgumentError('Unknown unit: $from'),
    };
    return inBytes / switch (to.toUpperCase()) {
      'B' => 1.0,
      'KB' => 1024.0,
      'MB' => 1024.0 * 1024,
      'GB' => 1024.0 * 1024 * 1024,
      'TB' => 1024.0 * 1024 * 1024 * 1024,
      _ => throw ArgumentError('Unknown unit: $to'),
    };
  }

  double bandwidthTime(double dataSizeMb, double bandwidthMbps) {
    if (bandwidthMbps <= 0) throw ArgumentError('Bandwidth must be positive');
    return (dataSizeMb * 8) / bandwidthMbps;
  }

  double throughput(double goodput, double total) {
    if (total <= 0) throw ArgumentError('Total must be positive');
    return goodput / total;
  }

  double latency(double distanceKm, {double speed = 200000}) {
    if (distanceKm <= 0) throw ArgumentError('Distance must be positive');
    return distanceKm * 1000 / speed;
  }

  double roundTripTime(double latencyMs) => latencyMs * 2;

  double bandwidthDelayProduct(double bandwidthMbps, double rttMs) {
    return bandwidthMbps * 1e6 * (rttMs / 1000) / 8;
  }

  double nyquistRate(double bandwidthHz) => 2 * bandwidthHz;

  double shannonCapacity(double bandwidthHz, double snr) {
    if (snr <= 0) throw ArgumentError('SNR must be positive');
    return bandwidthHz * math.log(1 + snr) / math.ln2;
  }

  double snrDb(double signalPower, double noisePower) {
    if (signalPower <= 0 || noisePower <= 0) {
      throw ArgumentError('Powers must be positive');
    }
    return 10 * math.log(signalPower / noisePower) / math.ln10;
  }
}
