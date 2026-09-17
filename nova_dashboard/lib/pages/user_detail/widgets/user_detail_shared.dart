// lib/pages/user_detail/widgets/user_detail_shared.dart
// Extraído de user_detail_page.dart (_sectionHeader/_cardDec/_badge/
// _miniStat/_formatDate) sin cambios de comportamiento ni de estilo.
import 'package:flutter/material.dart';
import '../user_detail_tokens.dart';

Widget userDetailSectionHeader(String title, Color color) => Row(children: [
  Container(width: 3, height: 14,
      decoration: BoxDecoration(
          color: kUserDetailTeal, borderRadius: BorderRadius.circular(2))),
  const SizedBox(width: 8),
  Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
      color: Color(0xFF0F172A))),
]);

BoxDecoration userDetailCardDecoration() => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(14),
  border: Border.all(color: const Color(0xFFE2E8F0)),
  boxShadow: [
    BoxShadow(
      color: Colors.grey.withOpacity(0.06),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ],
);

Widget userDetailBadge(String icon, String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(icon, style: TextStyle(fontSize: 12, color: color)),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    ]));

Widget userDetailMiniStat(String label, String value, IconData icon, Color color) =>
    Expanded(child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w800, color: color, height: 1.1)),
          Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
        ])),
      ]),
    ));

String userDetailFormatDate(String? ds) {
  if (ds == null) return 'N/A';
  try {
    final d    = DateTime.parse(ds);
    final diff = DateTime.now().difference(d);
    if (diff.inDays == 0) {
      if (diff.inHours == 0) return 'Hace ${diff.inMinutes}m';
      return 'Hace ${diff.inHours}h';
    }
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 7)  return 'Hace ${diff.inDays}d';
    return '${d.day}/${d.month}/${d.year}';
  } catch (e) { return ds; }
}
