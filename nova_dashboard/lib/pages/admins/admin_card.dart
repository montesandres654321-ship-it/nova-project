// lib/pages/admins/admin_card.dart
// ============================================================
// REDESIGN: SaaS-style card · franja por rol · context menu
// Callbacks y lógica sin cambios
// REFACTOR: tokens y _StatusBadge movidos a admin_tokens.dart /
// widgets/admin_status_badge.dart para bajar de 310 a <300 líneas.
// ============================================================
import 'package:flutter/material.dart';
import '../../models/admin_stats_model.dart';
import '../../utils/constants.dart';
import 'admin_tokens.dart';
import 'widgets/admin_status_badge.dart';

class AdminCard extends StatelessWidget {
  final AdminStats      adminStats;
  final VoidCallback?   onTapDetail;
  final VoidCallback?   onTapEdit;
  final VoidCallback?   onTapReassign;
  final VoidCallback?   onTapDashboard;
  final VoidCallback?   onTapDeactivate;

  const AdminCard({
    Key? key,
    required this.adminStats,
    this.onTapDetail,
    this.onTapEdit,
    this.onTapReassign,
    this.onTapDashboard,
    this.onTapDeactivate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final admin    = adminStats.admin;
    final hasPlace = adminStats.hasPlace;
    final roleClr  = _roleColor(admin.role);
    final isActive = admin.isActive;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isActive ? kAdminBorder : const Color(0xFFEEF2F7)),
        boxShadow: [
          BoxShadow(
            color: roleClr.withOpacity(isActive ? 0.07 : 0.02),
            blurRadius: 12, offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(isActive ? 0.04 : 0.02),
            blurRadius: 6, offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

            // ── Franja de color por rol ────────────────
            Container(
              width: 4,
              color: roleClr.withOpacity(isActive ? 1.0 : 0.2),
            ),

            // ── Contenido ─────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 6, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Fila superior: avatar + info + menú
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

                      // Avatar con inicial
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: roleClr.withOpacity(isActive ? 0.10 : 0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            admin.firstName.isNotEmpty
                                ? admin.firstName[0].toUpperCase() : 'U',
                            style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700,
                              color: roleClr.withOpacity(isActive ? 1.0 : 0.4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 13),

                      // Nombre + email + rol
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            // Nombre + badge de estado
                            Row(crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                              Expanded(
                                child: Text(admin.displayName,
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: isActive ? kAdminTextHead : kAdminTextSub,
                                        height: 1.2),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              ),
                              const SizedBox(width: 8),
                              AdminStatusBadge(isActive: isActive),
                            ]),

                            const SizedBox(height: 4),

                            // Email
                            Text(admin.email,
                                style: const TextStyle(
                                    fontSize: 12, color: kAdminTextMuted),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),

                            const SizedBox(height: 6),

                            // Chip de rol
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: roleClr.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: roleClr.withOpacity(0.28)),
                              ),
                              child: Text(
                                '${admin.roleEmoji} ${admin.roleLabel}',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: roleClr,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Menú contextual ⋯
                      SizedBox(
                        width: 36,
                        child: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert_rounded,
                              size: 18, color: kAdminTextSub),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                          offset: const Offset(0, 6),
                          onSelected: (action) {
                            switch (action) {
                              case 'detail':     onTapDetail?.call();     break;
                              case 'edit':       onTapEdit?.call();       break;
                              case 'dashboard':  onTapDashboard?.call();  break;
                              case 'reassign':   onTapReassign?.call();   break;
                              case 'deactivate': onTapDeactivate?.call(); break;
                            }
                          },
                          itemBuilder: (_) => [
                            if (onTapDetail != null)
                              _menuItem('detail',
                                  Icons.visibility_outlined, 'Ver detalle',
                                  kAdminTextHead),
                            if (onTapEdit != null)
                              _menuItem('edit',
                                  Icons.edit_outlined, 'Editar', kAdminTextHead),
                            if (onTapDashboard != null)
                              _menuItem('dashboard',
                                  Icons.dashboard_outlined, 'Ver Dashboard',
                                  kAdminBlue),
                            if (hasPlace && onTapReassign != null)
                              _menuItem('reassign',
                                  Icons.swap_horiz_rounded, 'Reasignar lugar',
                                  kAdminAmber),
                            if (onTapDeactivate != null) ...[
                              const PopupMenuDivider(height: 1),
                              _menuItem('deactivate',
                                  Icons.person_off_rounded, 'Desactivar',
                                  kAdminRed),
                            ],
                          ],
                        ),
                      ),
                    ]),

                    // Lugar asignado (si aplica)
                    if (hasPlace && adminStats.placeStats != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: kAdminBgPage,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: kAdminBorder),
                        ),
                        child: Row(children: [
                          Text(adminStats.placeStats!.typeWithEmoji,
                              style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(adminStats.placeStats!.placeName,
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600,
                                    color: kAdminTextHead),
                                overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(width: 8),
                          Text('📱 ${adminStats.placeStats!.totalScans}',
                              style: const TextStyle(
                                  fontSize: 11, color: kAdminTextMuted)),
                          const SizedBox(width: 8),
                          Text('🎁 ${adminStats.placeStats!.totalRewards}',
                              style: const TextStyle(
                                  fontSize: 11, color: kAdminTextMuted)),
                        ]),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  PopupMenuItem<String> _menuItem(
      String value, IconData icon, String label, Color color) =>
    PopupMenuItem<String>(
      value: value,
      height: 42,
      child: Row(children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 10),
        Text(label,
            style: TextStyle(fontSize: 13, color: color,
                fontWeight: FontWeight.w500)),
      ]),
    );

  Color _roleColor(String role) {
    switch (role) {
      case AppConstants.roleAdminGeneral: return kAdminPurple;
      case AppConstants.roleUserGeneral:  return kAdminBlue;
      case AppConstants.roleUserPlace:    return kAdminPrimary;
      default:                            return kAdminTextSub;
    }
  }
}
