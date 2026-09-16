// lib/widgets/register_email_field.dart
// ============================================================
// CAMPO DE CORREO DE REGISTRO — Nova App Móvil
// ============================================================
// FASE 2, PASO 2.2 del refactor de widgets. A diferencia de
// register_name_field.dart (PASO 2.1), aquí sí se reutiliza
// directamente email_input.dart (mismo ícono Icons.email_outlined,
// mismo estilo filled/bordes redondeados) en vez de reimplementar la
// decoración — es un wrapper delgado con el hint de contexto de
// registro ("tu@email.com") y el padding vertical que ya usa el
// campo de correo real en register_form.dart.
// ============================================================

import 'package:flutter/material.dart';
import '../core/design/app_spacing.dart';
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
      hintText: 'tu@email.com',
      verticalPadding: AppSpacing.md,
    );
  }
}
