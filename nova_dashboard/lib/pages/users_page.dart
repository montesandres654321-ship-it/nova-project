// lib/pages/users_page.dart
// CAMBIOS:
//  1. Import UserDetailPage descomentado
//  2. Navegación real a UserDetailPage en onTap y case 'detail'
//  3. Case 'edit' implementado — diálogo nombre/apellido/teléfono
//     llama PATCH /admin/users/:id (nuevo endpoint backend)
//  4. PopupMenuItem 'change-role' y _showChangeRoleDialog() eliminados
//  5. Texto del diálogo de desactivar corregido — menciona "app Nova"
// REFACTOR: tarjeta de usuario y diálogos extraídos a lib/pages/users/
// para bajar de 524 a <300 líneas.

import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import '../models/user_model.dart';
import '../widgets/common/pagination_controls.dart';
import 'user_detail_page.dart';
import 'users/dialogs/edit_user_dialog.dart';
import 'users/dialogs/toggle_user_status_dialog.dart';
import 'users/widgets/user_card_item.dart';
import 'users/widgets/users_header.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});
  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  List<UserModel> _users         = [];
  List<UserModel> _filteredUsers = [];
  bool   _loading      = true;
  String _error        = '';
  String _searchQuery  = '';
  String? _currentRole;

  int _currentPage = 1;
  static const int _pageSize = 20;

  List<UserModel> get _pagedUsers {
    final start = (_currentPage - 1) * _pageSize;
    if (start >= _filteredUsers.length) return [];
    return _filteredUsers.skip(start).take(_pageSize).toList();
  }

  int get _totalPages => (_filteredUsers.length / _pageSize).ceil().clamp(1, 999999);

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadCurrentRole();
  }

  Future<void> _loadCurrentRole() async {
    final role = await AdminService.getCurrentRole();
    if (mounted) setState(() => _currentRole = role);
  }

  Future<void> _loadUsers() async {
    setState(() { _loading = true; _error = ''; });
    try {
      final response = await AdminService.getAllUsers();
      if (response['success'] == true) {
        final usersData = response['users'] as List? ?? [];
        final users = usersData
            .whereType<Map<String, dynamic>>()
            .map((j) => UserModel.fromJson(j))
            .toList();
        if (mounted) setState(() {
          _users         = users;
          _filteredUsers = users;
          _currentPage   = 1;
          _loading       = false;
        });
      } else {
        throw Exception(response['error'] ?? 'Error al cargar');
      }
    } catch (e) {
      if (mounted) setState(() { _error = 'Error: $e'; _loading = false; });
    }
  }

  void _filterUsers(String query) {
    setState(() {
      _searchQuery = query;
      _currentPage = 1;
      if (query.isEmpty) {
        _filteredUsers = _users;
      } else {
        final q = query.toLowerCase();
        _filteredUsers = _users.where((u) =>
        u.email.toLowerCase().contains(q)        ||
            u.username.toLowerCase().contains(q)     ||
            (u.firstName ?? '').toLowerCase().contains(q) ||
            (u.lastName  ?? '').toLowerCase().contains(q)).toList();
      }
    });
  }

  void _toggleUserStatus(UserModel user) =>
      showToggleUserStatusDialog(context, user, _loadUsers);

  // Campos editables: nombre, apellido, teléfono. NO: email, username, rol.
  void _editUser(UserModel user) =>
      showEditUserDialog(context, user, _loadUsers);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
          UsersPageHeader(onRefresh: _loadUsers),
          // Barra de búsqueda
          Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                    style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                    decoration: const InputDecoration(
                        hintText: 'Buscar turista...',
                        hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                        prefixIcon: Icon(Icons.search_rounded, size: 18, color: Color(0xFF94A3B8)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 11)),
                    onChanged: _filterUsers),
              )),

          // Contador
          if (!_loading && _error.isEmpty)
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
                child: Row(children: [
                  Text('${_filteredUsers.length} turistas',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w500)),
                  if (_searchQuery.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Text('· filtrando por "$_searchQuery"',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                  ],
                ])),

          // Lista
          Expanded(child: _loading
              ? const Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text('Cargando turistas...'),
              ]))
              : _error.isNotEmpty
              ? Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 56, color: Colors.red),
                const SizedBox(height: 12),
                Text(_error, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                    onPressed: _loadUsers,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF06B6A4)),
                    child: const Text('Reintentar',
                        style: TextStyle(color: Colors.white))),
              ]))
              : _filteredUsers.isEmpty
              ? Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 56, color: Colors.grey[300]),
                const SizedBox(height: 12),
                Text(_searchQuery.isNotEmpty
                    ? 'Sin resultados para "$_searchQuery"'
                    : 'No hay turistas registrados',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500])),
              ]))
              : Column(children: [
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _loadUsers,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemCount: _pagedUsers.length,
                        itemBuilder: (_, i) => _buildUserCard(_pagedUsers[i]),
                      ),
                    ),
                  ),
                  PaginationControls(
                    currentPage: _currentPage,
                    totalPages: _totalPages,
                    onPageChanged: (p) => setState(() => _currentPage = p),
                  ),
                ])),
        ]);
  }

  Widget _buildUserCard(UserModel user) {
    return UserCardItem(
      user: user,
      currentRole: _currentRole,
      // ← Tap abre UserDetailPage
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => UserDetailPage(userId: user.id))),
      // ← Editar solo admin_general
      onEdit: () { if (_currentRole == 'admin_general') _editUser(user); },
      onToggle: () => _toggleUserStatus(user),
    );
  }
}
