// lib/pages/admins/widgets/admin_form_fields.dart
// Helpers de formulario compartidos por los diálogos de admins/.
import 'package:flutter/material.dart';
import '../admin_tokens.dart';

InputDecoration adminInputDecoration({Widget? suffix}) => InputDecoration(
  isDense: true,
  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
  filled: true,
  fillColor: Colors.white,
  suffixIcon: suffix,
  border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(9),
      borderSide: const BorderSide(color: kAdminBorder)),
  enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(9),
      borderSide: const BorderSide(color: kAdminBorder)),
  focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(9),
      borderSide: const BorderSide(color: kAdminPrimary, width: 1.5)),
  errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(9),
      borderSide: const BorderSide(color: kAdminRed)),
  focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(9),
      borderSide: const BorderSide(color: kAdminRed, width: 1.5)),
);

Widget adminLabelField(String label, Widget child) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(label,
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: kAdminTextMuted)),
    const SizedBox(height: 4),
    child,
  ],
);

Widget adminTextField({
  required String label,
  required TextEditingController ctrl,
  bool obscureText = false,
  Widget? suffix,
  TextInputType? keyboard,
  String? Function(String?)? validator,
}) => adminLabelField(label, TextFormField(
  controller: ctrl,
  obscureText: obscureText,
  keyboardType: keyboard,
  style: const TextStyle(fontSize: 13, color: kAdminTextHead),
  decoration: adminInputDecoration(suffix: suffix),
  validator: validator,
));

Widget adminFormRow2(Widget a, Widget b) => Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Expanded(child: a),
    const SizedBox(width: 10),
    Expanded(child: b),
  ],
);

Widget adminSectionDivider(String text) => Padding(
  padding: const EdgeInsets.only(bottom: 8),
  child: Row(children: [
    Container(width: 3, height: 12,
        decoration: BoxDecoration(
            color: kAdminPrimary,
            borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 7),
    Text(text,
        style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: kAdminTextMuted,
            letterSpacing: 0.6)),
  ]),
);
