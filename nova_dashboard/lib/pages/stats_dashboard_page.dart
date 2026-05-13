// lib/pages/stats_dashboard_page.dart
import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import '../services/analytics_service.dart';
import '../widgets/common/loading_indicator.dart';
import '../widgets/charts/line_chart_widget.dart';
import '../widgets/charts/bar_chart_widget.dart';
import '../widgets/charts/donut_chart_widget.dart';

// ── Design tokens ──────────────────────────────────────────────
const _kPrimary   = Color(0xFF06B6A4);
const _kBgPage    = Color(0xFFF1F5F9);
const _kTextHead  = Color(0xFF0F172A);
const _kTextMuted = Color(0xFF64748B);
const _kBorder    = Color(0xFFE2E8F0);

// ──────────────────────────────────────────────────────────────
class StatsDashboardPage extends StatefulWidget {
  final void Function(int index)?   onNavigate;
  final void Function(String tipo)? onNavigateToPlaces;
  final int placesIndex;
  final int rewardsIndex;
  final int reportsIndex;

  const StatsDashboardPage({
    super.key,
    this.onNavigate,
    this.onNavigateToPlaces,
    this.placesIndex  = 1,
    this.rewardsIndex = 3,
    this.reportsIndex = 4,
  });

  @override
  State<StatsDashboardPage> createState() => _StatsDashboardPageState();
}

// ──────────────────────────────────────────────────────────────
class _StatsDashboardPageState extends State<StatsDashboardPage> {
  final AnalyticsService _analytics = AnalyticsService();

  int _totalScans   = 0;
  int _totalUsers   = 0;
  int _totalPlaces  = 0;
  int _totalRewards = 0;

  List<Map<String, dynamic>> _scansByDay   = [];
  List<Map<String, dynamic>> _scansByHour  = [];
  List<Map<String, dynamic>> _topPlaces    = [];
  List<Map<String, dynamic>> _usersByMonth = [];
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
      final usersStats   = results[4] as Map<String, dynamic>;
      final rewardsByDay = results[5] as List<Map<String, dynamic>>;
      final placesStats  = results[6] as Map<String, dynamic>;

      if (!mounted) return;

      final stats          = dashboard['stats']   as Map<String, dynamic>? ?? {};
      final usersData      = usersStats['stats']  as Map<String, dynamic>? ?? {};
      final byMonth        = usersData['byMonth'] as List?                 ?? [];
      final placesData     = placesStats['stats'] as Map<String, dynamic>? ?? {};
      final byType         = placesData['byType'] as Map<String, dynamic>? ?? {};

      setState(() {
        _totalScans   = stats['scans']   as int? ?? 0;
        _totalUsers   = stats['users']   as int? ?? 0;
        _totalPlaces  = stats['places']  as int? ?? 0;
        _totalRewards = stats['rewards'] as int? ?? 0;
        _scansByDay   = scansByDay;
        _scansByHour  = scansByHour;
        _topPlaces    = topPlaces;
        _usersByMonth = List<Map<String, dynamic>>.from(byMonth);
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
      color: _kBgPage,
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
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _kBorder)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text('Estadísticas del Sistema',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                    color: _kTextHead)),
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
        if (constraints.maxWidth >= 900) {
          return _buildDesktopLayout();
        }
        return _buildMobileLayout();
      },
    );
  }

  // ═══════════════════════════════════════════════════════
  // DESKTOP — sin scroll, Column con Expanded
  // ═══════════════════════════════════════════════════════
  Widget _buildDesktopLayout() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Fila 1: KPIs — altura fija
          SizedBox(height: 90, child: _buildKpiRow()),
          const SizedBox(height: 12),

          // Fila 2: Escaneos por día + Top lugares
          Expanded(
            flex: 5,
            child: Row(
              children: [
                Expanded(flex: 3, child: _buildScansByDayChart()),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: _buildTopPlacesChart()),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Fila 3: Horario pico + Turistas por mes
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Expanded(child: _buildScansByHourChart()),
                const SizedBox(width: 12),
                Expanded(child: _buildUsersByMonthChart()),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Fila 4: Distribución por tipo + Recompensas por día
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Expanded(child: _buildPlacesByTypeChart()),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: _buildRewardsByDayChart()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // MOBILE — con scroll
  // ═══════════════════════════════════════════════════════
  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.2,
            children: [
              _buildKpiCard('Escaneos', _totalScans,
                  Icons.qr_code_scanner_rounded, const Color(0xFF06B6A4)),
              _buildKpiCard('Turistas', _totalUsers,
                  Icons.people_rounded, const Color(0xFF3B82F6)),
              _buildKpiCard('Lugares', _totalPlaces,
                  Icons.place_rounded, const Color(0xFF10B981)),
              _buildKpiCard('Recompensas', _totalRewards,
                  Icons.card_giftcard_rounded, const Color(0xFFF59E0B)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(height: 220, child: _buildScansByDayChart()),
          const SizedBox(height: 12),
          SizedBox(height: 220, child: _buildTopPlacesChart()),
          const SizedBox(height: 12),
          SizedBox(height: 220, child: _buildScansByHourChart()),
          const SizedBox(height: 12),
          SizedBox(height: 220, child: _buildUsersByMonthChart()),
          const SizedBox(height: 12),
          SizedBox(height: 220, child: _buildPlacesByTypeChart()),
          const SizedBox(height: 12),
          SizedBox(height: 220, child: _buildRewardsByDayChart()),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // KPI CARDS
  // ═══════════════════════════════════════════════════════
  Widget _buildKpiRow() {
    return Row(
      children: [
        Expanded(child: _buildKpiCard('Total Escaneos', _totalScans,
            Icons.qr_code_scanner_rounded, const Color(0xFF06B6A4))),
        const SizedBox(width: 10),
        Expanded(child: _buildKpiCard('Turistas', _totalUsers,
            Icons.people_rounded, const Color(0xFF3B82F6))),
        const SizedBox(width: 10),
        Expanded(child: _buildKpiCard('Lugares Activos', _totalPlaces,
            Icons.place_rounded, const Color(0xFF10B981))),
        const SizedBox(width: 10),
        Expanded(child: _buildKpiCard('Recompensas', _totalRewards,
            Icons.card_giftcard_rounded, const Color(0xFFF59E0B))),
      ],
    );
  }

  Widget _buildKpiCard(String label, int value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border(top: BorderSide(color: color, width: 3)),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$value',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
                        color: color, height: 1.1)),
                Text(label,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8, offset: const Offset(0, 2))],
      ),
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
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontSize: 13,
                          fontWeight: FontWeight.w600),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(subtitle,
                      style: TextStyle(fontSize: 10, color: Colors.grey[500]),
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
  // 6 GRÁFICAS
  // ═══════════════════════════════════════════════════════

  // 1. Escaneos por día
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
      accentColor: const Color(0xFF06B6A4),
      chart: data.isEmpty
          ? _buildEmptyState()
          : LayoutBuilder(builder: (ctx, c) {
              final h = c.maxHeight.isInfinite ? 160.0 : c.maxHeight;
              return LineChartWidget(
                title: '', data: data,
                color: const Color(0xFF06B6A4),
                fillArea: true,
                height: h,
              );
            }),
    );
  }

  // 2. Top establecimientos
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
      accentColor: const Color(0xFFD97706),
      chart: data.isEmpty
          ? _buildEmptyState()
          : LayoutBuilder(builder: (ctx, c) {
              final h = c.maxHeight.isInfinite ? 160.0 : c.maxHeight;
              return BarChartWidget(
                title: '', data: data,
                color: const Color(0xFFD97706),
                height: h,
                showValues: true,
              );
            }),
    );
  }

  // 3. Horario pico
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
      accentColor: const Color(0xFF8B5CF6),
      chart: data.every((e) => (e['value'] as int) == 0)
          ? _buildEmptyState()
          : LayoutBuilder(builder: (ctx, c) {
              final h = c.maxHeight.isInfinite ? 160.0 : c.maxHeight;
              return BarChartWidget(
                title: '', data: data,
                color: const Color(0xFF8B5CF6),
                height: h,
                showValues: false,
              );
            }),
    );
  }

  // 4. Turistas nuevos por mes
  Widget _buildUsersByMonthChart() {
    final data = _usersByMonth.map((e) => <String, dynamic>{
      'label': _formatMonth(e['month']?.toString() ?? ''),
      'value': e['count'] ?? 0,
    }).toList();

    return _buildChartContainer(
      title: 'Turistas Nuevos',
      subtitle: 'Registros por mes',
      accentColor: const Color(0xFF3B82F6),
      chart: data.isEmpty
          ? _buildEmptyState()
          : LayoutBuilder(builder: (ctx, c) {
              final h = c.maxHeight.isInfinite ? 160.0 : c.maxHeight;
              return LineChartWidget(
                title: '', data: data,
                color: const Color(0xFF3B82F6),
                fillArea: true,
                height: h,
              );
            }),
    );
  }

  // 5. Distribución por tipo de lugar
  Widget _buildPlacesByTypeChart() {
    final hotel = (_placesByType['hotel']      as num?)?.toInt() ?? 0;
    final rest  = (_placesByType['restaurant'] as num?)?.toInt() ?? 0;
    final bar   = (_placesByType['bar']        as num?)?.toInt() ?? 0;
    final total = hotel + rest + bar;

    final List<Map<String, dynamic>> chartData = [
      {'label': 'Hoteles',      'value': hotel, 'color': const Color(0xFF3B82F6)},
      {'label': 'Restaurantes', 'value': rest,  'color': const Color(0xFF10B981)},
      {'label': 'Bares',        'value': bar,   'color': const Color(0xFFF59E0B)},
    ].where((e) => (e['value'] as int) > 0).toList();

    return _buildChartContainer(
      title: 'Distribución por Tipo',
      subtitle: 'Establecimientos registrados',
      accentColor: const Color(0xFF10B981),
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

  // 6. Recompensas por día
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
      accentColor: const Color(0xFFEC4899),
      chart: data.isEmpty
          ? _buildEmptyState()
          : LayoutBuilder(builder: (ctx, c) {
              final h = c.maxHeight.isInfinite ? 160.0 : c.maxHeight;
              return LineChartWidget(
                title: '', data: data,
                color: const Color(0xFFEC4899),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_rounded, size: 32, color: Colors.grey[300]),
          const SizedBox(height: 6),
          Text('Sin datos disponibles',
              style: TextStyle(fontSize: 12, color: Colors.grey[400])),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
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
                backgroundColor: _kPrimary,
                foregroundColor: Colors.white),
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

  String _formatMonth(String monthStr) {
    try {
      final parts = monthStr.split('-');
      if (parts.length >= 2) {
        return '${_monthShort(int.parse(parts[1]))} ${parts[0].substring(2)}';
      }
    } catch (_) {}
    return monthStr;
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
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: _kBorder),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<int>(
        value: value,
        isDense: true,
        icon: const Icon(Icons.expand_more_rounded, size: 15, color: _kTextMuted),
        style: const TextStyle(fontSize: 12, color: _kTextHead),
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
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _kBorder),
        ),
        child: Icon(icon, size: 16, color: _kTextMuted),
      ),
    ),
  );
}
