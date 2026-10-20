// lib/main.dart — Nova App Móvil
// ============================================================
// FIX: eliminada ruta /success estática con datos vacíos
// La navegación a SuccessPage solo se hace con MaterialPageRoute
// desde ScanPage (con datos reales)
// ============================================================

import 'package:flutter/material.dart';
import 'core/design/app_theme.dart';

import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/forgot_password_page.dart';
import 'pages/main_navigation_page.dart';
import 'pages/scan_page.dart';
import 'pages/settings_page.dart';
import 'pages/history_page.dart';
import 'pages/profile_page.dart';
import 'pages/change_password_page.dart';
import 'pages/about_page.dart';
import 'pages/splash_page.dart';
import 'pages/recomendaciones_page.dart';
import 'pages/notificaciones_page.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'core/navigator_key.dart';
import 'services/notification_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.saveNotification(message);
  print('[FCM Background] ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Crea el canal Android + inicializa flutter_local_notifications
  await NotificationService.init();
  NotificationService.setupNotificationHandlers();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Nova App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: '/splash',
      routes: {
        '/splash':          (context) => const SplashPage(),
        '/':                (context) => const LoginPage(),
        '/register':        (context) => const RegisterPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/home':            (context) => const MainNavigationPage(),
        '/scan':            (context) => const ScanPage(),
        '/settings':        (context) => const SettingsPage(),
        '/profile':         (context) => const ProfilePage(),
        '/change-password': (context) => const ChangePasswordPage(),
        '/about':           (context) => const AboutPage(),
        '/history':         (context) => const HistoryPage(),
        '/recomendaciones': (context) => const RecomendacionesPage(),
        '/notificaciones':  (context) => const NotificacionesPage(),
        // FIX: /success ELIMINADA — solo se navega con MaterialPageRoute
        // desde ScanPage con datos reales del backend
      },
      onUnknownRoute: (settings) {
        // Si alguien intenta /success por deep link, redirige al login
        return MaterialPageRoute(builder: (context) => const LoginPage());
      },
    );
  }
}