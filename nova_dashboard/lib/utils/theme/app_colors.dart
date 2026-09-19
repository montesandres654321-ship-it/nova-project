// lib/utils/theme/app_colors.dart
// Paleta de colores — fuente única de verdad, alineada con nova-design.
// Extraído de app_theme.dart (Paso 1) sin cambiar ningún valor.
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ============================================================
  // MARCA
  // ============================================================
  static const Color primary      = Color(0xFF06B6A4);
  static const Color primaryDark  = Color(0xFF048577);
  static const Color primaryLight = Color(0xFFE6F7F5);
  static const Color onPrimary    = Colors.white;

  // ============================================================
  // ESTADOS (semánticos)
  // ============================================================
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color error   = Color(0xFFDC2626);
  static const Color info    = Color(0xFF2563EB);

  // ============================================================
  // SECUNDARIO — deprecado, apunta a info solo por compatibilidad
  // ============================================================
  static const Color secondary      = info;
  static const Color secondaryDark  = info;
  static const Color secondaryLight = info;

  // ============================================================
  // NEUTROS — escala con tinte teal
  // ============================================================
  static const Color gray900 = Color(0xFF1A2B2A);
  static const Color gray800 = Color(0xFF2C3E3D);
  static const Color gray700 = Color(0xFF3F5352);
  static const Color gray600 = Color(0xFF5C7371);
  static const Color gray500 = Color(0xFF5C7371);
  static const Color gray400 = Color(0xFF94A9A7);
  static const Color gray300 = Color(0xFFB7C7C5);
  static const Color gray200 = Color(0xFFE2E8E9);
  static const Color gray100 = Color(0xFFECF1F1);
  static const Color gray50  = Color(0xFFF5F7F8);

  // ============================================================
  // FONDOS Y SUPERFICIES
  // ============================================================
  static const Color background     = Colors.white;
  static const Color surface        = Colors.white;
  static const Color backgroundGray = gray50;
  static const Color bgPage         = backgroundGray;

  // ============================================================
  // TEXTO — nombres semánticos
  // ============================================================
  static const Color textHead  = gray900;
  static const Color textBody  = gray600;
  static const Color textMuted = gray400;

  // ============================================================
  // BORDE
  // ============================================================
  static const Color border = gray200;

  // ============================================================
  // PALETA "SLATE" — alias semánticos (Sprint 4, Parte A)
  // ============================================================
  // Escala tipo Tailwind slate, duplicada de forma idéntica en ~6
  // archivos *_tokens.dart de páginas del dashboard (admin, places,
  // place_details, profile, settings). NO coincide exactamente con la
  // escala gray50-900 de arriba (p.ej. slateBorder 0xFFE2E8F0 vs
  // border 0xFFE2E8E9) — por decisión de CTO se preserva como alias
  // propio en vez de forzarla a la escala teal existente, para no
  // cambiar el valor exacto que ya usan esas páginas.
  static const Color slateTextHead  = Color(0xFF0F172A);
  static const Color slateTextMuted = Color(0xFF64748B);
  static const Color slateTextSub   = Color(0xFF94A3B8);
  static const Color slateBorder    = Color(0xFFE2E8F0);
  static const Color slateBgPage    = Color(0xFFF1F5F9);
  static const Color slateBgCard    = Color(0xFFF8FAFC);
  static const Color slateBlue      = Color(0xFF3B82F6);
  static const Color slateAmber     = Color(0xFFF59E0B);
  static const Color slateGreen     = Color(0xFF10B981);
  static const Color slateRed       = Color(0xFFEF4444);
}
