// lib/pages/ruta_juegos_page.dart
// ============================================================
// PANTALLA RUTA OFICIAL JUEGOS 2027 — Nova App Móvil (NUEVA)
// ============================================================
// Datos hardcoded (itinerario de 3 días, operador) — per
// NOVA_MAPA_RUTAS_SCAN_RECOMPENSAS_PLAN.md PASO 5. El botón "Reservar
// ruta" muestra un diálogo informativo (sin backend de reservas aún).
//
// Fuente Boldonse no disponible en el paquete google_fonts instalado —
// se usa Open Sans ExtraBold como sustituto visual, igual que en los
// planes anteriores.
//
// Diseño Figma Septiembre 2026, node 8:2.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/design/app_colors.dart';

class _DiaItinerario {
  final String dia;
  final String lugar;
  final String descripcion;
  const _DiaItinerario(this.dia, this.lugar, this.descripcion);
}

const _kItinerario = [
  _DiaItinerario('Día 1', 'Llegada a Coveñas',
      'Recepción, check-in y tarde libre en Punta Bolívar.'),
  _DiaItinerario('Día 2', 'Santiago de Tolú y escenarios',
      'Recorrido por el malecón y visita a los escenarios deportivos de la sede.'),
  _DiaItinerario('Día 3', 'Sincelejo y cierre',
      'Ruta cultural en Sincelejo y despedida en la capital de Sucre.'),
];

const _kIncluye = [
  ('assets/icons/rutas/ic-entradas.svg', 'Entradas'),
  ('assets/icons/rutas/ic-transporte.svg', 'Transporte'),
  ('assets/icons/rutas/ic-hotel.svg', '2 noches'),
  ('assets/icons/rutas/ic-desayuno.svg', 'Desayunos'),
  ('assets/icons/rutas/ic-guia.svg', 'Guía local'),
  ('assets/icons/rutas/ic-seguro.svg', 'Seguro'),
];

class RutaJuegosPage extends StatelessWidget {
  const RutaJuegosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHero(context),
                    const SizedBox(height: 20),
                    _buildItinerario(),
                    const SizedBox(height: 24),
                    _buildQueIncluye(),
                    const SizedBox(height: 24),
                    _buildOperador(context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildBarraInferior(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 230,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
      ),
      child: Stack(
        children: [
          Positioned(left: 75, top: -60, child: _resplandor(140)),
          Positioned(left: 293, top: 0, child: _resplandor(160)),
          Positioned(left: 125, top: 120, child: _resplandor(180)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.bienvenidaAzul),
                    ),
                  ),
                  SvgPicture.asset('assets/images/logos/logo-juegos-nacionales-2027.svg', width: 92, height: 41),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Ruta oficial Juegos Nacionales 2027',
                style: GoogleFonts.openSans(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.bienvenidaAzul),
              ),
              const SizedBox(height: 6),
              Text(
                '3 días · Coveñas, Santiago de Tolú y Sincelejo',
                style: GoogleFonts.openSans(fontSize: 14, color: AppColors.bienvenidaTextoFuerte),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  SvgPicture.asset('assets/icons/ic-estrella.svg', width: 14),
                  const SizedBox(width: 6),
                  Text('4.9', style: GoogleFonts.openSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.bienvenidaTextoFuerte)),
                  const SizedBox(width: 4),
                  Text('(87 viajeros)', style: GoogleFonts.openSans(fontSize: 12, color: AppColors.textHint)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _resplandor(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.bienvenidaDorado.withValues(alpha: 0.18),
      ),
    );
  }

  Widget _buildItinerario() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Itinerario', style: GoogleFonts.openSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.bienvenidaVerde)),
          const SizedBox(height: 14),
          for (var i = 0; i < _kItinerario.length; i++) ...[
            _buildDiaItinerario(_kItinerario[i]),
            if (i != _kItinerario.length - 1) const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }

  Widget _buildDiaItinerario(_DiaItinerario d) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.bienvenidaBorde), borderRadius: BorderRadius.circular(14)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFFE6F2FA), borderRadius: BorderRadius.circular(10)),
            child: Text(d.dia, style: GoogleFonts.openSans(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.bienvenidaAzul)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(d.lugar, style: GoogleFonts.openSans(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.bienvenidaTextoFuerte)),
                const SizedBox(height: 4),
                Text(d.descripcion, style: GoogleFonts.openSans(fontSize: 12, color: AppColors.textSecondary, height: 17 / 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueIncluye() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Qué incluye', style: GoogleFonts.openSans(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.bienvenidaTextoFuerte)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 10,
            children: [
              for (final item in _kIncluye)
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 9, 14, 9),
                  decoration: BoxDecoration(border: Border.all(color: AppColors.bienvenidaBorde), borderRadius: BorderRadius.circular(999)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(item.$1, width: 14, height: 14),
                      const SizedBox(width: 8),
                      Text(item.$2, style: GoogleFonts.openSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.bienvenidaTextoFuerte)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOperador(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Operador', style: GoogleFonts.openSans(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.bienvenidaTextoFuerte)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.bienvenidaBorde), borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(color: Color(0xFFE6F2FA), shape: BoxShape.circle),
                      child: const Icon(Icons.apartment_rounded, color: AppColors.bienvenidaAzul, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Sucre Turismo Operador',
                              style: GoogleFonts.openSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.bienvenidaTextoFuerte)),
                          Text('Servicio local verificado',
                              style: GoogleFonts.openSans(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: const Color(0xFFE7F4EB), borderRadius: BorderRadius.circular(999)),
                      child: Text('Verificado', style: GoogleFonts.openSans(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.bienvenidaVerde)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _buildContacto(
                  icon: 'assets/icons/ic-whatsapp.svg',
                  etiqueta: 'WhatsApp',
                  accion: '+57 300 000 0000',
                  onTap: () => launchUrl(Uri.parse('https://wa.me/573000000000')),
                ),
                const SizedBox(height: 10),
                _buildContacto(
                  icon: 'assets/icons/ic-phone.svg',
                  etiqueta: 'Teléfono',
                  accion: '+57 300 000 0000',
                  onTap: () => launchUrl(Uri.parse('tel:+573000000000')),
                ),
                const SizedBox(height: 10),
                _buildContacto(
                  icon: 'assets/icons/ic-mail.svg',
                  etiqueta: 'Correo',
                  accion: 'contacto@sucreturismo.co',
                  onTap: () => launchUrl(Uri.parse('mailto:contacto@sucreturismo.co')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContacto({
    required String icon,
    required String etiqueta,
    required String accion,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: const Color(0xFFF7F9FB), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            SvgPicture.asset(icon, width: 20, height: 20),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(etiqueta, style: GoogleFonts.openSans(fontSize: 11, color: AppColors.textHint)),
                Text(accion, style: GoogleFonts.openSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.bienvenidaTextoFuerte)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarraInferior(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.bienvenidaBorde)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Consultar tarifa', style: GoogleFonts.openSans(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.bienvenidaTextoFuerte)),
                Text('por persona · 3 días', style: GoogleFonts.openSans(fontSize: 12, color: AppColors.textHint)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _mostrarDialogoReserva(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.bienvenidaVerde,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              elevation: 0,
            ),
            child: Text('Reservar ruta', style: GoogleFonts.openSans(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoReserva(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Próximamente'),
        content: const Text('Las reservas en línea de rutas turísticas estarán disponibles pronto. Contacta al operador para reservar por ahora.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Entendido')),
        ],
      ),
    );
  }
}
