// lib/features/graph/presentation/screens/graph_screen.dart
// ignore_for_file: deprecated_member_use

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/math_engine.dart';

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  final TextEditingController _funcController =
      TextEditingController(text: 'sin(x)');
  final TextEditingController _func2Controller = TextEditingController();

  List<FlSpot> _spots1 = [];
  List<FlSpot> _spots2 = [];
  String _errorMsg = '';
  double _xMin = -10, _xMax = 10;
  bool _showGrid = true;
  bool _isRadians = true;
  bool _showSecondFunc = false;

  final _engine = MathEngine(isRadians: true);

  @override
  void initState() {
    super.initState();
    _plot();
  }

  void _plot() {
    setState(() {
      _spots1 = _generatePoints(_funcController.text);
      if (_showSecondFunc && _func2Controller.text.isNotEmpty) {
        _spots2 = _generatePoints(_func2Controller.text);
      }
      _errorMsg = '';
    });
  }

  List<FlSpot> _generatePoints(String func) {
    final points = <FlSpot>[];
    const steps = 500;
    final step = (_xMax - _xMin) / steps;
    final preparedFunc = func
        .replaceAll('x', '(__x__)')
        .replaceAll('π', '(${math.pi})')
        .replaceAll('e', '(${math.e})');

    for (int i = 0; i <= steps; i++) {
      final x = _xMin + i * step;
      final expr = preparedFunc.replaceAll('(__x__)', x.toString());
      try {
        final y = _engine.evaluate(expr);
        if (y != null && !y.isNaN && !y.isInfinite && y.abs() < 1e6) {
          points.add(FlSpot(x, y));
        }
      } catch (_) {}
    }
    return points;
  }

  @override
  void dispose() {
    _funcController.dispose();
    _func2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // ignore: unused_local_variable
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final subColor =
        isDark ? AppColors.textSecondary : AppColors.textDarkSecondary;
    final gridColor = isDark ? Colors.white12 : Colors.black12;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Graph Plotter',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        actions: [
          IconButton(
            icon: Icon(_showGrid ? Icons.grid_on : Icons.grid_off),
            onPressed: () => setState(() => _showGrid = !_showGrid),
          ),
          IconButton(
            icon: Text(
              _isRadians ? 'RAD' : 'DEG',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.accent,
              ),
            ),
            onPressed: () {
              setState(() {
                _isRadians = !_isRadians;
                _engine.isRadians = _isRadians;
                _plot();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Function input area
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildFuncInput(
                  controller: _funcController,
                  label: 'f(x) = ',
                  color: AppColors.graphLine,
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () =>
                      setState(() => _showSecondFunc = !_showSecondFunc),
                  child: Row(
                    children: [
                      Icon(
                        _showSecondFunc
                            ? Icons.remove_circle_outline
                            : Icons.add_circle_outline,
                        size: 18,
                        color: AppColors.accentSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _showSecondFunc
                            ? 'Remove second function'
                            : 'Add second function',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.accentSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_showSecondFunc) ...[
                  const SizedBox(height: 8),
                  _buildFuncInput(
                    controller: _func2Controller,
                    label: 'g(x) = ',
                    color: AppColors.accentSecondary,
                    isDark: isDark,
                  ),
                ],
                const SizedBox(height: 12),

                // X range
                Row(
                  children: [
                    Text('x range:',
                        style: TextStyle(color: subColor, fontSize: 13)),
                    const SizedBox(width: 8),
                    _buildRangeField('Min', _xMin, isDark, (v) {
                      if (v < _xMax) {
                        setState(() {
                          _xMin = v;
                          _plot();
                        });
                      }
                    }),
                    const SizedBox(width: 8),
                    _buildRangeField('Max', _xMax, isDark, (v) {
                      if (v > _xMin) {
                        setState(() {
                          _xMax = v;
                          _plot();
                        });
                      }
                    }),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: _plot,
                      icon: const Icon(Icons.show_chart, size: 16),
                      label: const Text('Plot'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),

                if (_errorMsg.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _errorMsg,
                      style:
                          const TextStyle(color: AppColors.error, fontSize: 13),
                    ),
                  ),
              ],
            ),
          ),

          // Chart
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 16, 16),
              child: _spots1.isEmpty
                  ? Center(
                      child: Text('No valid data to plot',
                          style: TextStyle(color: subColor)),
                    )
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: _showGrid,
                          drawVerticalLine: true,
                          getDrawingHorizontalLine: (v) => FlLine(
                            color:
                                v == 0 ? gridColor.withOpacity(3) : gridColor,
                            strokeWidth: v == 0 ? 1.5 : 0.5,
                          ),
                          getDrawingVerticalLine: (v) => FlLine(
                            color:
                                v == 0 ? gridColor.withOpacity(3) : gridColor,
                            strokeWidth: v == 0 ? 1.5 : 0.5,
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: gridColor),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (v, _) => Text(
                                _formatAxisLabel(v),
                                style: TextStyle(fontSize: 10, color: subColor),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 22,
                              getTitlesWidget: (v, _) => Text(
                                _formatAxisLabel(v),
                                style: TextStyle(fontSize: 10, color: subColor),
                              ),
                            ),
                          ),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _spots1,
                            isCurved: false,
                            color: AppColors.graphLine,
                            barWidth: 2,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppColors.graphLine.withOpacity(0.07),
                            ),
                          ),
                          if (_showSecondFunc && _spots2.isNotEmpty)
                            LineChartBarData(
                              spots: _spots2,
                              isCurved: false,
                              color: AppColors.accentSecondary,
                              barWidth: 2,
                              dotData: const FlDotData(show: false),
                            ),
                        ],
                        minX: _xMin,
                        maxX: _xMax,
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            tooltipBgColor: isDark
                                ? AppColors.darkCard
                                : AppColors.lightCard,
                            getTooltipItems: (spots) => spots
                                .map((s) => LineTooltipItem(
                                      'x=${_formatAxisLabel(s.x)}\ny=${_formatAxisLabel(s.y)}',
                                      TextStyle(
                                          color: s.bar.color, fontSize: 12),
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFuncInput({
    required TextEditingController controller,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 52,
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.textDark,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              hintText: 'e.g. sin(x) + cos(2*x)',
              hintStyle: TextStyle(
                color: isDark
                    ? AppColors.textSecondary
                    : AppColors.textDarkSecondary,
                fontSize: 14,
              ),
              filled: true,
              fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: color, width: 1.5),
              ),
            ),
            onSubmitted: (_) => _plot(),
          ),
        ),
      ],
    );
  }

  Widget _buildRangeField(
      String label, double value, bool isDark, Function(double) onChanged) {
    return SizedBox(
      width: 72,
      child: TextFormField(
        initialValue: value.toInt().toString(),
        keyboardType:
            const TextInputType.numberWithOptions(signed: true, decimal: true),
        style: TextStyle(
          color: isDark ? Colors.white : AppColors.textDark,
          fontSize: 13,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 11),
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          filled: true,
          fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        onFieldSubmitted: (v) {
          final parsed = double.tryParse(v);
          if (parsed != null) onChanged(parsed);
        },
      ),
    );
  }

  String _formatAxisLabel(double v) {
    if (v == v.truncateToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }
}
