// lib/pages/places_page.dart
// ============================================================
// PANTALLA EXPLORAR — Nova App Móvil
// ============================================================
// Rediseño Figma Septiembre 2026 (NOVA_HOME_EXPLORAR_PLAN.md, node 5:2).
// Antes era un TabBarView por tipo de establecimiento (hoteles/
// restaurantes/bares); ahora es una lista de los tres municipios sede
// de los Juegos Nacionales 2027, con filtros de categoría. La API de
// lugares (ApiService.getPlacesByMunicipio) se mantiene — solo cambia
// la presentación.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design/app_colors.dart';
import '../models/place_model.dart';
import '../services/api_service.dart';
import '../widgets/nova_chip.dart';
import 'municipio_page.dart';
import 'mapa_page.dart';

class _MunicipioInfo {
  final String slug;
  final String nombre;
  final String descripcion;
  final String imagePath;
  const _MunicipioInfo(this.slug, this.nombre, this.descripcion, this.imagePath);
}

const _kMunicipiosExplorar = [
  _MunicipioInfo('sincelejo', 'Sincelejo', 'Capital de Sucre y sede principal de los Juegos.',
      'assets/images/municipios/foto-sincelejo.png'),
  _MunicipioInfo('santiago_de_tolu', 'Santiago de Tolú', 'Costa, malecón y patrimonio portuario.',
      'assets/images/municipios/foto-tolu.png'),
  _MunicipioInfo('covenas', 'Coveñas', 'Playas y naturaleza del Golfo de Morrosquillo.',
      'assets/images/municipios/foto-covenas.png'),
];

const _kCategorias = ['Lugares', 'Hoteles', 'Restaurantes', 'Bares', 'Reservas nat.'];

// Mapea el chip de categoría a un tipo de `places.tipo` para filtrar
// client-side — 'Lugares' no filtra (muestra todo).
const Map<String, String?> _kCategoriaTipo = {
  'Lugares': null,
  'Hoteles': 'hotel',
  'Restaurantes': 'restaurant',
  'Bares': 'bar',
  'Reservas nat.': 'naturaleza',
};

class PlacesPage extends StatefulWidget {
  const PlacesPage({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<PlacesPage> createState() => _PlacesPageState();
}

class _PlacesPageState extends State<PlacesPage> {
  String _municipioActivo = 'sincelejo';
  String _categoriaActiva = 'Lugares';

  bool _loading = true;
  final Map<String, List<Place>> _placesPorMunicipio = {};

  @override
  void initState() {
    super.initState();
    _municipioActivo = _kMunicipiosExplorar[widget.initialTab.clamp(0, _kMunicipiosExplorar.length - 1)].slug;
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    setState(() => _loading = true);
    try {
      final resultados = await Future.wait(
        _kMunicipiosExplorar.map((m) => ApiService.getPlacesByMunicipio(m.slug)),
      );
      if (!mounted) return;
      setState(() {
        for (var i = 0; i < _kMunicipiosExplorar.length; i++) {
          _placesPorMunicipio[_kMunicipiosExplorar[i].slug] = resultados[i];
        }
      });
    } catch (e) {
      debugPrint('Error cargando lugares por municipio: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Place> _placesFiltrados(String municipio) {
    final places = _placesPorMunicipio[municipio] ?? [];
    final tipoFiltro = _kCategoriaTipo[_categoriaActiva];
    if (tipoFiltro == null) return places;
    return places.where((p) => p.tipo == tipoFiltro).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadTodos,
          color: AppColors.bienvenidaAzul,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildFiltrosMunicipio(),
                const SizedBox(height: 16),
                _buildFiltrosCategoria(),
                const SizedBox(height: 20),
                _buildOfertaIntegral(),
                const SizedBox(height: 20),
                _buildListaMunicipios(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // HEADER — logo Juegos + título + subtítulo + buscador
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SvgPicture.asset(
                'assets/images/logos/logo-juegos-nacionales-2027.svg',
                width: 122,
                height: 55,
              ),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MapaPage())),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.bienvenidaFondoChip,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.map_outlined, color: AppColors.bienvenidaAzul, size: 22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Explora los tres municipios sede',
            style: GoogleFonts.openSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.bienvenidaRojo,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Descubre hoteles, restaurantes y experiencias en Sincelejo, Santiago de Tolú y Coveñas.',
            style: GoogleFonts.openSans(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.bienvenidaFondoChip,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                SvgPicture.asset('assets/icons/ic-buscar.svg', width: 18, height: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Buscar municipio, escenario o experiencia',
                    style: GoogleFonts.openSans(fontSize: 14, color: AppColors.textHint),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // FILTROS MUNICIPIO — grid 3 cols
  Widget _buildFiltrosMunicipio() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          for (final m in _kMunicipiosExplorar) ...[
            Expanded(
              child: NovaChip(
                label: m.nombre,
                active: _municipioActivo == m.slug,
                inactiveBackground: AppColors.bienvenidaFondoChip,
                inactiveHasBorder: false,
                onTap: () => setState(() => _municipioActivo = m.slug),
              ),
            ),
            if (m != _kMunicipiosExplorar.last) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  // FILTROS CATEGORÍA — grid 3x2 (Wrap)
  Widget _buildFiltrosCategoria() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: [
          for (final c in _kCategorias)
            NovaChip(
              label: c,
              active: _categoriaActiva == c,
              activeColor: AppColors.bienvenidaDorado,
              inactiveBackground: AppColors.bienvenidaFondoChip,
              inactiveHasBorder: false,
              onTap: () => setState(() => _categoriaActiva = c),
            ),
        ],
      ),
    );
  }

  // CARD "OFERTA INTEGRAL DE SUCRE"
  Widget _buildOfertaIntegral() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bienvenidaAzulOferta,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Oferta integral de Sucre',
                    style: GoogleFonts.openSans(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.bienvenidaTextoFuerte),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.bienvenidaAzul,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '7 experiencias',
                    style: GoogleFonts.openSans(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Hospedaje, gastronomía, cultura, naturaleza y deporte en un solo recorrido por los tres municipios sede.',
              style: GoogleFonts.openSans(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final texto in const ['Hospedaje', 'Gastronomía', 'Cultura', 'Naturaleza', 'Deporte'])
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      texto,
                      style: GoogleFonts.openSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.bienvenidaTextoFuerte),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // LISTA DE MUNICIPIOS — filtrada al municipio activo (chip seleccionado)
  Widget _buildListaMunicipios() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Center(child: CircularProgressIndicator(color: AppColors.bienvenidaAzul)),
      );
    }
    final activo = _kMunicipiosExplorar.firstWhere((m) => m.slug == _municipioActivo);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _buildTarjetaMunicipio(activo),
    );
  }

  Widget _buildTarjetaMunicipio(_MunicipioInfo m) {
    final places = _placesFiltrados(m.slug);
    final rating = places.isEmpty
        ? 0.0
        : places.map((p) => p.rating).reduce((a, b) => a + b) / places.length;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MunicipioPage(municipio: m.slug)),
      ),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.fromLTRB(10, 10, 14, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(m.imagePath, width: 78, height: 78, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    m.nombre,
                    style: GoogleFonts.openSans(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.bienvenidaTextoFuerte),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    m.descripcion,
                    style: GoogleFonts.openSans(fontSize: 13, color: AppColors.textSecondary, height: 18 / 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      SvgPicture.asset('assets/icons/ic-estrella.svg', width: 13, height: 13),
                      const SizedBox(width: 5),
                      Text(
                        rating > 0 ? rating.toStringAsFixed(1) : '—',
                        style: GoogleFonts.openSans(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      Text(' · ', style: GoogleFonts.openSans(fontSize: 12, color: AppColors.bienvenidaTextoFuerte)),
                      Text(
                        '${places.length} lugares',
                        style: GoogleFonts.openSans(fontSize: 12, color: AppColors.textHint),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      SvgPicture.asset('assets/icons/ic-beneficio.svg', width: 16, height: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Beneficios al escanear QR',
                        style: GoogleFonts.openSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.bienvenidaAzul),
                      ),
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
}
