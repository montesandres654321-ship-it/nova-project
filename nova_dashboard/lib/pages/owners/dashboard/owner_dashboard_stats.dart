// lib/pages/owners/dashboard/owner_dashboard_stats.dart
// Extraído de owners/dashboard_page.dart (_buildStatsRow/_stat) sin
// cambios de comportamiento ni de estilo.
import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';

Widget ownerStatsRow({
  required int visitors,
  required int scans,
  required int rewards,
  required int redeemed,
}) {
  return Row(children: [
    ownerStat('Visitantes', visitors, Icons.people_rounded, AppTheme.primary),
    const SizedBox(width: AppTheme.space8),
    ownerStat('Escaneos', scans, Icons.qr_code_scanner_rounded, AppTheme.primaryDark),
    const SizedBox(width: AppTheme.space8),
    ownerStat('Otorgadas', rewards, Icons.card_giftcard_rounded, AppTheme.warning),
    const SizedBox(width: AppTheme.space8),
    ownerStat('Canjeadas', redeemed, Icons.check_circle_rounded, AppTheme.success),
  ]);
}

Widget ownerStat(String t, int v, IconData i, Color c) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    // Antipatrón corregido: antes tenía border: Border.all(c.withOpacity(0.2))
    // Y boxShadow a la vez. Ahora usa AppTheme.cardDecoration() — solo sombra
    // (nova-design 4bis). Efecto secundario: el radio pasa de 10 a 12 (cardRadius).
    decoration: AppTheme.cardDecoration(),
    child: Row(children: [
      Container(width: 32, height: 32, decoration: BoxDecoration(
          color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(AppTheme.radiusSM)),
          child: Icon(i, color: c, size: 16)),
      const SizedBox(width: AppTheme.space8),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Text(v.toString(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: c)),
        Text(t, style: const TextStyle(fontSize: 9, color: AppTheme.textMuted)),
      ])),
    ])));
