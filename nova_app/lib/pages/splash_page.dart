import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

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
