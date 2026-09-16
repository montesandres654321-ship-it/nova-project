// lib/widgets/register_password_field.dart
// ============================================================
// CAMPO DE CONTRASEÑA DE REGISTRO — Nova App Móvil
// ============================================================
// FASE 2, PASO 2.3 del refactor de widgets.
//
// NOTA: el pedido se contradice a sí mismo — "REQUISITOS" pide
// `extends StatelessWidget`, pero "ESTRUCTURA" muestra un
// StatefulWidget con su propio `_obscureText`. Se prioriza
// REQUISITOS (StatelessWidget) porque además pide explícitamente
// "REUTILIZA logic de password_input.dart", y PasswordInput ya es
// stateful internamente — no hace falta duplicar ese estado aquí.
//
// Soporta los dos modos de PasswordInput:
// - Sin [onToggleVisibility]: modo no controlado, PasswordInput
//   maneja su propio estado de mostrar/ocultar (uso más simple).
// - Con [onToggleVisibility]: modo controlado, el padre decide
//   [obscureText] y reacciona al toggle (igual que hace
//   register_form.dart hoy con password/confirmar contraseña).
// ============================================================

import 'package:flutter/material.dart';
import '../core/design/app_spacing.dart';
import 'password_input.dart';

class RegisterPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final VoidCallback? onToggleVisibility;

  const RegisterPasswordField({
    super.key,
    required this.controller,
    this.validator,
    this.obscureText = true,
    this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    if (onToggleVisibility == null) {
      return PasswordInput(
        controller: controller,
        validator: validator,
        verticalPadding: AppSpacing.md,
      );
    }
    return PasswordInput(
      controller: controller,
      validator: validator,
      verticalPadding: AppSpacing.md,
      obscureText: obscureText,
      onToggleVisibility: (_) => onToggleVisibility!(),
    );
  }
}
