// lib/pages/users/dialogs/toggle_user_status_dialog.dart
// Extraído de users_page.dart (_toggleUserStatus) sin cambios de
// comportamiento.
import 'package:nova_dashboard/utils/app_theme.dart';
import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../../services/admin_service.dart';

Future<void> showToggleUserStatusDialog(
    BuildContext context, UserModel user, VoidCallback onSuccess) async {
  final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
          title: Text(user.isActive ? 'Desactivar Turista' : 'Activar Turista'),
          content: Text(user.isActive
              ? '¿Desactivar a ${user.displayName}?\n\n'
              'No podrá iniciar sesión en la app Nova.\n'
              'Su historial de escaneos y recompensas se conserva.\n'
              'Esta acción se puede revertir.'
              : '¿Activar a ${user.displayName}?\n\n'
              'Podrá volver a usar la app Nova.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar')),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: user.isActive ? AppTheme.error : AppTheme.success),
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(user.isActive ? 'Desactivar' : 'Activar',
                    style: const TextStyle(color: Colors.white))),
          ]));

  if (confirm != true) return;

  try {
    final result = await AdminService.toggleUserStatus(user.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['success'] == true
            ? result['message'] ?? 'Estado actualizado'
            : result['error']   ?? 'Error'),
        backgroundColor: result['success'] == true ? AppTheme.success : AppTheme.error));
    if (result['success'] == true) onSuccess();
  } catch (e) {
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'), backgroundColor: AppTheme.error));
  }
}
