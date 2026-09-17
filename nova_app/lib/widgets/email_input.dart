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
// pantalla (12 en login, AppSpacing.md en register/forgot_password).
// [enabled]/[hintText] reproducen el campo de forgot_password_page,
// que se deshabilita durante la carga y muestra un hint de ejemplo.
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design/app_colors.dart';
import '../core/design/app_spacing.dart';
import '../core/design/app_radius.dart';

class EmailInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final double verticalPadding;
  final bool enabled;
  final String? hintText;

  /// Cuando no es null, renderiza el estilo Figma (label arriba en texto
  /// aparte, sin ícono, fondo plano) en vez del InputDecoration flotante
  /// por defecto — usado solo por login/register (pantallas 06/07).
  final String? figmaLabel;
  final Color figmaFillColor;

  const EmailInput({
    super.key,
    required this.controller,
    this.label = 'Correo electrónico',
    this.validator,
    this.verticalPadding = 12,
    this.enabled = true,
    this.hintText,
    this.figmaLabel,
    this.figmaFillColor = AppColors.bienvenidaFondoInput,
  });

  @override
  Widget build(BuildContext context) {
    if (figmaLabel != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            figmaLabel!,
            style: GoogleFonts.openSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.bienvenidaTextoMedio,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: figmaFillColor,
              border: Border.all(color: AppColors.bienvenidaBorde),
              borderRadius: AppRadius.mdAll,
            ),
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.emailAddress,
              enabled: enabled,
              style: GoogleFonts.openSans(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: AppColors.bienvenidaTextoFuerte,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: GoogleFonts.openSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textHint,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: verticalPadding,
                ),
                border: InputBorder.none,
              ),
              validator: validator,
            ),
          ),
        ],
      );
    }

    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      enabled: enabled,
      style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 14, color: AppColors.textHint),
        hintText: hintText,
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
        disabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide.none,
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
