// lib/pages/rewards/widgets/rewards_table.dart
// Extraído de rewards_detail_page.dart (_buildDesktopContent, la tabla)
// sin cambios de comportamiento ni de estilo.
import 'package:flutter/material.dart';
import '../../../models/reward_model.dart';
import 'reward_row.dart';
import 'rewards_toolbar.dart';

class RewardsTable extends StatelessWidget {
  final List<RewardModel> rewards;
  final Set<int> loadingIds;
  final String emptyLabel;
  final void Function(RewardModel) onRedeem;

  const RewardsTable({
    super.key,
    required this.rewards,
    required this.loadingIds,
    required this.emptyLabel,
    required this.onRedeem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          decoration: const BoxDecoration(
            color: Color(0xFFF1F5F9),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
          ),
          child: Row(children: [
            rewardsColHead('Turista', flex: 3),
            rewardsColHead('Lugar', flex: 3),
            rewardsColHead('Recompensa', flex: 2),
            rewardsColHead('Fecha', flex: 2),
            rewardsColHead('Estado', flex: 2),
            rewardsColHead('Acción', flex: 2),
          ]),
        ),
        Expanded(
          child: rewards.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.card_giftcard_outlined, size: 52, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(emptyLabel, style: TextStyle(fontSize: 14, color: Colors.grey[500])),
          ]))
              : ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: rewards.length,
            itemBuilder: (_, i) => RewardRow(
              r: rewards[i],
              index: i,
              isLast: i == rewards.length - 1,
              onRedeem: () => onRedeem(rewards[i]),
              isLoading: loadingIds.contains(rewards[i].id),
            ),
          ),
        ),
      ]),
    );
  }
}
