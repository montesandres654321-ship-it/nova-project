// lib/pages/notificacion_preview_page.dart
// ============================================================
// Pantalla PÚBLICA (sin login) — se abre cuando el usuario toca
// una notificación push y NO tiene sesión activa.
//
// Flujo:
//   1. Llega con arguments = { 'municipio': 'sampues', 'title': '...', 'body': '...' }
//   2. Llama GET /places?municipio=sampues  (endpoint público, sin JWT)
//   3. Muestra: nombre, foto y categoría de cada lugar
//   4. Tap en cualquier lugar → LoginPage (con returnRoute en SharedPreferences)
//   5. Botón CTA al final → mismo efecto
//
// Cuando el usuario SÍ tiene sesión, notification_service.dart lo manda
// directamente a /recomendaciones y esta página nunca se abre.
// ============================================================

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../core/design/app_colors.dart';
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
    case 'restaurant': return Icons.restaurant_rounded;
    case 'hotel':      return Icons.hotel_rounded;
    case 'bar':        return Icons.local_bar_rounded;
    case 'playa':      return Icons.beach_access_rounded;
    case 'naturaleza': return Icons.park_rounded;
    case 'cultura':    return Icons.museum_rounded;
    case 'artesania':  return Icons.brush_rounded;
    default:           return Icons.place_rounded;
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
  bool _didInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInit) return;
    _didInit = true;

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    _municipio = args?['municipio'] as String? ?? '';
    _title     = args?['title']     as String? ?? '¡Hay lugares para ti!';
    _body      = args?['body']      as String? ??
        'Descubre lo mejor de ${_kMunicipioLabels[_municipio] ?? _municipio}';

    if (_municipio.isNotEmpty) {
      _cargarLugares();
    } else {
      setState(() => _cargando = false);
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
            .take(6)
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
    await prefs.setString('return_route', '/recomendaciones');
    await prefs.setString('return_route_municipio', _municipio);
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  // ─── UI ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final municipioLabel = _kMunicipioLabels[_municipio] ?? _municipio;

    return Scaffold(
      backgroundColor: AppColors.bienvenidaFondoInput,
      body: CustomScrollView(
        slivers: [
          // ── AppBar con gradiente del sistema de diseño ────────────────
          SliverAppBar(
            expandedHeight: 210,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primaryLight,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Chip "Vista previa"
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.22),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.35),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.visibility_rounded,
                                  color: Colors.white, size: 13),
                              SizedBox(width: 4),
                              Text(
                                'Vista previa · Sin sesión',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Título de la notificación
                        Text(
                          _title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        // Subtítulo
                        Text(
                          _body,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 13,
                            height: 1.3,
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
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── Encabezado de sección ─────────────────────────────
                if (_municipio.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: AppColors.primary,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          municipioLabel.isNotEmpty
                              ? 'Lugares en $municipioLabel'
                              : 'Lugares recomendados',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

                // ── Estado de carga / error / lista ───────────────────
                if (_cargando) ...[
                  const SizedBox(height: 40),
                  const Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(color: AppColors.primary),
                        SizedBox(height: 12),
                        Text(
                          'Cargando lugares…',
                          style: TextStyle(
                              color: AppColors.textHint, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ] else if (_error != null) ...[
                  const SizedBox(height: 40),
                  Center(
                    child: Column(
                      children: [
                        const Icon(Icons.wifi_off_rounded,
                            color: AppColors.textHint, size: 48),
                        const SizedBox(height: 12),
                        Text(_error!,
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 14),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _cargarLugares,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Reintentar'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ] else if (_lugares.isEmpty) ...[
                  const SizedBox(height: 40),
                  const Center(
                    child: Text(
                      'No hay lugares disponibles en este momento.',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 40),
                ] else ...[
                  // ── Grid de tarjetas (2 columnas) ─────────────────
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: _lugares.length,
                    itemBuilder: (context, index) => _LugarCard(
                      lugar: _lugares[index],
                      onTap: _irALogin,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // ── Banner CTA "inicia sesión" ────────────────────────
                _LoginCTABanner(onTap: _irALogin),

                const SizedBox(height: 16),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TARJETA DE LUGAR — con tap que lleva al login
// ═══════════════════════════════════════════════════════════════════════════
class _LugarCard extends StatelessWidget {
  final _PreviewPlace lugar;
  final VoidCallback onTap;

  const _LugarCard({required this.lugar, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Imagen con overlays ───────────────────────────────────
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildImage(lugar.imageUrl),

                  // Gradiente inferior sutil
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 48,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.30),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Badge de recompensa (esquina superior derecha)
                  if (lugar.hasReward)
                    Positioned(
                      top: 7,
                      right: 7,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.warning,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '🎁',
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                    ),

                  // Ícono de candado / login (esquina inferior derecha)
                  Positioned(
                    bottom: 7,
                    right: 7,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.lock_rounded,
                        size: 12,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Info ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(9, 7, 9, 9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tipo con ícono
                  Row(
                    children: [
                      Icon(
                        _iconoParaTipo(lugar.tipo),
                        color: AppColors.primary,
                        size: 11,
                      ),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          _labelParaTipo(lugar.tipo),
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.1,
                          ),
                          overflow: TextOverflow.ellipsis,
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
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Rating
                  if (lugar.rating != null && lugar.rating! > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: AppColors.warning, size: 12),
                        const SizedBox(width: 2),
                        Text(
                          lugar.rating!.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String? url) {
    if (url == null || url.isEmpty) {
      return Container(
        color: AppColors.surfaceVariant,
        child: const Center(
          child: Icon(Icons.image_not_supported_rounded,
              color: AppColors.textHint, size: 32),
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(
        color: AppColors.surfaceVariant,
        child: const Center(
          child: CircularProgressIndicator(
              strokeWidth: 2, color: AppColors.primary),
        ),
      ),
      errorWidget: (_, __, ___) => Container(
        color: AppColors.surfaceVariant,
        child: const Center(
          child: Icon(Icons.broken_image_rounded,
              color: AppColors.textHint, size: 32),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// BANNER CTA — "Inicia sesión para ver todo"
// ═══════════════════════════════════════════════════════════════════════════
class _LoginCTABanner extends StatelessWidget {
  final VoidCallback onTap;
  const _LoginCTABanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Ícono con fondo
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_open_rounded,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Inicia sesión para ver todo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Accede a recompensas, escanea QR y descubre lo mejor del Golfo de Morrosquillo',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.explore_rounded, size: 18),
              label: const Text(
                'Explorar y ganar recompensas',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
