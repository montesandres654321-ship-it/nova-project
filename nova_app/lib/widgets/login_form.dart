// lib/widgets/login_form.dart
// ============================================================
// FORMULARIO DE LOGIN — Nova App Móvil
// ============================================================
// Widget puramente de presentación: no llama a ApiService/AuthService
// directamente — delega el submit a login_page mediante [onLoginPressed]
// y [onGooglePressed]. login_page sigue siendo dueño del estado de
// carga, los controllers y la lógica de autenticación.
//
// Diseño actualizado al Figma de Septiembre 2026 (NOVA_AUTH_PLAN.md,
// pantalla 06 · Login) — assets locales en assets/images y assets/icons.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design/app_colors.dart';
import '../utils/validators.dart';
import '../pages/register_page.dart';
import '../pages/forgot_password_page.dart';
import 'email_input.dart';
import 'password_input.dart';

class LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool rememberMe;
  final ValueChanged<bool> onRememberMeChanged;
  final bool isLoading;
  final VoidCallback onLoginPressed;
  final VoidCallback onGooglePressed;

  const LoginForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.rememberMe,
    required this.onRememberMeChanged,
    required this.isLoading,
    required this.onLoginPressed,
    required this.onGooglePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── ENCABEZADO ──────────────────────────────────────
          SvgPicture.asset(
            'assets/images/logos/logo-nova-verde.svg',
            width: 88,
            height: 52.585,
          ),
          const SizedBox(height: 10),
          Text(
            'Bienvenido a Sucre.',
            style: GoogleFonts.openSans(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.bienvenidaVerde,
              height: 33 / 26,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Entra y sigue descubriendo el departamento.',
            style: GoogleFonts.openSans(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 22 / 15,
            ),
          ),
          const SizedBox(height: 32),

          // ── FORMULARIO ──────────────────────────────────────
          EmailInput(
            controller: emailController,
            validator: Validators.email,
            figmaLabel: 'Correo electrónico',
            hintText: 'tucorreo@ejemplo.com',
          ),
          const SizedBox(height: 20),

          PasswordInput(
            controller: passwordController,
            validator: Validators.password,
            label: 'Contraseña',
            placeholder: '••••••••',
            figmaStyle: true,
            verticalPadding: 15,
          ),
          const SizedBox(height: 16),

          // Fila: Recordarme + ¿Olvidaste?
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              GestureDetector(
                onTap: () => onRememberMeChanged(!rememberMe),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: rememberMe
                            ? AppColors.bienvenidaVerde
                            : Colors.white,
                        border: Border.all(color: AppColors.bienvenidaBorde),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: rememberMe
                          ? Center(
                              child: SvgPicture.asset(
                                'assets/icons/ic-check.svg',
                                width: 12,
                                height: 12,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Recordarme',
                      style: GoogleFonts.openSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.bienvenidaTextoMedio,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
                ),
                child: Text(
                  '¿Olvidaste tu contraseña?',
                  style: GoogleFonts.openSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.bienvenidaAzul,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Botón Iniciar sesión
          SizedBox(
            width: double.infinity,
            height: 49,
            child: ElevatedButton(
              onPressed: isLoading ? null : onLoginPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bienvenidaAzul,
                disabledBackgroundColor:
                    AppColors.bienvenidaAzul.withValues(alpha: 0.55),
                shape: const StadiumBorder(),
                elevation: 0,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Iniciar sesión',
                      style: GoogleFonts.openSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 25 / 13,
                      ),
                    ),
            ),
          ),

          // ── SEPARADOR "o continúa con" ───────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Row(
              children: [
                const Expanded(
                    child: Divider(
                        color: AppColors.bienvenidaBorde, thickness: 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'o continúa con',
                    style: GoogleFonts.openSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textHint,
                      height: 17 / 12,
                    ),
                  ),
                ),
                const Expanded(
                    child: Divider(
                        color: AppColors.bienvenidaBorde, thickness: 1)),
              ],
            ),
          ),

          // ── BOTONES SOCIALES ─────────────────────────────────
          _buildBotonSocial(
            logo: 'assets/images/logos/logo-google.png',
            logoW: 21,
            logoH: 21,
            logoLeft: 20,
            texto: 'Continuar con Google',
            onTap: onGooglePressed,
          ),
          const SizedBox(height: 12),
          _buildBotonSocial(
            logo: 'assets/images/logos/logo-facebook.png',
            logoW: 23,
            logoH: 23,
            logoLeft: 19,
            texto: 'Continuar con Facebook',
            onTap: null, // deshabilitado por ahora
          ),
          const SizedBox(height: 12),
          _buildBotonSocial(
            logo: 'assets/images/logos/logo-apple.png',
            logoW: 25,
            logoH: 25,
            logoLeft: 17,
            texto: 'Continuar con Apple',
            onTap: null, // deshabilitado por ahora
          ),

          const SizedBox(height: 16),

          // ── MÓDULO JUEGOS NACIONALES 2027 ─────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bienvenidaFondoInput,
              border: Border.all(color: AppColors.bienvenidaBorde),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 44,
                  height: 62,
                  child: Stack(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/ic-juegos-grafico-1.svg',
                        width: 44,
                        height: 62,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: SvgPicture.asset(
                          'assets/icons/ic-juegos-grafico-2.svg',
                          width: 26,
                          height: 32,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Juegos Nacionales 2027',
                        style: GoogleFonts.openSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.bienvenidaDorado,
                          height: 22 / 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Accede a lugares, reservas, resultados, clasificaciones y seguimiento en vivo.',
                        style: GoogleFonts.openSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                          height: 18 / 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── PIE DE PÁGINA ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Wrap(
              alignment: WrapAlignment.center,
              children: [
                Text(
                  '¿Aún no tienes cuenta? ',
                  style: GoogleFonts.openSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  ),
                  child: Text(
                    'Regístrate',
                    style: GoogleFonts.openSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.bienvenidaVerde,
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

  // Botón social reutilizable (logo anclado a la izquierda, texto centrado
  // en el ancho total del botón — spec Figma node 2:2, icono left=17-20px
  // según el logo para que nunca se superponga con el texto)
  Widget _buildBotonSocial({
    required String logo,
    required double logoW,
    required double logoH,
    required double logoLeft,
    required String texto,
    VoidCallback? onTap,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.bienvenidaBorde),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: EdgeInsets.zero,
        minimumSize: const Size(double.infinity, 49),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: logoLeft,
            child: Image.asset(logo, width: logoW, height: logoH),
          ),
          Text(
            texto,
            style: GoogleFonts.openSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.bienvenidaTextoMedio,
              height: 19 / 10,
            ),
          ),
        ],
      ),
    );
  }
}
