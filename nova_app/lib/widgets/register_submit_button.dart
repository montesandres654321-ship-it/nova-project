// lib/widgets/register_submit_button.dart
// ============================================================
// BOTÓN DE ENVÍO DE REGISTRO — Nova App Móvil
// ============================================================
// Único consumidor: register_form.dart. Estilo Figma: verde de marca,
// StadiumBorder — pantalla 07 · Registro.
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design/app_colors.dart';

class RegisterSubmitButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final String buttonText;

  const RegisterSubmitButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.buttonText = 'Crear cuenta',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 49,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.bienvenidaVerde,
          disabledBackgroundColor: AppColors.bienvenidaBorde,
          shape: const StadiumBorder(),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                buttonText,
                style: GoogleFonts.openSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 25 / 13,
                ),
              ),
      ),
    );
  }
}
