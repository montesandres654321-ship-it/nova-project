import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';

/// Resultado del ping de ubicación al backend.
/// [municipio] es el slug si el usuario está en la región de Sucre,
/// [ciudad] es el nombre de la ciudad real (ej. "Medellín, Antioquia")
/// cuando está fuera de cobertura (obtenido por reverse geocoding en el backend).
class LocationResult {
  final String? municipio;
  final String? ciudad;
  const LocationResult({this.municipio, this.ciudad});
}

class LocationService {
  /// Pide permiso si hace falta, obtiene la posición y la envía al backend.
  /// Retorna [LocationResult] con el municipio y/o ciudad real.
  static Future<LocationResult?> pingLocation(String authToken) async {
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
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
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
        // El backend devuelve { success: true, municipio: 'sampues', ciudad: 'Medellín, Antioquia' }
        return LocationResult(
          municipio: body['municipio'] as String?,
          ciudad: body['ciudad'] as String?,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Verifica el permiso actual SIN solicitarlo (no interrumpe al usuario).
  /// Si ya está concedido, hace el ping y retorna el resultado de ubicación;
  /// si no, retorna null para que el caller mantenga visible el banner.
  static Future<LocationResult?> checkAndPing(String authToken) async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return pingLocation(authToken); // hace el POST y devuelve resultado
    }
    return null; // banner sigue visible
  }
}
