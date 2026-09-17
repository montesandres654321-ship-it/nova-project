// lib/pages/user_detail/widgets/user_compact_stats.dart
// Extraído de user_detail_page.dart (_buildCompactStats/_miniStat) sin
// cambios de comportamiento ni de estilo.
import 'package:flutter/material.dart';
import '../user_detail_tokens.dart';
import 'user_detail_shared.dart';

class UserCompactStats extends StatelessWidget {
  final Map<String, dynamic> stats;
  const UserCompactStats({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final ts = stats['totalScans']      ?? 0;
    final tr = stats['totalRewards']    ?? 0;
    final rd = stats['redeemedRewards'] ?? 0;
    final pn = tr - rd;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: userDetailCardDecoration(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        userDetailSectionHeader('Estadísticas', kUserDetailTeal),
        const SizedBox(height: 12),
        Row(children: [
          userDetailMiniStat('Escaneos',    '$ts', Icons.qr_code_scanner,     kUserDetailBlue),
          const SizedBox(width: 10),
          userDetailMiniStat('Recompensas', '$tr', Icons.card_giftcard,        kUserDetailAmber),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          userDetailMiniStat('Canjeadas',  '$rd', Icons.check_circle_rounded,  kUserDetailGreen),
          const SizedBox(width: 10),
          userDetailMiniStat('Pendientes', '$pn', Icons.access_time_rounded,   Colors.purple),
        ]),
      ]),
    );
  }
}
