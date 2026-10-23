// lib/pages/ruta_patrimonio_page.dart
// ============================================================
// RUTA PATRIMONIO — Historia y cultura
// Carrusel "Rutas y recorridos", índice 1
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design/app_colors.dart';
import '../models/place_model.dart';
import '../services/api_service.dart';
import 'place_detail_page.dart';

// ── Colores locales ─────────────────────────────────────────
const _kFondo    = Color(0xFFFFF8F0);
const _kAmbar1   = Color(0xFF78350F);
const _kAmbar2   = Color(0xFFB45309);
const _kChip     = Color(0xFFFCD34D);

// ── Paradas curadas de la ruta ───────────────────────────────
class _Parada {
  final IconData icono;
  final String titulo;
  final String descripcion;
  final String tiempo;
  const _Parada(this.icono, this.titulo, this.descripcion, this.tiempo);
}

const _kParadas = [
  _Parada(Icons.account_balance_rounded,
      'Plaza Mayor de Sincelejo',
      'El corazón histórico del departamento. Catedral, palacio de gobierno y monumento al sombrero vueltiao.',
      '8:30 AM'),
  _Parada(Icons.museum_rounded,
      'Casa de la Cultura',
      'Exposición permanente de artesanías locales: sombreros vueltiao, tapices y mochilas wayuu.',
      '10:00 AM'),
  _Parada(Icons.architecture_rounded,
      'Barrio del Centro Histórico',
      'Casonas coloniales del siglo XIX, calles empedradas y murales del Festival del Porro.',
      '11:30 AM'),
  _Parada(Icons.local_activity_rounded,
      'Mercado de Sampués',
      'El municipio artesanal de Colombia. Talleres en vivo y venta directa de artesanos.',
      '2:00 PM'),
];

class RutaPatrimonioPage extends StatefulWidget {
  const RutaPatrimonioPage({super.key});

  @override
  State<RutaPatrimonioPage> createState() => _RutaPatrimonioPageState();
}

class _RutaPatrimonioPageState extends State<RutaPatrimonioPage> {
  List<Place> _lugares = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarLugares();
  }

  Future<void> _cargarLugares() async {
    try {
      final data = await ApiService.getPlacesByType('cultura');
      if (mounted) setState(() { _lugares = data; _cargando = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _cargando = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kFondo,
      body: CustomScrollView(
        slivers: [
          _buildHero(context),
          SliverToBoxAdapter(child: _buildStats()),
          SliverToBoxAdapter(child: _buildItinerario()),
          SliverToBoxAdapter(child: _buildLugaresSection()),
          SliverToBoxAdapter(child: _buildDatos()),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  // ── Hero ────────────────────────────────────────────────────
  Widget _buildHero(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      backgroundColor: _kAmbar1,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/rutas/foto-ruta-patrimonio.png',
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _kAmbar1.withValues(alpha: 0.3),
                    _kAmbar1.withValues(alpha: 0.85),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _kChip.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: _kChip.withValues(alpha: 0.5)),
                    ),
                    child: Text('Ruta Patrimonio',
                        style: GoogleFonts.openSans(fontSize: 11, fontWeight: FontWeight.w600, color: _kChip)),
                  ),
                  const SizedBox(height: 8),
                  Text('Historia y cultura',
                      style: GoogleFonts.openSans(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Sincelejo · Sampués · Patrimonio sabanero',
                      style: GoogleFonts.openSans(fontSize: 12, color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Stats chips ─────────────────────────────────────────────
  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _chip(Icons.schedule_rounded, '1 día completo'),
          _chip(Icons.location_on_rounded, '4 paradas'),
          _chip(Icons.directions_walk_rounded, 'Nivel fácil'),
          _chip(Icons.style_rounded, 'Sombrero vueltiao'),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _kAmbar2.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _kAmbar1),
          const SizedBox(width: 6),
          Text(label,
              style: GoogleFonts.openSans(fontSize: 12, fontWeight: FontWeight.w600, color: _kAmbar1)),
        ],
      ),
    );
  }

  // ── Itinerario ───────────────────────────────────────────────
  Widget _buildItinerario() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Itinerario del día',
              style: GoogleFonts.openSans(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.bienvenidaTextoFuerte)),
          const SizedBox(height: 14),
          for (int i = 0; i < _kParadas.length; i++) ...[
            _buildParada(_kParadas[i]),
            if (i < _kParadas.length - 1)
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Container(width: 2, height: 20, color: _kAmbar2.withValues(alpha: 0.25)),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildParada(_Parada p) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(color: _kAmbar1, shape: BoxShape.circle),
          child: Icon(p.icono, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.bienvenidaBorde),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(p.titulo,
                          style: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.w700,
                              color: AppColors.bienvenidaTextoFuerte)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _kFondo,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(p.tiempo,
                          style: GoogleFonts.openSans(fontSize: 11, fontWeight: FontWeight.w600, color: _kAmbar1)),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(p.descripcion,
                    style: GoogleFonts.openSans(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Lugares del backend ─────────────────────────────────────
  Widget _buildLugaresSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sitios culturales registrados',
              style: GoogleFonts.openSans(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.bienvenidaTextoFuerte)),
          const SizedBox(height: 4),
          Text('Museos, galerías y centros culturales',
              style: GoogleFonts.openSans(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 14),
          _buildLugaresContent(),
        ],
      ),
    );
  }

  Widget _buildLugaresContent() {
    if (_cargando) {
      return const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Center(
        child: Column(
          children: [
            Text('No se pudo cargar los lugares',
                style: GoogleFonts.openSans(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            TextButton(onPressed: _cargarLugares, child: const Text('Reintentar')),
          ],
        ),
      );
    }
    if (_lugares.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text('Próximamente más sitios culturales',
              style: GoogleFonts.openSans(fontSize: 13, color: AppColors.textHint)),
        ),
      );
    }
    return Column(children: _lugares.map((p) => _buildLugarCard(p)).toList());
  }

  Widget _buildLugarCard(Place place) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PlaceDetailPage(place: place))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.bienvenidaBorde),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
              child: place.imageUrl != null
                  ? Image.network(place.imageUrl!, width: 80, height: 80, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholderImg())
                  : _placeholderImg(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(place.displayName,
                        style: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.w700,
                            color: AppColors.bienvenidaTextoFuerte)),
                    const SizedBox(height: 3),
                    Text('${place.tipoEmoji} ${place.tipoLabel}',
                        style: GoogleFonts.openSans(fontSize: 11, color: AppColors.textSecondary)),
                    if (place.lugar != null) ...[
                      const SizedBox(height: 2),
                      Text(place.lugar!,
                          style: GoogleFonts.openSans(fontSize: 11, color: AppColors.textHint)),
                    ],
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderImg() {
    return Container(
      width: 80,
      height: 80,
      color: _kFondo,
      child: const Icon(Icons.museum_rounded, color: _kAmbar2, size: 28),
    );
  }

  // ── Datos culturales ─────────────────────────────────────────
  Widget _buildDatos() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _kAmbar1,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.emoji_events_rounded, color: _kChip, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Patrimonio nacional',
                      style: GoogleFonts.openSans(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('El sombrero vueltiao de Sampués es Patrimonio Cultural Inmaterial de la Humanidad (UNESCO 2017).',
                      style: GoogleFonts.openSans(fontSize: 12, color: Colors.white70, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
