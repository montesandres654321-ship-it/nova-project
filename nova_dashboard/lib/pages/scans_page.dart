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
///
/// REFACTOR: tabla, lista móvil y barra superior extraídas a
/// lib/pages/scans/ para bajar de 514 a <300 líneas.
library;

import 'package:nova_dashboard/utils/app_theme.dart';
import 'package:flutter/material.dart';
import '../services/analytics_service.dart';
import 'scans/scans_tokens.dart';
import 'scans/widgets/scans_desktop_table.dart';
import 'scans/widgets/scans_mobile_list.dart';
import 'scans/widgets/scans_toolbar.dart';

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
            ScansToolbar(
              total: total,
              onRefresh: () => _load(page: _currentPage),
              searchCtrl: _searchCtrl,
              search: _search,
              onSearch: _onSearch,
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
                        color: kScansPrimary))
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
      if (isMobile) return ScansMobileList(scans: _scans);
      return ScansDesktopTable(scans: _scans);
    });
  }

  Widget _buildError() => Center(child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Icon(Icons.error_outline, size: 40, color: AppTheme.error),
      const SizedBox(height: 12),
      Text(_error, textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13)),
      const SizedBox(height: 16),
      ElevatedButton.icon(
        onPressed: _load,
        icon: const Icon(Icons.refresh),
        label: const Text('Reintentar'),
        style: ElevatedButton.styleFrom(
            backgroundColor: kScansPrimary,
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
