// lib/pages/rewards/widgets/rewards_table.dart
import 'package:nova_dashboard/utils/app_theme.dart';
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
      decoration: AppTheme.cardDecoration(),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          decoration: BoxDecoration(
            color: AppTheme.backgroundGray,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppTheme.cardRadius),
              topRight: Radius.circular(AppTheme.cardRadius)),
            border: const Border(bottom: BorderSide(color: AppTheme.border)),
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
            Icon(Icons.card_giftcard_outlined, size: 52, color: AppTheme.gray200),
            const SizedBox(height: 12),
            Text(emptyLabel, style: const TextStyle(fontSize: 14, color: AppTheme.textMuted)),
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
