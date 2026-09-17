// lib/pages/stats/stats_kpi_section.dart
// Extraído de stats_dashboard_page.dart (_buildKpiRow/_buildKpiGrid/_buildKpiCard)
// sin cambios de comportamiento ni de estilo.
import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class StatsTotals {
  final int scans;
  final int users;
  final int places;
  final int rewards;
  const StatsTotals({
    required this.scans,
    required this.users,
    required this.places,
    required this.rewards,
  });
}

List<Widget> _kpiCards(StatsTotals t, void Function(String label) onTap) => [
  _StatsKpiCard(label: 'Total Escaneos', value: t.scans,
      icon: Icons.qr_code_scanner_rounded, color: AppTheme.primary, onTap: onTap),
  _StatsKpiCard(label: 'Turistas', value: t.users,
      icon: Icons.people_rounded, color: AppTheme.info, onTap: onTap),
  _StatsKpiCard(label: 'Lugares Activos', value: t.places,
      icon: Icons.place_rounded, color: AppTheme.success, onTap: onTap),
  _StatsKpiCard(label: 'Recompensas', value: t.rewards,
      icon: Icons.card_giftcard_rounded, color: AppTheme.warning, onTap: onTap),
];

Widget statsKpiRow(StatsTotals totals, void Function(String label) onTap) {
  final cards = _kpiCards(totals, onTap);
  return Row(children: [
    for (int i = 0; i < cards.length; i++) ...[
      if (i > 0) const SizedBox(width: 8),
      Expanded(child: cards[i]),
    ],
  ]);
}

Widget statsKpiGrid(
  StatsTotals totals,
  void Function(String label) onTap, {
  required int columns,
  required double aspectRatio,
}) {
  return GridView.count(
    crossAxisCount: columns,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisSpacing: 8,
    mainAxisSpacing: 8,
    childAspectRatio: aspectRatio,
    children: _kpiCards(totals, onTap),
  );
}

class _StatsKpiCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final void Function(String label) onTap;

  const _StatsKpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(label),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          // Antipatrón corregido: antes tenía border (franja superior de color)
          // + boxShadow a la vez. Ahora usa AppTheme.cardDecoration() — solo
          // sombra (nova-design 4bis).
          decoration: AppTheme.cardDecoration(),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('$value',
                        style: TextStyle(fontSize: 18,
                            fontWeight: FontWeight.w700, color: color,
                            height: 1.1)),
                    Text(label,
                        style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
