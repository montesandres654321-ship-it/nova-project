// lib/widgets/register_submit_button.dart
// ============================================================
// BOTÓN DE ENVÍO DE REGISTRO — Nova App Móvil
// ============================================================
// FASE 2, PASO 2.5 del refactor de widgets. Widget standalone con
// estado de carga (deshabilita el botón y muestra un spinner).
//
// Estilo tomado del botón real de register_form.dart (altura 52,
// AppColors.primary, spinner 20x20 strokeWidth 2) en vez del
// ElevatedButton por defecto de la estructura ilustrativa, para que
// sea visualmente consistente si en algún momento reemplaza al real.
// ============================================================

import 'package:flutter/material.dart';
import '../core/design/app_colors.dart';
import '../core/design/app_radius.dart';

class RegisterSubmitButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final String buttonText;

  const RegisterSubmitButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.buttonText = 'Crear cuenta',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.55),
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
            : Text(
                buttonText,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}
