// lib/widgets/register_name_field.dart
// ============================================================
// CAMPO DE NOMBRE — Registro (Nova App Móvil)
// ============================================================
// Único consumidor: register_form.dart. Estilo Figma (label arriba,
// sin ícono, fondo plano) — pantalla 07 · Registro.
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design/app_colors.dart';
import '../core/design/app_radius.dart';

class RegisterNameField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String? hintText;

  const RegisterNameField({
    super.key,
    required this.controller,
    this.validator,
    this.hintText = 'Ej. Beatriz',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nombre',
          style: GoogleFonts.openSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.bienvenidaTextoMedio,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bienvenidaFondoInput,
            border: Border.all(color: AppColors.bienvenidaBorde),
            borderRadius: AppRadius.mdAll,
          ),
          child: TextFormField(
            controller: controller,
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
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              border: InputBorder.none,
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }
}
