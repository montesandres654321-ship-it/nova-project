// lib/pages/admins/dialogs/edit_admin_dialog.dart
// Extraído de list_tab.dart (_editAdmin) sin cambios de comportamiento.
// CORREGIDO: usa PATCH /admin/users/:id.
import 'package:flutter/material.dart';
import '../../../models/admin_stats_model.dart';
import '../../../services/admin_service.dart';
import '../../../utils/app_theme.dart';

void showEditAdminDialog(
    BuildContext context, AdminStats a, VoidCallback onSuccess) {
  final firstCtrl = TextEditingController(text: a.admin.firstName);
  final lastCtrl  = TextEditingController(text: a.admin.lastName);
  final phoneCtrl = TextEditingController(text: a.admin.phone ?? '');

  showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
          title: Row(children: [
            const Icon(Icons.edit, color: AppTheme.primary),
            const SizedBox(width: 10),
            Expanded(child: Text('Editar — ${a.admin.displayName}',
                style: const TextStyle(fontSize: 16))),
          ]),
          content: SizedBox(width: 400, child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(children: [
                  Expanded(child: TextField(
                      controller: firstCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Nombre',
                          border: OutlineInputBorder(),
                          isDense: true))),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(
                      controller: lastCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Apellido',
                          border: OutlineInputBorder(),
                          isDense: true))),
                ]),
                const SizedBox(height: 12),
                TextField(
                    controller: phoneCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Teléfono',
                        border: OutlineInputBorder(),
                        isDense: true)),
              ])),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar')),
            ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  final result = await AdminService.updateUser(
                    userId:    a.admin.id,
                    firstName: firstCtrl.text.trim(),
                    lastName:  lastCtrl.text.trim(),
                    phone:     phoneCtrl.text.trim().isEmpty
                        ? null : phoneCtrl.text.trim(),
                  );
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(result['success'] == true
                          ? 'Usuario actualizado correctamente'
                          : result['error'] ?? 'Error al actualizar'),
                      backgroundColor: result['success'] == true
                          ? Colors.green : Colors.red));
                  if (result['success'] == true) onSuccess();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                child: const Text('Guardar')),
          ]));
}
