// lib/widgets/change_password_form.dart
// ============================================================
// FORMULARIO DE CAMBIO DE CONTRASEÑA — Nova App Móvil
// ============================================================
// Reutiliza password_input.dart en modo Figma. Los tres campos son
// independientes: cada uno tiene su propio ícono de mostrar/ocultar y
// su propio estado (modo interno/no controlado de PasswordInput).
//
// Diseño actualizado al Figma de Septiembre 2026 (NOVA_AUTH_PLAN.md,
// pantalla 08 · Cambiar contraseña): fondo de pantalla gris suave,
// inputs blancos (al revés que login/registro), labels en negrita,
// bloque "Requisitos de seguridad" en rojo, botón radius 30 (no pill).
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design/app_colors.dart';
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCampoPwd(
              label: 'Contraseña actual',
              controller: oldPasswordController,
              enabled: !loading,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Ingresa la contraseña';
                if (v.length < 6) return 'Mínimo 6 caracteres';
                return null;
              },
            ),
            const SizedBox(height: 14),
            _buildCampoPwd(
              label: 'Nueva contraseña',
              controller: newPasswordController,
              enabled: !loading,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Ingresa la contraseña';
                if (v.length < 6) return 'Mínimo 6 caracteres';
                return null;
              },
            ),
            const SizedBox(height: 14),
            _buildCampoPwd(
              label: 'Confirmar nueva contraseña',
              controller: confirmController,
              enabled: !loading,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Ingresa la contraseña';
                if (v != newPasswordController.text) {
                  return 'Las contraseñas no coinciden';
                }
                return null;
              },
            ),
            const SizedBox(height: 15),

            // Bloque requisitos de seguridad
            Container(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/ic-escudo-alerta.svg',
                        width: 14,
                        height: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Requisitos de seguridad',
                        style: GoogleFonts.openSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.bienvenidaRojo,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tu nueva contraseña debe tener al menos 8 caracteres, e incluir una combinación de letras mayúsculas, minúsculas, números y caracteres especiales.',
                    style: GoogleFonts.openSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.bienvenidaRojo,
                      height: 17 / 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // Botón actualizar (radius 30, NO stadium)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bienvenidaAzul,
                  disabledBackgroundColor:
                      AppColors.bienvenidaAzul.withValues(alpha: 0.55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                child: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Actualizar contraseña',
                        style: GoogleFonts.openSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Campo de contraseña estilo Figma: fondo blanco, label en negrita
  Widget _buildCampoPwd({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    required String? Function(String?) validator,
  }) {
    return PasswordInput(
      controller: controller,
      label: label,
      enabled: enabled,
      validator: validator,
      figmaStyle: true,
      figmaFillColor: Colors.white,
      figmaBoldLabel: true,
      figmaLabelColor: AppColors.bienvenidaTextoFuerte,
      figmaEyeIconAsset: 'assets/icons/ic-ojo-pwd.svg',
      figmaEyeIconSize: 18,
      verticalPadding: 12,
    );
  }
}
