// lib/pages/mobile_users/list_tab.dart
// REFACTOR: toolbar y tarjeta de usuario extraídas a
// lib/pages/mobile_users/widgets/ para bajar de 463 a <300 líneas.

import 'package:flutter/material.dart';
import 'package:nova_dashboard/services/admin_service.dart';
import 'package:nova_dashboard/models/user_model.dart';
import 'package:nova_dashboard/utils/app_theme.dart';
import 'package:nova_dashboard/pages/user_detail_page.dart';
import 'widgets/mobile_user_card.dart';
import 'widgets/mobile_users_toolbar.dart';

class MobileUsersListTab extends StatefulWidget {
  final bool canEdit;

  const MobileUsersListTab({
    super.key,
    required this.canEdit,
  });

  @override
  State<MobileUsersListTab> createState() => _MobileUsersListTabState();
}

class _MobileUsersListTabState extends State<MobileUsersListTab> {
  List<UserModel> _users = [];
  List<UserModel> _filteredUsers = [];
  bool _loading = true;
  String _error = '';
  String _searchQuery = '';
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      setState(() {
        _loading = true;
        _error = '';
      });

      // ✅ CORRECCIÓN: Usar instancia en lugar de método estático
      final response = await AdminService.getAllUsers();

      if (response['success'] == true) {
        final usersData = response['users'];
        if (usersData != null && usersData is List) {
          final users = usersData
              .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
              .toList();

          if (mounted) {
            setState(() {
              _users = users;
              _applyFilters();
              _loading = false;
            });
          }
        } else {
          throw Exception('Formato de datos inválido');
        }
      } else {
        throw Exception(response['error']?.toString() ?? 'Error al cargar usuarios');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al cargar usuarios: $e';
          _loading = false;
        });
      }
    }
  }

  void _applyFilters() {
    var filtered = _users;

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((user) {
        return user.email.toLowerCase().contains(query) ||
            user.username.toLowerCase().contains(query) ||
            (user.firstName?.toLowerCase().contains(query) ?? false) ||
            (user.lastName?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    if (_filterStatus == 'active') {
      filtered = filtered.where((u) => u.isActive).toList();
    } else if (_filterStatus == 'inactive') {
      filtered = filtered.where((u) => !u.isActive).toList();
    }

    setState(() {
      _filteredUsers = filtered;
    });
  }

  Future<void> _toggleUserStatus(UserModel user) async {
    if (!widget.canEdit) {
      _showError('No tienes permisos para editar usuarios');
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.isActive ? 'Desactivar Usuario' : 'Activar Usuario'),
        content: Text(
          user.isActive
              ? '¿Desactivar a ${user.displayName}? No podrá acceder al sistema.'
              : '¿Activar a ${user.displayName}? Podrá acceder nuevamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: user.isActive ? AppTheme.error : AppTheme.success,
            ),
            child: Text(user.isActive ? 'Desactivar' : 'Activar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // ✅ CORRECCIÓN: Usar instancia en lugar de método estático
        final result = await AdminService.toggleUserStatus(user.id);

        if (result['success'] == true) {
          if (mounted) {
            _showSuccess(result['message'] ?? 'Estado actualizado');
            _loadUsers();
          }
        } else {
          throw Exception(result['error'] ?? 'Error al cambiar estado');
        }
      } catch (e) {
        if (mounted) {
          _showError('Error: $e');
        }
      }
    }
  }

  void _navigateToUserDetail(UserModel user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserDetailPage(userId: user.id),
      ),
    ).then((_) {
      _loadUsers();
    });
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.success),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _users.length;
    final active = _users.where((u) => u.isActive).length;
    final inactive = total - active;

    return Column(
      children: [
        MobileUsersToolbar(
          searchQuery: _searchQuery,
          filterStatus: _filterStatus,
          total: total,
          active: active,
          inactive: inactive,
          onSearchChanged: (v) {
            setState(() => _searchQuery = v);
            _applyFilters();
          },
          onFilterChanged: (v) {
            setState(() => _filterStatus = v);
            _applyFilters();
          },
          onRefresh: _loadUsers,
        ),
        const Divider(height: 1),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error.isNotEmpty
              ? _buildErrorView()
              : _filteredUsers.isEmpty
              ? _buildEmptyView()
              : _buildUsersList(),
        ),
      ],
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: AppTheme.error),
          const SizedBox(height: AppTheme.spaceMD),
          Text(_error, textAlign: TextAlign.center),
          const SizedBox(height: AppTheme.spaceMD),
          ElevatedButton(
            onPressed: _loadUsers,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: AppTheme.gray400),
          const SizedBox(height: AppTheme.spaceMD),
          Text(
            _searchQuery.isNotEmpty
                ? 'No se encontraron usuarios'
                : 'No hay usuarios registrados',
            style: const TextStyle(fontSize: 16, color: AppTheme.gray600),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    return ListView.separated(
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      itemCount: _filteredUsers.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppTheme.spaceSM),
      itemBuilder: (context, index) {
        final user = _filteredUsers[index];
        return MobileUserCard(
          user: user,
          canEdit: widget.canEdit,
          onToggleStatus: () => _toggleUserStatus(user),
          onTap: () => _navigateToUserDetail(user),
        );
      },
    );
  }
}
