// lib/pages/place_details_page.dart
import 'package:flutter/material.dart';
import '../models/place.dart';
import 'places/form_page.dart';
import 'places/qr_dialog.dart';

// ── Design tokens ──────────────────────────────────────────────
const _kPrimary   = Color(0xFF06B6A4);
const _kBgPage    = Color(0xFFF1F5F9);
const _kTextHead  = Color(0xFF0F172A);
const _kTextMuted = Color(0xFF64748B);
const _kTextSub   = Color(0xFF94A3B8);
const _kBorder    = Color(0xFFE2E8F0);
const _kBlue      = Color(0xFF3B82F6);
const _kGreen     = Color(0xFF10B981);
const _kAmber     = Color(0xFFF59E0B);

// ──────────────────────────────────────────────────────────────
class PlaceDetailsPage extends StatelessWidget {
  final Place place;
  const PlaceDetailsPage({super.key, required this.place});

  Color get _typeColor {
    switch (place.tipo.toLowerCase()) {
      case 'hotel':      return _kBlue;
      case 'restaurant': return _kGreen;
      case 'bar':        return _kAmber;
      default:           return _kTextSub;
    }
  }

  IconData get _typeIcon {
    switch (place.tipo.toLowerCase()) {
      case 'hotel':      return Icons.hotel_rounded;
      case 'restaurant': return Icons.restaurant_rounded;
      case 'bar':        return Icons.local_bar_rounded;
      default:           return Icons.place_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBgPage,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _kTextHead,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: const BackButton(color: _kTextHead),
        titleSpacing: 0,
        title: Text(
          place.name,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _kTextHead),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20, color: _kTextMuted),
            tooltip: 'Editar',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => PlaceFormPage(place: place))),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, size: 20, color: _kTextMuted),
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
                  Icon(Icons.qr_code_rounded, size: 15, color: _kPrimary),
                  SizedBox(width: 10),
                  Text('Ver código QR', style: TextStyle(fontSize: 13, color: _kPrimary, fontWeight: FontWeight.w500)),
                ]),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: _kBorder),
        ),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 860;
        final isTablet  = constraints.maxWidth > 580;
        final hPad      = isDesktop ? 24.0 : (isTablet ? 18.0 : 14.0);
        final heroH     = isDesktop ? 140.0 : (isTablet ? 170.0 : 200.0);

        return SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // ── Hero ──────────────────────────────────────
            _buildHero(heroH),

            // ── Nombre + ubicación ─────────────────────────
            _buildNameSection(),

            // ── Contenido responsive ───────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, hPad, hPad, hPad),
              child: isDesktop
                  ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      // Columna izquierda fija 220px
                      SizedBox(
                        width: 220,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: _leftColumn(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Columna derecha expansible
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
  // HERO — altura adaptativa según breakpoint
  // ─────────────────────────────────────────────────────────
  Widget _buildHero(double height) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(fit: StackFit.expand, children: [
        (place.imageUrl != null && place.imageUrl!.isNotEmpty)
            ? Image.network(
                place.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _heroPlaceholder(),
              )
            : _heroPlaceholder(),

        // Gradiente inferior
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter, end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.32), Colors.transparent],
              ),
            ),
          ),
        ),

        // Badge de tipo
        Positioned(
          top: 10, left: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: _typeColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 5, offset: const Offset(0, 2))],
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(place.tipoEmoji, style: const TextStyle(fontSize: 11)),
              const SizedBox(width: 4),
              Text(place.tipoLabel, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700)),
            ]),
          ),
        ),

        // Badge de estado
        Positioned(
          top: 10, right: 10,
          child: _StatusBadge(isActive: place.isActive, onHero: true),
        ),
      ]),
    );
  }

  Widget _heroPlaceholder() {
    return Container(
      color: _typeColor.withOpacity(0.08),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(_typeIcon, size: 44, color: _typeColor.withOpacity(0.4)),
        const SizedBox(height: 6),
        Text('Sin imagen', style: TextStyle(fontSize: 11, color: _typeColor.withOpacity(0.5))),
      ]),
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
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: _kTextHead, height: 1.2),
                overflow: TextOverflow.ellipsis, maxLines: 1),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.location_on_outlined, size: 13, color: _kTextSub),
              const SizedBox(width: 3),
              Text(place.lugar, style: const TextStyle(fontSize: 12, color: _kTextMuted)),
              if (place.address != null && place.address!.isNotEmpty) ...[
                const Text(' · ', style: TextStyle(fontSize: 12, color: _kTextSub)),
                Expanded(
                  child: Text(place.address!, style: const TextStyle(fontSize: 12, color: _kTextMuted), overflow: TextOverflow.ellipsis),
                ),
              ],
            ]),
          ]),
        ),
        const SizedBox(width: 10),
        _StatusBadge(isActive: place.isActive),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────
  // KPI ROW — horizontal compact, ~46px altura total
  // ─────────────────────────────────────────────────────────
  Widget _buildKpiRow() {
    final reward      = place.hasReward ? (place.rewardStock?.toString() ?? '∞') : '—';
    return Row(children: [
      Expanded(child: _KpiMini(
          icon: Icons.location_on_outlined, label: 'Municipio',
          value: place.lugar, color: _kPrimary)),
      const SizedBox(width: 8),
      Expanded(child: _KpiMini(
          icon: Icons.card_giftcard_rounded,
          label: place.hasReward ? 'Stock' : 'Recompensa',
          value: reward, color: _kAmber)),
      const SizedBox(width: 8),
      Expanded(child: _KpiMini(
          icon: place.isActive ? Icons.check_circle_outline_rounded : Icons.cancel_outlined,
          label: 'Estado',
          value: place.isActive ? 'Activo' : 'Inactivo',
          color: place.isActive ? _kGreen : _kTextSub)),
    ]);
  }

  // ─────────────────────────────────────────────────────────
  // COLUMNAS
  // ─────────────────────────────────────────────────────────
  List<Widget> _leftColumn(BuildContext context) => [
    _buildInfoCard(),
    const SizedBox(height: 12),
    _buildQrCard(context),
  ];

  List<Widget> _rightColumn(BuildContext context) => [
    _buildKpiRow(),
    const SizedBox(height: 12),
    _buildDescriptionCard(),
    const SizedBox(height: 12),
    _buildAmenitiesCard(),
    if (place.hasReward) ...[
      const SizedBox(height: 12),
      _buildRewardCard(),
    ],
    if (place.hasOwner) ...[
      const SizedBox(height: 12),
      _buildOwnerCard(),
    ],
  ];

  List<Widget> _mobileColumn(BuildContext context) => [
    _buildKpiRow(),
    const SizedBox(height: 12),
    _buildInfoCard(),
    const SizedBox(height: 12),
    _buildDescriptionCard(),
    const SizedBox(height: 12),
    _buildAmenitiesCard(),
    if (place.hasReward) ...[
      const SizedBox(height: 12),
      _buildRewardCard(),
    ],
    const SizedBox(height: 12),
    _buildQrCard(context),
    if (place.hasOwner) ...[
      const SizedBox(height: 12),
      _buildOwnerCard(),
    ],
  ];

  // ─────────────────────────────────────────────────────────
  // CARDS — overhead reducido de 69px → 47px por card
  // ─────────────────────────────────────────────────────────
  Widget _buildInfoCard() {
    return _SectionCard(
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
        const Divider(height: 1, thickness: 0.5, color: _kBorder),
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.tag_rounded, size: 11, color: _kTextSub),
          const SizedBox(width: 4),
          Text('ID ${place.id}', style: const TextStyle(fontSize: 10, color: _kTextSub)),
          const Spacer(),
          if (place.createdAt != null)
            Text(_fmt(place.createdAt!), style: const TextStyle(fontSize: 10, color: _kTextSub)),
        ]),
      ]),
    );
  }

  Widget _buildDescriptionCard() {
    return _SectionCard(
      title: 'Descripción',
      child: Text(
        place.description.isNotEmpty ? place.description : 'Sin descripción disponible.',
        style: const TextStyle(fontSize: 13, color: _kTextMuted, height: 1.6),
      ),
    );
  }

  Widget _buildAmenitiesCard() {
    return _SectionCard(
      title: 'Servicios',
      subtitle: place.amenities.isEmpty ? null : '${place.amenities.length} disponibles',
      child: place.amenities.isEmpty
          ? const Text('Sin servicios registrados', style: TextStyle(fontSize: 12, color: _kTextSub))
          : Wrap(
              spacing: 6,
              runSpacing: 6,
              children: place.amenities.map((a) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _kPrimary.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _kPrimary.withOpacity(0.15)),
                ),
                child: Text(a, style: const TextStyle(fontSize: 11, color: _kPrimary, fontWeight: FontWeight.w500)),
              )).toList(),
            ),
    );
  }

  Widget _buildRewardCard() {
    return _SectionCard(
      title: 'Recompensa',
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _kAmber.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _kAmber.withOpacity(0.18)),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(place.rewardIcon ?? '🎁', style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(place.rewardName ?? 'Recompensa',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _kAmber)),
              if (place.rewardDescription != null && place.rewardDescription!.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(place.rewardDescription!,
                    style: const TextStyle(fontSize: 12, color: _kTextMuted, height: 1.4)),
              ],
              const SizedBox(height: 7),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _kAmber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _kAmber.withOpacity(0.25)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.inventory_2_outlined, size: 10, color: _kAmber),
                  const SizedBox(width: 4),
                  Text(place.rewardStockLabel,
                      style: const TextStyle(fontSize: 10, color: _kAmber, fontWeight: FontWeight.w600)),
                ]),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildQrCard(BuildContext context) {
    return _SectionCard(
      title: 'Código QR',
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: _kPrimary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _kPrimary.withOpacity(0.15)),
          ),
          child: const Icon(Icons.qr_code_2_rounded, size: 22, color: _kPrimary),
        ),
        const SizedBox(width: 12),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('QR generado y activo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _kTextHead)),
          SizedBox(height: 2),
          Text('Escanear para registrar visita', style: TextStyle(fontSize: 10, color: _kTextSub)),
        ])),
        TextButton.icon(
          onPressed: () => showDialog(context: context, builder: (_) => QRDialog(place: place)),
          icon: const Icon(Icons.open_in_new_rounded, size: 13, color: _kPrimary),
          label: const Text('Ver', style: TextStyle(fontSize: 12, color: _kPrimary, fontWeight: FontWeight.w600)),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ]),
    );
  }

  Widget _buildOwnerCard() {
    return _SectionCard(
      title: 'Propietario',
      child: Row(children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: _kPrimary.withOpacity(0.1),
          child: Text(place.ownerInitials,
              style: const TextStyle(fontSize: 12, color: _kPrimary, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(place.ownerDisplay,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _kTextHead)),
          if (place.ownerEmail != null) ...[
            const SizedBox(height: 2),
            Text(place.ownerEmail!, style: const TextStyle(fontSize: 11, color: _kTextSub)),
          ],
          if (place.ownerPhone != null) ...[
            const SizedBox(height: 2),
            Text(place.ownerPhone!, style: const TextStyle(fontSize: 11, color: _kTextSub)),
          ],
        ])),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────
  Widget _infoRow(IconData icon, String text) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 13, color: _kTextSub),
      const SizedBox(width: 7),
      Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: _kTextMuted, height: 1.4))),
    ],
  );

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION CARD — overhead reducido: 47px (antes 69px)
// ─────────────────────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String  title;
  final String? subtitle;
  final Widget  child;
  const _SectionCard({required this.title, this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _kBorder),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
        child: Row(children: [
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _kTextHead)),
          if (subtitle != null) ...[
            const SizedBox(width: 6),
            Text(subtitle!, style: const TextStyle(fontSize: 10, color: _kTextSub)),
          ],
        ]),
      ),
      const Divider(height: 14, thickness: 0.5, color: _kBorder),
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        child: child,
      ),
    ]),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// KPI MINI — horizontal compact (~46px altura, antes ~80px)
// ─────────────────────────────────────────────────────────────────────────────
class _KpiMini extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;
  final Color    color;
  const _KpiMini({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: _kBorder),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 1))],
    ),
    child: Row(children: [
      Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: color.withOpacity(0.09),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 14, color: color),
      ),
      const SizedBox(width: 8),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _kTextHead, height: 1.1),
              overflow: TextOverflow.ellipsis, maxLines: 1),
          const SizedBox(height: 1),
          Text(label, style: const TextStyle(fontSize: 10, color: _kTextSub)),
        ],
      )),
    ]),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// STATUS BADGE
// ─────────────────────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final bool isActive;
  final bool onHero;
  const _StatusBadge({required this.isActive, this.onHero = false});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? _kGreen : _kTextSub;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: onHero ? Colors.white.withOpacity(0.92) : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: onHero ? Colors.transparent : color.withOpacity(0.25)),
        boxShadow: onHero
            ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 5, offset: const Offset(0, 2))]
            : null,
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 5, height: 5, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(
          isActive ? 'Activo' : 'Inactivo',
          style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
        ),
      ]),
    );
  }
}
