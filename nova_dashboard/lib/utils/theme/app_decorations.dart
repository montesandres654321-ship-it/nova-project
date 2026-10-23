// lib/utils/theme/app_decorations.dart
// Decoraciones reutilizables — alineadas con nova_app (border-based, radius 16).
// La app móvil usa borde + sin sombra. El dashboard adopta el mismo sistema.
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_radii.dart';
import 'app_shadows.dart';

class AppDecorations {
  AppDecorations._();

  /// Tarjeta estándar — border-based, igual que nova_app.
  /// Equivalente a: border: Border.all(color: AppColors.border), radius 16.
  static BoxDecoration card({
    Color? color,
    Color? borderColor,
    bool withShadow = false,
  }) {
    return BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(AppRadii.cardRadius),
      border: Border.all(
        color: borderColor ?? AppColors.border,
        width: 1,
      ),
      boxShadow: withShadow ? AppShadows.cardShadow : null,
    );
  }

  /// Tarjeta de KPI/stat — acento de color con borde coloreado tenue.
  /// Mantiene el gradiente sutil que ya tenía, pero ahora alineado con
  /// el radio de tarjeta estándar (16).
  static BoxDecoration statCard({
    required Color color,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          color.withOpacity(0.08),
          color.withOpacity(0.03),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(AppRadii.cardRadius),
      border: Border.all(
        color: color.withOpacity(0.18),
        width: 1,
      ),
    );
  }

  /// Decoración flotante (modales, dropdowns) — sí usa sombra.
  static BoxDecoration elevated({Color? color}) {
    return BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(AppRadii.radiusMD),
      boxShadow: AppShadows.shadowMD,
    );
  }
}
