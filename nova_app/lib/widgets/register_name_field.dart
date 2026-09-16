// lib/widgets/register_name_field.dart
// ============================================================
// CAMPO DE NOMBRE REUTILIZABLE — Nova App Móvil
// ============================================================
// FASE 2, PASO 2.1 del refactor de widgets. Widget standalone: campo
// de texto con ícono de persona, hint personalizable y validador
// opcional.
//
// register_form.dart actualmente valida "Nombre" con labelText (no
// hintText) e ícono Icons.person_outline_rounded, con estilo propio
// del design system (filled, bordes redondeados) — se mantiene ese
// estilo visual aquí para consistencia con el resto de la app, pero
// se sigue la API exacta pedida (hintText con default, Icons.person).
// Este widget aún no reemplaza el campo de register_form.dart.
// ============================================================

import 'package:flutter/material.dart';
import '../core/design/app_colors.dart';
import '../core/design/app_spacing.dart';
import '../core/design/app_radius.dart';

class RegisterNameField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String? hintText;

  const RegisterNameField({
    super.key,
    required this.controller,
    this.validator,
    this.hintText = 'Tu nombre completo',
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(fontSize: 14, color: AppColors.textHint),
        prefixIcon: const Icon(Icons.person, size: 20, color: AppColors.textHint),
        filled: true,
        fillColor: AppColors.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 12,
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
