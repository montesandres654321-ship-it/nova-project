// lib/pages/login/login_form_fields.dart
// Campos del formulario de login — usa AppTheme como única fuente de verdad.
import 'package:nova_dashboard/utils/app_theme.dart';
import 'package:flutter/material.dart';

InputDecoration loginInputDecoration({
  required String   hint,
  required IconData icon,
  Widget?           suffix,
}) {
  return InputDecoration(
    hintText:  hint,
    hintStyle: TextStyle(fontSize: 13, color: AppTheme.textMuted),
    prefixIcon: Icon(icon, size: 18, color: AppTheme.textMuted),
    suffixIcon: suffix,
    filled:    true,
    fillColor: AppTheme.backgroundGray,          // gray50 = 0xFFF9FAFB
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      borderSide: BorderSide(color: AppTheme.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      borderSide: BorderSide(color: AppTheme.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      borderSide: const BorderSide(color: AppTheme.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      borderSide: BorderSide(color: AppTheme.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      borderSide: BorderSide(color: AppTheme.error, width: 2),
    ),
  );
}

Widget loginFieldLabel(String text) => Text(
  text,
  style: TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppTheme.textHead,
  ),
);

class LoginEmailField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  const LoginEmailField({super.key, required this.controller, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      loginFieldLabel('Correo electrónico'),
      const SizedBox(height: 6),
      TextFormField(
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        style: TextStyle(fontSize: 14, color: AppTheme.textHead),
        decoration: loginInputDecoration(
          hint: 'admin@ejemplo.com',
          icon: Icons.email_outlined,
        ),
        validator: (v) {
          if (v == null || v.isEmpty) return 'Ingrese su email';
          if (!v.contains('@')) return 'Email inválido';
          return null;
        },
        enabled: enabled,
      ),
    ]);
  }
}

class LoginPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmitted;

  const LoginPasswordField({
    super.key,
    required this.controller,
    required this.enabled,
    required this.obscure,
    required this.onToggleObscure,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      loginFieldLabel('Contraseña'),
      const SizedBox(height: 6),
      TextFormField(
        controller: controller,
        obscureText: obscure,
        style: TextStyle(fontSize: 14, color: AppTheme.textHead),
        decoration: loginInputDecoration(
          hint: '••••••••',
          icon: Icons.lock_outline_rounded,
          suffix: IconButton(
            icon: Icon(
              obscure
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              size: 18,
              color: AppTheme.textMuted,
            ),
            onPressed: onToggleObscure,
            splashRadius: 16,
          ),
        ),
        validator: (v) => v?.isEmpty ?? true ? 'Ingrese su contraseña' : null,
        enabled: enabled,
        onFieldSubmitted: (_) => onSubmitted(),
      ),
    ]);
  }
}
