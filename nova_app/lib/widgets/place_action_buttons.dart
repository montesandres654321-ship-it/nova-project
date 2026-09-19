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
import '../models/place_model.dart';
import '../models/place_type.dart';
import '../pages/scan_page.dart';
import '../core/design/app_colors.dart';
import '../core/design/app_spacing.dart';
import '../core/design/app_radius.dart';

class PlaceActionButtons extends StatelessWidget {
  final Place place;
  final PlaceType type;

  const PlaceActionButtons({super.key, required this.place, required this.type});

  // type.scanLabel solo cubre hotel/restaurant/bar (los 3 valores que
  // conoce PlaceType); para el resto de los 13 tipos de places.tipo
  // (ver BD_SCHEMA.md) se usa un texto genérico en vez de heredar la
  // etiqueta incorrecta del fallback "hotel" de PlaceType.fromTipo.
  String get _scanLabel {
    const tiposConocidos = {'hotel', 'restaurant', 'bar'};
    if (tiposConocidos.contains(place.tipo)) return type.scanLabel;
    return 'Escanear QR de este lugar';
  }

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
          label: Text(_scanLabel),
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
