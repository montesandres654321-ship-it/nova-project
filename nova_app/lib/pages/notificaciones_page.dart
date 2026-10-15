// lib/pages/notificaciones_page.dart
// Pantalla simple de la última notificación recibida — los datos se
// guardan en SharedPreferences por NotificationService.saveNotification()
// (ver notification_service.dart) cada vez que llega un push, en
// foreground o background.
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/design/app_colors.dart';

class NotificacionesPage extends StatefulWidget {
  const NotificacionesPage({super.key});

  @override
  State<NotificacionesPage> createState() => _NotificacionesPageState();
}

class _NotificacionesPageState extends State<NotificacionesPage> {
  bool _loading = true;
  String? _titulo;
  String? _cuerpo;
  String? _municipio;
  String? _hora;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final titulo = prefs.getString('last_notif_title');
    final cuerpo = prefs.getString('last_notif_body');
    final municipio = prefs.getString('last_notif_municipio');
    final hora = prefs.getString('last_notif_time');

    // Marcar como vista — actualiza el badge en HomePage cuando se
    // regrese a esa pantalla (HomePage vuelve a leer el prefs al volver).
    await prefs.setBool('has_new_notification', false);

    if (!mounted) return;
    setState(() {
      _titulo = titulo;
      _cuerpo = cuerpo;
      _municipio = municipio;
      _hora = hora;
      _loading = false;
    });
  }

  String _formatearHora(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: AppColors.bienvenidaAzul,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.bienvenidaAzul),
            )
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    final hayNotificacion = _titulo != null && _titulo!.isNotEmpty;

    if (!hayNotificacion) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.notifications_none, size: 48, color: AppColors.textHint),
              SizedBox(height: 12),
              Text(
                'No tienes notificaciones aún',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    final tieneMunicipio = _municipio != null && _municipio!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🔔', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _titulo!,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _cuerpo ?? '',
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (tieneMunicipio)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.sistemaAzulClaro,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _municipio!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.bienvenidaAzul,
                      ),
                    ),
                  ),
                const Spacer(),
                Text(
                  _formatearHora(_hora),
                  style: const TextStyle(fontSize: 12, color: AppColors.textHint),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: tieneMunicipio
                    ? () => Navigator.pushNamed(context, '/recomendaciones',
                        arguments: _municipio)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bienvenidaAzul,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Ver lugares recomendados'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
