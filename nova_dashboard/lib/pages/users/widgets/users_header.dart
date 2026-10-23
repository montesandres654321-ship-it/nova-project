// lib/pages/users/widgets/users_header.dart
// Extraído de users_page.dart (_buildPageHeader/_buildIconButton) sin
// cambios de comportamiento ni de estilo.
import 'package:nova_dashboard/utils/app_theme.dart';
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
                  color: AppTheme.textHead)),
          const SizedBox(height: 2),
          const Text('Gestión de usuarios registrados',
              style: TextStyle(fontSize: 12, color: AppTheme.textBody)),
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
          border: Border.all(color: AppTheme.border),
        ),
        child: const Icon(Icons.refresh_rounded, size: 18, color: AppTheme.textBody),
      ),
    ),
  );
}
