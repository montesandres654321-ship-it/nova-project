// lib/pages/places/places_tokens.dart
// Tokens de color compartidos entre list_tab.dart y los widgets extraídos
// de él (consistentes con stats_dashboard_page, igual que antes).
import 'package:flutter/material.dart';

const kPlacesPrimary   = Color(0xFF06B6A4);
const kPlacesBgPage    = Color(0xFFF1F5F9);
const kPlacesTextHead  = Color(0xFF0F172A);
const kPlacesTextMuted = Color(0xFF64748B);
const kPlacesTextSub   = Color(0xFF94A3B8);
const kPlacesBorder    = Color(0xFFE2E8F0);
const kPlacesBlue      = Color(0xFF3B82F6);
const kPlacesGreen     = Color(0xFF10B981);
const kPlacesAmber     = Color(0xFFF59E0B);
const kPlacesRed       = Color(0xFFEF4444);
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
