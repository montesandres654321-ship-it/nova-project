// lib/pages/places/qr/qr_image_card.dart
// Extraído de qr_dialog.dart (contenedor del QR + chip de código) sin
// cambios de comportamiento ni de estilo.
import 'package:flutter/material.dart';
import '../../../models/place.dart';
import 'qr_type_style.dart';

Widget qrImageCard(Place place) {
  final typeColor = qrTypeColor(place);
  final typeLightColor = qrTypeLightColor(place);
  final data = qrData(place);
  final imageUrl = qrImageUrl(place);

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: typeColor.withOpacity(0.25), width: 2),
      boxShadow: [
        BoxShadow(
          color: typeColor.withOpacity(0.08),
          spreadRadius: 2,
          blurRadius: 12,
        ),
      ],
    ),
    child: Column(children: [
      // Imagen del QR
      ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          imageUrl,
          width: 260,
          height: 260,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return SizedBox(
              width: 260, height: 260,
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                      : null,
                  color: typeColor,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stack) => Container(
            width: 260, height: 260,
            color: Colors.grey[100],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code, size: 60, color: Colors.grey[400]),
                const SizedBox(height: 8),
                Text('Error al cargar QR',
                    style: TextStyle(color: Colors.grey[500])),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(height: 12),

      // Código con color del tipo
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: typeLightColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.qr_code_2, size: 16, color: typeColor),
            const SizedBox(width: 6),
            Text(
              data,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: typeColor,
              ),
            ),
          ],
        ),
      ),
    ]),
  );
}
