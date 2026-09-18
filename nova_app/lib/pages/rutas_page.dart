// lib/pages/rutas_page.dart
// ============================================================
// PANTALLA RUTAS TURÍSTICAS — Nova App Móvil (NUEVA)
// ============================================================
// Lista de rutas curadas (datos mock — la BD no tiene tabla de rutas
// aún, per NOVA_MAPA_RUTAS_SCAN_RECOMPENSAS_PLAN.md PASO 4). El botón
// "Consultar" de cada tarjeta no tiene acción todavía (pantalla de
// detalle futura); la ruta destacada "Ruta oficial Juegos 2027" sí
// navega a una pantalla real (ruta_juegos_page.dart).
//
// Diseño Figma Septiembre 2026, node 7:39.
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/design/app_colors.dart';
import 'ruta_juegos_page.dart';

class _Ruta {
  final String imagePath;
  final String etiqueta;
  final String titulo;
  final String subtitulo;
  final double rating;
  const _Ruta(this.imagePath, this.etiqueta, this.titulo, this.subtitulo, this.rating);
}

const _kRutas = [
  _Ruta('assets/images/rutas/foto-escenarios-deportivos.png', '1 día · 4 escenarios',
      'Escenarios deportivos', 'Sincelejo · recorre las sedes de los Juegos', 4.9),
  _Ruta('assets/images/rutas/foto-cultura-patrimonio.png', '1 día · 5 paradas',
      'Cultura y patrimonio', 'Sincelejo · historia y tradición sabanera', 4.8),
  _Ruta('assets/images/rutas/foto-gastronomia.png', '1 día · 3 degustaciones',
      'Gastronomía y platos típicos', 'Coveñas, Tolú y Sincelejo', 4.9),
  _Ruta('assets/images/rutas/foto-naturaleza-parques.png', '1 día · 4 parques',
      'Naturaleza y parques', 'Coveñas y Santiago de Tolú', 4.7),
  _Ruta('assets/images/rutas/foto-compras-artesanias.png', '1 día · 3 mercados',
      'Compras y artesanías', 'Los tres municipios sede', 4.8),
];

class RutasPage extends StatelessWidget {
  const RutasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rutas en Coveñas, Santiago de Tolú y Sincelejo',
                      style: GoogleFonts.openSans(fontSize: 19, fontWeight: FontWeight.w700, color: AppColors.bienvenidaTextoFuerte),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Recorridos curados para descubrir lo mejor de los tres municipios sede.',
                      style: GoogleFonts.openSans(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: _buildBannerJuegos(context),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  children: [
                    for (final r in _kRutas) ...[
                      _buildTarjetaRuta(r),
                      const SizedBox(height: 14),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Banner destacado hacia la ruta oficial de los Juegos 2027
  Widget _buildBannerJuegos(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RutaJuegosPage())),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bienvenidaAzul,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Ruta oficial Juegos Nacionales 2027',
                    style: GoogleFonts.openSans(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '3 días · Coveñas, Santiago de Tolú y Sincelejo',
                    style: GoogleFonts.openSans(fontSize: 12, color: AppColors.bienvenidaAzulClaro),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTarjetaRuta(_Ruta r) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.bienvenidaBorde)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: Image.asset(r.imagePath, width: double.infinity, height: 120, fit: BoxFit.cover),
              ),
              Positioned(
                left: 12,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(999)),
                  child: Text(
                    r.etiqueta,
                    style: GoogleFonts.openSans(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.titulo, style: GoogleFonts.openSans(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.bienvenidaTextoFuerte)),
                const SizedBox(height: 6),
                Text(r.subtitulo, style: GoogleFonts.openSans(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    SvgPicture.asset('assets/icons/ic-estrella.svg', width: 13),
                    const SizedBox(width: 8),
                    Text('${r.rating}', style: GoogleFonts.openSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.bienvenidaTextoFuerte)),
                    const Spacer(),
                    // Sin pantalla de detalle todavía — placeholder intencional
                    Text('Consultar', style: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.bienvenidaVerde)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
