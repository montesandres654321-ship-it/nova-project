// lib/widgets/stats_card.dart
// ============================================================
// ÚLTIMO ESCANEO / ESTADÍSTICA DE VISITAS — Nova App Móvil
// ============================================================
// Extraído de home_page.dart (FASE 3, PASO 3.2 del refactor).
// El plan describía "3 cards de estadísticas" (lugares visitados,
// recompensas, etc.), pero esa funcionalidad no existe en el código
// real. Lo que existe es esta sección: el último escaneo registrado
// junto con el contador total de escaneos — se reproduce tal cual,
// sin inventar estadísticas adicionales.
// ============================================================

import 'package:flutter/material.dart';
import '../models/scan_record.dart';
import '../core/design/app_colors.dart';
import '../core/design/app_spacing.dart';
import '../core/design/app_radius.dart';

class StatsCard extends StatelessWidget {
  final bool loading;
  final ScanRecord? lastScan;
  final int totalScans;

  const StatsCard({
    super.key,
    required this.loading,
    required this.lastScan,
    required this.totalScans,
  });

  IconData _getPlaceIcon(String type) {
    switch (type.toLowerCase()) {
      case 'hotel':
        return Icons.hotel;
      case 'restaurant':
        return Icons.restaurant;
      case 'bar':
        return Icons.local_bar;
      default:
        return Icons.place;
    }
  }

  String _timeAgo(DateTime dt) {
    final localDt = dt.toLocal();
    final diff = DateTime.now().difference(localDt);
    if (diff.isNegative || diff.inSeconds < 60) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    if (diff.inDays < 30) {
      return 'Hace ${(diff.inDays / 7).floor()} sem';
    }
    if (diff.inDays < 365) {
      return 'Hace ${(diff.inDays / 30).floor()} meses';
    }
    return 'Hace ${(diff.inDays / 365).floor()} año(s)';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Último escaneo',
          trailing: totalScans > 0 ? '$totalScans en total' : null,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (loading)
          ClipRRect(
            borderRadius: AppRadius.pillAll,
            child: const LinearProgressIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.surfaceVariant,
              minHeight: 3,
            ),
          )
        else if (lastScan != null)
          _buildLastScanCard()
        else
          _buildEmptyState(),
      ],
    );
  }

  Widget _buildSectionHeader(String title, {String? trailing}) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        if (trailing != null) ...[
          const Spacer(),
          Text(
            trailing,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ],
    );
  }

  Widget _buildLastScanCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppRadius.mdAll,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: AppRadius.smAll,
            ),
            child: Icon(
              _getPlaceIcon(lastScan!.type),
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lastScan!.local,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  lastScan!.place,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            _timeAgo(lastScan!.time),
            style: const TextStyle(fontSize: 12, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.lg,
        horizontal: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppRadius.mdAll,
      ),
      child: const Column(
        children: [
          Icon(Icons.qr_code_outlined, size: 32, color: AppColors.textHint),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Aún no tienes escaneos',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2),
          Text(
            'Escanea tu primer código QR',
            style: TextStyle(fontSize: 12, color: AppColors.textHint),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
