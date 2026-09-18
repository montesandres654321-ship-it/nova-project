// lib/widgets/nova_chip.dart
// ============================================================
// CHIP ACTIVO/INACTIVO — Nova App Móvil
// ============================================================
// Chip reutilizable para filtros de categoría/municipio en Home y
// Explorar. El color activo y el estilo del inactivo (con o sin
// borde) varían según la pantalla — ver NOVA_HOME_EXPLORAR_PLAN.md.
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design/app_colors.dart';

class NovaChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback? onTap;

  /// Color de fondo cuando [active] es true (verde en Home/municipios,
  /// dorado en categorías de Explorar).
  final Color activeColor;

  /// Color de fondo cuando [active] es false.
  final Color inactiveBackground;

  /// Home usa borde en el estado inactivo; Explorar no.
  final bool inactiveHasBorder;

  const NovaChip({
    super.key,
    required this.label,
    required this.active,
    this.onTap,
    this.activeColor = AppColors.bienvenidaVerde,
    this.inactiveBackground = Colors.white,
    this.inactiveHasBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: active ? activeColor : inactiveBackground,
          borderRadius: BorderRadius.circular(999),
          border: (!active && inactiveHasBorder)
              ? Border.all(color: AppColors.bienvenidaBorde)
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.openSans(
            fontSize: 10,
            fontWeight: active ? FontWeight.w600 : FontWeight.w500,
            color: active ? Colors.white : AppColors.bienvenidaTextoMedio,
          ),
        ),
      ),
    );
  }
}
