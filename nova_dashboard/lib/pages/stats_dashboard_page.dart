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
import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import '../services/analytics_service.dart';
import '../utils/app_theme.dart';
import '../widgets/common/loading_indicator.dart';
import '../widgets/charts/line_chart_widget.dart';
import '../widgets/charts/bar_chart_widget.dart';
import '../widgets/charts/donut_chart_widget.dart';

// Design tokens locales eliminados (Paso 2, Lote 3) — migrados a AppTheme:
//   AppTheme.primary   (#06B6A4) → AppTheme.primary   (match exacto)
//   AppTheme.bgPage    (#F1F5F9) → AppTheme.bgPage    (sin match exacto — consolidado)
//   AppTheme.textHead  (#0F172A) → AppTheme.textHead  (sin match exacto — consolidado)
//   AppTheme.textMuted (#64748B) → AppTheme.textMuted (sin match exacto — consolidado)
//   AppTheme.border    (#E2E8F0) → AppTheme.border    (match casi exacto)

// ──────────────────────────────────────────────────────────────

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

// ──────────────────────────────────────────────────────────────
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
          _PeriodDropdown(
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
          _DashIconButton(
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

  // ═══════════════════════════════════════════════════════
  // DESKTOP (>= 900px) — sin scroll
  // ═══════════════════════════════════════════════════════
  Widget _buildDesktopLayout() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        children: [
          SizedBox(height: 75, child: _buildKpiRow(columns: 4)),
          const SizedBox(height: 10),
          Expanded(
            flex: 6,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 3, child: _buildScansByDayChart()),
                const SizedBox(width: 10),
                Expanded(flex: 2, child: _buildTopPlacesChart()),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            flex: 4,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 1, child: _buildScansByHourChart()),
                const SizedBox(width: 10),
                Expanded(flex: 1, child: _buildPlacesByTypeChart()),
                const SizedBox(width: 10),
                Expanded(flex: 1, child: _buildRewardsByDayChart()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // TABLET (600–900px) — scroll suave
  // ═══════════════════════════════════════════════════════
  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          _buildKpiGrid(columns: 2, aspectRatio: 2.5),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SizedBox(
                  height: 220,
                  child: _buildScansByDayChart(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 220,
                  child: _buildTopPlacesChart(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SizedBox(
                  height: 200,
                  child: _buildScansByHourChart(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 200,
                  child: _buildPlacesByTypeChart(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: _buildRewardsByDayChart(),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // MÓVIL (< 600px) — scroll vertical
  // ═══════════════════════════════════════════════════════
  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _buildKpiGrid(columns: 2, aspectRatio: 2.0),
          const SizedBox(height: 10),
          SizedBox(height: 200, child: _buildScansByDayChart()),
          const SizedBox(height: 10),
          SizedBox(height: 200, child: _buildTopPlacesChart()),
          const SizedBox(height: 10),
          SizedBox(height: 180, child: _buildScansByHourChart()),
          const SizedBox(height: 10),
          SizedBox(height: 180, child: _buildPlacesByTypeChart()),
          const SizedBox(height: 10),
          SizedBox(height: 180, child: _buildRewardsByDayChart()),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // KPI — Row (desktop) y Grid (tablet/móvil)
  // ═══════════════════════════════════════════════════════
  Widget _buildKpiRow({required int columns}) {
    return Row(
      children: [
        Expanded(child: _buildKpiCard('Total Escaneos', _totalScans,
            Icons.qr_code_scanner_rounded, AppTheme.primary)),
        const SizedBox(width: 8),
        Expanded(child: _buildKpiCard('Turistas', _totalUsers,
            Icons.people_rounded, AppTheme.info)),
        const SizedBox(width: 8),
        Expanded(child: _buildKpiCard('Lugares Activos', _totalPlaces,
            Icons.place_rounded, AppTheme.success)),
        const SizedBox(width: 8),
        Expanded(child: _buildKpiCard('Recompensas', _totalRewards,
            Icons.card_giftcard_rounded, AppTheme.warning)),
      ],
    );
  }

  Widget _buildKpiGrid({required int columns, required double aspectRatio}) {
    final cards = [
      _buildKpiCard('Total Escaneos', _totalScans,
          Icons.qr_code_scanner_rounded, AppTheme.primary),
      _buildKpiCard('Turistas', _totalUsers,
          Icons.people_rounded, AppTheme.info),
      _buildKpiCard('Lugares Activos', _totalPlaces,
          Icons.place_rounded, AppTheme.success),
      _buildKpiCard('Recompensas', _totalRewards,
          Icons.card_giftcard_rounded, AppTheme.warning),
    ];

    return GridView.count(
      crossAxisCount: columns,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: aspectRatio,
      children: cards,
    );
  }

  Widget _buildKpiCard(String label, int value, IconData icon, Color color) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _navigateFromKpi(label),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          // Antipatrón corregido: antes tenía border (franja superior de color)
          // + boxShadow a la vez. Ahora usa AppTheme.cardDecoration() — solo
          // sombra (nova-design 4bis). Se pierde la franja de color superior
          // como método de distinción; el ícono y el número siguen coloreados.
          decoration: AppTheme.cardDecoration(),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('$value',
                        style: TextStyle(fontSize: 18,
                            fontWeight: FontWeight.w700, color: color,
                            height: 1.1)),
                    Text(label,
                        style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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

  // ═══════════════════════════════════════════════════════
  // CHART CONTAINER genérico
  // ═══════════════════════════════════════════════════════
  Widget _buildChartContainer({
    required String title,
    required String subtitle,
    required Color  accentColor,
    required Widget chart,
  }) {
    // Este contenedor sigue siendo la ÚNICA capa de decoración de la gráfica:
    // LineChartWidget y BarChartWidget ya no se auto-decoran (Lote 3), así que
    // el problema de doble-tarjeta queda resuelto para esas 2. DonutChartWidget
    // todavía se auto-decora (fuera del alcance de este lote) — la gráfica
    // "Distribución por Tipo" sigue con doble tarjeta hasta un próximo lote.
    return Container(
      decoration: AppTheme.cardDecoration(),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 4, height: 18,
              decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: AppTheme.space8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontSize: 13,
                          fontWeight: FontWeight.w600),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(subtitle,
                      style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 10),
          Expanded(child: chart),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // 5 GRÁFICAS
  // ═══════════════════════════════════════════════════════

  Widget _buildScansByDayChart() {
    final data = _scansByDay.map((e) => <String, dynamic>{
      'label': _formatDate(e['date']?.toString() ?? ''),
      'value': e['count'] ?? 0,
    }).toList();

    return _buildChartContainer(
      title: 'Actividad de Escaneos',
      subtitle: _selectedDays == 0
          ? 'Todo el historial'
          : 'Últimos $_selectedDays días',
      accentColor: AppTheme.primary,
      chart: data.isEmpty
          ? _buildEmptyState()
          : LayoutBuilder(builder: (ctx, c) {
              final h = c.maxHeight.isInfinite ? 160.0 : c.maxHeight;
              return LineChartWidget(
                title: '', data: data,
                color: AppTheme.primary,
                fillArea: true,
                height: h,
              );
            }),
    );
  }

  Widget _buildTopPlacesChart() {
    final data = _topPlaces.map((p) => <String, dynamic>{
      'label': () {
        final n = (p['name'] ?? '').toString();
        return n.length > 12 ? '${n.substring(0, 12)}…' : n;
      }(),
      'value': p['total_scans'] ?? 0,
    }).toList();

    return _buildChartContainer(
      title: 'Top Establecimientos',
      subtitle: 'Por número de escaneos',
      accentColor: AppTheme.warning,
      chart: data.isEmpty
          ? _buildEmptyState()
          : LayoutBuilder(builder: (ctx, c) {
              final h = c.maxHeight.isInfinite ? 160.0 : c.maxHeight;
              return BarChartWidget(
                title: '', data: data,
                color: AppTheme.warning,
                height: h,
                showValues: true,
              );
            }),
    );
  }

  Widget _buildScansByHourChart() {
    final Map<int, int> hourMap = {};
    for (final e in _scansByHour) {
      final h = (e['hour'] as num?)?.toInt() ?? 0;
      hourMap[h] = (e['count'] as num?)?.toInt() ?? 0;
    }
    final List<Map<String, dynamic>> data = List.generate(24, (h) => {
      'label': '${h.toString().padLeft(2, '0')}h',
      'value': hourMap[h] ?? 0,
    });

    return _buildChartContainer(
      title: 'Horario Pico',
      subtitle: 'Escaneos por hora del día',
      accentColor: AppTheme.info,
      chart: data.every((e) => (e['value'] as int) == 0)
          ? _buildEmptyState()
          : LayoutBuilder(builder: (ctx, c) {
              final h = c.maxHeight.isInfinite ? 160.0 : c.maxHeight;
              return BarChartWidget(
                title: '', data: data,
                color: AppTheme.info,
                height: h,
                showValues: false,
              );
            }),
    );
  }

  Widget _buildPlacesByTypeChart() {
    final hotel = (_placesByType['hotel']      as num?)?.toInt() ?? 0;
    final rest  = (_placesByType['restaurant'] as num?)?.toInt() ?? 0;
    final bar   = (_placesByType['bar']        as num?)?.toInt() ?? 0;
    final total = hotel + rest + bar;

    final List<Map<String, dynamic>> chartData = [
      {'label': 'Hoteles',      'value': hotel, 'color': AppTheme.info},
      {'label': 'Restaurantes', 'value': rest,  'color': AppTheme.success},
      {'label': 'Bares',        'value': bar,   'color': AppTheme.warning},
    ].where((e) => (e['value'] as int) > 0).toList();

    return _buildChartContainer(
      title: 'Distribución por Tipo',
      subtitle: 'Establecimientos registrados',
      accentColor: AppTheme.success,
      chart: total == 0
          ? _buildEmptyState()
          : LayoutBuilder(builder: (ctx, c) {
              final h = c.maxHeight.isInfinite ? 160.0 : c.maxHeight;
              return DonutChartWidget(
                title: '', subtitle: '',
                data: chartData,
                height: h,
                showLegend: true,
              );
            }),
    );
  }

  Widget _buildRewardsByDayChart() {
    final data = _rewardsByDay.map((e) => <String, dynamic>{
      'label': _formatDate(e['date']?.toString() ?? ''),
      'value': e['count'] ?? 0,
    }).toList();

    return _buildChartContainer(
      title: 'Recompensas por Día',
      subtitle: _selectedDays == 0
          ? 'Todo el historial'
          : 'Últimos $_selectedDays días',
      accentColor: AppTheme.primaryDark,
      chart: data.isEmpty
          ? _buildEmptyState()
          : LayoutBuilder(builder: (ctx, c) {
              final h = c.maxHeight.isInfinite ? 160.0 : c.maxHeight;
              return LineChartWidget(
                title: '', data: data,
                color: AppTheme.primaryDark,
                fillArea: true,
                height: h,
              );
            }),
    );
  }

  // ═══════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_rounded, size: 32, color: AppTheme.textMuted),
          SizedBox(height: 6),
          Text('Sin datos disponibles', style: AppTheme.textCaption),
        ],
      ),
    );
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

  String _formatDate(String dateStr) {
    try {
      final d = DateTime.parse(dateStr);
      return '${d.day} ${_monthShort(d.month)}';
    } catch (_) {
      return dateStr;
    }
  }

  String _monthShort(int m) {
    const months = [
      '', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    return m >= 1 && m <= 12 ? months[m] : '';
  }
}

// ──────────────────────────────────────────────────────────────
// PERIOD DROPDOWN
// ──────────────────────────────────────────────────────────────
class _PeriodDropdown extends StatelessWidget {
  final int                value;
  final List<int>          options;
  final ValueChanged<int?> onChanged;

  const _PeriodDropdown({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppTheme.border),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<int>(
        value: value,
        isDense: true,
        icon: const Icon(Icons.expand_more_rounded, size: 15, color: AppTheme.textMuted),
        style: const TextStyle(fontSize: 12, color: AppTheme.textHead),
        items: options.map((d) => DropdownMenuItem(
          value: d,
          child: Text(
            d == 0 ? 'Todo' : 'Últ. $d días',
            style: const TextStyle(fontSize: 12),
          ),
        )).toList(),
        onChanged: onChanged,
      ),
    ),
  );
}

// ──────────────────────────────────────────────────────────────
// ICON BUTTON (header)
// ──────────────────────────────────────────────────────────────
class _DashIconButton extends StatelessWidget {
  final IconData     icon;
  final String       tooltip;
  final VoidCallback onTap;

  const _DashIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.space8),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.border),
        ),
        child: Icon(icon, size: 16, color: AppTheme.textMuted),
      ),
    ),
  );
}
