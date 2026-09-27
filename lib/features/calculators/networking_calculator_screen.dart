import 'package:flutter/material.dart';
import '../../core/widgets/ui.dart';
import '../../domain/services/networking_calculator_service.dart';

class NetworkingCalculatorScreen extends StatelessWidget {
  const NetworkingCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Networking Calculators')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Educational calculators for IP addressing, subnetting, and data rates.',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _CalcItem('IPv4 Calculator', Icons.dns_outlined, 'IP + mask details', () => _push(context, const _Ipv4Calc())),
          _CalcItem('CIDR Calculator', Icons.tag_outlined, 'Prefix to mask', () => _push(context, const _CidrCalc())),
          _CalcItem('Subnet Calculator', Icons.account_tree_outlined, 'Network, broadcast, hosts', () => _push(context, const _SubnetCalc())),
          _CalcItem('IP Range Calculator', Icons.linear_scale_outlined, 'List addresses in range', () => _push(context, const _IpRangeCalc())),
          _CalcItem('Binary IP Converter', Icons.code_outlined, 'IP ↔ binary', () => _push(context, const _BinaryIpCalc())),
          _CalcItem('Data Rate Converter', Icons.swap_horiz_outlined, 'bps, kbps, Mbps', () => _push(context, const _DataRateCalc())),
          _CalcItem('Bandwidth Calculator', Icons.speed_outlined, 'Transfer time', () => _push(context, const _BandwidthCalc())),
          _CalcItem('Throughput Calculator', Icons.trending_up_outlined, 'Goodput ratio', () => _push(context, const _ThroughputCalc())),
          _CalcItem('Latency Calculator', Icons.timer_outlined, 'Propagation delay', () => _push(context, const _LatencyCalc())),
        ],
      ),
    );
  }

  static void _push(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}

class _CalcItem extends StatelessWidget {
  const _CalcItem(this.title, this.icon, this.subtitle, this.onTap);
  final String title, subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(icon, color: Theme.of(context).colorScheme.onPrimaryContainer),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      ),
    );
  }
}

Widget _resultSection(BuildContext context, List<Widget> cards) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      Text('Results', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 10),
      ...cards,
    ],
  );
}

class _Ipv4Calc extends StatefulWidget {
  const _Ipv4Calc();
  @override
  State<_Ipv4Calc> createState() => _Ipv4CalcState();
}

class _Ipv4CalcState extends State<_Ipv4Calc> {
  final _ip = TextEditingController();
  final _cidr = TextEditingController(text: '24');
  SubnetInfo? _result;
  String? _error;
  final _service = const NetworkingCalculatorService();

  @override
  void dispose() {
    _ip.dispose();
    _cidr.dispose();
    super.dispose();
  }

  void _calculate() {
    final cidr = int.tryParse(_cidr.text);
    if (cidr == null || cidr < 0 || cidr > 32) {
      setState(() {
        _error = 'CIDR must be 0–32';
        _result = null;
      });
      return;
    }
    try {
      setState(() {
        _result = _service.calculateSubnet(_ip.text, cidr: cidr);
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = 'Invalid IP address';
        _result = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('IPv4 Calculator')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(controller: _ip, decoration: const InputDecoration(labelText: 'IP address', hintText: '192.168.1.10')),
          const SizedBox(height: 12),
          TextField(controller: _cidr, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'CIDR prefix', hintText: '24')),
          const SizedBox(height: 20),
          FilledButton(onPressed: _calculate, child: const Text('Calculate')),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
              ),
            ),
          ],
          if (_result != null)
            _resultSection(context, [
              ResultCard(label: 'Network', value: _result!.networkAddress.dotted, icon: Icons.lan_outlined),
              ResultCard(label: 'Broadcast', value: _result!.broadcastAddress.dotted, icon: Icons.campaign_outlined),
              ResultCard(label: 'Subnet mask', value: _result!.subnetMask.dotted, icon: Icons.filter_alt_outlined),
              ResultCard(label: 'Wildcard mask', value: _result!.wildcardMask.dotted, icon: Icons.filter_alt_off_outlined),
              ResultCard(label: 'First host', value: _result!.firstHost.dotted, icon: Icons.computer_outlined),
              ResultCard(label: 'Last host', value: _result!.lastHost.dotted, icon: Icons.computer),
              ResultCard(label: 'Usable hosts', value: '${_result!.usableHosts}', icon: Icons.devices_outlined),
              ResultCard(label: 'CIDR', value: '/${_result!.cidr}', icon: Icons.tag_outlined),
              ResultCard(label: 'Class', value: _result!.ipClass, icon: Icons.class_outlined),
              ResultCard(label: 'Private', value: _result!.isPrivate ? 'Yes' : 'No', icon: Icons.lock_outline),
            ]),
        ],
      ),
    );
  }
}

class _CidrCalc extends StatefulWidget {
  const _CidrCalc();
  @override
  State<_CidrCalc> createState() => _CidrCalcState();
}

class _CidrCalcState extends State<_CidrCalc> {
  final _cidr = TextEditingController();
  IpAddress? _mask;
  IpAddress? _wildcard;
  int? _hosts;
  String? _error;
  final _service = const NetworkingCalculatorService();

  @override
  void dispose() {
    _cidr.dispose();
    super.dispose();
  }

  void _calculate() {
    final cidr = int.tryParse(_cidr.text);
    if (cidr == null || cidr < 0 || cidr > 32) {
      setState(() {
        _error = 'CIDR must be 0–32';
        _mask = null;
        _wildcard = null;
        _hosts = null;
      });
      return;
    }
    final mask = _service.maskFromCidr(cidr);
    setState(() {
      _mask = mask;
      _wildcard = ~mask;
      _hosts = cidr >= 31 ? (cidr == 32 ? 1 : 2) : (1 << (32 - cidr)) - 2;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CIDR Calculator')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(controller: _cidr, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'CIDR prefix', hintText: '24')),
          const SizedBox(height: 20),
          FilledButton(onPressed: _calculate, child: const Text('Convert')),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
              ),
            ),
          ],
          if (_mask != null)
            _resultSection(context, [
              ResultCard(label: 'Subnet mask', value: _mask!.dotted, icon: Icons.filter_alt_outlined),
              ResultCard(label: 'Wildcard', value: _wildcard!.dotted, icon: Icons.filter_alt_off_outlined),
              ResultCard(label: 'Total addresses', value: '${(_hosts ?? 0) + 2}', icon: Icons.numbers_outlined),
              ResultCard(label: 'Usable hosts', value: '$_hosts', icon: Icons.devices_outlined),
            ]),
        ],
      ),
    );
  }
}

class _SubnetCalc extends StatefulWidget {
  const _SubnetCalc();
  @override
  State<_SubnetCalc> createState() => _SubnetCalcState();
}

class _SubnetCalcState extends State<_SubnetCalc> {
  final _ip = TextEditingController();
  final _cidr = TextEditingController(text: '24');
  final _newCidr = TextEditingController(text: '26');
  List<SubnetInfo>? _result;
  String? _error;
  final _service = const NetworkingCalculatorService();

  @override
  void dispose() {
    _ip.dispose();
    _cidr.dispose();
    _newCidr.dispose();
    super.dispose();
  }

  void _calculate() {
    final cidr = int.tryParse(_cidr.text);
    final newCidr = int.tryParse(_newCidr.text);
    if (cidr == null || newCidr == null) {
      setState(() {
        _error = 'Enter valid CIDR values';
        _result = null;
      });
      return;
    }
    try {
      setState(() {
        _result = _service.subnetSplit(_ip.text, cidr, newCidr);
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _result = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subnet Calculator')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(controller: _ip, decoration: const InputDecoration(labelText: 'IP address')),
          const SizedBox(height: 12),
          TextField(controller: _cidr, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Current CIDR')),
          const SizedBox(height: 12),
          TextField(controller: _newCidr, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'New CIDR')),
          const SizedBox(height: 20),
          FilledButton(onPressed: _calculate, child: const Text('Subnet')),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
              ),
            ),
          ],
          if (_result != null) ...[
            Text('${_result!.length} subnets', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            for (var i = 0; i < _result!.length; i++)
              Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Subnet ${i + 1}', style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text('Network: ${_result![i].networkAddress.dotted}'),
                      Text('Broadcast: ${_result![i].broadcastAddress.dotted}'),
                      Text('Range: ${_result![i].firstHost.dotted} – ${_result![i].lastHost.dotted}'),
                      Text('Hosts: ${_result![i].usableHosts}'),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _IpRangeCalc extends StatefulWidget {
  const _IpRangeCalc();
  @override
  State<_IpRangeCalc> createState() => _IpRangeCalcState();
}

class _IpRangeCalcState extends State<_IpRangeCalc> {
  final _start = TextEditingController();
  final _end = TextEditingController();
  List<String>? _result;
  String? _error;
  final _service = const NetworkingCalculatorService();

  @override
  void dispose() {
    _start.dispose();
    _end.dispose();
    super.dispose();
  }

  void _calculate() {
    try {
      final range = _service.ipRange(_start.text, _end.text);
      setState(() {
        _result = range;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _result = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('IP Range Calculator')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(controller: _start, decoration: const InputDecoration(labelText: 'Start IP')),
          const SizedBox(height: 12),
          TextField(controller: _end, decoration: const InputDecoration(labelText: 'End IP')),
          const SizedBox(height: 20),
          FilledButton(onPressed: _calculate, child: const Text('List')),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
              ),
            ),
          ],
          if (_result != null)
            _resultSection(context, [
              ResultCard(label: 'Addresses', value: '${_result!.length}', icon: Icons.format_list_numbered_outlined),
              for (var i = 0; i < _result!.length && i < 20; i++)
                ResultCard(label: 'IP $i', value: _result![i], icon: Icons.dns_outlined),
              if (_result!.length > 20)
                Text('... and ${_result!.length - 20} more'),
            ]),
        ],
      ),
    );
  }
}

class _BinaryIpCalc extends StatefulWidget {
  const _BinaryIpCalc();
  @override
  State<_BinaryIpCalc> createState() => _BinaryIpCalcState();
}

class _BinaryIpCalcState extends State<_BinaryIpCalc> {
  final _ip = TextEditingController();
  String? _binary;
  String? _error;
  final _service = const NetworkingCalculatorService();

  @override
  void dispose() {
    _ip.dispose();
    super.dispose();
  }

  void _calculate() {
    try {
      setState(() {
        _binary = _service.ipToBinary(_ip.text);
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = 'Invalid IP address';
        _binary = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Binary IP Converter')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(controller: _ip, decoration: const InputDecoration(labelText: 'IP address')),
          const SizedBox(height: 20),
          FilledButton(onPressed: _calculate, child: const Text('Convert')),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
              ),
            ),
          ],
          if (_binary != null)
            _resultSection(context, [
              ResultCard(label: 'Binary', value: _binary!, icon: Icons.code_outlined),
            ]),
        ],
      ),
    );
  }
}

class _DataRateCalc extends StatefulWidget {
  const _DataRateCalc();
  @override
  State<_DataRateCalc> createState() => _DataRateCalcState();
}

class _DataRateCalcState extends State<_DataRateCalc> {
  final _value = TextEditingController();
  String _from = 'Mbps';
  String _to = 'Gbps';
  double? _result;
  String? _error;
  final _service = const NetworkingCalculatorService();

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  void _calculate() {
    final value = double.tryParse(_value.text);
    if (value == null) {
      setState(() {
        _error = 'Enter a valid value';
        _result = null;
      });
      return;
    }
    setState(() {
      _result = _service.convertDataRate(value, _from, _to);
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Rate Converter')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(controller: _value, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Value')),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _from,
                  decoration: const InputDecoration(labelText: 'From'),
                  items: const [
                    DropdownMenuItem(value: 'bps', child: Text('bps')),
                    DropdownMenuItem(value: 'Kbps', child: Text('Kbps')),
                    DropdownMenuItem(value: 'Mbps', child: Text('Mbps')),
                    DropdownMenuItem(value: 'Gbps', child: Text('Gbps')),
                    DropdownMenuItem(value: 'Tbps', child: Text('Tbps')),
                  ],
                  onChanged: (v) => setState(() => _from = v ?? 'Mbps'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _to,
                  decoration: const InputDecoration(labelText: 'To'),
                  items: const [
                    DropdownMenuItem(value: 'bps', child: Text('bps')),
                    DropdownMenuItem(value: 'Kbps', child: Text('Kbps')),
                    DropdownMenuItem(value: 'Mbps', child: Text('Mbps')),
                    DropdownMenuItem(value: 'Gbps', child: Text('Gbps')),
                    DropdownMenuItem(value: 'Tbps', child: Text('Tbps')),
                  ],
                  onChanged: (v) => setState(() => _to = v ?? 'Gbps'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton(onPressed: _calculate, child: const Text('Convert')),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
              ),
            ),
          ],
          if (_result != null)
            _resultSection(context, [
              ResultCard(label: 'Result', value: '${_result!.toStringAsFixed(6)} $_to', icon: Icons.swap_horiz_outlined),
            ]),
        ],
      ),
    );
  }
}

class _BandwidthCalc extends StatefulWidget {
  const _BandwidthCalc();
  @override
  State<_BandwidthCalc> createState() => _BandwidthCalcState();
}

class _BandwidthCalcState extends State<_BandwidthCalc> {
  final _size = TextEditingController();
  final _bw = TextEditingController();
  double? _result;
  String? _error;
  final _service = const NetworkingCalculatorService();

  @override
  void dispose() {
    _size.dispose();
    _bw.dispose();
    super.dispose();
  }

  void _calculate() {
    final size = double.tryParse(_size.text);
    final bw = double.tryParse(_bw.text);
    if (size == null || bw == null) {
      setState(() {
        _error = 'Enter size and bandwidth';
        _result = null;
      });
      return;
    }
    setState(() {
      _result = _service.bandwidthTime(size, bw);
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bandwidth Calculator')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(controller: _size, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Data size (Mb)')),
          const SizedBox(height: 12),
          TextField(controller: _bw, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Bandwidth (Mbps)')),
          const SizedBox(height: 20),
          FilledButton(onPressed: _calculate, child: const Text('Calculate')),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
              ),
            ),
          ],
          if (_result != null)
            _resultSection(context, [
              ResultCard(label: 'Transfer time', value: '${_result!.toStringAsFixed(3)} seconds', icon: Icons.speed_outlined),
            ]),
        ],
      ),
    );
  }
}

class _ThroughputCalc extends StatefulWidget {
  const _ThroughputCalc();
  @override
  State<_ThroughputCalc> createState() => _ThroughputCalcState();
}

class _ThroughputCalcState extends State<_ThroughputCalc> {
  final _good = TextEditingController();
  final _total = TextEditingController();
  double? _result;
  String? _error;
  final _service = const NetworkingCalculatorService();

  @override
  void dispose() {
    _good.dispose();
    _total.dispose();
    super.dispose();
  }

  void _calculate() {
    final good = double.tryParse(_good.text);
    final total = double.tryParse(_total.text);
    if (good == null || total == null) {
      setState(() {
        _error = 'Enter goodput and total';
        _result = null;
      });
      return;
    }
    try {
      setState(() {
        _result = _service.throughput(good, total);
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _result = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Throughput Calculator')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(controller: _good, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Goodput (bits)')),
          const SizedBox(height: 12),
          TextField(controller: _total, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Total sent (bits)')),
          const SizedBox(height: 20),
          FilledButton(onPressed: _calculate, child: const Text('Calculate')),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
              ),
            ),
          ],
          if (_result != null)
            _resultSection(context, [
              ResultCard(label: 'Throughput ratio', value: '${(_result! * 100).toStringAsFixed(2)}%', icon: Icons.trending_up_outlined),
            ]),
        ],
      ),
    );
  }
}

class _LatencyCalc extends StatefulWidget {
  const _LatencyCalc();
  @override
  State<_LatencyCalc> createState() => _LatencyCalcState();
}

class _LatencyCalcState extends State<_LatencyCalc> {
  final _dist = TextEditingController();
  double? _result;
  String? _error;
  final _service = const NetworkingCalculatorService();

  @override
  void dispose() {
    _dist.dispose();
    super.dispose();
  }

  void _calculate() {
    final dist = double.tryParse(_dist.text);
    if (dist == null) {
      setState(() {
        _error = 'Enter distance';
        _result = null;
      });
      return;
    }
    setState(() {
      _result = _service.latency(dist);
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Latency Calculator')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(controller: _dist, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Distance (km)')),
          const SizedBox(height: 20),
          FilledButton(onPressed: _calculate, child: const Text('Calculate')),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
              ),
            ),
          ],
          if (_result != null)
            _resultSection(context, [
              ResultCard(label: 'Latency', value: '${(_result! * 1000).toStringAsFixed(3)} ms', icon: Icons.timer_outlined),
              ResultCard(label: 'Round-trip (RTT)', value: '${(_result! * 2000).toStringAsFixed(3)} ms', icon: Icons.sync_outlined),
            ]),
        ],
      ),
    );
  }
}
