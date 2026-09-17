// lib/pages/places/qr_dialog.dart
// ============================================================
// MEJORAS:
//   1. QR personalizado por tipo (colores diferentes para hotel/restaurant/bar)
//   2. Descarga real al PC — usa fetch + blob en vez de abrir pestaña
//   3. Diseño mejorado con colores del tipo de lugar
// REFACTOR: estilos por tipo, descarga y secciones del diálogo extraídas
// a lib/pages/places/qr/ para bajar de 325 a <300 líneas.
// ============================================================
import 'package:flutter/material.dart';
import '../../models/place.dart';
import 'qr/qr_dialog_actions.dart';
import 'qr/qr_dialog_header.dart';
import 'qr/qr_image_card.dart';

class QRDialog extends StatelessWidget {
  final Place place;

  const QRDialog({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 440,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            qrDialogHeader(context, place),
            const SizedBox(height: 16),
            qrImageCard(place),
            const SizedBox(height: 16),
            qrInstructions(place),
            const SizedBox(height: 20),
            qrActionButtons(context, place),
          ],
        ),
      ),
    );
  }
}
