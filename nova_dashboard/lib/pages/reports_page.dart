// lib/pages/reports_page.dart
// REFACTOR: header, fila de KPIs y tarjetas de gráficas extraídas a
// lib/pages/reports/ para bajar de 423 a <300 líneas.
import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import '../services/analytics_service.dart';
import '../utils/app_theme.dart';
import 'reports/reports_charts.dart';
import 'reports/reports_header.dart';
import 'reports/reports_kpi_row.dart';

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

  // ─── BUILD ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppTheme.backgroundGray,
      child: Column(children: [
        ReportsHeader(
          selectedDays: _selectedDays,
          daysOptions: _daysOptions,
          refreshing: _refreshing,
          onDaysChanged: (v) { setState(() => _selectedDays = v); _loadData(); },
          onRefresh: _refresh,
        ),
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
            reportsKpiRow(
              context: context, isWide: isWide,
              totalScans: _totalScans, totalUsers: _totalUsers,
              totalPlaces: _totalPlaces, totalRewards: _totalRewards,
            ),
            const SizedBox(height: 14),
            Expanded(
              child: isWide
                  ? Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      Expanded(flex: 55, child: reportsScansCard(
                          scansByDay: _scansByDay, periodLabel: _periodLabel)),
                      const SizedBox(width: 14),
                      Expanded(flex: 45, child: reportsRankingCard(_topPlaces)),
                    ])
                  : Column(children: [
                      Expanded(child: reportsScansCard(
                          scansByDay: _scansByDay, periodLabel: _periodLabel)),
                      const SizedBox(height: 14),
                      if (_topPlaces.isNotEmpty) Expanded(child: reportsRankingCard(_topPlaces)),
                    ]),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildError() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.error_outline_rounded, size: 52, color: AppTheme.error),
      const SizedBox(height: 14),
      Text(_error, textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
      const SizedBox(height: 20),
      ElevatedButton.icon(
        onPressed: _loadData,
        icon: const Icon(Icons.refresh_rounded, size: 16),
        label: const Text('Reintentar'),
        style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: AppTheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
      ),
    ]),
  );
}
