// lib/widgets/success_countdown.dart
// ============================================================
// CUENTA REGRESIVA DE REDIRECCIÓN — Nova App Móvil
// ============================================================
// Extraído de success_page.dart (FASE 4, PASO 4.1 del refactor).
// El Timer que decrementa [secondsRemaining] se queda en
// success_page.dart — este widget solo presenta el valor actual.
// ============================================================

import 'package:flutter/material.dart';
import '../core/design/app_colors.dart';
import '../core/design/app_spacing.dart';
import '../core/design/app_radius.dart';

class SuccessCountdown extends StatelessWidget {
  final int secondsRemaining;
  final int totalSeconds;

  const SuccessCountdown({
    super.key,
    required this.secondsRemaining,
    required this.totalSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
        ((totalSeconds - secondsRemaining) / totalSeconds).clamp(0.0, 1.0);
    return Column(
      children: [
        const Text(
          'Volviendo al inicio en',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xs + 4),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: 0.1),
            border: Border.all(color: AppColors.primary, width: 3),
          ),
          child: Center(
            child: Text(
              '$secondsRemaining',
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: 200,
          child: ClipRRect(
            borderRadius: AppRadius.smAll,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.border,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 8,
            ),
          ),
        ),
      ],
    );
  }
}
