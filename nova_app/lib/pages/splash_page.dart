import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/design/app_colors.dart';
import 'permissions_page.dart';
import 'main_navigation_page.dart';

const _kLogoBlancoUrl =
    'https://www.figma.com/api/mcp/asset/b6c2b25d-2adf-489f-82ab-cd1bd96e362d/e5f41.svg';

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

  Future<void> _navigateNext() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    final prefs = await SharedPreferences.getInstance();
    final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => onboardingComplete
            ? const MainNavigationPage()
            : const PermissionsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bienvenidaAzul,
      body: Center(
        child: SvgPicture.network(
          _kLogoBlancoUrl,
          width: 144,
          height: 84.82,
        ),
      ),
    );
  }
}
