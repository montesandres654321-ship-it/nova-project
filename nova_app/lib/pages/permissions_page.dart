import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/design/app_colors.dart';
import 'onboarding_page.dart';

const _kLogoVerdeAsset = 'assets/images/logos/logo-nova-verde.svg';
const _kIconoMapaAsset = 'assets/icons/ic-mapa.svg';
const _kIconoEscudoAsset = 'assets/icons/ic-escudo.svg';
const _kIconoManosAsset = 'assets/icons/ic-manos.svg';
const _kLogoMincitAsset = 'assets/images/logos/logo-mincit.png';
const _kLogoGobernacionAsset = 'assets/images/logos/logo-gobernacion-sucre.png';

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
                  SvgPicture.asset(
                    _kLogoVerdeAsset,
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
                        _kIconoMapaAsset,
                        33,
                        33,
                        'Usamos tu ubicación y datos de navegación para mostrarte hoteles, sitios y reservas cerca de ti.',
                      ),
                      const SizedBox(height: 28),
                      _buildBullet(
                        _kIconoEscudoAsset,
                        32,
                        34,
                        'Tu privacidad va primero. Solo usamos tu información para mejorar tu experiencia, nunca la compartimos sin tu permiso.',
                      ),
                      const SizedBox(height: 28),
                      _buildBullet(
                        _kIconoManosAsset,
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
                        Image.asset(_kLogoMincitAsset, width: 69, height: 40),
                        const SizedBox(width: 15),
                        Image.asset(
                          _kLogoGobernacionAsset,
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

  Widget _buildBullet(String iconAsset, double w, double h, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(iconAsset, width: w, height: h),
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
