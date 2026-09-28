import 'package:flutter/material.dart';

import '../../core/design/app_spacing.dart';
import '../../core/error/app_exception.dart';
import '../../domain/services/networking_calculator_service.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/calculator.dart';
import '../../widgets/cards.dart';
import '../../widgets/inputs.dart';
import '../../widgets/performance_watcher.dart';

/// Networking calculators: subnetting, CIDR, address ranges and data rates.
///
/// The two subnet tools take text rather than numbers, so they are bespoke
/// screens; the numeric ones use the shared [CalculatorField] pattern.
class NetworkingCalculatorScreen extends StatelessWidget {
  const NetworkingCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenPerformanceWatcher(
      name: 'Networking',
      child: AppScaffold(
        title: 'Networking',
        slivers: [
          const SliverToBoxAdapter(
            child: _Intro(
              text: 'Subnetting, address conversion and link maths. '
                  'Everything is computed on this device.',
            ),
          ),
          const SliverSectionHeader(title: 'Addressing'),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
              child: Column(
                children: [
                  AppListRow(
                    title: 'Subnet calculator',
                    subtitle: Text('Network, mask, hosts and broadcast'),
                    leading: const Icon(Icons.lan_outlined),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const _SubnetCalculatorScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppListRow(
                    title: 'Subnet splitter',
                    subtitle: Text('VLSM split of a block into equal subnets'),
                    leading: const Icon(Icons.call_split),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const _SubnetSplitScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppListRow(
                    title: 'Address converter',
                    subtitle: Text('IPv4 to binary, or CIDR to mask'),
                    leading: const Icon(Icons.swap_horiz),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const _AddressConverterScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverSectionHeader(title: 'Rates'),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
              child: Column(
                children: [
                  AppListRow(
                    title: 'Data rate converter',
                    subtitle: Text('bps through Tbps'),
                    leading: const Icon(Icons.speed),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const _DataRateScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppListRow(
                    title: 'Bandwidth and time',
                    subtitle: Text('Transfer time, throughput, latency, RTT'),
                    leading: const Icon(Icons.schedule),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const _BandwidthScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppListRow(
                    title: 'Channel capacity',
                    subtitle: Text('Nyquist rate, Shannon capacity, SNR'),
                    leading: const Icon(Icons.graphic_eq),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const _CapacityScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter, AppSpacing.sm, AppSpacing.gutter, 0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}

// --- Subnet ---------------------------------------------------------------

class _SubnetCalculatorScreen extends StatefulWidget {
  const _SubnetCalculatorScreen();

  @override
  State<_SubnetCalculatorScreen> createState() => _SubnetCalculatorScreenState();
}

class _SubnetCalculatorScreenState extends State<_SubnetCalculatorScreen> {
  final _ip = TextEditingController(text: '192.168.1.0');
  final _cidr = TextEditingController(text: '24');
  String _mask = '';
  SubnetInfo? _result;
  String? _error;

  @override
  void dispose() {
    _ip.dispose();
    _cidr.dispose();
    super.dispose();
  }

  void _calculate() {
    try {
      final info = NetworkingCalculatorService().calculateSubnet(
        _ip.text.trim(),
        cidr: int.tryParse(_cidr.text.trim()),
      );
      setState(() {
        _result = info;
        _mask = info.subnetMask.dotted;
        _error = null;
      });
    } on AppException catch (error) {
      setState(() {
        _error = error.message;
        _result = null;
      });
    } on Object catch (error) {
      setState(() {
        _error = 'Could not read that address: $error';
        _result = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenPerformanceWatcher(
      name: 'Subnet calculator',
      child: AppScaffold(
        title: 'Subnet calculator',
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.gutter),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const FormulaPanel(
                      formula: 'hosts = 2^(32−CIDR) − 2', label: 'Formula'),
                  const SizedBox(height: AppSpacing.lg),
                  TextField(
                    controller: _ip,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'IP address'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _cidr,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'CIDR prefix'),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton.icon(
                    onPressed: _calculate,
                    icon: const Icon(Icons.calculate_outlined),
                    label: const Text('Calculate'),
                  ),
                  if (_error != null) ErrorBanner(message: _error!),
                ],
              ),
            ),
          ),
          if (_result != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.gutter, AppSpacing.lg, AppSpacing.gutter, 0),
                child: Column(
                  children: [
                    ResultCard(label: 'Network address', value: _result!.networkAddress.dotted),
                    ResultCard(label: 'Subnet mask', value: _mask),
                    ResultCard(
                        label: 'First host',
                        value: _result!.firstHost.dotted),
                    ResultCard(
                        label: 'Broadcast address',
                        value: _result!.broadcastAddress.dotted),
                    ResultCard(
                        label: 'Last host', value: _result!.lastHost.dotted),
                    ResultCard(
                      label: 'Usable hosts',
                      value: '${_result!.usableHosts}',
                      icon: Icons.devices,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SubnetSplitScreen extends StatefulWidget {
  const _SubnetSplitScreen();

  @override
  State<_SubnetSplitScreen> createState() => _SubnetSplitScreenState();
}

class _SubnetSplitScreenState extends State<_SubnetSplitScreen> {
  final _ip = TextEditingController(text: '192.168.1.0');
  final _cidr = TextEditingController(text: '24');
  final _newCidr = TextEditingController(text: '26');
  List<SubnetInfo> _results = const [];
  String? _error;

  @override
  void dispose() {
    _ip.dispose();
    _cidr.dispose();
    _newCidr.dispose();
    super.dispose();
  }

  void _calculate() {
    try {
      final split = NetworkingCalculatorService().subnetSplit(
        _ip.text.trim(),
        int.parse(_cidr.text.trim()),
        int.parse(_newCidr.text.trim()),
      );
      setState(() {
        _results = split;
        _error = null;
      });
    } on Object catch (error) {
      setState(() {
        _error = 'Could not split that block: $error';
        _results = const [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenPerformanceWatcher(
      name: 'Subnet splitter',
      child: AppScaffold(
        title: 'Subnet splitter',
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.gutter),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const FormulaPanel(
                      formula: 'subnets = 2^(newCIDR − oldCIDR)',
                      label: 'Formula'),
                  const SizedBox(height: AppSpacing.lg),
                  TextField(
                    controller: _ip,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Network address'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _cidr,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Current CIDR'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: TextField(
                          controller: _newCidr,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'New CIDR'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton.icon(
                    onPressed: _calculate,
                    icon: const Icon(Icons.call_split),
                    label: const Text('Split'),
                  ),
                  if (_error != null) ErrorBanner(message: _error!),
                ],
              ),
            ),
          ),
          if (_results.isNotEmpty) ...[
            const SliverSectionHeader(
                title: 'Subnets', subtitle: 'Newest first'),
            LazySliverList(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final sub = _results[index];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.gutter, 0, AppSpacing.gutter, AppSpacing.sm),
                  child: Card(
                    key: ValueKey('${sub.networkAddress.dotted}/$index'),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 14,
                        child: Text('${index + 1}'),
                      ),
                      title: Text(sub.networkAddress.dotted),
                      subtitle: Text(
                          '${sub.firstHost.dotted} – ${sub.lastHost.dotted}\n'
                          '${sub.usableHosts} usable hosts'),
                      isThreeLine: true,
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _AddressConverterScreen extends StatefulWidget {
  const _AddressConverterScreen();

  @override
  State<_AddressConverterScreen> createState() =>
      _AddressConverterScreenState();
}

class _AddressConverterScreenState extends State<_AddressConverterScreen> {
  final _value = TextEditingController(text: '192.168.1.1');
  String? _output;
  String? _label;
  String? _error;

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  void _convert() {
    final raw = _value.text.trim();
    try {
      final service = NetworkingCalculatorService();
      if (raw.contains('/')) {
        final parts = raw.split('/');
        final mask = service.maskFromCidr(int.tryParse(parts.last) ?? 24);
        setState(() {
          _output = mask.dotted;
          _label = 'Subnet mask';
          _error = null;
        });
      } else if (raw.contains('.')) {
        setState(() {
          _output = service.ipToBinary(raw);
          _label = 'Binary';
          _error = null;
        });
      } else if (RegExp(r'^[01]{8,}(\\.[01]{8,})*\$').hasMatch(raw)) {
        setState(() {
          _output = service.binaryToIp(raw);
          _label = 'IPv4 address';
          _error = null;
        });
      } else {
        setState(() {
          _error = 'Enter an IPv4 address, a binary string, or CIDR like /24';
          _output = null;
        });
      }
    } on Object {
      setState(() {
        _error = 'Could not read that value';
        _output = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenPerformanceWatcher(
      name: 'Address converter',
      child: AppScaffold(
        title: 'Address converter',
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.gutter),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _value,
                    decoration: const InputDecoration(
                      labelText: 'IPv4, binary, or CIDR',
                      hintText: '192.168.1.1 or 11000000.10101000… or /24',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton.icon(
                    onPressed: _convert,
                    icon: const Icon(Icons.swap_horiz),
                    label: const Text('Convert'),
                  ),
                  if (_error != null) ErrorBanner(message: _error!),
                ],
              ),
            ),
          ),
          if (_output != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.gutter),
                child: ResultCard(
                  label: _label ?? 'Result',
                  value: _output!,
                  onCopy: () => copyToClipboard(context, _output!),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// --- Rates ----------------------------------------------------------------

class _DataRateScreen extends StatefulWidget {
  const _DataRateScreen();

  @override
  State<_DataRateScreen> createState() => _DataRateScreenState();
}

class _DataRateScreenState extends State<_DataRateScreen> {
  final _value = TextEditingController(text: '100');
  String _from = 'Mbps';
  String _to = 'Gbps';
  double? _result;
  String? _error;

  static const _units = ['bps', 'Kbps', 'Mbps', 'Gbps', 'Tbps', 'Bps', 'KB/s', 'MB/s', 'GB/s'];

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  void _convert() {
    final input = double.tryParse(_value.text.trim());
    if (input == null) {
      setState(() {
        _error = 'Enter a number';
        _result = null;
      });
      return;
    }
    setState(() {
      _result = NetworkingCalculatorService().convertDataRate(input, _from, _to);
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenPerformanceWatcher(
      name: 'Data rate converter',
      child: AppScaffold(
        title: 'Data rate',
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.gutter),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _value,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Value'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _from,
                          decoration: const InputDecoration(labelText: 'From'),
                          items: [
                            for (final unit in _units)
                              DropdownMenuItem(value: unit, child: Text(unit)),
                          ],
                          onChanged: (v) => setState(() => _from = v ?? _from),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _to,
                          decoration: const InputDecoration(labelText: 'To'),
                          items: [
                            for (final unit in _units)
                              DropdownMenuItem(value: unit, child: Text(unit)),
                          ],
                          onChanged: (v) => setState(() => _to = v ?? _to),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton.icon(
                    onPressed: _convert,
                    icon: const Icon(Icons.swap_horiz),
                    label: const Text('Convert'),
                  ),
                  if (_error != null) ErrorBanner(message: _error!),
                ],
              ),
            ),
          ),
          if (_result != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.gutter),
                child: ResultCard(
                  label: '$_from → $_to',
                  value: '${_result!.toStringAsFixed(4)} $_to',
                  icon: Icons.speed,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BandwidthScreen extends StatelessWidget {
  const _BandwidthScreen();

  @override
  Widget build(BuildContext context) {
    return const CalculatorScreen(
      title: 'Bandwidth and time',
      formula: 't = data / bandwidth',
      fields: [
        CalculatorField(label: 'Transfer size (Mb)'),
        CalculatorField(label: 'Bandwidth (Mbps)'),
      ],
      compute: _bandwidth,
    );
  }
}

List<CalculatorResult> _bandwidth(Map<String, double> input) {
  final time = NetworkingCalculatorService()
      .bandwidthTime(input['Transfer size (Mb)']!, input['Bandwidth (Mbps)']!);
  return [
    CalculatorResult(
      label: 'Transfer time',
      value: time < 1
          ? (time * 1000).toStringAsFixed(2)
          : time.toStringAsFixed(3),
      unit: time < 1 ? 'ms' : 's',
      icon: Icons.schedule,
      note: 'Excludes protocol overhead and latency.',
    ),
  ];
}

class _CapacityScreen extends StatelessWidget {
  const _CapacityScreen();

  @override
  Widget build(BuildContext context) {
    return const CalculatorScreen(
      title: 'Channel capacity',
      formula: 'C = B log₂(1 + SNR),  nyquist = 2B',
      fields: [
        CalculatorField(label: 'Bandwidth (Hz)'),
        CalculatorField(label: 'SNR (linear)'),
      ],
      compute: _capacity,
    );
  }
}

List<CalculatorResult> _capacity(Map<String, double> input) {
  final service = NetworkingCalculatorService();
  final bandwidth = input['Bandwidth (Hz)']!;
  final snr = input['SNR (linear)']!;
  if (snr <= 0) {
    throw const ValidationException('SNR must be greater than zero.');
  }
  return [
    CalculatorResult(
      label: 'Shannon capacity',
      value: service.shannonCapacity(bandwidth, snr).toStringAsFixed(2),
      unit: 'bps',
      icon: Icons.graphic_eq,
    ),
    CalculatorResult(
      label: 'Nyquist rate',
      value: service.nyquistRate(bandwidth).toStringAsFixed(2),
      unit: 'bps',
      icon: Icons.waves_outlined,
    ),
  ];
}
