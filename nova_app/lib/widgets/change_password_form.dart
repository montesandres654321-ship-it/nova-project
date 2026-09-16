// lib/widgets/change_password_form.dart
// ============================================================
// FORMULARIO DE CAMBIO DE CONTRASEÑA — Nova App Móvil
// ============================================================
// Extraído de change_password_page.dart (FASE 2, PASO 2.4 del refactor).
// Reutiliza password_input.dart (PASO 2.1). A diferencia de
// register_page, aquí los tres campos son independientes: cada uno
// tiene su propio ícono de mostrar/ocultar y su propio estado, igual
// que en el original (_obscureOld, _obscureNew, _obscureConfirm por
// separado) — se usa el modo interno (no controlado) de PasswordInput.
// ============================================================

import 'package:flutter/material.dart';
import '../core/design/app_colors.dart';
import '../core/design/app_spacing.dart';
import '../core/design/app_radius.dart';
import '../core/design/app_text_styles.dart';
import 'password_input.dart';

class ChangePasswordForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController oldPasswordController;
  final TextEditingController newPasswordController;
  final TextEditingController confirmController;
  final bool loading;
  final VoidCallback onSubmit;

  const ChangePasswordForm({
    super.key,
    required this.formKey,
    required this.oldPasswordController,
    required this.newPasswordController,
    required this.confirmController,
    required this.loading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.xl),
          topRight: Radius.circular(AppRadius.xl),
        ),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xxl),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: AppRadius.lgAll,
                ),
                child: const Icon(Icons.lock_reset_rounded,
                    color: AppColors.primary, size: 26),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text('Nueva contraseña', style: AppTextStyles.headline),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Ingresa tu contraseña actual y luego la nueva.',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: AppSpacing.lg),
              PasswordInput(
                controller: oldPasswordController,
                label: 'Contraseña actual',
                enabled: !loading,
                verticalPadding: AppSpacing.md,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Ingresa la contraseña';
                  if (v.length < 6) return 'Mínimo 6 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              PasswordInput(
                controller: newPasswordController,
                label: 'Nueva contraseña',
                enabled: !loading,
                verticalPadding: AppSpacing.md,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Ingresa la contraseña';
                  if (v.length < 6) return 'Mínimo 6 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              PasswordInput(
                controller: confirmController,
                label: 'Confirmar contraseña',
                enabled: !loading,
                verticalPadding: AppSpacing.md,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Ingresa la contraseña';
                  if (v != newPasswordController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: loading ? null : onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    disabledBackgroundColor:
                        AppColors.primary.withValues(alpha: 0.55),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.mdAll),
                  ),
                  child: loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.onPrimary),
                        )
                      : const Text('Actualizar contraseña',
                          style: AppTextStyles.labelLg),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
