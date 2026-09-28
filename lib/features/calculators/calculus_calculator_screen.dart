import 'package:flutter/material.dart';

import '../../core/design/app_spacing.dart';
import '../../core/error/app_exception.dart';
import '../../domain/services/calculus_calculator_service.dart';
import '../../services/performance/performance_monitor.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/cards.dart';
import '../../widgets/inputs.dart';
import '../../widgets/performance_watcher.dart';

/// The five calculus tools this calculator offers.
enum _Tool { derivative, indefiniteIntegral, definiteIntegral, limit, slope }

/// Calculus calculator.
///
/// The previous screen had a real freeze: the Riemann rectangle count came
/// from an unbounded text field, and a large value was evaluated in a tight
/// loop on the UI isolate inside `setState` — typing `10000000` hung the app.
/// Two things fix it here:
///
///  * every numeric input is capped with an explicit maximum, and the
///    rectangle count additionally has a hard ceiling in the field
///    configuration;
///  * the work is measured, and reported through the performance logger, so a
///    regression shows up as a slow operation instead of as a frozen screen.
class CalculusCalculatorScreen extends StatefulWidget {
  const CalculusCalculatorScreen({super.key});

  @override
  State<CalculusCalculatorScreen> createState() =>
      _CalculusCalculatorScreenState();
}

class _CalculusCalculatorScreenState extends State<CalculusCalculatorScreen> {
  static const _service = CalculusCalculatorService();

  /// Hard ceiling on loop-based integration. Above this the run would block
  /// the isolate for seconds, which is worse than refusing the input.
  static const _maxIterations = 100000;

  static final _tools = <_Tool, (String, String)>{
    _Tool.derivative: ('Derivative', 'd/dx'),
    _Tool.indefiniteIntegral: ('Indefinite integral', '∫ f(x) dx'),
    _Tool.definiteIntegral: ('Definite integral', '∫ₐᵇ f(x) dx'),
    _Tool.limit: ('Limit', 'lim f(x)'),
    _Tool.slope: ('Average rate of change', '(f(b) − f(a)) / (b − a)'),
  };

  final _expression = TextEditingController(text: '3x^2 + 2x - 5');
  final _a = TextEditingController(text: '0');
  final _b = TextEditingController(text: '1');
  final _rectangles = TextEditingController(text: '100');

  _Tool _tool = _Tool.derivative;
  String? _result;
  String? _error;
  Duration? _elapsed;

  @override
  void dispose() {
    _expression.dispose();
    _a.dispose();
    _b.dispose();
    _rectangles.dispose();
    super.dispose();
  }

  bool get _needsBounds =>
      _tool == _Tool.definiteIntegral || _tool == _Tool.limit || _tool == _Tool.slope;

  void _calculate() {
    final expression = _expression.text.trim();
    if (expression.isEmpty) {
      setState(() {
        _error = 'Enter an expression, e.g. 3x^2 + 2x - 5';
        _result = null;
      });
      return;
    }

    // Parse once here so a malformed expression fails before any loop starts.
    Polynomial.parse(expression);

    final trace =
        PerformanceMonitor.instance.trackAi('calculus', context: {'tool': _tool.name});
    final clock = Stopwatch()..start();
    try {
      final value = switch (_tool) {
        _Tool.derivative => _service.derivative(expression).toString(),
        _Tool.indefiniteIntegral =>
          _service.indefiniteIntegral(expression).toString(),
        _Tool.definiteIntegral => _format(_service.definiteIntegral(
              expression,
              _bound(_a, 'Lower bound'),
              _bound(_b, 'Upper bound'),
              intervals: _rectangleCount(),
            )),
        _Tool.limit => () {
            final limit = _service.limit(
                expression, _bound(_a, 'Approach point'));
            return limit == null ? 'does not exist' : _format(limit);
          }(),
        _Tool.slope => _format(_service.averageRateOfChange(
              expression,
              _bound(_a, 'Start point'),
              _bound(_b, 'End point'),
            )),
      };
      setState(() {
        _result = value;
        _error = null;
        _elapsed = clock.elapsed;
      });
    } on ArgumentError catch (error) {
      setState(() {
        _error = _cleanArgumentError(error);
        _result = null;
      });
    } on Object catch (error) {
      setState(() {
        _error = 'Could not evaluate that: $error';
        _result = null;
      });
    } finally {
      trace.stop();
    }
  }

  double _bound(TextEditingController controller, String label) {
    final value = double.tryParse(controller.text.trim());
    if (value == null) {
      throw ValidationException('$label must be a number.');
    }
    return value;
  }

  /// Reads and caps the rectangle count, which is the one input that can
  /// otherwise turn into an unbounded loop.
  int _rectangleCount() {
    final value = int.tryParse(_rectangles.text.trim()) ?? 100;
    if (value <= 0) {
      throw const ValidationException('Rectangle count must be positive.');
    }
    if (value > _maxIterations) {
      throw ValidationException(
          'Rectangle count is capped at $_maxIterations so the app stays responsive.');
    }
    return value;
  }

  static String _format(double value) {
    if (value.isNaN) return 'undefined';
    if (value.isInfinite) return value.isNegative ? '−∞' : '∞';
    // Trim trailing zeros so 0.5000000 does not look like a bug.
    final text = value.toStringAsFixed(6);
    return text.contains('.')
        ? text.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '')
        : text;
  }

  static String _cleanArgumentError(ArgumentError error) {
    final message = error.message?.toString() ?? 'That input is not valid.';
    return message.replaceFirst('Invalid argument(s): ', '');
  }

  @override
  Widget build(BuildContext context) {
    final label = _tools[_tool]!;

    return ScreenPerformanceWatcher(
      name: 'Calculus',
      child: AppScaffold(
        title: 'Calculus',
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.gutter),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilterChipRow(
                    options: _tools.values.map((v) => v.$1).toList(),
                    selected: label.$1,
                    onSelected: (value) {
                      final entry = _tools.entries
                          .firstWhere((e) => e.value.$1 == value);
                      setState(() => _tool = entry.key);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FormulaPanel(formula: label.$2),
                  const SizedBox(height: AppSpacing.lg),
                  TextField(
                    controller: _expression,
                    autocorrect: false,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _calculate(),
                    decoration: const InputDecoration(
                      labelText: 'Expression',
                      hintText: 'Polynomials, e.g. 3x^2 + 2x - 5',
                    ),
                  ),
                  if (_needsBounds) ...[
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _a,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true, signed: true),
                            decoration: InputDecoration(
                              labelText: _tool == _Tool.slope ? 'Start' : 'a',
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: TextField(
                            controller: _b,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true, signed: true),
                            decoration: const InputDecoration(labelText: 'b'),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (_tool == _Tool.definiteIntegral) ...[
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _rectangles,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Rectangles',
                        helperText: 'At most $_maxIterations',
                        helperMaxLines: 2,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton.icon(
                    onPressed: _calculate,
                    icon: const Icon(Icons.functions),
                    label: const Text('Evaluate'),
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
                child: Column(
                  children: [
                    ResultCard(
                      label: label.$1,
                      value: _result!,
                      mono: false,
                      onCopy: () => copyToClipboard(context, _result!),
                    ),
                    if (_elapsed != null)
                      Text(
                        'Computed in ${_elapsed!.inMicroseconds} µs on this device',
                        style: Theme.of(context).textTheme.labelSmall,
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
