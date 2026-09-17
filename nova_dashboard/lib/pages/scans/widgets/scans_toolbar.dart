// lib/pages/scans/widgets/scans_toolbar.dart
// Extraído de scans_page.dart (header + buscador de build()) sin cambios
// de comportamiento ni de estilo.
import 'package:flutter/material.dart';
import '../scans_tokens.dart';

class ScansToolbar extends StatelessWidget {
  final int total;
  final VoidCallback onRefresh;
  final TextEditingController searchCtrl;
  final String search;
  final ValueChanged<String> onSearch;

  const ScansToolbar({
    super.key,
    required this.total,
    required this.onRefresh,
    required this.searchCtrl,
    required this.search,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
          width: 4, height: 24,
          decoration: BoxDecoration(
            color: kScansPrimary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        const Text('Escaneos',
          style: TextStyle(fontSize: 20,
              fontWeight: FontWeight.w700)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: kScansPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text('$total registros',
            style: TextStyle(fontSize: 12,
                color: kScansPrimary,
                fontWeight: FontWeight.w500)),
        ),
        const Spacer(),
        IconButton(
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Recargar',
        ),
      ]),
      const SizedBox(height: 16),
      SizedBox(
        height: 44,
        child: TextField(
          controller: searchCtrl,
          onChanged: onSearch,
          decoration: InputDecoration(
            hintText: 'Buscar por turista, lugar...',
            hintStyle: TextStyle(
                fontSize: 13, color: Colors.grey[400]),
            prefixIcon: Icon(Icons.search_rounded,
                color: Colors.grey[400], size: 20),
            suffixIcon: search.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded,
                        size: 18),
                    onPressed: () {
                      searchCtrl.clear();
                      onSearch('');
                    })
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: kScansPrimary),
            ),
          ),
        ),
      ),
    ]);
  }
}
