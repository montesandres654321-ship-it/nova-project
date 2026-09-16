// lib/widgets/history_empty_state.dart
// ============================================================
// ESTADO VACÍO/ERROR REUTILIZABLE — Nova App Móvil
// ============================================================
// Extraído de history_page.dart (FASE 3, PASO 3.1 del refactor).
// Los 4 estados originales (escaneos vacío, escaneos error,
// recompensas vacío, recompensas error) comparten la misma estructura
// (icono en círculo + título + mensaje opcional + botón opcional) pero
// difieren en tamaños de fuente y en si tienen mensaje/botón — por eso
// [titleStyle]/[messageStyle]/[messageMaxLines] son configurables en
// vez de fijos, para reproducir cada estado original exacto.
// ============================================================

import 'package:flutter/material.dart';
import '../core/design/app_colors.dart';
import '../core/design/app_spacing.dart';
import '../core/design/app_radius.dart';

class HistoryEmptyState extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final String title;
  final TextStyle titleStyle;
  final String? message;
  final TextStyle messageStyle;
  final int? messageMaxLines;
  final VoidCallback? onRetry;
  final String retryLabel;

  const HistoryEmptyState({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.title,
    this.titleStyle = const TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    this.message,
    this.messageStyle = const TextStyle(
      fontSize: 14,
      color: AppColors.textSecondary,
      height: 1.5,
    ),
    this.messageMaxLines,
    this.onRetry,
    this.retryLabel = 'Reintentar',
  });

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
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 44, color: iconColor),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(title, style: titleStyle, textAlign: TextAlign.center),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                message!,
                style: messageStyle,
                textAlign: TextAlign.center,
                maxLines: messageMaxLines,
                overflow:
                    messageMaxLines != null ? TextOverflow.ellipsis : null,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(retryLabel),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
