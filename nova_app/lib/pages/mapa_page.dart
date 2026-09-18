// lib/pages/mapa_page.dart
// ============================================================
// PANTALLA MAPA — Nova App Móvil (NUEVA)
// ============================================================
// Mapa real con flutter_map + OpenStreetMap (sin API key ni costo,
// decisión tomada por el usuario sobre las 3 opciones del plan:
// google_maps_flutter sería más parecido al Figma pero requiere una
// API key propia con facturación en Google Cloud).
//
// Marcadores reales desde ApiService.getAllPlaces() filtrados a los
// que ya tienen latitud/longitud — los 24 places de producción están
// geocodificados (4 en Sincelejo/Tolú/Coveñas + 20 en Sampués).
//
// El botón GPS usa la ubicación real del dispositivo (geolocator) —
// pide permiso en tiempo de ejecución y cae de vuelta al centro del
// golfo de Morrosquillo si el usuario la niega o falla la lectura.
//
// Diseño Figma Septiembre 2026 (NOVA_GPS_GEOCODIFICACION_PERFIL_PLAN.md
// PARTE A, sobre la base de NOVA_MAPA_RUTAS_SCAN_RECOMPENSAS_PLAN.md
// node 7:2).
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/design/app_colors.dart';
import '../models/place_model.dart';
import '../services/api_service.dart';
import 'place_detail_page.dart';

const _kCentroGolfo = LatLng(9.41, -75.55);
const _kZoomInicial = 10.3;

const _kFiltros = ['Todo', 'Escenarios', 'Agenda', 'Restaurantes'];
// 'Agenda' no tiene una categoría propia en places.tipo todavía —
// se comporta como 'Todo' hasta que exista esa dimensión de datos.
const Map<String, String?> _kFiltroTipo = {
  'Todo': null,
  'Escenarios': 'escenario_deportivo',
  'Agenda': null,
  'Restaurantes': 'restaurant',
};

class MapaPage extends StatefulWidget {
  const MapaPage({super.key});

  @override
  State<MapaPage> createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  final MapController _mapController = MapController();
  List<Place> _places = [];
  bool _loading = true;
  String _filtroActivo = 'Todo';
  Place? _seleccionado;
  LatLng? _userPosition;
  bool _loadingGps = false;

  @override
  void initState() {
    super.initState();
    _loadPlaces();
  }

  Future<void> _loadPlaces() async {
    try {
      final places = await ApiService.getAllPlaces();
      if (!mounted) return;
      final conCoords = places.where((p) => p.latitud != null && p.longitud != null).toList();
      setState(() {
        _places = conCoords;
        _seleccionado = conCoords.isNotEmpty ? conCoords.first : null;
      });
    } catch (e) {
      debugPrint('Error cargando lugares para el mapa: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Place> get _placesFiltrados {
    final tipo = _kFiltroTipo[_filtroActivo];
    if (tipo == null) return _places;
    return _places.where((p) => p.tipo == tipo).toList();
  }

  Future<void> _centrarEnUbicacion() async {
    setState(() => _loadingGps = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _mostrarSnack('Activa la ubicación en tu dispositivo');
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _mostrarSnack('Permiso de ubicación denegado');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _mostrarSnack('Permiso denegado permanentemente. Ve a Ajustes para activarlo.');
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      if (!mounted) return;
      final userPos = LatLng(pos.latitude, pos.longitude);
      setState(() => _userPosition = userPos);
      _mapController.move(userPos, 14.0);
    } catch (e) {
      _mapController.move(_kCentroGolfo, _kZoomInicial);
      _mostrarSnack('No se pudo obtener tu ubicación');
    } finally {
      if (mounted) setState(() => _loadingGps = false);
    }
  }

  void _mostrarSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.bienvenidaAzul),
    );
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
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: _kCentroGolfo,
              initialZoom: _kZoomInicial,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.nova_app',
              ),
              MarkerLayer(
                markers: [
                  for (final p in _placesFiltrados)
                    Marker(
                      point: LatLng(p.latitud!, p.longitud!),
                      width: 32,
                      height: 32,
                      child: GestureDetector(
                        onTap: () => setState(() => _seleccionado = p),
                        child: SvgPicture.asset(_iconoPin(p.tipo), width: 26, height: 26),
                      ),
                    ),
                  if (_userPosition != null)
                    Marker(
                      point: _userPosition!,
                      width: 72,
                      height: 72,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(color: AppColors.bienvenidaAzul.withValues(alpha: 0.18), shape: BoxShape.circle),
                          ),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: AppColors.bienvenidaAzul,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [BoxShadow(color: AppColors.bienvenidaAzul.withValues(alpha: 0.4), blurRadius: 8)],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),

          if (_loading)
            const Positioned(
              top: 118,
              left: 0,
              right: 0,
              child: Center(child: CircularProgressIndicator(color: AppColors.bienvenidaAzul)),
            ),

          // Buscador flotante
          Positioned(
            top: 56,
            left: 20,
            right: 20,
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [BoxShadow(color: Color(0x1F000000), blurRadius: 14, offset: Offset(0, 4))],
              ),
              child: Row(
                children: [
                  SvgPicture.asset('assets/icons/ic-buscar.svg', width: 18),
                  const SizedBox(width: 10),
                  Text('Explorar Sucre', style: GoogleFonts.openSans(fontSize: 14, color: AppColors.textHint)),
                ],
              ),
            ),
          ),

          // Filtros flotantes
          Positioned(
            top: 118,
            left: 20,
            right: 20,
            height: 45,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final f in _kFiltros) ...[
                    _buildFiltroMapa(f),
                    const SizedBox(width: 9),
                  ],
                ],
              ),
            ),
          ),

          // Botón GPS — ubicación real del dispositivo (geolocator)
          Positioned(
            right: 20,
            bottom: 230,
            child: GestureDetector(
              onTap: _loadingGps ? null : _centrarEnUbicacion,
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: const [BoxShadow(color: Color(0x24000000), blurRadius: 10, offset: Offset(0, 3))],
                ),
                child: _loadingGps
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.bienvenidaAzul),
                      )
                    : const Icon(Icons.my_location, color: AppColors.bienvenidaAzul, size: 22),
              ),
            ),
          ),

          // Hoja inferior
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildHojaInferior(),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltroMapa(String texto) {
    final activo = _filtroActivo == texto;
    return GestureDetector(
      onTap: () => setState(() => _filtroActivo = texto),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: activo ? AppColors.bienvenidaAzul : Colors.white,
          borderRadius: BorderRadius.circular(999),
          boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Text(
          texto,
          style: GoogleFonts.openSans(fontSize: 10, fontWeight: FontWeight.w600, color: activo ? Colors.white : AppColors.bienvenidaTextoMedio),
        ),
      ),
    );
  }

  Widget _buildHojaInferior() {
    final p = _seleccionado;
    return Container(
      height: 210,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(width: 42, height: 4, decoration: BoxDecoration(color: const Color(0xFFD8DEE6), borderRadius: BorderRadius.circular(999))),
          const SizedBox(height: 14),
          if (p == null)
            Expanded(
              child: Center(
                child: Text(
                  _loading ? 'Cargando lugares…' : 'Aún no hay lugares con ubicación en el mapa.',
                  style: GoogleFonts.openSans(fontSize: 13, color: AppColors.textSecondary),
                ),
              ),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: p.imageUrl?.isNotEmpty == true
                        ? Image.network(p.imageUrl!, width: 64, height: 64, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(width: 64, height: 64, color: AppColors.surfaceVariant))
                        : Container(width: 64, height: 64, color: AppColors.surfaceVariant,
                            child: const Icon(Icons.place_outlined, color: AppColors.textHint)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(p.name, style: GoogleFonts.openSans(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.bienvenidaTextoFuerte)),
                        const SizedBox(height: 4),
                        Text('${p.tipoLabel} · ${p.lugar}',
                            style: GoogleFonts.openSans(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 15, color: AppColors.bienvenidaDorado),
                            const SizedBox(width: 4),
                            Text('${p.rating}', style: GoogleFonts.openSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.bienvenidaTextoFuerte)),
                            Text(' · Ver disponibilidad', style: GoogleFonts.openSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.bienvenidaVerde)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => launchUrl(Uri.parse(
                          'https://www.google.com/maps/dir/?api=1&destination=${p.latitud},${p.longitud}')),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.bienvenidaAzul, width: 1.5),
                        shape: const StadiumBorder(),
                        minimumSize: const Size(0, 45),
                      ),
                      child: Text('Cómo llegar',
                          style: GoogleFonts.openSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.bienvenidaAzul)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PlaceDetailPage(place: p))),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.bienvenidaAzul,
                        shape: const StadiumBorder(),
                        minimumSize: const Size(0, 45),
                        elevation: 0,
                      ),
                      child: Text('Ver lugar',
                          style: GoogleFonts.openSans(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
