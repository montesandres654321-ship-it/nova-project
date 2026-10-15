import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utils/constants.dart';
import '../core/navigator_key.dart';

class NotificationService {
  /// Guarda la última notificación recibida en SharedPreferences, para
  /// que NotificacionesPage la muestre. Pública (no `_saveNotification`)
  /// porque el background handler de main.dart también la llama, y ese
  /// handler vive en otro archivo.
  static Future<void> saveNotification(RemoteMessage message) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'last_notif_title', message.notification?.title ?? '');
    await prefs.setString(
        'last_notif_body', message.notification?.body ?? '');
    await prefs.setString(
        'last_notif_municipio', message.data['municipio'] ?? '');
    await prefs.setString(
        'last_notif_time', DateTime.now().toIso8601String());
    await prefs.setBool('has_new_notification', true);
  }
  /// Registra el token FCM del dispositivo en el backend. Si el usuario
  /// todavía no tiene el permiso de notificaciones concedido, primero
  /// muestra un diálogo explicativo — solo pide el permiso del sistema
  /// si el usuario acepta "Activar".
  static Future<void> registerToken(
      String authToken, BuildContext context) async {
    final messaging = FirebaseMessaging.instance;

    final currentSettings = await messaging.getNotificationSettings();
    NotificationSettings settings;

    if (currentSettings.authorizationStatus == AuthorizationStatus.authorized) {
      // Ya tiene el permiso — saltarse el diálogo y registrar directo.
      settings = currentSettings;
    } else {
      if (!context.mounted) return;
      final activar = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Recomendaciones para ti'),
          content: const Text(
            'Activa las notificaciones para recibir sugerencias de '
            'lugares y platos cerca de donde estás.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Ahora no'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Activar'),
            ),
          ],
        ),
      );

      if (activar != true) return;

      settings = await messaging.requestPermission(
        alert: true, badge: true, sound: true,
      );
    }

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      final fcmToken = await messaging.getToken();
      if (fcmToken == null) return;

      try {
        await http.post(
          Uri.parse('${AppConstants.backendUrl}/devices/register'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $authToken',
          },
          body: jsonEncode({'token': fcmToken}),
        );
        print('[FCM] Token registrado en backend');
      } catch (e) {
        print('[FCM] Error registrando token: $e');
      }
    }
  }

  static void setupNotificationHandlers() {
    // App en background → usuario toca la notificación
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final municipio = message.data['municipio'];
      print('[FCM] Notificación abierta, municipio: $municipio');
      if (municipio != null) {
        navigatorKey.currentState
            ?.pushNamed('/recomendaciones', arguments: municipio);
      }
    });

    // App en foreground → mostrar notificación en pantalla
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('[FCM Foreground] ${message.notification?.title}');
      saveNotification(message);
    });
  }
}
