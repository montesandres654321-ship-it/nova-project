// lib/pages/platos_tipicos_page.dart
// ============================================================
// PLATOS TÍPICOS — Cocina de Sucre y el Golfo de Morrosquillo
// Carrusel "Sabores y compras locales", índice 1
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design/app_colors.dart';
import '../models/place.dart';
import '../services/api_service.dart';
import 'place_detail_page.dart';

// ── Colores locales ─────────────────────────────────────────
const _kFondo    = Color(0xFFFFF8F0);
const _kNaranja1 = Color(0xFFB45309);
const _kNaranja2 = Color(0xFFD97706);
const _kChip     = Color(0xFFFDE68A);

// ── Platos curados ───────────────────────────────────────────
class _Plato {
  final String emoji;
  final String nombre;
  final String descripcion;
  final String donde;
  const _Plato(this.emoji, this.nombre, this.descripcion, this.donde);
}

const _kPlatos = [
  _Plato('🫔',
      'Arepa de huevo',
      'Masa de maíz frita con huevo entero dentro. Crujiente por fuera, suave por dentro. El desayuno sabanero por excelencia.',
      'Fritas en plazas y esquinas de Sincelejo y Coveñas'),
  _Plato('🦐',
      'Cazuela de mariscos',
      'Caldo espeso de leche de coco con camarones, ostras y pargo. Receta de pescadores del golfo, cocinada a leña.',
      'Restaurantes del malecón de Santiago de Tolú'),
  _Plato('🐟',
      'Pargo rojo frito',
      'Pescado entero de agua salada frito con plátano asado, arroz de coco y ensalada. Plato emblema del litoral sucreño.',
      'Todo el litoral costero de Coveñas y Tolú'),
  _Plato('🥘',
      'Sancocho de sábalo',
      'Sopa robusta con el sábalo del río Sinú, ñame y plátano verde. Tradición de los pueblos ribereños de Sucre.',
      'Restaurantes tradicionales en Sincelejo'),
  _Plato('🫙',
      'Dulce de papayuela',
      'Conserva artesanal de papayuela con panela y especias. Se vende en tarros de vidrio en los mercados locales.',
      'Mercado de Sampués y tiendas de artesanías'),
  _Plato('🧃',
      'Chicha de maíz',
      'Bebida fermentada de maíz amarillo con panela. Fresca y levemente dulce. Parte de las festividades del Porro.',
      'Festivales y mercados populares de la región'),
];

class PlatosTipicosPage extends StatefulWidget {
  const PlatosTipicosPage({super.key});

  @override
  State<PlatosTipicosPage> createState() => _PlatosTipicosPageState();
}

class _PlatosTipicosPageState extends State<PlatosTipicosPage> {
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
      final data = await ApiService.getPlacesByType('gastronomia');
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
          SliverToBoxAdapter(child: _buildIntro()),
          SliverToBoxAdapter(child: _buildPlatosGrid()),
          SliverToBoxAdapter(child: _buildLugaresSection()),
          SliverToBoxAdapter(child: _buildSabiaQue()),
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
      backgroundColor: _kNaranja1,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/gastronomia/foto-platos-tipicos.png',
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _kNaranja1.withValues(alpha: 0.25),
                    _kNaranja1.withValues(alpha: 0.90),
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
                    child: Text('Gastronomía local',
                        style: GoogleFonts.openSans(fontSize: 11, fontWeight: FontWeight.w600, color: _kChip)),
                  ),
                  const SizedBox(height: 8),
                  Text('Platos típicos',
                      style: GoogleFonts.openSans(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Cocina de Sucre · Golfo de Morrosquillo',
                      style: GoogleFonts.openSans(fontSize: 12, color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Intro chips ──────────────────────────────────────────────
  Widget _buildIntro() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _chip('🌊', 'Mariscos frescos'),
          _chip('🥥', 'Coco y leche'),
          _chip('🌽', 'Maíz artesanal'),
          _chip('🔥', 'A leña'),
        ],
      ),
    );
  }

  Widget _chip(String emoji, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _kNaranja2.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 6),
          Text(label,
              style: GoogleFonts.openSans(fontSize: 12, fontWeight: FontWeight.w600, color: _kNaranja1)),
        ],
      ),
    );
  }

  // ── Grilla de platos ─────────────────────────────────────────
  Widget _buildPlatosGrid() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sabores que debes probar',
              style: GoogleFonts.openSans(fontSize: 17, fontWeight: FontWeight.w700,
                  color: AppColors.bienvenidaTextoFuerte)),
          const SizedBox(height: 4),
          Text('Los platos más representativos de la región',
              style: GoogleFonts.openSans(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 14),
          ...  _kPlatos.map((p) => _buildTarjetaPlato(p)).toList(),
        ],
      ),
    );
  }

  Widget _buildTarjetaPlato(_Plato p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bienvenidaBorde),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _kFondo,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(p.emoji, style: const TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.nombre,
                    style: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.w700,
                        color: AppColors.bienvenidaTextoFuerte)),
                const SizedBox(height: 4),
                Text(p.descripcion,
                    style: GoogleFonts.openSans(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 11, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(p.donde,
                          style: GoogleFonts.openSans(fontSize: 11, color: AppColors.textHint,
                              fontStyle: FontStyle.italic),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Lugares del backend ─────────────────────────────────────
  Widget _buildLugaresSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Restaurantes y fondas',
              style: GoogleFonts.openSans(fontSize: 17, fontWeight: FontWeight.w700,
                  color: AppColors.bienvenidaTextoFuerte)),
          const SizedBox(height: 4),
          Text('Establecimientos de gastronomía registrados',
              style: GoogleFonts.openSans(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 14),
          _buildLugaresContent(),
        ],
      ),
    );
  }

  Widget _buildLugaresContent() {
    if (_cargando) {
      return const Center(
          child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()));
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
          child: Text('Próximamente más restaurantes y fondas',
              style: GoogleFonts.openSans(fontSize: 13, color: AppColors.textHint)),
        ),
      );
    }
    return Column(children: _lugares.map((p) => _buildLugarCard(p)).toList());
  }

  Widget _buildLugarCard(Place place) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => PlaceDetailPage(place: place))),
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
      width: 80, height: 80,
      color: _kFondo,
      child: const Center(child: Text('🍽️', style: TextStyle(fontSize: 28))),
    );
  }

  // ── Sabía que ────────────────────────────────────────────────
  Widget _buildSabiaQue() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _kNaranja1,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Text('🫔', style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('¿Sabías que…?',
                      style: GoogleFonts.openSans(fontSize: 13, fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('La arepa de huevo de Coveñas es tan famosa que tiene su propio festival gastronómico cada año en la Costa Caribe.',
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
