// lib/widgets/success_reward_card.dart
// ============================================================
// TARJETA DE RECOMPENSA OBTENIDA — Nova App Móvil
// ============================================================
// Extraído de success_page.dart (FASE 4, PASO 4.1 del refactor).
// Widget de presentación: el estado de confirmación (rewardConfirmed/
// confirmingReward) y la llamada a ApiService.redeemReward se quedan
// en success_page.dart — este widget solo recibe el estado y expone
// [onConfirm].
// ============================================================

import 'package:flutter/material.dart';
import '../core/design/app_colors.dart';
import '../core/design/app_spacing.dart';
import '../core/design/app_radius.dart';

class SuccessRewardCard extends StatelessWidget {
  final Map<String, dynamic> reward;
  final bool confirmed;
  final bool confirming;
  final VoidCallback onConfirm;

  const SuccessRewardCard({
    super.key,
    required this.reward,
    required this.confirmed,
    required this.confirming,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm + 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.warning.withValues(alpha: 0.08),
            AppColors.warning.withValues(alpha: 0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.warning, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.warning.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(reward['icon'] ?? '🎁', style: const TextStyle(fontSize: 40)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            reward['name'] ?? 'Recompensa',
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.warning),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          if (reward['description'] != null &&
              reward['description'].toString().isNotEmpty)
            Text(
              reward['description'],
              style: const TextStyle(
                  fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.xs + 4),
            decoration: BoxDecoration(
              color: AppColors.warning,
              borderRadius: AppRadius.pillAll,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.stars, color: Colors.white, size: 18),
                SizedBox(width: AppSpacing.xs + 4),
                Text(
                  'Nueva recompensa desbloqueada',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (!confirmed)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: confirming ? null : onConfirm,
                icon: confirming
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.onPrimary),
                      )
                    : const Icon(Icons.check_circle_rounded),
                label: Text(confirming
                    ? 'Confirmando...'
                    : 'Confirmar que recibí mi premio'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.mdAll),
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm + 4),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: AppRadius.mdAll,
                border: Border.all(color: AppColors.success),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: AppColors.success, size: 20),
                  SizedBox(width: AppSpacing.xs + 4),
                  Text(
                    '¡Premio confirmado!',
                    style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
