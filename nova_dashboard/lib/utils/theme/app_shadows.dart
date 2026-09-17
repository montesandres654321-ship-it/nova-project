// lib/utils/theme/app_shadows.dart
// Sistema de sombras de 3 niveles (nova-design 4bis) — extraído de
// app_theme.dart sin cambiar valores.
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppShadows {
  AppShadows._();

  // Nivel 1 — tarjeta: sombra muy sutil, sin borde.
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: AppColors.gray900.withOpacity(0.05),
      blurRadius: 12,
      offset: const Offset(0, 2),
    ),
  ];
  static List<BoxShadow> get shadowSM => cardShadow; // alias legacy

  // Nivel 2 — flotante (modales, menús, popovers): sombra más marcada.
  static List<BoxShadow> get shadowMD => [
    BoxShadow(
      color: AppColors.gray900.withOpacity(0.12),
      blurRadius: 24,
      offset: const Offset(0, 4),
    ),
  ];

  // Resplandor de acento (uso puntual).
  static List<BoxShadow> get shadowLG => [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.2),
      blurRadius: 30,
      offset: const Offset(0, 8),
    ),
  ];
}
