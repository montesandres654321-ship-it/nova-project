// lib/pages/places/qr/qr_dialog_header.dart
// Extraído de qr_dialog.dart (header del diálogo) sin cambios de
// comportamiento ni de estilo.
import 'package:nova_dashboard/utils/app_theme.dart';
import 'package:flutter/material.dart';
import '../../../models/place.dart';
import 'qr_type_style.dart';

Widget qrDialogHeader(BuildContext context, Place place) {
  final typeColor = qrTypeColor(place);
  final typeLightColor = qrTypeLightColor(place);
  return Row(children: [
    Container(
      width: 44, height: 44,
      decoration: BoxDecoration(
        color: typeLightColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: typeColor.withOpacity(0.3)),
      ),
      child: Center(
        child: Text(qrTypeIcon(place), style: const TextStyle(fontSize: 22)),
      ),
    ),
    const SizedBox(width: 12),
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(place.name,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          Text('${place.tipoLabel} · ${place.lugar}',
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.textBody)),
        ],
      ),
    ),
    IconButton(
      icon: const Icon(Icons.close),
      onPressed: () => Navigator.pop(context),
    ),
  ]);
}
