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
          const SizedBox(height: 8),
          Text(
            'Bienvenido a Sucre.',
            style: GoogleFonts.openSans(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.bienvenidaVerde,
              height: 33 / 26,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Entra y sigue descubriendo el departamento.',
            style: GoogleFonts.openSans(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 22 / 15,
            ),
          ),
          const SizedBox(height: 24),

          // ── FORMULARIO ──────────────────────────────────────
          EmailInput(
            controller: emailController,
            validator: Validators.email,
            figmaLabel: 'Correo electrónico',
            hintText: 'tucorreo@ejemplo.com',
          ),
          const SizedBox(height: 16),

          PasswordInput(
            controller: passwordController,
            validator: Validators.password,
            label: 'Contraseña',
            placeholder: '••••••••',
            figmaStyle: true,
            verticalPadding: 15,
          ),
          const SizedBox(height: 14),

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
          const SizedBox(height: 16),

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
            padding: const EdgeInsets.symmetric(vertical: 16),
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
          // 3 botones cuadrados lado a lado (icono arriba, label abajo)
          // en vez de fila vertical — evita cualquier superposición
          // icono/texto y ahorra espacio vertical en pantallas chicas.
          Row(
            children: [
              Expanded(
                child: _buildBotonSocialIcono(
                  logo: 'assets/images/logos/logo-google.png',
                  fallbackIcon: Icons.g_mobiledata,
                  fallbackColor: const Color(0xFF4285F4),
                  label: 'Google',
                  onTap: onGooglePressed,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildBotonSocialIcono(
                  logo: 'assets/images/logos/logo-facebook.png',
                  fallbackIcon: Icons.facebook,
                  fallbackColor: const Color(0xFF1877F2),
                  label: 'Facebook',
                  onTap: null, // deshabilitado por ahora
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildBotonSocialIcono(
                  logo: 'assets/images/logos/logo-apple.png',
                  fallbackIcon: Icons.apple,
                  fallbackColor: Colors.black,
                  label: 'Apple',
                  onTap: null, // deshabilitado por ahora
                ),
              ),
            ],
          ),

          // ── PIE DE PÁGINA ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
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

  // Botón social cuadrado (icono arriba, label abajo) — usado en fila de 3
  // (Google / Facebook / Apple) para que quepan lado a lado sin overflow.
  Widget _buildBotonSocialIcono({
    required String logo,
    required IconData fallbackIcon,
    required Color fallbackColor,
    required String label,
    required VoidCallback? onTap,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.bienvenidaBorde),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        minimumSize: const Size(0, 52),
        backgroundColor: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            logo,
            width: 24,
            height: 24,
            errorBuilder: (_, __, ___) =>
                Icon(fallbackIcon, size: 26, color: fallbackColor),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.openSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.bienvenidaTextoMedio,
            ),
          ),
        ],
      ),
    );
  }
}
