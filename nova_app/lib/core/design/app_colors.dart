import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const Color primary      = Color(0xFF06B6A4);
  static const Color primaryLight = Color(0xFF0EA5E9);
  static const Color onPrimary    = Color(0xFFFFFFFF);

  // Surfaces
  static const Color surface        = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF3F4F6);

  // Text
  static const Color textPrimary   = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint      = Color(0xFF9CA3AF);

  // Status
  static const Color error   = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info    = Color(0xFF0EA5E9);

  // UI chrome
  static const Color border = Color(0xFFE5E7EB);

  // Gradient (top-left → bottom-right for depth)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  // Flujo bienvenida (splash/permisos/onboarding) — paleta propia del Figma,
  // distinta de la marca teal usada en el resto de la app.
  static const Color bienvenidaAzul    = Color(0xFF0071BD);
  static const Color bienvenidaVerde   = Color(0xFF078930);
  static const Color bienvenidaDorado  = Color(0xFFF5A623);
  static const Color bienvenidaTextoFuerte = Color(0xFF3D3D3D);
  static const Color bienvenidaTextoMedio  = Color(0xFF4B5563);
  static const Color bienvenidaBorde   = Color(0xFFE3E8EE);
  // Dot inactivo del onboarding: azul distinto a bienvenidaAzul, exacto del Figma.
  static const Color bienvenidaDotInactivo = Color(0xFF1A87C4);

  // Pantallas de autenticación (Login/Registro/Cambiar contraseña) — mismo
  // Figma que el flujo bienvenida, tokens adicionales usados solo ahí.
  static const Color bienvenidaRojo      = Color(0xFFBD0412); // Requisitos de seguridad
  static const Color bienvenidaAzulClaro = Color(0xFFEAF7FF); // Fondo botón atrás circular
  static const Color bienvenidaFondoInput = Color(0xFFF7F9FB); // Fondo input login/registro
}
