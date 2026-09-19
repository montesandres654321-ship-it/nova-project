/// Página de perfil del turista autenticado.
///
/// Muestra los datos personales (nombre, apellido, usuario, correo,
/// teléfono) en campos siempre editables — a diferencia del diseño
/// anterior (toggle editar/cancelar), el Figma no distingue un modo de
/// solo lectura. [_save] y [_loadUser] mantienen la misma lógica y
/// llamada a [ApiService.updateProfile] de antes.
///
/// También aloja "Cerrar sesión": esta es la única entrada de logout de
/// la app — se perdió cuando `WelcomeCard`/`_logout()` se eliminaron de
/// home_page.dart en el rediseño de Home (NOVA_HOME_EXPLORAR_PLAN.md).
/// Se reintroduce aquí con la misma lógica (GoogleAuthService.signOut
/// si aplica + ApiService.logout + navegar a '/').
///
/// Diseño Figma Septiembre 2026 (NOVA_GPS_GEOCODIFICACION_PERFIL_PLAN.md,
/// node 42:367).
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/google_auth_service.dart';
import '../utils/constants.dart';
import '../core/design/app_colors.dart';
import 'settings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  bool _loading = false;
  bool _isGoogleUser = false;

  // ── Lifecycle ──────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  // ── Data ───────────────────────────────────────────────────

  Future<void> _loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString(AppConstants.keyUser);
      final isGoogle = await GoogleAuthService.isGoogleUser();
      if (!mounted) return;
      setState(() => _isGoogleUser = isGoogle);

      if (userStr != null) {
        final user = jsonDecode(userStr);
        if (!mounted) return;
        setState(() {
          _firstNameCtrl.text = user['first_name'] ?? '';
          _lastNameCtrl.text = user['last_name'] ?? '';
          _usernameCtrl.text = user['username'] ?? '';
          _emailCtrl.text = user['email'] ?? '';
          _phoneCtrl.text = user['phone'] ?? '';
        });
      }
    } catch (e) {
      _showError('Error cargando perfil: $e');
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);

    try {
      final data = await ApiService.updateProfile(
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        username: _usernameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _isGoogleUser ? null : _phoneCtrl.text.trim(),
      );

      if (!mounted) return;

      if (data['success'] == true) {
        _showSuccess('Perfil actualizado correctamente');
      } else {
        _showError(data['error'] ?? 'Error al actualizar');
      }
    } catch (e) {
      if (mounted) _showError('Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.logout_rounded, color: AppColors.error, size: 32),
              ),
              const SizedBox(height: 16),
              Text('Cerrar sesión',
                  style: GoogleFonts.openSans(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.bienvenidaTextoFuerte)),
              const SizedBox(height: 8),
              Text('¿Estás seguro de que quieres salir?',
                  style: GoogleFonts.openSans(fontSize: 14, color: AppColors.textSecondary), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.bienvenidaBorde),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Salir', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirm != true || !mounted) return;

    if (_isGoogleUser) await GoogleAuthService.signOut();
    await ApiService.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
  }

  void _handleCambiarFoto() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Cambiar foto de perfil: próximamente'),
      backgroundColor: AppColors.bienvenidaAzul,
    ));
  }

  // ── Mensajes ───────────────────────────────────────────────

  void _showSuccess(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating),
      );

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
      );

  String get _inicialNombre {
    final n = _firstNameCtrl.text.trim();
    if (n.isNotEmpty) return n[0].toUpperCase();
    final u = _usernameCtrl.text.trim();
    return u.isNotEmpty ? u[0].toUpperCase() : '?';
  }

  // ── Build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: SafeArea(
        child: Column(
          children: [
            _buildEncabezado(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildAvatar(),
                      const SizedBox(height: 20),
                      _buildCampoPerfil('Nombre', _firstNameCtrl),
                      const SizedBox(height: 12),
                      _buildCampoPerfil('Apellido', _lastNameCtrl),
                      const SizedBox(height: 12),
                      _buildCampoPerfil('Nombre de usuario', _usernameCtrl),
                      const SizedBox(height: 12),
                      _buildCampoPerfil('Correo electrónico', _emailCtrl, keyboardType: TextInputType.emailAddress, email: true),
                      if (!_isGoogleUser) ...[
                        const SizedBox(height: 12),
                        _buildCampoPerfil('Número telefónico', _phoneCtrl, keyboardType: TextInputType.phone),
                      ],
                      const SizedBox(height: 20),
                      _buildBotonGuardar(),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage())),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Ir a Ajustes de la Cuenta',
                                style: GoogleFonts.openSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.bienvenidaAzul)),
                            const SizedBox(width: 8),
                            SvgPicture.asset('assets/icons/ic-chevron-right.svg', width: 14),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _loading ? null : _handleLogout,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.error),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text('Cerrar sesión',
                              style: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.error)),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEncabezado() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.bienvenidaBorde)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(color: AppColors.bienvenidaAzulClaro, shape: BoxShape.circle),
              child: Center(child: SvgPicture.asset('assets/icons/ic-flecha-atras.svg', width: 16)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Perfil del turista',
                    style: GoogleFonts.openSans(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.bienvenidaTextoFuerte)),
                Text('Gestiona tus datos personales',
                    style: GoogleFonts.openSans(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(color: AppColors.bienvenidaAzulClaro, shape: BoxShape.circle),
          child: Center(
            child: Container(
              width: 68,
              height: 68,
              decoration: const BoxDecoration(color: Color(0xFFBFE0F2), shape: BoxShape.circle),
              child: Center(
                child: Text(_inicialNombre,
                    style: GoogleFonts.openSans(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.bienvenidaAzul)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _handleCambiarFoto,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.bienvenidaBorde),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text('Cambiar foto',
                style: GoogleFonts.openSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.bienvenidaAzul)),
          ),
        ),
      ],
    );
  }

  Widget _buildBotonGuardar() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.bienvenidaAzul, AppColors.bienvenidaVerde]),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ElevatedButton(
        onPressed: _loading ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: _loading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text('Guardar cambios', style: GoogleFonts.openSans(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
    );
  }

  Widget _buildCampoPerfil(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    bool email = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.openSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.bienvenidaTextoFuerte)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.bienvenidaBorde),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: controller,
            enabled: !_loading,
            keyboardType: keyboardType,
            style: GoogleFonts.openSans(fontSize: 14, color: AppColors.bienvenidaTextoFuerte),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: InputBorder.none,
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Campo obligatorio';
              if (email && !v.contains('@')) return 'Correo inválido';
              return null;
            },
          ),
        ),
      ],
    );
  }
}
