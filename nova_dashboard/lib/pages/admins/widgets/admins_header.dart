// lib/pages/admins/widgets/admins_header.dart
// Header compacto de AdminsListTab: título + acciones, búsqueda/filtro y KPIs.
// Extraído de list_tab.dart sin cambios de comportamiento ni de estilo.
import 'package:flutter/material.dart';
import '../admin_tokens.dart';

class AdminsHeader extends StatelessWidget {
  final bool canEdit;
  final int total;
  final int admins;
  final int generals;
  final int owners;
  final int filteredCount;
  final String filterRole;
  final VoidCallback onCreateUser;
  final VoidCallback onRefresh;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onFilterChanged;

  const AdminsHeader({
    Key? key,
    required this.canEdit,
    required this.total,
    required this.admins,
    required this.generals,
    required this.owners,
    required this.filteredCount,
    required this.filterRole,
    required this.onCreateUser,
    required this.onRefresh,
    required this.onSearchChanged,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('Administradores',
              style: TextStyle(fontSize: 18,
                  fontWeight: FontWeight.w700, color: kAdminTextHead)),
          const Spacer(),
          if (canEdit) ...[
            ElevatedButton.icon(
              onPressed: onCreateUser,
              icon: const Icon(Icons.person_add_rounded, size: 15),
              label: const Text('Crear usuario',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: kAdminPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 9),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 6),
          ],
          SizedBox(
            width: 32, height: 32,
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded,
                  size: 18, color: kAdminTextMuted),
              onPressed: onRefresh,
              tooltip: 'Actualizar',
              padding: EdgeInsets.zero,
            ),
          ),
        ]),

        const SizedBox(height: 10),

        Row(children: [
          Expanded(
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                color: kAdminBgPage,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kAdminBorder),
              ),
              child: TextField(
                style: const TextStyle(fontSize: 13, color: kAdminTextHead),
                decoration: const InputDecoration(
                  hintText: 'Buscar por nombre, email o lugar...',
                  hintStyle: TextStyle(fontSize: 13, color: kAdminTextSub),
                  prefixIcon: Icon(Icons.search_rounded,
                      size: 17, color: kAdminTextSub),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
                onChanged: onSearchChanged,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: kAdminBgPage,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kAdminBorder),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: filterRole,
                isDense: true,
                icon: const Icon(Icons.expand_more_rounded,
                    size: 16, color: kAdminTextMuted),
                style: const TextStyle(
                    fontSize: 12, color: kAdminTextHead),
                items: const [
                  DropdownMenuItem(
                      value: 'all',
                      child: Text('Todos los roles')),
                  DropdownMenuItem(
                      value: 'admin_general',
                      child: Text('👑 Admin General')),
                  DropdownMenuItem(
                      value: 'user_general',
                      child: Text('📋 Secretaría')),
                  DropdownMenuItem(
                      value: 'user_place',
                      child: Text('🏪 Propietarios')),
                ],
                onChanged: (v) {
                  if (v != null) onFilterChanged(v);
                },
              ),
            ),
          ),
        ]),

        const SizedBox(height: 10),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            _kpiChip('Total', total, kAdminBlue),
            _kpiSep(),
            _kpiChip('Admins', admins, kAdminPurple),
            _kpiSep(),
            _kpiChip('Secretaría', generals, kAdminPrimary),
            _kpiSep(),
            _kpiChip('Propietarios', owners, kAdminAmber),
            if (filteredCount != total) ...[
              _kpiSep(),
              _kpiChip('Filtrados', filteredCount, kAdminTextMuted),
            ],
          ]),
        ),
      ]),
    );
  }

  Widget _kpiChip(String label, int value, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.2)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 6, height: 6,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 6),
      Text('$value ',
          style: TextStyle(fontSize: 13,
              fontWeight: FontWeight.w700, color: color)),
      Text(label,
          style: TextStyle(fontSize: 12,
              color: color.withOpacity(0.85))),
    ]),
  );

  Widget _kpiSep() => Container(
    width: 1, height: 16, color: kAdminBorder,
    margin: const EdgeInsets.symmetric(horizontal: 8),
  );
}
