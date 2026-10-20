// lib/pages/notificacion_preview_page.dart
// ============================================================
// Pantalla PÚBLICA (sin login) — se abre cuando el usuario toca
// una notificación push y NO tiene sesión activa.
//
// Flujo:
//   1. Llega con arguments = { 'municipio': 'sampues', 'title': '...', 'body': '...' }
//   2. Llama GET /places?municipio=sampues  (endpoint público, sin JWT)
//   3. Muestra: nombre, foto y categoría de cada lugar
//   4. Botón CTA → LoginPage con returnRoute guardado en SharedPreferences
//
// Cuando el usuario SÍ tiene sesión, notification_service.dart lo manda
// directamente a /recomendaciones y esta página nunca se abre.
// ============================================================

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../utils/constants.dart';

// ─── Etiquetas legibles por municipio ───────────────────────────────────────
const Map<String, String> _kMunicipioLabels = {
  'sincelejo':        'Sincelejo',
  'santiago_de_tolu': 'Santiago de Tolú',
  'covenas':          'Coveñas',
  'sampues':          'Sampués',
};

// ─── Icono por categoría ─────────────────────────────────────────────────────
IconData _iconoParaTipo(String tipo) {
  switch (tipo) {
    case 'restaurant': return Icons.restaurant;
    case 'hotel':      return Icons.hotel;
    case 'bar':        return Icons.local_bar;
    case 'playa':      return Icons.beach_access;
    case 'naturaleza': return Icons.park;
    case 'cultura':    return Icons.museum;
    case 'artesania':  return Icons.brush;
    default:           return Icons.place;
  }
}

// ─── Etiqueta legible por tipo ───────────────────────────────────────────────
String _labelParaTipo(String tipo) {
  switch (tipo) {
    case 'restaurant': return 'Restaurante';
    case 'hotel':      return 'Hotel';
    case 'bar':        return 'Bar';
    case 'playa':      return 'Playa';
    case 'naturaleza': return 'Naturaleza';
    case 'cultura':    return 'Cultura';
    case 'artesania':  return 'Artesanía';
    default:           return tipo;
  }
}

// ─── Modelo mínimo para el preview ──────────────────────────────────────────
class _PreviewPlace {
  final String name;
  final String tipo;
  final String? imageUrl;
  final double? rating;
  final bool hasReward;

  _PreviewPlace({
    required this.name,
    required this.tipo,
    this.imageUrl,
    this.rating,
    this.hasReward = false,
  });

  factory _PreviewPlace.fromJson(Map<String, dynamic> json) {
    return _PreviewPlace(
      name:      json['name']      as String? ?? '',
      tipo:      json['tipo']      as String? ?? 'lugar',
      imageUrl:  json['image_url'] as String?,
      rating:    (json['rating'] as num?)?.toDouble(),
      hasReward: json['has_reward'] as bool? ?? false,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PÁGINA
// ═══════════════════════════════════════════════════════════════════════════
class NotificacionPreviewPage extends StatefulWidget {
  const NotificacionPreviewPage({super.key});

  @override
  State<NotificacionPreviewPage> createState() =>
      _NotificacionPreviewPageState();
}

class _NotificacionPreviewPageState
    extends State<NotificacionPreviewPage> {
  // Argumentos recibidos desde la notificación
  String _municipio = '';
  String _title     = '';
  String _body      = '';

  // Estado de carga
  List<_PreviewPlace> _lugares = [];
  bool _cargando = true;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    _municipio = args?['municipio'] as String? ?? '';
    _title     = args?['title']     as String? ?? '¡Hay lugares para ti!';
    _body      = args?['body']      as String? ??
        'Descubre lo mejor de ${_kMunicipioLabels[_municipio] ?? _municipio}';

    if (_municipio.isNotEmpty && _lugares.isEmpty && _cargando) {
      _cargarLugares();
    }
  }

  Future<void> _cargarLugares() async {
    setState(() {
      _cargando = true;
      _error    = null;
    });

    try {
      // Endpoint público — NO necesita Authorization header
      final uri = Uri.parse(
        '${AppConstants.backendUrl}/places?municipio=$_municipio',
      );
      final response = await http.get(uri).timeout(AppConstants.timeoutNormal);

      if (response.statusCode == 200) {
        final json   = jsonDecode(response.body) as Map<String, dynamic>;
        final data   = json['data'] as List<dynamic>? ?? [];
        final parsed = data
            .map((e) => _PreviewPlace.fromJson(e as Map<String, dynamic>))
            .where((p) => p.name.isNotEmpty)
            .take(6) // máximo 6 cards en el preview
            .toList();

        setState(() {
          _lugares  = parsed;
          _cargando = false;
        });
      } else {
        setState(() {
          _error    = 'No pudimos cargar los lugares (${response.statusCode})';
          _cargando = false;
        });
      }
    } catch (e) {
      setState(() {
        _error    = 'Sin conexión. Intenta de nuevo.';
        _cargando = false;
      });
    }
  }

  // Guarda la ruta de retorno y navega al login
  Future<void> _irALogin() async {
    final prefs = await SharedPreferences.getInstance();
    // Después del login, SplashPage o LoginPage redirige aquí
    await prefs.setString(
      'return_route',
      '/recomendaciones',
    );
    await prefs.setString(
      'return_route_municipio',
      _municipio,
    );
    if (!mounted) return;
    Navigator.pushNamed(context, '/');
  }

  // ─── UI ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colorTeal  = const Color(0xFF06B6A4);
    final municipioLabel =
        _kMunicipioLabels[_municipio] ?? _municipio;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // ── AppBar con gradiente ──────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: colorTeal,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF0D9488),
                      colorTeal,
                      const Color(0xFF22D3EE),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Chip "Vista previa"
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.visibility,
                                  color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'Vista previa',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Título de la notificación
                        Text(
                          _title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        // Subtítulo
                        Text(
                          _body,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.88),
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Contenido ──────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Encabezado de sección
                if (_municipio.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Icon(Icons.location_on,
                            color: colorTeal, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Lugares en $municipioLabel',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Estado de carga / error / lista
                if (_cargando) ...[
                  const SizedBox(height: 32),
                  Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(color: colorTeal),
                        const SizedBox(height: 12),
                        Text(
                          'Cargando lugares…',
                          style: TextStyle(
                              color: Colors.grey[500], fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ] else if (_error != null) ...[
                  const SizedBox(height: 32),
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.wifi_off,
                            color: Colors.grey[400], size: 48),
                        const SizedBox(height: 12),
                        Text(_error!,
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 14),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _cargarLugares,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                          style: OutlinedButton.styleFrom(
                              foregroundColor: colorTeal,
                              side: BorderSide(color: colorTeal)),
                        ),
                      ],
                    ),
                  ),
                ] else if (_lugares.isEmpty) ...[
                  const SizedBox(height: 32),
                  Center(
                    child: Text(
                      'No hay lugares disponibles en este momento.',
                      style: TextStyle(
                          color: Colors.grey[500], fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ] else ...[
                  // Grid de tarjetas
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.78,
                    ),
                    itemCount: _lugares.length,
                    itemBuilder: (context, index) =>
                        _LugarCard(lugar: _lugares[index]),
                  ),
                ],

                const SizedBox(height: 24),

                // ── Banner "inicia sesión" ─────────────────────────────
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorTeal.withOpacity(0.08),
                        const Color(0xFF22D3EE).withOpacity(0.06),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: colorTeal.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.lock_outline,
                          color: colorTeal, size: 32),
                      const SizedBox(height: 10),
                      const Text(
                        'Inicia sesión para ver recompensas, escanear QR y mucho más',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _irALogin,
                          icon: const Icon(Icons.explore, size: 20),
                          label: const Text(
                            'Explorar y ganar recompensas',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorTeal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TARJETA DE LUGAR
// ═══════════════════════════════════════════════════════════════════════════
class _LugarCard extends StatelessWidget {
  final _PreviewPlace lugar;
  const _LugarCard({required this.lugar});

  @override
  Widget build(BuildContext context) {
    final colorTeal = const Color(0xFF06B6A4);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Imagen ──────────────────────────────────────────────────
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildImage(lugar.imageUrl),

                // Gradiente inferior para el badge
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 40,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.35),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Badge de recompensa
                if (lugar.hasReward)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '🎁 Premio',
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Info ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Categoría
                Row(
                  children: [
                    Icon(_iconoParaTipo(lugar.tipo),
                        color: colorTeal, size: 12),
                    const SizedBox(width: 3),
                    Text(
                      _labelParaTipo(lugar.tipo),
                      style: TextStyle(
                        fontSize: 11,
                        color: colorTeal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                // Nombre
                Text(
                  lugar.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                // Rating
                if (lugar.rating != null && lugar.rating! > 0) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star,
                          color: Color(0xFFFBBF24), size: 12),
                      const SizedBox(width: 2),
                      Text(
                        lugar.rating!.toStringAsFixed(1),
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String? url) {
    if (url == null || url.isEmpty) {
      return Container(
        color: const Color(0xFFE2E8F0),
        child: const Center(
          child: Icon(Icons.image_not_supported,
              color: Color(0xFF94A3B8), size: 36),
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(
        color: const Color(0xFFE2E8F0),
        child: const Center(
          child: CircularProgressIndicator(
              strokeWidth: 2, color: Color(0xFF06B6A4)),
        ),
      ),
      errorWidget: (_, __, ___) => Container(
        color: const Color(0xFFE2E8F0),
        child: const Center(
          child: Icon(Icons.broken_image,
              color: Color(0xFF94A3B8), size: 36),
        ),
      ),
    );
  }
}
