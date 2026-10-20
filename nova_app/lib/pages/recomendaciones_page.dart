// lib/pages/recomendaciones_page.dart
// Pantalla de recomendaciones por municipio — destino del deep link
// nova://explorar/:municipio disparado desde una notificación push
// (ver notification_service.dart) y de la ruta nombrada '/recomendaciones'.
// El municipio llega como settings.arguments de la ruta (patrón Regla 5
// del skill nova-flutter), no por constructor — así funciona igual sea
// `Navigator.pushNamed(context, '/recomendaciones', arguments: slug)`
// desde cualquier pantalla.
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/design/app_colors.dart';
import '../models/place_model.dart';
import '../services/recommendations_service.dart';
import '../utils/constants.dart';
import 'place_detail_page.dart';

const Map<String, String> _kMunicipioLabels = {
  'sincelejo': 'Sincelejo',
  'santiago_de_tolu': 'Santiago de Tolú',
  'covenas': 'Coveñas',
  'sampues': 'Sampués',
};

// Orden fijo de las categorías con tab propio — el resto de los 13 tipos
// de `places.tipo` (escenario_deportivo, parque, ruta, gastronomia,
// compras, servicio) solo aparece en el tab "Todos".
const List<MapEntry<String, String>> _kCategoriaOrder = [
  MapEntry('restaurant', 'Restaurantes'),
  MapEntry('hotel', 'Hoteles'),
  MapEntry('playa', 'Playas'),
  MapEntry('naturaleza', 'Naturaleza'),
  MapEntry('cultura', 'Cultura'),
  MapEntry('artesania', 'Artesanía'),
  MapEntry('bar', 'Bares'),
];

class _CategoriaTab {
  final String label;
  final List<Place> lugares;
  const _CategoriaTab(this.label, this.lugares);
}

IconData _iconoParaTipo(String tipo) {
  switch (tipo) {
    case 'restaurant':
      return Icons.restaurant;
    case 'hotel':
      return Icons.hotel;
    case 'bar':
      return Icons.local_bar;
    case 'playa':
      return Icons.beach_access;
    case 'naturaleza':
      return Icons.park;
    case 'cultura':
      return Icons.museum;
    case 'artesania':
      return Icons.brush;
    default:
      return Icons.place;
  }
}

class RecomendacionesPage extends StatefulWidget {
  const RecomendacionesPage({super.key});

  @override
  State<RecomendacionesPage> createState() => _RecomendacionesPageState();
}

class _RecomendacionesPageState extends State<RecomendacionesPage> {
  bool _loading = true;
  String? _error;
  List<Place> _lugares = [];
  String _municipio = '';
  bool _didLoad = false;

  // ModalRoute.of(context) necesita el árbol ya enlazado — no está
  // disponible todavía en initState(), así que la primera carga se
  // dispara desde didChangeDependencies() (se ejecuta una sola vez
  // gracias a _didLoad).
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didLoad) {
      _didLoad = true;
      final args = ModalRoute.of(context)?.settings.arguments;
      _municipio = args is String ? args : '';
      _loadRecommendations();
    }
  }

  Future<void> _loadRecommendations() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.keyToken) ?? '';

      // Sin token válido no podemos llamar /recommendations (requiere JWT).
      // Redirigimos al preview público para que el usuario pueda ver los
      // lugares e iniciar sesión desde ahí.
      if (token.isEmpty) {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed(
          '/notificacion-preview',
          arguments: {'municipio': _municipio},
        );
        return;
      }

      final data =
          await RecommendationsService.getByMunicipio(_municipio, token);
      if (!mounted) return;
      setState(() => _lugares = data.map(Place.fromJson).toList());
    } catch (e) {
      if (!mounted) return;
      // Si el backend devuelve 401 (token expirado), redirigir al preview
      final errorStr = e.toString();
      if (errorStr.contains('401') || errorStr.contains('403')) {
        Navigator.of(context).pushReplacementNamed(
          '/notificacion-preview',
          arguments: {'municipio': _municipio},
        );
        return;
      }
      setState(() => _error = 'No pudimos cargar las recomendaciones');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String get _tituloMunicipio => _kMunicipioLabels[_municipio] ?? _municipio;

  // Solo incluye categorías con al menos 1 lugar — "Todos" siempre está.
  List<_CategoriaTab> _buildCategorias() {
    final categorias = <_CategoriaTab>[_CategoriaTab('Todos', _lugares)];
    for (final entry in _kCategoriaOrder) {
      final filtrados = _lugares.where((p) => p.tipo == entry.key).toList();
      if (filtrados.isNotEmpty) {
        categorias.add(_CategoriaTab(entry.value, filtrados));
      }
    }
    return categorias;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.bienvenidaAzul,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _tituloMunicipio,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const Text(
              'Lugares recomendados para ti',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.bienvenidaAzul),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: AppColors.textHint),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadRecommendations,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bienvenidaAzul,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_lugares.isEmpty) {
      return const Center(
        child: Text(
          'Todavía no hay lugares recomendados en este municipio.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    final categorias = _buildCategorias();

    return DefaultTabController(
      length: categorias.length,
      child: Column(
        children: [
          Material(
            color: Colors.white,
            child: TabBar(
              isScrollable: true,
              indicatorColor: AppColors.bienvenidaAzul,
              labelColor: AppColors.bienvenidaAzul,
              unselectedLabelColor: AppColors.textSecondary,
              tabs: [for (final c in categorias) Tab(text: c.label)],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [for (final c in categorias) _buildLista(c.lugares)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLista(List<Place> lugares) {
    if (lugares.isEmpty) {
      return const Center(
        child: Text(
          'No hay lugares en esta categoría todavía.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: lugares.length,
      itemBuilder: (_, i) {
        final lugar = lugares[i];
        return _PlaceCard(
          place: lugar,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PlaceDetailPage(place: lugar)),
          ),
        );
      },
    );
  }
}

class _PlaceCard extends StatelessWidget {
  const _PlaceCard({required this.place, required this.onTap});

  final Place place;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(_iconoParaTipo(place.tipo),
                          size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        place.tipoLabel,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 12),
                      const Text('⭐', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 2),
                      Text(
                        place.rating.toStringAsFixed(1),
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  if (place.hasReward &&
                      (place.rewardName?.isNotEmpty ?? false)) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.sistemaVerdeClaro,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '🎁 ${place.rewardName}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
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

  Widget _buildImage() {
    if (place.imageUrl == null || place.imageUrl!.isEmpty) {
      return Container(
        height: 160,
        width: double.infinity,
        color: AppColors.surfaceVariant,
        child: const Icon(Icons.place, size: 48, color: AppColors.textHint),
      );
    }
    return Image.network(
      place.imageUrl!,
      height: 160,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        height: 160,
        color: AppColors.surfaceVariant,
        child: const Icon(Icons.place, size: 48, color: AppColors.textHint),
      ),
    );
  }
}
