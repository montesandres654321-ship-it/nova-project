// lib/pages/dashboard_page.dart
// TAREA 2: sidebar → TopBar horizontal (desktop) + Drawer (mobile)

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

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const _teal = Color(0xFF06B6A4);

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
  List<_NavItem> get _navItems => [
    _NavItem(icon: Icons.home_rounded,              label: 'Inicio'),
    _NavItem(icon: Icons.place_rounded,             label: 'Lugares'),
    if (_showAdmins) _NavItem(icon: Icons.admin_panel_settings, label: 'Administradores'),
    if (_showAdmins) _NavItem(icon: Icons.people_rounded,       label: 'Turistas'),
    _NavItem(icon: Icons.card_giftcard_rounded,     label: 'Recompensas'),
    _NavItem(icon: Icons.analytics_rounded,         label: 'Reportes'),
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
          appBar: _buildDesktopTopBar(),
          body: _pages[_selectedIndex],
        );
      }

      // Mobile: AppBar con hamburguesa + Drawer
      return Scaffold(
        appBar: _buildMobileAppBar(),
        drawer: _buildMobileDrawer(),
        body: _pages[_selectedIndex],
      );
    });
  }

  // ── LOGO ISLA TROPICAL ──────────────────────────────────────
  Widget _buildLogo({double iconSize = 32, double fontSize = 16}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(iconSize * 0.28),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(iconSize * 0.28),
            child: Image.asset(
              'assets/icon/app_icon_192.png',
              width: iconSize,
              height: iconSize,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Icon(
                Icons.travel_explore_rounded,
                color: Colors.white,
                size: iconSize * 0.62,
              ),
            ),
          ),
        ),
        SizedBox(width: iconSize * 0.25),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'NOVA',
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                height: 1.1,
              ),
            ),
            Text(
              'Dashboard',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: fontSize * 0.58,
                fontWeight: FontWeight.w300,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── DESKTOP: TopBar horizontal con tabs ─────────────────────

  PreferredSizeWidget _buildDesktopTopBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(56),
      child: Container(
        color: _teal,
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: 56,
            child: Row(children: [
              // Logo
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildLogo(iconSize: 32, fontSize: 16),
              ),
              Container(width: 1, height: 56, color: Colors.white24),
              // Nav tabs — scrollable para que no overflow con muchos items
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _navItems.asMap().entries.map((entry) {
                      final i = entry.key;
                      final item = entry.value;
                      final isSelected = _selectedIndex == i;
                      return InkWell(
                        onTap: () => setState(() {
                          _selectedIndex = i;
                          if (i == _placesIndex) _currentPlaceFilter = 'all';
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          height: 56,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: isSelected ? Colors.white : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(item.icon,
                                  color: isSelected ? Colors.white : Colors.white60,
                                  size: 16),
                              const SizedBox(width: 6),
                              Text(item.label,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.white60,
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  )),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              // Menú usuario
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 200),
                child: _buildUserMenu(compact: false),
              ),
              const SizedBox(width: 8),
            ]),
          ),
        ),
      ),
    );
  }

  // ── MOBILE: AppBar con hamburguesa ──────────────────────────

  PreferredSizeWidget _buildMobileAppBar() {
    return AppBar(
      backgroundColor: _teal,
      title: _buildLogo(iconSize: 28, fontSize: 15),
      actions: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 56),
          child: _buildUserMenu(compact: true),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ── MOBILE: Drawer vertical ─────────────────────────────────

  Drawer _buildMobileDrawer() {
    return Drawer(
      width: 220,
      child: SafeArea(
        child: Column(children: [
          // Cabecera del Drawer
          Container(
            color: _teal,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _buildLogo(iconSize: 36, fontSize: 16),
            ]),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _navItems.length,
              itemBuilder: (_, i) {
                final item     = _navItems[i];
                final selected = _selectedIndex == i;
                return ListTile(
                  leading: Icon(item.icon,
                      color: selected ? _teal : Colors.grey[600], size: 22),
                  title: Text(item.label,
                      style: TextStyle(
                        color: selected ? _teal : Colors.grey[800],
                        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 14,
                      )),
                  tileColor: selected ? _teal.withOpacity(0.08) : null,
                  onTap: () {
                    setState(() {
                      _selectedIndex = i;
                      if (i == _placesIndex) _currentPlaceFilter = 'all';
                    });
                    Navigator.of(context).pop(); // cerrar Drawer
                  },
                );
              },
            ),
          ),
        ]),
      ),
    );
  }

  // ── USER MENU ───────────────────────────────────────────────

  Widget _buildUserMenu({bool compact = false}) {
    final roleLabel = AppConstants.getRoleLabel(_userRole);
    final roleEmoji = AppConstants.getRoleEmoji(_userRole);

    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 8),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: Colors.white,
            child: Text(
              _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
              style: const TextStyle(
                  color: _teal, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          if (!compact) ...[
            const SizedBox(width: 6),
            Flexible(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_userName.split(' ').first,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis, maxLines: 1),
                Text('$roleEmoji $roleLabel',
                    style: const TextStyle(color: Colors.white70, fontSize: 9),
                    overflow: TextOverflow.ellipsis, maxLines: 1),
              ],
            )),
          ],
          const Icon(Icons.arrow_drop_down, color: Colors.white, size: 18),
        ]),
      ),
      itemBuilder: (_) => [
        PopupMenuItem(
          enabled: false,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(_userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text(_userEmail, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                  color: _teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12)),
              child: Text('$roleEmoji $roleLabel',
                  style: const TextStyle(fontSize: 10, color: _teal)),
            ),
            const Divider(),
          ]),
        ),
        const PopupMenuItem(value: 'profile', child: ListTile(
            leading: Icon(Icons.person_rounded, color: _teal),
            title: Text('Mi Perfil'),
            contentPadding: EdgeInsets.zero, dense: true)),
        const PopupMenuItem(value: 'password', child: ListTile(
            leading: Icon(Icons.lock_rounded, color: _teal),
            title: Text('Cambiar Contraseña'),
            contentPadding: EdgeInsets.zero, dense: true)),
        const PopupMenuDivider(),
        const PopupMenuItem(value: 'logout', child: ListTile(
            leading: Icon(Icons.logout_rounded, color: Colors.red),
            title: Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
            contentPadding: EdgeInsets.zero, dense: true)),
      ],
      onSelected: (v) {
        switch (v) {
          case 'profile':
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const ProfilePage()));
            break;
          case 'password':
            if (_userId != null) {
              showDialog(
                  context: context,
                  builder: (_) => ChangePasswordDialog(userId: _userId!));
            }
            break;
          case 'logout':
            _confirmLogout();
            break;
        }
      },
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que quieres salir?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              await AdminService.logout();
              if (mounted) {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/login', (_) => false);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String   label;
  const _NavItem({required this.icon, required this.label});
}
