// lib/widgets/welcome_card.dart
// ============================================================
// SALUDO DE BIENVENIDA — Nova App Móvil
// ============================================================
// Extraído de home_page.dart (FASE 3, PASO 3.2 del refactor).
// Header con saludo personalizado + botón de cerrar sesión. El plan
// mencionaba un "avatar", pero el original no tiene uno — no se
// inventa, se reproduce solo lo que existía.
// ============================================================

import 'package:flutter/material.dart';
import '../core/design/app_colors.dart';
import '../core/design/app_spacing.dart';

class WelcomeCard extends StatelessWidget {
  final String userName;
  final String userEmail;
  final VoidCallback onLogout;

  const WelcomeCard({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hola, $userName',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  userEmail.isNotEmpty ? userEmail : 'Bienvenido a Nova',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onLogout,
            icon: const Icon(Icons.logout_rounded, size: 22),
            color: AppColors.textSecondary,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
    );
  }
}
