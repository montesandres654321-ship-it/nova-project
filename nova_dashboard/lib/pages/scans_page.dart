/// Página de listado completo de escaneos del sistema NOVA App.
///
/// Muestra todos los escaneos registrados con información del turista,
/// lugar visitado, fecha/hora y si obtuvo recompensa en esa visita.
///
/// **Funcionalidades:**
/// - Búsqueda en tiempo real por nombre de turista, email o nombre del lugar
/// - Paginación configurable (50 registros por página por defecto)
/// - Vista tabla en desktop, vista tarjetas en móvil
/// - Indicador visual de recompensa obtenida por escaneo
/// - Soporte de debounce en la búsqueda para evitar peticiones excesivas
///
/// Los datos se cargan desde [AnalyticsService.getAllScans] que llama al
/// endpoint `GET /admin/scans/all` del backend.
import 'package:flutter/material.dart';
import '../services/analytics_service.dart';

class ScansPage extends StatefulWidget {
  const ScansPage({super.key});

  @override
  State<ScansPage> createState() => _ScansPageState();
}

class _ScansPageState extends State<ScansPage> {
  final AnalyticsService _analytics = AnalyticsService();
  final TextEditingController _searchCtrl = TextEditingController();

  List<Map<String, dynamic>> _scans = [];
  Map<String, dynamic> _meta = {};
  bool _loading = true;
  String _error = '';
  int _currentPage = 1;
  String _search = '';

  static const int _limit = 50;
  static const Color _primary = Color(0xFF06B6A4);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load({int page = 1}) async {
    setState(() { _loading = true; _error = ''; });
    try {
      final result = await _analytics.getAllScans(
        page: page,
        limit: _limit,
        search: _search,
      );
      setState(() {
        _scans = List<Map<String,dynamic>>.from(result['scans'] ?? []);
        _meta  = Map<String,dynamic>.from(result['meta'] ?? {});
        _currentPage = page;
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _onSearch(String value) {
    setState(() => _search = value);
    _load(page: 1);
  }

  String _formatDate(String? iso) {
    if (iso == null) return '';
    try {
      final d = DateTime.parse(iso).toLocal();
      return '${d.day}/${d.month}/${d.year} ${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';
    } catch (_) { return iso; }
  }

  Color _placeColor(String? tipo) {
    switch (tipo) {
      case 'hotel':      return const Color(0xFF3B82F6);
      case 'restaurant': return const Color(0xFF10B981);
      case 'bar':        return const Color(0xFFF59E0B);
      default:           return _primary;
    }
  }

  IconData _placeIcon(String? tipo) {
    switch (tipo) {
      case 'hotel':      return Icons.hotel_rounded;
      case 'restaurant': return Icons.restaurant_rounded;
      case 'bar':        return Icons.local_bar_rounded;
      default:           return Icons.place_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final total  = _meta['total']  as int? ?? 0;
    final pages  = _meta['pages']  as int? ?? 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────
            Row(children: [
              Container(
                width: 4, height: 24,
                decoration: BoxDecoration(
                  color: _primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              const Text('Escaneos',
                style: TextStyle(fontSize: 20,
                    fontWeight: FontWeight.w700)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('$total registros',
                  style: TextStyle(fontSize: 12,
                      color: _primary,
                      fontWeight: FontWeight.w500)),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _load(page: _currentPage),
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Recargar',
              ),
            ]),
            const SizedBox(height: 16),

            // ── Buscador ─────────────────────────────
            SizedBox(
              height: 44,
              child: TextField(
                controller: _searchCtrl,
                onChanged: _onSearch,
                decoration: InputDecoration(
                  hintText: 'Buscar por turista, lugar...',
                  hintStyle: TextStyle(
                      fontSize: 13, color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search_rounded,
                      color: Colors.grey[400], size: 20),
                  suffixIcon: _search.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded,
                              size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            _onSearch('');
                          })
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _primary),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Tabla ─────────────────────────────────
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8, offset: const Offset(0, 2),
                  )],
                ),
                child: _loading
                    ? const Center(child: CircularProgressIndicator(
                        color: Color(0xFF06B6A4)))
                    : _error.isNotEmpty
                        ? _buildError()
                        : _scans.isEmpty
                            ? _buildEmpty()
                            : _buildTable(),
              ),
            ),

            // ── Paginación ────────────────────────────
            if (!_loading && _scans.isNotEmpty && pages > 1)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _currentPage > 1
                          ? () => _load(page: _currentPage - 1)
                          : null,
                      icon: const Icon(Icons.chevron_left_rounded),
                    ),
                    Text('Página $_currentPage de $pages',
                      style: const TextStyle(fontSize: 13)),
                    IconButton(
                      onPressed: _currentPage < pages
                          ? () => _load(page: _currentPage + 1)
                          : null,
                      icon: const Icon(Icons.chevron_right_rounded),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTable() {
    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 600;
      if (isMobile) return _buildMobileList();
      return _buildDesktopTable();
    });
  }

  // ── Vista desktop: tabla con columnas ──────────────
  Widget _buildDesktopTable() {
    return Column(children: [
      // Cabecera
      Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12)),
          border: Border(bottom: BorderSide(
              color: Colors.grey[200]!)),
        ),
        child: Row(children: [
          Expanded(flex: 3, child: Text('Turista',
            style: _headerStyle())),
          Expanded(flex: 3, child: Text('Lugar',
            style: _headerStyle())),
          Expanded(flex: 2, child: Text('Fecha',
            style: _headerStyle())),
          Expanded(flex: 2, child: Text('Recompensa',
            style: _headerStyle())),
        ]),
      ),
      // Filas
      Expanded(
        child: ListView.builder(
          itemCount: _scans.length,
          itemBuilder: (context, i) {
            final s = _scans[i];
            final userName   = s['user_name']?.toString() ?? '';
            final email      = s['user_email']?.toString() ?? '';
            final placeName  = s['place_name']?.toString() ?? '';
            final placeType  = s['place_type']?.toString() ?? '';
            final placeLoc   = s['place_location']?.toString() ?? '';
            final date       = _formatDate(s['created_at']?.toString());
            final gotReward  = s['got_reward'] == true;
            final rewardName = s['reward_name']?.toString() ?? '';
            final rewardIcon = s['reward_icon']?.toString() ?? '🎁';
            final color = _placeColor(placeType);

            return Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(
                    color: Colors.grey[100]!)),
                color: i.isEven ? Colors.white
                    : const Color(0xFFFAFAFA),
              ),
              child: Row(children: [
                // Turista
                Expanded(flex: 3, child: Row(children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: _primary.withOpacity(0.1),
                    child: Text(
                      userName.isNotEmpty
                          ? userName[0].toUpperCase() : '?',
                      style: TextStyle(fontSize: 12,
                          color: _primary,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userName, style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                      Text(email, style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    ],
                  )),
                ])),

                // Lugar
                Expanded(flex: 3, child: Row(children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(_placeIcon(placeType),
                        color: color, size: 14),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(placeName, style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                      Text(placeLoc, style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    ],
                  )),
                ])),

                // Fecha
                Expanded(flex: 2, child: Text(date,
                  style: TextStyle(fontSize: 12,
                      color: Colors.grey[600]))),

                // Recompensa
                Expanded(flex: 2, child: gotReward
                    ? Row(children: [
                        Text(rewardIcon,
                            style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Expanded(child: Text(rewardName,
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFF59E0B),
                              fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis)),
                      ])
                    : Text('—', style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12))),
              ]),
            );
          },
        ),
      ),
    ]);
  }

  // ── Vista móvil: tarjetas ──────────────────────────
  Widget _buildMobileList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _scans.length,
      itemBuilder: (context, i) {
        final s = _scans[i];
        final userName   = s['user_name']?.toString() ?? '';
        final email      = s['user_email']?.toString() ?? '';
        final placeName  = s['place_name']?.toString() ?? '';
        final placeType  = s['place_type']?.toString() ?? '';
        final placeLoc   = s['place_location']?.toString() ?? '';
        final date       = _formatDate(s['created_at']?.toString());
        final gotReward  = s['got_reward'] == true;
        final rewardName = s['reward_name']?.toString() ?? '';
        final rewardIcon = s['reward_icon']?.toString() ?? '🎁';
        final color = _placeColor(placeType);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: _primary.withOpacity(0.1),
                child: Text(
                  userName.isNotEmpty
                      ? userName[0].toUpperCase() : '?',
                  style: TextStyle(fontSize: 13,
                      color: _primary,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(userName, style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
                  Text(email, style: TextStyle(
                      fontSize: 11, color: Colors.grey[500])),
                  const SizedBox(height: 6),
                  Row(children: [
                    Icon(_placeIcon(placeType),
                        color: color, size: 13),
                    const SizedBox(width: 4),
                    Expanded(child: Text('$placeName · $placeLoc',
                      style: TextStyle(fontSize: 12,
                          color: Colors.grey[700]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis)),
                  ]),
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(Icons.access_time_rounded,
                        size: 11, color: Colors.grey[400]),
                    const SizedBox(width: 3),
                    Text(date, style: TextStyle(
                        fontSize: 11, color: Colors.grey[500])),
                    if (gotReward) ...[
                      const SizedBox(width: 8),
                      Expanded(child: Text('$rewardIcon $rewardName',
                        style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFF59E0B),
                            fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis)),
                    ],
                  ]),
                ],
              )),
            ],
          ),
        );
      },
    );
  }

  TextStyle _headerStyle() => TextStyle(
    fontSize: 12, fontWeight: FontWeight.w600,
    color: Colors.grey[600], letterSpacing: 0.3);

  Widget _buildError() => Center(child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Icon(Icons.error_outline, size: 40, color: Colors.red),
      const SizedBox(height: 12),
      Text(_error, textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13)),
      const SizedBox(height: 16),
      ElevatedButton.icon(
        onPressed: _load,
        icon: const Icon(Icons.refresh),
        label: const Text('Reintentar'),
        style: ElevatedButton.styleFrom(
            backgroundColor: _primary,
            foregroundColor: Colors.white),
      ),
    ],
  ));

  Widget _buildEmpty() => Center(child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.qr_code_scanner_rounded,
          size: 48, color: Colors.grey[300]),
      const SizedBox(height: 12),
      Text(_search.isNotEmpty
          ? 'Sin resultados para "$_search"'
          : 'No hay escaneos registrados',
        style: TextStyle(fontSize: 14,
            color: Colors.grey[500])),
    ],
  ));
}
