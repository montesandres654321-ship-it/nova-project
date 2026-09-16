// lib/widgets/register_form.dart
// ============================================================
// FORMULARIO DE REGISTRO — Nova App Móvil
// ============================================================
// Extraído de register_page.dart (FASE 2, PASO 2.2 del refactor).
// Widget puramente de presentación: no llama a ApiService/AuthService
// directamente — delega el submit a register_page mediante
// [onRegisterPressed]. register_page sigue siendo dueño del estado
// (controllers, isRegistering, gender, countryCode, obscure, acceptTos)
// y de la lógica de registro y selección de fecha.
//
// FASE 2, PASO 2.6 del refactor de widgets: los campos de nombre,
// correo, contraseña, confirmar contraseña y el botón de envío ahora
// delegan en RegisterNameField/RegisterEmailField/RegisterPasswordField/
// RegisterConfirmPasswordField/RegisterSubmitButton. Apellido, usuario,
// fecha de nacimiento, género, teléfono/código de país y el checkbox
// de términos quedan intactos (no había widgets nuevos para ellos).
//
// CAMBIO DE COMPORTAMIENTO: antes, el campo "Confirmar contraseña" no
// tenía ícono propio y reflejaba la misma bandera de visibilidad que
// "Contraseña". RegisterConfirmPasswordField no soporta ese modo
// compartido — ahora tiene su propio ícono de ojo y su propio estado
// de visibilidad, independiente del campo de contraseña.
// ============================================================

import 'package:flutter/material.dart';
import '../core/design/app_colors.dart';
import '../core/design/app_spacing.dart';
import '../core/design/app_radius.dart';
import 'terms_checkbox.dart';
import 'register_name_field.dart';
import 'register_email_field.dart';
import 'register_password_field.dart';
import 'register_confirm_password_field.dart';
import 'register_submit_button.dart';

class RegisterForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final TextEditingController dobController;
  final TextEditingController phoneController;

  final String gender;
  final ValueChanged<String> onGenderChanged;

  final String countryCode;
  final ValueChanged<String> onCountryCodeChanged;
  final List<String> countryCodes;

  final bool obscurePassword;
  final ValueChanged<bool> onTogglePasswordObscure;

  final bool acceptTos;
  final ValueChanged<bool> onAcceptTosChanged;

  final bool isRegistering;
  final VoidCallback onDobTap;
  final VoidCallback onRegisterPressed;

  const RegisterForm({
    super.key,
    required this.formKey,
    required this.firstNameController,
    required this.lastNameController,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmController,
    required this.dobController,
    required this.phoneController,
    required this.gender,
    required this.onGenderChanged,
    required this.countryCode,
    required this.onCountryCodeChanged,
    required this.countryCodes,
    required this.obscurePassword,
    required this.onTogglePasswordObscure,
    required this.acceptTos,
    required this.onAcceptTosChanged,
    required this.isRegistering,
    required this.onDobTap,
    required this.onRegisterPressed,
  });

  String? Function(String?) _reqValidator(String field) =>
      (v) => (v == null || v.trim().isEmpty) ? 'Ingresa tu $field' : null;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.xl),
          topRight: Radius.circular(AppRadius.xl),
        ),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Datos personales ──────────────────────────────
              _buildSectionLabel('Datos personales'),
              RegisterNameField(
                controller: firstNameController,
                hintText: 'Nombre',
                validator: _reqValidator('nombre'),
              ),
              const SizedBox(height: AppSpacing.md),
              _buildInput(
                controller: lastNameController,
                label: 'Apellido',
                icon: Icons.person_outline_rounded,
                validator: _reqValidator('apellido'),
              ),
              const SizedBox(height: AppSpacing.md),
              _buildInput(
                controller: dobController,
                label: 'Fecha de nacimiento',
                icon: Icons.cake_outlined,
                readOnly: true,
                onTap: onDobTap,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today_outlined,
                      color: AppColors.textHint, size: 18),
                  onPressed: onDobTap,
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Selecciona tu fecha' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                initialValue: gender,
                style:
                    const TextStyle(fontSize: 15, color: AppColors.textPrimary),
                decoration: _inputDecoration(
                  label: 'Género',
                  icon: Icons.wc_outlined,
                ),
                items: const [
                  DropdownMenuItem(value: 'Femenino', child: Text('Femenino')),
                  DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
                  DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                ],
                onChanged: (v) => onGenderChanged(v ?? gender),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Tu cuenta ─────────────────────────────────────
              _buildSectionLabel('Tu cuenta'),
              TextFormField(
                controller: usernameController,
                style:
                    const TextStyle(fontSize: 15, color: AppColors.textPrimary),
                onChanged: (v) {
                  if (v.contains(' ')) {
                    usernameController.text = v.replaceAll(' ', '_');
                    usernameController.selection = TextSelection.fromPosition(
                        TextPosition(offset: usernameController.text.length));
                  }
                },
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Elige un nombre de usuario';
                  }
                  if (v.contains(' ')) return 'Sin espacios (usa _ o .)';
                  if (v.length < 3) return 'Mínimo 3 caracteres';
                  if (!RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(v)) {
                    return 'Solo letras, números, _ y .';
                  }
                  return null;
                },
                decoration: _inputDecoration(
                  label: 'Nombre de usuario',
                  icon: Icons.account_box_outlined,
                ).copyWith(
                  hintText: 'ej: viajero_nova',
                  helperText: 'Sin espacios · Solo letras, números, _ y .',
                  helperStyle:
                      const TextStyle(fontSize: 11, color: AppColors.textHint),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              RegisterEmailField(
                controller: emailController,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requerido';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(v)) {
                    return 'Correo inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Seguridad ──────────────────────────────────────
              _buildSectionLabel('Seguridad'),
              RegisterPasswordField(
                controller: passwordController,
                obscureText: obscurePassword,
                onToggleVisibility: () =>
                    onTogglePasswordObscure(!obscurePassword),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requerido';
                  if (v.length < 6) return 'Mínimo 6 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              RegisterConfirmPasswordField(
                confirmController: confirmController,
                passwordController: passwordController,
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Contacto ──────────────────────────────────────
              _buildSectionLabel('Contacto'),
              _buildPhoneRow(),
              const SizedBox(height: AppSpacing.xl),

              // ── Términos ──────────────────────────────────────
              TermsCheckbox(value: acceptTos, onChanged: onAcceptTosChanged),
              const SizedBox(height: AppSpacing.lg),

              // ── Botón principal ───────────────────────────────
              RegisterSubmitButton(
                onPressed: onRegisterPressed,
                isLoading: isRegistering,
              ),
              const SizedBox(height: AppSpacing.md),

              // Link de vuelta al login
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    '¿Ya tienes cuenta? Inicia sesión',
                    style: TextStyle(
                        fontSize: 14, color: AppColors.textSecondary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Cabecera de sección: texto en mayúsculas con letra tracking
  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textHint,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  // Fila de teléfono: selector de código + campo de número
  Widget _buildPhoneRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dropdown del código de país — ancho fijo, mismo estilo que inputs
        SizedBox(
          width: 88,
          child: DropdownButtonFormField<String>(
            initialValue: countryCode,
            isExpanded: true,
            style:
                const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surfaceVariant,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.md,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.mdAll,
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.mdAll,
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: AppRadius.mdAll,
                borderSide: const BorderSide(color: AppColors.error),
              ),
            ),
            items: countryCodes
                .map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(c, style: const TextStyle(fontSize: 13))))
                .toList(),
            onChanged: (v) => onCountryCodeChanged(v ?? countryCode),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _buildInput(
            controller: phoneController,
            label: 'Teléfono móvil',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Requerido';
              if (v.trim().length < 7) return 'Número muy corto';
              return null;
            },
          ),
        ),
      ],
    );
  }

  // InputDecoration base — única fuente de verdad para todos los campos
  InputDecoration _inputDecoration({
    required String label,
    required IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 14, color: AppColors.textHint),
      prefixIcon:
          icon != null ? Icon(icon, size: 20, color: AppColors.textHint) : null,
      filled: true,
      fillColor: AppColors.surfaceVariant,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.mdAll,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.mdAll,
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppRadius.mdAll,
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppRadius.mdAll,
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }

  // TextFormField estilizado con tokens del design system
  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
      decoration: _inputDecoration(label: label, icon: icon)
          .copyWith(suffixIcon: suffixIcon),
      validator: validator,
    );
  }
}
