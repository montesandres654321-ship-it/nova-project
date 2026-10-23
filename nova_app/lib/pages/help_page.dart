/// Página "Ayuda y Soporte" de Nova App.
///
/// Muestra preguntas frecuentes (FAQ) con expansión acordeón,
/// datos de contacto y enlace a redes sociales.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design/app_colors.dart';

// ── Modelo FAQ ────────────────────────────────────────────────
class _Faq {
  final String pregunta;
  final String respuesta;
  const _Faq(this.pregunta, this.respuesta);
}

const _kFaqs = [
  _Faq(
    '¿Cómo escaneo un código QR?',
    'Abre Nova y pulsa el ícono de escáner en la pantalla principal. Apunta la cámara al código QR visible en el establecimiento y espera a que se registre automáticamente. Asegúrate de tener buena iluminación y que el código esté completo en el encuadre.',
  ),
  _Faq(
    '¿Cómo acumulo puntos y recompensas?',
    'Cada vez que escaneas el código QR de un establecimiento participante acumulas puntos. La cantidad de puntos varía según el establecimiento y la categoría. Puedes ver tus puntos acumulados en la sección "Perfil" de la app.',
  ),
  _Faq(
    '¿Puedo usar Nova sin conexión a internet?',
    'Algunas secciones como el mapa y el contenido ya visitado funcionan con datos en caché. Sin embargo, el escaneo de códigos QR, la actualización de recompensas y tu perfil requieren conexión activa.',
  ),
  _Faq(
    '¿Cómo cambio mi contraseña?',
    'Ve a tu Perfil → "Ir a Ajustes de la Cuenta" → "Cambiar contraseña". Necesitarás tu contraseña actual para poder cambiarla. Si ingresaste con Google, esta opción no estará disponible ya que la contraseña es gestionada por Google.',
  ),
  _Faq(
    '¿Qué hago si un establecimiento no aparece en el mapa?',
    'Es posible que el establecimiento aún no esté registrado en la plataforma. Puedes reportarlo usando el correo de soporte para que evaluemos su inclusión. Los datos del mapa se actualizan periódicamente.',
  ),
  _Faq(
    '¿Es seguro compartir mis datos con Nova?',
    'Sí. Nova protege tu información de acuerdo con las leyes colombianas de protección de datos. Solo recopilamos la información necesaria para tu experiencia turística y nunca la vendemos a terceros. Consulta nuestra política en Términos y Condiciones.',
  ),
  _Faq(
    '¿Cómo elimino mi cuenta?',
    'Actualmente puedes solicitar la eliminación de tu cuenta escribiendo al correo soporte@novaapp.com.co con el asunto "Eliminar cuenta". Procesaremos tu solicitud en un plazo máximo de 5 días hábiles.',
  ),
  _Faq(
    '¿La app funciona en iOS?',
    'Por ahora Nova está disponible exclusivamente para Android. Estamos trabajando en la versión para iOS y la anunciaremos próximamente en nuestras redes sociales.',
  ),
];

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  int? _expanded;

  static const _kEmail = 'soporte@novaapp.com.co';

  void _copyEmail(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: _kEmail));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Correo copiado: $_kEmail',
            style: GoogleFonts.openSans(fontSize: 13)),
        backgroundColor: AppColors.bienvenidaAzul,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner de contacto rápido
                    _buildContactoBanner(context),
                    const SizedBox(height: 24),

                    // FAQ
                    _buildSectionLabel('PREGUNTAS FRECUENTES'),
                    const SizedBox(height: 10),
                    _buildFaqCard(),

                    const SizedBox(height: 24),
                    _buildSectionLabel('TAMBIÉN PUEDES ENCONTRARNOS EN'),
                    const SizedBox(height: 10),
                    _buildRedesCard(),
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
                Text('Ayuda y Soporte',
                    style: GoogleFonts.openSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.bienvenidaTextoFuerte)),
                Text('Resolvemos tus dudas',
                    style: GoogleFonts.openSans(
                        fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactoBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.bienvenidaAzul, Color(0xFF1A6BAD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.headset_mic_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('¿Necesitas ayuda directa?',
                    style: GoogleFonts.openSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                const SizedBox(height: 3),
                Text('Escríbenos y te respondemos en 24 h hábiles.',
                    style: GoogleFonts.openSans(
                        fontSize: 12, color: Colors.white.withValues(alpha: 0.85))),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _copyEmail(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset('assets/icons/ic-mail.svg',
                            width: 14, height: 14,
                            colorFilter: const ColorFilter.mode(
                                AppColors.bienvenidaAzul, BlendMode.srcIn)),
                        const SizedBox(width: 6),
                        Text(_kEmail,
                            style: GoogleFonts.openSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.bienvenidaAzul)),
                        const SizedBox(width: 8),
                        const Icon(Icons.copy_rounded,
                            size: 13, color: AppColors.bienvenidaAzul),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(text,
        style: GoogleFonts.openSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 0.5));
  }

  Widget _buildFaqCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.bienvenidaBorde),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: List.generate(_kFaqs.length, (i) {
          final faq = _kFaqs[i];
          final isExpanded = _expanded == i;
          return Column(
            children: [
              InkWell(
                onTap: () => setState(() => _expanded = isExpanded ? null : i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          faq.pregunta,
                          style: GoogleFonts.openSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isExpanded
                                  ? AppColors.bienvenidaAzul
                                  : AppColors.bienvenidaTextoFuerte),
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(Icons.keyboard_arrow_down_rounded,
                            size: 20,
                            color: isExpanded
                                ? AppColors.bienvenidaAzul
                                : AppColors.textHint),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  color: AppColors.bienvenidaAzulClaro.withValues(alpha: 0.5),
                  child: Text(
                    faq.respuesta,
                    style: GoogleFonts.openSans(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.6),
                  ),
                ),
                crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
              if (i < _kFaqs.length - 1)
                const Divider(height: 1, thickness: 1, color: AppColors.bienvenidaBorde),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildRedesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.bienvenidaBorde),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildRedRow(
            icon: Icons.alternate_email_rounded,
            red: 'Instagram',
            handle: '@novaapp.co',
            color: const Color(0xFFE1306C),
          ),
          const Divider(height: 20, thickness: 1, color: AppColors.bienvenidaBorde),
          _buildRedRow(
            icon: Icons.facebook_rounded,
            red: 'Facebook',
            handle: 'Nova App Colombia',
            color: const Color(0xFF1877F2),
          ),
          const Divider(height: 20, thickness: 1, color: AppColors.bienvenidaBorde),
          _buildRedRow(
            icon: Icons.chat_bubble_rounded,
            red: 'WhatsApp',
            handle: '+57 300 000 0000',
            color: const Color(0xFF25D366),
          ),
        ],
      ),
    );
  }

  Widget _buildRedRow({
    required IconData icon,
    required String red,
    required String handle,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(red,
                  style: GoogleFonts.openSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.bienvenidaTextoFuerte)),
              Text(handle,
                  style: GoogleFonts.openSans(
                      fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}
