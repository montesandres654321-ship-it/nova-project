// lib/pages/places/qr/qr_type_style.dart
// Extraído de qr_dialog.dart (_typeColor/_typeLightColor/_typeIcon/
// _qrData/_qrImageUrl) sin cambios de comportamiento.
import 'package:flutter/material.dart';
import '../../../models/place.dart';

Color qrTypeColor(Place place) {
  switch (place.tipo.toLowerCase()) {
    case 'hotel':               return const Color(0xFF2563EB);
    case 'restaurant':
    case 'gastronomia':         return const Color(0xFF059669);
    case 'bar':                 return const Color(0xFFD97706);
    case 'escenario_deportivo': return const Color(0xFFDC2626);
    case 'parque':
    case 'naturaleza':          return const Color(0xFF0D9488);
    case 'cultura':
    case 'artesania':           return const Color(0xFF7C3AED);
    case 'playa':               return const Color(0xFF0284C7);
    case 'ruta':                return const Color(0xFF4F46E5);
    case 'compras':             return const Color(0xFFDB2777);
    default:                    return const Color(0xFF06B6A4);
  }
}

Color qrTypeLightColor(Place place) {
  switch (place.tipo.toLowerCase()) {
    case 'hotel':               return const Color(0xFFDBEAFE);
    case 'restaurant':
    case 'gastronomia':         return const Color(0xFFD1FAE5);
    case 'bar':                 return const Color(0xFFFEF3C7);
    case 'escenario_deportivo': return const Color(0xFFFEE2E2);
    case 'parque':
    case 'naturaleza':          return const Color(0xFFCCFBF1);
    case 'cultura':
    case 'artesania':           return const Color(0xFFEDE9FE);
    case 'playa':               return const Color(0xFFE0F2FE);
    case 'ruta':                return const Color(0xFFE0E7FF);
    case 'compras':             return const Color(0xFFFCE7F3);
    default:                    return const Color(0xFFE0F7FA);
  }
}

String qrTypeIcon(Place place) => place.tipoEmoji;

String qrData(Place place) => 'PLACE:${place.id}';

// URL del QR con color personalizado por tipo
String qrImageUrl(Place place) {
  final encoded = Uri.encodeComponent(qrData(place));
  final qrColor = qrTypeColor(place).toARGB32().toRadixString(16).substring(2);
  return 'https://api.qrserver.com/v1/create-qr-code/'
      '?size=400x400&data=$encoded&format=png&margin=12'
      '&color=$qrColor&bgcolor=FFFFFF';
}
