// lib/utils/theme/app_typography.dart
// Jerarquía tipográfica nova-design — extraído de app_theme.dart sin
// cambiar valores.
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static const TextStyle textScreenTitle = TextStyle(
    fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textHead, fontFamily: 'Roboto',
  );
  static const TextStyle textSectionTitle = TextStyle(
    fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textHead, fontFamily: 'Roboto',
  );
  static const TextStyle textSubtitle = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textHead, fontFamily: 'Roboto',
  );
  static const TextStyle textBodyStyle = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textBody, fontFamily: 'Roboto',
  );
  static const TextStyle textCaption = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textMuted, fontFamily: 'Roboto',
  );
}
