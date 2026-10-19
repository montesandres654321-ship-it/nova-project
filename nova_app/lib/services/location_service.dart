import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';

class LocationService {
  /// Pide permiso si hace falta, obtiene la posición y la envía al backend.
  /// Retorna el slug del municipio resuelto (p.ej. 'sampues') si todo va
  /// bien, o `null` si el permiso fue denegado o hubo un error.
  static Future<String?> pingLocation(String authToken) async {
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
        return null;
      }

      // Obtener posición
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );

      // Enviar al backend y capturar el municipio resuelto
      final response = await http.post(
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

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        // El backend devuelve { success: true, municipio: 'sampues' }
        final municipio = body['municipio'] as String?;
        return municipio; // puede ser null si las coords no caen en ningún bbox
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Verifica el permiso actual SIN solicitarlo (no interrumpe al usuario).
  /// Si ya está concedido, hace el ping y retorna el municipio resuelto;
  /// si no, retorna null para que el caller mantenga visible el banner.
  static Future<String?> checkAndPing(String authToken) async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return pingLocation(authToken); // hace el POST y devuelve municipio
    }
    return null; // banner sigue visible
  }
}
