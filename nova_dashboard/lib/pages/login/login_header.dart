// lib/pages/login/login_header.dart
// Extraído de login_page.dart (logo badge + título + subtítulo) sin
// cambios de comportamiento ni de estilo.
import 'package:flutter/material.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(children: [

        // Logo badge con gradiente y sombra teal
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F766E), Color(0xFF06B6A4)],
              begin: Alignment.topLeft,
              end:   Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF06B6A4).withOpacity(0.40),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.qr_code_scanner_rounded,
            color: Colors.white,
            size: 32,
          ),
        ),

        const SizedBox(height: 18),

        // Título dos tonos: NOVA (negro bold) + Dashboard (slate ligero)
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'NOVA',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: 2.0,
                ),
              ),
              TextSpan(
                text: ' Dashboard',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  color: Color(0xFF475569),
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          'Panel de administración',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF94A3B8),
            letterSpacing: 0.2,
          ),
        ),
      ]),
    );
  }
}
