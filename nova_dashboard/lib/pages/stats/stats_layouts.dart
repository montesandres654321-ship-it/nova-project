// lib/pages/stats/stats_layouts.dart
// Extraído de stats_dashboard_page.dart (_buildDesktopLayout/_buildTabletLayout/
// _buildMobileLayout) sin cambios de comportamiento ni de estilo.
import 'package:flutter/material.dart';
import 'stats_charts.dart';
import 'stats_kpi_section.dart';

// ═══════════════════════════════════════════════════════
// DESKTOP (>= 900px) — sin scroll
// ═══════════════════════════════════════════════════════
Widget statsDesktopLayout({
  required StatsTotals totals,
  required List<Map<String, dynamic>> scansByDay,
  required List<Map<String, dynamic>> scansByHour,
  required List<Map<String, dynamic>> topPlaces,
  required List<Map<String, dynamic>> rewardsByDay,
  required Map<String, dynamic> placesByType,
  required int selectedDays,
  required void Function(String label) onKpiTap,
}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
    child: Column(
      children: [
        SizedBox(height: 75, child: statsKpiRow(totals, onKpiTap)),
        const SizedBox(height: 10),
        Expanded(
          flex: 6,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 3, child: ScansByDayChart(
                  scansByDay: scansByDay, selectedDays: selectedDays)),
              const SizedBox(width: 10),
              Expanded(flex: 2, child: TopPlacesChart(topPlaces: topPlaces)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          flex: 4,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 1, child: ScansByHourChart(scansByHour: scansByHour)),
              const SizedBox(width: 10),
              Expanded(flex: 1, child: PlacesByTypeChart(placesByType: placesByType)),
              const SizedBox(width: 10),
              Expanded(flex: 1, child: RewardsByDayChart(
                  rewardsByDay: rewardsByDay, selectedDays: selectedDays)),
            ],
          ),
        ),
      ],
    ),
  );
}

// ═══════════════════════════════════════════════════════
// TABLET (600–900px) — scroll suave
// ═══════════════════════════════════════════════════════
Widget statsTabletLayout({
  required StatsTotals totals,
  required List<Map<String, dynamic>> scansByDay,
  required List<Map<String, dynamic>> scansByHour,
  required List<Map<String, dynamic>> topPlaces,
  required List<Map<String, dynamic>> rewardsByDay,
  required Map<String, dynamic> placesByType,
  required int selectedDays,
  required void Function(String label) onKpiTap,
}) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(14),
    child: Column(
      children: [
        statsKpiGrid(totals, onKpiTap, columns: 2, aspectRatio: 2.5),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: SizedBox(height: 220, child: ScansByDayChart(
                scansByDay: scansByDay, selectedDays: selectedDays))),
            const SizedBox(width: 10),
            Expanded(child: SizedBox(height: 220, child: TopPlacesChart(topPlaces: topPlaces))),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: SizedBox(height: 200, child: ScansByHourChart(scansByHour: scansByHour))),
            const SizedBox(width: 10),
            Expanded(child: SizedBox(height: 200, child: PlacesByTypeChart(placesByType: placesByType))),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(height: 200, child: RewardsByDayChart(
            rewardsByDay: rewardsByDay, selectedDays: selectedDays)),
        const SizedBox(height: 12),
      ],
    ),
  );
}

// ═══════════════════════════════════════════════════════
// MÓVIL (< 600px) — scroll vertical
// ═══════════════════════════════════════════════════════
Widget statsMobileLayout({
  required StatsTotals totals,
  required List<Map<String, dynamic>> scansByDay,
  required List<Map<String, dynamic>> scansByHour,
  required List<Map<String, dynamic>> topPlaces,
  required List<Map<String, dynamic>> rewardsByDay,
  required Map<String, dynamic> placesByType,
  required int selectedDays,
  required void Function(String label) onKpiTap,
}) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(12),
    child: Column(
      children: [
        statsKpiGrid(totals, onKpiTap, columns: 2, aspectRatio: 2.0),
        const SizedBox(height: 10),
        SizedBox(height: 200, child: ScansByDayChart(
            scansByDay: scansByDay, selectedDays: selectedDays)),
        const SizedBox(height: 10),
        SizedBox(height: 200, child: TopPlacesChart(topPlaces: topPlaces)),
        const SizedBox(height: 10),
        SizedBox(height: 180, child: ScansByHourChart(scansByHour: scansByHour)),
        const SizedBox(height: 10),
        SizedBox(height: 180, child: PlacesByTypeChart(placesByType: placesByType)),
        const SizedBox(height: 10),
        SizedBox(height: 180, child: RewardsByDayChart(
            rewardsByDay: rewardsByDay, selectedDays: selectedDays)),
        const SizedBox(height: 12),
      ],
    ),
  );
}
