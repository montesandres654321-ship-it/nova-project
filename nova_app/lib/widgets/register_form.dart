// lib/widgets/register_form.dart
// ============================================================
// FORMULARIO DE REGISTRO — Nova App Móvil
// ============================================================
// Widget puramente de presentación: no llama a ApiService/AuthService
// directamente — delega el submit a register_page mediante
// [onRegisterPressed]. register_page sigue siendo dueño del estado
// (controllers, isRegistering, gender, countryCode, obscure, acceptTos)
// y de la lógica de registro y selección de fecha.
//
// Diseño actualizado al Figma de Septiembre 2026 (NOVA_AUTH_PLAN.md,
// pantalla 07 · Registro): 10 campos en el orden del Figma, con el
// campo "Lugar de residencia" agregado al final. El selector de código
// de país (+57/+1/...) se conserva junto al teléfono — es lógica de
// negocio existente que el Figma no cubre, no un ajuste visual.
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design/app_colors.dart';
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
  final TextEditingController residenciaController;

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
    required this.residenciaController,
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
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RegisterNameField(
            controller: firstNameController,
            validator: _reqValidator('nombre'),
          ),
          const SizedBox(height: 18),

          _buildFigmaField(
            controller: lastNameController,
            label: 'Apellido',
            hintText: 'Ej. Vergara',
            validator: _reqValidator('apellido'),
          ),
          const SizedBox(height: 18),

          _buildFigmaField(
            controller: dobController,
            label: 'Fecha de nacimiento',
            hintText: 'DD / MM / AAAA',
            readOnly: true,
            onTap: onDobTap,
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Selecciona tu fecha' : null,
          ),
          const SizedBox(height: 18),

          _buildCampoGenero(),
          const SizedBox(height: 18),

          _buildFigmaField(
            controller: usernameController,
            label: 'Nombre de usuario',
            hintText: '@beatrizvergara',
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
          ),
          const SizedBox(height: 18),

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
          const SizedBox(height: 18),

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
          const SizedBox(height: 18),

          RegisterConfirmPasswordField(
            confirmController: confirmController,
            passwordController: passwordController,
          ),
          const SizedBox(height: 18),

          _buildPhoneRow(),
          const SizedBox(height: 18),

          _buildFigmaField(
            controller: residenciaController,
            label: 'Lugar de residencia',
            hintText: '',
          ),
          const SizedBox(height: 18),

          // ── CHECKBOX TÉRMINOS ─────────────────────────────────
          TermsCheckbox(value: acceptTos, onChanged: onAcceptTosChanged),
          const SizedBox(height: 18),

          // ── BOTÓN CREAR CUENTA (VERDE) ───────────────────────
          // onPressed siempre activo: _register() ya valida _acceptTos
          // y muestra el snackbar correspondiente (lógica preexistente).
          RegisterSubmitButton(
            onPressed: onRegisterPressed,
            isLoading: isRegistering,
          ),

          // ── PIE DE PÁGINA ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '¿Ya tienes cuenta? ',
                    style: GoogleFonts.openSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Text(
                      'Inicia sesión',
                      style: GoogleFonts.openSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.bienvenidaAzul,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Campo de texto genérico con label arriba, estilo Figma
  Widget _buildFigmaField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    bool readOnly = false,
    VoidCallback? onTap,
    ValueChanged<String>? onChanged,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.openSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.bienvenidaTextoMedio,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bienvenidaFondoInput,
            border: Border.all(color: AppColors.bienvenidaBorde),
            borderRadius: AppRadius.mdAll,
          ),
          child: TextFormField(
            controller: controller,
            readOnly: readOnly,
            onTap: onTap,
            onChanged: onChanged,
            keyboardType: keyboardType,
            style: GoogleFonts.openSans(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AppColors.bienvenidaTextoFuerte,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.openSans(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: AppColors.textHint,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              border: InputBorder.none,
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  // Dropdown Género — mismo estilo visual que los campos de texto
  Widget _buildCampoGenero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Género',
          style: GoogleFonts.openSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.bienvenidaTextoMedio,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bienvenidaFondoInput,
            border: Border.all(color: AppColors.bienvenidaBorde),
            borderRadius: AppRadius.mdAll,
          ),
          child: DropdownButtonFormField<String>(
            initialValue: gender,
            style: GoogleFonts.openSans(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AppColors.bienvenidaTextoFuerte,
            ),
            hint: Text(
              'Selecciona una opción',
              style: GoogleFonts.openSans(fontSize: 15, color: AppColors.textHint),
            ),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              border: InputBorder.none,
            ),
            items: const [
              DropdownMenuItem(value: 'Femenino', child: Text('Femenino')),
              DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
              DropdownMenuItem(value: 'Otro', child: Text('Otro')),
            ],
            onChanged: (v) => onGenderChanged(v ?? gender),
          ),
        ),
      ],
    );
  }

  // Fila de teléfono: selector de código + campo de número (estilo Figma)
  Widget _buildPhoneRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Teléfono móvil',
          style: GoogleFonts.openSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.bienvenidaTextoMedio,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 88,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.bienvenidaFondoInput,
                  border: Border.all(color: AppColors.bienvenidaBorde),
                  borderRadius: AppRadius.mdAll,
                ),
                child: DropdownButtonFormField<String>(
                  initialValue: countryCode,
                  isExpanded: true,
                  style: GoogleFonts.openSans(
                      fontSize: 14, color: AppColors.bienvenidaTextoFuerte),
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                    border: InputBorder.none,
                  ),
                  items: countryCodes
                      .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c, style: const TextStyle(fontSize: 13))))
                      .toList(),
                  onChanged: (v) => onCountryCodeChanged(v ?? countryCode),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.bienvenidaFondoInput,
                  border: Border.all(color: AppColors.bienvenidaBorde),
                  borderRadius: AppRadius.mdAll,
                ),
                child: TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.openSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: AppColors.bienvenidaTextoFuerte,
                  ),
                  decoration: InputDecoration(
                    hintText: '300 000 0000',
                    hintStyle: GoogleFonts.openSans(
                        fontSize: 15, color: AppColors.textHint),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 15),
                    border: InputBorder.none,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Requerido';
                    if (v.trim().length < 7) return 'Número muy corto';
                    return null;
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
