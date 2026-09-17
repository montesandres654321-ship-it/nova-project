// lib/pages/mobile_users/widgets/mobile_user_card.dart
// Extraído de list_tab.dart (_buildUserCard) sin cambios de comportamiento
// ni de estilo.
import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../../utils/app_theme.dart';

class MobileUserCard extends StatelessWidget {
  final UserModel user;
  final bool canEdit;
  final VoidCallback onToggleStatus;
  final VoidCallback onTap;

  const MobileUserCard({
    super.key,
    required this.user,
    required this.canEdit,
    required this.onToggleStatus,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: user.isActive
              ? AppTheme.success.withOpacity(0.2)
              : AppTheme.gray300,
          child: Icon(
            user.isGoogleUser ? Icons.g_mobiledata : Icons.person,
            color: user.isActive ? AppTheme.success : AppTheme.gray600,
          ),
        ),
        title: Text(
          user.displayName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: user.isActive ? AppTheme.gray900 : AppTheme.gray500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: user.isActive
                        ? AppTheme.success.withOpacity(0.1)
                        : AppTheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  ),
                  child: Text(
                    user.isActive ? 'Activo' : 'Inactivo',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: user.isActive ? AppTheme.success : AppTheme.error,
                    ),
                  ),
                ),
                if (user.isGoogleUser) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                    ),
                    child: const Text(
                      'Google',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.info,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: canEdit
            ? PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'toggle') {
              onToggleStatus();
            } else if (value == 'detail') {
              onTap();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'detail',
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20),
                  SizedBox(width: 8),
                  Text('Ver detalle'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'toggle',
              child: Row(
                children: [
                  Icon(
                    user.isActive ? Icons.block : Icons.check_circle,
                    size: 20,
                    color: user.isActive ? AppTheme.error : AppTheme.success,
                  ),
                  const SizedBox(width: 8),
                  Text(user.isActive ? 'Desactivar' : 'Activar'),
                ],
              ),
            ),
          ],
        )
            : null,
        onTap: onTap,
      ),
    );
  }
}
