// lib/widgets/charts/donut/donut_colors.dart
// Extraído de donut_chart_widget.dart (_getColor) sin cambiar valores.
import 'package:flutter/material.dart';

// Antes: arcoíris de librería (Colors.green/orange/blue/red/purple).
// Ahora: variantes de teal/verde de la paleta NOVA (nova-charts §3).
const _donutColors = [
  Color(0xFF06B6A4), // primary teal
  Color(0xFF048577), // primaryDark
  Color(0xFF5EEAD4), // teal 300
  Color(0xFF0891B2), // cyan 600
  Color(0xFF2563EB), // info blue
  Color(0xFF94A9A7), // textMuted (neutro)
];

Color donutColorForIndex(int index) => _donutColors[index % _donutColors.length];
