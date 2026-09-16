// lib/widgets/profile_actions.dart
// ============================================================
// BOTONES DE EDICIÓN DE PERFIL — Nova App Móvil
// ============================================================
// Extraído de profile_page.dart (FASE 3, PASO 3.5 del refactor).
// El plan mencionaba botones de "cambiar contraseña" y "logout", pero
// esa funcionalidad no existe en esta pantalla — solo Cancelar/Guardar
// durante el modo edición (el toggle de editar ya vive en el AppBar
// de profile_page). No se inventan acciones nuevas.
// ============================================================

import 'package:flutter/material.dart';
import '../core/design/app_colors.dart';
import '../core/design/app_spacing.dart';
import '../core/design/app_radius.dart';

class ProfileActions extends StatelessWidget {
  final bool loading;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const ProfileActions({
    super.key,
    required this.loading,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: loading ? null : onCancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: ElevatedButton(
            onPressed: loading ? null : onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.onPrimary,
                    ),
                  )
                : const Text('Guardar'),
          ),
        ),
      ],
    );
  }
}
