// lib/widgets/place_action_buttons.dart
// ============================================================
// BOTÓN DE ACCIÓN DE DETALLE DE LUGAR — Nova App Móvil
// ============================================================
// Extraído de place_detail_page.dart (FASE 3, PASO 3.3 del refactor).
// El plan mencionaba botones de "compartir" y "favorito", pero esa
// funcionalidad no existe en el código real — solo el botón de
// escanear QR. No se inventan acciones nuevas.
// ============================================================

import 'package:flutter/material.dart';
import '../models/place_type.dart';
import '../pages/scan_page.dart';
import '../core/design/app_colors.dart';
import '../core/design/app_spacing.dart';
import '../core/design/app_radius.dart';

class PlaceActionButtons extends StatelessWidget {
  final PlaceType type;

  const PlaceActionButtons({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ScanPage()),
          ),
          icon: const Icon(Icons.qr_code_scanner_rounded),
          label: Text(type.scanLabel),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
