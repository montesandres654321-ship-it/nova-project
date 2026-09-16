// lib/widgets/scan_history_card.dart
// ============================================================
// TARJETA INDIVIDUAL DE ESCANEO — Nova App Móvil
// ============================================================
// FASE 1, PASO 1.1 del refactor de widgets. Card standalone y
// reutilizable para un ítem de historial de escaneos — sin lógica de
// lista (agrupación por fecha, RefreshIndicator, etc. siguen en
// scan_history_list.dart).
//
// NOTA: ScanRecord no tiene campos `place.name` ni `createdAt` (el
// modelo real usa `local` para el nombre del establecimiento, `place`
// para el municipio y `time` para la fecha). Tampoco existe un campo
// de "estado" explícito — se usa si el escaneo tiene recompensa
// asociada (`hasReward`/`rewardName`) como el único dato de estado
// disponible en el modelo.
// ============================================================

import 'package:flutter/material.dart';
import '../models/scan_record.dart';
import '../core/design/app_colors.dart';
import '../core/design/app_spacing.dart';
import '../core/design/app_radius.dart';

class ScanHistoryCard extends StatelessWidget {
  final ScanRecord scan;
  final VoidCallback onTap;

  const ScanHistoryCard({
    super.key,
    required this.scan,
    required this.onTap,
  });

  IconData _typeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'hotel':
        return Icons.hotel_rounded;
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'bar':
        return Icons.local_bar_rounded;
      default:
        return Icons.place_rounded;
    }
  }

  Color _typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'hotel':
        return AppColors.primaryLight;
      case 'restaurant':
        return AppColors.warning;
      case 'bar':
        return AppColors.error;
      default:
        return AppColors.textHint;
    }
  }

  String _formatDateTime(DateTime dt) {
    final d = dt.toLocal();
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final hour = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return '$day/$month/${d.year}  $hour:$min';
  }

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(scan.type);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      elevation: 0,
      color: AppColors.surfaceVariant,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.mdAll,
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdAll,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ícono del tipo de lugar (o imagen si existe)
              ClipRRect(
                borderRadius: AppRadius.smAll,
                child: scan.image != null && scan.image!.isNotEmpty
                    ? Image.network(
                        scan.image!,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildTypeIconBox(color),
                      )
                    : _buildTypeIconBox(color),
              ),
              const SizedBox(width: AppSpacing.md),

              // Nombre del establecimiento + municipio + fecha/hora
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scan.local,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (scan.place.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        scan.place,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 5),
                    Text(
                      _formatDateTime(scan.time),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),

              // Estado del escaneo: recompensa obtenida o sin recompensa
              _buildStatusBadge(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeIconBox(Color color) {
    return Container(
      width: 48,
      height: 48,
      color: color.withValues(alpha: 0.12),
      child: Icon(_typeIcon(scan.type), color: color, size: 22),
    );
  }

  Widget _buildStatusBadge() {
    if (scan.hasReward) {
      return Container(
        constraints: const BoxConstraints(maxWidth: 90),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.12),
          borderRadius: AppRadius.pillAll,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.card_giftcard_rounded, size: 10, color: AppColors.warning),
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                scan.rewardName ?? 'Premio',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.warning,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.textHint.withValues(alpha: 0.10),
        borderRadius: AppRadius.pillAll,
      ),
      child: const Text(
        'Sin recompensa',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.textHint,
        ),
      ),
    );
  }
}
