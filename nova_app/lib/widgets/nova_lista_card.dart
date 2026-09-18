// lib/widgets/nova_lista_card.dart
// ============================================================
// TARJETA DE LISTA HORIZONTAL — Nova App Móvil
// ============================================================
// Tarjeta reutilizable: foto + nombre + descripción + rating (+
// opcional "N lugares" y línea de beneficio). Usada en "Lo mejor
// valorado" (Home), tarjetas de municipio (Explorar) y "Lugares"
// (Municipio) — el tamaño de foto y las líneas opcionales varían por
// contexto. Diseño Figma Septiembre 2026 (NOVA_HOME_EXPLORAR_PLAN.md).
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design/app_colors.dart';

class NovaListaCard extends StatelessWidget {
  final String imagePath;
  final String nombre;
  final String descripcion;
  final double rating;
  final int? reviews;
  final int? nLugares;
  final String? beneficioTexto;
  final double photoSize;
  final VoidCallback? onTap;

  const NovaListaCard({
    super.key,
    required this.imagePath,
    required this.nombre,
    required this.descripcion,
    required this.rating,
    this.reviews,
    this.nLugares,
    this.beneficioTexto,
    this.photoSize = 72,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.fromLTRB(10, 10, 14, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imagePath.startsWith('http')
                  ? Image.network(
                      imagePath,
                      width: photoSize,
                      height: photoSize,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : Image.asset(
                      imagePath,
                      width: photoSize,
                      height: photoSize,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    nombre,
                    style: GoogleFonts.openSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.bienvenidaTextoFuerte,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    descripcion,
                    style: GoogleFonts.openSans(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 18 / 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SvgPicture.asset('assets/icons/ic-estrella.svg', width: 13, height: 13),
                      const SizedBox(width: 5),
                      Text(
                        rating.toStringAsFixed(1),
                        style: GoogleFonts.openSans(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      if (reviews != null)
                        Text(
                          ' ($reviews)',
                          style: GoogleFonts.openSans(fontSize: 12, color: AppColors.textHint),
                        ),
                      if (nLugares != null) ...[
                        Text(' · ', style: GoogleFonts.openSans(fontSize: 12, color: AppColors.bienvenidaTextoFuerte)),
                        Text(
                          '$nLugares lugares',
                          style: GoogleFonts.openSans(fontSize: 12, color: AppColors.textHint),
                        ),
                      ],
                    ],
                  ),
                  if (beneficioTexto != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        SvgPicture.asset('assets/icons/ic-beneficio.svg', width: 16, height: 16),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            beneficioTexto!,
                            style: GoogleFonts.openSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.bienvenidaAzul,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        width: photoSize,
        height: photoSize,
        color: AppColors.surfaceVariant,
        child: Icon(Icons.image_not_supported_outlined, color: AppColors.textHint, size: photoSize * 0.4),
      );
}
