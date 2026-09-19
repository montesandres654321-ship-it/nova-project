// lib/pages/admins/dialogs/deactivate_admin_dialog.dart
// Extraído de list_tab.dart (_deactivateAdmin) sin cambios de comportamiento.
// Soft delete: preserva historial. Con 2 advertencias claras.
import 'package:nova_dashboard/utils/app_theme.dart';
import 'package:flutter/material.dart';
import '../../../models/admin_stats_model.dart';
import '../../../services/admin_service.dart';

Future<void> showDeactivateAdminDialog(
    BuildContext context, AdminStats a, VoidCallback onSuccess) async {
  final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
          title: Row(children: [
            const Icon(Icons.warning_amber_rounded, color: AppTheme.warning),
            const SizedBox(width: 8),
            const Text('Desactivar usuario'),
          ]),
          content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('¿Desactivar a ${a.admin.displayName}?',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.withOpacity(0.3))),
                    child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• Ya no podrá acceder al panel web.',
                              style: TextStyle(fontSize: 13)),
                          SizedBox(height: 4),
                          Text('• Su historial y datos se conservan.',
                              style: TextStyle(fontSize: 13)),
                          SizedBox(height: 4),
                          Text('• Esta acción se puede revertir desde el panel.',
                              style: TextStyle(fontSize: 13)),
                        ])),
              ]),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar')),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.error, foregroundColor: Colors.white),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Desactivar')),
          ]));

  if (confirm != true || !context.mounted) return;

  try {
    // Llama DELETE /admin/users/:id (soft delete en backend)
    final result = await AdminService.deactivateUser(a.admin.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['success'] == true
            ? result['message'] ?? '${a.admin.displayName} desactivado'
            : result['error'] ?? 'Error al desactivar'),
        backgroundColor: result['success'] == true ? AppTheme.success : AppTheme.error));
    if (result['success'] == true) onSuccess();
  } catch (e) {
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'), backgroundColor: AppTheme.error));
  }
}
