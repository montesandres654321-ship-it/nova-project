// lib/pages/reports/reports_kpi_row.dart
// Extraído de reports_page.dart (_buildKpiRow/_kpiCard + constantes)
// sin cambios de comportamiento ni de estilo.
import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

// Antes: [blue, green, amber, purple] — el morado no existe en la paleta
// oficial y esta pantalla usaba un orden distinto al de stats_dashboard_page
// para los mismos 4 KPIs. Alineado aquí para que "Turistas"/"Recompensas"/etc.
// tengan el mismo color en toda la app (hallazgo de la auditoría).
const _kpiColors = [
  AppTheme.primary,
  AppTheme.info,
  AppTheme.success,
  AppTheme.warning,
];
const _kpiIcons = [
  Icons.qr_code_scanner_rounded,
  Icons.people_rounded,
  Icons.place_rounded,
  Icons.card_giftcard_rounded,
];
const _kpiLabels = ['Total Escaneos', 'Turistas', 'Lugares Activos', 'Recompensas'];
// Rutas de navegación para cada KPI (deben existir en main.dart)
const _kpiRoutes = ['/scans', '/users', '/places', '/rewards'];

Widget reportsKpiRow({
  required BuildContext context,
  required bool isWide,
  required int totalScans,
  required int totalUsers,
  required int totalPlaces,
  required int totalRewards,
}) {
  final values = [
    totalScans.toString(),
    totalUsers.toString(),
    totalPlaces.toString(),
    totalRewards.toString(),
  ];

  if (isWide) {
    return Row(children: List.generate(4, (i) => Expanded(
      child: Padding(
        padding: EdgeInsets.only(left: i > 0 ? 12 : 0),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, _kpiRoutes[i]),
            child: _kpiCard(i, values[i]),
          ),
        ),
      ),
    )));
  }
  return GridView.count(
    crossAxisCount: 2, shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    mainAxisSpacing: 10, crossAxisSpacing: 10,
    childAspectRatio: 2.2,
    children: List.generate(4, (i) => MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, _kpiRoutes[i]),
        child: _kpiCard(i, values[i]),
      ),
    )),
  );
}

Widget _kpiCard(int index, String value) {
  final color = _kpiColors[index];
  return Container(
    // Antipatrón corregido: antes tenía border izquierdo de color + boxShadow
    // a la vez. Ahora solo sombra (nova-design 4bis) — se pierde la franja
    // de color como distinción, el ícono y el valor siguen coloreados.
    decoration: AppTheme.cardDecoration(),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    child: Row(children: [
      Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(_kpiIcons[index], color: color, size: 16),
      ),
      const SizedBox(width: 10),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800,
                  color: AppTheme.textHead, height: 1.1)),
          Text(_kpiLabels[index],
              style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
              overflow: TextOverflow.ellipsis),
        ],
      )),
    ]),
  );
}
