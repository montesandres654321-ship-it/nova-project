// lib/pages/profile/widgets/profile_danger_card.dart
// Extraído de profile_page.dart (_buildDangerCard) sin cambios de
// comportamiento ni de estilo.
import 'package:flutter/material.dart';
import '../profile_tokens.dart';
import 'profile_shared.dart';

class ProfileDangerCard extends StatelessWidget {
  final VoidCallback onLogout;
  const ProfileDangerCard({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFEE2E2)),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8, offset: const Offset(0, 2),
        )],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
          child: Row(children: [
            Container(
              width: 6, height: 6,
              decoration: const BoxDecoration(
                  color: kProfileRed, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            const Text('Zona de peligro',
                style: TextStyle(fontSize: 13,
                    fontWeight: FontWeight.w700, color: kProfileRed)),
          ]),
        ),
        const Divider(height: 20, thickness: 0.5,
            color: Color(0xFFFEE2E2)),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
          child: profileActionRow(
            icon: Icons.logout_rounded,
            iconColor: kProfileRed,
            title: 'Cerrar sesión',
            subtitle: 'Salir de tu cuenta actual',
            onTap: onLogout,
            isDestructive: true,
          ),
        ),
      ]),
    );
  }
}
