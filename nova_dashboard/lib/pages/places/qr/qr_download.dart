// lib/pages/places/qr/qr_download.dart
// Extraído de qr_dialog.dart (_downloadQR/_openInNewTab) sin cambios de
// comportamiento.
// FIX: Descarga real — fetch la imagen y crear blob para download
// ignore: avoid_web_libraries_in_flutter
import 'package:nova_dashboard/utils/app_theme.dart';
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../models/place.dart';
import 'qr_type_style.dart';

Future<void> downloadQrImage(BuildContext context, Place place) async {
  try {
    if (kIsWeb) {
      // Mostrar indicador de descarga
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preparando descarga...'),
            backgroundColor: AppTheme.primary,
            duration: Duration(seconds: 1),
          ),
        );
      }

      // Fetch la imagen como bytes
      final response = await http.get(Uri.parse(qrImageUrl(place)));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final blob = html.Blob([bytes], 'image/png');
        final url = html.Url.createObjectUrlFromBlob(blob);

        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'QR_${place.name.replaceAll(' ', '_')}_${place.tipo}.png')
          ..style.display = 'none';

        html.document.body?.append(anchor);
        anchor.click();

        // Limpiar
        Future.delayed(const Duration(milliseconds: 100), () {
          anchor.remove();
          html.Url.revokeObjectUrl(url);
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ QR de "${place.name}" descargado'),
              backgroundColor: AppTheme.success,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        throw Exception('Error al descargar imagen: ${response.statusCode}');
      }
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al descargar: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }
}

void openQrInNewTab(Place place) {
  if (kIsWeb) {
    html.window.open(qrImageUrl(place), '_blank');
  }
}
