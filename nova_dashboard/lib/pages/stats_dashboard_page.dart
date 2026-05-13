// lib/pages/stats_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/admin_service.dart';
import '../widgets/common/loading_indicator.dart';
import '../widgets/common/error_widget.dart';
import '../widgets/charts/line_chart_widget.dart';
import '../widgets/charts/bar_chart_widget.dart';
import '../widgets/charts/donut_chart_widget.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
const _kPrimary   = Color(0xFF06B6A4);
const _kBgPage    = Color(0xFFF1F5F9);
const _kTextHead  = Color(0xFF0F172A);
const _kTextMuted = Color(0xFF64748B);
const _kTextSub   = Color(0xFF94A3B8);
const _kBorder    = Color(0xFFE2E8F0);
const _kBlue      = Color(0xFF3B82F6);
const _kGreen     = Color(0xFF10B981);
const _kAmber     = Color(0xFFF59E0B);
const _kPurple    = Color(0xFF8B5CF6);

// ─────────────────────────────────────────────────────────────────────────────
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

// ─────────────────────────────────────────────────────────────────────────────
class _StatsDashboardPageState extends State<StatsDashboardPage> {

  // ── State — SIN CAMBIOS ───────────────────────────────────
  bool   _loading = true;
  String _error   = '';
  int    _selectedDays = 0;

  int _totalUsers = 0, _totalPlaces = 0, _totalScans = 0, _totalRewards = 0;

  List<Map<String, dynamic>> _scansByDay     = [];
  List<Map<String, dynamic>> _topPlaces      = [];
  Map<String, dynamic>       _placesByType   = {};
  List<Map<String, dynamic>> _recentActivity = [];

  final List<int> _daysOptions = [7, 15, 30, 60, 90, 0];

  @override
  void initState() { super.initState(); _load(); }

  // ── LÓGICA — SIN CAMBIOS ─────────────────────────────────
  Future<void> _load() async {
    setState(() { _loading = true; _error = ''; });
    try {
      final results = await Future.wait([
        AdminService.getDashboardStats(),
        AdminService.getDashboardSummary(),
      ]);
      if (!mounted) return;

      final stats   = results[0];
      final summary = results[1];

      debugPrint('📊 getDashboardStats keys: ${stats.keys}');
      debugPrint('📊 scansByDay present: ${stats.containsKey('scansByDay')}');

      if (stats['success'] == true) {
        final s = stats['stats'] as Map<String, dynamic>? ?? {};
        _totalUsers   = _n(s['users']);
        _totalPlaces  = _n(s['places']);
        _totalScans   = _n(s['scans']);
        _totalRewards = _n(s['rewards']);
        _placesByType = stats['placesByType'] as Map<String, dynamic>? ?? {};
        _topPlaces    = List<Map<String, dynamic>>.from(stats['topPlaces'] ?? []);

        if (stats['scansByDay'] is List) {
          _scansByDay = List<Map<String, dynamic>>.from(stats['scansByDay'] as List);
        }
      }

      if (summary['success'] == true) {
        _recentActivity = List<Map<String, dynamic>>.from(summary['recentActivity'] ?? []);
        if (stats['success'] != true) {
          _totalUsers  = _n(summary['totalUsers']);
          _totalPlaces = _n(summary['activePlaces']);
          _totalScans  = _n(summary['totalScans']);
        }
        if (_scansByDay.isEmpty && summary['scansByDay'] is List) {
          _scansByDay = List<Map<String, dynamic>>.from(summary['scansByDay'] as List);
        }
      }

      debugPrint('📊 scansByDay count: ${_scansByDay.length}');
      setState(() { _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  static int _n(dynamic v) => v is num ? v.toInt() : 0;

  String get _periodLabel =>
      _selectedDays == 0 ? 'Todo el historial' : 'Últimos $_selectedDays días';

  // ─────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingIndicator(message: 'Cargando estadísticas...');
    if (_error.isNotEmpty) {
      return ErrorDisplay(message: _error, onRetry: _load, retryLabel: 'Reintentar');
    }

    return ColoredBox(
      color: _kBgPage,
      child: LayoutBuilder(builder: (_, constraints) {
        final isDesktop = constraints.maxWidth > 900;
        final isTablet  = constraints.maxWidth > 580;
        final hPad      = isDesktop ? 32.0 : (isTablet ? 24.0 : 16.0);

        // ── DESKTOP: layout fijo sin scroll ─────────────────
        if (isDesktop) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // 1. Header
              _buildHeader(),
              const SizedBox(height: 16),

              // 2. KPI cards
              _buildKpiGrid(isDesktop: true),
              const SizedBox(height: 14),

              // 3. Gráficas — ocupan el espacio restante
              Expanded(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                // Gráfico principal (70%)
                Expanded(flex: 7, child: _buildMainChart()),
                const SizedBox(width: 14),
                // Panel lateral (30%)
                Expanded(flex: 3, child: Column(children: [
                  Expanded(child: _buildTopPlacesCard()),
                  const SizedBox(height: 14),
                  Expanded(child: _buildDistributionCard()),
                ])),
              ])),

              // 4. Actividad reciente
              if (_recentActivity.isNotEmpty) ...[
                const SizedBox(height: 14),
                _buildActivityFeed(),
              ],
            ]),
          );
        }

        // ── TABLET / MOBILE: scroll vertical ─────────────────
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildKpiGrid(isDesktop: false, isTablet: isTablet),
            const SizedBox(height: 16),

            // Gráfico de línea con altura adecuada para el contenido
            SizedBox(height: 300, child: _buildMainChart()),
            const SizedBox(height: 14),

            // Top lugares
            SizedBox(height: isTablet ? 280 : 260, child: _buildTopPlacesCard()),
            const SizedBox(height: 14),

            // Distribución — altura generosa para donut + leyenda
            SizedBox(height: isTablet ? 320 : 300, child: _buildDistributionCard()),

            if (_recentActivity.isNotEmpty) ...[
              const SizedBox(height: 14),
              _buildActivityFeed(),
            ],
            const SizedBox(height: 20),
          ]),
        );
      }),
    );
  }

  // ─────────────────────────────────────────────────────────
  // 1. HEADER
  // ─────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      const Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Hola, Admin 👋',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
                  color: _kTextHead, height: 1.2)),
          SizedBox(height: 4),
          Text('Resumen general del sistema',
              style: TextStyle(fontSize: 13, color: _kTextMuted)),
        ]),
      ),
      _PeriodDropdown(
        value: _selectedDays,
        options: _daysOptions,
        onChanged: (v) { if (v != null) setState(() => _selectedDays = v); },
      ),
      const SizedBox(width: 8),
      _DashIconButton(icon: Icons.refresh_rounded, tooltip: 'Actualizar', onTap: _load),
    ]);
  }

  // ─────────────────────────────────────────────────────────
  // 2. KPI GRID
  // ─────────────────────────────────────────────────────────
  Widget _buildKpiGrid({required bool isDesktop, bool isTablet = false}) {
    final cards = [
      _KpiItem(label: 'Turistas',         value: _totalUsers,   icon: Icons.people_rounded,
          color: _kBlue,   onTap: () => widget.onNavigate?.call(widget.placesIndex + 2)),
      _KpiItem(label: 'Lugares activos',  value: _totalPlaces,  icon: Icons.store_rounded,
          color: _kGreen,  onTap: () => widget.onNavigate?.call(widget.placesIndex)),
      _KpiItem(label: 'Escaneos totales', value: _totalScans,   icon: Icons.qr_code_scanner_rounded,
          color: _kAmber,  onTap: () => widget.onNavigate?.call(widget.reportsIndex)),
      _KpiItem(label: 'Recompensas',      value: _totalRewards, icon: Icons.card_giftcard_rounded,
          color: _kPurple, onTap: () => widget.onNavigate?.call(widget.rewardsIndex)),
    ];

    if (isDesktop || isTablet) {
      return Row(children: [
        Expanded(child: _KpiCard(item: cards[0])), const SizedBox(width: 12),
        Expanded(child: _KpiCard(item: cards[1])), const SizedBox(width: 12),
        Expanded(child: _KpiCard(item: cards[2])), const SizedBox(width: 12),
        Expanded(child: _KpiCard(item: cards[3])),
      ]);
    }

    // Mobile: 2 columnas compactas con aspect ratio generoso
    return GridView.count(
      crossAxisCount:   2,
      shrinkWrap:       true,
      physics:          const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing:  10,
      childAspectRatio: 2.2,
      children: cards.map((c) => _KpiCard(item: c, compact: true)).toList(),
    );
  }

  // ─────────────────────────────────────────────────────────
  // 3. MAIN CHART — línea de escaneos
  // ─────────────────────────────────────────────────────────
  Widget _buildMainChart() {
    List<Map<String, dynamic>> filtered = _scansByDay;
    if (_selectedDays > 0 && _scansByDay.isNotEmpty) {
      final cutoff = DateTime.now().subtract(Duration(days: _selectedDays));
      filtered = _scansByDay.where((item) {
        try { return DateTime.parse(item['date'].toString()).isAfter(cutoff); }
        catch (_) { return true; }
      }).toList();
    }
    final chartData = filtered.map((item) {
      final ds = item['date']?.toString() ?? '';
      String label = ds;
      try { label = DateFormat('d MMM', 'es').format(DateTime.parse(ds)); } catch (_) {}
      return {'label': label, 'value': item['count'] ?? 0};
    }).toList();

    final periodTotal = chartData.fold<int>(
        0, (s, e) => s + ((e['value'] as num?)?.toInt() ?? 0));

    return _SectionCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Escaneos en el período',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _kTextHead)),
            const SizedBox(height: 2),
            Text(_periodLabel, style: const TextStyle(fontSize: 12, color: _kTextMuted)),
          ])),
          if (chartData.isNotEmpty)
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(_fmtNum(periodTotal),
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w800,
                      color: _kPrimary, height: 1.0)),
              const Text('en el período',
                  style: TextStyle(fontSize: 10, color: _kTextSub)),
            ]),
        ]),

        const SizedBox(height: 4),
        const Divider(color: _kBorder, thickness: 0.5, height: 16),

        // El gráfico rellena el espacio restante
        Expanded(
          child: chartData.isEmpty
              ? _emptyState(Icons.show_chart_rounded, 'Sin datos de escaneos')
              : LayoutBuilder(builder: (_, box) => LineChartWidget(
                  title: '', data: chartData,
                  color: _kPrimary, fillArea: true,
                  height: box.maxHeight.isFinite ? box.maxHeight : 240)),
        ),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────
  // 4a. TOP LUGARES
  // ─────────────────────────────────────────────────────────
  Widget _buildTopPlacesCard() {
    final data = _topPlaces.take(6).map((p) => {
      'label': p['name']?.toString() ?? '',
      'value': p['totalScans'] ?? p['total_scans'] ?? 0,
    }).toList();

    return _SectionCard(
      compact: true,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Top establecimientos',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _kTextHead)),
            SizedBox(height: 2),
            Text('Por número de escaneos',
                style: TextStyle(fontSize: 11, color: _kTextMuted)),
          ])),
          GestureDetector(
            onTap: () => widget.onNavigate?.call(widget.reportsIndex),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Text('Ver reportes',
                  style: TextStyle(fontSize: 11, color: _kPrimary, fontWeight: FontWeight.w500)),
              SizedBox(width: 2),
              Icon(Icons.chevron_right_rounded, size: 14, color: _kPrimary),
            ]),
          ),
        ]),
        const SizedBox(height: 4),
        const Divider(color: _kBorder, thickness: 0.5, height: 14),
        Expanded(
          child: data.isEmpty
              ? _emptyState(Icons.bar_chart_rounded, 'Sin escaneos registrados')
              : LayoutBuilder(builder: (_, box) => BarChartWidget(
                  title: '', data: data, color: _kPrimary,
                  height: box.maxHeight.isFinite ? box.maxHeight : 200,
                  showValues: true)),
        ),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────
  // 4b. DISTRIBUCIÓN POR TIPO
  // ─────────────────────────────────────────────────────────
  Widget _buildDistributionCard() {
    final hotels      = _n(_placesByType['hotel']);
    final restaurants = _n(_placesByType['restaurant']);
    final bars        = _n(_placesByType['bar']);
    final total       = hotels + restaurants + bars;

    return _SectionCard(
      compact: true,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Distribución por tipo',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _kTextHead)),
        const SizedBox(height: 2),
        const Text('Establecimientos registrados',
            style: TextStyle(fontSize: 11, color: _kTextMuted)),
        const SizedBox(height: 4),
        const Divider(color: _kBorder, thickness: 0.5, height: 14),

        total == 0
            ? Expanded(child: _emptyState(Icons.pie_chart_rounded, 'Sin lugares registrados'))
            : Expanded(
                child: LayoutBuilder(builder: (_, box) {
                  final avail  = box.maxHeight.isFinite ? box.maxHeight : 220.0;
                  // Leyenda: 3 filas × ~20px + 2 gaps × 6px = 72px
                  const legendH = 72.0;
                  const minDonut = 44.0;
                  final donutH = (avail - legendH - 10).clamp(0.0, 220.0);
                  final showDonut = donutH >= minDonut;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (showDonut) ...[
                        SizedBox(
                          height: donutH,
                          child: DonutChartWidget(
                            title: '', subtitle: '',
                            data: [
                              {'label': 'Hoteles',      'value': hotels,      'color': _kBlue},
                              {'label': 'Restaurantes', 'value': restaurants, 'color': _kGreen},
                              {'label': 'Bares',        'value': bars,        'color': _kAmber},
                            ],
                            height: donutH,
                            showLegend: false,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      _legendRow('🏨', 'Hoteles',      hotels,      _kBlue,  'hotel',      total),
                      const SizedBox(height: 6),
                      _legendRow('🍽️', 'Restaurantes', restaurants, _kGreen, 'restaurant', total),
                      const SizedBox(height: 6),
                      _legendRow('🍹', 'Bares',        bars,        _kAmber, 'bar',        total),
                    ],
                  );
                }),
              ),
      ]),
    );
  }

  Widget _legendRow(
      String emoji, String label, int count, Color color, String tipo, int total) {
    final pct = total > 0 ? count / total : 0.0;
    return GestureDetector(
      onTap: () => widget.onNavigateToPlaces?.call(tipo),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label,
              style: const TextStyle(fontSize: 12, color: _kTextHead,
                  fontWeight: FontWeight.w500)),
        ),
        SizedBox(
          width: 72,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 5,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 34,
          child: Text('${(pct * 100).round()}%',
              style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w700),
              textAlign: TextAlign.right),
        ),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────
  // 5. ACTIVITY FEED
  // ─────────────────────────────────────────────────────────
  Widget _buildActivityFeed() {
    final items = _recentActivity.take(3).toList();
    return _SectionCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Actividad reciente',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _kTextHead)),
            SizedBox(height: 2),
            Text('Últimas interacciones en el sistema',
                style: TextStyle(fontSize: 11, color: _kTextMuted)),
          ])),
          _Pill(text: '${items.length} registros', color: _kTextSub),
        ]),
        const SizedBox(height: 4),
        const Divider(color: _kBorder, thickness: 0.5, height: 14),
        ...items.asMap().entries.map((entry) {
          final i    = entry.key;
          final item = entry.value;
          return Column(children: [
            _ActivityFeedItem(item: item),
            if (i < items.length - 1)
              const Divider(height: 1, thickness: 0.5, color: Color(0xFFF8FAFC)),
          ]);
        }),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────
  static String _fmtNum(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000)    return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toString();
  }

  Widget _emptyState(IconData icon, String msg) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, size: 32, color: const Color(0xFFCBD5E1)),
      const SizedBox(height: 8),
      Text(msg, style: const TextStyle(fontSize: 12, color: _kTextSub)),
    ]),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTIVITY FEED ITEM
// ─────────────────────────────────────────────────────────────────────────────
class _ActivityFeedItem extends StatelessWidget {
  final Map<String, dynamic> item;
  const _ActivityFeedItem({required this.item});

  static String _relTime(String ts) {
    try {
      final diff = DateTime.now().difference(DateTime.parse(ts));
      if (diff.inSeconds < 60)  return 'ahora';
      if (diff.inMinutes < 60)  return 'hace ${diff.inMinutes} min';
      if (diff.inHours   < 24)  return 'hace ${diff.inHours}h';
      if (diff.inDays    == 1)  return 'ayer';
      if (diff.inDays    < 7)   return 'hace ${diff.inDays}d';
      return DateFormat('d MMM', 'es').format(DateTime.parse(ts));
    } catch (_) { return ''; }
  }

  @override
  Widget build(BuildContext context) {
    final name  = item['userName']?.toString()  ?? 'Turista';
    final place = item['placeName']?.toString() ?? 'un lugar';
    final type  = item['type']?.toString() ?? item['placeType']?.toString() ?? '';
    final ts    = item['timestamp']?.toString() ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final firstName = name.split(' ').first;

    Color typeColor; String typeLabel; String typeEmoji;
    switch (type.toLowerCase()) {
      case 'hotel':
        typeColor = _kBlue;    typeLabel = 'Hotel';       typeEmoji = '🏨'; break;
      case 'restaurant':
        typeColor = _kGreen;   typeLabel = 'Restaurante'; typeEmoji = '🍽️'; break;
      case 'bar':
        typeColor = _kAmber;   typeLabel = 'Bar';         typeEmoji = '🍹'; break;
      default:
        typeColor = _kTextSub; typeLabel = type.isEmpty ? '' : type; typeEmoji = '📍';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [

        CircleAvatar(
          radius: 17,
          backgroundColor: _kPrimary.withOpacity(0.08),
          child: Text(initial,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold, color: _kPrimary)),
        ),
        const SizedBox(width: 12),

        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, color: _kTextHead, height: 1.4),
                children: [
                  TextSpan(text: firstName,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const TextSpan(text: ' escaneó '),
                  TextSpan(text: place,
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Text(_relTime(ts),
                style: const TextStyle(fontSize: 10, color: _kTextSub)),
          ],
        )),
        const SizedBox(width: 10),

        if (typeLabel.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: typeColor.withOpacity(0.25)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(typeEmoji, style: const TextStyle(fontSize: 10)),
              const SizedBox(width: 3),
              Text(typeLabel,
                  style: TextStyle(
                      fontSize: 10, color: typeColor, fontWeight: FontWeight.w600)),
            ]),
          ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KPI ITEM (data)
// ─────────────────────────────────────────────────────────────────────────────
class _KpiItem {
  final String        label;
  final int           value;
  final IconData      icon;
  final Color         color;
  final VoidCallback? onTap;
  const _KpiItem({
    required this.label, required this.value,
    required this.icon,  required this.color, this.onTap,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// KPI CARD
// ─────────────────────────────────────────────────────────────────────────────
class _KpiCard extends StatelessWidget {
  final _KpiItem item;
  final bool compact;
  const _KpiCard({required this.item, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? 14.0 : 17.0;
    final boxSize  = compact ? 26.0 : 34.0;
    final padding  = compact
        ? const EdgeInsets.symmetric(horizontal: 10, vertical: 8)
        : const EdgeInsets.symmetric(horizontal: 14, vertical: 12);
    final gap = compact ? 8.0 : 10.0;

    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: _kBorder),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8, offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // Accent strip
            Container(height: 3, color: item.color),

            // Card content
            Padding(
              padding: padding,
              child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Container(
                  width: boxSize, height: boxSize,
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(item.icon, color: item.color, size: iconSize),
                ),
                SizedBox(width: gap),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _fmt(item.value),
                      style: TextStyle(
                        fontSize: compact ? 18.0 : 21.0,
                        fontWeight: FontWeight.w800,
                        color: _kTextHead, height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: compact ? 10.0 : 11.0,
                            color: _kTextMuted)),
                  ],
                )),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  static String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000)    return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toString();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION CARD
// ─────────────────────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final Widget child;
  final bool compact;
  const _SectionCard({required this.child, this.compact = false});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(compact ? 16.0 : 20.0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _kBorder),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10, offset: const Offset(0, 2),
        ),
      ],
    ),
    child: child,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// PILL
// ─────────────────────────────────────────────────────────────────────────────
class _Pill extends StatelessWidget {
  final String text;
  final Color  color;
  const _Pill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(text,
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500)),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// PERIOD DROPDOWN
// ─────────────────────────────────────────────────────────────────────────────
class _PeriodDropdown extends StatelessWidget {
  final int                value;
  final List<int>          options;
  final ValueChanged<int?> onChanged;
  const _PeriodDropdown({
    required this.value, required this.options, required this.onChanged,
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
        value: value, isDense: true,
        icon: const Icon(Icons.expand_more_rounded, size: 15, color: _kTextMuted),
        style: const TextStyle(fontSize: 12, color: _kTextHead),
        items: options.map((d) => DropdownMenuItem(
            value: d,
            child: Text(d == 0 ? 'Todo' : 'Últ. $d días',
                style: const TextStyle(fontSize: 12)))).toList(),
        onChanged: onChanged,
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// ICON BUTTON (header action)
// ─────────────────────────────────────────────────────────────────────────────
class _DashIconButton extends StatelessWidget {
  final IconData     icon;
  final String       tooltip;
  final VoidCallback onTap;
  const _DashIconButton({required this.icon, required this.tooltip, required this.onTap});

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
