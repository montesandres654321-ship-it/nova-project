// lib/pages/cultura_page.dart
// ============================================================
// PANTALLA CULTURA — Juegos Nacionales 2027 · Nova App Móvil
// ============================================================
// Datos tenttativos / hardcoded — entorno de pruebas.
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design/app_colors.dart';

class _EventoCultural {
  final IconData icono;
  final String nombre;
  final String descripcion;
  final String fecha;
  final String lugar;
  const _EventoCultural({
    required this.icono,
    required this.nombre,
    required this.descripcion,
    required this.fecha,
    required this.lugar,
  });
}

const _kEventos = [
  _EventoCultural(
    icono: Icons.music_note_rounded,
    nombre: 'Festival Folclórico del Golfo',
    descripcion: 'Porro, cumbia y mapalé en escenarios abiertos de Tolú y Coveñas.',
    fecha: '10–12 Oct 2027',
    lugar: 'Santiago de Tolú',
  ),
  _EventoCultural(
    icono: Icons.palette_rounded,
    nombre: 'Exposición Artesanías de Sucre',
    descripcion: 'Muestra de cestería, sombrero vueltiao y cerámica de Sampués.',
    fecha: '11–18 Oct 2027',
    lugar: 'Sincelejo',
  ),
  _EventoCultural(
    icono: Icons.theater_comedy_rounded,
    nombre: 'Noche de Leyendas Costeñas',
    descripcion: 'Teatro callejero con personajes de la tradición oral del Caribe.',
    fecha: '13 Oct 2027',
    lugar: 'Coveñas',
  ),
  _EventoCultural(
    icono: Icons.restaurant_rounded,
    nombre: 'Feria Gastronómica del Golfo',
    descripcion: 'Mote de queso, arroz con leche de coco, frutos del mar y más.',
    fecha: '14–16 Oct 2027',
    lugar: 'Santiago de Tolú',
  ),
  _EventoCultural(
    icono: Icons.local_library_rounded,
    nombre: 'Ruta Patrimonial Sincelejo',
    descripcion: 'Recorrido guiado por la arquitectura republicana del centro histórico.',
    fecha: '15 Oct 2027',
    lugar: 'Sincelejo',
  ),
  _EventoCultural(
    icono: Icons.camera_alt_rounded,
    nombre: 'Concurso Fotografía Turística',
    descripcion: 'Capta la esencia del Golfo de Morrosquillo. Premios a los mejores retratos.',
    fecha: '10–20 Oct 2027',
    lugar: 'Toda la región',
  ),
];

class CulturaPage extends StatelessWidget {
  const CulturaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHero(context),
              const SizedBox(height: 24),
              _buildSectionTitle('Eventos y tradición'),
              const SizedBox(height: 14),
              _buildEventos(),
              const SizedBox(height: 24),
              _buildBannerInfo(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 240,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Foto de portada
            Image.asset(
              'assets/images/rutas/foto-cultura-patrimonio.png',
              fit: BoxFit.cover,
            ),
            // Gradiente púrpura encima
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF6B21A8).withValues(alpha: 0.30),
                    const Color(0xFF4C1D95).withValues(alpha: 0.88),
                  ],
                ),
              ),
            ),
            // Contenido
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.40)),
                    ),
                    child: Text(
                      'Juegos Nacionales y Paranacionales',
                      style: GoogleFonts.openSans(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Cultura 2027',
                    style: GoogleFonts.openSans(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Eventos, tradiciones y patrimonio del Golfo de Morrosquillo',
                    style: GoogleFonts.openSans(fontSize: 13, color: Colors.white.withValues(alpha: 0.85)),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _buildStatChip(Icons.event_rounded, '${_kEventos.length}', 'Eventos'),
                      const SizedBox(width: 10),
                      _buildStatChip(Icons.location_city_rounded, '3', 'Municipios'),
                      const SizedBox(width: 10),
                      _buildStatChip(Icons.calendar_month_rounded, 'Oct', '2027'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String valor, String etiqueta) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(valor, style: GoogleFonts.openSans(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
              Text(etiqueta, style: GoogleFonts.openSans(fontSize: 9, color: Colors.white.withValues(alpha: 0.8))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String titulo) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        titulo,
        style: GoogleFonts.openSans(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF6B21A8)),
      ),
    );
  }

  Widget _buildEventos() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          for (var i = 0; i < _kEventos.length; i++) ...[
            _buildCardEvento(_kEventos[i], i == 0),
            if (i != _kEventos.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildCardEvento(_EventoCultural e, bool destacado) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: destacado ? const Color(0xFFF5F0FF) : Colors.white,
        border: Border.all(
          color: destacado
              ? const Color(0xFF6B21A8).withValues(alpha: 0.25)
              : AppColors.bienvenidaBorde,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: destacado ? const Color(0xFF6B21A8) : const Color(0xFFF5F0FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(e.icono, size: 22, color: destacado ? Colors.white : const Color(0xFF6B21A8)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.nombre,
                    style: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.bienvenidaTextoFuerte)),
                const SizedBox(height: 4),
                Text(e.descripcion,
                    style: GoogleFonts.openSans(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildBadge(Icons.calendar_today_rounded, e.fecha),
                    const SizedBox(width: 8),
                    _buildBadge(Icons.location_on_rounded, e.lugar),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: AppColors.textHint),
          const SizedBox(width: 4),
          Text(texto, style: GoogleFonts.openSans(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildBannerInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F0FF),
          border: Border.all(color: const Color(0xFF6B21A8).withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(color: Color(0xFF6B21A8), shape: BoxShape.circle),
              child: const Icon(Icons.info_outline_rounded, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Información tentativa',
                      style: GoogleFonts.openSans(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF6B21A8))),
                  const SizedBox(height: 3),
                  Text('La programación cultural oficial se publicará próximamente en el portal de los Juegos Nacionales 2027.',
                      style: GoogleFonts.openSans(fontSize: 11, color: AppColors.textSecondary, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
