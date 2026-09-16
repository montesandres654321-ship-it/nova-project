// lib/widgets/success_message.dart
// ============================================================
// TÍTULO Y SUBTÍTULO DE LA PANTALLA DE ÉXITO — Nova App Móvil
// ============================================================
// Extraído de success_page.dart (FASE 4, PASO 4.1 del refactor).
// ============================================================

import 'package:flutter/material.dart';
import '../core/design/app_colors.dart';
import '../core/design/app_spacing.dart';

class SuccessMessage extends StatelessWidget {
  final bool hasError;
  final bool hasReward;
  final String? errorMessage;

  const SuccessMessage({
    super.key,
    required this.hasError,
    required this.hasReward,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    late String title;
    late Color color;
    if (hasError) {
      title = '¡Ups! Algo salió mal';
      color = AppColors.error;
    } else if (hasReward) {
      title = '¡Felicidades! 🎉';
      color = AppColors.warning;
    } else {
      title = '¡Escaneo Exitoso!';
      color = AppColors.success;
    }

    final String subtitle;
    if (hasError) {
      subtitle = errorMessage ?? 'Error desconocido';
    } else if (hasReward) {
      subtitle = '¡Has ganado una recompensa!';
    } else {
      subtitle = 'El código QR ha sido escaneado correctamente';
    }

    return Column(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
