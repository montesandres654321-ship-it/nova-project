// lib/pages/places/places_tokens.dart
// Tokens de color compartidos entre list_tab.dart y los widgets extraídos
// de él (consistentes con stats_dashboard_page, igual que antes).
import 'package:nova_dashboard/utils/app_theme.dart';
import 'package:flutter/material.dart';

const kPlacesPrimary   = AppTheme.primary;
const kPlacesBgPage    = AppTheme.slateBgPage;
const kPlacesTextHead  = AppTheme.slateTextHead;
const kPlacesTextMuted = AppTheme.slateTextMuted;
const kPlacesTextSub   = AppTheme.slateTextSub;
const kPlacesBorder    = AppTheme.slateBorder;
const kPlacesBlue      = AppTheme.slateBlue;
const kPlacesGreen     = AppTheme.slateGreen;
const kPlacesAmber     = AppTheme.slateAmber;
const kPlacesRed       = AppTheme.slateRed;
const kPlacesTeal      = Color(0xFF14B8A6);
const kPlacesPurple    = Color(0xFF8B5CF6);
const kPlacesCyan      = Color(0xFF0EA5E9);
const kPlacesIndigo    = Color(0xFF6366F1);
const kPlacesPink      = Color(0xFFEC4899);

Color placeTypeColor(String tipo) {
  switch (tipo.toLowerCase()) {
    case 'hotel':               return kPlacesBlue;
    case 'restaurant':
    case 'gastronomia':         return kPlacesGreen;
    case 'bar':                 return kPlacesAmber;
    case 'escenario_deportivo': return kPlacesRed;
    case 'parque':
    case 'naturaleza':          return kPlacesTeal;
    case 'cultura':
    case 'artesania':           return kPlacesPurple;
    case 'playa':               return kPlacesCyan;
    case 'ruta':                return kPlacesIndigo;
    case 'compras':             return kPlacesPink;
    default:                    return kPlacesTextSub;
  }
}
