// lib/pages/rewards_detail_page.dart
// ============================================================
// FIX: Botón "Canjear" en columna Estado para recompensas pendientes
// Usa PATCH /rewards/:id/redeem del backend
// REFACTOR: fila de tabla, tarjeta móvil y barras de filtro extraídas a
// lib/pages/rewards/ para bajar de 661 a <300 líneas.
// ============================================================
import 'package:nova_dashboard/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'rewards/rewards_detail_tokens.dart';
import 'rewards/widgets/reward_mobile_card.dart';
import 'rewards/widgets/rewards_table.dart';
import 'rewards/widgets/rewards_toolbar.dart';
import '../services/reward_service.dart';
import '../models/reward_model.dart';

class RewardsDetailPage extends StatefulWidget {
  final String initialFilter;

  const RewardsDetailPage({
    super.key,
    this.initialFilter = 'all',
  });

  @override
  State<RewardsDetailPage> createState() => _RewardsDetailPageState();
}

class _RewardsDetailPageState extends State<RewardsDetailPage> {
  List<RewardModel> _allRewards      = [];
  List<RewardModel> _filteredRewards = [];
  bool    _loading      = true;
  String? _error;
  late String _tableFilter;
  String _searchQuery = '';
  final Set<int> _loadingIds = {};

  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tableFilter = widget.initialFilter;
    _loadData();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final rewards = await RewardService.getAllRewards();
      if (!mounted) return;
      setState(() {
        _allRewards      = rewards;
        _filteredRewards = _applyFilters(rewards);
        _loading         = false;
      });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  List<RewardModel> _applyFilters(List<RewardModel> list) {
    var result = list;
    switch (_tableFilter) {
      case 'redeemed': result = result.where((r) =>  r.isRedeemedBool).toList(); break;
      case 'pending':  result = result.where((r) => !r.isRedeemedBool).toList(); break;
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((r) {
        final name = '${r.firstName ?? ''} ${r.lastName ?? ''}'.toLowerCase();
        final place = (r.placeName ?? '').toLowerCase();
        final reward = r.rewardName.toLowerCase();
        return name.contains(q) || place.contains(q) || reward.contains(q);
      }).toList();
    }
    return result;
  }

  void _setFilter(String filter) {
    setState(() { _tableFilter = filter; _filteredRewards = _applyFilters(_allRewards); });
  }

  void _onSearch(String query) {
    setState(() { _searchQuery = query; _filteredRewards = _applyFilters(_allRewards); });
  }

  // ── ENTREGAR RECOMPENSA ─────────────────────────────────
  Future<void> _redeemReward(RewardModel reward) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(children: [
          Text(reward.rewardIcon ?? '🎁', style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          const Expanded(child: Text('Entregar Recompensa', style: TextStyle(fontSize: 16))),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('¿Entregar esta recompensa?', style: TextStyle(color: Colors.grey[700])),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: kRewardsAmber.withOpacity(0.06), borderRadius: BorderRadius.circular(8)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Turista: ${[reward.firstName, reward.lastName].where((s) => s != null && s.isNotEmpty).join(' ')}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              Text('Lugar: ${reward.placeName ?? 'N/A'}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              Text('Premio: ${reward.rewardName}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ]),
          ),
          const SizedBox(height: 8),
          Text('Esta acción no se puede deshacer.', style: TextStyle(fontSize: 11, color: Colors.red[400])),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.check_circle_rounded, size: 16),
            label: const Text('Entregar'),
            style: ElevatedButton.styleFrom(backgroundColor: kRewardsGreen, foregroundColor: Colors.white),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _loadingIds.add(reward.id));

    final result = await RewardService.redeemRewardAdmin(reward.id);

    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        _loadingIds.remove(reward.id);
        final idx = _allRewards.indexWhere((r) => r.id == reward.id);
        if (idx != -1) _allRewards[idx] = _allRewards[idx].copyWith(isRedeemed: 1);
        _filteredRewards = _applyFilters(_allRewards);
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('✅ Recompensa entregada correctamente'),
        backgroundColor: kRewardsGreen,
      ));
    } else {
      setState(() => _loadingIds.remove(reward.id));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: ${result['error'] ?? 'No se pudo entregar'}'),
        backgroundColor: AppTheme.error,
      ));
    }
  }

  String get _pageTitle {
    switch (_tableFilter) {
      case 'redeemed': return 'Recompensas Canjeadas';
      case 'pending':  return 'Recompensas Pendientes';
      default:         return 'Todas las Recompensas';
    }
  }

  int get _totalCount    => _allRewards.length;
  int get _redeemedCount => _allRewards.where((r) =>  r.isRedeemedBool).length;
  int get _pendingCount  => _allRewards.where((r) => !r.isRedeemedBool).length;

  String get _emptyLabel => _searchQuery.isNotEmpty
      ? 'Sin resultados para "$_searchQuery"'
      : _tableFilter == 'redeemed' ? 'No hay canjeadas'
      : _tableFilter == 'pending' ? 'No hay pendientes'
      : 'No hay recompensas';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(_pageTitle),
        backgroundColor: kRewardsTeal, foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _loadData, tooltip: 'Actualizar'),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kRewardsTeal))
          : _error != null ? _buildError() : _buildContent(),
    );
  }

  Widget _buildContent() {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 600) return _buildMobileContent();
      return _buildDesktopContent();
    });
  }

  Widget _buildMobileContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        RewardsMobileFilterBar(
          totalCount: _totalCount, redeemedCount: _redeemedCount, pendingCount: _pendingCount,
          tableFilter: _tableFilter, onSetFilter: _setFilter,
          searchCtrl: _searchCtrl, searchQuery: _searchQuery, onSearch: _onSearch,
        ),
        const SizedBox(height: 8),
        Text('${_filteredRewards.length} resultados',
            style: TextStyle(fontSize: 11, color: Colors.grey[500])),
        const SizedBox(height: 8),
        if (_filteredRewards.isEmpty)
          Center(child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.card_giftcard_outlined, size: 52, color: Colors.grey[300]),
              const SizedBox(height: 12),
              Text(_emptyLabel, style: TextStyle(fontSize: 14, color: Colors.grey[500])),
            ]),
          ))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredRewards.length,
            itemBuilder: (context, i) => RewardMobileCard(
              r: _filteredRewards[i],
              isLoading: _loadingIds.contains(_filteredRewards[i].id),
              onRedeem: () => _redeemReward(_filteredRewards[i]),
            ),
          ),
      ]),
    );
  }

  Widget _buildDesktopContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        RewardsDesktopToolbar(
          totalCount: _totalCount, redeemedCount: _redeemedCount, pendingCount: _pendingCount,
          resultCount: _filteredRewards.length,
          tableFilter: _tableFilter, onSetFilter: _setFilter,
          searchCtrl: _searchCtrl, searchQuery: _searchQuery, onSearch: _onSearch,
        ),

        const SizedBox(height: 16),

        Expanded(child: RewardsTable(
          rewards: _filteredRewards,
          loadingIds: _loadingIds,
          emptyLabel: _emptyLabel,
          onRedeem: _redeemReward,
        )),
      ]),
    );
  }

  Widget _buildError() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    const Icon(Icons.error_outline, size: 56, color: AppTheme.error),
    const SizedBox(height: 16), Text(_error!, textAlign: TextAlign.center),
    const SizedBox(height: 20),
    ElevatedButton.icon(onPressed: _loadData, icon: const Icon(Icons.refresh), label: const Text('Reintentar'),
        style: ElevatedButton.styleFrom(backgroundColor: kRewardsTeal, foregroundColor: Colors.white)),
  ]));
}
