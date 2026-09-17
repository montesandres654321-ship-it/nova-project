// lib/pages/places/qr/qr_type_style.dart
// Extraído de qr_dialog.dart (_typeColor/_typeLightColor/_typeIcon/
// _qrData/_qrImageUrl) sin cambios de comportamiento.
import 'package:flutter/material.dart';
import '../../../models/place.dart';

Color qrTypeColor(Place place) {
  switch (place.tipo.toLowerCase()) {
    case 'hotel':      return const Color(0xFF2563EB);
    case 'restaurant': return const Color(0xFF059669);
    case 'bar':        return const Color(0xFFD97706);
    default:           return const Color(0xFF06B6A4);
  }
}

Color qrTypeLightColor(Place place) {
  switch (place.tipo.toLowerCase()) {
    case 'hotel':      return const Color(0xFFDBEAFE);
    case 'restaurant': return const Color(0xFFD1FAE5);
    case 'bar':        return const Color(0xFFFEF3C7);
    default:           return const Color(0xFFE0F7FA);
  }
}

String qrTypeIcon(Place place) {
  switch (place.tipo.toLowerCase()) {
    case 'hotel':      return '🏨';
    case 'restaurant': return '🍽️';
    case 'bar':        return '🍹';
    default:           return '📍';
  }
}

String qrData(Place place) => 'PLACE:${place.id}';

// URL del QR con color personalizado por tipo
String qrImageUrl(Place place) {
  final encoded = Uri.encodeComponent(qrData(place));
  String qrColor;
  switch (place.tipo.toLowerCase()) {
    case 'hotel':      qrColor = '2563EB'; break;
    case 'restaurant': qrColor = '059669'; break;
    case 'bar':        qrColor = 'D97706'; break;
    default:           qrColor = '06B6A4'; break;
  }
  return 'https://api.qrserver.com/v1/create-qr-code/'
      '?size=400x400&data=$encoded&format=png&margin=12'
      '&color=$qrColor&bgcolor=FFFFFF';
}
