// lib/widgets/terms_checkbox.dart
// ============================================================
// CHECKBOX DE TÉRMINOS Y CONDICIONES — Nova App Móvil
// ============================================================
// Extraído de register_page.dart (FASE 2, PASO 2.2 del refactor).
// Fila reutilizable: checkbox + texto de aceptación.
// ============================================================

import 'package:flutter/material.dart';
import '../core/design/app_colors.dart';

class TermsCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;

  const TermsCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label = 'Acepto los términos y condiciones',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Transform.scale(
          scale: 0.9,
          child: Checkbox(
            value: value,
            onChanged: (v) => onChanged(v ?? false),
            activeColor: AppColors.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}
