// lib/pages/place_details/widgets/place_details_cards.dart
// Extraído de place_details_page.dart (_buildInfoCard/_buildDescriptionCard/
// _buildAmenitiesCard/_buildRewardCard/_buildQrCard/_buildOwnerCard) sin
// cambios de comportamiento ni de estilo.
import 'package:flutter/material.dart';
import '../../../models/place.dart';
import '../../places/qr_dialog.dart';
import '../place_details_tokens.dart';
import 'place_details_shared.dart';

Widget _infoRow(IconData icon, String text) => Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Icon(icon, size: 13, color: kPlaceDetailsTextSub),
    const SizedBox(width: 7),
    Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: kPlaceDetailsTextMuted, height: 1.4))),
  ],
);

String _fmt(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

Widget buildPlaceInfoCard(Place place) {
  return PlaceDetailsSectionCard(
    title: 'Información',
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _infoRow(Icons.location_on_outlined, place.lugar),
      if (place.address != null && place.address!.isNotEmpty) ...[
        const SizedBox(height: 7),
        _infoRow(Icons.home_outlined, place.address!),
      ],
      if (place.phone != null && place.phone!.isNotEmpty) ...[
        const SizedBox(height: 7),
        _infoRow(Icons.phone_outlined, place.phone!),
      ],
      if (place.priceRange != null && place.priceRange!.isNotEmpty) ...[
        const SizedBox(height: 7),
        _infoRow(Icons.attach_money_rounded, place.priceRange!),
      ],
      const SizedBox(height: 10),
      const Divider(height: 1, thickness: 0.5, color: kPlaceDetailsBorder),
      const SizedBox(height: 8),
      Row(children: [
        const Icon(Icons.tag_rounded, size: 11, color: kPlaceDetailsTextSub),
        const SizedBox(width: 4),
        Text('ID ${place.id}', style: const TextStyle(fontSize: 10, color: kPlaceDetailsTextSub)),
        const Spacer(),
        if (place.createdAt != null)
          Text(_fmt(place.createdAt!), style: const TextStyle(fontSize: 10, color: kPlaceDetailsTextSub)),
      ]),
    ]),
  );
}

Widget buildPlaceDescriptionCard(Place place) {
  return PlaceDetailsSectionCard(
    title: 'Descripción',
    child: Text(
      place.description.isNotEmpty ? place.description : 'Sin descripción disponible.',
      style: const TextStyle(fontSize: 13, color: kPlaceDetailsTextMuted, height: 1.6),
    ),
  );
}

Widget buildPlaceAmenitiesCard(Place place) {
  return PlaceDetailsSectionCard(
    title: 'Servicios',
    subtitle: place.amenities.isEmpty ? null : '${place.amenities.length} disponibles',
    child: place.amenities.isEmpty
        ? const Text('Sin servicios registrados', style: TextStyle(fontSize: 12, color: kPlaceDetailsTextSub))
        : Wrap(
            spacing: 6,
            runSpacing: 6,
            children: place.amenities.map((a) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: kPlaceDetailsPrimary.withOpacity(0.07),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kPlaceDetailsPrimary.withOpacity(0.15)),
              ),
              child: Text(a, style: const TextStyle(fontSize: 11, color: kPlaceDetailsPrimary, fontWeight: FontWeight.w500)),
            )).toList(),
          ),
  );
}

Widget buildPlaceRewardCard(Place place) {
  return PlaceDetailsSectionCard(
    title: 'Recompensa',
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kPlaceDetailsAmber.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kPlaceDetailsAmber.withOpacity(0.18)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(place.rewardIcon ?? '🎁', style: const TextStyle(fontSize: 26)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(place.rewardName ?? 'Recompensa',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kPlaceDetailsAmber)),
            if (place.rewardDescription != null && place.rewardDescription!.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(place.rewardDescription!,
                  style: const TextStyle(fontSize: 12, color: kPlaceDetailsTextMuted, height: 1.4)),
            ],
            const SizedBox(height: 7),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: kPlaceDetailsAmber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kPlaceDetailsAmber.withOpacity(0.25)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.inventory_2_outlined, size: 10, color: kPlaceDetailsAmber),
                const SizedBox(width: 4),
                Text(place.rewardStockLabel,
                    style: const TextStyle(fontSize: 10, color: kPlaceDetailsAmber, fontWeight: FontWeight.w600)),
              ]),
            ),
          ]),
        ),
      ]),
    ),
  );
}

Widget buildPlaceQrCard(BuildContext context, Place place) {
  return PlaceDetailsSectionCard(
    title: 'Código QR',
    child: Row(children: [
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: kPlaceDetailsPrimary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kPlaceDetailsPrimary.withOpacity(0.15)),
        ),
        child: const Icon(Icons.qr_code_2_rounded, size: 22, color: kPlaceDetailsPrimary),
      ),
      const SizedBox(width: 12),
      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('QR generado y activo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kPlaceDetailsTextHead)),
        SizedBox(height: 2),
        Text('Escanear para registrar visita', style: TextStyle(fontSize: 10, color: kPlaceDetailsTextSub)),
      ])),
      TextButton.icon(
        onPressed: () => showDialog(context: context, builder: (_) => QRDialog(place: place)),
        icon: const Icon(Icons.open_in_new_rounded, size: 13, color: kPlaceDetailsPrimary),
        label: const Text('Ver', style: TextStyle(fontSize: 12, color: kPlaceDetailsPrimary, fontWeight: FontWeight.w600)),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    ]),
  );
}

Widget buildPlaceOwnerCard(Place place) {
  return PlaceDetailsSectionCard(
    title: 'Propietario',
    child: Row(children: [
      CircleAvatar(
        radius: 18,
        backgroundColor: kPlaceDetailsPrimary.withOpacity(0.1),
        child: Text(place.ownerInitials,
            style: const TextStyle(fontSize: 12, color: kPlaceDetailsPrimary, fontWeight: FontWeight.bold)),
      ),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(place.ownerDisplay,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kPlaceDetailsTextHead)),
        if (place.ownerEmail != null) ...[
          const SizedBox(height: 2),
          Text(place.ownerEmail!, style: const TextStyle(fontSize: 11, color: kPlaceDetailsTextSub)),
        ],
        if (place.ownerPhone != null) ...[
          const SizedBox(height: 2),
          Text(place.ownerPhone!, style: const TextStyle(fontSize: 11, color: kPlaceDetailsTextSub)),
        ],
      ])),
    ]),
  );
}
