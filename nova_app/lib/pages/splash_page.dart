import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../core/design/app_colors.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import 'permissions_page.dart';
import 'main_navigation_page.dart';

const _kLogoBlancoAsset = 'assets/images/logos/logo-nova-blanco.svg';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateNext();
  }

  // Sin sesión activa (sin token, o token inválido/expirado) siempre se
  // muestra el flujo de bienvenida completo (permisos → onboarding →
  // login) — no se recuerda si el usuario ya lo vio antes.
  Future<void> _navigateNext() async {
    // Ejecutamos splash y verificación de notificación en paralelo
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    // ── Verificar si la app fue abierta desde una notificación (app cerrada) ──
    // getInitialMessage() solo devuelve algo cuando el usuario tocó una
    // notificación FCM con la app completamente cerrada (terminated state).
    final initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      // La app se abrió por tap en notificación — interceptamos el flujo normal
      final municipio = initialMessage.data['municipio'] ?? '';
      final title     = initialMessage.notification?.title ?? '';
      final body      = initialMessage.notification?.body  ?? '';

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.keyToken);
      final tieneSession = token != null && token.isNotEmpty;

      if (!mounted) return;

      if (tieneSession) {
        // Usuario logueado → directo a recomendaciones
        Navigator.of(context).pushReplacementNamed(
          '/recomendaciones',
          arguments: municipio,
        );
      } else {
        // Sin sesión → preview público con info de los lugares
        Navigator.of(context).pushReplacementNamed(
          '/notificacion-preview',
          arguments: {
            'municipio': municipio,
            'title':     title,
            'body':      body,
          },
        );
      }
      return; // No continuar con el flujo normal de splash
    }

    // ── Flujo normal (app abierta sin notificación) ───────────────────────
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.keyToken);

    Widget destination;
    if (token != null && token.isNotEmpty) {
      // Un token guardado no basta: puede haber expirado o haber sido
      // revocado (logout en otro dispositivo, Sprint 4). Validarlo contra
      // el backend antes de entrar directo al Home.
      final valid = await AuthService.validateToken(token);
      if (!mounted) return;
      if (valid) {
        destination = const MainNavigationPage();
      } else {
        await AuthService.logout();
        destination = const PermissionsPage();
      }
    } else {
      destination = const PermissionsPage();
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bienvenidaAzul,
      body: Center(
        child: SvgPicture.asset(
          _kLogoBlancoAsset,
          width: 144,
          height: 84.82,
        ),
      ),
    );
  }
}
