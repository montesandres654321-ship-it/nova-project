// lib/core/navigator_key.dart
// Key global de navegación — permite navegar desde fuera del árbol de
// widgets (ej: el listener de FCM en notification_service.dart, que no
// tiene BuildContext propio). Vive en su propio archivo para que
// main.dart y notification_service.dart puedan importarlo sin crear
// un import circular entre ambos.
import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
