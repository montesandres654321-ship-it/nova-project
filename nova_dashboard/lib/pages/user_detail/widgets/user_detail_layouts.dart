// lib/pages/user_detail/widgets/user_detail_layouts.dart
// Extraído de user_detail_page.dart (_buildContent/_buildLayout/
// _buildSectionTitle) sin cambios de comportamiento ni de estilo.
import 'package:nova_dashboard/utils/app_theme.dart';
import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import 'user_compact_stats.dart';
import 'user_profile_card.dart';
import 'user_recent_rewards.dart';
import 'user_recent_scans.dart';
import 'user_top_places.dart';

Widget _sectionTitle(String title, IconData icon, Color color) {
  return Row(
    children: [
      Container(
        width: 4, height: 18,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 8),
      Icon(icon, size: 16, color: color),
      const SizedBox(width: 6),
      Text(title, style: const TextStyle(
        fontSize: 14, fontWeight: FontWeight.w600,
        color: Color(0xFF1F2937),
      )),
    ],
  );
}

class UserDetailContent extends StatelessWidget {
  final UserModel user;
  final Map<String, dynamic> stats;
  final List<dynamic> scans;
  final List<dynamic> rewards;
  final List<dynamic> topPlaces;
  final void Function(dynamic rewardId) onDeliverReward;

  const UserDetailContent({
    super.key,
    required this.user,
    required this.stats,
    required this.scans,
    required this.rewards,
    required this.topPlaces,
    required this.onDeliverReward,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraints) {
      final w = constraints.maxWidth;

      if (w > 900) return _desktopLayout();
      if (w > 600) return _tabletLayout();
      return _mobileLayout();
    });
  }

  // ── Desktop: 4 columnas con VerticalDivider ───────────
  Widget _desktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 240,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                UserProfileCard(user: user),
                const SizedBox(height: 16),
                UserCompactStats(stats: stats),
              ],
            ),
          ),
        ),
        const VerticalDivider(width: 1, color: Color(0xFFE5E7EB)),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Lugares Más Visitados',
                    Icons.place_rounded, AppTheme.primary),
                const SizedBox(height: 12),
                UserTopPlacesCard(topPlaces: topPlaces),
              ],
            ),
          ),
        ),
        const VerticalDivider(width: 1, color: Color(0xFFE5E7EB)),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Recompensas Recientes',
                    Icons.card_giftcard_rounded, const Color(0xFFF59E0B)),
                const SizedBox(height: 12),
                UserRecentRewardsCard(rewards: rewards, onDeliver: onDeliverReward),
              ],
            ),
          ),
        ),
        const VerticalDivider(width: 1, color: Color(0xFFE5E7EB)),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Últimos Escaneos',
                    Icons.qr_code_scanner_rounded, const Color(0xFF3B82F6)),
                const SizedBox(height: 12),
                UserRecentScansCard(scans: scans),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _tabletLayout() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 250,
          child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              UserProfileCard(user: user),
              const SizedBox(height: 16),
              UserCompactStats(stats: stats),
            ]),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (topPlaces.isNotEmpty) ...[
              UserTopPlacesCard(topPlaces: topPlaces),
              const SizedBox(height: 16),
            ],
            UserRecentScansCard(scans: scans),
            const SizedBox(height: 16),
            UserRecentRewardsCard(rewards: rewards, onDeliver: onDeliverReward),
          ]),
        )),
      ]),
    );
  }

  Widget _mobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        UserProfileCard(user: user),
        const SizedBox(height: 12),
        UserCompactStats(stats: stats),
        if (topPlaces.isNotEmpty) ...[
          const SizedBox(height: 12),
          UserTopPlacesCard(topPlaces: topPlaces),
        ],
        const SizedBox(height: 12),
        UserRecentScansCard(scans: scans),
        const SizedBox(height: 12),
        UserRecentRewardsCard(rewards: rewards, onDeliver: onDeliverReward),
      ]),
    );
  }
}
