// lib/widgets/charts/donut/donut_colors.dart
// Extraído de donut_chart_widget.dart (_getColor) sin cambiar valores.
import 'package:flutter/material.dart';
import 'package:nova_dashboard/utils/app_theme.dart';

// Antes: arcoíris de librería (Colors.green/orange/blue/red/purple).
// Ahora: variantes de teal/verde de la paleta NOVA (nova-charts §3).
const _donutColors = [
  AppTheme.primary, // primary teal
  AppTheme.primaryDark, // primaryDark
  Color(0xFF5EEAD4), // teal 300
  AppTheme.primaryGradientEnd, // cyan 600
  AppTheme.info, // info blue
  Color(0xFF94A9A7), // textMuted (neutro)
];

Color donutColorForIndex(int index) => _donutColors[index % _donutColors.length];
