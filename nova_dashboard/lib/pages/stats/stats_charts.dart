// lib/pages/stats/stats_charts.dart
// Extraído de stats_dashboard_page.dart (_buildChartContainer y las 5
// gráficas) sin cambios de comportamiento ni de estilo.
import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../widgets/charts/bar_chart_widget.dart';
import '../../widgets/charts/donut_chart_widget.dart';
import '../../widgets/charts/line_chart_widget.dart';

Widget statsEmptyState() {
  return const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.bar_chart_rounded, size: 32, color: AppTheme.textMuted),
        SizedBox(height: 6),
        Text('Sin datos disponibles', style: AppTheme.textCaption),
      ],
    ),
  );
}

Widget statsChartContainer({
  required String title,
  required String subtitle,
  required Color accentColor,
  required Widget chart,
}) {
  // Única capa de decoración de la gráfica: LineChartWidget y BarChartWidget
  // ya no se auto-decoran (Lote 3). DonutChartWidget todavía se auto-decora
  // (fuera del alcance de este refactor) — "Distribución por Tipo" sigue con
  // doble tarjeta hasta un próximo lote.
  return Container(
    decoration: AppTheme.cardDecoration(),
    padding: const EdgeInsets.all(14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(
            width: 4, height: 18,
            decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: AppTheme.space8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 13,
                        fontWeight: FontWeight.w600),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(subtitle,
                    style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ]),
        const SizedBox(height: 10),
        Expanded(child: chart),
      ],
    ),
  );
}

String formatStatsDate(String dateStr) {
  try {
    final d = DateTime.parse(dateStr);
    return '${d.day} ${_monthShort(d.month)}';
  } catch (_) {
    return dateStr;
  }
}

String _monthShort(int m) {
  const months = [
    '', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
  ];
  return m >= 1 && m <= 12 ? months[m] : '';
}

class ScansByDayChart extends StatelessWidget {
  final List<Map<String, dynamic>> scansByDay;
  final int selectedDays;
  const ScansByDayChart({
    super.key, required this.scansByDay, required this.selectedDays,
  });

  @override
  Widget build(BuildContext context) {
    final data = scansByDay.map((e) => <String, dynamic>{
      'label': formatStatsDate(e['date']?.toString() ?? ''),
      'value': e['count'] ?? 0,
    }).toList();

    return statsChartContainer(
      title: 'Actividad de Escaneos',
      subtitle: selectedDays == 0
          ? 'Todo el historial'
          : 'Últimos $selectedDays días',
      accentColor: AppTheme.primary,
      chart: data.isEmpty
          ? statsEmptyState()
          : LayoutBuilder(builder: (ctx, c) {
              final h = c.maxHeight.isInfinite ? 160.0 : c.maxHeight;
              return LineChartWidget(
                title: '', data: data,
                color: AppTheme.primary,
                fillArea: true,
                height: h,
              );
            }),
    );
  }
}

class TopPlacesChart extends StatelessWidget {
  final List<Map<String, dynamic>> topPlaces;
  const TopPlacesChart({super.key, required this.topPlaces});

  @override
  Widget build(BuildContext context) {
    final data = topPlaces.map((p) => <String, dynamic>{
      'label': () {
        final n = (p['name'] ?? '').toString();
        return n.length > 12 ? '${n.substring(0, 12)}…' : n;
      }(),
      'value': p['total_scans'] ?? 0,
    }).toList();

    return statsChartContainer(
      title: 'Top Establecimientos',
      subtitle: 'Por número de escaneos',
      accentColor: AppTheme.warning,
      chart: data.isEmpty
          ? statsEmptyState()
          : LayoutBuilder(builder: (ctx, c) {
              final h = c.maxHeight.isInfinite ? 160.0 : c.maxHeight;
              return BarChartWidget(
                title: '', data: data,
                color: AppTheme.warning,
                height: h,
                showValues: true,
              );
            }),
    );
  }
}

class ScansByHourChart extends StatelessWidget {
  final List<Map<String, dynamic>> scansByHour;
  const ScansByHourChart({super.key, required this.scansByHour});

  @override
  Widget build(BuildContext context) {
    final Map<int, int> hourMap = {};
    for (final e in scansByHour) {
      final h = (e['hour'] as num?)?.toInt() ?? 0;
      hourMap[h] = (e['count'] as num?)?.toInt() ?? 0;
    }
    final List<Map<String, dynamic>> data = List.generate(24, (h) => {
      'label': '${h.toString().padLeft(2, '0')}h',
      'value': hourMap[h] ?? 0,
    });

    return statsChartContainer(
      title: 'Horario Pico',
      subtitle: 'Escaneos por hora del día',
      accentColor: AppTheme.info,
      chart: data.every((e) => (e['value'] as int) == 0)
          ? statsEmptyState()
          : LayoutBuilder(builder: (ctx, c) {
              final h = c.maxHeight.isInfinite ? 160.0 : c.maxHeight;
              return BarChartWidget(
                title: '', data: data,
                color: AppTheme.info,
                height: h,
                showValues: false,
              );
            }),
    );
  }
}

class PlacesByTypeChart extends StatelessWidget {
  final Map<String, dynamic> placesByType;
  const PlacesByTypeChart({super.key, required this.placesByType});

  @override
  Widget build(BuildContext context) {
    final hotel = (placesByType['hotel']      as num?)?.toInt() ?? 0;
    final rest  = (placesByType['restaurant'] as num?)?.toInt() ?? 0;
    final bar   = (placesByType['bar']        as num?)?.toInt() ?? 0;
    final total = hotel + rest + bar;

    final List<Map<String, dynamic>> chartData = [
      {'label': 'Hoteles',      'value': hotel, 'color': AppTheme.info},
      {'label': 'Restaurantes', 'value': rest,  'color': AppTheme.success},
      {'label': 'Bares',        'value': bar,   'color': AppTheme.warning},
    ].where((e) => (e['value'] as int) > 0).toList();

    return statsChartContainer(
      title: 'Distribución por Tipo',
      subtitle: 'Establecimientos registrados',
      accentColor: AppTheme.success,
      chart: total == 0
          ? statsEmptyState()
          : LayoutBuilder(builder: (ctx, c) {
              final h = c.maxHeight.isInfinite ? 160.0 : c.maxHeight;
              return DonutChartWidget(
                title: '', subtitle: '',
                data: chartData,
                height: h,
                showLegend: true,
              );
            }),
    );
  }
}

class RewardsByDayChart extends StatelessWidget {
  final List<Map<String, dynamic>> rewardsByDay;
  final int selectedDays;
  const RewardsByDayChart({
    super.key, required this.rewardsByDay, required this.selectedDays,
  });

  @override
  Widget build(BuildContext context) {
    final data = rewardsByDay.map((e) => <String, dynamic>{
      'label': formatStatsDate(e['date']?.toString() ?? ''),
      'value': e['count'] ?? 0,
    }).toList();

    return statsChartContainer(
      title: 'Recompensas por Día',
      subtitle: selectedDays == 0
          ? 'Todo el historial'
          : 'Últimos $selectedDays días',
      accentColor: AppTheme.primaryDark,
      chart: data.isEmpty
          ? statsEmptyState()
          : LayoutBuilder(builder: (ctx, c) {
              final h = c.maxHeight.isInfinite ? 160.0 : c.maxHeight;
              return LineChartWidget(
                title: '', data: data,
                color: AppTheme.primaryDark,
                fillArea: true,
                height: h,
              );
            }),
    );
  }
}
