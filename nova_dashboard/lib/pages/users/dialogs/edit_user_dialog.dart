// lib/pages/users/dialogs/edit_user_dialog.dart
// Extraído de users_page.dart (_editUser) sin cambios de comportamiento.
// Campos editables: nombre, apellido, teléfono. NO: email, username, rol.
import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../../services/admin_service.dart';
import '../../../utils/app_theme.dart';

void showEditUserDialog(
    BuildContext context, UserModel user, VoidCallback onSuccess) {
  final firstCtrl = TextEditingController(text: user.firstName ?? '');
  final lastCtrl  = TextEditingController(text: user.lastName  ?? '');
  final phoneCtrl = TextEditingController(text: user.phone     ?? '');

  showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
          title: Row(children: [
            const Icon(Icons.edit, color: AppTheme.primary),
            const SizedBox(width: 10),
            Expanded(child: Text('Editar — ${user.displayName}',
                style: const TextStyle(fontSize: 16))),
          ]),
          content: SizedBox(width: 380, child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LayoutBuilder(builder: (ctx, constraints) {
                  final isMobile = constraints.maxWidth < 500;
                  if (isMobile) {
                    return Column(children: [
                      TextField(
                          controller: firstCtrl,
                          decoration: const InputDecoration(
                              labelText: 'Nombre',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                              isDense: true)),
                      const SizedBox(height: 12),
                      TextField(
                          controller: lastCtrl,
                          decoration: const InputDecoration(
                              labelText: 'Apellido',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person_outline),
                              isDense: true)),
                    ]);
                  }
                  return Row(children: [
                    Expanded(child: TextField(
                        controller: firstCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Nombre',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                            isDense: true))),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(
                        controller: lastCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Apellido',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person_outline),
                            isDense: true))),
                  ]);
                }),
                const SizedBox(height: 12),
                TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                        labelText: 'Teléfono',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                        isDense: true)),
              ])),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar')),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                onPressed: () async {
                  Navigator.pop(ctx);
                  final result = await AdminService.updateUser(
                    userId:    user.id,
                    firstName: firstCtrl.text.trim(),
                    lastName:  lastCtrl.text.trim(),
                    phone:     phoneCtrl.text.trim().isEmpty
                        ? null : phoneCtrl.text.trim(),
                  );
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(result['success'] == true
                          ? 'Turista actualizado correctamente'
                          : result['error'] ?? 'Error al actualizar'),
                      backgroundColor: result['success'] == true
                          ? AppTheme.success : AppTheme.error));
                  if (result['success'] == true) onSuccess();
                },
                child: const Text('Guardar')),
          ]));
}
