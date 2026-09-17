// lib/pages/places/qr/qr_dialog_actions.dart
// Extraído de qr_dialog.dart (instrucciones + botones) sin cambios de
// comportamiento ni de estilo.
import 'package:flutter/material.dart';
import '../../../models/place.dart';
import 'qr_download.dart';
import 'qr_type_style.dart';

Widget qrInstructions(Place place) {
  final typeColor = qrTypeColor(place);
  final typeLightColor = qrTypeLightColor(place);
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: typeLightColor.withOpacity(0.5),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: typeColor.withOpacity(0.15)),
    ),
    child: Row(children: [
      Icon(Icons.info_outline, size: 16, color: typeColor),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          'Imprime este QR y colócalo en el establecimiento. '
              'Los turistas lo escanean con la app Nova para '
              'acumular puntos y obtener recompensas.',
          style: TextStyle(fontSize: 11, color: Colors.grey[700]),
        ),
      ),
    ]),
  );
}

Widget qrActionButtons(BuildContext context, Place place) {
  final typeColor = qrTypeColor(place);
  return Row(children: [
    Expanded(
      child: OutlinedButton.icon(
        onPressed: () => openQrInNewTab(place),
        icon: const Icon(Icons.open_in_new, size: 18),
        label: const Text('Abrir'),
        style: OutlinedButton.styleFrom(
          foregroundColor: typeColor,
          side: BorderSide(color: typeColor),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    ),
    const SizedBox(width: 12),
    Expanded(
      flex: 2,
      child: ElevatedButton.icon(
        onPressed: () => downloadQrImage(context, place),
        icon: const Icon(Icons.download, size: 18),
        label: const Text('Descargar PNG'),
        style: ElevatedButton.styleFrom(
          backgroundColor: typeColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    ),
  ]);
}
