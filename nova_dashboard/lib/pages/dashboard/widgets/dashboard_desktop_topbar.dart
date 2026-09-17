// lib/pages/dashboard/widgets/dashboard_desktop_topbar.dart
// Extraído de dashboard_page.dart (_buildDesktopTopBar) sin cambios de
// comportamiento ni de estilo.
import 'package:flutter/material.dart';
import '../dashboard_nav_item.dart';
import 'dashboard_logo.dart';
import 'dashboard_user_menu.dart';

const kDashboardDesktopTeal = Color(0xFF06B6A4);

class DashboardDesktopTopBar extends StatelessWidget implements PreferredSizeWidget {
  final List<NavItem> navItems;
  final int selectedIndex;
  final void Function(int index) onSelect;
  final Widget userMenu;

  const DashboardDesktopTopBar({
    super.key,
    required this.navItems,
    required this.selectedIndex,
    required this.onSelect,
    required this.userMenu,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kDashboardDesktopTeal,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Row(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const DashboardLogo(iconSize: 32, fontSize: 16),
            ),
            Container(width: 1, height: 56, color: Colors.white24),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: navItems.asMap().entries.map((entry) {
                    final i = entry.key;
                    final item = entry.value;
                    final isSelected = selectedIndex == i;
                    return InkWell(
                      onTap: () => onSelect(i),
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
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: userMenu,
            ),
            const SizedBox(width: 8),
          ]),
        ),
      ),
    );
  }
}
