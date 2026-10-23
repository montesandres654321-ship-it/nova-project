// lib/pages/cienagas_page.dart
// ============================================================
// PANTALLA CIÉNAGAS — Naturaleza y parques · Nova App Móvil
// ============================================================
// Información curada sobre las ciénagas del Golfo de Morrosquillo.
// Combina datos hardcoded (fichas ecosistema) + lugares reales
// del backend con tipo 'naturaleza'.
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design/app_colors.dart';
import '../models/place_model.dart';
import '../services/api_service.dart';
import 'place_detail_page.dart';

// ── Modelo interno ────────────────────────────────────────────
class _FichaCienaga {
  final IconData icono;
  final String titulo;
  final String descripcion;
  const _FichaCienaga({
    required this.icono,
    required this.titulo,
    required this.descripcion,
  });
}

// ── Datos curados ─────────────────────────────────────────────
const _kFichas = [
  _FichaCienaga(
    icono: Icons.water_rounded,
    titulo: 'Ciénaga La Caimanera',
    descripcion:
        'Espejo de agua dulce conectado al mar que regula el ecosistema costero. Hábitat clave para caimanes, tortugas y aves acuáticas.',
  ),
  _FichaCienaga(
    icono: Icons.rowing_rounded,
    titulo: 'Recorridos en Chalupa',
    descripcion:
        'Tours en embarcaciones tradicionales por los canales entre ciénagas. Los guías locales narran la historia y fauna del lugar.',
  ),
  _FichaCienaga(
    icono: Icons.camera_rounded,
    titulo: 'Avistamiento de Aves',
    descripcion:
        'Más de 120 especies registradas, incluyendo garzas morenas, patos cuervo, cormoranes y flamencos rosados en temporada.',
  ),
  _FichaCienaga(
    icono: Icons.set_meal_rounded,
    titulo: 'Pesca Artesanal',
    descripcion:
        'Las familias pescadoras de Tolú y Coveñas mantienen la tradición de pesca con atarraya en las ciénagas desde hace generaciones.',
  ),
];

const _kDatos = [
  _Dato(Icons.water_rounded, '8', 'Ciénagas'),
  _Dato(Icons.flutter_dash_rounded, '+120', 'Especies de aves'),
  _Dato(Icons.directions_boat_rounded, '4', 'Rutas acuáticas'),
];

class _Dato {
  final IconData icono;
  final String valor;
  final String etiqueta;
  const _Dato(this.icono, this.valor, this.etiqueta);
}

// ── Colores del tema ──────────────────────────────────────────
const _kAzul1 = Color(0xFF0C4A6E);
const _kAzul2 = Color(0xFF0369A1);
const _kFondo = Color(0xFFE0F2FE);

// ── Widget principal ──────────────────────────────────────────
class CienagasPage extends StatefulWidget {
  const CienagasPage({super.key});

  @override
  State<CienagasPage> createState() => _CienagasPageState();
}

class _CienagasPageState extends State<CienagasPage> {
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
              _buildSectionTitle('Fauna y recorridos'),
              const SizedBox(height: 14),
              _buildFichas(),
              const SizedBox(height: 28),
              _buildSectionTitle('Lugares cercanos'),
              const SizedBox(height: 14),
              _buildPlaces(),
              const SizedBox(height: 28),
              _buildBannerConsejos(),
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
              'assets/images/rutas/foto-ruta-cienagas.png',
              fit: BoxFit.cover,
            ),
            // Gradiente azul agua encima
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _kAzul1.withValues(alpha: 0.30),
                    _kAzul2.withValues(alpha: 0.88),
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
                        const Icon(Icons.water_rounded,
                            size: 12, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          'Nova · Naturaleza y parques',
                          style: GoogleFonts.openSans(
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
                    'Ciénagas',
                    style: GoogleFonts.openSans(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Humedales y fauna acuática del Golfo de Morrosquillo',
                    style: GoogleFonts.openSans(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Stats
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
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
                style: GoogleFonts.openSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Text(
                etiqueta,
                style: GoogleFonts.openSans(
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
        style: GoogleFonts.openSans(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: _kAzul1,
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

  Widget _buildCardFicha(_FichaCienaga f, bool destacada) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: destacada ? _kFondo : Colors.white,
        border: Border.all(
          color: destacada
              ? _kAzul1.withValues(alpha: 0.25)
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
                  color: destacada ? _kAzul2 : _kFondo,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  f.icono,
                  size: 20,
                  color: destacada ? Colors.white : _kAzul2,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  f.titulo,
                  style: GoogleFonts.openSans(
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
            style: GoogleFonts.openSans(
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
            color: _kAzul2,
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
              style: GoogleFonts.openSans(
                  fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: _cargarPlaces,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: Text(
                'Reintentar',
                style: GoogleFonts.openSans(
                    fontSize: 13, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kAzul2,
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
              const Icon(Icons.water_rounded, size: 28, color: _kAzul2),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Aún no hay lugares registrados. Vuelve pronto.',
                  style: GoogleFonts.openSans(
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
                          style: GoogleFonts.openSans(
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
                              style: GoogleFonts.openSans(
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
                            style: GoogleFonts.openSans(
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
                          style: GoogleFonts.openSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _kAzul2,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          size: 18, color: _kAzul2),
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
        child: Icon(Icons.water_rounded, size: 40, color: _kAzul2),
      ),
    );
  }

  // ── Banner consejos de visita ─────────────────────────────────
  Widget _buildBannerConsejos() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _kFondo,
          border: Border.all(color: _kAzul1.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: _kAzul2,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.tips_and_updates_rounded,
                  size: 20, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Consejo de visita',
                    style: GoogleFonts.openSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _kAzul1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'El mejor horario para avistar aves es al amanecer. Usa repelente, lleva ropa de colores neutros y respeta la fauna silvestre.',
                    style: GoogleFonts.openSans(
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
