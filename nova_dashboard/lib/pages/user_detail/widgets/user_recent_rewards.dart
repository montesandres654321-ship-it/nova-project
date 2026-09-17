// lib/pages/user_detail/widgets/user_recent_rewards.dart
// Extraído de user_detail_page.dart (_buildRecentRewards) sin cambios de
// comportamiento ni de estilo.
import 'package:flutter/material.dart';
import '../user_detail_tokens.dart';
import 'user_detail_shared.dart';

class UserRecentRewardsCard extends StatelessWidget {
  final List<dynamic> rewards;
  final void Function(dynamic rewardId) onDeliver;

  const UserRecentRewardsCard({
    super.key,
    required this.rewards,
    required this.onDeliver,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: userDetailCardDecoration(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: userDetailSectionHeader('Recompensas Recientes', kUserDetailAmber),
        ),
        if (rewards.isEmpty)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Center(child: Column(children: [
              Icon(Icons.card_giftcard, size: 32, color: Colors.grey[300]),
              const SizedBox(height: 8),
              Text('Sin recompensas registradas',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            ])),
          )
        else
          ...(rewards.take(10).map((r) {
            final isPending = r['is_redeemed'] != 1 && r['is_redeemed'] != true;
            return ListTile(
              dense: true,
              leading: Icon(
                isPending ? Icons.card_giftcard : Icons.check_circle,
                color: isPending ? kUserDetailAmber : kUserDetailGreen,
                size: 20,
              ),
              title: Text(r['reward_name'] ?? 'N/A',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              subtitle: Text(r['place_name'] ?? 'N/A',
                  style: TextStyle(fontSize: 10, color: Colors.grey[600])),
              trailing: isPending
                  ? SizedBox(
                      height: 28,
                      child: ElevatedButton(
                        onPressed: () => onDeliver(r['id']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kUserDetailTeal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                        child: const Text('Entregar'),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: kUserDetailGreen.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('Canjeada',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: kUserDetailGreen)),
                    ),
            );
          })),
        const SizedBox(height: 8),
      ]),
    );
  }
}
