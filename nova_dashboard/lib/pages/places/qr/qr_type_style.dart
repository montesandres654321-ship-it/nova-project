// lib/pages/places/qr/qr_type_style.dart
// Extraído de qr_dialog.dart (_typeColor/_typeLightColor/_typeIcon/
// _qrData/_qrImageUrl) sin cambios de comportamiento.
//
// Todos los colores por tipo de lugar usan los tokens de AppTheme (alias
// de AppColors.tipoXxx / AppColors.tipoXxxBg), que mapean a la escala
// Tailwind 600 para íconos y 100 para fondos. Cero hardcodes.
import 'package:flutter/material.dart';
import '../../../models/place.dart';
import '../../../utils/app_theme.dart';

Color qrTypeColor(Place place) {
  switch (place.tipo.toLowerCase()) {
    case 'hotel':               return AppTheme.tipoHotel;
    case 'restaurant':
    case 'gastronomia':         return AppTheme.tipoGastronomia;
    case 'bar':                 return AppTheme.tipoBar;
    case 'escenario_deportivo': return AppTheme.tipoDeportivo;
    case 'parque':
    case 'naturaleza':          return AppTheme.tipoNaturaleza;
    case 'cultura':
    case 'artesania':           return AppTheme.tipoArtesania;
    case 'playa':               return AppTheme.tipoPlaya;
    case 'ruta':                return AppTheme.tipoRuta;
    case 'compras':             return AppTheme.tipoCompras;
    default:                    return AppTheme.primary;
  }
}

Color qrTypeLightColor(Place place) {
  switch (place.tipo.toLowerCase()) {
    case 'hotel':               return AppTheme.tipoHotelBg;
    case 'restaurant':
    case 'gastronomia':         return AppTheme.tipoGastronomiaBg;
    case 'bar':                 return AppTheme.tipoBarBg;
    case 'escenario_deportivo': return AppTheme.tipoDeportivoBg;
    case 'parque':
    case 'naturaleza':          return AppTheme.tipoNaturalezaBg;
    case 'cultura':
    case 'artesania':           return AppTheme.tipoArtesaniaBg;
    case 'playa':               return AppTheme.tipoPLayaBg;
    case 'ruta':                return AppTheme.tipoRutaBg;
    case 'compras':             return AppTheme.tipoComprasBg;
    default:                    return AppTheme.tipoDefaultBg;
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
