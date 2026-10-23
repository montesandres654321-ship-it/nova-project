// lib/utils/theme/app_typography.dart
// Jerarquía tipográfica — alineada con nova_app AppTextStyles.
// Escala y pesos idénticos a la app móvil para garantizar coherencia visual.
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  // ── Equivalencias con nova_app AppTextStyles ─────────────────────────────
  // headlineLg → textScreenTitle   (26px, w800)
  // headline   → textHeadline      (22px, w700)
  // title      → textSectionTitle  (18px, w700)
  // titleMd    → textSubtitle      (16px, w700)
  // label      → textLabel         (14px, w600)
  // body       → textBodyStyle     (14px, w400)
  // bodySm     → textBodySm        (13px, w400)
  // caption    → textCaption       (12px, w500)
  // sectionLabel → textSectionLabel(11px, w600)
  // ─────────────────────────────────────────────────────────────────────────

  static const TextStyle textScreenTitle = TextStyle(
    fontSize: 26, fontWeight: FontWeight.w800,
    color: AppColors.textHead, letterSpacing: -0.3,
  );
  static const TextStyle textHeadline = TextStyle(
    fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textHead,
  );
  static const TextStyle textSectionTitle = TextStyle(
    fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textHead,
  );
  static const TextStyle textSubtitle = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textHead,
  );
  static const TextStyle textLabel = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textHead,
  );
  static const TextStyle textBodyStyle = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w400,
    color: AppColors.textBody, height: 1.5,
  );
  static const TextStyle textBodySm = TextStyle(
    fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textBody,
  );
  static const TextStyle textCaption = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textMuted,
  );
  static const TextStyle textSectionLabel = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w600,
    color: AppColors.textMuted, letterSpacing: 0.8,
  );
}
