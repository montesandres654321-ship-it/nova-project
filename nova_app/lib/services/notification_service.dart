import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utils/constants.dart';
import '../core/navigator_key.dart';

/// Canal de notificaciones — debe coincidir con el channelId que envía el backend
const String _kChannelId   = 'nova_recomendaciones';
const String _kChannelName = 'Recomendaciones NOVA';
const String _kChannelDesc = 'Lugares y recompensas cerca de ti';

final FlutterLocalNotificationsPlugin _localNotif =
    FlutterLocalNotificationsPlugin();

class NotificationService {
  /// Inicializa flutter_local_notifications y crea el canal Android.
  /// Llamar UNA vez desde main(), antes de runApp().
  static Future<void> init() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _localNotif.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Usuario tocó la notificación local (foreground) → chequear JWT
        final municipio = response.payload ?? '';
        if (municipio.isEmpty) return;

        final prefs       = await SharedPreferences.getInstance();
        final token       = prefs.getString(AppConstants.keyToken);
        final tieneSession = token != null && token.isNotEmpty;

        if (tieneSession) {
          navigatorKey.currentState
              ?.pushNamed('/recomendaciones', arguments: municipio);
        } else {
          navigatorKey.currentState?.pushNamed(
            '/notificacion-preview',
            arguments: {'municipio': municipio},
          );
        }
      },
    );

    // Crear el canal en Android 8+ (obligatorio para que aparezca en bandeja)
    const androidChannel = AndroidNotificationChannel(
      _kChannelId,
      _kChannelName,
      description: _kChannelDesc,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotif
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }
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

  /// Navega al destino correcto según si el usuario tiene sesión activa.
  ///
  /// • Con JWT  → /recomendaciones  (pantalla autenticada, muestra lugares completos)
  /// • Sin JWT  → /notificacion-preview  (pantalla pública con preview + CTA de login)
  static Future<void> _routeAfterTap(RemoteMessage message) async {
    final municipio = message.data['municipio'] ?? '';
    final title     = message.notification?.title ?? '';
    final body      = message.notification?.body  ?? '';

    print('[FCM] Tap en notificación — municipio: $municipio');

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.keyToken);
    final tieneSession = token != null && token.isNotEmpty;

    if (tieneSession) {
      // Usuario autenticado → directo a recomendaciones
      navigatorKey.currentState
          ?.pushNamed('/recomendaciones', arguments: municipio);
    } else {
      // Sin sesión → preview público con nombre, foto y tipo de lugares
      navigatorKey.currentState?.pushNamed(
        '/notificacion-preview',
        arguments: {
          'municipio': municipio,
          'title':     title,
          'body':      body,
        },
      );
    }
  }

  static void setupNotificationHandlers() {
    // App en background → usuario toca la notificación
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _routeAfterTap(message);
    });

    // App en foreground → mostrar en bandeja del sistema como notificación real
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('[FCM Foreground] ${message.notification?.title}');
      saveNotification(message);
      _showLocalNotification(message);
    });
  }

  /// Muestra una notificación local en la bandeja del sistema.
  /// Se usa cuando la app está en foreground y FCM no la muestra
  /// automáticamente en Android.
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final notif = message.notification;
    if (notif == null) return;

    final municipio = message.data['municipio'] ?? '';

    const androidDetails = AndroidNotificationDetails(
      _kChannelId,
      _kChannelName,
      channelDescription: _kChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    await _localNotif.show(
      message.hashCode,
      notif.title,
      notif.body,
      const NotificationDetails(android: androidDetails),
      payload: municipio,
    );
  }
}
