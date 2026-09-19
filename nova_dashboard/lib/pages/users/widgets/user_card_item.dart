// lib/pages/users/widgets/user_card_item.dart
// Extraído de users_page.dart (_UserCardItem/_UserCardItemState) sin
// cambios de comportamiento ni de estilo.
import 'package:nova_dashboard/utils/app_theme.dart';
import 'package:flutter/material.dart';
import '../../../models/user_model.dart';

class UserCardItem extends StatefulWidget {
  final UserModel user;
  final String? currentRole;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onToggle;

  const UserCardItem({
    super.key,
    required this.user,
    required this.currentRole,
    required this.onTap,
    required this.onEdit,
    required this.onToggle,
  });

  @override
  State<UserCardItem> createState() => _UserCardItemState();
}

class _UserCardItemState extends State<UserCardItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: _hovered ? const Color(0xFFF0FDFA) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hovered
                  ? AppTheme.primary.withOpacity(0.35)
                  : const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_hovered ? 0.08 : 0.04),
                blurRadius: _hovered ? 14 : 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              // Avatar
              CircleAvatar(
                radius: 22,
                backgroundColor: user.isActive
                    ? AppTheme.primary.withOpacity(0.12)
                    : Colors.grey.shade200,
                child: Icon(
                    user.isGoogleUser ? Icons.g_mobiledata : Icons.person,
                    color: user.isActive ? AppTheme.primary : Colors.grey,
                    size: 22),
              ),
              const SizedBox(width: 14),

              // Info principal
              Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.displayName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15,
                            color: Color(0xFF111827))),
                    const SizedBox(height: 3),
                    Text(user.email,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 7),
                    Row(children: [
                      // Badge estado
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                              color: user.isActive
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10)),
                          child: Text(
                              user.isActive ? 'Activo' : 'Inactivo',
                              style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w600,
                                  color: user.isActive
                                      ? const Color(0xFF059669)
                                      : Colors.red))),
                      const SizedBox(width: 8),
                      Text('${user.scansCount} escaneos',
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF9CA3AF))),
                      if (user.isGoogleUser) ...[
                        const SizedBox(width: 8),
                        const Text('Google',
                            style: TextStyle(
                                fontSize: 11, color: Color(0xFF9CA3AF))),
                      ],
                    ]),
                  ])),

              // Menú de acciones
              PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  onSelected: (value) {
                    switch (value) {
                      case 'detail': widget.onTap(); break;
                      case 'edit':   widget.onEdit(); break;
                      case 'toggle': widget.onToggle(); break;
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                        value: 'detail',
                        child: Row(children: [
                          Icon(Icons.info_outline, size: 20),
                          SizedBox(width: 8),
                          Text('Ver detalle'),
                        ])),

                    if (widget.currentRole == 'admin_general')
                      const PopupMenuItem(
                          value: 'edit',
                          child: Row(children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ])),

                    PopupMenuItem(
                        value: 'toggle',
                        child: Row(children: [
                          Icon(
                              user.isActive ? Icons.block : Icons.check_circle,
                              size: 20,
                              color: user.isActive ? Colors.red : Colors.green),
                          const SizedBox(width: 8),
                          Text(user.isActive ? 'Desactivar' : 'Activar'),
                        ])),
                  ]),
            ]),
          ),
        ),
      ),
    );
  }
}
