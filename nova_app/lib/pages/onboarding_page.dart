import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/design/app_colors.dart';
import 'login_page.dart';

// Slide 1 · Descubre
const _kFotoDescubreAsset = 'assets/images/onboarding/foto-covenas-tolu-sincelejo.png';
const _kOverlayDescubreAsset = 'assets/images/onboarding/overlay-foto.png';
const _kLogoBlancoDescubreAsset = 'assets/images/logos/logo-nova-blanco-m.svg';

// Slide 2 · Vive
const _kFotoViveAsset = 'assets/images/onboarding/foto-sucre-sincelejo.png';
const _kOverlayViveAsset = 'assets/images/onboarding/overlay-foto.png';
// Mismo logo "Nova blanco M" que en el slide Descubre (Figma exportó un ID
// distinto por estar en otro frame, pero es el mismo asset visual).
const _kLogoBlancoViveAsset = 'assets/images/logos/logo-nova-blanco-m.svg';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _nextPage() {
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // El onboarding solo se muestra cuando splash ya determinó que no hay
  // sesión activa (ver splash_page.dart), así que siempre termina en login.
  void _finishOnboarding() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        children: [
          _DescubreSlide(onContinue: _nextPage),
          _ViveSlide(onFinish: _finishOnboarding),
        ],
      ),
    );
  }
}

Widget _buildDots({
  required int currentIndex,
  required Color activeColor,
  required Color inactiveColor,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(2, (i) {
        final isActive = i == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: isActive ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    ),
  );
}

class _DescubreSlide extends StatelessWidget {
  const _DescubreSlide({required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 386,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(_kFotoDescubreAsset, fit: BoxFit.cover),
              Image.asset(_kOverlayDescubreAsset, fit: BoxFit.cover),
              Positioned(
                left: 253,
                top: 295,
                child: SvgPicture.asset(
                  _kLogoBlancoDescubreAsset,
                  width: 112,
                  height: 65.825,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 35, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'De la sabana al mar, en la palma de tu mano.',
                style: GoogleFonts.openSans(
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                  color: AppColors.bienvenidaVerde,
                  height: 30 / 23,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Escenarios, restaurantes, parques, artesanías y hospedaje en las tres sedes.',
                style: GoogleFonts.openSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.bienvenidaTextoMedio,
                  height: 22 / 14,
                ),
              ),
            ],
          ),
        ),
        const Expanded(child: SizedBox()),
        _buildDots(
          currentIndex: 0,
          activeColor: AppColors.bienvenidaVerde,
          inactiveColor: AppColors.bienvenidaDotInactivo,
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bienvenidaAzul,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: const StadiumBorder(),
              ),
              child: Text(
                'Continuar',
                style: GoogleFonts.openSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _ViveSlide extends StatelessWidget {
  const _ViveSlide({required this.onFinish});

  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 386,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(_kFotoViveAsset, fit: BoxFit.cover),
              Image.asset(_kOverlayViveAsset, fit: BoxFit.cover),
              Positioned(
                left: 253,
                top: 295,
                child: SvgPicture.asset(
                  _kLogoBlancoViveAsset,
                  width: 112,
                  height: 65.825,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 35, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sucre es mucho más que sol y playa.',
                style: GoogleFonts.openSans(
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                  color: AppColors.bienvenidaVerde,
                  height: 30 / 23,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Explora restaurantes, platos típicos, parques, compras, artesanías, alojamiento, rutas y servicios.',
                style: GoogleFonts.openSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.bienvenidaTextoMedio,
                  height: 22 / 14,
                ),
              ),
            ],
          ),
        ),
        const Expanded(child: SizedBox()),
        _buildDots(
          currentIndex: 1,
          activeColor: AppColors.bienvenidaVerde,
          inactiveColor: AppColors.bienvenidaDotInactivo,
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onFinish,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bienvenidaAzul,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: const StadiumBorder(),
              ),
              child: Text(
                'Empezar',
                style: GoogleFonts.openSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
