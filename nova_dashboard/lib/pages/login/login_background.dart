// lib/pages/login/login_background.dart
// Extraído de login_page.dart (fondo gradiente + círculos decorativos)
// sin cambios de comportamiento ni de estilo.
import 'package:flutter/material.dart';

class LoginBackground extends StatelessWidget {
  const LoginBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      // ── 1. FONDO GRADIENTE 3 COLORES ─────────────────
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end:   Alignment.bottomRight,
            colors: [
              Color(0xFF0F766E), // teal oscuro
              Color(0xFF06B6A4), // primary
              Color(0xFF67E8F9), // light accent
            ],
          ),
        ),
      ),

      // ── 2. CÍRCULOS DECORATIVOS SUTILES ───────────────
      Positioned(
        top: -100, right: -80,
        child: Container(
          width: 300, height: 300,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.06),
          ),
        ),
      ),
      Positioned(
        bottom: -80, left: -60,
        child: Container(
          width: 240, height: 240,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.06),
          ),
        ),
      ),
      Positioned(
        top: 120, left: 50,
        child: Container(
          width: 70, height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.04),
          ),
        ),
      ),
    ]);
  }
}
