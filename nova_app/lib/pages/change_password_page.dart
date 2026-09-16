import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../core/design/app_back_button.dart';
import '../core/design/app_colors.dart';
import '../core/design/app_spacing.dart';
import '../core/design/app_radius.dart';
import '../widgets/change_password_form.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);

    try {
      final data = await ApiService.changePassword(
        currentPassword: _oldPassCtrl.text.trim(),
        newPassword: _newPassCtrl.text.trim(),
      );

      if (!mounted) return;

      if (data['success'] == true) {
        _showSnack(data['message'] ?? 'Contraseña actualizada', AppColors.success);
        _oldPassCtrl.clear();
        _newPassCtrl.clear();
        _confirmCtrl.clear();
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) Navigator.pop(context);
      } else {
        _showSnack(data['error'] ?? 'Error al actualizar', AppColors.error);
      }
    } catch (e) {
      if (mounted) _showSnack('Error: $e', AppColors.error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg, Color color) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.smAll),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHero(),
              Expanded(
                child: ChangePasswordForm(
                  formKey: _formKey,
                  oldPasswordController: _oldPassCtrl,
                  newPasswordController: _newPassCtrl,
                  confirmController: _confirmCtrl,
                  loading: _loading,
                  onSubmit: _updatePassword,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppBackButton(
            variant: AppBackButtonVariant.onPrimary,
            onTap: _loading ? null : () => Navigator.pop(context),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Cambiar contraseña',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Elige una contraseña segura',
            style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }
}
