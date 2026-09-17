// lib/utils/theme/app_decorations.dart
// Decoraciones reutilizables — extraído de app_theme.dart sin cambiar
// comportamiento.
import 'package:flutter/material.dart';
import 'app_radii.dart';
import 'app_shadows.dart';

class AppDecorations {
  AppDecorations._();

  static BoxDecoration card({
    Color? color,
    List<BoxShadow>? boxShadow,
  }) {
    return BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(AppRadii.cardRadius),
      boxShadow: boxShadow ?? AppShadows.cardShadow,
    );
  }

  static BoxDecoration statCard({
    required Color color,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          color.withOpacity(0.1),
          color.withOpacity(0.05),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(AppRadii.radiusMD),
      border: Border.all(
        color: color.withOpacity(0.2),
        width: 1,
      ),
    );
  }
}
