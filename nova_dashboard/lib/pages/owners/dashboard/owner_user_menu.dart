// lib/pages/owners/dashboard/owner_user_menu.dart
// Extraído de owners/dashboard_page.dart (_buildUserMenu) sin cambios de
// comportamiento ni de estilo.
// FIX 2: usa loggedUserName/loggedUserEmail (del JWT/SharedPreferences),
// no el nombre del propietario del lugar.
import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';
import '../../profile/change_password_dialog.dart';
import '../../profile/profile_page.dart';

Widget ownerUserMenu({
  required BuildContext context,
  required String loggedUserName,
  required String loggedUserEmail,
  required String fallbackUserName,
  required String fallbackUserEmail,
  required int? userId,
  required VoidCallback onLogout,
}) => PopupMenuButton<String>(offset: const Offset(0, 50),
    child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: Row(mainAxisSize: MainAxisSize.min, children: [
      CircleAvatar(radius: 13, backgroundColor: AppTheme.surface,
          child: Text(
            loggedUserName.isNotEmpty ? loggedUserName[0].toUpperCase() : 'U',
            style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 11),
          )),
      const SizedBox(width: AppTheme.space4),
      Text(
        (loggedUserName.isNotEmpty ? loggedUserName : fallbackUserName).split(' ').first,
        style: const TextStyle(color: AppTheme.onPrimary, fontSize: 12),
      ),
      const Icon(Icons.arrow_drop_down, color: AppTheme.onPrimary, size: 18),
    ])),
    itemBuilder: (_) => [
      PopupMenuItem(enabled: false, child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Text(
          loggedUserName.isNotEmpty ? loggedUserName : fallbackUserName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        Text(
          loggedUserEmail.isNotEmpty ? loggedUserEmail : fallbackUserEmail,
          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
        ),
        const Divider(),
      ])),
      const PopupMenuItem(value: 'profile', child: ListTile(leading: Icon(Icons.person_rounded, color: AppTheme.primary), title: Text('Mi Perfil'), contentPadding: EdgeInsets.zero, dense: true)),
      const PopupMenuItem(value: 'password', child: ListTile(leading: Icon(Icons.lock_rounded, color: AppTheme.primary), title: Text('Cambiar Contraseña'), contentPadding: EdgeInsets.zero, dense: true)),
      const PopupMenuItem(value: 'logout', child: ListTile(leading: Icon(Icons.logout_rounded, color: AppTheme.error), title: Text('Cerrar Sesión', style: TextStyle(color: AppTheme.error)), contentPadding: EdgeInsets.zero, dense: true)),
    ],
    onSelected: (v) {
      switch (v) {
        case 'profile': Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfilePage())); break;
        case 'password': if (userId != null) showDialog(context: context, builder: (_) => ChangePasswordDialog(userId: userId)); break;
        case 'logout': onLogout(); break;
      }
    });
