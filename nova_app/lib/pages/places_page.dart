// lib/pages/places_page.dart
// ============================================================
// PANTALLA EXPLORAR — Nova App Móvil
// ============================================================
// Rediseño Oct 2026: mapa integrado en la parte superior
// (FlutterMap de altura fija, sin interferir con el scroll),
// buscador funcional, chips de Oferta integral con navegación.
// Todo lo anterior (filtros municipio, filtros categoría,
// tarjetas municipio → MunicipioPage) se mantiene intacto.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design/app_colors.dart';
import '../models/place_model.dart';
import '../services/api_service.dart';
import '../widgets/nova_chip.dart';
import '../widgets/error_display_widget.dart';
import 'municipio_page.dart';
import 'mapa_page.dart';
import 'categoria_places_page.dart';

// ── Constantes mapa ──────────────────────────────────────────
const _kCentroGolfo = LatLng(9.41, -75.55);
const _kZoomMini    = 9.5;

// ── Municipios ───────────────────────────────────────────────
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
  _MunicipioInfo('sampues', 'Sampués', 'Capital artesanal con talleres de tejido y palma.',
      'assets/images/municipios/foto-sampues.png'),
];

// ── Filtros categoría ─────────────────────────────────────────
const _kCategorias = ['Lugares', 'Hoteles', 'Restaurantes', 'Bares', 'Reservas nat.'];

const Map<String, String?> _kCategoriaTipo = {
  'Lugares': null,
  'Hoteles': 'hotel',
  'Restaurantes': 'restaurant',
  'Bares': 'bar',
  'Reservas nat.': 'naturaleza',
};

// ── Chips Oferta integral → navegación ───────────────────────
const _kOfertaChips = [
  {'label': 'Hospedaje',   'tipo': 'hotel'},
  {'label': 'Gastronomía', 'tipo': 'gastronomia'},
  {'label': 'Cultura',     'tipo': 'cultura'},
  {'label': 'Naturaleza',  'tipo': 'naturaleza'},
  {'label': 'Deporte',     'tipo': 'escenario_deportivo'},
];

class PlacesPage extends StatefulWidget {
  const PlacesPage({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<PlacesPage> createState() => _PlacesPageState();
}

class _PlacesPageState extends State<PlacesPage> {
  String _municipioActivo = 'sincelejo';
  String _categoriaActiva = 'Lugares';
  String _busqueda = '';

  bool _loading = true;
  String? _error;
  final Map<String, List<Place>> _placesPorMunicipio = {};
  List<Place> _placesParaMapa = [];

  // Controller del buscador
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _municipioActivo = _kMunicipiosExplorar[widget.initialTab.clamp(0, _kMunicipiosExplorar.length - 1)].slug;
    _loadTodos();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadTodos() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Carga por municipio (igual que antes) + todos para marcadores del mapa
      final futures = <Future>[
        ...(_kMunicipiosExplorar.map((m) => ApiService.getPlacesByMunicipio(m.slug))),
        ApiService.getAllPlaces(),
      ];
      final resultados = await Future.wait(futures.cast<Future<List<Place>>>());
      if (!mounted) return;
      setState(() {
        for (var i = 0; i < _kMunicipiosExplorar.length; i++) {
          _placesPorMunicipio[_kMunicipiosExplorar[i].slug] = resultados[i];
        }
        // Últimos resultados = getAllPlaces → filtrar los que tienen coordenadas
        _placesParaMapa = resultados[_kMunicipiosExplorar.length]
            .where((p) => p.latitud != null && p.longitud != null)
            .toList();
      });
    } catch (e) {
      debugPrint('Error cargando lugares: $e');
      if (mounted && _placesPorMunicipio.isEmpty) {
        setState(() => _error = 'No pudimos cargar los lugares. Verifica tu conexión.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Place> _placesFiltrados(String municipio) {
    final places = _placesPorMunicipio[municipio] ?? [];
    final tipoFiltro = _kCategoriaTipo[_categoriaActiva];
    var lista = tipoFiltro == null ? places : places.where((p) => p.tipo == tipoFiltro).toList();
    // Filtro de búsqueda por nombre
    if (_busqueda.isNotEmpty) {
      final q = _busqueda.toLowerCase();
      lista = lista.where((p) => p.name.toLowerCase().contains(q) || (p.lugar?.toLowerCase().contains(q) ?? false)).toList();
    }
    return lista;
  }

  String _iconoPin(String tipo) {
    switch (tipo) {
      case 'escenario_deportivo':
        return 'assets/icons/mapa/ic-pin-escenario.svg';
      case 'parque':
        return 'assets/icons/mapa/ic-pin-parque.svg';
      case 'restaurant':
      case 'gastronomia':
        return 'assets/icons/mapa/ic-pin-restaurante.svg';
      default:
        return 'assets/icons/mapa/ic-pin-agenda.svg';
    }
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
                _buildMapaIntegrado(),
                _buildBuscador(),
                const SizedBox(height: 16),
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

  // ── HEADER: logo pequeño izquierda + título ──────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/logos/logo-juegos-nacionales-2027.svg',
            width: 72,
            height: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Explora los municipios sede',
              style: GoogleFonts.openSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.bienvenidaRojo,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── MAPA INTEGRADO de altura fija ────────────────────────────
  // AbsorbPointer en el eje vertical para que el scroll de la
  // página no sea capturado por el mapa. El mapa acepta pinch-zoom
  // y pan horizontal con un Listener sobre el eje X.
  Widget _buildMapaIntegrado() {
    return Stack(
      children: [
        // Mapa OpenStreetMap — 220 px de alto, sin gestos de scroll vertical
        SizedBox(
          height: 220,
          child: ClipRect(
            child: IgnorePointer(
              // Solo ignoramos los toques para evitar que capture el scroll;
              // el botón "Ver mapa completo" está encima y sí recibe toques.
              ignoring: false,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: _kCentroGolfo,
                  initialZoom: _kZoomMini,
                  // Desactivar rotación y limitar interacciones para que el scroll
                  // de la página funcione con normalidad
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.pinchZoom | InteractiveFlag.doubleTapZoom,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.nova_app',
                  ),
                  MarkerLayer(
                    markers: [
                      for (final p in _placesParaMapa)
                        Marker(
                          point: LatLng(p.latitud!, p.longitud!),
                          width: 24,
                          height: 24,
                          child: SvgPicture.asset(_iconoPin(p.tipo), width: 20, height: 20),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // Gradiente oscuro inferior para legibilidad del botón
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 70,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.35)],
              ),
            ),
          ),
        ),

        // Botón "Ver mapa completo" → MapaPage
        Positioned(
          bottom: 12,
          right: 14,
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MapaPage()),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                boxShadow: const [
                  BoxShadow(color: Color(0x28000000), blurRadius: 8, offset: Offset(0, 2)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.open_in_full_rounded, size: 13, color: AppColors.bienvenidaAzul),
                  const SizedBox(width: 6),
                  Text(
                    'Ver mapa completo',
                    style: GoogleFonts.openSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.bienvenidaAzul,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Badge de lugares con coordenadas
        if (_placesParaMapa.isNotEmpty)
          Positioned(
            top: 12,
            left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.bienvenidaAzul,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${_placesParaMapa.length} lugares en el mapa',
                style: GoogleFonts.openSans(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  // ── BUSCADOR FUNCIONAL ────────────────────────────────────────
  Widget _buildBuscador() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _busqueda = v.trim()),
        style: GoogleFonts.openSans(fontSize: 14, color: AppColors.bienvenidaTextoFuerte),
        decoration: InputDecoration(
          hintText: 'Buscar municipio, escenario o experiencia',
          hintStyle: GoogleFonts.openSans(fontSize: 14, color: AppColors.textHint),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: SvgPicture.asset('assets/icons/ic-buscar.svg', width: 18, height: 18),
          ),
          suffixIcon: _busqueda.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textHint),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _busqueda = '');
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.bienvenidaFondoChip,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        ),
      ),
    );
  }

  // ── FILTROS MUNICIPIO (sin cambios) ───────────────────────────
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

  // ── FILTROS CATEGORÍA (sin cambios) ───────────────────────────
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

  // ── OFERTA INTEGRAL — chips ahora navegan ─────────────────────
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
                    style: GoogleFonts.openSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.bienvenidaTextoFuerte,
                    ),
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
                    style: GoogleFonts.openSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Hospedaje, gastronomía, cultura, naturaleza y deporte en los cuatro municipios sede.',
              style: GoogleFonts.openSans(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            // Chips con navegación real
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final chip in _kOfertaChips)
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CategoriaPlacesPage(
                          titulo: chip['label']!,
                          tipo: chip['tipo']!,
                        ),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            chip['label']!,
                            style: GoogleFonts.openSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.bienvenidaTextoFuerte,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.chevron_right_rounded, size: 14, color: AppColors.bienvenidaAzul),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── LISTA MUNICIPIOS (lógica igual, + búsqueda) ───────────────
  Widget _buildListaMunicipios() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Center(child: CircularProgressIndicator(color: AppColors.bienvenidaAzul)),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ErrorDisplayWidget(mensaje: _error!, onRetry: _loadTodos),
      );
    }
    final activo = _kMunicipiosExplorar.firstWhere((m) => m.slug == _municipioActivo);
    final places = _placesFiltrados(activo.slug);

    // Mensaje cuando búsqueda no encuentra nada
    if (_busqueda.isNotEmpty && places.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.search_off_rounded, size: 40, color: AppColors.textHint),
              const SizedBox(height: 10),
              Text(
                'Sin resultados para "$_busqueda"',
                style: GoogleFonts.openSans(fontSize: 14, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
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
                    style: GoogleFonts.openSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.bienvenidaTextoFuerte,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    m.descripcion,
                    style: GoogleFonts.openSans(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 18 / 13,
                    ),
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
                        style: GoogleFonts.openSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        ' · ',
                        style: GoogleFonts.openSans(
                          fontSize: 12,
                          color: AppColors.bienvenidaTextoFuerte,
                        ),
                      ),
                      Text(
                        '${places.length} lugares',
                        style: GoogleFonts.openSans(
                          fontSize: 12,
                          color: AppColors.textHint,
                        ),
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
                        style: GoogleFonts.openSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.bienvenidaAzul,
                        ),
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
