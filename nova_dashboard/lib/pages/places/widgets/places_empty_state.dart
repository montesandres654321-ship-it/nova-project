// lib/pages/places/widgets/places_empty_state.dart
// Extraído de list_tab.dart (_buildEmptyState) sin cambios de comportamiento
// ni de estilo.
import 'package:flutter/material.dart';
import '../places_tokens.dart';

class PlacesEmptyState extends StatelessWidget {
  final bool isFiltered;
  final bool canEdit;
  final VoidCallback onAddPlace;

  const PlacesEmptyState({
    super.key,
    required this.isFiltered,
    required this.canEdit,
    required this.onAddPlace,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            color: kPlacesBorder,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            isFiltered
                ? Icons.search_off_rounded
                : Icons.store_mall_directory_outlined,
            size: 30, color: kPlacesTextSub),
        ),
        const SizedBox(height: 16),
        Text(
          isFiltered ? 'Sin resultados' : 'No hay lugares aún',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
              color: kPlacesTextHead),
        ),
        const SizedBox(height: 6),
        Text(
          isFiltered
              ? 'Prueba con otros filtros o búsqueda'
              : 'Agrega el primer lugar para comenzar',
          style: const TextStyle(fontSize: 13, color: kPlacesTextMuted),
          textAlign: TextAlign.center,
        ),
        if (!isFiltered && canEdit) ...[
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onAddPlace,
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text('Agregar lugar',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPlacesPrimary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ]),
    );
  }
}
