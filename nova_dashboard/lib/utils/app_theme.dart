// lib/utils/app_theme.dart
// ============================================================
// FUENTE ÚNICA DE VERDAD — paleta oficial nova-design (Paso 1)
// ============================================================
// Alineado con la paleta oficial de nova-design. Los nombres ya usados en
// 12 archivos del dashboard se mantienen (solo cambió su VALOR). Los
// nombres nuevos son alias de los mismos campos, para que el Paso 2 pueda
// migrar las páginas sin tener que volver a tocar este archivo.
//
// Usados externamente hoy (NO renombrar sin avisar):
//   primary, error, success, warning, info, backgroundGray,
//   gray900, gray600, gray500, gray400, gray300,
//   spaceXXS, spaceXS, spaceSM, spaceMD, spaceLG,
//   radiusSM, radiusMD, lightTheme
//
// REFACTOR: los valores reales viven en lib/utils/theme/ (app_colors.dart,
// app_spacing.dart, app_radii.dart, app_shadows.dart, app_typography.dart,
// app_theme_data.dart, app_decorations.dart), divididos para que ningún
// archivo supere 300 líneas. Esta clase se mantiene como la ÚNICA API
// pública (AppTheme.xxx) para no tener que tocar los 17+ archivos que ya
// la usan — cada campo es un redirect const/getter a su fuente real, sin
// cambiar ni un valor.
// ============================================================

import 'package:flutter/material.dart';
import 'theme/app_colors.dart';
import 'theme/app_decorations.dart';
import 'theme/app_radii.dart';
import 'theme/app_shadows.dart';
import 'theme/app_spacing.dart';
import 'theme/app_theme_data.dart';
import 'theme/app_typography.dart';

class AppTheme {
  AppTheme._();

  // ============================================================
  // MARCA
  // ============================================================
  static const Color primary      = AppColors.primary;
  static const Color primaryDark  = AppColors.primaryDark;
  static const Color primaryLight = AppColors.primaryLight;
  static const Color onPrimary    = AppColors.onPrimary;

  // ============================================================
  // ESTADOS (semánticos)
  // ============================================================
  static const Color success = AppColors.success;
  static const Color warning = AppColors.warning;
  static const Color error   = AppColors.error;
  static const Color info    = AppColors.info;

  // ============================================================
  // SECUNDARIO — DEPRECATED
  // La paleta oficial de nova-design no define una familia "secondary".
  // Se mantienen apuntando a `info` solo por seguridad de compilación.
  // ============================================================
  @Deprecated('La paleta oficial no define "secondary". Usa AppTheme.info.')
  static const Color secondary = AppColors.secondary;
  @Deprecated('La paleta oficial no define "secondary". Usa AppTheme.info.')
  static const Color secondaryDark = AppColors.secondaryDark;
  @Deprecated('La paleta oficial no define "secondary". Usa AppTheme.info.')
  static const Color secondaryLight = AppColors.secondaryLight;

  // ============================================================
  // NEUTROS — escala con tinte teal
  // ============================================================
  static const Color gray900 = AppColors.gray900;
  static const Color gray800 = AppColors.gray800;
  static const Color gray700 = AppColors.gray700;
  static const Color gray600 = AppColors.gray600;
  static const Color gray500 = AppColors.gray500;
  static const Color gray400 = AppColors.gray400;
  static const Color gray300 = AppColors.gray300;
  static const Color gray200 = AppColors.gray200;
  static const Color gray100 = AppColors.gray100;
  static const Color gray50  = AppColors.gray50;

  // ============================================================
  // FONDOS Y SUPERFICIES
  // ============================================================
  static const Color background     = AppColors.background;
  static const Color surface        = AppColors.surface;
  static const Color backgroundGray = AppColors.backgroundGray;
  static const Color bgPage         = AppColors.bgPage;

  // ============================================================
  // TEXTO — nombres semánticos (alias de la escala neutra)
  // ============================================================
  static const Color textHead  = AppColors.textHead;
  static const Color textBody  = AppColors.textBody;
  static const Color textMuted = AppColors.textMuted;

  // ============================================================
  // BORDE
  // ============================================================
  static const Color border = AppColors.border;

  // ============================================================
  // ESPACIADO — escala oficial de 8
  // ============================================================
  static const double space4  = AppSpacing.space4;
  static const double space8  = AppSpacing.space8;
  static const double space16 = AppSpacing.space16;
  static const double space24 = AppSpacing.space24;
  static const double space32 = AppSpacing.space32;

  // Legacy — nombres usados en stat_card.dart y mobile_users/list_tab.dart
  static const double spaceXXS  = AppSpacing.spaceXXS;
  static const double spaceXS   = AppSpacing.spaceXS;
  static const double spaceSM   = AppSpacing.spaceSM;
  static const double spaceMD   = AppSpacing.spaceMD;
  static const double spaceLG   = AppSpacing.spaceLG;
  static const double spaceXL   = AppSpacing.spaceXL;
  static const double spaceXXL  = AppSpacing.spaceXXL;
  static const double spaceXXXL = AppSpacing.spaceXXXL;

  // ============================================================
  // RADIOS
  // ============================================================
  static const double radiusSM   = AppRadii.radiusSM;
  static const double radiusMD   = AppRadii.radiusMD;
  static const double radiusLG   = AppRadii.radiusLG;
  static const double radiusXL   = AppRadii.radiusXL;
  static const double radiusFull = AppRadii.radiusFull;
  static const double cardRadius = AppRadii.cardRadius;

  // ============================================================
  // SOMBRAS — sistema de 3 niveles de nova-design (4bis)
  // ============================================================
  static List<BoxShadow> get cardShadow => AppShadows.cardShadow;
  static List<BoxShadow> get shadowSM => AppShadows.shadowSM;
  static List<BoxShadow> get shadowMD => AppShadows.shadowMD;
  static List<BoxShadow> get shadowLG => AppShadows.shadowLG;

  // ============================================================
  // TIPOGRAFÍA — jerarquía nova-design (mínimo 12px siempre)
  // ============================================================
  static const TextStyle textScreenTitle  = AppTypography.textScreenTitle;
  static const TextStyle textSectionTitle = AppTypography.textSectionTitle;
  static const TextStyle textSubtitle     = AppTypography.textSubtitle;
  static const TextStyle textBodyStyle    = AppTypography.textBodyStyle;
  static const TextStyle textCaption      = AppTypography.textCaption;

  // ============================================================
  // THEME DATA
  // ============================================================
  static ThemeData get lightTheme => AppThemeData.lightTheme;

  // ============================================================
  // DECORACIONES REUTILIZABLES
  // ============================================================
  static BoxDecoration cardDecoration({
    Color? color,
    List<BoxShadow>? boxShadow,
  }) =>
      AppDecorations.card(color: color, boxShadow: boxShadow);

  static BoxDecoration statCardDecoration({required Color color}) =>
      AppDecorations.statCard(color: color);
}
