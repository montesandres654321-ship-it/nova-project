// lib/widgets/register_confirm_password_field.dart
// ============================================================
// CAMPO DE CONFIRMAR CONTRASEÑA DE REGISTRO — Nova App Móvil
// ============================================================
// FASE 2, PASO 2.4 del refactor de widgets. StatefulWidget con su
// propio estado de visibilidad y su propio validador de coincidencia
// contra [passwordController] — coincide con lo pedido (a diferencia
// del PASO 2.3, aquí REQUISITOS y ESTRUCTURA no se contradicen).
//
// Reutiliza password_input.dart en modo controlado (mismo ícono,
// mismo estilo) en vez de reimplementar el TextFormField desde cero,
// siguiendo el precedente del PASO 2.3. PasswordInput no soporta
// `hintText` (solo `label`), así que el hint "Repite tu contraseña"
// de la estructura ilustrativa no se agrega — no era parte del
// checklist explícito de este paso.
// ============================================================

import 'package:flutter/material.dart';
import 'password_input.dart';

class RegisterConfirmPasswordField extends StatefulWidget {
  final TextEditingController confirmController;
  final TextEditingController passwordController;

  const RegisterConfirmPasswordField({
    super.key,
    required this.confirmController,
    required this.passwordController,
  });

  @override
  State<RegisterConfirmPasswordField> createState() =>
      _RegisterConfirmPasswordFieldState();
}

class _RegisterConfirmPasswordFieldState
    extends State<RegisterConfirmPasswordField> {
  bool _obscureText = true;

  String? _validateMatch(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }
    if (value != widget.passwordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return PasswordInput(
      controller: widget.confirmController,
      label: 'Confirmar contraseña',
      placeholder: 'Repite la contraseña',
      figmaStyle: true,
      verticalPadding: 15,
      obscureText: _obscureText,
      onToggleVisibility: (value) => setState(() => _obscureText = value),
      validator: _validateMatch,
    );
  }
}
