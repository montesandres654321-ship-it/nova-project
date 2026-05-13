// lib/pages/reports_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/admin_service.dart';
import '../services/analytics_service.dart';
import '../utils/app_theme.dart';
import '../widgets/charts/line_chart_widget.dart';
import '../widgets/charts/bar_chart_widget.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});
  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final _analytics = AnalyticsService();

  bool   _loading    = true;
  bool   _refreshing = false;
  String _error      = '';
  int    _selectedDays = 0;

  int    _totalScans = 0, _totalUsers = 0, _totalPlaces = 0, _totalRewards = 0;
  List<Map<String, dynamic>> _scansByDay = [], _topPlaces = [];

  final List<int> _daysOptions = [7, 15, 30, 60, 90, 0];

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = ''; });
    try {
      final dp = _selectedDays == 0 ? 3650 : _selectedDays;
      final results = await Future.wait([
        AdminService.getDashboardStats(),
        _analytics.getScansByDay(days: dp),
        _analytics.getTopPlacesByScans(limit: 20),
      ]);
      if (!mounted) return;
      final dash  = results[0] as Map<String, dynamic>;
      final scans = results[1] as List<Map<String, dynamic>>;
      final top   = results[2] as List<Map<String, dynamic>>;
      if (dash['success'] == true) {
        final stats = dash['stats'] as Map<String, dynamic>? ?? {};
        setState(() {
          _totalScans   = stats['scans']   as int? ?? 0;
          _totalUsers   = stats['users']   as int? ?? 0;
          _totalPlaces  = stats['places']  as int? ?? 0;
          _totalRewards = stats['rewards'] as int? ?? 0;
          _scansByDay   = scans;
          _topPlaces    = top;
          _loading      = false;
        });
      } else {
        setState(() { _error = dash['error']?.toString() ?? 'Error'; _loading = false; });
      }
    } catch (e) {
      if (mounted) setState(() { _error = '$e'; _loading = false; });
    }
  }

  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    try { await _loadData(); } finally { if (mounted) setState(() => _refreshing = false); }
  }

  String get _periodLabel =>
      _selectedDays == 0 ? 'Todo el historial' : 'Últimos $_selectedDays días';

  // ─── PAGE HEADER ──────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
      child: Row(children: [
        Container(
          width: 3, height: 18,
          decoration: BoxDecoration(
            color: AppTheme.primary, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 10),
        const Text('Reportes',
            style: TextStyle(
                fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
        const Spacer(),
        // Period selector
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: DropdownButton<int>(
            value: _selectedDays,
            underline: const SizedBox(),
            isDense: true,
            style: const TextStyle(fontSize: 12, color: Color(0xFF374151)),
            icon: const Icon(Icons.expand_more, size: 16, color: Color(0xFF9CA3AF)),
            items: _daysOptions.map((d) => DropdownMenuItem<int>(
              value: d,
              child: Text(d == 0 ? 'Todo' : '$d días',
                  style: const TextStyle(fontSize: 12)),
            )).toList(),
            onChanged: (v) {
              if (v != null) { setState(() => _selectedDays = v); _loadData(); }
            },
          ),
        ),
        const SizedBox(width: 8),
        _refreshing
            ? const Padding(
                padding: EdgeInsets.all(10),
                child: SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary)))
            : IconButton(
                icon: const Icon(Icons.refresh_rounded, size: 18, color: Color(0xFF6B7280)),
                tooltip: 'Actualizar',
                onPressed: _refresh,
                padding: const EdgeInsets.all(6),
                constraints: const BoxConstraints(),
              ),
      ]),
    );
  }

  // ─── BUILD ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppTheme.backgroundGray,
      child: Column(children: [
        _buildHeader(),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
              : _error.isNotEmpty
                  ? _buildError()
                  : _buildContent(),
        ),
      ]),
    );
  }

  // ─── CONTENT ─────────────────────────────────────────────────

  Widget _buildContent() {
    return LayoutBuilder(builder: (ctx, box) {
      final isWide = box.maxWidth > 800;
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildKpiRow(isWide),
            const SizedBox(height: 14),
            Expanded(
              child: isWide
                  ? Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      Expanded(flex: 55, child: _buildScansCard()),
                      const SizedBox(width: 14),
                      Expanded(flex: 45, child: _buildRankingCard()),
                    ])
                  : Column(children: [
                      Expanded(child: _buildScansCard()),
                      const SizedBox(height: 14),
                      if (_topPlaces.isNotEmpty) Expanded(child: _buildRankingCard()),
                    ]),
            ),
          ],
        ),
      );
    });
  }

  // ─── KPI CARDS (compactas) ────────────────────────────────────

  static const _kpiColors = [
    Color(0xFF3B82F6),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFF7C3AED),
  ];
  static const _kpiIcons = [
    Icons.qr_code_scanner_rounded,
    Icons.people_rounded,
    Icons.place_rounded,
    Icons.card_giftcard_rounded,
  ];
  static const _kpiLabels = ['Total Escaneos', 'Turistas', 'Lugares Activos', 'Recompensas'];

  Widget _buildKpiRow(bool isWide) {
    final values = [
      _totalScans.toString(),
      _totalUsers.toString(),
      _totalPlaces.toString(),
      _totalRewards.toString(),
    ];

    if (isWide) {
      return Row(children: List.generate(4, (i) => Expanded(
        child: Padding(
          padding: EdgeInsets.only(left: i > 0 ? 12 : 0),
          child: _kpiCard(i, values[i]),
        ),
      )));
    }
    return GridView.count(
      crossAxisCount: 2, shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10, crossAxisSpacing: 10,
      childAspectRatio: 2.2,
      children: List.generate(4, (i) => _kpiCard(i, values[i])),
    );
  }

  Widget _kpiCard(int index, String value) {
    final color = _kpiColors[index];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: color, width: 3)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(_kpiIcons[index], color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A), height: 1.1)),
            Text(_kpiLabels[index],
                style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
                overflow: TextOverflow.ellipsis),
          ],
        )),
      ]),
    );
  }

  // ─── SCANS CHART CARD ─────────────────────────────────────────

  Widget _buildScansCard() {
    final chartData = _scansByDay.map((item) {
      final ds = item['date']?.toString() ?? '';
      String l = ds;
      try { l = DateFormat('d MMM', 'es').format(DateTime.parse(ds)); } catch (_) {}
      return {'label': l, 'value': item['count'] ?? 0};
    }).toList();

    return _chartCard(
      title: 'Actividad de Escaneos',
      trailing: _periodChip(_periodLabel),
      child: chartData.isEmpty
          ? _emptyChart(Icons.show_chart_rounded, 'Sin datos en este período')
          : LineChartWidget(
              title: '',
              data: chartData,
              color: AppTheme.primary,
              fillArea: true,
              height: double.infinity,
            ),
    );
  }

  // ─── RANKING CHART CARD ───────────────────────────────────────

  Widget _buildRankingCard() {
    if (_topPlaces.isEmpty) {
      return _chartCard(
        title: 'Top Establecimientos',
        trailing: _periodChip('por escaneos'),
        child: _emptyChart(Icons.bar_chart_rounded, 'Sin datos de lugares'),
      );
    }

    final cd = _topPlaces.map((p) => {
      'label': p['name']?.toString() ?? '',
      'value': p['totalScans'] ?? p['total_scans'] ?? 0,
    }).toList();

    return _chartCard(
      title: 'Top Establecimientos',
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        _periodChip('por escaneos'),
        const SizedBox(width: 6),
        if (cd.length > 7)
          _periodChip('← scroll →', subtle: true),
      ]),
      child: BarChartWidget(
        title: '',
        data: cd,
        color: AppTheme.primary,
        showValues: true,
      ),
    );
  }

  // ─── HELPERS ─────────────────────────────────────────────────

  Widget _chartCard({
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
            child: Row(children: [
              Container(
                  width: 3, height: 16,
                  decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A))),
              const Spacer(),
              if (trailing != null) trailing,
            ]),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          // Chart area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _periodChip(String text, {bool subtle = false}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: subtle
          ? const Color(0xFFF8FAFC)
          : AppTheme.primary.withOpacity(0.06),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: subtle
            ? const Color(0xFFE2E8F0)
            : AppTheme.primary.withOpacity(0.15),
      ),
    ),
    child: Text(text,
        style: TextStyle(
            fontSize: 9,
            color: subtle ? const Color(0xFF94A3B8) : const Color(0xFF475569),
            fontWeight: FontWeight.w500)),
  );

  Widget _emptyChart(IconData icon, String text) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, size: 36, color: Colors.grey[300]),
      const SizedBox(height: 10),
      Text(text, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
    ]),
  );

  Widget _buildError() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.error_outline_rounded, size: 52, color: Color(0xFFEF4444)),
      const SizedBox(height: 14),
      Text(_error, textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
      const SizedBox(height: 20),
      ElevatedButton.icon(
        onPressed: _loadData,
        icon: const Icon(Icons.refresh_rounded, size: 16),
        label: const Text('Reintentar'),
        style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
      ),
    ]),
  );
}
