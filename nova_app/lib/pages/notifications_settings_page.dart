/// Página de configuración de Notificaciones.
///
/// Permite activar/desactivar cada tipo de alerta.
/// Estado persiste en SharedPreferences — sin backend por ahora.
/// Cuando se integre FCM, solo se añade la llamada al servicio aquí,
/// sin cambiar la UI.
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/design/app_colors.dart';

// ── Claves SharedPreferences ─────────────────────────────────
const _kNotifEventos    = 'notif_eventos';
const _kNotifBeneficios = 'notif_beneficios';
const _kNotifNoticias   = 'notif_noticias';
const _kNotifRecordatorios = 'notif_recordatorios';

class NotificationsSettingsPage extends StatefulWidget {
  const NotificationsSettingsPage({super.key});

  @override
  State<NotificationsSettingsPage> createState() => _NotificationsSettingsPageState();
}

class _NotificationsSettingsPageState extends State<NotificationsSettingsPage> {
  bool _eventos        = true;
  bool _beneficios     = true;
  bool _noticias       = false;
  bool _recordatorios  = true;
  bool _loading        = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _eventos        = prefs.getBool(_kNotifEventos)        ?? true;
      _beneficios     = prefs.getBool(_kNotifBeneficios)     ?? true;
      _noticias       = prefs.getBool(_kNotifNoticias)       ?? false;
      _recordatorios  = prefs.getBool(_kNotifRecordatorios)  ?? true;
      _loading        = false;
    });
  }

  Future<void> _save(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: SafeArea(
        child: Column(
          children: [
            _buildEncabezado(context),
            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Descripción
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.bienvenidaAzulClaro,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.notifications_rounded,
                                color: AppColors.bienvenidaAzul, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Elige qué alertas quieres recibir sobre tu experiencia en Nova.',
                                style: GoogleFonts.openSans(
                                    fontSize: 13, color: AppColors.bienvenidaAzul, height: 1.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildSectionLabel('ALERTAS Y AVISOS'),
                      const SizedBox(height: 8),
                      _buildCard([
                        _buildToggleRow(
                          icon: Icons.event_rounded,
                          title: 'Eventos y actividades',
                          subtitle: 'Juegos Nacionales 2027 y programación local',
                          value: _eventos,
                          onChanged: (v) {
                            setState(() => _eventos = v);
                            _save(_kNotifEventos, v);
                          },
                        ),
                        _buildToggleRow(
                          icon: Icons.card_giftcard_rounded,
                          title: 'Beneficios y recompensas',
                          subtitle: 'Puntos acumulados y canjes disponibles',
                          value: _beneficios,
                          onChanged: (v) {
                            setState(() => _beneficios = v);
                            _save(_kNotifBeneficios, v);
                          },
                        ),
                        _buildToggleRow(
                          icon: Icons.campaign_rounded,
                          title: 'Novedades de Nova',
                          subtitle: 'Nuevas funciones y actualizaciones',
                          value: _noticias,
                          onChanged: (v) {
                            setState(() => _noticias = v);
                            _save(_kNotifNoticias, v);
                          },
                        ),
                        _buildToggleRow(
                          icon: Icons.alarm_rounded,
                          title: 'Recordatorios',
                          subtitle: 'Recordatorios de visitas y escaneos',
                          value: _recordatorios,
                          onChanged: (v) {
                            setState(() => _recordatorios = v);
                            _save(_kNotifRecordatorios, v);
                          },
                          isLast: true,
                        ),
                      ]),

                      const SizedBox(height: 20),
                      Text(
                        'Puedes cambiar estas preferencias en cualquier momento. Las notificaciones del sistema operativo deben habilitarse desde los ajustes de tu teléfono.',
                        style: GoogleFonts.openSans(
                            fontSize: 11, color: AppColors.textHint, height: 1.6),
                        textAlign: TextAlign.center,
                      ),
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
              decoration: const BoxDecoration(
                  color: AppColors.bienvenidaAzulClaro, shape: BoxShape.circle),
              child: Center(
                  child: SvgPicture.asset('assets/icons/ic-flecha-atras.svg', width: 16)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Notificaciones',
                    style: GoogleFonts.openSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.bienvenidaTextoFuerte)),
                Text('Gestiona tus alertas',
                    style: GoogleFonts.openSans(
                        fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(text,
        style: GoogleFonts.openSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 0.5));
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.bienvenidaBorde),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(children: children),
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: value ? AppColors.bienvenidaAzulClaro : const Color(0xFFF0F4F8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon,
                    size: 18,
                    color: value ? AppColors.bienvenidaAzul : AppColors.textHint),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: GoogleFonts.openSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.bienvenidaTextoFuerte)),
                    Text(subtitle,
                        style: GoogleFonts.openSans(
                            fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Switch.adaptive(
                value: value,
                onChanged: onChanged,
                activeColor: AppColors.bienvenidaAzul,
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(height: 1, thickness: 1, color: AppColors.bienvenidaBorde),
      ],
    );
  }
}
