// lib/pages/reports/reports_charts.dart
// Extraído de reports_page.dart (_buildScansCard/_buildRankingCard/
// _chartCard/_periodChip/_emptyChart) sin cambios de comportamiento ni de
// estilo.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/app_theme.dart';
import '../../widgets/charts/bar_chart_widget.dart';
import '../../widgets/charts/line_chart_widget.dart';

Widget reportsScansCard({
  required List<Map<String, dynamic>> scansByDay,
  required String periodLabel,
}) {
  final chartData = scansByDay.map((item) {
    final ds = item['date']?.toString() ?? '';
    String l = ds;
    try { l = DateFormat('d MMM', 'es').format(DateTime.parse(ds)); } catch (_) {}
    return {'label': l, 'value': item['count'] ?? 0};
  }).toList();

  return reportsChartCard(
    title: 'Actividad de Escaneos',
    trailing: reportsPeriodChip(periodLabel),
    child: chartData.isEmpty
        ? reportsEmptyChart(Icons.show_chart_rounded, 'Sin datos en este período')
        : LineChartWidget(
            title: '',
            data: chartData,
            color: AppTheme.primary,
            fillArea: true,
            height: double.infinity,
          ),
  );
}

Widget reportsRankingCard(List<Map<String, dynamic>> topPlaces) {
  if (topPlaces.isEmpty) {
    return reportsChartCard(
      title: 'Top Establecimientos',
      trailing: reportsPeriodChip('por escaneos'),
      child: reportsEmptyChart(Icons.bar_chart_rounded, 'Sin datos de lugares'),
    );
  }

  final cd = topPlaces.map((p) => {
    'label': p['name']?.toString() ?? '',
    'value': p['totalScans'] ?? p['total_scans'] ?? 0,
  }).toList();

  return reportsChartCard(
    title: 'Top Establecimientos',
    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
      reportsPeriodChip('por escaneos'),
      const SizedBox(width: 6),
      if (cd.length > 7)
        reportsPeriodChip('← scroll →', subtle: true),
    ]),
    child: BarChartWidget(
      title: '',
      data: cd,
      color: AppTheme.primary,
      showValues: true,
    ),
  );
}

Widget reportsChartCard({
  required String title,
  required Widget child,
  Widget? trailing,
}) {
  return Container(
    decoration: AppTheme.cardDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
          child: Row(children: [
            Container(
                width: 3, height: 16,
                decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: AppTheme.space8),
            Text(title,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700,
                    color: AppTheme.textHead)),
            const Spacer(),
            if (trailing != null) trailing,
          ]),
        ),
        // Divisor: nova-design reserva AppTheme.border para inputs y
        // divisores — antes usaba un gris suelto (#F1F5F9).
        const Divider(height: 1, color: AppTheme.border),
        // Chart area
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
            child: child,
          ),
        ),
      ],
    ),
  );
}

Widget reportsPeriodChip(String text, {bool subtle = false}) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
  decoration: BoxDecoration(
    color: subtle
        ? AppTheme.bgPage
        : AppTheme.primary.withOpacity(0.06),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: subtle
          ? AppTheme.border
          : AppTheme.primary.withOpacity(0.15),
    ),
  ),
  child: Text(text,
      style: TextStyle(
          fontSize: 9,
          color: subtle ? AppTheme.textMuted : AppTheme.textBody,
          fontWeight: FontWeight.w500)),
);

Widget reportsEmptyChart(IconData icon, String text) => Center(
  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(icon, size: 36, color: AppTheme.textMuted),
    const SizedBox(height: 10),
    Text(text, style: AppTheme.textCaption),
  ]),
);
