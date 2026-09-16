// lib/widgets/charts/ranking_chart_widget.dart
import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

/// Widget de ranking horizontal (Top N)
class RankingChartWidget extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> data;
  final Color color;
  final String? subtitle;
  final double? height;
  final int? maxItems;

  const RankingChartWidget({
    Key? key,
    required this.title,
    required this.data,
    this.color = AppTheme.primary,
    this.subtitle,
    this.height = 400,
    this.maxItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _buildEmptyState();
    }

    final displayData = maxItems != null && data.length > maxItems!
        ? data.sublist(0, maxItems!)
        : data;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: displayData.length,
                itemBuilder: (context, index) {
                  return _buildRankingItem(index, displayData[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingItem(int index, Map<String, dynamic> item) {
    final label = item['label']?.toString() ?? item['name']?.toString() ?? 'N/A';
    final value = item['value'] ?? item['count'] ?? 0;
    final emoji = item['emoji']?.toString() ?? '';
    final maxValue = _getMaxValue();
    final percentage = maxValue > 0 ? (value / maxValue) : 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con ranking y label
          Row(
            children: [
              // Número de ranking
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  // _getRankColor ahora espera el puesto en base 1 (1º/2º/3º),
                  // no el índice base 0 de la lista — de ahí el +1.
                  color: _getRankColor(index + 1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Emoji (si existe)
              if (emoji.isNotEmpty) ...[
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 6),
              ],

              // Label
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Valor
              Text(
                value.toString(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Barra de progreso — Container + FractionallySizedBox en vez de
          // LinearProgressIndicator de Material, para consistencia visual
          // con el resto de gráficas fl_chart del dashboard.
          Container(
            height: 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: AppTheme.border,
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage.toDouble(),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: _getRankColor(index + 1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // rank en base 1 (1º, 2º, 3º...). Antes usaba Colors.amber/grey/brown
  // (medallas fuera de la paleta NOVA) — ahora usa tokens oficiales.
  // NOTA: el parámetro `color` del widget deja de usarse en el fallback;
  // ver reporte de la migración.
  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return AppTheme.primary; // oro → teal
      case 2:
        return AppTheme.textBody; // plata → gris
      case 3:
        return AppTheme.warning; // bronce → ámbar oficial
      default:
        return AppTheme.textMuted;
    }
  }

  double _getMaxValue() {
    if (data.isEmpty) return 0;
    double max = 0;
    for (var item in data) {
      final value = (item['value'] ?? item['count'] ?? 0).toDouble();
      if (value > max) max = value;
    }
    return max;
  }

  Widget _buildEmptyState() {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events,
              size: 48,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 8),
            Text(
              'No hay datos disponibles',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}