// lib/pages/profile/profile_page.dart
// ============================================================
// REDESIGN: SaaS profile panel · avatar · sections · logout
// Lógica sin cambios
// REFACTOR: tarjetas y diálogo de logout extraídos a
// lib/pages/profile/widgets/ para bajar de 694 a <300 líneas.
// ============================================================
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/constants.dart';
import '../../services/admin_service.dart';
import 'change_password_dialog.dart';
import 'profile_tokens.dart';
import 'widgets/logout_dialog.dart';
import 'widgets/profile_danger_card.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_info_card.dart';
import 'widgets/profile_security_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  // ── State — SIN CAMBIOS ───────────────────────────────
  String _userName = '', _userEmail = '', _userRole = '';
  int?   _userId;
  late TextEditingController _firstNameController,
      _lastNameController, _phoneController;
  bool _loading = true, _editing = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController  = TextEditingController();
    _phoneController     = TextEditingController();
    _loadUserData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ── LÓGICA — SIN CAMBIOS ─────────────────────────────
  Future<void> _loadUserData() async {
    setState(() => _loading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _userName  = prefs.getString(AppConstants.keyUserName)  ?? '';
        _userEmail = prefs.getString(AppConstants.keyUserEmail) ?? '';
        _userRole  = prefs.getString(AppConstants.keyUserRole)  ?? '';
        _userId    = prefs.getInt(AppConstants.keyUserId);
        final parts = _userName.split(' ');
        if (parts.length >= 2) {
          _firstNameController.text = parts.first;
          _lastNameController.text  = parts.sublist(1).join(' ');
        } else {
          _firstNameController.text = _userName;
        }
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _saveChanges() async {
    if (_userId == null) return;
    setState(() => _loading = true);
    try {
      final result = await AdminService.updateMyProfile(
        firstName: _firstNameController.text.trim(),
        lastName:  _lastNameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null : _phoneController.text.trim(),
      );
      if (result['success'] == true) {
        final prefs    = await SharedPreferences.getInstance();
        final fullName =
            '${_firstNameController.text} ${_lastNameController.text}'.trim();
        await prefs.setString(AppConstants.keyUserName, fullName);
        setState(() { _userName = fullName; _editing = false; _loading = false; });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(result['message'] ?? 'Perfil actualizado'),
              backgroundColor: Colors.green));
        }
      } else {
        setState(() => _loading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(result['error'] ?? 'Error'),
              backgroundColor: Colors.red));
        }
      }
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  void _showChangePasswordDialog() {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('No se pudo obtener el ID'),
          backgroundColor: Colors.red));
      return;
    }
    showDialog(context: context,
        builder: (_) => ChangePasswordDialog(userId: _userId!));
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => LogoutDialog(
        onConfirm: () async {
          await AdminService.logout();
          if (mounted) {
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/login', (_) => false);
          }
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: kProfileBgPage,
        body: Center(child: CircularProgressIndicator(color: kProfilePrimary)),
      );
    }

    return Scaffold(
      backgroundColor: kProfileBgPage,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: kProfileTextHead,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text('Mi Perfil',
            style: TextStyle(fontSize: 16,
                fontWeight: FontWeight.w600, color: kProfileTextHead)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: kProfileBorder),
        ),
      ),
      body: LayoutBuilder(builder: (_, constraints) {
        final isWide = constraints.maxWidth > 700;
        return SingleChildScrollView(
          padding: EdgeInsets.all(isWide ? 28.0 : 16.0),
          child: isWide
              // ── Desktop: 2 columnas — info | seguridad+peligro ──
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _profileHeader(),
                          const SizedBox(height: 20),
                          _infoCard(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _securityCard(),
                          const SizedBox(height: 16),
                          _dangerCard(),
                        ],
                      ),
                    ),
                  ],
                )
              // ── Mobile: 1 columna (igual que antes) ─────────────
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _profileHeader(),
                    const SizedBox(height: 20),
                    _infoCard(),
                    const SizedBox(height: 16),
                    _securityCard(),
                    const SizedBox(height: 16),
                    _dangerCard(),
                    const SizedBox(height: 28),
                  ],
                ),
        );
      }),
    );
  }

  Widget _profileHeader() => ProfileHeader(
      userName: _userName, userEmail: _userEmail, userRole: _userRole);

  Widget _infoCard() => ProfileInfoCard(
      editing: _editing,
      userName: _userName,
      userEmail: _userEmail,
      firstNameController: _firstNameController,
      lastNameController: _lastNameController,
      phoneController: _phoneController,
      onStartEdit: () => setState(() => _editing = true),
      onCancelEdit: () { setState(() => _editing = false); _loadUserData(); },
      onSave: _saveChanges);

  Widget _securityCard() => ProfileSecurityCard(
      userRole: _userRole, onChangePassword: _showChangePasswordDialog);

  Widget _dangerCard() => ProfileDangerCard(onLogout: _confirmLogout);
}
