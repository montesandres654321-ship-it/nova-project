// lib/pages/login_page.dart
// CORRECCIÓN CRÍTICA: pushNamedAndRemoveUntil limpia TODO el stack
// Evita que el botón ← lleve a sesiones de otros usuarios
// REFACTOR: fondo, header y campos del formulario extraídos a
// lib/pages/login/ para bajar de 446 a <300 líneas.
import 'package:nova_dashboard/utils/app_theme.dart';
import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import 'login/login_background.dart';
import 'login/login_form_fields.dart';
import 'login/login_header.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey            = GlobalKey<FormState>();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading         = false;
  bool _obscurePassword = true;

  late final AnimationController _animCtrl;
  late final Animation<double>   _fadeAnim;
  late final Animation<Offset>   _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 480));
    _fadeAnim  = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
            begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── LÓGICA — SIN CAMBIOS ─────────────────────────────────
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final result = await AdminService.login(
        email:    _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (result['success'] != true) {
        _showError(result['error'] ?? 'Credenciales inválidas');
        return;
      }

      final role      = result['role']      as String?;
      final placeId   = result['place_id']  as int?;
      final userName  = result['userName']  as String? ?? '';
      final userEmail = result['userEmail'] as String? ?? '';

      if (role == 'admin_general' || role == 'user_general') {
        // pushNamedAndRemoveUntil elimina TODAS las rutas anteriores
        // (_) => false = no mantener ninguna ruta en el stack
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/dashboard', (_) => false,
        );

      } else if (role == 'user_place') {
        if (placeId == null) {
          _showError('Tu usuario no tiene un lugar asignado.\nContacta al administrador.');
          await AdminService.logout();
          return;
        }
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/owner-dashboard',
          (_) => false, // limpia todo el stack
          arguments: {
            'placeId':   placeId,
            'userName':  userName,
            'userEmail': userEmail,
          },
        );

      } else {
        // role null = turista móvil, sin acceso al panel
        await AdminService.logout();
        _showError(
          'Este usuario no tiene acceso al panel administrativo.\n'
          'El panel es solo para administradores y propietarios.',
        );
      }
    } catch (e) {
      if (mounted) _showError('Error de conexión: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 5),
    ));
  }

  // ── BUILD ────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const LoginBackground(),

          // ── CARD DE LOGIN (centrada, animada) ──────────
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 40,
                            offset: const Offset(0, 20),
                            spreadRadius: -8,
                          ),
                          BoxShadow(
                            color: const Color(0xFF0F766E).withOpacity(0.18),
                            blurRadius: 80,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(32, 36, 32, 32),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const LoginHeader(),

                              const SizedBox(height: 28),
                              const Divider(
                                  color: Color(0xFFF1F5F9), height: 1, thickness: 1),
                              const SizedBox(height: 24),

                              LoginEmailField(
                                controller: _emailController,
                                enabled: !_loading,
                              ),

                              const SizedBox(height: 16),

                              LoginPasswordField(
                                controller: _passwordController,
                                enabled: !_loading,
                                obscure: _obscurePassword,
                                onToggleObscure: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                                onSubmitted: _login,
                              ),

                              const SizedBox(height: 24),

                              // ── BOTÓN PRINCIPAL ──────────
                              SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: _loading ? null : _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primary,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor:
                                        AppTheme.primary.withOpacity(0.55),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12)),
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: _loading
                                      ? const SizedBox(
                                          width: 20, height: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white),
                                        )
                                      : const Text(
                                          'Iniciar Sesión',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // ── FOOTER ───────────────────
                              const Text(
                                'Golfo de Morrosquillo · NOVA',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFFCBD5E1),
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
