// lib/pages/forgot_password_page.dart
// ============================================================
// RECUPERACIÓN DE CONTRASEÑA — Nova App Móvil
// ============================================================
// Rediseño Oct 2026 — paleta Figma (azul #0071BD / verde #078930),
// fondo blanco igual que login_page. Llama al backend real:
//   POST /auth/forgot-password    → envía email con código de 6 dígitos
//   POST /auth/verify-reset-code  → valida código + nueva contraseña
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/design/app_colors.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import '../widgets/email_input.dart';
import '../widgets/password_input.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  // ── Controladores ─────────────────────────────────────────
  final _emailCtrl    = TextEditingController();
  final _codeCtrl    = TextEditingController();
  final _passCtrl     = TextEditingController();
  final _confirmCtrl  = TextEditingController();
  final _emailFormKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();

  // ── Estado ─────────────────────────────────────────────────
  // Paso 1: ingresar correo → Paso 2: ingresar token + nueva contraseña
  // Paso 3: éxito
  int  _step      = 1; // 1 | 2 | 3
  bool _loading   = false;
  bool _showPass  = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // ── Acción: enviar correo ──────────────────────────────────
  Future<void> _sendEmail() async {
    if (!(_emailFormKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      final res = await http.post(
        Uri.parse('${AppConstants.backendUrl}${AppConstants.forgotPasswordEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': _emailCtrl.text.trim().toLowerCase()}),
      ).timeout(AppConstants.timeoutNormal);

      if (!mounted) return;
      final body = jsonDecode(res.body);
      if (res.statusCode == 200 && body['success'] == true) {
        setState(() => _step = 2);
      } else {
        _showError(body['error'] ?? 'Error al enviar el correo');
      }
    } catch (e) {
      if (mounted) _showError('Error de conexión. Verifica tu internet.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Acción: cambiar contraseña ─────────────────────────────
  Future<void> _resetPassword() async {
    if (!(_resetFormKey.currentState?.validate() ?? false)) return;
    if (_passCtrl.text != _confirmCtrl.text) {
      _showError('Las contraseñas no coinciden');
      return;
    }
    setState(() => _loading = true);
    try {
      final res = await http.post(
        Uri.parse('${AppConstants.backendUrl}${AppConstants.verifyResetCodeEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email':        _emailCtrl.text.trim().toLowerCase(),
          'code':         _codeCtrl.text.trim(),
          'new_password': _passCtrl.text,
        }),
      ).timeout(AppConstants.timeoutNormal);

      if (!mounted) return;
      final body = jsonDecode(res.body);
      if (res.statusCode == 200 && body['success'] == true) {
        setState(() => _step = 3);
      } else {
        _showError(body['error'] ?? 'Código inválido o expirado');
      }
    } catch (e) {
      if (mounted) _showError('Error de conexión. Verifica tu internet.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.error,
    ));
  }

  // ── Build ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBackButton(),
              const SizedBox(height: 28),
              _buildLogo(),
              const SizedBox(height: 20),
              _buildStepIndicator(),
              const SizedBox(height: 28),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.06, 0),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: switch (_step) {
                  1 => _buildStep1(key: const ValueKey(1)),
                  2 => _buildStep2(key: const ValueKey(2)),
                  _ => _buildStep3(key: const ValueKey(3)),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Botón atrás
  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () {
        if (_step > 1 && _step < 3) {
          setState(() => _step -= 1);
        } else {
          Navigator.pop(context);
        }
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.bienvenidaAzulClaro,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 16, color: AppColors.bienvenidaAzul),
      ),
    );
  }

  // Logo
  Widget _buildLogo() {
    return SvgPicture.asset(
      'assets/images/logos/logo-nova-verde.svg',
      width: 72,
      height: 43,
    );
  }

  // Indicador de pasos (3 dots)
  Widget _buildStepIndicator() {
    return Row(
      children: List.generate(3, (i) {
        final active = i + 1 == _step;
        final done   = i + 1 < _step;
        return Container(
          margin: const EdgeInsets.only(right: 6),
          width:  active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: done
                ? AppColors.bienvenidaVerde
                : active
                    ? AppColors.bienvenidaAzul
                    : AppColors.bienvenidaBorde,
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }

  // ── PASO 1: Ingresar correo ────────────────────────────────
  Widget _buildStep1({Key? key}) {
    return Form(
      key: _emailFormKey,
      child: Column(
        key: key,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIconContainer(
            icon: Icons.lock_outline_rounded,
            color: AppColors.bienvenidaAzul,
          ),
          const SizedBox(height: 16),
          Text('¿Olvidaste tu contraseña?',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.bienvenidaTextoFuerte)),
          const SizedBox(height: 8),
          Text(
            'Te enviaremos un código de 6 dígitos a tu email',
            style: TextStyle(
                fontSize: 14, color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 24),
          EmailInput(
            controller: _emailCtrl,
            validator: Validators.email,
            figmaLabel: 'Correo electrónico',
            hintText: 'tucorreo@ejemplo.com',
            enabled: !_loading,
          ),
          const SizedBox(height: 20),
          _buildPrimaryButton(
            label: 'Enviar código',
            loading: _loading,
            onPressed: _sendEmail,
          ),
          const SizedBox(height: 14),
          _buildSecondaryLink(
            label: 'Volver al inicio de sesión',
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  // ── PASO 2: Token + nueva contraseña ──────────────────────
  Widget _buildStep2({Key? key}) {
    return Form(
      key: _resetFormKey,
      child: Column(
        key: key,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIconContainer(
            icon: Icons.mark_email_read_outlined,
            color: AppColors.bienvenidaVerde,
          ),
          const SizedBox(height: 16),
          Text('Revisa tu correo',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.bienvenidaTextoFuerte)),
          const SizedBox(height: 8),
          Text(
            'Si el correo está registrado recibirás un código de 6 dígitos (vence en 15 minutos). Ingrésalo aquí junto con tu nueva contraseña.',
            style: TextStyle(
                fontSize: 14, color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 8),
          // Correo ingresado
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.bienvenidaFondoInput,
              border: Border.all(color: AppColors.bienvenidaBorde),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.email_outlined,
                    size: 16, color: AppColors.bienvenidaAzul),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _emailCtrl.text,
                    style: TextStyle(
                        fontSize: 13,
                        color: AppColors.bienvenidaTextoMedio),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Campo token
          _buildLabel('Código del correo'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _codeCtrl,
            enabled: !_loading,
            keyboardType: TextInputType.number,
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(
                fontSize: 18,
                letterSpacing: 6,
                fontWeight: FontWeight.w700,
                color: AppColors.bienvenidaTextoFuerte),
            decoration: _inputDecoration('000000').copyWith(counterText: ''),
            validator: (v) => (v == null || v.trim().length != 6)
                ? 'Ingresa el código de 6 dígitos'
                : null,
          ),
          const SizedBox(height: 16),
          // Nueva contraseña
          PasswordInput(
            controller: _passCtrl,
            label: 'Nueva contraseña',
            placeholder: '••••••••',
            figmaStyle: true,
            verticalPadding: 15,
            validator: (v) =>
                (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
          ),
          const SizedBox(height: 14),
          // Confirmar contraseña
          _buildLabel('Confirmar contraseña'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _confirmCtrl,
            obscureText: !_showPass,
            enabled: !_loading,
            style: TextStyle(
                fontSize: 13, color: AppColors.bienvenidaTextoFuerte),
            decoration: _inputDecoration('Repite la contraseña').copyWith(
              suffixIcon: GestureDetector(
                onTap: () => setState(() => _showPass = !_showPass),
                child: Icon(
                  _showPass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 20,
                  color: AppColors.textHint,
                ),
              ),
            ),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Confirma tu contraseña' : null,
          ),
          const SizedBox(height: 22),
          _buildPrimaryButton(
            label: 'Cambiar contraseña',
            loading: _loading,
            onPressed: _resetPassword,
          ),
          const SizedBox(height: 14),
          _buildSecondaryLink(
            label: '¿No recibiste el correo? Volver',
            onTap: () => setState(() => _step = 1),
          ),
        ],
      ),
    );
  }

  // ── PASO 3: Éxito ─────────────────────────────────────────
  Widget _buildStep3({Key? key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildIconContainer(
          icon: Icons.check_circle_outline_rounded,
          color: AppColors.bienvenidaVerde,
        ),
        const SizedBox(height: 16),
        Text('¡Contraseña actualizada!',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.bienvenidaTextoFuerte)),
        const SizedBox(height: 8),
        Text(
          'Tu contraseña se cambió correctamente. Ya puedes iniciar sesión con tus nuevas credenciales.',
          style: TextStyle(
              fontSize: 14, color: AppColors.textSecondary, height: 1.5),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 49,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.bienvenidaVerde,
              shape: const StadiumBorder(),
              elevation: 0,
            ),
            child: Text('Ir al inicio de sesión',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
          ),
        ),
      ],
    );
  }

  // ── Helpers ───────────────────────────────────────────────
  Widget _buildIconContainer({required IconData icon, required Color color}) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.bienvenidaTextoMedio),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
          fontSize: 13, color: AppColors.textHint),
      filled: true,
      fillColor: AppColors.bienvenidaFondoInput,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.bienvenidaBorde),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.bienvenidaBorde),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: AppColors.bienvenidaAzul, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required bool loading,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 49,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.bienvenidaAzul,
          disabledBackgroundColor:
              AppColors.bienvenidaAzul.withValues(alpha: 0.55),
          shape: const StadiumBorder(),
          elevation: 0,
        ),
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : Text(label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
      ),
    );
  }

  Widget _buildSecondaryLink({
    required String label,
    required VoidCallback onTap,
  }) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          label,
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
