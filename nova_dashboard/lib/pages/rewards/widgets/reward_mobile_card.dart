// lib/pages/rewards/widgets/reward_mobile_card.dart
// Extraído de rewards_detail_page.dart (item de _buildRewardsList) sin
// cambios de comportamiento ni de estilo.
import 'package:flutter/material.dart';
import '../../../models/reward_model.dart';
import '../rewards_detail_tokens.dart';

class RewardMobileCard extends StatelessWidget {
  final RewardModel r;
  final bool isLoading;
  final VoidCallback onRedeem;

  const RewardMobileCard({
    super.key,
    required this.r,
    required this.isLoading,
    required this.onRedeem,
  });

  @override
  Widget build(BuildContext context) {
    final isRedeemed = r.isRedeemedBool;
    final name = [r.firstName, r.lastName]
        .where((s) => s != null && s.isNotEmpty).join(' ');
    final userName = name.isNotEmpty ? name : (r.email ?? 'Turista');
    final placeName = r.placeName ?? '';
    final rewardName = r.rewardName;
    final rewardIcon = r.rewardIcon ?? '🎁';
    final date = r.earnedAt.length >= 10 ? r.earnedAt.substring(0, 10) : r.earnedAt;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: kRewardsTeal.withOpacity(0.1),
          child: Text(
            userName.isNotEmpty ? userName[0].toUpperCase() : '?',
            style: const TextStyle(color: kRewardsTeal, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(userName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Row(children: [
              Flexible(child: Text(placeName,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis)),
              const Text(' · ', style: TextStyle(color: Colors.grey)),
              Text(date, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              Text('$rewardIcon ', style: const TextStyle(fontSize: 12)),
              Flexible(child: Text(rewardName,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF374151)),
                  overflow: TextOverflow.ellipsis)),
            ]),
          ]),
        ),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isRedeemed ? kRewardsGreen.withOpacity(0.1) : kRewardsAmber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isRedeemed ? 'Canjeada' : 'Pendiente',
              style: TextStyle(
                fontSize: 10,
                color: isRedeemed ? kRewardsGreen : kRewardsAmber,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (!isRedeemed) ...[
            const SizedBox(height: 6),
            isLoading
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : GestureDetector(
                    onTap: onRedeem,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: kRewardsAmber,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('Entregar',
                          style: TextStyle(fontSize: 10, color: Colors.white,
                              fontWeight: FontWeight.w500)),
                    ),
                  ),
          ],
        ]),
      ]),
    );
  }
}
