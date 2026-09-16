import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../core/design/app_colors.dart';
import '../core/design/app_spacing.dart';
import '../core/design/app_radius.dart';
import '../widgets/login_form.dart';
import 'main_navigation_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _isLoading = false;
  bool _rememberMe = false;

  // ── Lifecycle ──────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString(AppConstants.keySavedEmail);
    final savedRemember = prefs.getBool(AppConstants.keyRememberMe) ?? false;
    if (savedEmail != null) _emailCtrl.text = savedEmail;
    setState(() => _rememberMe = savedRemember);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // ── Actions ────────────────────────────────────────────────

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);

    try {
      final data = await ApiService.login(
        _emailCtrl.text.trim(),
        _passCtrl.text.trim(),
      );

      if (data['success'] == true) {
        // Verificar que no sea admin/propietario — la app es solo para turistas
        final user = data['user'];
        final role = user?['role']?.toString() ?? '';
        if (role.isNotEmpty &&
            ['admin_general', 'user_general', 'user_place'].contains(role)) {
          await ApiService.logout();
          if (!mounted) return;
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Acceso restringido'),
              content: const Text(
                'Esta aplicación es exclusiva para turistas.\n\n'
                'Si eres administrador, accede desde:\n'
                'nova-project-wk67.vercel.app',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Entendido'),
                ),
              ],
            ),
          );
          return;
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.keyAuthProvider, 'email');
        if (_rememberMe) {
          await prefs.setString(AppConstants.keySavedEmail, _emailCtrl.text.trim());
          await prefs.setBool(AppConstants.keyRememberMe, true);
        } else {
          await prefs.remove(AppConstants.keySavedEmail);
          await prefs.setBool(AppConstants.keyRememberMe, false);
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Bienvenido ${user?['first_name'] ?? user?['username'] ?? ''}'),
          backgroundColor: AppColors.success,
        ));
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigationPage()),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(data['error'] ?? 'Error en login'),
          backgroundColor: AppColors.error,
        ));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error de conexión: $e'),
        backgroundColor: AppColors.error,
      ));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Inicio con Google: próximamente'),
        backgroundColor: AppColors.warning,
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final screenH = MediaQuery.sizeOf(context).height;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: screenH - padding.top - padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    _buildHero(),
                    Expanded(
                      child: LoginForm(
                        formKey: _formKey,
                        emailController: _emailCtrl,
                        passwordController: _passCtrl,
                        rememberMe: _rememberMe,
                        onRememberMeChanged: (val) =>
                            setState(() => _rememberMe = val),
                        isLoading: _isLoading,
                        onLoginPressed: _login,
                        onGooglePressed: _loginWithGoogle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Sección superior: logo + nombre de la app
  Widget _buildHero() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 12,
      ),
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: AppRadius.lgAll,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.travel_explore_rounded,
              size: 26,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'NOVA',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 6,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Tu pasaporte digital de viajes',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.8),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
