// lib/pages/user_detail_page.dart
// UI: layout responsivo 3 col (>900) / 2 col (600-900) / 1 col (<600)
// Lógica, endpoints y modelos sin cambios
// REFACTOR: tarjetas y layouts extraídos a lib/pages/user_detail/ para
// bajar de 574 a <300 líneas.
import 'package:nova_dashboard/utils/app_theme.dart';
import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import '../services/reward_service.dart';
import '../models/user_model.dart';
import 'user_detail/user_detail_tokens.dart';
import 'user_detail/widgets/user_detail_layouts.dart';

class UserDetailPage extends StatefulWidget {
  final int userId;
  const UserDetailPage({super.key, required this.userId});
  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  bool _loading = true;
  String _error = '';
  UserModel? _user;
  List<dynamic> _scans = [], _rewards = [], _topPlaces = [];
  Map<String, dynamic> _stats = {};

  @override
  void initState() { super.initState(); _loadUserDetail(); }

  Future<void> _loadUserDetail() async {
    try {
      setState(() { _loading = true; _error = ''; });
      final r = await AdminService.getUserDetail(widget.userId);
      if (r['success'] == true && mounted) {
        setState(() {
          _user      = UserModel.fromJson(r['user']);
          _scans     = r['scans']     ?? [];
          _rewards   = r['rewards']   ?? [];
          _topPlaces = r['topPlaces'] ?? [];
          _stats     = r['stats']     ?? {};
          _loading   = false;
        });
      } else { throw Exception(r['error'] ?? 'Error'); }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _deliverReward(dynamic rewardId) async {
    if (rewardId == null) return;
    try {
      final result = await RewardService.redeemRewardAdmin(rewardId as int);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['success'] == true
            ? 'Recompensa entregada correctamente'
            : result['error'] ?? 'Error al entregar'),
        backgroundColor: result['success'] == true ? AppTheme.success : AppTheme.error,
      ));
      if (result['success'] == true) _loadUserDetail();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'), backgroundColor: AppTheme.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(_user?.displayName ?? 'Detalle de Usuario'),
        backgroundColor: kUserDetailTeal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadUserDetail),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kUserDetailTeal))
          : _error.isNotEmpty
              ? _buildError()
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_user == null) return const SizedBox();
    return UserDetailContent(
      user: _user!,
      stats: _stats,
      scans: _scans,
      rewards: _rewards,
      topPlaces: _topPlaces,
      onDeliverReward: _deliverReward,
    );
  }

  Widget _buildError() => Center(child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Icon(Icons.error_outline, size: 60, color: AppTheme.error),
      const SizedBox(height: 16),
      Text('Error: $_error', textAlign: TextAlign.center),
      const SizedBox(height: 16),
      ElevatedButton.icon(
        onPressed: _loadUserDetail,
        icon: const Icon(Icons.refresh),
        label: const Text('Reintentar'),
        style: ElevatedButton.styleFrom(
            backgroundColor: kUserDetailTeal, foregroundColor: Colors.white),
      ),
    ],
  ));
}
