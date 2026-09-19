/// Página "Acerca de Nova" — información institucional de la plataforma.
///
/// Diseño Figma Septiembre 2026 (node 42:571): marca, descripción de la
/// identidad de turismo integral, logos institucionales (Mincit,
/// Gobernación de Sucre) y un enlace a más información.
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/design/app_colors.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: SafeArea(
        child: Column(
          children: [
            _buildEncabezado(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildMarca(),
                    const SizedBox(height: 20),
                    _buildCajaDetalles(),
                    const SizedBox(height: 20),
                    _buildLogosInstitucionales(),
                    const SizedBox(height: 20),
                    _buildLinkMasInformacion(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEncabezado(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.bienvenidaBorde)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(color: AppColors.bienvenidaAzulClaro, shape: BoxShape.circle),
              child: Center(child: SvgPicture.asset('assets/icons/ic-flecha-atras.svg', width: 16)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Acerca de Nova',
                    style: GoogleFonts.openSans(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.bienvenidaTextoFuerte)),
                Text('Información de la plataforma',
                    style: GoogleFonts.openSans(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarca() {
    return Column(
      children: [
        SvgPicture.asset('assets/images/logos/logo-nova-verde.svg', width: 112, height: 67),
        const SizedBox(height: 8),
        Text('Nova Sucre',
            style: GoogleFonts.openSans(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.bienvenidaTextoFuerte)),
        Text('Versión 1.0.0',
            style: GoogleFonts.openSans(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildCajaDetalles() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.bienvenidaBorde),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Identidad de turismo integral',
              style: GoogleFonts.openSans(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.bienvenidaAzul)),
          const SizedBox(height: 12),
          Text(
            'Nova permite descubrir y gestionar lugares, escenarios deportivos '
            'y servicios de Coveñas, Santiago de Tolú y Sincelejo mediante QR.',
            style: GoogleFonts.openSans(fontSize: 13, height: 20 / 13, color: AppColors.bienvenidaTextoFuerte),
          ),
          const SizedBox(height: 12),
          Text(
            'Conéctate directamente con el patrimonio local, la gastronomía '
            'tradicional y vive los Juegos Nacionales y Paranacionales 2027.',
            style: GoogleFonts.openSans(fontSize: 13, height: 20 / 13, color: AppColors.bienvenidaTextoFuerte),
          ),
        ],
      ),
    );
  }

  Widget _buildLogosInstitucionales() {
    return Container(
      width: 180,
      height: 67,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.bienvenidaBorde),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/logos/logo-mincit.png', width: 69, height: 40, fit: BoxFit.contain),
          const SizedBox(width: 15),
          Image.asset('assets/images/logos/logo-gobernacion-sucre.png', width: 44, height: 44, fit: BoxFit.contain),
        ],
      ),
    );
  }

  Widget _buildLinkMasInformacion() {
    return GestureDetector(
      onTap: () => _openLink('https://www.sucre.gov.co'),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Más información',
              style: GoogleFonts.openSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.bienvenidaAzul,
                decoration: TextDecoration.underline,
              )),
          const SizedBox(width: 8),
          SvgPicture.asset('assets/icons/ic-external-link.svg', width: 14, height: 14),
        ],
      ),
    );
  }
}
