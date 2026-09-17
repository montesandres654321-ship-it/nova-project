// lib/widgets/register_password_field.dart
// ============================================================
// CAMPO DE CONTRASEÑA DE REGISTRO — Nova App Móvil
// ============================================================
// Wrapper sobre password_input.dart en modo Figma — pantalla 07.
// Soporta modo controlado (obscureText compartido con "confirmar
// contraseña", igual que hace register_form.dart hoy).
// ============================================================

import 'package:flutter/material.dart';
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
    return PasswordInput(
      controller: controller,
      validator: validator,
      label: 'Contraseña',
      placeholder: 'Mínimo 8 caracteres',
      figmaStyle: true,
      verticalPadding: 15,
      obscureText: onToggleVisibility == null ? null : obscureText,
      onToggleVisibility: onToggleVisibility == null
          ? null
          : (_) => onToggleVisibility!(),
    );
  }
}
