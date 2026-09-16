// lib/widgets/email_input.dart
// ============================================================
// CAMPO DE CORREO REUTILIZABLE — Nova App Móvil
// ============================================================
// Extraído de login_page.dart / register_page.dart (FASE 2, PASO 2.2).
// [validator] se recibe por parámetro (no usa Validators.email a la
// fuerza) porque login y register muestran mensajes distintos para el
// campo vacío ("Ingresa tu correo" vs "Requerido") — se preserva el
// texto exacto de cada página original.
// [verticalPadding] permite igualar el padding original de cada
// pantalla (12 en login, AppSpacing.md en register).
// ============================================================

import 'package:flutter/material.dart';
import '../core/design/app_colors.dart';
import '../core/design/app_spacing.dart';
import '../core/design/app_radius.dart';

class EmailInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final double verticalPadding;

  const EmailInput({
    super.key,
    required this.controller,
    this.label = 'Correo electrónico',
    this.validator,
    this.verticalPadding = 12,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 14, color: AppColors.textHint),
        prefixIcon: const Icon(Icons.email_outlined,
            size: 20, color: AppColors.textHint),
        filled: true,
        fillColor: AppColors.surfaceVariant,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: verticalPadding,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
      validator: validator,
    );
  }
}
