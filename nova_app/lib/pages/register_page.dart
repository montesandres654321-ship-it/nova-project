import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../core/design/app_colors.dart';
import '../widgets/register_form.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _residenciaCtrl = TextEditingController();

  String _gender = 'Femenino';
  String _countryCode = '+57';
  bool _obscure = true;
  bool _acceptTos = false;
  bool _isRegistering = false;

  final List<String> _countryCodes = ['+57', '+1', '+34', '+52'];

  // ── Lifecycle ──────────────────────────────────────────────

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _dobCtrl.dispose();
    _phoneCtrl.dispose();
    _residenciaCtrl.dispose();
    super.dispose();
  }

  // ── Actions ────────────────────────────────────────────────

  Future<void> _pickDate() async {
    if (!mounted) return;
    final now = DateTime.now();
    final initial = DateTime(now.year - 20, now.month, now.day);
    try {
      final picked = await showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: DateTime(1900),
        lastDate: now,
        builder: (context, child) => Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.onPrimary,
            ),
          ),
          child: child!,
        ),
      );
      if (!mounted) return;
      if (picked != null) {
        setState(() {
          _dobCtrl.text =
              '${picked.year.toString().padLeft(4, '0')}-'
              '${picked.month.toString().padLeft(2, '0')}-'
              '${picked.day.toString().padLeft(2, '0')}';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _register() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_acceptTos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes aceptar los términos y condiciones'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    setState(() => _isRegistering = true);

    try {
      final data = await ApiService.register(
        firstName: _firstCtrl.text.trim(),
        lastName: _lastCtrl.text.trim(),
        username: _usernameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
        phone: '$_countryCode ${_phoneCtrl.text.trim()}',
        dob: _dobCtrl.text.trim(),
        gender: _gender,
        acceptedTerms: _acceptTos,
        residence: _residenciaCtrl.text.trim(),
      );

      if (!mounted) return;

      if (data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cuenta creada correctamente'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['error'] ?? 'Error al registrar'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isRegistering = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── ENCABEZADO ──────────────────────────────────
              SvgPicture.asset(
                'assets/images/logos/logo-nova-verde.svg',
                width: 88,
                height: 52.585,
              ),
              const SizedBox(height: 10),
              Text(
                'Crea tu cuenta y empieza\na recorrer Sucre.',
                style: GoogleFonts.openSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.bienvenidaVerde,
                  height: 33 / 26,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Guarda tus lugares, reserva y acumula recompensas.',
                style: GoogleFonts.openSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 22 / 15,
                ),
              ),
              const SizedBox(height: 32),

              RegisterForm(
                formKey: _formKey,
                firstNameController: _firstCtrl,
                lastNameController: _lastCtrl,
                usernameController: _usernameCtrl,
                emailController: _emailCtrl,
                passwordController: _passCtrl,
                confirmController: _confirmCtrl,
                dobController: _dobCtrl,
                phoneController: _phoneCtrl,
                residenciaController: _residenciaCtrl,
                gender: _gender,
                onGenderChanged: (v) => setState(() => _gender = v),
                countryCode: _countryCode,
                onCountryCodeChanged: (v) =>
                    setState(() => _countryCode = v),
                countryCodes: _countryCodes,
                obscurePassword: _obscure,
                onTogglePasswordObscure: (v) =>
                    setState(() => _obscure = v),
                acceptTos: _acceptTos,
                onAcceptTosChanged: (v) => setState(() => _acceptTos = v),
                isRegistering: _isRegistering,
                onDobTap: _pickDate,
                onRegisterPressed: _register,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
