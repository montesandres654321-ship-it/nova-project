// lib/widgets/action_buttons.dart
// ============================================================
// GRID DE ACCESOS RÁPIDOS — Nova App Móvil
// ============================================================
// Extraído de home_page.dart (FASE 3, PASO 3.2 del refactor).
// Grid 2×2: Historial, Lugares, Mi Perfil, Ajustes.
// ============================================================

import 'package:flutter/material.dart';
import '../core/design/app_colors.dart';
import '../core/design/app_spacing.dart';
import '../core/design/app_radius.dart';

class ActionButtons extends StatelessWidget {
  final void Function(int) onNavigateToTab;

  const ActionButtons({super.key, required this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Accesos rápidos',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppSpacing.sm,
          mainAxisSpacing: AppSpacing.sm,
          childAspectRatio: 1.7,
          children: [
            _buildGridItem(
              Icons.history_rounded,
              'Historial',
              () => onNavigateToTab(2),
            ),
            _buildGridItem(
              Icons.explore_rounded,
              'Lugares',
              () => onNavigateToTab(1),
            ),
            _buildGridItem(
              Icons.person_outline_rounded,
              'Mi Perfil',
              () => onNavigateToTab(3),
            ),
            _buildGridItem(
              Icons.settings_outlined,
              'Ajustes',
              () => Navigator.pushNamed(context, '/settings'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGridItem(IconData icon, String label, VoidCallback onTap) {
    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.mdAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdAll,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppRadius.mdAll,
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: AppRadius.smAll,
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
