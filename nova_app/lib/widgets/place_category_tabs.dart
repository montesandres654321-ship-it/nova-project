// lib/widgets/place_category_tabs.dart
// ============================================================
// TABS DE CATEGORÍA DE LUGARES — Nova App Móvil
// ============================================================
// Extraído de places_page.dart (FASE 3, PASO 3.4 del refactor).
// TabBar de Hoteles/Restaurantes/Bares para usar en el `bottom` del
// AppBar de places_page. El TabController lo sigue creando y
// gestionando places_page (dueño del ciclo de vida del vsync).
// ============================================================

import 'package:flutter/material.dart';
import '../core/design/app_colors.dart';

class PlaceCategoryTabs extends StatelessWidget implements PreferredSizeWidget {
  final TabController controller;

  const PlaceCategoryTabs({super.key, required this.controller});

  static const List<Tab> _tabs = [
    Tab(text: 'Hoteles'),
    Tab(text: 'Restaurantes'),
    Tab(text: 'Bares'),
  ];

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      tabs: _tabs,
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.textSecondary,
      indicatorColor: AppColors.primary,
      indicatorWeight: 2,
      labelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 14,
      ),
      dividerColor: AppColors.border,
    );
  }

  // Delegar en el preferredSize real de TabBar (depende de indicatorWeight
  // y de los tabs) en vez de asumir una altura fija.
  @override
  Size get preferredSize => const TabBar(tabs: _tabs).preferredSize;
}
