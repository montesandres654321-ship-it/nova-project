// lib/widgets/scan_history_list.dart
// ============================================================
// LISTA DE ESCANEOS DEL HISTORIAL — Nova App Móvil
// ============================================================
// FASE 1, PASO 1.4 del refactor de widgets: dividido en
// ScanHistoryCard, ScanHistoryFilters y ScanHistoryEmptyState.
// Ahora es StatefulWidget porque mantiene el estado local del filtro
// de búsqueda (antes era StatelessWidget puro).
//
// CAMBIO DE COMPORTAMIENTO EXPLÍCITO (pedido en el PASO 1.4): la
// lista ya no agrupa los escaneos por fecha (Hoy/Ayer/Esta semana/...)
// — ahora es un ListView plano de ScanHistoryCard. Si se quiere
// recuperar el agrupado, avisar para revertir esta parte.
//
// `onScanTap` es opcional y nuevo: no existe pantalla de detalle de
// escaneo en la app, así que si no se provee, el tap no hace nada.
// history_page.dart no lo pasa todavía (no se modificó su llamada).
// ============================================================

import 'package:flutter/material.dart';
import '../models/scan_record.dart';
import '../pages/places_page.dart';
import '../core/design/app_colors.dart';
import '../core/design/app_spacing.dart';
import '../core/design/app_radius.dart';
import 'history_empty_state.dart';
import 'scan_history_card.dart';
import 'scan_history_filters.dart';
import 'scan_history_empty_state.dart';

class ScanHistoryList extends StatefulWidget {
  final bool loading;
  final String error;
  final List<ScanRecord> records;
  final Future<void> Function() onRefresh;
  final void Function(ScanRecord)? onScanTap;

  const ScanHistoryList({
    super.key,
    required this.loading,
    required this.error,
    required this.records,
    required this.onRefresh,
    this.onScanTap,
  });

  @override
  State<ScanHistoryList> createState() => _ScanHistoryListState();
}

class _ScanHistoryListState extends State<ScanHistoryList> {
  String? _searchQuery;

  List<ScanRecord> get _filteredRecords {
    final query = _searchQuery?.trim().toLowerCase();
    if (query == null || query.isEmpty) return widget.records;
    return widget.records
        .where((r) =>
            r.local.toLowerCase().contains(query) ||
            r.place.toLowerCase().contains(query))
        .toList();
  }

  void _handleSearchChange(String? value) {
    setState(() => _searchQuery = value);
  }

  void _handleReset() {
    setState(() => _searchQuery = null);
  }

  void _handleExplore() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PlacesPage()),
    );
  }

  // ── Build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (widget.loading) return _buildLoadingState();

    if (widget.records.isEmpty) {
      if (widget.error == 'No hay escaneos registrados') {
        return ScanHistoryEmptyState(onExplore: _handleExplore);
      }
      return _buildErrorState();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.xs,
          ),
          child: ScanHistoryFilters(
            onSearchChange: _handleSearchChange,
            onReset: _handleReset,
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: widget.onRefresh,
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                0,
                AppSpacing.xs,
                0,
                AppSpacing.xl,
              ),
              itemCount: _filteredRecords.length,
              itemBuilder: (_, i) {
                final scan = _filteredRecords[i];
                return ScanHistoryCard(
                  scan: scan,
                  onTap: () => widget.onScanTap?.call(scan),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // ── Estados (sin cambios respecto al original) ──────────────

  Widget _buildLoadingState() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(
        top: AppSpacing.sm,
        bottom: AppSpacing.xl,
      ),
      itemCount: 5,
      itemBuilder: (_, __) => _buildSkeletonItem(),
    );
  }

  Widget _buildSkeletonItem() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _shimmerBox(48, 48, radius: AppRadius.sm),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerWide(13),
                const SizedBox(height: 6),
                _shimmerBox(10, 110),
                const SizedBox(height: 6),
                _shimmerBox(10, 72),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _shimmerBox(10, 50),
        ],
      ),
    );
  }

  Widget _shimmerBox(double height, double width, {double radius = AppRadius.sm}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _shimmerWide(double height) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
    );
  }

  Widget _buildErrorState() {
    return HistoryEmptyState(
      icon: Icons.cloud_off_rounded,
      iconColor: AppColors.error,
      iconBackgroundColor: AppColors.error.withValues(alpha: 0.08),
      title: 'No se pudo cargar el historial',
      message: widget.error,
      messageStyle: const TextStyle(
        fontSize: 13,
        color: AppColors.textSecondary,
        height: 1.4,
      ),
      messageMaxLines: 3,
      onRetry: widget.onRefresh,
    );
  }
}
