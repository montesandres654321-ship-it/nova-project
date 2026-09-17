// lib/pages/places/widgets/place_card.dart
// Extraído de list_tab.dart (_buildPlaceCard/_menuItem/_StatusBadge) sin
// cambios de comportamiento ni de estilo.
import 'package:flutter/material.dart';
import '../../../models/place.dart';
import '../places_tokens.dart';

class PlaceCard extends StatelessWidget {
  final Place place;
  final bool canEdit;
  final bool canViewInfo;
  final void Function(String action, Place place) onAction;

  const PlaceCard({
    super.key,
    required this.place,
    required this.canEdit,
    required this.canViewInfo,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor  = placeTypeColor(place.tipo);
    final isInactive = !place.isActive;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isInactive ? const Color(0xFFEEF2F7) : kPlacesBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isInactive ? 0.02 : 0.04),
            blurRadius: 8, offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

            // Franja de color por tipo
            Container(
              width: 4,
              color: typeColor.withOpacity(isInactive ? 0.2 : 1.0),
            ),

            // Contenido principal
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 6, 14),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                  // Icono de tipo
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(isInactive ? 0.05 : 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(place.tipoEmoji,
                          style: const TextStyle(fontSize: 20)),
                    ),
                  ),
                  const SizedBox(width: 13),

                  // Texto
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // Nombre + badge estado
                        Row(crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                          Expanded(
                            child: Text(place.name,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: isInactive
                                        ? kPlacesTextSub
                                        : kPlacesTextHead,
                                    height: 1.2),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(width: 8),
                          _StatusBadge(isActive: place.isActive),
                        ]),

                        const SizedBox(height: 6),

                        // Tipo chip + ubicación
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: typeColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: typeColor.withOpacity(0.28)),
                            ),
                            child: Text(place.tipoLabel,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: typeColor,
                                    fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.location_on_outlined,
                              size: 12, color: kPlacesTextSub),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(place.lugar,
                                style: const TextStyle(
                                    fontSize: 12, color: kPlacesTextMuted),
                                overflow: TextOverflow.ellipsis),
                          ),
                        ]),

                        // Propietario
                        if (place.ownerFirstName != null) ...[
                          const SizedBox(height: 5),
                          Row(children: [
                            const Icon(Icons.person_outline_rounded,
                                size: 12, color: kPlacesTextSub),
                            const SizedBox(width: 4),
                            Text(
                              '${place.ownerFirstName}'
                              '${place.ownerLastName != null ? ' ${place.ownerLastName}' : ''}',
                              style: const TextStyle(
                                  fontSize: 11, color: kPlacesTextSub),
                            ),
                          ]),
                        ],

                        // Recompensa
                        if (place.hasReward &&
                            place.rewardName != null) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: kPlacesAmber.withOpacity(0.07),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: kPlacesAmber.withOpacity(0.2)),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min,
                                children: [
                              const Icon(Icons.card_giftcard_rounded,
                                  size: 11, color: kPlacesAmber),
                              const SizedBox(width: 4),
                              Text(place.rewardName!,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: kPlacesAmber,
                                      fontWeight: FontWeight.w500)),
                            ]),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Menú contextual ⋯
                  SizedBox(
                    width: 36,
                    child: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded,
                          size: 18, color: kPlacesTextSub),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                      offset: const Offset(0, 6),
                      onSelected: (a) => onAction(a, place),
                      itemBuilder: (_) => [
                        if (canViewInfo)
                          _menuItem('view',
                              Icons.visibility_outlined, 'Ver detalle',
                              kPlacesTextHead),
                        _menuItem('qr',
                            Icons.qr_code_rounded, 'Ver QR', kPlacesPrimary),
                        if (canEdit) ...[
                          _menuItem('edit',
                              Icons.edit_outlined, 'Editar', kPlacesTextHead),
                          const PopupMenuDivider(height: 1),
                          _menuItem(
                            'toggle',
                            place.isActive
                                ? Icons.toggle_off_outlined
                                : Icons.toggle_on_outlined,
                            place.isActive ? 'Desactivar lugar' : 'Activar lugar',
                            place.isActive ? kPlacesRed : kPlacesGreen,
                          ),
                          const PopupMenuDivider(height: 1),
                          _menuItem('delete',
                              Icons.delete_outline_rounded, 'Eliminar',
                              kPlacesRed),
                        ],
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  PopupMenuItem<String> _menuItem(
      String value, IconData icon, String label, Color color) =>
    PopupMenuItem<String>(
      value: value,
      height: 42,
      child: Row(children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 10),
        Text(label,
            style: TextStyle(fontSize: 13,
                color: color,
                fontWeight: FontWeight.w500)),
      ]),
    );
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;
  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? kPlacesGreen : kPlacesTextSub;
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
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2),
        ),
      ]),
    );
  }
}
