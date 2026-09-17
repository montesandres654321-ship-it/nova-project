// lib/pages/place_details_page.dart
// REFACTOR: hero, tarjetas y widgets compartidos extraídos a
// lib/pages/place_details/ para bajar de 610 a <300 líneas.
import 'package:flutter/material.dart';
import '../models/place.dart';
import 'places/form_page.dart';
import 'places/qr_dialog.dart';
import 'place_details/place_details_tokens.dart';
import 'place_details/widgets/place_details_cards.dart';
import 'place_details/widgets/place_details_hero.dart';
import 'place_details/widgets/place_details_shared.dart';

class PlaceDetailsPage extends StatelessWidget {
  final Place place;
  const PlaceDetailsPage({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPlaceDetailsBgPage,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: kPlaceDetailsTextHead,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: const BackButton(color: kPlaceDetailsTextHead),
        titleSpacing: 0,
        title: Text(
          place.name,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kPlaceDetailsTextHead),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20, color: kPlaceDetailsTextMuted),
            tooltip: 'Editar',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => PlaceFormPage(place: place))),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, size: 20, color: kPlaceDetailsTextMuted),
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            offset: const Offset(0, 6),
            elevation: 4,
            onSelected: (action) {
              if (action == 'qr') showDialog(context: context, builder: (_) => QRDialog(place: place));
            },
            itemBuilder: (_) => const [
              PopupMenuItem<String>(
                value: 'qr',
                height: 40,
                child: Row(children: [
                  Icon(Icons.qr_code_rounded, size: 15, color: kPlaceDetailsPrimary),
                  SizedBox(width: 10),
                  Text('Ver código QR', style: TextStyle(fontSize: 13, color: kPlaceDetailsPrimary, fontWeight: FontWeight.w500)),
                ]),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: kPlaceDetailsBorder),
        ),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 860;
        final isTablet  = constraints.maxWidth > 580;
        final hPad      = isDesktop ? 24.0 : (isTablet ? 18.0 : 14.0);
        final heroH     = isDesktop ? 140.0 : (isTablet ? 170.0 : 200.0);

        return SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            PlaceDetailsHero(place: place, height: heroH),

            _buildNameSection(),

            Padding(
              padding: EdgeInsets.fromLTRB(hPad, hPad, hPad, hPad),
              child: isDesktop
                  ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      SizedBox(
                        width: 220,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: _leftColumn(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _rightColumn(context),
                        ),
                      ),
                    ])
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _mobileColumn(context),
                    ),
            ),

            const SizedBox(height: 20),
          ]),
        );
      }),
    );
  }

  // ─────────────────────────────────────────────────────────
  // NOMBRE + UBICACIÓN — compacto
  // ─────────────────────────────────────────────────────────
  Widget _buildNameSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(place.name,
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: kPlaceDetailsTextHead, height: 1.2),
                overflow: TextOverflow.ellipsis, maxLines: 1),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.location_on_outlined, size: 13, color: kPlaceDetailsTextSub),
              const SizedBox(width: 3),
              Text(place.lugar, style: const TextStyle(fontSize: 12, color: kPlaceDetailsTextMuted)),
              if (place.address != null && place.address!.isNotEmpty) ...[
                const Text(' · ', style: TextStyle(fontSize: 12, color: kPlaceDetailsTextSub)),
                Expanded(
                  child: Text(place.address!, style: const TextStyle(fontSize: 12, color: kPlaceDetailsTextMuted), overflow: TextOverflow.ellipsis),
                ),
              ],
            ]),
          ]),
        ),
        const SizedBox(width: 10),
        PlaceDetailsStatusBadge(isActive: place.isActive),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────
  // KPI ROW — horizontal compact, ~46px altura total
  // ─────────────────────────────────────────────────────────
  Widget _buildKpiRow() {
    final reward = place.hasReward ? (place.rewardStock?.toString() ?? '∞') : '—';
    return Row(children: [
      Expanded(child: PlaceDetailsKpiMini(
          icon: Icons.location_on_outlined, label: 'Municipio',
          value: place.lugar, color: kPlaceDetailsPrimary)),
      const SizedBox(width: 8),
      Expanded(child: PlaceDetailsKpiMini(
          icon: Icons.card_giftcard_rounded,
          label: place.hasReward ? 'Stock' : 'Recompensa',
          value: reward, color: kPlaceDetailsAmber)),
      const SizedBox(width: 8),
      Expanded(child: PlaceDetailsKpiMini(
          icon: place.isActive ? Icons.check_circle_outline_rounded : Icons.cancel_outlined,
          label: 'Estado',
          value: place.isActive ? 'Activo' : 'Inactivo',
          color: place.isActive ? kPlaceDetailsGreen : kPlaceDetailsTextSub)),
    ]);
  }

  // ─────────────────────────────────────────────────────────
  // COLUMNAS
  // ─────────────────────────────────────────────────────────
  List<Widget> _leftColumn(BuildContext context) => [
    buildPlaceInfoCard(place),
    const SizedBox(height: 12),
    buildPlaceQrCard(context, place),
  ];

  List<Widget> _rightColumn(BuildContext context) => [
    _buildKpiRow(),
    const SizedBox(height: 12),
    buildPlaceDescriptionCard(place),
    const SizedBox(height: 12),
    buildPlaceAmenitiesCard(place),
    if (place.hasReward) ...[
      const SizedBox(height: 12),
      buildPlaceRewardCard(place),
    ],
    if (place.hasOwner) ...[
      const SizedBox(height: 12),
      buildPlaceOwnerCard(place),
    ],
  ];

  List<Widget> _mobileColumn(BuildContext context) => [
    _buildKpiRow(),
    const SizedBox(height: 12),
    buildPlaceInfoCard(place),
    const SizedBox(height: 12),
    buildPlaceDescriptionCard(place),
    const SizedBox(height: 12),
    buildPlaceAmenitiesCard(place),
    if (place.hasReward) ...[
      const SizedBox(height: 12),
      buildPlaceRewardCard(place),
    ],
    const SizedBox(height: 12),
    buildPlaceQrCard(context, place),
    if (place.hasOwner) ...[
      const SizedBox(height: 12),
      buildPlaceOwnerCard(place),
    ],
  ];
}
