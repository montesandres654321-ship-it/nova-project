// lib/pages/dashboard/widgets/dashboard_user_menu.dart
// Extraído de dashboard_page.dart (_buildUserMenu) sin cambios de
// comportamiento ni de estilo.
import 'package:nova_dashboard/utils/app_theme.dart';
import 'package:flutter/material.dart';
import '../../../utils/constants.dart';

const kDashboardTeal = AppTheme.primary;

class DashboardUserMenu extends StatelessWidget {
  final bool compact;
  final String userName;
  final String userEmail;
  final String userRole;
  final VoidCallback onProfile;
  final VoidCallback onChangePassword;
  final VoidCallback onLogout;

  const DashboardUserMenu({
    super.key,
    this.compact = false,
    required this.userName,
    required this.userEmail,
    required this.userRole,
    required this.onProfile,
    required this.onChangePassword,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final roleLabel = AppConstants.getRoleLabel(userRole);
    final roleEmoji = AppConstants.getRoleEmoji(userRole);

    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 8),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: Colors.white,
            child: Text(
              userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
              style: const TextStyle(
                  color: kDashboardTeal, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          if (!compact) ...[
            const SizedBox(width: 6),
            Flexible(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(userName.split(' ').first,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis, maxLines: 1),
                Text('$roleEmoji $roleLabel',
                    style: const TextStyle(color: Colors.white70, fontSize: 9),
                    overflow: TextOverflow.ellipsis, maxLines: 1),
              ],
            )),
          ],
          const Icon(Icons.arrow_drop_down, color: Colors.white, size: 18),
        ]),
      ),
      itemBuilder: (_) => [
        PopupMenuItem(
          enabled: false,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text(userEmail, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                  color: kDashboardTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12)),
              child: Text('$roleEmoji $roleLabel',
                  style: const TextStyle(fontSize: 10, color: kDashboardTeal)),
            ),
            const Divider(),
          ]),
        ),
        const PopupMenuItem(value: 'profile', child: ListTile(
            leading: Icon(Icons.person_rounded, color: kDashboardTeal),
            title: Text('Mi Perfil'),
            contentPadding: EdgeInsets.zero, dense: true)),
        const PopupMenuItem(value: 'password', child: ListTile(
            leading: Icon(Icons.lock_rounded, color: kDashboardTeal),
            title: Text('Cambiar Contraseña'),
            contentPadding: EdgeInsets.zero, dense: true)),
        const PopupMenuDivider(),
        const PopupMenuItem(value: 'logout', child: ListTile(
            leading: Icon(Icons.logout_rounded, color: Colors.red),
            title: Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
            contentPadding: EdgeInsets.zero, dense: true)),
      ],
      onSelected: (v) {
        switch (v) {
          case 'profile':       onProfile();        break;
          case 'password':      onChangePassword();  break;
          case 'logout':        onLogout();          break;
        }
      },
    );
  }
}
