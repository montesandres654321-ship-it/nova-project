// lib/pages/dashboard/widgets/dashboard_logo.dart
// Extraído de dashboard_page.dart (_buildLogo) sin cambios de
// comportamiento ni de estilo.
import 'package:flutter/material.dart';

class DashboardLogo extends StatelessWidget {
  final double iconSize;
  final double fontSize;
  const DashboardLogo({super.key, this.iconSize = 36, this.fontSize = 15});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(iconSize * 0.22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(iconSize * 0.22),
            child: Image.asset(
              'assets/icon/app_icon_192.png',
              width: iconSize,
              height: iconSize,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Icon(
                Icons.travel_explore_rounded,
                color: const Color(0xFF06B6A4),
                size: iconSize * 0.62,
              ),
            ),
          ),
        ),
        SizedBox(width: iconSize * 0.28),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'NOVA App',
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                height: 1.1,
              ),
            ),
            Text(
              'Dashboard',
              style: TextStyle(
                color: Colors.white.withOpacity(0.72),
                fontSize: fontSize * 0.58,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
