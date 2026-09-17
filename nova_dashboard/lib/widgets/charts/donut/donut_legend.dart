// lib/widgets/charts/donut/donut_legend.dart
// Extraído de donut_chart_widget.dart (_buildLegend) sin cambios de
// comportamiento ni de estilo.
import 'package:flutter/material.dart';
import 'donut_colors.dart';

class DonutLegend extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const DonutLegend({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: data.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final label = item['label']?.toString() ?? '';
          final value = item['value'] ?? 0;
          final color = item['color'] ?? donutColorForIndex(index);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  value.toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
