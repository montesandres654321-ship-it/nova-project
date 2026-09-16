// lib/widgets/scan_history_empty_state.dart
// ============================================================
// ESTADO VACÍO DEL HISTORIAL DE ESCANEOS — Nova App Móvil
// ============================================================
// FASE 1, PASO 1.3 del refactor de widgets. Widget standalone: ícono
// + texto + botón "Explorar lugares".
//
// NOTA: ya existe lib/widgets/history_empty_state.dart (genérico, de
// un refactor anterior), pero su botón es de "Reintentar" con ícono
// de refresh — no encaja semánticamente con una acción de "explorar".
// Este widget es nuevo y autocontenido, no una variante de aquel.
// ============================================================

import 'package:flutter/material.dart';
import '../core/design/app_colors.dart';
import '../core/design/app_spacing.dart';
import '../core/design/app_radius.dart';

class ScanHistoryEmptyState extends StatelessWidget {
  final VoidCallback onExplore;

  const ScanHistoryEmptyState({super.key, required this.onExplore});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: const BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inbox_rounded,
                size: 44,
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'No tienes escaneos aún',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onExplore,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
              ),
              child: const Text(
                'Explorar lugares',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
