import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/design/app_colors.dart';
import '../utils/constants.dart';
import 'login_page.dart';
import 'main_navigation_page.dart';

// Slide 1 · Juegos Nacionales 2027
const _kResplandorAmarilloUrl =
    'https://www.figma.com/api/mcp/asset/adaf1d75-b547-461e-9a78-e1702b61e09b/8140d.svg';
const _kResplandorAzulUrl =
    'https://www.figma.com/api/mcp/asset/adaf1d75-b547-461e-9a78-e1702b61e09b/3acb3.svg';
const _kResplandorVerdeUrl =
    'https://www.figma.com/api/mcp/asset/adaf1d75-b547-461e-9a78-e1702b61e09b/74af4.svg';
const _kIlustracionJuegosUrl =
    'https://www.figma.com/api/mcp/asset/adaf1d75-b547-461e-9a78-e1702b61e09b/a50fc.svg';
const _kLogoJuegosUrl =
    'https://www.figma.com/api/mcp/asset/adaf1d75-b547-461e-9a78-e1702b61e09b/ef0b6.svg';

// Slide 2 · Descubre
const _kFotoDescubreUrl =
    'https://www.figma.com/api/mcp/asset/d4b27e73-70b6-4c6d-8aa2-bfc08f9f53d5/a2e6c.png';
const _kOverlayDescubreUrl =
    'https://www.figma.com/api/mcp/asset/d4b27e73-70b6-4c6d-8aa2-bfc08f9f53d5/1ad03.png';
const _kLogoBlancoDescubreUrl =
    'https://www.figma.com/api/mcp/asset/d4b27e73-70b6-4c6d-8aa2-bfc08f9f53d5/45af4.svg';

// Slide 3 · Vive
const _kFotoViveUrl =
    'https://www.figma.com/api/mcp/asset/6115a06f-36f6-492e-baee-9eee424608d3/39831.png';
const _kOverlayViveUrl =
    'https://www.figma.com/api/mcp/asset/6115a06f-36f6-492e-baee-9eee424608d3/1ad03.png';
const _kLogoBlancoViveUrl =
    'https://www.figma.com/api/mcp/asset/6115a06f-36f6-492e-baee-9eee424608d3/049e8.svg';

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

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    final hasToken = (prefs.getString(AppConstants.keyToken) ?? '').isNotEmpty;
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            hasToken ? const MainNavigationPage() : const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        children: [
          _JuegosSlide(onContinue: _nextPage),
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
      children: List.generate(3, (i) {
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

class _JuegosSlide extends StatelessWidget {
  const _JuegosSlide({required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: double.infinity,
              height: 381,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Positioned(
                    left: 260,
                    top: -21,
                    child: SvgPicture.network(
                      _kResplandorAmarilloUrl,
                      width: 180,
                      height: 180,
                    ),
                  ),
                  Positioned(
                    left: -62,
                    top: 203,
                    child: SvgPicture.network(
                      _kResplandorAzulUrl,
                      width: 183,
                      height: 183,
                    ),
                  ),
                  Positioned(
                    left: 249,
                    top: 256,
                    child: SvgPicture.network(
                      _kResplandorVerdeUrl,
                      width: 202,
                      height: 202,
                    ),
                  ),
                  Positioned(
                    left: 70,
                    top: 12,
                    child: SvgPicture.network(
                      _kIlustracionJuegosUrl,
                      width: 370,
                      height: 536,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 16,
              top: 19,
              child: SvgPicture.network(
                _kLogoJuegosUrl,
                width: 109,
                height: 49,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 36, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'La app oficial para vivir el evento y descubrir el departamento.',
                style: GoogleFonts.openSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.bienvenidaVerde,
                  height: 30 / 20,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Compara agenda, disciplinas, escenarios y rutas de Coveñas, Santiago de Tolú y Sincelejo antes y después de cada competencia.',
                style: GoogleFonts.openSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.bienvenidaTextoMedio,
                  height: 22 / 15,
                ),
              ),
            ],
          ),
        ),
        const Expanded(child: SizedBox()),
        _buildDots(
          currentIndex: 0,
          activeColor: AppColors.bienvenidaDorado,
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
                backgroundColor: AppColors.bienvenidaDorado,
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
              Image.network(_kFotoDescubreUrl, fit: BoxFit.cover),
              Image.network(_kOverlayDescubreUrl, fit: BoxFit.cover),
              Positioned(
                left: 253,
                top: 295,
                child: SvgPicture.network(
                  _kLogoBlancoDescubreUrl,
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
              Image.network(_kFotoViveUrl, fit: BoxFit.cover),
              Image.network(_kOverlayViveUrl, fit: BoxFit.cover),
              Positioned(
                left: 253,
                top: 295,
                child: SvgPicture.network(
                  _kLogoBlancoViveUrl,
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
          currentIndex: 2,
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
