// lib/pages/users/widgets/users_header.dart
// Extraído de users_page.dart (_buildPageHeader/_buildIconButton) sin
// cambios de comportamiento ni de estilo.
import 'package:flutter/material.dart';

class UsersPageHeader extends StatelessWidget {
  final VoidCallback onRefresh;
  const UsersPageHeader({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Turistas',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 20, fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A))),
          const SizedBox(height: 2),
          const Text('Gestión de usuarios registrados',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        ]),
        const Spacer(),
        usersIconButton(icon: Icons.refresh_rounded, tooltip: 'Actualizar', onTap: onRefresh),
      ]),
    );
  }
}

Widget usersIconButton({required IconData icon, required String tooltip, required VoidCallback onTap}) {
  return Tooltip(
    message: tooltip,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF64748B)),
      ),
    ),
  );
}
