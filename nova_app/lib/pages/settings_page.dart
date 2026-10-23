/// Página "Ajustes de Nova" — preferencias y soporte.
///
/// Diseño Figma Septiembre 2026 (node 42:434): dos secciones de tarjetas
/// (Preferencias / Soporte y Legal) con ícono, título y descripción por fila.
/// "Cambiar contraseña" no aplica a cuentas de Google (sin contraseña local),
/// igual que en el diseño anterior.
library;

import 'package:flutter/material.dart';
import '../core/design/app_text_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/design/app_colors.dart';
import '../services/google_auth_service.dart';
import 'about_page.dart';
import 'change_password_page.dart';
import 'help_page.dart';
import 'notifications_settings_page.dart';
import 'terms_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bienvenidaFondoInput,
      body: SafeArea(
        child: Column(
          children: [
            _buildEncabezado(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionLabel('PREFERENCIAS'),
                    const SizedBox(height: 8),
                    FutureBuilder<bool>(
                      future: GoogleAuthService.isGoogleUser(),
                      builder: (context, snapshot) {
                        final isGoogleUser = snapshot.data == true;
                        return _buildCard([
                          _SettingsRow(
                            iconAsset: 'assets/icons/ic-bell.svg',
                            title: 'Notificaciones',
                            subtitle: 'Alertas de eventos y beneficios',
                            onTap: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const NotificationsSettingsPage())),
                          ),
                          if (!isGoogleUser)
                            _SettingsRow(
                              iconAsset: 'assets/icons/ic-key.svg',
                              title: 'Cambiar contraseña',
                              subtitle: 'Actualizar credenciales de seguridad',
                              onTap: () => Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => const ChangePasswordPage())),
                            ),
                        ]);
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildSectionLabel('SOPORTE Y LEGAL'),
                    const SizedBox(height: 8),
                    _buildCard([
                      _SettingsRow(
                        iconAsset: 'assets/icons/ic-file-text.svg',
                        title: 'Términos y condiciones',
                        subtitle: 'Políticas de uso de la plataforma',
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const TermsPage())),
                      ),
                      _SettingsRow(
                        iconAsset: 'assets/icons/ic-help-circle.svg',
                        title: 'Ayuda y Soporte',
                        subtitle: 'Preguntas frecuentes y contacto',
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const HelpPage())),
                      ),
                      _SettingsRow(
                        iconAsset: 'assets/icons/ic-info.svg',
                        title: 'Acerca de Nova',
                        subtitle: 'Versión, créditos y más',
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const AboutPage())),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEncabezado(BuildContext context) {
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
                Text('Ajustes de Nova',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.bienvenidaTextoFuerte)),
                Text('Configuraciones de la aplicación',
                    style: AppTextStyles.bodySm),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(text,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.5));
  }

  Widget _buildCard(List<_SettingsRow> rows) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.bienvenidaBorde),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: List.generate(rows.length, (i) {
          return Column(
            children: [
              rows[i],
              if (i < rows.length - 1)
                const Divider(height: 1, thickness: 1, color: AppColors.bienvenidaBorde),
            ],
          );
        }),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.iconAsset,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String iconAsset;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: AppColors.bienvenidaAzulClaro, borderRadius: BorderRadius.circular(10)),
              child: Center(child: SvgPicture.asset(iconAsset, width: 18, height: 18)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.bienvenidaTextoFuerte)),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            SvgPicture.asset('assets/icons/ic-chevron-right.svg', width: 16, height: 16),
          ],
        ),
      ),
    );
  }
}
