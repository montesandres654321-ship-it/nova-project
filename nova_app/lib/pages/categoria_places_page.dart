// lib/pages/categoria_places_page.dart
// ============================================================
// PANTALLA GENÉRICA DE CATEGORÍA — Nova App Móvil
// ============================================================
// Carga lugares del backend por tipo usando ApiService.getPlacesByType.
// Reutilizada por los 5 chips de categoría de la HomePage:
//   Escenarios → escenario_deportivo
//   Restaurantes → restaurant
//   Parques → parque
//   Artesanías → artesania
//   Playas → playa
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design/app_colors.dart';
import '../models/place_model.dart';
import '../services/api_service.dart';
import 'place_detail_page.dart';

class CategoriaPlacesPage extends StatefulWidget {
  final String titulo;
  final String tipo;

  const CategoriaPlacesPage({
    super.key,
    required this.titulo,
    required this.tipo,
  });

  @override
  State<CategoriaPlacesPage> createState() => _CategoriaPlacesPageState();
}

class _CategoriaPlacesPageState extends State<CategoriaPlacesPage> {
  List<Place> _places = [];
  bool _loading = true;
  String? _error;

  // Color y emoji por tipo
  Color get _colorPrimario {
    switch (widget.tipo) {
      case 'escenario_deportivo':
        return AppColors.bienvenidaAzul;
      case 'restaurant':
        return AppColors.bienvenidaCoral;
      case 'parque':
        return AppColors.bienvenidaVerde;
      case 'artesania':
        return const Color(0xFF8B4513);
      case 'playa':
        return const Color(0xFF0891B2);
      default:
        return AppColors.bienvenidaAzul;
    }
  }

  Color get _colorFondo {
    switch (widget.tipo) {
      case 'escenario_deportivo':
        return const Color(0xFFE6F2FA);
      case 'restaurant':
        return const Color(0xFFFFF0EC);
      case 'parque':
        return const Color(0xFFE7F4EB);
      case 'artesania':
        return const Color(0xFFFFF3E0);
      case 'playa':
        return const Color(0xFFE0F7FA);
      default:
        return const Color(0xFFE6F2FA);
    }
  }

  IconData get _icono {
    switch (widget.tipo) {
      case 'escenario_deportivo':
        return Icons.stadium_rounded;
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'parque':
        return Icons.park_rounded;
      case 'artesania':
        return Icons.brush_rounded;
      case 'playa':
        return Icons.beach_access_rounded;
      default:
        return Icons.place_rounded;
    }
  }

  String get _subtitulo {
    switch (widget.tipo) {
      case 'escenario_deportivo':
        return 'Espacios deportivos del Golfo de Morrosquillo';
      case 'restaurant':
        return 'Gastronomía local en la región';
      case 'parque':
        return 'Parques y espacios naturales';
      case 'artesania':
        return 'Artesanías y cultura local';
      case 'playa':
        return 'Playas del Golfo de Morrosquillo';
      default:
        return 'Lugares destacados';
    }
  }

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
      final places = await ApiService.getPlacesByType(widget.tipo);
      if (mounted) {
        setState(() {
          _places = places;
          _loading = false;
        });
      }
    } catch (e) {
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
        child: Column(
          children: [
            _buildHero(context),
            Expanded(child: _buildCuerpo()),
          ],
        ),
      ),
    );
  }

  // ── Hero ──────────────────────────────────────────────────────
  Widget _buildHero(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_colorPrimario, _colorPrimario.withValues(alpha: 0.75)],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Stack(
        children: [
          Positioned(left: -30, top: -20, child: _resplandor(130)),
          Positioned(right: -20, bottom: -10, child: _resplandor(160)),
          Column(
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
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_icono, size: 12, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      'Nova · Golfo de Morrosquillo',
                      style: GoogleFonts.openSans(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.titulo,
                style: GoogleFonts.openSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _subtitulo,
                style: GoogleFonts.openSans(fontSize: 13, color: Colors.white.withValues(alpha: 0.85)),
              ),
              const SizedBox(height: 16),
              if (!_loading && _error == null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.place_rounded, size: 14, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        '${_places.length} lugar${_places.length != 1 ? 'es' : ''} encontrado${_places.length != 1 ? 's' : ''}',
                        style: GoogleFonts.openSans(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _resplandor(double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.08)),
  );

  // ── Cuerpo ────────────────────────────────────────────────────
  Widget _buildCuerpo() {
    if (_loading) return _buildCargando();
    if (_error != null) return _buildError();
    if (_places.isEmpty) return _buildVacio();
    return _buildLista();
  }

  Widget _buildCargando() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: _colorPrimario, strokeWidth: 2.5),
          const SizedBox(height: 16),
          Text(
            'Cargando lugares…',
            style: GoogleFonts.openSans(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded, size: 56, color: AppColors.textHint.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: GoogleFonts.openSans(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _cargarPlaces,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: Text('Reintentar', style: GoogleFonts.openSans(fontSize: 13, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _colorPrimario,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVacio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_icono, size: 56, color: AppColors.textHint.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(
            'Aún no hay lugares\nregistrados en esta categoría',
            textAlign: TextAlign.center,
            style: GoogleFonts.openSans(fontSize: 15, color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 8),
          Text(
            'Vuelve pronto',
            style: GoogleFonts.openSans(fontSize: 12, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }

  Widget _buildLista() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      itemCount: _places.length,
      itemBuilder: (context, i) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: _buildCardPlace(_places[i]),
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
            // Imagen o placeholder
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
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
            // Info
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
                          style: GoogleFonts.openSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.bienvenidaTextoFuerte,
                          ),
                        ),
                      ),
                      if (place.rating != null) ...[
                        const SizedBox(width: 8),
                        _buildRating(place.rating!),
                      ],
                    ],
                  ),
                  if (place.lugar != null && place.lugar!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 13, color: AppColors.textHint),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            place.lugar!,
                            style: GoogleFonts.openSans(fontSize: 12, color: AppColors.textSecondary),
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
                      _buildChipTipo(place.tipoLabel),
                      Icon(Icons.chevron_right_rounded, size: 18, color: _colorPrimario),
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
      color: _colorFondo,
      child: Center(child: Icon(_icono, size: 40, color: _colorPrimario.withValues(alpha: 0.4))),
    );
  }

  Widget _buildRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 13, color: Color(0xFFFFC107)),
        const SizedBox(width: 3),
        Text(
          rating.toStringAsFixed(1),
          style: GoogleFonts.openSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.bienvenidaTextoFuerte),
        ),
      ],
    );
  }

  Widget _buildChipTipo(String tipo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _colorFondo,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        tipo,
        style: GoogleFonts.openSans(fontSize: 10, fontWeight: FontWeight.w600, color: _colorPrimario),
      ),
    );
  }
}
