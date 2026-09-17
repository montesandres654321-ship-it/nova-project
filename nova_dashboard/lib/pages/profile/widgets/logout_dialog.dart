// lib/pages/profile/widgets/logout_dialog.dart
// Extraído de profile_page.dart (_LogoutDialog) sin cambios de
// comportamiento ni de estilo.
import 'package:flutter/material.dart';
import '../profile_tokens.dart';

class LogoutDialog extends StatelessWidget {
  final Future<void> Function() onConfirm;
  const LogoutDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) => Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(mainAxisSize: MainAxisSize.min, children: [

        // Icono
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.logout_rounded,
              color: kProfileRed, size: 30),
        ),
        const SizedBox(height: 18),

        const Text('¿Cerrar sesión?',
            style: TextStyle(fontSize: 18,
                fontWeight: FontWeight.w800, color: kProfileTextHead)),
        const SizedBox(height: 8),
        const Text(
          'Se cerrará tu sesión actual y\ndeberás volver a iniciar sesión.',
          style: TextStyle(fontSize: 13,
              color: kProfileTextMuted, height: 1.55),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 26),

        Row(children: [
          Expanded(child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: kProfileTextMuted,
              side: const BorderSide(color: kProfileBorder),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 13),
            ),
            child: const Text('Cancelar',
                style: TextStyle(fontSize: 13,
                    fontWeight: FontWeight.w500)),
          )),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kProfileRed,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 13),
            ),
            child: const Text('Salir',
                style: TextStyle(fontSize: 13,
                    fontWeight: FontWeight.w600)),
          )),
        ]),
      ]),
    ),
  );
}
