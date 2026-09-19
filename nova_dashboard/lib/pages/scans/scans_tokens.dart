// lib/pages/scans/scans_tokens.dart
// Tokens y helpers compartidos por scans_page.dart y sus widgets.
import 'package:nova_dashboard/utils/app_theme.dart';
import 'package:flutter/material.dart';

const kScansPrimary = AppTheme.primary;

Color scansPlaceColor(String? tipo) {
  switch (tipo) {
    case 'hotel':      return const Color(0xFF3B82F6);
    case 'restaurant': return const Color(0xFF10B981);
    case 'bar':        return const Color(0xFFF59E0B);
    default:           return kScansPrimary;
  }
}

IconData scansPlaceIcon(String? tipo) {
  switch (tipo) {
    case 'hotel':      return Icons.hotel_rounded;
    case 'restaurant': return Icons.restaurant_rounded;
    case 'bar':        return Icons.local_bar_rounded;
    default:           return Icons.place_rounded;
  }
}

String scansFormatDate(String? iso) {
  if (iso == null) return '';
  try {
    final d = DateTime.parse(iso).toLocal();
    return '${d.day}/${d.month}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  } catch (_) { return iso; }
}
