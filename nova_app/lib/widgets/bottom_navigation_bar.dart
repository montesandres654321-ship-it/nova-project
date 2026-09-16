// lib/widgets/bottom_navigation_bar.dart
// ============================================================
// BARRA DE NAVEGACIÓN INFERIOR — Nova App Móvil
// ============================================================
// Extraído de main_navigation_page.dart (FASE 4, PASO 4.5 del refactor).
// Se nombra `MainBottomNavBar` (no `BottomNavigationBar`) para no
// chocar con la clase homónima de Flutter Material.
// ============================================================

import 'package:flutter/material.dart';
import '../core/design/app_colors.dart';
import '../core/design/app_spacing.dart';
import '../core/design/app_radius.dart';

class MainBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const MainBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: AppColors.surface,
      elevation: 8,
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Inicio'),
                _buildNavItem(1, Icons.explore_rounded, Icons.explore_outlined, 'Explorar'),
              ],
            ),
          ),
          const SizedBox(width: 72),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(2, Icons.history_rounded, Icons.history_outlined, 'Historial'),
                _buildNavItem(3, Icons.person_rounded, Icons.person_outlined, 'Perfil'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData activeIcon,
    IconData inactiveIcon,
    String label,
  ) {
    final selected = currentIndex == index;
    return InkWell(
      onTap: () => onTap(index),
      borderRadius: AppRadius.smAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon con fade entre activo/inactivo
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Icon(
                selected ? activeIcon : inactiveIcon,
                key: ValueKey('${label}_$selected'),
                color: selected ? AppColors.primary : AppColors.textHint,
                size: 24,
              ),
            ),
            const SizedBox(height: 2),
            // Label con transición de estilo
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              style: TextStyle(
                fontSize: 10,
                color: selected ? AppColors.primary : AppColors.textHint,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
