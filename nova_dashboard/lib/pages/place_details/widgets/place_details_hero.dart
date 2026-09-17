// lib/pages/place_details/widgets/place_details_hero.dart
// Extraído de place_details_page.dart (_buildHero/_heroPlaceholder) sin
// cambios de comportamiento ni de estilo.
import 'package:flutter/material.dart';
import '../../../models/place.dart';
import '../place_details_tokens.dart';
import 'place_details_shared.dart';

class PlaceDetailsHero extends StatelessWidget {
  final Place place;
  final double height;
  const PlaceDetailsHero({super.key, required this.place, required this.height});

  @override
  Widget build(BuildContext context) {
    final typeColor = placeDetailsTypeColor(place.tipo);
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(fit: StackFit.expand, children: [
        (place.imageUrl != null && place.imageUrl!.isNotEmpty)
            ? Image.network(
                place.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(typeColor),
              )
            : _placeholder(typeColor),

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
              color: typeColor,
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
          child: PlaceDetailsStatusBadge(isActive: place.isActive, onHero: true),
        ),
      ]),
    );
  }

  Widget _placeholder(Color typeColor) {
    return Container(
      color: typeColor.withOpacity(0.08),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(placeDetailsTypeIcon(place.tipo), size: 44, color: typeColor.withOpacity(0.4)),
        const SizedBox(height: 6),
        Text('Sin imagen', style: TextStyle(fontSize: 11, color: typeColor.withOpacity(0.5))),
      ]),
    );
  }
}
