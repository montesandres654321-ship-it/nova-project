// lib/pages/owners/dashboard/owner_dashboard_charts.dart
// Extraído de owners/dashboard_page.dart (_lineChart/_barChart/_donutChart/
// _emptyBox) sin cambios de comportamiento ni de estilo.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../utils/app_theme.dart';
import '../../../widgets/charts/bar_chart_widget.dart';
import '../../../widgets/charts/donut_chart_widget.dart';
import '../../../widgets/charts/line_chart_widget.dart';

Widget ownerEmptyBox(IconData icon, String msg) => Container(
    decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.06), blurRadius: 6)]),
    child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, size: 28, color: AppTheme.textMuted), const SizedBox(height: AppTheme.space4),
      Text(msg, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted))])));

List<Map<String, dynamic>> _labeledScansByDay(List<Map<String, dynamic>> scansByDay) {
  return scansByDay.map((i) {
    String l = i['date']?.toString() ?? '';
    try { l = DateFormat('d MMM', 'es').format(DateTime.parse(l)); } catch (_) {}
    return {'label': l, 'value': i['count'] ?? 0};
  }).toList();
}

Widget ownerLineChart(List<Map<String, dynamic>> scansByDay) {
  if (scansByDay.isEmpty) return ownerEmptyBox(Icons.show_chart, 'Sin actividad aún');
  return LineChartWidget(
      title: 'Visitas por Día', data: _labeledScansByDay(scansByDay),
      color: AppTheme.primary, height: double.infinity, fillArea: true);
}

Widget ownerBarChart(List<Map<String, dynamic>> scansByDay) {
  if (scansByDay.isEmpty) return ownerEmptyBox(Icons.bar_chart_rounded, 'Sin datos');
  return BarChartWidget(
      title: 'Escaneos por Día', data: _labeledScansByDay(scansByDay),
      color: AppTheme.primary, height: double.infinity, showValues: true);
}

Widget ownerDonutChart({required int rewards, required int redeemed}) {
  if (rewards == 0) return ownerEmptyBox(Icons.donut_large, 'Sin recompensas');
  return DonutChartWidget(title: 'Recompensas', subtitle: '', data: [
    {'label': 'Canjeadas', 'value': redeemed, 'color': AppTheme.success},
    {'label': 'Pendientes', 'value': rewards - redeemed, 'color': AppTheme.warning},
  ], height: double.infinity, showLegend: true);
}
