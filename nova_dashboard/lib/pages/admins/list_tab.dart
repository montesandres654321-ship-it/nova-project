// lib/pages/admins/list_tab.dart
// CAMBIOS:
//  1. Botón "Desactivar" agregado en AdminCard — soft delete
//     llama DELETE /admin/users/:id (nuevo endpoint backend)
//  2. _editAdmin usa PATCH /admin/users/:id (nuevo endpoint)
//     — antes llamaba PUT /users/update/:id que no existía
//  3. Diálogo de desactivación con 2 advertencias claras
//  4. REDESIGN: header compacto · KPI chips · modal SaaS premium
//  5. REFACTOR: header y diálogos extraídos a archivos propios
//     (widgets/admins_header.dart, dialogs/*.dart) para bajar de
//     886 a <300 líneas, sin cambiar comportamiento.

import 'package:flutter/material.dart';
import '../../models/admin_stats_model.dart';
import '../../models/place.dart';
import '../../services/admin_service.dart';
import '../../services/place_service.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/loading_indicator.dart';
import 'admin_card.dart';
import 'admin_detail_dialog.dart';
import 'admin_tokens.dart';
import 'dialogs/create_user_dialog.dart';
import 'dialogs/deactivate_admin_dialog.dart';
import 'dialogs/edit_admin_dialog.dart';
import 'dialogs/reassign_place_dialog.dart';
import 'widgets/admins_header.dart';

class AdminsListTab extends StatefulWidget {
  // canEdit: true = admin_general, false = user_general (solo lectura)
  final bool canEdit;
  const AdminsListTab({Key? key, this.canEdit = true}) : super(key: key);
  @override
  State<AdminsListTab> createState() => _AdminsListTabState();
}

class _AdminsListTabState extends State<AdminsListTab> {
  List<AdminStats> _allAdmins      = [];
  List<AdminStats> _filteredAdmins = [];
  bool    _isLoading  = true;
  String? _error;
  String  _filterRole  = 'all';
  String  _searchQuery = '';

  @override
  void initState() { super.initState(); _loadAdmins(); }

  Future<void> _loadAdmins() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final admins = await AdminService.getUsersWithDetails();
      setState(() { _allAdmins = admins; _applyFilters(); _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  void _applyFilters() {
    var filtered = _allAdmins;
    if (_filterRole != 'all') {
      filtered = filtered.where((a) => a.admin.role == _filterRole).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((a) =>
      a.admin.displayName.toLowerCase().contains(q) ||
          a.admin.email.toLowerCase().contains(q)       ||
          (a.admin.placeName?.toLowerCase().contains(q) ?? false)).toList();
    }
    setState(() => _filteredAdmins = filtered);
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: kAdminBgPage,
      child: Column(children: [
        AdminsHeader(
          canEdit: widget.canEdit,
          total: _allAdmins.length,
          admins: _allAdmins.where((a) => a.admin.role == 'admin_general').length,
          generals: _allAdmins.where((a) => a.admin.role == 'user_general').length,
          owners: _allAdmins.where((a) => a.admin.role == 'user_place').length,
          filteredCount: _filteredAdmins.length,
          filterRole: _filterRole,
          onCreateUser: _showCreateUserDialog,
          onRefresh: _loadAdmins,
          onSearchChanged: (v) { _searchQuery = v; _applyFilters(); },
          onFilterChanged: (v) { setState(() { _filterRole = v; }); _applyFilters(); },
        ),
        const Divider(height: 1, thickness: 0.5, color: kAdminBorder),
        Expanded(child: _buildContent()),
      ]),
    );
  }

  Widget _buildContent() {
    if (_isLoading) return const LoadingIndicator(message: 'Cargando...');
    if (_error != null) return ErrorDisplay(message: _error!, onRetry: _loadAdmins);
    if (_filteredAdmins.isEmpty) {
      return EmptyState(
          icon:    Icons.person_off,
          title:   'No hay administradores',
          message: _searchQuery.isNotEmpty
              ? 'Sin resultados para "$_searchQuery"'
              : 'No hay administradores registrados');
    }
    return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
        itemCount: _filteredAdmins.length,
        itemBuilder: (_, i) => AdminCard(
          adminStats:      _filteredAdmins[i],
          onTapDetail:     widget.canEdit ? () => _showDetail(_filteredAdmins[i]) : null,
          onTapEdit:       widget.canEdit ? () => _editAdmin(_filteredAdmins[i])  : null,
          onTapReassign:   widget.canEdit ? () => _reassignPlace(_filteredAdmins[i]) : null,
          // FIX 5: "Ver Dashboard" solo para propietarios de lugar
          onTapDashboard:  _filteredAdmins[i].admin.role == 'user_place'
              ? () => _viewDashboard(_filteredAdmins[i])
              : null,
          onTapDeactivate: widget.canEdit ? () => _deactivateAdmin(_filteredAdmins[i]) : null,
        ));
  }

  // ── Acciones ───────────────────────────────────────────

  void _showDetail(AdminStats a) {
    showDialog(context: context,
        builder: (_) => AdminDetailDialog(adminStats: a));
  }

  void _viewDashboard(AdminStats a) {
    final placeId = a.admin.placeId;
    if (placeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Este usuario no tiene un lugar asignado'),
          backgroundColor: Colors.orange));
      return;
    }
    Navigator.of(context).pushNamed('/owner-dashboard', arguments: {
      'placeId': placeId, 'userName': a.admin.displayName,
      'userEmail': a.admin.email,
    });
  }

  void _editAdmin(AdminStats a) => showEditAdminDialog(context, a, _loadAdmins);

  void _reassignPlace(AdminStats a) => showReassignPlaceDialog(context, a, _loadAdmins);

  void _deactivateAdmin(AdminStats a) => showDeactivateAdminDialog(context, a, _loadAdmins);

  void _showCreateUserDialog() async {
    List<Place> places = [];
    try { places = await PlaceService.getAllPlaces(); } catch (_) {}
    if (!mounted) return;
    showDialog(
        context: context, barrierDismissible: false,
        builder: (_) => CreateUserDialog(places: places, onSuccess: _loadAdmins));
  }
}
