// lib/widgets/password_input.dart
// ============================================================
// CAMPO DE CONTRASEÑA REUTILIZABLE — Nova App Móvil
// ============================================================
// Extraído de login_page.dart (FASE 2, PASO 2.1 del refactor).
// Por defecto mantiene internamente el estado de "mostrar/ocultar"
// contraseña, con estilo idéntico al campo original de login_page.
//
// Modo controlado (usado por register_page en el PASO 2.2): si se
// provee [obscureText], el widget deja de manejar su propio estado y
// usa el valor externo — necesario porque en register_page el campo
// de contraseña y el de confirmación comparten una sola bandera de
// visibilidad. [showToggle] permite ocultar el ícono de ojo (el campo
// de confirmar contraseña original no tiene uno propio).
//
// [enabled]/[verticalPadding] (usados por change_password_page en el
// PASO 2.4) reproducen el estado deshabilitado durante la carga y el
// padding vertical (AppSpacing.md) de esa pantalla.
// ============================================================

import 'package:flutter/material.dart';
import '../core/design/app_colors.dart';
import '../core/design/app_spacing.dart';
import '../core/design/app_radius.dart';

class PasswordInput extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final bool showToggle;
  final bool? obscureText;
  final ValueChanged<bool>? onToggleVisibility;
  final bool enabled;
  final double verticalPadding;

  const PasswordInput({
    super.key,
    required this.controller,
    this.label = 'Contraseña',
    this.validator,
    this.showToggle = true,
    this.obscureText,
    this.onToggleVisibility,
    this.enabled = true,
    this.verticalPadding = 12,
  });

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  bool _internalObscure = true;

  bool get _obscure => widget.obscureText ?? _internalObscure;

  void _handleToggle() {
    if (widget.onToggleVisibility != null) {
      widget.onToggleVisibility!(!_obscure);
    } else {
      setState(() => _internalObscure = !_internalObscure);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      enabled: widget.enabled,
      style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: const TextStyle(fontSize: 14, color: AppColors.textHint),
        prefixIcon: const Icon(Icons.lock_outline_rounded,
            size: 20, color: AppColors.textHint),
        suffixIcon: widget.showToggle
            ? IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textHint,
                  size: 20,
                ),
                onPressed: _handleToggle,
              )
            : null,
        filled: true,
        fillColor: AppColors.surfaceVariant,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: widget.verticalPadding,
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
      validator: widget.validator,
    );
  }
}
