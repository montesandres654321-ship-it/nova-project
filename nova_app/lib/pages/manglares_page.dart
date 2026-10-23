// lib/pages/manglares_page.dart
// ============================================================
// PANTALLA MANGLARES — Naturaleza y parques · Nova App Móvil
// ============================================================
// Información curada sobre los manglares del Golfo de Morrosquillo.
// Combina datos hardcoded (fichas ecosistema) + lugares reales
// del backend con tipo 'naturaleza'.
// ============================================================

import 'package:flutter/material.dart';
import '../core/design/app_colors.dart';
import '../models/place_model.dart';
import '../services/api_service.dart';
import 'place_detail_page.dart';

// ── Modelo interno ────────────────────────────────────────────
class _FichaManglar {
  final IconData icono;
  final String titulo;
  final String descripcion;
  final Color color;
  const _FichaManglar({
    required this.icono,
    required this.titulo,
    required this.descripcion,
    required this.color,
  });
}

// ── Datos curados ─────────────────────────────────────────────
const _kFichas = [
  _FichaManglar(
    icono: Icons.water_rounded,
    titulo: 'Manglar de La Caimanera',
    descripcion:
        'Uno de los manglares mejor conservados del Caribe colombiano. Bosque denso de mangle rojo, blanco y negro que protege la línea costera.',
    color: Color(0xFF166534),
  ),
  _FichaManglar(
    icono: Icons.park_rounded,
    titulo: 'Manglar Isla Palma',
    descripcion:
        'Ecosistema insular que alberga aves migratorias, iguanas y pelícanos. Acceso en lancha desde Coveñas.',
    color: Color(0xFF15803D),
  ),
  _FichaManglar(
    icono: Icons.directions_boat_rounded,
    titulo: 'Recorrido en Canoa',
    descripcion:
        'Tours guiados de 2–3 horas por los canales interiores. Observe garzas, martín pescador y fauna acuática en su hábitat natural.',
    color: Color(0xFF1A7A4A),
  ),
  _FichaManglar(
    icono: Icons.eco_rounded,
    titulo: 'Vivero de Mangles',
    descripcion:
        'Proyecto comunitario de reforestación en Tolú Viejo. Participa en la siembra de plántulas y contribuye a la conservación.',
    color: Color(0xFF166534),
  ),
];

const _kDatos = [
  _Dato(Icons.forest_rounded, '12.000 ha', 'Área protegida'),
  _Dato(Icons.pets_rounded, '+80', 'Especies de fauna'),
  _Dato(Icons.sailing_rounded, '6', 'Rutas de canoa'),
];

class _Dato {
  final IconData icono;
  final String valor;
  final String etiqueta;
  const _Dato(this.icono, this.valor, this.etiqueta);
}

// ── Colores del tema ──────────────────────────────────────────
const _kVerde1 = Color(0xFF14532D);
const _kVerde2 = Color(0xFF166534);
const _kFondo = AppColors.sistemaVerdeClaro;

// ── Widget principal ──────────────────────────────────────────
class ManglaresPage extends StatefulWidget {
  const ManglaresPage({super.key});

  @override
  State<ManglaresPage> createState() => _ManglaresPageState();
}

class _ManglaresPageState extends State<ManglaresPage> {
  List<Place> _places = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarPlaces();
  }

  Future<void> _cargarPlaces() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final places = await ApiService.getPlacesByType('naturaleza');
      if (mounted) {
        setState(() {
          _places = places;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'No se pudieron cargar los lugares. Intenta de nuevo.';
          _loading = false;
        });
      }
    }
  }

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
              const SizedBox(height: 28),
              _buildSectionTitle('El ecosistema'),
              const SizedBox(height: 14),
              _buildFichas(),
              const SizedBox(height: 28),
              _buildSectionTitle('Lugares cercanos'),
              const SizedBox(height: 14),
              _buildPlaces(),
              const SizedBox(height: 28),
              _buildBannerConservacion(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ── Hero ──────────────────────────────────────────────────────
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
              'assets/images/rutas/foto-naturaleza-parques.png',
              fit: BoxFit.cover,
            ),
            // Gradiente verde encima
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _kVerde1.withValues(alpha: 0.30),
                    _kVerde2.withValues(alpha: 0.88),
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
                  // Botón atrás
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Chip categoría
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.40)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.eco_rounded, size: 12, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          'Nova · Naturaleza y parques',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Manglares',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Ecosistema protegido del Golfo de Morrosquillo',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Stats
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final d in _kDatos)
                        _buildStatChip(d.icono, d.valor, d.etiqueta),
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
              Text(
                valor,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Text(
                etiqueta,
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Título de sección ─────────────────────────────────────────
  Widget _buildSectionTitle(String titulo) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        titulo,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: _kVerde1,
        ),
      ),
    );
  }

  // ── Fichas del ecosistema ─────────────────────────────────────
  Widget _buildFichas() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          for (var i = 0; i < _kFichas.length; i++) ...[
            _buildCardFicha(_kFichas[i], i == 0),
            if (i != _kFichas.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildCardFicha(_FichaManglar f, bool destacada) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: destacada ? _kFondo : Colors.white,
        border: Border.all(
          color: destacada
              ? _kVerde1.withValues(alpha: 0.25)
              : AppColors.bienvenidaBorde,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: destacada ? _kVerde2 : _kFondo,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  f.icono,
                  size: 20,
                  color: destacada ? Colors.white : _kVerde2,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  f.titulo,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.bienvenidaTextoFuerte,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            f.descripcion,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  // ── Lugares del backend ───────────────────────────────────────
  Widget _buildPlaces() {
    if (_loading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: CircularProgressIndicator(
            color: _kVerde2,
            strokeWidth: 2.5,
          ),
        ),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Icon(Icons.cloud_off_rounded,
                size: 40, color: AppColors.textHint.withValues(alpha: 0.4)),
            const SizedBox(height: 10),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: _cargarPlaces,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: Text(
                'Reintentar',
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kVerde2,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }
    if (_places.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _kFondo,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.forest_rounded, size: 28, color: _kVerde2),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Aún no hay lugares registrados. Vuelve pronto.',
                  style: TextStyle(
                      fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          for (var i = 0; i < _places.length; i++) ...[
            _buildCardPlace(_places[i]),
            if (i != _places.length - 1) const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }

  Widget _buildCardPlace(Place place) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PlaceDetailPage(place: place)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.bienvenidaBorde),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
              child: place.imageUrl != null && place.imageUrl!.isNotEmpty
                  ? Image.network(
                      place.imageUrl!,
                      width: double.infinity,
                      height: 140,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                    )
                  : _buildImagePlaceholder(),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          place.displayName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.bienvenidaTextoFuerte,
                          ),
                        ),
                      ),
                      if (place.rating != null) ...[
                        const SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 13, color: Color(0xFFFFC107)),
                            const SizedBox(width: 3),
                            Text(
                              place.rating!.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.bienvenidaTextoFuerte,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  if (place.lugar != null && place.lugar!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            size: 13, color: AppColors.textHint),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            place.lugar!,
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _kFondo,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          place.tipoLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _kVerde2,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          size: 18, color: _kVerde2),
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

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 140,
      color: _kFondo,
      child: const Center(
        child: Icon(Icons.forest_rounded, size: 40, color: _kVerde2),
      ),
    );
  }

  // ── Banner conservación ───────────────────────────────────────
  Widget _buildBannerConservacion() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _kFondo,
          border: Border.all(color: _kVerde1.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: _kVerde2,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.volunteer_activism_rounded,
                  size: 20, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Conservación activa',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _kVerde1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Los manglares del Golfo están bajo protección ambiental. Al visitarlos, contribuyes al ecoturismo sostenible de Sucre.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
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
