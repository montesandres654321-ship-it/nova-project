// lib/pages/owners/dashboard/owner_reward_mini.dart
// Extraído de owners/dashboard_page.dart (_rewardMini/_miniStat) sin
// cambios de comportamiento ni de estilo (FIX 3: Stock/Entregadas/Disponibles).
import 'package:flutter/material.dart';
import '../../../models/place.dart';
import '../../../utils/app_theme.dart';
import '../reward_dialog.dart';

Widget ownerRewardMini({
  required BuildContext context,
  required Place? place,
  required int rewards,
  required VoidCallback onSaved,
}) {
  // rewardStock == null → ilimitado; rewardStock != null → stock fijo
  final stock          = place?.rewardStock;
  final disponiblesNum = stock != null ? stock - rewards : null;
  final disponiblesStr = disponiblesNum == null ? '∞' : '$disponiblesNum';
  // Alerta roja si quedan 3 o menos unidades (solo cuando hay stock fijo)
  final disponiblesColor = disponiblesNum != null && disponiblesNum <= 3
      ? AppTheme.error
      : AppTheme.warning;

  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.warning.withOpacity(0.2))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Row(children: [
        Text(place?.rewardIcon ?? '🎁', style: const TextStyle(fontSize: 22)),
        const SizedBox(width: AppTheme.space8),
        Expanded(child: Text(place?.rewardName ?? 'Recompensa',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            maxLines: 1, overflow: TextOverflow.ellipsis)),
      ]),
      const SizedBox(height: 6),
      Row(children: [
        ownerMiniStat(stock == null ? '∞' : '$stock', 'Stock',       AppTheme.primary),
        const SizedBox(width: 6),
        ownerMiniStat('$rewards',                    'Entregadas',   AppTheme.warning),
        const SizedBox(width: 6),
        ownerMiniStat(disponiblesStr,                 'Disponibles',  disponiblesColor),
      ]),
      const SizedBox(height: 6),
      InkWell(
        onTap: () => showDialog(context: context, builder: (_) => OwnerRewardDialog(
            currentIcon: place?.rewardIcon, currentName: place?.rewardName,
            currentDescription: place?.rewardDescription, currentStock: place?.rewardStock, onSaved: onSaved)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppTheme.space4),
          decoration: BoxDecoration(color: AppTheme.warning.withOpacity(0.08), borderRadius: BorderRadius.circular(6)),
          child: const Text('Editar', textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: AppTheme.warning, fontWeight: FontWeight.w600)),
        ),
      ),
    ]),
  );
}

Widget ownerMiniStat(String v, String l, Color c) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: AppTheme.space4),
    decoration: BoxDecoration(color: c.withOpacity(0.06), borderRadius: BorderRadius.circular(6)),
    child: Column(children: [
      Text(v, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: c)),
      Text(l, style: const TextStyle(fontSize: 8, color: AppTheme.textMuted)),
    ])));
