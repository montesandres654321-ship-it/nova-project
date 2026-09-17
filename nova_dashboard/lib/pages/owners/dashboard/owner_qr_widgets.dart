// lib/pages/owners/dashboard/owner_qr_widgets.dart
// Extraído de owners/dashboard_page.dart (_qrBig/_qrMini) sin cambios de
// comportamiento ni de estilo.
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../models/place.dart';
import '../../../utils/app_theme.dart';
import '../../places/qr_dialog.dart';

Widget ownerQrBig(BuildContext context, Place place) => Container(
    padding: const EdgeInsets.all(AppTheme.space16),
    decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.06), blurRadius: 6)]),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('Código QR',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      const SizedBox(height: AppTheme.space8),
      Expanded(
        child: Center(
          child: QrImageView(
            data: 'PLACE:${place.id}',
            version: QrVersions.auto,
            size: 200,
          ),
        ),
      ),
      Text('PLACE:${place.id}',
          style: const TextStyle(fontFamily: 'monospace', fontSize: 9,
              fontWeight: FontWeight.w700, color: AppTheme.primary)),
      const SizedBox(height: 6),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => showDialog(
              context: context, builder: (_) => QRDialog(place: place)),
          icon: const Icon(Icons.fullscreen_rounded, size: 14),
          label: const Text('Ver QR completo',
              style: TextStyle(fontSize: 11)),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.primary,
            side: const BorderSide(color: AppTheme.primary),
            padding: const EdgeInsets.symmetric(vertical: 6),
          ),
        ),
      ),
    ]));

Widget ownerQrMini(BuildContext context, Place place) => Container(
    width: 100,
    padding: const EdgeInsets.all(AppTheme.space8),
    decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2))),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.network(
          'https://api.qrserver.com/v1/create-qr-code/?size=60x60&data=PLACE:${place.id}&format=png&margin=2',
          width: 60, height: 60, errorBuilder: (_, __, ___) => Container(width: 60, height: 60,
          color: AppTheme.bgPage, child: const Icon(Icons.qr_code, size: 24, color: AppTheme.textMuted)))),
      const SizedBox(height: AppTheme.space4),
      Text('PLACE:${place.id}', style: const TextStyle(fontFamily: 'monospace', fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.primary)),
      const SizedBox(height: AppTheme.space4),
      InkWell(
        onTap: () => showDialog(context: context, builder: (_) => QRDialog(place: place)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppTheme.space4),
          decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(6)),
          child: const Text('Descargar', textAlign: TextAlign.center,
              style: TextStyle(fontSize: 9, color: AppTheme.onPrimary, fontWeight: FontWeight.w600)),
        ),
      ),
    ]));
