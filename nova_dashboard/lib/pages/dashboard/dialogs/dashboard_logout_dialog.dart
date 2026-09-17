// lib/pages/dashboard/dialogs/dashboard_logout_dialog.dart
// Extraído de dashboard_page.dart (_confirmLogout) sin cambios de
// comportamiento ni de estilo.
import 'package:flutter/material.dart';

void showDashboardLogoutDialog(BuildContext context, Future<void> Function() onConfirm) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Cerrar sesión'),
      content: const Text('¿Seguro que quieres salir?'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, foregroundColor: Colors.white),
          child: const Text('Salir'),
        ),
      ],
    ),
  );
}
