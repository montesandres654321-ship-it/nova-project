// lib/pages/admins/detail/admin_detail_shared.dart
// Extraído de admin_detail_dialog.dart (_card/_infoRow/_badgeRow/_statRow/
// _statusBadge/_roleBadge) sin cambios de comportamiento ni de estilo.
import 'package:flutter/material.dart';
import 'admin_detail_tokens.dart';

Widget adminDetailCard(String title, List<Widget> children) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: kAdminDetailBorder),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Header de sección
      Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: const BoxDecoration(
          color: kAdminDetailBgCard,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          border: Border(bottom: BorderSide(color: kAdminDetailBorder, width: 0.5)),
        ),
        child: Row(children: [
          Container(width: 2, height: 11,
              decoration: BoxDecoration(
                  color: kAdminDetailPrimary, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 7),
          Text(title,
              style: const TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w700,
                  color: kAdminDetailTextMuted, letterSpacing: 0.5)),
        ]),
      ),
      // Contenido
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children),
      ),
    ]),
  );
}

Widget adminDetailInfoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        width: 76,
        child: Text(label,
            style: const TextStyle(
                fontSize: 11, color: kAdminDetailTextSub, fontWeight: FontWeight.w500)),
      ),
      Expanded(
        child: Text(value,
            style: const TextStyle(
                fontSize: 12, color: kAdminDetailTextHead, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
            maxLines: 2),
      ),
    ]),
  );
}

Widget adminDetailBadgeRow(String label, Widget badge) {
  return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
    SizedBox(
      width: 76,
      child: Text(label,
          style: const TextStyle(
              fontSize: 11, color: kAdminDetailTextSub, fontWeight: FontWeight.w500)),
    ),
    badge,
  ]);
}

Widget adminDetailStatRow(IconData icon, String label, String value, Color color) {
  return Row(children: [
    Container(
      width: 26, height: 26,
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Icon(icon, size: 13, color: color),
    ),
    const SizedBox(width: 8),
    Expanded(
      child: Text(label,
          style: const TextStyle(fontSize: 11, color: kAdminDetailTextMuted)),
    ),
    Text(value,
        style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w700, color: color)),
  ]);
}

Widget adminDetailStatusBadge(bool isActive,
    {String activeText = 'Activo', String inactiveText = 'Inactivo'}) {
  final color = isActive ? kAdminDetailGreen : kAdminDetailRed;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 6, height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 5),
      Text(isActive ? activeText : inactiveText,
          style: TextStyle(
              fontSize: 11, color: color,
              fontWeight: FontWeight.w700, letterSpacing: 0.2)),
    ]),
  );
}

Widget adminDetailRoleBadge(String emoji, String label) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: kAdminDetailPrimary.withOpacity(0.08),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: kAdminDetailPrimary.withOpacity(0.2)),
    ),
    child: Text('$emoji $label',
        style: const TextStyle(
            fontSize: 11, color: kAdminDetailPrimary, fontWeight: FontWeight.w700)),
  );
}
