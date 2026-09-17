import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/design/app_colors.dart';
import 'onboarding_page.dart';

const _kLogoVerdeUrl =
    'https://www.figma.com/api/mcp/asset/baf4c37f-0e17-4905-9818-d81d36c4e84b/4f980.svg';
const _kIconoMapaUrl =
    'https://www.figma.com/api/mcp/asset/baf4c37f-0e17-4905-9818-d81d36c4e84b/b04f3.svg';
const _kIconoEscudoUrl =
    'https://www.figma.com/api/mcp/asset/baf4c37f-0e17-4905-9818-d81d36c4e84b/61457.svg';
const _kIconoManosUrl =
    'https://www.figma.com/api/mcp/asset/baf4c37f-0e17-4905-9818-d81d36c4e84b/64496.svg';
const _kLogoMincitUrl =
    'https://www.figma.com/api/mcp/asset/baf4c37f-0e17-4905-9818-d81d36c4e84b/fb3bb.png';
const _kLogoGobernacionUrl =
    'https://www.figma.com/api/mcp/asset/baf4c37f-0e17-4905-9818-d81d36c4e84b/209d0.png';

class PermissionsPage extends StatelessWidget {
  const PermissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.network(
                    _kLogoVerdeUrl,
                    width: 88,
                    height: 52.585,
                  ),
                  const SizedBox(height: 30),
                  Text(
                    '¡Síguenos por nuestro\ndepartamento!',
                    style: GoogleFonts.openSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.bienvenidaVerde,
                      height: 35 / 28,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Column(
                    children: [
                      _buildBullet(
                        _kIconoMapaUrl,
                        33,
                        33,
                        'Usamos tu ubicación y datos de navegación para mostrarte hoteles, sitios y reservas cerca de ti.',
                      ),
                      const SizedBox(height: 28),
                      _buildBullet(
                        _kIconoEscudoUrl,
                        32,
                        34,
                        'Tu privacidad va primero. Solo usamos tu información para mejorar tu experiencia, nunca la compartimos sin tu permiso.',
                      ),
                      const SizedBox(height: 28),
                      _buildBullet(
                        _kIconoManosUrl,
                        34,
                        34,
                        'Al aceptar, nos ayudas a construir el mejor mapa de los tres municipios sede.',
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    'Con el respaldo de',
                    style: GoogleFonts.openSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.bienvenidaTextoFuerte,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 180,
                    height: 67,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.bienvenidaBorde),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 12),
                        Image.network(_kLogoMincitUrl, width: 69, height: 40),
                        const SizedBox(width: 15),
                        Image.network(
                          _kLogoGobernacionUrl,
                          width: 44,
                          height: 44,
                        ),
                        const SizedBox(width: 12),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const OnboardingPage()),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bienvenidaAzul,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: const StadiumBorder(),
                  ),
                  child: Text(
                    'Continuar',
                    style: GoogleFonts.openSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 26 / 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBullet(String iconUrl, double w, double h, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.network(iconUrl, width: w, height: h),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.openSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.bienvenidaTextoMedio,
              height: 22 / 14,
            ),
          ),
        ),
      ],
    );
  }
}
