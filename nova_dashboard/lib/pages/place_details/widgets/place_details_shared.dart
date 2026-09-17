// lib/pages/place_details/widgets/place_details_shared.dart
// Extraído de place_details_page.dart (_SectionCard/_KpiMini/_StatusBadge)
// sin cambios de comportamiento ni de estilo.
import 'package:flutter/material.dart';
import '../place_details_tokens.dart';

class PlaceDetailsSectionCard extends StatelessWidget {
  final String  title;
  final String? subtitle;
  final Widget  child;
  const PlaceDetailsSectionCard({super.key, required this.title, this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: kPlaceDetailsBorder),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
        child: Row(children: [
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kPlaceDetailsTextHead)),
          if (subtitle != null) ...[
            const SizedBox(width: 6),
            Text(subtitle!, style: const TextStyle(fontSize: 10, color: kPlaceDetailsTextSub)),
          ],
        ]),
      ),
      const Divider(height: 14, thickness: 0.5, color: kPlaceDetailsBorder),
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        child: child,
      ),
    ]),
  );
}

class PlaceDetailsKpiMini extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;
  final Color    color;
  const PlaceDetailsKpiMini({super.key, required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: kPlaceDetailsBorder),
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
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: kPlaceDetailsTextHead, height: 1.1),
              overflow: TextOverflow.ellipsis, maxLines: 1),
          const SizedBox(height: 1),
          Text(label, style: const TextStyle(fontSize: 10, color: kPlaceDetailsTextSub)),
        ],
      )),
    ]),
  );
}

class PlaceDetailsStatusBadge extends StatelessWidget {
  final bool isActive;
  final bool onHero;
  const PlaceDetailsStatusBadge({super.key, required this.isActive, this.onHero = false});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? kPlaceDetailsGreen : kPlaceDetailsTextSub;
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
