import 'package:flutter/material.dart';
import '../core/design/app_back_button.dart';
import '../core/design/app_colors.dart';
import '../core/design/app_spacing.dart';
import '../widgets/forgot_password_form.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _emailSent = false;

  // ── Lifecycle ──────────────────────────────────────────────

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  // ── Actions ────────────────────────────────────────────────

  Future<void> _sendRecoveryEmail() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);

    try {
      // TODO: reemplazar con ApiService.requestPasswordReset(_emailCtrl.text.trim())
      // cuando el endpoint esté disponible en el backend.
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;
      setState(() {
        _emailSent = true;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error inesperado: $e'),
        backgroundColor: AppColors.error,
      ));
    }
  }

  void _goBack() {
    if (!_isLoading) Navigator.pop(context);
  }

  // ── Build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration:
            const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHero(),
              Expanded(
                child: ForgotPasswordForm(
                  formKey: _formKey,
                  emailController: _emailCtrl,
                  isLoading: _isLoading,
                  emailSent: _emailSent,
                  onSubmit: _sendRecoveryEmail,
                  onBackPressed: _goBack,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Sección superior con gradiente: botón de regreso + título
  Widget _buildHero() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppBackButton(
            variant: AppBackButtonVariant.onPrimary,
            onTap: _goBack,
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Recuperar acceso',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Te enviaremos instrucciones a tu correo',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
