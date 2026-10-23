// lib/pages/owners/place_edit/place_edit_fields.dart
// Extraído de place_edit_page.dart (_readOnlyField/_dec/_sectionCard) sin
// cambios de comportamiento ni de estilo.
import 'package:nova_dashboard/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'place_edit_tokens.dart';

Widget placeEditReadOnlyField(String label, String value, IconData icon) {
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label,
        style: const TextStyle(fontSize: 10, color: AppTheme.textMuted,
            fontWeight: FontWeight.w600)),
    const SizedBox(height: 3),
    Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
            color: AppTheme.backgroundGray,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.border)),
        child: Row(children: [
          Icon(icon, size: 16, color: AppTheme.textMuted),
          const SizedBox(width: 8),
          Expanded(child: Text(value,
              style: const TextStyle(fontSize: 13, color: AppTheme.textHead))),
        ])),
  ]);
}

InputDecoration placeEditInputDecoration(String label, IconData icon, {String? hint}) =>
    InputDecoration(
        labelText: label, hintText: hint,
        prefixIcon: Icon(icon, size: 18),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: kPlaceEditTeal, width: 1.5)));

Widget placeEditSectionCard(String title, List<Widget> children) {
  return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(
            color: Colors.grey.withOpacity(0.07), blurRadius: 8)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
                border: Border(left: BorderSide(color: kPlaceEditTeal, width: 4)),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12))),
            child: Text(title,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.bold,
                    color: kPlaceEditTeal))),
        Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children)),
      ]));
}
