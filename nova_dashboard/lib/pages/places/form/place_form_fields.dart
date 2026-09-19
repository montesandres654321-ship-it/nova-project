// lib/pages/places/form/place_form_fields.dart
// Helpers de formulario compartidos, extraídos de form_page.dart
// (_sectionCard/_responsiveFieldRow/_inputDecoration/_field/_dropdown)
// sin cambios de comportamiento ni de estilo.
import 'package:flutter/material.dart';
import '../../../models/place.dart';
import 'place_form_tokens.dart';

Widget placeFormSectionCard(String title, List<Widget> children) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: kPlaceFormBorder),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2)),
      ],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
        child: Row(children: [
          Container(
              width: 3, height: 16,
              decoration: BoxDecoration(
                  color: kPlaceFormTeal, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 10),
          Text(title,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A))),
        ]),
      ),
      const Divider(height: 1, color: Color(0xFFF1F5F9)),
      Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children)),
    ]),
  );
}

Widget placeFormResponsiveFieldRow(Widget left, Widget right) {
  return LayoutBuilder(builder: (ctx, constraints) {
    if (constraints.maxWidth < 500) {
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        left, const SizedBox(height: 12), right,
      ]);
    }
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: left), const SizedBox(width: 16), Expanded(child: right),
    ]);
  });
}

InputDecoration placeFormInputDecoration(String label, IconData icon,
    {String? hint}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    hintStyle: const TextStyle(fontSize: 12, color: Color(0xFFCBD5E1)),
    labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
    prefixIcon: Icon(icon, size: 17, color: const Color(0xFF94A3B8)),
    isDense: true,
    contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
    filled: true,
    fillColor: kPlaceFormBg,
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: kPlaceFormBorder)),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: kPlaceFormBorder)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: kPlaceFormTeal, width: 2)),
    errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFEF4444))),
    focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2)),
  );
}

Widget placeFormField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  String? hint,
  int maxLines = 1,
  String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: controller,
    maxLines: maxLines,
    decoration: placeFormInputDecoration(label, icon, hint: hint),
    validator: validator,
    style: const TextStyle(fontSize: 13),
  );
}

Widget placeFormTypeDropdown({
  required String value,
  required String label,
  required IconData icon,
  required List<String> items,
  required void Function(String?) onChanged,
}) {
  return DropdownButtonFormField<String>(
    value: value,
    decoration: placeFormInputDecoration(label, icon),
    style: const TextStyle(fontSize: 13, color: Colors.black87),
    items: items
        .map((t) => DropdownMenuItem(value: t, child: Text(Place.tiposLabels[t] ?? t)))
        .toList(),
    onChanged: onChanged,
  );
}
