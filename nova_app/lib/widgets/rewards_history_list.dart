// lib/widgets/rewards_history_list.dart
// ============================================================
// LISTA DE RECOMPENSAS DEL HISTORIAL — Nova App Móvil
// ============================================================
// Extraído de history_page.dart (FASE 3, PASO 3.1 del refactor).
// Widget de presentación puro: recibe el estado (loading/error/rewards)
// ya cargado por history_page. No llama a ApiService.
// ============================================================

import 'package:flutter/material.dart';
import '../core/design/app_colors.dart';
import '../core/design/app_spacing.dart';
import '../core/design/app_radius.dart';
import 'history_empty_state.dart';

class RewardsHistoryList extends StatelessWidget {
  final bool loading;
  final String error;
  final List<Map<String, dynamic>> rewards;
  final Future<void> Function() onRefresh;

  const RewardsHistoryList({
    super.key,
    required this.loading,
    required this.error,
    required this.rewards,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
      );
    }
    if (error.isNotEmpty) {
      return HistoryEmptyState(
        icon: Icons.cloud_off_rounded,
        iconColor: AppColors.error,
        iconBackgroundColor: AppColors.error.withValues(alpha: 0.08),
        title: 'No se pudo cargar las recompensas',
        titleStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        onRetry: onRefresh,
      );
    }
    if (rewards.isEmpty) {
      return const HistoryEmptyState(
        icon: Icons.card_giftcard_outlined,
        iconColor: AppColors.textHint,
        iconBackgroundColor: AppColors.surfaceVariant,
        title: 'No tienes recompensas aún',
        message: 'Escanea QR en los establecimientos\npara ganar recompensas.',
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.xs, AppSpacing.md, AppSpacing.xl,
        ),
        itemCount: rewards.length,
        itemBuilder: (_, i) => _buildRewardItem(rewards[i]),
      ),
    );
  }

  Widget _buildRewardItem(Map<String, dynamic> r) {
    final isRedeemed = r['is_redeemed'] == true;
    final icon  = r['reward_icon']?.toString() ?? '🎁';
    final name  = r['reward_name']?.toString() ?? 'Recompensa';
    final place = r['place_name']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(children: [
        // Emoji del ícono
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: AppRadius.smAll,
          ),
          child: Center(child: Text(icon, style: const TextStyle(fontSize: 22))),
        ),
        const SizedBox(width: AppSpacing.md),
        // Nombre y lugar
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (place.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(place,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        // Badge de estado
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isRedeemed
                ? AppColors.success.withValues(alpha: 0.10)
                : AppColors.primary.withValues(alpha: 0.08),
            borderRadius: AppRadius.pillAll,
          ),
          child: Text(
            isRedeemed ? 'Canjeada' : 'Pendiente',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isRedeemed ? AppColors.success : AppColors.primary,
            ),
          ),
        ),
      ]),
    );
  }
}
