// lib/pages/admins/dialogs/reassign_place_dialog.dart
// Extraído de list_tab.dart (_reassignPlace) sin cambios de comportamiento.
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import '../../../models/admin_stats_model.dart';
import '../../../models/place.dart';
import '../../../services/admin_service.dart';
import '../../../services/place_service.dart';
import '../../../utils/app_theme.dart';

Future<void> showReassignPlaceDialog(
    BuildContext context, AdminStats a, VoidCallback onSuccess) async {
  if (a.admin.role != 'user_place') {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Solo se puede asignar lugar a propietarios')));
    return;
  }
  List<Place> places = [];
  try { places = await PlaceService.getAllPlaces(); } catch (_) {}
  if (!context.mounted) return;

  Place? selectedPlace = a.admin.placeId != null
      ? places.where((p) => p.id == a.admin.placeId).firstOrNull
      : null;

  showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
          builder: (ctx, setD) => AlertDialog(
              title: Text('Asignar lugar a ${a.admin.displayName}'),
              content: SizedBox(width: 400, child: places.isEmpty
                  ? const Text('No hay lugares disponibles')
                  : DropdownButtonFormField<Place>(
                  value: selectedPlace,
                  hint: const Text('Selecciona un lugar'),
                  items: places.map((p) => DropdownMenuItem(
                      value: p,
                      child: Text('${p.tipoEmoji} ${p.name} — ${p.lugar}',
                          overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (p) => setD(() => selectedPlace = p))),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancelar')),
                ElevatedButton(
                    onPressed: selectedPlace == null ? null : () async {
                      Navigator.pop(ctx);
                      final result = await AdminService.changeUserRole(
                          a.admin.id, 'user_place', placeId: selectedPlace!.id);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(result['success'] == true
                              ? 'Lugar asignado correctamente'
                              : result['error'] ?? 'Error'),
                          backgroundColor: result['success'] == true
                              ? Colors.green : Colors.red));
                      if (result['success'] == true) onSuccess();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                    child: const Text('Asignar')),
              ])));
}
