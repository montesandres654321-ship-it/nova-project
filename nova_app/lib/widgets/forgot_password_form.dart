// lib/widgets/forgot_password_form.dart
// ============================================================
// FORMULARIO DE RECUPERACIÓN DE CONTRASEÑA — Nova App Móvil
// ============================================================
// Extraído de forgot_password_page.dart (FASE 2, PASO 2.3 del refactor).
// Widget de presentación: muestra el formulario de correo o el estado
// de éxito según [emailSent]. No llama a ningún servicio — el envío
// real sigue pendiente de backend (ver TODO en forgot_password_page).
// ============================================================

import 'package:flutter/material.dart';
import '../core/design/app_colors.dart';
import '../core/design/app_spacing.dart';
import '../core/design/app_radius.dart';
import '../utils/validators.dart';
import 'email_input.dart';

class ForgotPasswordForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final bool isLoading;
  final bool emailSent;
  final VoidCallback onSubmit;
  final VoidCallback onBackPressed;

  const ForgotPasswordForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.isLoading,
    required this.emailSent,
    required this.onSubmit,
    required this.onBackPressed,
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
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        child: emailSent ? _buildSuccessContent() : _buildFormContent(),
      ),
    );
  }

  // Estado inicial: formulario de correo
  Widget _buildFormContent() {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIcon(
            icon: Icons.lock_reset_rounded,
            color: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.md),

          const Text(
            '¿Olvidaste tu contraseña?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Ingresa tu dirección de correo electrónico y te enviaremos instrucciones para recuperar tu acceso.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          EmailInput(
            controller: emailController,
            verticalPadding: AppSpacing.md,
            enabled: !isLoading,
            hintText: 'ejemplo@correo.com',
            validator: Validators.email,
          ),
          const SizedBox(height: AppSpacing.lg),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isLoading ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                disabledBackgroundColor:
                    AppColors.primary.withValues(alpha: 0.55),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.onPrimary,
                      ),
                    )
                  : const Text(
                      'Enviar instrucciones',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          Center(
            child: TextButton(
              onPressed: isLoading ? null : onBackPressed,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Volver al inicio de sesión',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Estado de confirmación: mensaje honesto post-envío
  Widget _buildSuccessContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildIcon(
          icon: Icons.mark_email_read_outlined,
          color: AppColors.success,
        ),
        const SizedBox(height: AppSpacing.md),

        const Text(
          'Solicitud enviada',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Mensaje honesto — no afirma que el correo existe
        const Text(
          'Si este correo está registrado en Nova, recibirás instrucciones para recuperar tu acceso en los próximos minutos.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Correo ingresado — referencia para el usuario
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: AppRadius.mdAll,
          ),
          child: Row(
            children: [
              const Icon(Icons.email_outlined,
                  color: AppColors.textHint, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  emailController.text,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Tip sobre spam
        const Text(
          'Revisa también tu carpeta de spam si no encuentras el correo.',
          style: TextStyle(fontSize: 12, color: AppColors.textHint, height: 1.4),
        ),
        const SizedBox(height: AppSpacing.xl),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: onBackPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
            ),
            child: const Text(
              'Volver al inicio de sesión',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIcon({required IconData icon, required Color color}) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.lgAll,
      ),
      child: Icon(icon, color: color, size: 30),
    );
  }
}
