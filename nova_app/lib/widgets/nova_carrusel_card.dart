// lib/widgets/nova_carrusel_card.dart
// ============================================================
// TARJETA DE CARRUSEL — Nova App Móvil
// ============================================================
// Tarjeta reutilizable de 150px de ancho con foto (96px) + título +
// subtítulo. Usada en las secciones de carrusel horizontal de Home
// (Juegos 2027, municipios, rutas, naturaleza, sabores) — diseño
// Figma Septiembre 2026 (NOVA_HOME_EXPLORAR_PLAN.md).
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design/app_colors.dart';

class NovaCarruselCard extends StatelessWidget {
  final String imagePath;
  final String titulo;
  final String subtitulo;
  final VoidCallback? onTap;

  const NovaCarruselCard({
    super.key,
    required this.imagePath,
    required this.titulo,
    required this.subtitulo,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.asset(
                imagePath,
                width: 150,
                height: 96,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    titulo,
                    style: GoogleFonts.openSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.bienvenidaTextoFuerte,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitulo,
                    style: GoogleFonts.openSans(
                      fontSize: 10,
                      color: AppColors.textHint,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
