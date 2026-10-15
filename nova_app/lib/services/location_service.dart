import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';

class LocationService {
  /// Pide permiso si hace falta, obtiene la posición y la envía al backend.
  /// Retorna `false` si el permiso quedó denegado (para que el caller pueda
  /// mostrar un banner) — NO se silencia el resultado del permiso.
  static Future<bool> pingLocation(String authToken) async {
    try {
      // Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      // deniedForever: Geolocator no muestra ningún diálogo del sistema
      // (ya no sirve pedirlo de nuevo) — solo reportamos el estado.
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return false;
      }

      // Obtener posición
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );

      // Enviar al backend
      await http.post(
        Uri.parse('${AppConstants.backendUrl}/location/ping'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'lat': position.latitude,
          'lng': position.longitude,
        }),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Verifica el permiso actual SIN solicitarlo (no interrumpe al usuario).
  /// Si ya está concedido, hace el ping y retorna true; si no, retorna
  /// false para que el caller mantenga visible el banner de ubicación.
  static Future<bool> checkAndPing(String authToken) async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      await pingLocation(authToken); // hace el POST
      return true;
    }
    return false; // banner sigue visible
  }
}
