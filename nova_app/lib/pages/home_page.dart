/// Página principal de la app NOVA App para turistas.
///
/// Es el índice 0 del [MainNavigationPage] y la primera pantalla
/// que ve el turista después de iniciar sesión.
///
/// Los datos del usuario y el último escaneo se cargan desde
/// [SharedPreferences] (datos locales) y [ApiService.getScanHistory] (backend).
/// La presentación vive en [WelcomeCard], [StatsCard] y [ActionButtons]
/// (widgets/).
///
/// [onNavigateToTab] — callback para navegar a otras tabs del [MainNavigationPage]
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/scan_record.dart';
import '../services/api_service.dart';
import '../services/google_auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../core/design/app_colors.dart';
import '../core/design/app_spacing.dart';
import '../core/design/app_radius.dart';
import '../widgets/welcome_card.dart';
import '../widgets/stats_card.dart';
import '../widgets/action_buttons.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.onNavigateToTab});

  final void Function(int) onNavigateToTab;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ScanRecord? _lastScan;
  bool _loading = true;
  String _userName = '';
  String _userEmail = '';
  int _totalScans = 0;

  // ── Lifecycle ──────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadLastScan();
  }

  // ── Data ───────────────────────────────────────────────────

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(AppConstants.keyUser);

      if (userData != null) {
        final user = json.decode(userData);
        setState(() {
          _userName = user['first_name'] ?? user['username'] ?? 'Usuario';
          _userEmail = user['email'] ?? '';
        });
      } else {
        final userName =
            prefs.getString(AppConstants.keyUsername) ?? 'Usuario';
        final firstName =
            prefs.getString(AppConstants.keyFirstName) ?? '';
        final email = prefs.getString(AppConstants.keyEmail) ?? '';
        setState(() {
          _userName = firstName.isNotEmpty ? firstName : userName;
          _userEmail = email;
        });
      }
    } catch (e) {
      debugPrint('Error cargando datos: $e');
      setState(() {
        _userName = 'Usuario';
        _userEmail = '';
      });
    }
  }

  Future<void> _loadLastScan() async {
    setState(() => _loading = true);
    try {
      final scans = await ApiService.getScanHistory();
      setState(() {
        _totalScans = scans.length;
        if (scans.isNotEmpty) _lastScan = scans.first;
      });
    } catch (e) {
      debugPrint('Error cargando historial: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  // ── Actions ────────────────────────────────────────────────

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout_rounded,
                    color: AppColors.error, size: 32),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Cerrar sesión',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                '¿Estás seguro de que quieres salir?',
                style: TextStyle(
                    fontSize: 14, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.mdAll),
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        final isGoogle =
                            await GoogleAuthService.isGoogleUser();
                        if (isGoogle) await GoogleAuthService.signOut();
                        await ApiService.logout();
                        if (!mounted) return;
                        Navigator.pushReplacementNamed(context, '/');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.mdAll),
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Salir',
                          style:
                              TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            WelcomeCard(
              userName: _userName,
              userEmail: _userEmail,
              onLogout: _logout,
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // [1] CTA principal
                    _buildScanCTA(),
                    const SizedBox(height: AppSpacing.lg),

                    // [2] Último escaneo
                    StatsCard(
                      loading: _loading,
                      lastScan: _lastScan,
                      totalScans: _totalScans,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // [3] Accesos rápidos
                    ActionButtons(onNavigateToTab: widget.onNavigateToTab),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Botón principal de escaneo QR
  Widget _buildScanCTA() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/scan'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: AppRadius.lgAll,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.28),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Escanear QR',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Toca para escanear un lugar',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: AppRadius.mdAll,
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
