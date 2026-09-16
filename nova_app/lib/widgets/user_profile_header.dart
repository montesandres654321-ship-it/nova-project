// lib/widgets/user_profile_header.dart
// ============================================================
// AVATAR + NOMBRE + CORREO DEL PERFIL — Nova App Móvil
// ============================================================
// Extraído de profile_page.dart (FASE 3, PASO 3.5 del refactor).
// Avatar con iniciales (gradiente), nombre completo y correo.
// ============================================================

import 'package:flutter/material.dart';
import '../core/design/app_colors.dart';
import '../core/design/app_spacing.dart';

class UserProfileHeader extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String email;

  const UserProfileHeader({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final initial = firstName.isNotEmpty ? firstName[0].toUpperCase() : '?';
    final fullName = '$firstName $lastName'.trim();

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              initial,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.onPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (fullName.isNotEmpty)
          Text(
            fullName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        const SizedBox(height: AppSpacing.xs),
        if (email.isNotEmpty)
          Text(
            email,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}
