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
    this.label = 'Acepto los Términos de uso y la Política de privacidad de Nova.',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 18,
          height: 18,
          child: Checkbox(
            value: value,
            onChanged: (v) => onChanged(v ?? false),
            side: const BorderSide(color: AppColors.textHint, width: 1.5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5)),
            activeColor: AppColors.bienvenidaVerde,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 19 / 13,
            ),
          ),
        ),
      ],
    );
  }
}
