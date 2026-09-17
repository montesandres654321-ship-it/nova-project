// lib/pages/stats_dashboard_page.dart

/// Página principal de estadísticas y analytics del sistema NOVA App.
///
/// Muestra 4 KPIs y 6 gráficas en tiempo real alimentadas por [AnalyticsService]:
/// - **Actividad de escaneos por día** — gráfica de línea con selección de período
/// - **Top establecimientos por escaneos** — gráfica de barras horizontal
/// - **Horario pico** — distribución de escaneos por hora del día (0-23h)
/// - **Turistas nuevos por mes** — evolución mensual de registros
/// - **Distribución de establecimientos por tipo** — donut hotel/restaurante/bar
/// - **Recompensas por día** — tendencia de recompensas generadas
///
/// Soporta 3 breakpoints responsive:
/// - **Desktop** (≥900px): layout sin scroll con columnas [Expanded]
/// - **Tablet** (600-900px): 2 columnas con scroll suave
/// - **Móvil** (<600px): columna única con scroll vertical
///
/// Parámetros de navegación opcionales permiten navegar a otras secciones
/// del [DashboardPage] al interactuar con los KPIs o gráficas.
///
/// REFACTOR: las gráficas, KPIs y controles del header se extrajeron a
/// lib/pages/stats/ (stats_charts.dart, stats_kpi_section.dart,
/// stats_header_controls.dart) para bajar de 772 a <300 líneas, sin
/// cambiar comportamiento.
import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import '../services/analytics_service.dart';
import '../utils/app_theme.dart';
import '../widgets/common/loading_indicator.dart';
import 'stats/stats_header_controls.dart';
import 'stats/stats_kpi_section.dart';
import 'stats/stats_layouts.dart';

/// Widget principal de la página de estadísticas.
///
/// Recibe callbacks de navegación opcionales para conectar los KPIs
/// con las secciones correspondientes del dashboard (lugares, turistas, recompensas).
class StatsDashboardPage extends StatefulWidget {
  final void Function(int index)?   onNavigate;
  final void Function(String tipo)? onNavigateToPlaces;
  final int placesIndex;
  final int usersIndex;
  final int rewardsIndex;
  final int reportsIndex;

  const StatsDashboardPage({
    super.key,
    this.onNavigate,
    this.onNavigateToPlaces,
    this.placesIndex  = 1,
    this.usersIndex   = 3,
    this.rewardsIndex = 4,
    this.reportsIndex = 5,
  });

  @override
  State<StatsDashboardPage> createState() => _StatsDashboardPageState();
}

class _StatsDashboardPageState extends State<StatsDashboardPage> {
  static const double _mobileBreak = 600;
  static const double _tabletBreak = 900;

  final AnalyticsService _analytics = AnalyticsService();

  int _totalScans   = 0;
  int _totalUsers   = 0;
  int _totalPlaces  = 0;
  int _totalRewards = 0;

  List<Map<String, dynamic>> _scansByDay   = [];
  List<Map<String, dynamic>> _scansByHour  = [];
  List<Map<String, dynamic>> _topPlaces    = [];
  List<Map<String, dynamic>> _rewardsByDay = [];
  Map<String, dynamic>       _placesByType = {};

  bool   _loading      = true;
  String _error        = '';
  int    _selectedDays = 0;

  final List<int> _daysOptions = [0, 7, 15, 30, 60, 90];

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ── CARGA EN PARALELO ─────────────────────────────────────
  Future<void> _load() async {
    setState(() { _loading = true; _error = ''; });
    try {
      final days = _selectedDays == 0 ? 3650 : _selectedDays;

      final results = await Future.wait<dynamic>([
        AdminService.getDashboardStats(),
        _analytics.getScansByDay(days: days),
        _analytics.getScansByHour(),
        _analytics.getTopPlacesByScans(limit: 6),
        _analytics.getUsersStats(),
        _analytics.getRewardsByDay(days: days),
        _analytics.getPlacesStats(),
      ]);

      final dashboard    = results[0] as Map<String, dynamic>;
      final scansByDay   = results[1] as List<Map<String, dynamic>>;
      final scansByHour  = results[2] as List<Map<String, dynamic>>;
      final topPlaces    = results[3] as List<Map<String, dynamic>>;
      // results[4] = usersStats (no se muestra en el layout actual)
      final rewardsByDay = results[5] as List<Map<String, dynamic>>;
      final placesStats  = results[6] as Map<String, dynamic>;

      if (!mounted) return;

      final stats      = dashboard['stats']   as Map<String, dynamic>? ?? {};
      final placesData = placesStats['stats'] as Map<String, dynamic>? ?? {};
      final byType     = placesData['byType'] as Map<String, dynamic>? ?? {};

      setState(() {
        _totalScans   = stats['scans']   as int? ?? 0;
        _totalUsers   = stats['users']   as int? ?? 0;
        _totalPlaces  = stats['places']  as int? ?? 0;
        _totalRewards = stats['rewards'] as int? ?? 0;
        _scansByDay   = scansByDay;
        _scansByHour  = scansByHour;
        _topPlaces    = topPlaces;
        _rewardsByDay = rewardsByDay;
        _placesByType = byType;
        _loading      = false;
      });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  StatsTotals get _totals => StatsTotals(
    scans: _totalScans, users: _totalUsers,
    places: _totalPlaces, rewards: _totalRewards,
  );

  // ── BUILD ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingIndicator(message: 'Cargando estadísticas...');
    if (_error.isNotEmpty) return _buildError();

    return ColoredBox(
      color: AppTheme.bgPage,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  // ── HEADER con período y refresh ─────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text('Estadísticas del Sistema',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                    color: AppTheme.textHead)),
          ),
          PeriodDropdown(
            value: _selectedDays,
            options: _daysOptions,
            onChanged: (v) {
              if (v != null) {
                setState(() => _selectedDays = v);
                _load();
              }
            },
          ),
          const SizedBox(width: 8),
          DashIconButton(
            icon: Icons.refresh_rounded,
            tooltip: 'Actualizar',
            onTap: _load,
          ),
        ],
      ),
    );
  }

  // ── BODY con LayoutBuilder ────────────────────────────────
  Widget _buildBody() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        if (w >= _tabletBreak) return _buildDesktopLayout();
        if (w >= _mobileBreak) return _buildTabletLayout();
        return _buildMobileLayout();
      },
    );
  }

  Widget _buildDesktopLayout() => statsDesktopLayout(
      totals: _totals, scansByDay: _scansByDay, scansByHour: _scansByHour,
      topPlaces: _topPlaces, rewardsByDay: _rewardsByDay,
      placesByType: _placesByType, selectedDays: _selectedDays,
      onKpiTap: _navigateFromKpi);

  Widget _buildTabletLayout() => statsTabletLayout(
      totals: _totals, scansByDay: _scansByDay, scansByHour: _scansByHour,
      topPlaces: _topPlaces, rewardsByDay: _rewardsByDay,
      placesByType: _placesByType, selectedDays: _selectedDays,
      onKpiTap: _navigateFromKpi);

  Widget _buildMobileLayout() => statsMobileLayout(
      totals: _totals, scansByDay: _scansByDay, scansByHour: _scansByHour,
      topPlaces: _topPlaces, rewardsByDay: _rewardsByDay,
      placesByType: _placesByType, selectedDays: _selectedDays,
      onKpiTap: _navigateFromKpi);

  void _navigateFromKpi(String label) {
    switch (label) {
      case 'Total Escaneos':
        Navigator.pushNamed(context, '/scans');
        break;
      case 'Turistas':
        if (widget.onNavigate != null) {
          widget.onNavigate!(widget.usersIndex);
        } else {
          Navigator.pushNamed(context, '/users');
        }
        break;
      case 'Lugares Activos':
        if (widget.onNavigate != null) {
          widget.onNavigate!(widget.placesIndex);
        } else {
          Navigator.pushNamed(context, '/places');
        }
        break;
      case 'Recompensas':
        if (widget.onNavigate != null) {
          widget.onNavigate!(widget.rewardsIndex);
        } else {
          Navigator.pushNamed(context, '/rewards');
        }
        break;
    }
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
          const SizedBox(height: 12),
          Text(_error,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.onPrimary),
          ),
        ],
      ),
    );
  }
}
