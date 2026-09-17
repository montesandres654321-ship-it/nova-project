// lib/pages/admins/widgets/admin_status_badge.dart
// Extraído de admin_card.dart (_StatusBadge) sin cambios de comportamiento
// ni de estilo.
import 'package:flutter/material.dart';
import '../admin_tokens.dart';

class AdminStatusBadge extends StatelessWidget {
  final bool isActive;
  const AdminStatusBadge({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? kAdminGreen : kAdminTextSub;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 6, height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          isActive ? 'Activo' : 'Inactivo',
          style: TextStyle(
              fontSize: 10, color: color,
              fontWeight: FontWeight.w700, letterSpacing: 0.2),
        ),
      ]),
    );
  }
}
