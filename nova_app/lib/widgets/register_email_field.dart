// lib/widgets/register_email_field.dart
// ============================================================
// CAMPO DE CORREO DE REGISTRO — Nova App Móvil
// ============================================================
// Wrapper delgado sobre email_input.dart en modo Figma (label arriba,
// sin ícono) — pantalla 07 · Registro.
// ============================================================

import 'package:flutter/material.dart';
import 'email_input.dart';

class RegisterEmailField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const RegisterEmailField({
    super.key,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return EmailInput(
      controller: controller,
      validator: validator,
      figmaLabel: 'Correo electrónico',
      hintText: 'tucorreo@ejemplo.com',
    );
  }
}
