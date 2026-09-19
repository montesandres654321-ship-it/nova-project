// lib/pages/place_details/place_details_tokens.dart
// Tokens de color compartidos por place_details_page.dart y sus widgets.
import 'package:nova_dashboard/utils/app_theme.dart';
import 'package:flutter/material.dart';

const kPlaceDetailsPrimary   = AppTheme.primary;
const kPlaceDetailsBgPage    = AppTheme.slateBgPage;
const kPlaceDetailsTextHead  = AppTheme.slateTextHead;
const kPlaceDetailsTextMuted = AppTheme.slateTextMuted;
const kPlaceDetailsTextSub   = AppTheme.slateTextSub;
const kPlaceDetailsBorder    = AppTheme.slateBorder;
const kPlaceDetailsBlue      = AppTheme.slateBlue;
const kPlaceDetailsGreen     = AppTheme.slateGreen;
const kPlaceDetailsAmber     = AppTheme.slateAmber;

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
