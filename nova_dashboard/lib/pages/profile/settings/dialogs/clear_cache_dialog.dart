// lib/pages/profile/settings/dialogs/clear_cache_dialog.dart
// Extraído de settings_page.dart (_clearCache) sin cambios de
// comportamiento ni de estilo.
import 'package:nova_dashboard/utils/app_theme.dart';
import 'package:flutter/material.dart';
import '../settings_tokens.dart';

Future<void> showClearCacheDialog(BuildContext context) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              color: kSettingsRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.cleaning_services_rounded,
                color: kSettingsRed, size: 28),
          ),
          const SizedBox(height: 16),
          const Text('¿Limpiar caché?',
              style: TextStyle(fontSize: 17,
                  fontWeight: FontWeight.w800, color: kSettingsTextHead)),
          const SizedBox(height: 8),
          const Text('Se eliminarán todos los datos temporales.',
              style: TextStyle(fontSize: 13, color: kSettingsTextMuted),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: OutlinedButton(
              onPressed: () => Navigator.pop(context, false),
              style: OutlinedButton.styleFrom(
                foregroundColor: kSettingsTextMuted,
                side: const BorderSide(color: kSettingsBorder),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Cancelar',
                  style: TextStyle(fontSize: 13)),
            )),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: kSettingsRed,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Limpiar',
                  style: TextStyle(fontSize: 13,
                      fontWeight: FontWeight.w600)),
            )),
          ]),
        ]),
      ),
    ),
  );

  if (confirm == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Caché limpiado'),
        backgroundColor: AppTheme.success));
  }
}
