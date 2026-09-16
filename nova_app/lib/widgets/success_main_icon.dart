// lib/widgets/success_main_icon.dart
// ============================================================
// ÍCONO PRINCIPAL DE LA PANTALLA DE ÉXITO — Nova App Móvil
// ============================================================
// Extraído de success_page.dart (FASE 4, PASO 4.1 del refactor).
// Círculo de ícono: error / recompensa / éxito simple. La animación
// de escala (ScaleTransition) se queda en success_page.dart, que es
// quien posee el AnimationController — este widget es solo el ícono.
// ============================================================

import 'package:flutter/material.dart';
import '../core/design/app_colors.dart';

class SuccessMainIcon extends StatelessWidget {
  final bool hasError;
  final bool hasReward;
  final String? rewardIcon;

  const SuccessMainIcon({
    super.key,
    required this.hasError,
    required this.hasReward,
    this.rewardIcon,
  });

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.error, width: 3),
        ),
        child: const Icon(Icons.error_outline, size: 52, color: AppColors.error),
      );
    }
    if (hasReward) {
      return Container(
        width: 105,
        height: 105,
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.08),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.warning, width: 4),
          boxShadow: [
            BoxShadow(
              color: AppColors.warning.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Center(
          child: Text(rewardIcon ?? '🎁', style: const TextStyle(fontSize: 52)),
        ),
      );
    }
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.success, width: 3),
      ),
      child: const Icon(Icons.check_circle, size: 52, color: AppColors.success),
    );
  }
}
