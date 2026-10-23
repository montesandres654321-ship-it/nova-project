// lib/pages/login/login_header.dart
// Logo badge + título + subtítulo — usa AppTheme como única fuente de verdad.
import 'package:nova_dashboard/utils/app_theme.dart';
import 'package:flutter/material.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(children: [

        // Logo badge con gradiente teal y sombra
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryDark, AppTheme.primary],
              begin: Alignment.topLeft,
              end:   Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.40),
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

        // Título: NOVA (bold oscuro) + Dashboard (ligero)
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: 'NOVA',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textHead,
                  letterSpacing: 2.0,
                ),
              ),
              TextSpan(
                text: ' Dashboard',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  color: AppTheme.textBody,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 6),

        Text(
          'Panel de administración',
          style: TextStyle(
            fontSize: 13,
            color: AppTheme.textMuted,
            letterSpacing: 0.2,
          ),
        ),
      ]),
    );
  }
}
