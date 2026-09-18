// lib/pages/municipio_page.dart
// ============================================================
// PANTALLA MUNICIPIO — Nova App Móvil (NUEVA)
// ============================================================
// Se abre al tocar una tarjeta de municipio en Home/Explorar.
// Diseño Figma Septiembre 2026 (NOVA_HOME_EXPLORAR_PLAN.md, node 5:62)
// — detallado a fondo solo para Sincelejo; Santiago de Tolú y Coveñas
// usan contenido editorial más breve hasta que el backend soporte
// historia/estadísticas por municipio (columnas ya agregadas en
// places.historia/stats_* — pendiente de poblar y de un endpoint
// dedicado; por ahora la sección "Historia" es estática).
//
// Los "Lugares" del municipio SÍ vienen de la BD real vía
// ApiService.getPlacesByMunicipio(municipio).
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design/app_colors.dart';
import '../models/place_model.dart';
import '../services/api_service.dart';
import '../widgets/nova_lista_card.dart';
import 'place_detail_page.dart';

class _TimelineEntry {
  final String anio;
  final String evento;
  const _TimelineEntry(this.anio, this.evento);
}

class _ChipQueHacer {
  final IconData icon;
  final String label;
  const _ChipQueHacer(this.icon, this.label);
}

class _MunicipioData {
  final String heroAsset;
  final String nombre;
  final String subtitulo;
  final double valoracion;
  final int nLugares;
  final int nRutas;
  final String historiaTitulo;
  final String historiaDescripcion;
  final List<_TimelineEntry> timeline;
  final String textoFinalBold;
  final String textoFinalResto;
  final List<_ChipQueHacer> chips;

  const _MunicipioData({
    required this.heroAsset,
    required this.nombre,
    required this.subtitulo,
    required this.valoracion,
    required this.nLugares,
    required this.nRutas,
    required this.historiaTitulo,
    required this.historiaDescripcion,
    required this.timeline,
    required this.textoFinalBold,
    required this.textoFinalResto,
    required this.chips,
  });
}

const Map<String, _MunicipioData> _kMunicipios = {
  'sincelejo': _MunicipioData(
    heroAsset: 'assets/images/municipios/hero-sincelejo.png',
    nombre: 'Sincelejo',
    subtitulo: 'Capital de Sucre · Sede de los Juegos Nacionales 2027',
    valoracion: 4.7,
    nLugares: 12,
    nRutas: 3,
    historiaTitulo: 'Sincelejo en su historia',
    historiaDescripcion:
        'Capital del departamento de Sucre, cuna del Festival Nacional del Burro y epicentro cultural del Golfo de Morrosquillo.',
    timeline: [
      _TimelineEntry('1776', 'Fundación del poblado de Sincelejo.'),
      _TimelineEntry('1966', 'Se erige como capital del nuevo departamento de Sucre.'),
      _TimelineEntry('2027', 'Sede principal de los Juegos Nacionales y Paranacionales.'),
    ],
    textoFinalBold: 'Las Fiestas del 20 de Enero',
    textoFinalResto: ' reúnen cada año a miles de visitantes en torno a la corraleja y la música sabanera.',
    chips: [
      _ChipQueHacer(Icons.event_outlined, 'Agenda'),
      _ChipQueHacer(Icons.theater_comedy_outlined, 'Cultura'),
      _ChipQueHacer(Icons.restaurant_outlined, 'Gastronomía'),
      _ChipQueHacer(Icons.stadium_outlined, 'Espacios'),
      _ChipQueHacer(Icons.shopping_bag_outlined, 'Compras'),
    ],
  ),
  'santiago_de_tolu': _MunicipioData(
    heroAsset: 'assets/images/municipios/foto-tolu.png',
    nombre: 'Santiago de Tolú',
    subtitulo: 'Costa y patrimonio del Golfo de Morrosquillo',
    valoracion: 4.6,
    nLugares: 8,
    nRutas: 2,
    historiaTitulo: 'Santiago de Tolú en su historia',
    historiaDescripcion:
        'Uno de los puertos más antiguos del Caribe colombiano, con playas, malecón y tradición pesquera.',
    timeline: [
      _TimelineEntry('1535', 'Fundación española del puerto de Tolú.'),
      _TimelineEntry('2027', 'Sede de eventos náuticos de los Juegos Nacionales.'),
    ],
    textoFinalBold: 'El malecón turístico',
    textoFinalResto: ' es el punto de encuentro para disfrutar el atardecer sobre el mar Caribe.',
    chips: [
      _ChipQueHacer(Icons.event_outlined, 'Agenda'),
      _ChipQueHacer(Icons.beach_access_outlined, 'Playas'),
      _ChipQueHacer(Icons.restaurant_outlined, 'Gastronomía'),
    ],
  ),
  'covenas': _MunicipioData(
    heroAsset: 'assets/images/municipios/foto-covenas.png',
    nombre: 'Coveñas',
    subtitulo: 'Playas y naturaleza del Golfo de Morrosquillo',
    valoracion: 4.6,
    nLugares: 6,
    nRutas: 2,
    historiaTitulo: 'Coveñas en su historia',
    historiaDescripcion:
        'Balneario por excelencia de la región Caribe, con playas de aguas cálidas y manglares cercanos.',
    timeline: [
      _TimelineEntry('1960s', 'Auge turístico como destino de playa del Caribe.'),
      _TimelineEntry('2027', 'Sede de actividades acuáticas de los Juegos Nacionales.'),
    ],
    textoFinalBold: 'Punta Bolívar',
    textoFinalResto: ' es la playa más visitada, con deportes acuáticos y comida típica frente al mar.',
    chips: [
      _ChipQueHacer(Icons.beach_access_outlined, 'Playas'),
      _ChipQueHacer(Icons.park_outlined, 'Naturaleza'),
      _ChipQueHacer(Icons.restaurant_outlined, 'Gastronomía'),
    ],
  ),
};

class MunicipioPage extends StatefulWidget {
  const MunicipioPage({super.key, required this.municipio});

  /// Slug del municipio: 'sincelejo' | 'santiago_de_tolu' | 'covenas'
  final String municipio;

  @override
  State<MunicipioPage> createState() => _MunicipioPageState();
}

class _MunicipioPageState extends State<MunicipioPage> {
  List<Place> _lugares = [];
  bool _loading = true;

  _MunicipioData get _data => _kMunicipios[widget.municipio] ?? _kMunicipios['sincelejo']!;

  @override
  void initState() {
    super.initState();
    _loadLugares();
  }

  Future<void> _loadLugares() async {
    try {
      final lugares = await ApiService.getPlacesByMunicipio(widget.municipio);
      if (!mounted) return;
      setState(() => _lugares = lugares);
    } catch (e) {
      debugPrint('Error cargando lugares de ${widget.municipio}: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHero(data),
            const SizedBox(height: 20),
            _buildStats(data),
            const SizedBox(height: 24),
            _buildHistoria(data),
            const SizedBox(height: 24),
            _buildQuePuedesHacer(data),
            const SizedBox(height: 24),
            _buildLugares(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(_MunicipioData data) {
    return SizedBox(
      height: 278,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(data.heroAsset, fit: BoxFit.cover),
            Container(color: Colors.black.withValues(alpha: 0.35)),
            Positioned(
              top: 56,
              left: 20,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.bienvenidaTextoFuerte),
                ),
              ),
            ),
            Positioned(
              top: 56,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: SvgPicture.asset(
                  'assets/images/logos/logo-juegos-nacionales-2027.svg',
                  width: 40,
                  height: 40,
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    data.nombre,
                    style: GoogleFonts.openSans(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.subtitulo,
                    style: GoogleFonts.openSans(fontSize: 13, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(_MunicipioData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: _buildStatCard(data.valoracion.toStringAsFixed(1), 'Valoración')),
          const SizedBox(width: 10),
          Expanded(child: _buildStatCard('${data.nLugares}', 'Lugares')),
          const SizedBox(width: 10),
          Expanded(child: _buildStatCard('${data.nRutas}', 'Rutas')),
        ],
      ),
    );
  }

  Widget _buildStatCard(String valor, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.bienvenidaBorde),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            valor,
            style: GoogleFonts.openSans(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.bienvenidaAzul),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.openSans(fontSize: 11, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoria(_MunicipioData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.historiaTitulo,
            style: GoogleFonts.openSans(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.bienvenidaVerde),
          ),
          const SizedBox(height: 8),
          Text(
            data.historiaDescripcion,
            style: GoogleFonts.openSans(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.bienvenidaBorde),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < data.timeline.length; i++) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 44,
                        child: Text(
                          data.timeline[i].anio,
                          style: GoogleFonts.openSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.bienvenidaAzul),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          data.timeline[i].evento,
                          style: GoogleFonts.openSans(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  if (i != data.timeline.length - 1) ...[
                    const SizedBox(height: 14),
                    const Divider(color: AppColors.bienvenidaBorde, height: 1),
                    const SizedBox(height: 14),
                  ],
                ],
                const SizedBox(height: 14),
                const Divider(color: AppColors.bienvenidaBorde, height: 1),
                const SizedBox(height: 14),
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.openSans(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                    children: [
                      TextSpan(
                        text: data.textoFinalBold,
                        style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.bienvenidaTextoFuerte),
                      ),
                      TextSpan(text: data.textoFinalResto),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuePuedesHacer(_MunicipioData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿Qué puedes hacer?',
            style: GoogleFonts.openSans(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.bienvenidaTextoFuerte),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final chip in data.chips)
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 9, 14, 9),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.bienvenidaBorde),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(chip.icon, size: 14, color: AppColors.bienvenidaTextoFuerte),
                      const SizedBox(width: 6),
                      Text(
                        chip.label,
                        style: GoogleFonts.openSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.bienvenidaTextoFuerte),
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

  Widget _buildLugares() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lugares',
            style: GoogleFonts.openSans(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.bienvenidaTextoFuerte),
          ),
          const SizedBox(height: 12),
          if (_loading)
            const LinearProgressIndicator(minHeight: 2)
          else if (_lugares.isEmpty)
            Text(
              'Aún no hay lugares registrados en este municipio.',
              style: GoogleFonts.openSans(fontSize: 13, color: AppColors.textSecondary),
            )
          else
            Column(
              children: [
                for (final lugar in _lugares) ...[
                  NovaListaCard(
                    imagePath: lugar.imageUrl?.isNotEmpty == true
                        ? lugar.imageUrl!
                        : 'assets/images/lugares/foto-estadio-arturo-cumplido.png',
                    nombre: lugar.name,
                    descripcion: lugar.description,
                    rating: lugar.rating,
                    photoSize: 70,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PlaceDetailPage(place: lugar)),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
        ],
      ),
    );
  }
}
