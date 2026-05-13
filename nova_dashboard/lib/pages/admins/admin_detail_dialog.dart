// lib/pages/admins/admin_detail_dialog.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/admin_stats_model.dart';
import '../../models/admin_model.dart';

// ── Design tokens (consistentes con el resto del dashboard) ───
const _kPrimary   = Color(0xFF06B6A4);
const _kTextHead  = Color(0xFF0F172A);
const _kTextMuted = Color(0xFF64748B);
const _kTextSub   = Color(0xFF94A3B8);
const _kBorder    = Color(0xFFE2E8F0);
const _kBgCard    = Color(0xFFF8FAFC);
const _kGreen     = Color(0xFF10B981);
const _kRed       = Color(0xFFEF4444);
const _kBlue      = Color(0xFF3B82F6);
const _kAmber     = Color(0xFFF59E0B);

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
                          child: _buildLeftCol(admin),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 4,
                          child: _buildRightCol(admin, hasActivity),
                        ),
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLeftCol(admin),
                      const SizedBox(height: 10),
                      _buildRightCol(admin, hasActivity),
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
        border: Border(bottom: BorderSide(color: _kBorder, width: 0.5)),
      ),
      child: Row(children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            color: _kPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Icon(Icons.person_rounded, size: 17, color: _kPrimary),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Detalle del Administrador',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700, color: _kTextHead)),
            Text(admin.displayName,
                style: const TextStyle(fontSize: 11, color: _kTextSub),
                overflow: TextOverflow.ellipsis),
          ]),
        ),
        // Badge de rol en el header para ahorrar espacio en el body
        _roleBadge(admin.roleEmoji, admin.roleLabel),
        const SizedBox(width: 6),
        IconButton(
          icon: const Icon(Icons.close_rounded, size: 19, color: _kTextMuted),
          onPressed: () => Navigator.of(context).pop(),
          padding: EdgeInsets.zero,
        ),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // COLUMNA IZQUIERDA: Información personal + Rol y permisos
  // ─────────────────────────────────────────────────────────────
  Widget _buildLeftCol(AdminModel admin) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _card('INFORMACIÓN PERSONAL', [
        _infoRow('Nombre', admin.displayName),
        _infoRow('Email', admin.email),
        _infoRow('Usuario', '@${admin.username}'),
        if (admin.phone != null && admin.phone!.isNotEmpty)
          _infoRow('Teléfono', admin.phone!),
      ]),
      const SizedBox(height: 10),
      _card('ROL Y PERMISOS', [
        _badgeRow('Rol', _roleBadge(admin.roleEmoji, admin.roleLabel)),
        const SizedBox(height: 8),
        // Estado del USUARIO — separado del estado del lugar
        _badgeRow('Estado',
          _statusBadge(admin.isActive,
            activeText: 'Usuario activo',
            inactiveText: 'Usuario inactivo')),
      ]),
    ]);
  }

  // ─────────────────────────────────────────────────────────────
  // COLUMNA DERECHA: Actividad + Lugar + Estadísticas
  // ─────────────────────────────────────────────────────────────
  Widget _buildRightCol(AdminModel admin, bool hasActivity) {
    final ps = adminStats.placeStats;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (hasActivity) ...[
        _card('ACTIVIDAD', [
          if (admin.createdAt != null)
            _infoRow('Registrado',
                DateFormat('dd/MM/yyyy').format(admin.createdAt!)),
          if (admin.lastLogin != null)
            _infoRow('Último login',
                DateFormat('dd/MM/yyyy HH:mm').format(admin.lastLogin!)),
        ]),
        const SizedBox(height: 10),
      ],

      if (adminStats.hasPlace && ps != null) ...[
        _card('LUGAR ASIGNADO', [
          _infoRow('Nombre', ps.placeName),
          _infoRow('Tipo', ps.typeWithEmoji),
          _infoRow('Ubicación', ps.placeLocation),
          // Estado del LUGAR — solo si el backend lo envía
          if (ps.placeIsActive != null) ...[
            const SizedBox(height: 4),
            _badgeRow('Estado',
              _statusBadge(ps.placeIsActive!,
                activeText: 'Lugar activo',
                inactiveText: 'Lugar inactivo')),
          ],
        ]),
        const SizedBox(height: 10),
        _card('ESTADÍSTICAS', [
          _statRow(Icons.qr_code_scanner_rounded, 'Escaneos',
              ps.totalScans.toString(), _kPrimary),
          const SizedBox(height: 7),
          _statRow(Icons.people_rounded, 'Visitantes únicos',
              ps.uniqueVisitors.toString(), _kBlue),
          const SizedBox(height: 7),
          _statRow(Icons.card_giftcard_rounded, 'Recompensas',
              ps.totalRewards.toString(), _kAmber),
        ]),
      ] else ...[
        _card('LUGAR ASIGNADO', [
          Row(children: [
            const Icon(Icons.store_outlined, size: 14, color: _kTextSub),
            const SizedBox(width: 6),
            Expanded(child: Text(
              admin.role == 'user_place'
                  ? 'Sin lugar asignado aún'
                  : 'No aplica para este rol',
              style: const TextStyle(fontSize: 12, color: _kTextSub),
            )),
          ]),
        ]),
      ],
    ]);
  }

  // ─────────────────────────────────────────────────────────────
  // FOOTER
  // ─────────────────────────────────────────────────────────────
  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _kBorder, width: 0.5)),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: _kTextMuted,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          ),
          child: const Text('Cerrar', style: TextStyle(fontSize: 13)),
        ),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // CARD DE SECCIÓN
  // ─────────────────────────────────────────────────────────────
  Widget _card(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header de sección
        Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          decoration: const BoxDecoration(
            color: _kBgCard,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            border: Border(bottom: BorderSide(color: _kBorder, width: 0.5)),
          ),
          child: Row(children: [
            Container(width: 2, height: 11,
                decoration: BoxDecoration(
                    color: _kPrimary, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 7),
            Text(title,
                style: const TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w700,
                    color: _kTextMuted, letterSpacing: 0.5)),
          ]),
        ),
        // Contenido
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children),
        ),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // ROWS
  // ─────────────────────────────────────────────────────────────
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 76,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 11, color: _kTextSub, fontWeight: FontWeight.w500)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 12, color: _kTextHead, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
              maxLines: 2),
        ),
      ]),
    );
  }

  Widget _badgeRow(String label, Widget badge) {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      SizedBox(
        width: 76,
        child: Text(label,
            style: const TextStyle(
                fontSize: 11, color: _kTextSub, fontWeight: FontWeight.w500)),
      ),
      badge,
    ]);
  }

  Widget _statRow(IconData icon, String label, String value, Color color) {
    return Row(children: [
      Container(
        width: 26, height: 26,
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(icon, size: 13, color: color),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(label,
            style: const TextStyle(fontSize: 11, color: _kTextMuted)),
      ),
      Text(value,
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w700, color: color)),
    ]);
  }

  // ─────────────────────────────────────────────────────────────
  // BADGES
  // ─────────────────────────────────────────────────────────────
  Widget _statusBadge(bool isActive,
      {String activeText = 'Activo', String inactiveText = 'Inactivo'}) {
    final color = isActive ? _kGreen : _kRed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 6, height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(isActive ? activeText : inactiveText,
            style: TextStyle(
                fontSize: 11, color: color,
                fontWeight: FontWeight.w700, letterSpacing: 0.2)),
      ]),
    );
  }

  Widget _roleBadge(String emoji, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _kPrimary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kPrimary.withOpacity(0.2)),
      ),
      child: Text('$emoji $label',
          style: const TextStyle(
              fontSize: 11, color: _kPrimary, fontWeight: FontWeight.w700)),
    );
  }
}
