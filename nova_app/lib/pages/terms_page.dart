/// Página "Términos y Condiciones" de Nova App.
///
/// Contenido estático — texto legal básico ajustado a la plataforma
/// de turismo digital del Golfo de Morrosquillo, Sucre.
/// Cuando haya un endpoint de CMS, reemplazar _kSecciones con una
/// llamada al backend y envolver en FutureBuilder.
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design/app_colors.dart';

// ── Modelo de sección ─────────────────────────────────────────
class _Seccion {
  final String titulo;
  final String cuerpo;
  const _Seccion(this.titulo, this.cuerpo);
}

const _kSecciones = [
  _Seccion(
    '1. Aceptación de los términos',
    'Al descargar, instalar o usar la aplicación Nova, aceptas quedar vinculado por estos Términos y Condiciones. Si no estás de acuerdo con alguna parte de estos términos, no debes usar la aplicación.',
  ),
  _Seccion(
    '2. Descripción del servicio',
    'Nova es una plataforma digital de turismo que facilita la conexión entre turistas y establecimientos del Golfo de Morrosquillo, Sucre, Colombia. A través de la app puedes escanear códigos QR en establecimientos participantes, acumular recompensas y acceder a información turística de la región.',
  ),
  _Seccion(
    '3. Registro y cuenta de usuario',
    'Para acceder a todas las funciones de Nova debes crear una cuenta con información verídica. Eres responsable de mantener la confidencialidad de tus credenciales y de todas las actividades realizadas desde tu cuenta. Debes notificarnos de inmediato ante cualquier uso no autorizado.',
  ),
  _Seccion(
    '4. Uso aceptable',
    'Aceptas usar Nova únicamente para fines lícitos y de acuerdo con estos términos. Está prohibido: (a) usar la aplicación de manera que viole leyes o regulaciones locales, nacionales o internacionales; (b) manipular el sistema de recompensas de forma fraudulenta; (c) intentar acceder sin autorización a sistemas o redes de Nova.',
  ),
  _Seccion(
    '5. Sistema de recompensas',
    'Las recompensas acumuladas en Nova tienen valor dentro de la plataforma y los establecimientos participantes. Nova se reserva el derecho de modificar, suspender o cancelar el programa de recompensas con previo aviso. Las recompensas no son canjeables por dinero en efectivo.',
  ),
  _Seccion(
    '6. Privacidad y datos personales',
    'La recolección y uso de tu información personal se rige por nuestra Política de Privacidad, que forma parte integral de estos términos. Tus datos son utilizados exclusivamente para mejorar tu experiencia en la plataforma y no son compartidos con terceros sin tu consentimiento, salvo las excepciones contempladas en la ley.',
  ),
  _Seccion(
    '7. Propiedad intelectual',
    'Todo el contenido de Nova —incluyendo logos, textos, imágenes, diseño y código— es propiedad de Nova o sus licenciantes y está protegido por las leyes de propiedad intelectual vigentes en Colombia. Queda prohibida su reproducción sin autorización expresa.',
  ),
  _Seccion(
    '8. Limitación de responsabilidad',
    'Nova no se responsabiliza por: (a) interrupciones del servicio por mantenimiento o fuerza mayor; (b) información inexacta proporcionada por establecimientos terceros; (c) daños indirectos derivados del uso de la aplicación. Hacemos nuestro mejor esfuerzo para garantizar la disponibilidad y precisión de la información.',
  ),
  _Seccion(
    '9. Modificaciones',
    'Nos reservamos el derecho de modificar estos términos en cualquier momento. Las modificaciones entrarán en vigor al momento de su publicación en la aplicación. El uso continuado de Nova después de la publicación de los cambios constituye tu aceptación de los mismos.',
  ),
  _Seccion(
    '10. Ley aplicable',
    'Estos términos se rigen por las leyes de la República de Colombia. Cualquier controversia derivada del uso de Nova será sometida a los tribunales competentes de la ciudad de Sincelejo, Sucre.',
  ),
  _Seccion(
    '11. Contacto',
    'Si tienes preguntas sobre estos Términos y Condiciones, puedes contactarnos a través del correo soporte@novaapp.com.co o desde la sección "Ayuda y Soporte" de la aplicación.',
  ),
];

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fecha de actualización
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFE082)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              size: 16, color: Color(0xFFB8860B)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Última actualización: octubre 2026',
                              style: GoogleFonts.openSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFB8860B)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Introducción
                    Text(
                      'Bienvenido a Nova, la plataforma oficial de turismo digital del Golfo de Morrosquillo. '
                      'Antes de usar nuestra aplicación, te pedimos leer detenidamente los siguientes términos.',
                      style: GoogleFonts.openSans(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.65),
                    ),
                    const SizedBox(height: 24),

                    // Secciones
                    ...List.generate(_kSecciones.length, (i) {
                      final s = _kSecciones[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.titulo,
                              style: GoogleFonts.openSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.bienvenidaTextoFuerte),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              s.cuerpo,
                              style: GoogleFonts.openSans(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  height: 1.65),
                            ),
                            if (i < _kSecciones.length - 1) ...[
                              const SizedBox(height: 16),
                              const Divider(color: AppColors.bienvenidaBorde),
                            ],
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 8),
                    // Footer
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.bienvenidaAzulClaro,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        '© 2026 Nova App — Plataforma de Turismo Digital del Golfo de Morrosquillo, Sucre, Colombia.',
                        style: GoogleFonts.openSans(
                            fontSize: 11,
                            color: AppColors.bienvenidaAzul,
                            height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
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
              decoration: const BoxDecoration(
                  color: AppColors.bienvenidaAzulClaro, shape: BoxShape.circle),
              child: Center(
                  child: SvgPicture.asset('assets/icons/ic-flecha-atras.svg', width: 16)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Términos y Condiciones',
                    style: GoogleFonts.openSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.bienvenidaTextoFuerte)),
                Text('Políticas de uso de la plataforma',
                    style: GoogleFonts.openSans(
                        fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
