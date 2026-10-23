// lib/utils/theme/app_colors.dart
// Paleta de colores — fuente única de verdad, alineada con nova-design.
// Extraído de app_theme.dart (Paso 1) sin cambiar ningún valor.
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ============================================================
  // MARCA
  // ============================================================
  static const Color primary             = Color(0xFF06B6A4);
  static const Color primaryDark         = Color(0xFF048577);
  // Variante profunda del primary (teal-800, Tailwind) — usada en login
  // como overlay sutil y en gradientes de profundidad.
  static const Color primaryDeep         = Color(0xFF0F766E);
  // Extremo del gradiente en profile_header — cyan-600, un tono
  // más frío que el primary para dar profundidad al gradiente.
  static const Color primaryGradientEnd  = Color(0xFF0891B2);
  // Acento claro del gradiente de login background — cyan-200.
  // Tono muy suave para el extremo derecho del gradiente de la pantalla de login.
  static const Color primaryAccentLight  = Color(0xFF67E8F9);
  static const Color primaryLight        = Color(0xFFE6F7F5);
  static const Color onPrimary           = Colors.white;

  // Fondo alternativo neutro — usado en pantallas de error y scaffolds
  // sin contenido (no coincide exactamente con gray50 ni slateBgPage).
  static const Color backgroundAlt       = Color(0xFFF5F5F5);

  // ============================================================
  // ESTADOS (semánticos) — alineados con nova_app AppColors
  // ============================================================
  static const Color success = Color(0xFF10B981); // = slateGreen, = AppColors.success móvil
  static const Color warning = Color(0xFFF59E0B); // = slateAmber, igual en ambos
  static const Color error   = Color(0xFFEF4444); // = slateRed,   = AppColors.error móvil
  static const Color info    = Color(0xFF0EA5E9); // sky-500, alineado con nova_app

  // ============================================================
  // SECUNDARIO — deprecado, apunta a info solo por compatibilidad
  // ============================================================
  static const Color secondary      = info;
  static const Color secondaryDark  = info;
  static const Color secondaryLight = info;

  // ============================================================
  // NEUTROS — alineados con nova_app AppColors (escala Tailwind Gray)
  // ============================================================
  static const Color gray900 = Color(0xFF111827); // = AppColors.textPrimary móvil
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray600 = Color(0xFF6B7280); // = AppColors.textSecondary móvil
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray400 = Color(0xFF9CA3AF); // = AppColors.textHint móvil
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray200 = Color(0xFFE5E7EB); // = AppColors.border móvil
  static const Color gray100 = Color(0xFFF3F4F6); // = AppColors.surfaceVariant móvil
  static const Color gray50  = Color(0xFFF9FAFB);

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

  // ============================================================
  // LOGROS Y RANGOS — colores semánticos de gamificación
  // ============================================================
  // Color de bronce (tercer lugar) — amber-800 de Tailwind.
  // Usado en el podio de visitantes frecuentes (visitors_page).
  static const Color rankBronce = Color(0xFF92400E);

  // ============================================================
  // TIPOS DE LUGAR (QR) — colores semánticos por categoría
  // Usados en qr_type_style.dart para identificar visualmente
  // cada tipo de establecimiento en el mapa de QRs.
  // Alineados con la paleta Tailwind (escala 600-700).
  // ============================================================
  // Colores principales (texto / ícono)
  static const Color tipoHotel             = Color(0xFF2563EB); // blue-600
  static const Color tipoGastronomia       = Color(0xFF059669); // emerald-600
  static const Color tipoBar               = Color(0xFFD97706); // amber-600
  static const Color tipoDeportivo         = Color(0xFFDC2626); // red-600
  static const Color tipoNaturaleza        = Color(0xFF0D9488); // teal-600
  static const Color tipoArtesania         = Color(0xFF7C3AED); // violet-600
  static const Color tipoPlaya             = Color(0xFF0284C7); // sky-600
  static const Color tipoRuta              = Color(0xFF4F46E5); // indigo-600
  static const Color tipoCompras           = Color(0xFFDB2777); // pink-600
  // Colores de fondo (chip / card ligero)
  static const Color tipoHotelBg           = Color(0xFFDBEAFE); // blue-100
  static const Color tipoGastronomiaBg     = Color(0xFFD1FAE5); // emerald-100
  static const Color tipoBarBg             = Color(0xFFFEF3C7); // amber-100
  static const Color tipoDeportivoBg       = Color(0xFFFEE2E2); // red-100
  static const Color tipoNaturalezaBg      = Color(0xFFCCFBF1); // teal-100
  static const Color tipoArtesaniaBg       = Color(0xFFEDE9FE); // violet-100
  static const Color tipoPLayaBg           = Color(0xFFE0F2FE); // sky-100
  static const Color tipoRutaBg            = Color(0xFFE0E7FF); // indigo-100
  static const Color tipoComprasBg         = Color(0xFFFCE7F3); // pink-100
  static const Color tipoDefaultBg         = Color(0xFFE0F7FA); // cyan-50
}
