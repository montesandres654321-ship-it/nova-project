// lib/pages/places/widgets/places_header.dart
// Extraído de list_tab.dart (_buildHeader/_filterPill) sin cambios de
// comportamiento ni de estilo.
import 'package:flutter/material.dart';
import '../places_tokens.dart';

class PlacesHeader extends StatelessWidget {
  final bool canEdit;
  final List<Map<String, dynamic>> filters;
  final String selectedFilter;
  final String statusFilter;
  final int resultCount;
  final VoidCallback onAddPlace;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onFilterSelected;
  final ValueChanged<String> onStatusFilterToggled;

  const PlacesHeader({
    super.key,
    required this.canEdit,
    required this.filters,
    required this.selectedFilter,
    required this.statusFilter,
    required this.resultCount,
    required this.onAddPlace,
    required this.onSearchChanged,
    required this.onFilterSelected,
    required this.onStatusFilterToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Búsqueda + botón ─────────────────────────────
        Row(children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: kPlacesBgPage,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kPlacesBorder),
              ),
              child: TextField(
                style: const TextStyle(fontSize: 13, color: kPlacesTextHead),
                decoration: const InputDecoration(
                  hintText: 'Buscar lugares...',
                  hintStyle: TextStyle(fontSize: 13, color: kPlacesTextSub),
                  prefixIcon: Icon(Icons.search_rounded, size: 18, color: kPlacesTextSub),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 11),
                ),
                onChanged: onSearchChanged,
              ),
            ),
          ),
          if (canEdit) ...[
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: onAddPlace,
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Nuevo',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPlacesPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ]),

        const SizedBox(height: 12),

        // ── Pills de filtros ─────────────────────────────
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [

            // Tipo
            ...filters.map((f) => _filterPill(
              f['label'] as String,
              selectedFilter == f['value'],
              () => onFilterSelected(f['value'] as String),
              activeColor: kPlacesPrimary,
              activeTextColor: Colors.white,
            )),

            // Separador
            Container(width: 1, height: 22, color: kPlacesBorder,
                margin: const EdgeInsets.symmetric(horizontal: 8)),

            // Estado (sin duplicar "Todos" — clic en pill activo lo deselecciona)
            _filterPill('Activos', statusFilter == 'active',
                () => onStatusFilterToggled('active'),
                activeColor: kPlacesGreen.withOpacity(0.1),
                activeTextColor: kPlacesGreen,
                activeBorderColor: kPlacesGreen.withOpacity(0.35)),

            _filterPill('Inactivos', statusFilter == 'inactive',
                () => onStatusFilterToggled('inactive'),
                activeColor: kPlacesRed.withOpacity(0.08),
                activeTextColor: kPlacesRed,
                activeBorderColor: kPlacesRed.withOpacity(0.3)),
          ]),
        ),

        const SizedBox(height: 10),

        // ── Contador ─────────────────────────────────────
        Text(
          '$resultCount lugar${resultCount != 1 ? 'es' : ''}',
          style: const TextStyle(fontSize: 12, color: kPlacesTextSub,
              fontWeight: FontWeight.w500),
        ),
      ]),
    );
  }

  Widget _filterPill(
    String label, bool selected, VoidCallback onTap, {
    required Color activeColor,
    required Color activeTextColor,
    Color? activeBorderColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? (activeBorderColor ?? activeColor)
                  : kPlacesBorder,
            ),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: selected ? activeTextColor : kPlacesTextMuted,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.w400)),
        ),
      ),
    );
  }
}
