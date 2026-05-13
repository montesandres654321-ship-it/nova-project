// lib/widgets/charts/line_chart_widget.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class LineChartWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Map<String, dynamic>> data;
  final Color? color;
  final double height;
  final bool fillArea;

  const LineChartWidget({
    Key? key,
    required this.title,
    this.subtitle,
    required this.data,
    this.color,
    this.height = 300,
    this.fillArea = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return _emptyState();

    final useFixed = !height.isInfinite;
    final effectiveColor = color ?? const Color(0xFF06B6A4);

    final maxY       = _computeMaxY();
    final yInterval  = _computeYInterval(maxY);
    final xInterval  = data.length > 20 ? 4.0 : data.length > 10 ? 2.0 : 1.0;

    Widget chart = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Text(title,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
          if (subtitle != null) ...[
            const SizedBox(height: 3),
            Text(subtitle!,
                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
          ],
          const SizedBox(height: 12),
        ],
        Expanded(
          child: LineChart(LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: yInterval,
              getDrawingHorizontalLine: (_) =>
                  const FlLine(color: Color(0xFFF1F5F9), strokeWidth: 1),
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 34,
                  interval: yInterval,
                  getTitlesWidget: (v, _) {
                    if (v == 0) return const SizedBox();
                    final s = v >= 1000
                        ? '${(v / 1000).toStringAsFixed(1)}k'
                        : v.toInt().toString();
                    return Text(s,
                        style: const TextStyle(
                            fontSize: 9, color: Color(0xFF94A3B8)));
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 26,
                  interval: xInterval,
                  getTitlesWidget: (v, _) {
                    final i = v.toInt();
                    if (i < 0 || i >= data.length) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        data[i]['label']?.toString() ?? '',
                        style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8)),
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: const Border(
                bottom: BorderSide(color: Color(0xFFE2E8F0)),
                left:   BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
            minX: 0,
            maxX: (data.length - 1).toDouble(),
            minY: 0,
            maxY: maxY,
            lineBarsData: [
              LineChartBarData(
                spots: _getSpots(),
                isCurved: true,
                curveSmoothness: 0.35,
                color: effectiveColor,
                barWidth: 2.5,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: data.length <= 20,
                  getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                    radius: 3.5,
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeColor: effectiveColor,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: fillArea,
                  gradient: LinearGradient(
                    colors: [
                      effectiveColor.withOpacity(0.18),
                      effectiveColor.withOpacity(0.01),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                tooltipBgColor: const Color(0xFF1E293B),
                tooltipRoundedRadius: 8,
                tooltipPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                getTooltipItems: (spots) => spots.map((spot) {
                  final i = spot.x.toInt();
                  if (i < 0 || i >= data.length) return null;
                  return LineTooltipItem(
                    '${data[i]['label']}\n${spot.y.toInt()}',
                    const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                        height: 1.5),
                  );
                }).toList(),
              ),
            ),
          )),
        ),
      ],
    );

    final dec = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
            color: Colors.grey.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 2)),
      ],
    );

    if (useFixed) {
      return Container(height: height, padding: const EdgeInsets.all(14), decoration: dec, child: chart);
    }
    return Container(padding: const EdgeInsets.all(14), decoration: dec, child: chart);
  }

  List<FlSpot> _getSpots() => List.generate(data.length, (i) {
        final v = data[i]['value'];
        return FlSpot(i.toDouble(),
            v is num ? v.toDouble() : 0.0);
      });

  double _computeMaxY() {
    if (data.isEmpty) return 5;
    double maxV = 0;
    for (final d in data) {
      final v = d['value'];
      final dv = v is num ? v.toDouble() : 0.0;
      if (dv > maxV) maxV = dv;
    }
    if (maxV == 0) return 5;
    final raw = maxV * 1.28;
    if (raw <= 5)   return (raw + 1).ceilToDouble();
    if (raw <= 20)  return (raw / 2).ceil() * 2.0;
    if (raw <= 100) return (raw / 5).ceil() * 5.0;
    if (raw <= 500) return (raw / 25).ceil() * 25.0;
    return (raw / 100).ceil() * 100.0;
  }

  double _computeYInterval(double maxY) {
    if (maxY <= 5)   return 1;
    if (maxY <= 20)  return 5;
    if (maxY <= 100) return 10;
    if (maxY <= 500) return 50;
    return (maxY / 5).ceilToDouble();
  }

  Widget _emptyState() => Container(
        height: height.isInfinite ? null : height,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.07),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.show_chart_rounded, size: 36, color: Colors.grey[300]),
            const SizedBox(height: 10),
            Text('Sin datos de actividad',
                style: TextStyle(fontSize: 12, color: Colors.grey[400])),
          ]),
        ),
      );
}
