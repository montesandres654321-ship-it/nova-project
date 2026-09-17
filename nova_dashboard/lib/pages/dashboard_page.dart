// lib/pages/dashboard_page.dart
// TAREA 2: sidebar → TopBar horizontal (desktop) + Drawer (mobile)

/// Scaffold principal del dashboard administrativo NOVA App.
///
/// Gestiona la navegación entre todas las secciones mediante una barra de
/// navegación superior (TopBar) en pantallas desktop y un Drawer con menú
/// lateral en dispositivos móviles.
///
/// **Roles soportados:**
/// - `admin_general`: acceso total — ve todas las secciones incluyendo gestión de admins y turistas
/// - `user_general`: secretaría de turismo — dashboard completo sin gestión de administradores
/// - `user_place`: propietario de establecimiento — redirigido automáticamente a [OwnerDashboardPage]
///
/// El logo del header usa [DashboardLogo] que muestra el ícono de isla
/// tropical con [Image.asset] y fallback automático al ícono del sistema.
///
/// Ver también:
/// - [StatsDashboardPage] para las gráficas de analytics
/// - [RewardsPage] para gestión de recompensas
/// - [ScansPage] para el historial de escaneos
///
/// REFACTOR: logo, topbar, drawer y menú de usuario extraídos a
/// lib/pages/dashboard/ para bajar de 494 a <300 líneas.
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../services/admin_service.dart';
import 'stats_dashboard_page.dart';
import 'places/list_tab.dart';
import 'admins/list_tab.dart';
import 'users_page.dart';
import 'rewards_page.dart';
import 'reports_page.dart';
import 'profile/profile_page.dart';
import 'profile/change_password_dialog.dart';
import 'dashboard/dashboard_nav_item.dart';
import 'dashboard/dialogs/dashboard_logout_dialog.dart';
import 'dashboard/widgets/dashboard_desktop_topbar.dart';
import 'dashboard/widgets/dashboard_mobile_shell.dart';
import 'dashboard/widgets/dashboard_user_menu.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int    _selectedIndex     = 0;
  String _userName          = '';
  String _userEmail         = '';
  String _userRole          = '';
  int?   _userId;
  bool   _loaded            = false;
  String _currentPlaceFilter = 'all';

  @override
  void initState() { super.initState(); _init(); }

  Future<void> _init() async {
    final prefs   = await SharedPreferences.getInstance();
    final role    = prefs.getString(AppConstants.keyUserRole)  ?? '';
    final name    = prefs.getString(AppConstants.keyUserName)  ?? 'Usuario';
    final email   = prefs.getString(AppConstants.keyUserEmail) ?? '';
    final placeId = prefs.getInt('placeId');
    final userId  = prefs.getInt(AppConstants.keyUserId);

    if (role == AppConstants.roleUserPlace) {
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/owner-dashboard', (_) => false,
            arguments: {'placeId': placeId, 'userName': name, 'userEmail': email});
      }
      return;
    }

    if (role != AppConstants.roleAdminGeneral && role != AppConstants.roleUserGeneral) {
      await AdminService.logout();
      if (mounted) Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
      return;
    }

    setState(() {
      _userName  = name;
      _userEmail = email;
      _userRole  = role;
      _userId    = userId;
      _loaded    = true;
    });
  }

  bool get _canEdit      => _userRole == AppConstants.roleAdminGeneral;
  bool get _canViewInfo  => _userRole == AppConstants.roleAdminGeneral || _userRole == AppConstants.roleUserGeneral;
  bool get _showAdmins   => _userRole == AppConstants.roleAdminGeneral;

  // ── Índices dinámicos según rol ─────────────────────────────
  int get _placesIndex  => 1;
  // usersIndex solo existe para admin_general (índice 3); -1 = no disponible
  int get _usersIndex   => _showAdmins ? 3 : -1;
  int get _rewardsIndex => _showAdmins ? 4 : 2;
  int get _reportsIndex => _showAdmins ? 5 : 3;

  void _navigateTo(int index) {
    if (index >= 0 && index < _pages.length) setState(() => _selectedIndex = index);
  }

  void _navigateToPlaces(String filter) {
    setState(() { _currentPlaceFilter = filter; _selectedIndex = _placesIndex; });
  }

  // Usado por la TopBar/Drawer: además resetea el filtro de lugares.
  void _selectNavItem(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == _placesIndex) _currentPlaceFilter = 'all';
    });
  }

  // ── Páginas ─────────────────────────────────────────────────
  List<Widget> get _pages => [
    StatsDashboardPage(
      onNavigate:        _navigateTo,
      onNavigateToPlaces: _navigateToPlaces,
      placesIndex:  _placesIndex,
      usersIndex:   _usersIndex,
      rewardsIndex: _rewardsIndex,
      reportsIndex: _reportsIndex,
    ),
    PlacesListTab(
      canEdit: _canEdit, canViewInfo: _canViewInfo,
      initialFilter: _currentPlaceFilter, key: ValueKey(_currentPlaceFilter),
    ),
    if (_showAdmins) AdminsListTab(canEdit: _canEdit),
    if (_showAdmins) const UsersPage(),
    const RewardsPage(),
    const ReportsPage(),
  ];

  // ── Items de nav (mismos para TopBar y Drawer) ──────────────
  List<NavItem> get _navItems => [
    const NavItem(icon: Icons.home_rounded,              label: 'Inicio'),
    const NavItem(icon: Icons.place_rounded,             label: 'Lugares'),
    if (_showAdmins) const NavItem(icon: Icons.admin_panel_settings, label: 'Administradores'),
    if (_showAdmins) const NavItem(icon: Icons.people_rounded,       label: 'Turistas'),
    const NavItem(icon: Icons.card_giftcard_rounded,     label: 'Recompensas'),
    const NavItem(icon: Icons.analytics_rounded,         label: 'Reportes'),
  ];

  // ── BUILD PRINCIPAL ─────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return LayoutBuilder(builder: (_, constraints) {
      final isDesktop = constraints.maxWidth > 900;

      if (isDesktop) {
        return Scaffold(
          appBar: DashboardDesktopTopBar(
            navItems: _navItems,
            selectedIndex: _selectedIndex,
            onSelect: _selectNavItem,
            userMenu: _buildUserMenu(compact: false),
          ),
          body: _pages[_selectedIndex],
        );
      }

      // Mobile: AppBar con hamburguesa + Drawer
      return Scaffold(
        appBar: dashboardMobileAppBar(userMenu: _buildUserMenu(compact: true)),
        drawer: DashboardMobileDrawer(
          navItems: _navItems,
          selectedIndex: _selectedIndex,
          onSelect: _selectNavItem,
        ),
        body: _pages[_selectedIndex],
      );
    });
  }

  Widget _buildUserMenu({bool compact = false}) {
    return DashboardUserMenu(
      compact: compact,
      userName: _userName,
      userEmail: _userEmail,
      userRole: _userRole,
      onProfile: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const ProfilePage())),
      onChangePassword: () {
        if (_userId != null) {
          showDialog(
              context: context,
              builder: (_) => ChangePasswordDialog(userId: _userId!));
        }
      },
      onLogout: _confirmLogout,
    );
  }

  void _confirmLogout() {
    showDashboardLogoutDialog(context, () async {
      await AdminService.logout();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
      }
    });
  }
}
