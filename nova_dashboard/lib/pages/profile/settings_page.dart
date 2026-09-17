// lib/pages/profile/settings_page.dart
// ============================================================
// REDESIGN: SaaS settings panel · categorías · items premium
// Lógica sin cambios
// REFACTOR: tarjetas, filas y diálogo extraídos a
// lib/pages/profile/settings/ para bajar de 486 a <300 líneas.
// NOTA: página sin ruta activa (código no alcanzable desde la navegación
// actual, según AUDITORIA_DASHBOARD_REPORTE.md) — se refactoriza igual
// por pedido explícito, sin cambiar su comportamiento.
// ============================================================
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings/dialogs/clear_cache_dialog.dart';
import 'settings/settings_tokens.dart';
import 'settings/widgets/settings_shared.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  // ── State — SIN CAMBIOS ───────────────────────────────
  bool   _notifications      = true;
  bool   _emailNotifications = true;
  bool   _autoRefresh        = true;
  String _language           = 'es';
  String _dateFormat         = 'dd/MM/yyyy';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // ── LÓGICA — SIN CAMBIOS ─────────────────────────────
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notifications      = prefs.getBool('notifications')       ?? true;
      _emailNotifications = prefs.getBool('email_notifications') ?? true;
      _autoRefresh        = prefs.getBool('auto_refresh')        ?? true;
      _language           = prefs.getString('language')          ?? 'es';
      _dateFormat         = prefs.getString('date_format')       ?? 'dd/MM/yyyy';
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool)   { await prefs.setBool(key, value); }
    else if (value is String) { await prefs.setString(key, value); }
  }

  // ─────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSettingsBgPage,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: kSettingsTextHead,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text('Configuración',
            style: TextStyle(fontSize: 16,
                fontWeight: FontWeight.w600, color: kSettingsTextHead)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: kSettingsBorder),
        ),
      ),
      body: LayoutBuilder(builder: (_, constraints) {
        final isWide = constraints.maxWidth > 700;
        return SingleChildScrollView(
          padding: EdgeInsets.all(isWide ? 28.0 : 16.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  // ── Notificaciones ─────────────────
                  SettingsCard(title: 'Notificaciones', children: [
                    settingsToggleRow(
                      icon: Icons.notifications_outlined,
                      iconColor: kSettingsPrimary,
                      title: 'Notificaciones push',
                      subtitle: 'Alertas en tiempo real',
                      value: _notifications,
                      onChanged: (v) {
                        setState(() => _notifications = v);
                        _saveSetting('notifications', v);
                      },
                    ),
                    settingsItemDivider(),
                    settingsToggleRow(
                      icon: Icons.mail_outline_rounded,
                      iconColor: kSettingsBlue,
                      title: 'Notificaciones por email',
                      subtitle: 'Resúmenes por correo',
                      value: _emailNotifications,
                      onChanged: (v) {
                        setState(() => _emailNotifications = v);
                        _saveSetting('email_notifications', v);
                      },
                    ),
                  ]),

                  const SizedBox(height: 16),

                  // ── Preferencias ───────────────────
                  SettingsCard(title: 'Preferencias', children: [
                    settingsToggleRow(
                      icon: Icons.sync_rounded,
                      iconColor: kSettingsAmber,
                      title: 'Auto-actualizar',
                      subtitle: 'Recargar datos automáticamente',
                      value: _autoRefresh,
                      onChanged: (v) {
                        setState(() => _autoRefresh = v);
                        _saveSetting('auto_refresh', v);
                      },
                    ),
                    settingsItemDivider(),
                    settingsDropdownRow(
                      icon: Icons.language_rounded,
                      iconColor: kSettingsBlue,
                      title: 'Idioma',
                      subtitle: 'Idioma de la interfaz',
                      trailing: settingsStyledDropdown<String>(
                        value: _language,
                        items: const [
                          DropdownMenuItem(value: 'es', child: Text('Español')),
                          DropdownMenuItem(value: 'en', child: Text('English')),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            setState(() => _language = v);
                            _saveSetting('language', v);
                          }
                        },
                      ),
                    ),
                    settingsItemDivider(),
                    settingsDropdownRow(
                      icon: Icons.calendar_today_rounded,
                      iconColor: kSettingsPrimary,
                      title: 'Formato de fecha',
                      subtitle: 'Cómo se muestran las fechas',
                      trailing: settingsStyledDropdown<String>(
                        value: _dateFormat,
                        items: const [
                          DropdownMenuItem(
                              value: 'dd/MM/yyyy',
                              child: Text('DD/MM/AAAA')),
                          DropdownMenuItem(
                              value: 'MM/dd/yyyy',
                              child: Text('MM/DD/AAAA')),
                          DropdownMenuItem(
                              value: 'yyyy-MM-dd',
                              child: Text('AAAA-MM-DD')),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            setState(() => _dateFormat = v);
                            _saveSetting('date_format', v);
                          }
                        },
                      ),
                    ),
                  ]),

                  const SizedBox(height: 16),

                  // ── Sistema ────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: const Color(0xFFFEE2E2)),
                      boxShadow: [BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8, offset: const Offset(0, 2),
                      )],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
                          child: Row(children: [
                            Container(
                              width: 6, height: 6,
                              decoration: const BoxDecoration(
                                  color: kSettingsRed, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 8),
                            const Text('Sistema',
                                style: TextStyle(fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: kSettingsRed)),
                          ]),
                        ),
                        const Divider(height: 20, thickness: 0.5,
                            color: Color(0xFFFEE2E2)),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                          child: settingsDangerRow(
                            icon: Icons.cleaning_services_rounded,
                            title: 'Limpiar caché',
                            subtitle:
                                'Eliminar datos temporales del sistema',
                            onTap: () => showClearCacheDialog(context),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
