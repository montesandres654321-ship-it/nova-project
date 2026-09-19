// lib/pages/login/login_form_fields.dart
// Extraído de login_page.dart (_inputDec + campos de email/contraseña)
// sin cambios de comportamiento ni de estilo.
import 'package:nova_dashboard/utils/app_theme.dart';
import 'package:flutter/material.dart';

InputDecoration loginInputDecoration({
  required String   hint,
  required IconData icon,
  Widget?           suffix,
}) {
  return InputDecoration(
    hintText:  hint,
    hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFCBD5E1)),
    prefixIcon: Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
    suffixIcon: suffix,
    filled:    true,
    fillColor: const Color(0xFFF8FAFC),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppTheme.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFEF4444)),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
    ),
  );
}

Widget loginFieldLabel(String text) => Text(
  text,
  style: const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Color(0xFF374151),
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
        style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
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
        style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
        decoration: loginInputDecoration(
          hint: '••••••••',
          icon: Icons.lock_outline_rounded,
          suffix: IconButton(
            icon: Icon(
              obscure
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              size: 18,
              color: const Color(0xFF94A3B8),
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
