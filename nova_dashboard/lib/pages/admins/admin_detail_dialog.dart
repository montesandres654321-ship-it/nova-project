// lib/pages/admins/admin_detail_dialog.dart
// REFACTOR: tokens, filas/tarjetas compartidas y las dos columnas de
// contenido extraídas a lib/pages/admins/detail/ para bajar de 371 a
// <300 líneas.
import 'package:flutter/material.dart';
import '../../models/admin_model.dart';
import '../../models/admin_stats_model.dart';
import 'detail/admin_detail_columns.dart';
import 'detail/admin_detail_shared.dart';
import 'detail/admin_detail_tokens.dart';

class AdminDetailDialog extends StatelessWidget {
  final AdminStats adminStats;

  const AdminDetailDialog({
    Key? key,
    required this.adminStats,
  }) : super(key: key);

  // ─────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final admin = adminStats.admin;
    final hasActivity = admin.createdAt != null || admin.lastLogin != null;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 560),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, admin),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: LayoutBuilder(builder: (_, box) {
                  final isWide = box.maxWidth > 460;
                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: adminDetailLeftCol(admin),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 4,
                          child: adminDetailRightCol(admin, adminStats, hasActivity),
                        ),
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      adminDetailLeftCol(admin),
                      const SizedBox(height: 10),
                      adminDetailRightCol(admin, adminStats, hasActivity),
                    ],
                  );
                }),
              ),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // HEADER — compacto, sin avatar gigante
  // ─────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, AdminModel admin) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 14, 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: kAdminDetailBorder, width: 0.5)),
      ),
      child: Row(children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            color: kAdminDetailPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Icon(Icons.person_rounded, size: 17, color: kAdminDetailPrimary),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text(
              'Detalle del Administrador',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kAdminDetailTextHead),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Row(mainAxisSize: MainAxisSize.min, children: [
              adminDetailRoleBadge(admin.roleEmoji, admin.roleLabel),
            ]),
          ]),
        ),
        IconButton(
          icon: const Icon(Icons.close_rounded, size: 19, color: kAdminDetailTextMuted),
          onPressed: () => Navigator.of(context).pop(),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // FOOTER
  // ─────────────────────────────────────────────────────────────
  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: kAdminDetailBorder, width: 0.5)),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: kAdminDetailTextMuted,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          ),
          child: const Text('Cerrar', style: TextStyle(fontSize: 13)),
        ),
      ]),
    );
  }
}
