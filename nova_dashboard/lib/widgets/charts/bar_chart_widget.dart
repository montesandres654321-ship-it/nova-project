// lib/widgets/charts/bar_chart_widget.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BarChartWidget extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> data;
  final Color color;
  final String? subtitle;
  final double? height;
  final bool showValues;

  const BarChartWidget({
    Key? key,
    required this.title,
    required this.data,
    this.color = const Color(0xFF06B6A4),
    this.subtitle,
    this.height,
    this.showValues = false,
  }) : super(key: key);

  double get _maxVal {
    if (data.isEmpty) return 10;
    double m = 0;
    for (final d in data) {
      final v = (d['value'] ?? 0).toDouble();
      if (v > m) m = v;
    }
    return m > 0 ? m : 10;
  }

  double _computeMaxY() {
    final raw = _maxVal * 1.22;
    if (raw <= 5)   return (raw + 1).ceilToDouble();
    if (raw <= 20)  return (raw / 2).ceil() * 2.0;
    if (raw <= 100) return (raw / 5).ceil() * 5.0;
    if (raw <= 500) return (raw / 25).ceil() * 25.0;
    return (raw / 100).ceil() * 100.0;
  }

  double _computeInterval(double maxY) {
    if (maxY <= 5)   return 1;
    if (maxY <= 20)  return 5;
    if (maxY <= 50)  return 10;
    if (maxY <= 200) return 25;
    if (maxY <= 500) return 100;
    return (maxY / 5).ceilToDouble();
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return _emptyState();

    return LayoutBuilder(builder: (ctx, box) {
      final w = box.maxWidth.isFinite   ? box.maxWidth   : 600.0;
      final h = (height != null && !height!.isInfinite)
          ? height!
          : (box.maxHeight.isFinite ? box.maxHeight : 320.0);

      return _buildChart(w, h);
    });
  }

  Widget _buildChart(double containerW, double containerH) {
    final n      = data.length;
    const leftW  = 36.0;
    const rightP = 14.0;
    const topP   = 6.0;
    const bottomH = 46.0; // for 2-line labels

    // Scroll triggers when bars would shrink below 22px
    final minChartW = leftW + n * 54.0 + rightP;
    final needsScroll = minChartW > containerW;
    final chartW = needsScroll ? minChartW : containerW;

    // Bar width: proportional, clamped to [20, 52]
    final barW  = ((chartW - leftW - rightP) / (n * 2.1)).clamp(20.0, 52.0);

    final maxY       = _computeMaxY();
    final interval   = _computeInterval(maxY);
    final maxChars   = barW < 28 ? 5 : barW < 38 ? 8 : 12;

    Widget bars = SizedBox(
      width:  chartW,
      height: containerH,
      child: Padding(
        padding: EdgeInsets.fromLTRB(0, topP, rightP, 0),
        child: BarChart(BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: const Color(0xFF1E293B),
              tooltipRoundedRadius: 8,
              tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              getTooltipItem: (g, gi, rod, _) {
                if (gi >= data.length) return null;
                return BarTooltipItem(
                  '${data[gi]['label']}\n${rod.toY.toInt()}',
                  const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600,
                    fontSize: 11, height: 1.5),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: leftW,
                interval: interval,
                getTitlesWidget: (v, _) {
                  if (v == 0) return const SizedBox();
                  final s = v >= 1000
                      ? '${(v / 1000).toStringAsFixed(1)}k'
                      : v.toInt().toString();
                  return Text(s,
                      style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8)));
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: bottomH,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= data.length) return const SizedBox();
                  var l = data[i]['label']?.toString() ?? '';
                  if (l.length > maxChars) l = '${l.substring(0, maxChars - 1)}…';
                  return Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: SizedBox(
                      width: barW + 8,
                      child: Text(l,
                        style: TextStyle(
                          fontSize: barW < 28 ? 7.5 : 9.0,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: interval,
            getDrawingHorizontalLine: (_) =>
                const FlLine(color: Color(0xFFF1F5F9), strokeWidth: 1),
          ),
          borderData: FlBorderData(
            show: true,
            border: const Border(
              bottom: BorderSide(color: Color(0xFFE2E8F0)),
              left:   BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
          barGroups: data.asMap().entries.map((e) {
            final val = (e.value['value'] ?? 0).toDouble();
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: val,
                  width: barW,
                  borderRadius: const BorderRadius.only(
                    topLeft:  Radius.circular(5),
                    topRight: Radius.circular(5),
                  ),
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.5)],
                    begin: Alignment.topCenter,
                    end:   Alignment.bottomCenter,
                  ),
                ),
              ],
            );
          }).toList(),
        )),
      ),
    );

    Widget chartArea = needsScroll
        ? SingleChildScrollView(scrollDirection: Axis.horizontal, child: bars)
        : bars;

    if (height != null && !height!.isInfinite) {
      return SizedBox(height: height, child: chartArea);
    }
    return chartArea;
  }

  Widget _emptyState() => SizedBox(
    height: (height != null && !height!.isInfinite) ? height : 200,
    child: Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.bar_chart_rounded, size: 36, color: Colors.grey[300]),
        const SizedBox(height: 8),
        Text('Sin datos disponibles',
            style: TextStyle(color: Colors.grey[500], fontSize: 12)),
      ]),
    ),
  );
}
