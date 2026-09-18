/// Página principal de la app NOVA App para turistas.
///
/// Es el índice 0 del [MainNavigationPage] y la primera pantalla
/// que ve el turista después de iniciar sesión.
///
/// Los datos del usuario y el último escaneo se cargan desde
/// [SharedPreferences] (datos locales) y [ApiService.getScanHistory] /
/// [ApiService.getAllPlaces] (backend).
///
/// Diseño Figma Septiembre 2026 (NOVA_HOME_EXPLORAR_PLAN.md, node 4:2):
/// encabezado con foto+gradiente, CTA de escaneo, banner Juegos
/// Nacionales 2027, chips de categoría y carruseles curados (Juegos,
/// municipios, rutas, naturaleza, sabores) + lista "Lo mejor valorado"
/// con datos reales de [ApiService.getAllPlaces].
///
/// [onNavigateToTab] — callback para navegar a otras tabs del [MainNavigationPage]
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/scan_record.dart';
import '../models/place_model.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../core/design/app_colors.dart';
import '../widgets/nova_carrusel_card.dart';
import '../widgets/nova_lista_card.dart';
import '../widgets/nova_chip.dart';
import 'place_detail_page.dart';
import 'municipio_page.dart';
import 'rutas_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.onNavigateToTab});

  final void Function(int) onNavigateToTab;

  @override
  State<HomePage> createState() => _HomePageState();
}

// Contenido curado de las secciones de carrusel — no proviene de la BD,
// coincide con las tarjetas estáticas del mockup Figma.
class _CarruselItem {
  final String imagePath;
  final String titulo;
  final String subtitulo;
  const _CarruselItem(this.imagePath, this.titulo, this.subtitulo);
}

const _kJuegosItems = [
  _CarruselItem('assets/images/home/foto-deportes.png', 'Deportes', 'Agenda y resultados'),
  _CarruselItem('assets/images/home/foto-escenarios.png', 'Escenarios', 'Sedes de competencia'),
  _CarruselItem('assets/images/home/foto-cultura.png', 'Cultura', 'Eventos y tradición'),
];

const _kMunicipioItems = [
  _CarruselItem('assets/images/municipios/foto-covenas.png', 'Coveñas', 'Playas y naturaleza'),
  _CarruselItem('assets/images/municipios/foto-tolu.png', 'Santiago de Tolú', 'Costa y patrimonio'),
  _CarruselItem('assets/images/municipios/foto-sincelejo.png', 'Sincelejo', 'Capital de Sucre'),
];
const _kMunicipioSlugs = ['covenas', 'santiago_de_tolu', 'sincelejo'];

const _kRutaItems = [
  _CarruselItem('assets/images/rutas/foto-ruta-costera.png', 'Ruta Costera', 'Playas y manglares'),
  _CarruselItem('assets/images/rutas/foto-ruta-patrimonio.png', 'Ruta Patrimonio', 'Historia y cultura'),
  _CarruselItem('assets/images/rutas/foto-ruta-cienagas.png', 'Ruta Ciénagas', 'Naturaleza viva'),
];

const _kNaturalezaItems = [
  _CarruselItem('assets/images/naturaleza/foto-manglares.png', 'Manglares', 'Ecosistema protegido'),
  _CarruselItem('assets/images/naturaleza/foto-cienagas.png', 'Ciénagas', 'Fauna y recorridos'),
];

const _kSaboresItems = [
  _CarruselItem('assets/images/gastronomia/foto-restaurantes.png', 'Restaurantes', 'Sabor local'),
  _CarruselItem('assets/images/gastronomia/foto-platos-tipicos.png', 'Platos típicos', 'Cocina de Sucre'),
  _CarruselItem('assets/images/gastronomia/foto-compras.png', 'Compras', 'Artesanías y más'),
];

const _kChips = ['Escenarios', 'Restaurantes', 'Parques', 'Artesanías', 'Playas'];

class _HomePageState extends State<HomePage> {
  ScanRecord? _lastScan;
  bool _loading = true;
  String _userName = '';

  List<Place> _topPlaces = [];
  bool _loadingTopPlaces = true;
  String _chipActivo = 'Escenarios';

  // ── Lifecycle ──────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadLastScan();
    _loadTopPlaces();
  }

  // ── Data ───────────────────────────────────────────────────

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(AppConstants.keyUser);

      if (userData != null) {
        final user = json.decode(userData);
        setState(() {
          _userName = user['first_name'] ?? user['username'] ?? 'Usuario';
        });
      } else {
        final userName =
            prefs.getString(AppConstants.keyUsername) ?? 'Usuario';
        final firstName =
            prefs.getString(AppConstants.keyFirstName) ?? '';
        setState(() {
          _userName = firstName.isNotEmpty ? firstName : userName;
        });
      }
    } catch (e) {
      debugPrint('Error cargando datos: $e');
      setState(() {
        _userName = 'Usuario';
      });
    }
  }

  Future<void> _loadLastScan() async {
    setState(() => _loading = true);
    try {
      final scans = await ApiService.getScanHistory();
      setState(() {
        if (scans.isNotEmpty) _lastScan = scans.first;
      });
    } catch (e) {
      debugPrint('Error cargando historial: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // "Lo mejor valorado" — top lugares reales de la BD, ya vienen
  // ordenados por rating desde el backend (GET /places sin filtros).
  Future<void> _loadTopPlaces() async {
    try {
      final places = await ApiService.getAllPlaces();
      if (!mounted) return;
      setState(() => _topPlaces = places.take(5).toList());
    } catch (e) {
      debugPrint('Error cargando lo mejor valorado: $e');
    } finally {
      if (mounted) setState(() => _loadingTopPlaces = false);
    }
  }

  String get _userLocation => _lastScan?.place ?? 'Sucre, Colombia';

  // ── Build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEncabezado(),
              const SizedBox(height: 20),
              _buildCtaEscanear(),
              const SizedBox(height: 16),
              _buildUltimoEscaneo(),
              const SizedBox(height: 20),
              _buildBannerJuegos(),
              const SizedBox(height: 20),
              _buildChipsCategorias(),
              const SizedBox(height: 24),
              _buildSeccionCarrusel(
                titulo: 'Juegos 2027',
                tituloEspecial: true,
                items: _kJuegosItems,
              ),
              const SizedBox(height: 24),
              _buildSeccionCarrusel(
                titulo: 'Explora por municipio',
                items: _kMunicipioItems,
                onTapItem: (i) => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MunicipioPage(municipio: _kMunicipioSlugs[i]),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildSeccionCarrusel(
                titulo: 'Rutas y recorridos',
                verMasLabel: 'Ver rutas',
                onVerMasTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RutasPage())),
                items: _kRutaItems,
                onTapItem: (_) => Navigator.push(context, MaterialPageRoute(builder: (_) => const RutasPage())),
              ),
              const SizedBox(height: 24),
              _buildSeccionCarrusel(
                titulo: 'Naturaleza y parques',
                verMasLabel: 'Ver lugares',
                items: _kNaturalezaItems,
              ),
              const SizedBox(height: 24),
              _buildSeccionCarrusel(
                titulo: 'Sabores y compras locales',
                verMasLabel: 'Ver lugares',
                items: _kSaboresItems,
              ),
              const SizedBox(height: 24),
              _buildLoMejorValorado(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // [1] ENCABEZADO — foto + gradiente + saludo + buscador
  Widget _buildEncabezado() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        image: DecorationImage(
          image: AssetImage('assets/images/home/foto-hero-home.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xCC0A578B), // rgba(10,87,139,0.8)
                      Color(0xCC0071BD), // rgba(0,113,189,0.8)
                      Color(0x7AFFFFFF), // rgba(255,255,255,0.48)
                    ],
                    stops: [0.02, 0.50, 0.98],
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Hola, $_userName',
                            style: GoogleFonts.openSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset('assets/icons/ic-map-pin.svg', width: 16, height: 16),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Estás en $_userLocation',
                                  style: GoogleFonts.openSans(fontSize: 13, color: Colors.white),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        width: 42,
                        height: 42,
                        color: const Color(0xFFBFE0F2),
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: () {}, // Búsqueda: pendiente de implementar
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset('assets/icons/ic-buscar.svg', width: 18, height: 18),
                        const SizedBox(width: 10),
                        Text(
                          '¿Tienes un lugar en mente?',
                          style: GoogleFonts.openSans(fontSize: 14, color: AppColors.textHint),
                        ),
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

  // [2a] CTA ESCANEAR QR — mantiene la navegación original a /scan
  Widget _buildCtaEscanear() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/scan'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0071BD), Color(0xFF078930)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SvgPicture.asset(
                  'assets/icons/ic-qr-code.svg',
                  width: 20,
                  height: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Escanear QR',
                      style: GoogleFonts.openSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Toca para escanear un lugar',
                      style: GoogleFonts.openSans(fontSize: 12, color: AppColors.bienvenidaAzulClaro),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // [2b] CARD ÚLTIMO ESCANEO
  Widget _buildUltimoEscaneo() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: LinearProgressIndicator(minHeight: 2),
      );
    }
    if (_lastScan == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.bienvenidaBorde),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _lastScan!.local,
                    style: GoogleFonts.openSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.bienvenidaTextoFuerte,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _lastScan!.place,
                    style: GoogleFonts.openSans(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.bienvenidaAzulClaro,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Hoy',
                style: GoogleFonts.openSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.bienvenidaAzul,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // [3] BANNER JUEGOS NACIONALES 2027
  Widget _buildBannerJuegos() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.bienvenidaCoral,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -40,
              bottom: -20,
              child: Opacity(
                opacity: 0.14,
                child: SvgPicture.asset(
                  'assets/icons/ic-marca-agua-juegos.svg',
                  width: 200,
                  height: 90,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildChipBanner('Evento especial'),
                    _buildChipBanner('2027'),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Juegos Nacionales y Paranacionales 2027',
                  style: GoogleFonts.openSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Agenda, escenarios, cultura, gastronomía y naturaleza de los tres municipios sede.',
                  style: GoogleFonts.openSans(
                    fontSize: 13,
                    color: AppColors.bienvenidaAzulClaro,
                    height: 19 / 13,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _buildBotonBanner('Deportes', solido: true)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildBotonBanner('Escenarios', solido: false)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChipBanner(String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        texto,
        style: GoogleFonts.openSans(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
      ),
    );
  }

  Widget _buildBotonBanner(String texto, {required bool solido}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: solido ? Colors.white : Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: solido ? null : Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: Text(
        texto,
        style: GoogleFonts.openSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: solido ? AppColors.bienvenidaCoral : Colors.white,
        ),
      ),
    );
  }

  // [4] CHIPS CATEGORÍAS (scroll horizontal)
  Widget _buildChipsCategorias() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _kChips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => NovaChip(
          label: _kChips[i],
          active: _chipActivo == _kChips[i],
          onTap: () => setState(() => _chipActivo = _kChips[i]),
        ),
      ),
    );
  }

  // Secciones de carrusel genéricas (Juegos 2027, municipios, rutas, ...)
  Widget _buildSeccionCarrusel({
    required String titulo,
    required List<_CarruselItem> items,
    bool tituloEspecial = false,
    String? verMasLabel,
    VoidCallback? onVerMasTap,
    void Function(int index)? onTapItem,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                titulo,
                style: GoogleFonts.openSans(
                  fontSize: tituloEspecial ? 15 : 18,
                  fontWeight: FontWeight.w700,
                  color: tituloEspecial ? AppColors.bienvenidaCoral : AppColors.bienvenidaTextoFuerte,
                ),
              ),
              if (verMasLabel != null)
                GestureDetector(
                  onTap: onVerMasTap,
                  child: Text(
                    verMasLabel,
                    style: GoogleFonts.openSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.bienvenidaAzul,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 168,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => NovaCarruselCard(
              imagePath: items[i].imagePath,
              titulo: items[i].titulo,
              subtitulo: items[i].subtitulo,
              onTap: onTapItem == null ? null : () => onTapItem(i),
            ),
          ),
        ),
      ],
    );
  }

  // [10] LO MEJOR VALORADO — lista real desde la BD
  Widget _buildLoMejorValorado() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Lo mejor valorado',
            style: GoogleFonts.openSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.bienvenidaTextoFuerte,
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (_loadingTopPlaces)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: LinearProgressIndicator(minHeight: 2),
          )
        else if (_topPlaces.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Aún no hay lugares para mostrar.',
              style: GoogleFonts.openSans(fontSize: 13, color: AppColors.textSecondary),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                for (final place in _topPlaces) ...[
                  NovaListaCard(
                    imagePath: place.imageUrl?.isNotEmpty == true
                        ? place.imageUrl!
                        : 'assets/images/lugares/foto-estadio-arturo-cumplido.png',
                    nombre: place.name,
                    descripcion: '${place.lugar} · ${place.tipoLabel}',
                    rating: place.rating,
                    photoSize: 72,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PlaceDetailPage(place: place)),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
