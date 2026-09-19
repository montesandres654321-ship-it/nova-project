// lib/pages/dashboard/widgets/dashboard_mobile_shell.dart
// Extraído de dashboard_page.dart (_buildMobileAppBar/_buildMobileDrawer)
// sin cambios de comportamiento ni de estilo.
import 'package:nova_dashboard/utils/app_theme.dart';
import 'package:flutter/material.dart';
import '../dashboard_nav_item.dart';
import 'dashboard_logo.dart';

const kDashboardMobileTeal = AppTheme.primary;

PreferredSizeWidget dashboardMobileAppBar({
  required Widget userMenu,
}) {
  return AppBar(
    backgroundColor: kDashboardMobileTeal,
    title: const DashboardLogo(iconSize: 28, fontSize: 15),
    actions: [
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 56),
        child: userMenu,
      ),
      const SizedBox(width: 4),
    ],
  );
}

class DashboardMobileDrawer extends StatelessWidget {
  final List<NavItem> navItems;
  final int selectedIndex;
  final void Function(int index) onSelect;

  const DashboardMobileDrawer({
    super.key,
    required this.navItems,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 220,
      child: SafeArea(
        child: Column(children: [
          Container(
            color: kDashboardMobileTeal,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              DashboardLogo(iconSize: 36, fontSize: 16),
            ]),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: navItems.length,
              itemBuilder: (_, i) {
                final item     = navItems[i];
                final selected = selectedIndex == i;
                return ListTile(
                  leading: Icon(item.icon,
                      color: selected ? kDashboardMobileTeal : Colors.grey[600], size: 22),
                  title: Text(item.label,
                      style: TextStyle(
                        color: selected ? kDashboardMobileTeal : Colors.grey[800],
                        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 14,
                      )),
                  tileColor: selected ? kDashboardMobileTeal.withOpacity(0.08) : null,
                  onTap: () {
                    onSelect(i);
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
}
