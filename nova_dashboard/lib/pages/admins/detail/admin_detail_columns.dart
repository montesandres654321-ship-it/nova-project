// lib/pages/admins/detail/admin_detail_columns.dart
// Extraído de admin_detail_dialog.dart (_buildLeftCol/_buildRightCol) sin
// cambios de comportamiento ni de estilo.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/admin_model.dart';
import '../../../models/admin_stats_model.dart';
import 'admin_detail_shared.dart';
import 'admin_detail_tokens.dart';

Widget adminDetailLeftCol(AdminModel admin) {
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    adminDetailCard('INFORMACIÓN PERSONAL', [
      adminDetailInfoRow('Nombre', admin.displayName),
      adminDetailInfoRow('Email', admin.email),
      adminDetailInfoRow('Usuario', '@${admin.username}'),
      if (admin.phone != null && admin.phone!.isNotEmpty)
        adminDetailInfoRow('Teléfono', admin.phone!),
    ]),
    const SizedBox(height: 10),
    adminDetailCard('ROL Y PERMISOS', [
      adminDetailBadgeRow('Rol', adminDetailRoleBadge(admin.roleEmoji, admin.roleLabel)),
      const SizedBox(height: 8),
      // Estado del USUARIO — separado del estado del lugar
      adminDetailBadgeRow('Estado',
        adminDetailStatusBadge(admin.isActive,
          activeText: 'Usuario activo',
          inactiveText: 'Usuario inactivo')),
    ]),
  ]);
}

Widget adminDetailRightCol(AdminModel admin, AdminStats adminStats, bool hasActivity) {
  final ps = adminStats.placeStats;

  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    if (hasActivity) ...[
      adminDetailCard('ACTIVIDAD', [
        if (admin.createdAt != null)
          adminDetailInfoRow('Registrado',
              DateFormat('dd/MM/yyyy').format(admin.createdAt!)),
        if (admin.lastLogin != null)
          adminDetailInfoRow('Último login',
              DateFormat('dd/MM/yyyy HH:mm').format(admin.lastLogin!)),
      ]),
      const SizedBox(height: 10),
    ],

    if (adminStats.hasPlace && ps != null) ...[
      adminDetailCard('LUGAR ASIGNADO', [
        adminDetailInfoRow('Nombre', ps.placeName),
        adminDetailInfoRow('Tipo', ps.typeWithEmoji),
        adminDetailInfoRow('Ubicación', ps.placeLocation),
        // Estado del LUGAR — solo si el backend lo envía
        if (ps.placeIsActive != null) ...[
          const SizedBox(height: 4),
          adminDetailBadgeRow('Estado',
            adminDetailStatusBadge(ps.placeIsActive!,
              activeText: 'Lugar activo',
              inactiveText: 'Lugar inactivo')),
        ],
      ]),
      const SizedBox(height: 10),
      adminDetailCard('ESTADÍSTICAS', [
        adminDetailStatRow(Icons.qr_code_scanner_rounded, 'Escaneos',
            ps.totalScans.toString(), kAdminDetailPrimary),
        const SizedBox(height: 7),
        adminDetailStatRow(Icons.people_rounded, 'Visitantes únicos',
            ps.uniqueVisitors.toString(), kAdminDetailBlue),
        const SizedBox(height: 7),
        adminDetailStatRow(Icons.card_giftcard_rounded, 'Recompensas',
            ps.totalRewards.toString(), kAdminDetailAmber),
      ]),
    ] else ...[
      adminDetailCard('LUGAR ASIGNADO', [
        Row(children: [
          const Icon(Icons.store_outlined, size: 14, color: kAdminDetailTextSub),
          const SizedBox(width: 6),
          Expanded(child: Text(
            admin.role == 'user_place'
                ? 'Sin lugar asignado aún'
                : 'No aplica para este rol',
            style: const TextStyle(fontSize: 12, color: kAdminDetailTextSub),
          )),
        ]),
      ]),
    ],
  ]);
}
