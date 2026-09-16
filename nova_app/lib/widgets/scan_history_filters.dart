// lib/widgets/scan_history_filters.dart
// ============================================================
// FILTROS DEL HISTORIAL DE ESCANEOS — Nova App Móvil
// ============================================================
// FASE 1, PASO 1.2 del refactor de widgets. Widget standalone y
// reutilizable: campo de búsqueda por lugar + botón de limpiar
// filtros. Sin lógica de lista — scan_history_list.dart aún no filtra
// nada, esta funcionalidad no existía antes en el código (ni búsqueda
// ni filtros de historial); este widget queda listo para conectarse
// cuando se integre.
// ============================================================

import 'package:flutter/material.dart';
import '../core/design/app_colors.dart';
import '../core/design/app_spacing.dart';
import '../core/design/app_radius.dart';

class ScanHistoryFilters extends StatefulWidget {
  final void Function(String?) onSearchChange;
  final VoidCallback onReset;

  const ScanHistoryFilters({
    super.key,
    required this.onSearchChange,
    required this.onReset,
  });

  @override
  State<ScanHistoryFilters> createState() => _ScanHistoryFiltersState();
}

class _ScanHistoryFiltersState extends State<ScanHistoryFilters> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearchChanged(String value) {
    widget.onSearchChange(value.isEmpty ? null : value);
  }

  void _handleReset() {
    _searchController.clear();
    widget.onReset();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            onChanged: _handleSearchChanged,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Buscar por lugar...',
              hintStyle: const TextStyle(fontSize: 14, color: AppColors.textHint),
              prefixIcon: const Icon(Icons.search_rounded,
                  size: 20, color: AppColors.textHint),
              filled: true,
              fillColor: AppColors.surfaceVariant,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: AppRadius.mdAll,
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.mdAll,
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.mdAll,
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        IconButton(
          onPressed: _handleReset,
          icon: const Icon(Icons.filter_alt_off_rounded),
          color: AppColors.textSecondary,
          tooltip: 'Limpiar filtros',
        ),
      ],
    );
  }
}
