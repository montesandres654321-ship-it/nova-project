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
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final String? placeholder;

  /// Cuando es true, renderiza el estilo Figma (label arriba en texto
  /// aparte, ícono de ojo en SVG local, fondo configurable) en vez del
  /// InputDecoration flotante por defecto — usado por login/register/
  /// cambiar-contraseña (pantallas 06/07/08).
  final bool figmaStyle;
  final Color figmaFillColor;
  final bool figmaBoldLabel;
  final Color figmaLabelColor;
  final String figmaEyeIconAsset;
  final double figmaEyeIconSize;

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
    this.placeholder,
    this.figmaStyle = false,
    this.figmaFillColor = AppColors.bienvenidaFondoInput,
    this.figmaBoldLabel = false,
    this.figmaLabelColor = AppColors.bienvenidaTextoMedio,
    this.figmaEyeIconAsset = 'assets/icons/ic-ojo.svg',
    this.figmaEyeIconSize = 20,
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
    if (widget.figmaStyle) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: GoogleFonts.openSans(
              fontSize: 13,
              fontWeight: widget.figmaBoldLabel ? FontWeight.w700 : FontWeight.w600,
              color: widget.figmaLabelColor,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: widget.figmaFillColor,
              border: Border.all(color: AppColors.bienvenidaBorde),
              borderRadius: AppRadius.mdAll,
            ),
            child: TextFormField(
              controller: widget.controller,
              obscureText: _obscure,
              enabled: widget.enabled,
              style: GoogleFonts.openSans(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: AppColors.bienvenidaTextoFuerte,
              ),
              decoration: InputDecoration(
                hintText: widget.placeholder,
                hintStyle: GoogleFonts.openSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textHint,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: widget.verticalPadding,
                ),
                border: InputBorder.none,
                suffixIcon: widget.showToggle
                    ? GestureDetector(
                        onTap: _handleToggle,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: SvgPicture.asset(
                            widget.figmaEyeIconAsset,
                            width: widget.figmaEyeIconSize,
                            height: widget.figmaEyeIconSize,
                          ),
                        ),
                      )
                    : null,
              ),
              validator: widget.validator,
            ),
          ),
        ],
      );
    }

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
