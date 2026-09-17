// lib/pages/place_details/place_details_tokens.dart
// Tokens de color compartidos por place_details_page.dart y sus widgets.
import 'package:flutter/material.dart';

const kPlaceDetailsPrimary   = Color(0xFF06B6A4);
const kPlaceDetailsBgPage    = Color(0xFFF1F5F9);
const kPlaceDetailsTextHead  = Color(0xFF0F172A);
const kPlaceDetailsTextMuted = Color(0xFF64748B);
const kPlaceDetailsTextSub   = Color(0xFF94A3B8);
const kPlaceDetailsBorder    = Color(0xFFE2E8F0);
const kPlaceDetailsBlue      = Color(0xFF3B82F6);
const kPlaceDetailsGreen     = Color(0xFF10B981);
const kPlaceDetailsAmber     = Color(0xFFF59E0B);

Color placeDetailsTypeColor(String tipo) {
  switch (tipo.toLowerCase()) {
    case 'hotel':      return kPlaceDetailsBlue;
    case 'restaurant': return kPlaceDetailsGreen;
    case 'bar':        return kPlaceDetailsAmber;
    default:           return kPlaceDetailsTextSub;
  }
}

IconData placeDetailsTypeIcon(String tipo) {
  switch (tipo.toLowerCase()) {
    case 'hotel':      return Icons.hotel_rounded;
    case 'restaurant': return Icons.restaurant_rounded;
    case 'bar':        return Icons.local_bar_rounded;
    default:           return Icons.place_rounded;
  }
}
