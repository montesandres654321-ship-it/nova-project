/// Página de historial de escaneos del turista autenticado.
///
/// Muestra todos los lugares que el turista ha visitado mediante escaneo QR,
/// ordenados del más reciente al más antiguo, y sus recompensas obtenidas.
///
/// Los datos se cargan desde [ApiService.getScanHistory] y
/// [ApiService.getUserRewards]. La presentación de cada tab vive en
/// [ScanHistoryList] y [RewardsHistoryList] (widgets/), respectivamente.
library;

import 'package:flutter/material.dart';
import '../models/scan_record.dart';
import '../services/api_service.dart';
import '../core/design/app_back_button.dart';
import '../core/design/app_colors.dart';
import '../core/design/app_spacing.dart';
import '../widgets/scan_history_list.dart';
import '../widgets/rewards_history_list.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<ScanRecord> _records = [];
  bool _loading = true;
  String _error = '';

  // Recompensas del turista
  List<Map<String, dynamic>> _rewards = [];
  bool _rewardsLoading = true;
  String _rewardsError = '';

  // ── Lifecycle ──────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _loadRewards();
  }

  // ── Data ───────────────────────────────────────────────────

  Future<void> _loadHistory() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final scans = await ApiService.getScanHistory();
      setState(() => _records = scans);
      if (scans.isEmpty) {
        setState(() => _error = 'No hay escaneos registrados');
      }
    } catch (e) {
      setState(() => _error = 'Error al cargar historial: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadRewards() async {
    setState(() { _rewardsLoading = true; _rewardsError = ''; });
    try {
      final rewards = await ApiService.getUserRewards();
      if (!mounted) return;
      setState(() { _rewards = rewards; _rewardsLoading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _rewardsError = 'Error al cargar recompensas'; _rewardsLoading = false; });
    }
  }

  // ── Build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          title: const Text('Historial'),
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          scrolledUnderElevation: 1,
          surfaceTintColor: AppColors.surface,
          automaticallyImplyLeading: false,
          leadingWidth: 52,
          leading: Navigator.canPop(context)
              ? const Padding(
                  padding: EdgeInsets.only(left: AppSpacing.sm),
                  child: Center(child: AppBackButton()),
                )
              : null,
          titleTextStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, size: 22),
              onPressed: _loadHistory,
              tooltip: 'Actualizar',
              color: AppColors.textSecondary,
            ),
          ],
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              Tab(text: 'Escaneos'),
              Tab(text: 'Recompensas'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ScanHistoryList(
              loading: _loading,
              error: _error,
              records: _records,
              onRefresh: _loadHistory,
            ),
            RewardsHistoryList(
              loading: _rewardsLoading,
              error: _rewardsError,
              rewards: _rewards,
              onRefresh: _loadRewards,
            ),
          ],
        ),
      ),
    );
  }
}
