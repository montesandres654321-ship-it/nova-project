import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../core/design/app_colors.dart';
import '../widgets/login_form.dart';
import '../services/notification_service.dart';
import '../services/location_service.dart';
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
  // Figma muestra el checkbox "Recordarme" ya marcado por defecto;
  // _loadSaved() lo corrige según la preferencia real guardada.
  bool _rememberMe = true;

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
          await prefs.setString(
              AppConstants.keySavedEmail, _emailCtrl.text.trim());
          await prefs.setBool(AppConstants.keyRememberMe, true);
        } else {
          await prefs.remove(AppConstants.keySavedEmail);
          await prefs.setBool(AppConstants.keyRememberMe, false);
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Bienvenido ${user?['first_name'] ?? user?['username'] ?? ''}'),
          backgroundColor: AppColors.success,
        ));

        // Ubicación + notificaciones push — ambos determinan si se debe
        // mostrar el banner de "activa tu ubicación" en HomePage.
        final token = data['token']?.toString() ?? '';
        bool showLocationBanner = false;
        if (token.isNotEmpty) {
          final locationOk = await LocationService.pingLocation(token);
          if (!mounted) return;
          await NotificationService.registerToken(token, context);
          if (!mounted) return;
          showLocationBanner = !locationOk;
        }

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const MainNavigationPage(),
            settings: RouteSettings(
              arguments: {'showLocationBanner': showLocationBanner},
            ),
          ),
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
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
          child: LoginForm(
            formKey: _formKey,
            emailController: _emailCtrl,
            passwordController: _passCtrl,
            rememberMe: _rememberMe,
            onRememberMeChanged: (val) => setState(() => _rememberMe = val),
            isLoading: _isLoading,
            onLoginPressed: _login,
            onGooglePressed: _loginWithGoogle,
          ),
        ),
      ),
    );
  }
}
