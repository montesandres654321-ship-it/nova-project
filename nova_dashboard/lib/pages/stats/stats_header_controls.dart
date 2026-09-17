// lib/pages/stats/stats_header_controls.dart
// Extraído de stats_dashboard_page.dart (_PeriodDropdown/_DashIconButton)
// sin cambios de comportamiento ni de estilo.
import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class PeriodDropdown extends StatelessWidget {
  final int value;
  final List<int> options;
  final ValueChanged<int?> onChanged;

  const PeriodDropdown({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppTheme.border),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<int>(
        value: value,
        isDense: true,
        icon: const Icon(Icons.expand_more_rounded, size: 15, color: AppTheme.textMuted),
        style: const TextStyle(fontSize: 12, color: AppTheme.textHead),
        items: options.map((d) => DropdownMenuItem(
          value: d,
          child: Text(
            d == 0 ? 'Todo' : 'Últ. $d días',
            style: const TextStyle(fontSize: 12),
          ),
        )).toList(),
        onChanged: onChanged,
      ),
    ),
  );
}

class DashIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const DashIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.space8),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.border),
        ),
        child: Icon(icon, size: 16, color: AppTheme.textMuted),
      ),
    ),
  );
}
