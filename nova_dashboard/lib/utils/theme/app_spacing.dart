// lib/utils/theme/app_spacing.dart
// Escala de espaciado — extraído de app_theme.dart sin cambiar valores.
class AppSpacing {
  AppSpacing._();

  // Escala oficial de 8
  static const double space4  = 4.0;
  static const double space8  = 8.0;
  static const double space16 = 16.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;

  // Legacy — nombres usados en stat_card.dart y mobile_users/list_tab.dart
  static const double spaceXXS = space4;
  static const double spaceXS  = space8;
  static const double spaceSM  = 12.0; // legacy — no está en la escala oficial de 8
  static const double spaceMD  = space16;
  static const double spaceLG  = space24;
  static const double spaceXL  = space32;
  static const double spaceXXL  = 48.0;
  static const double spaceXXXL = 64.0;
}
