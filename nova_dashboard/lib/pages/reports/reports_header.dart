// lib/pages/reports/reports_header.dart
// Extraído de reports_page.dart (_buildHeader) sin cambios de
// comportamiento ni de estilo.
import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class ReportsHeader extends StatelessWidget {
  final int selectedDays;
  final List<int> daysOptions;
  final bool refreshing;
  final ValueChanged<int> onDaysChanged;
  final VoidCallback onRefresh;

  const ReportsHeader({
    super.key,
    required this.selectedDays,
    required this.daysOptions,
    required this.refreshing,
    required this.onDaysChanged,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
      child: Row(children: [
        Container(
          width: 3, height: 18,
          decoration: BoxDecoration(
            color: AppTheme.primary, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 10),
        const Text('Reportes',
            style: TextStyle(
                fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textHead)),
        const Spacer(),
        // Period selector
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.border),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: DropdownButton<int>(
            value: selectedDays,
            underline: const SizedBox(),
            isDense: true,
            style: const TextStyle(fontSize: 12, color: AppTheme.textBody),
            icon: const Icon(Icons.expand_more, size: 16, color: AppTheme.textMuted),
            items: daysOptions.map((d) => DropdownMenuItem<int>(
              value: d,
              child: Text(d == 0 ? 'Todo' : '$d días',
                  style: const TextStyle(fontSize: 12)),
            )).toList(),
            onChanged: (v) {
              if (v != null) onDaysChanged(v);
            },
          ),
        ),
        const SizedBox(width: 8),
        refreshing
            ? const Padding(
                padding: EdgeInsets.all(10),
                child: SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary)))
            : IconButton(
                icon: const Icon(Icons.refresh_rounded, size: 18, color: AppTheme.textMuted),
                tooltip: 'Actualizar',
                onPressed: onRefresh,
                padding: const EdgeInsets.all(6),
                constraints: const BoxConstraints(),
              ),
      ]),
    );
  }
}
