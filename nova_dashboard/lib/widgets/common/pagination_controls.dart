// lib/widgets/common/pagination_controls.dart
// Paginación client-side reutilizable — mismo patrón visual que
// scans_page.dart (prev/next + "Página X de Y"), para listas que ya
// se cargan completas del backend (users, admins, places).
import 'package:flutter/material.dart';

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Text('Página $currentPage de $totalPages',
              style: const TextStyle(fontSize: 13)),
          IconButton(
            onPressed:
                currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}
