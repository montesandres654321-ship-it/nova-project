// lib/services/analytics/analytics_misc_service.dart
// Extraído de analytics_service.dart (getRealTimeAnalytics/clearCache/
// getUsersStats/getPlacesStats) sin cambiar comportamiento.
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'analytics_http.dart';

class AnalyticsMiscService {
  /// Stub de analytics en tiempo real — endpoint no disponible en el backend.
  /// Mantenido por compatibilidad. No lanza excepción.
  Future<Map<String, dynamic>> getRealTimeAnalytics() async {
    return {'available': false, 'message': 'Endpoint no disponible'};
  }

  /// Limpia la caché del servicio (stub — no hay caché implementada).
  Future<void> clearCache() async {
    // No hay endpoint real — no hacer nada
  }

  /// Estadísticas de turistas registrados (`stats.total`, `stats.active`,
  /// `stats.newThisMonth`, `stats.byMonth`).
  Future<Map<String, dynamic>> getUsersStats() async {
    try {
      final headers  = await AnalyticsHttp.authHeaders();
      final url      = Uri.parse('${AnalyticsHttp.baseUrl}/analytics/users/stats');
      final response = await http.get(url, headers: headers)
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Error ${response.statusCode}');
    } catch (e) { throw Exception('Error de red: $e'); }
  }

  /// Estadísticas de lugares turísticos activos (`stats.total`,
  /// `stats.withOwner`, `stats.withReward`, `stats.byType`, `stats.avgRating`).
  Future<Map<String, dynamic>> getPlacesStats() async {
    try {
      final headers  = await AnalyticsHttp.authHeaders();
      final url      = Uri.parse('${AnalyticsHttp.baseUrl}/analytics/places/stats');
      final response = await http.get(url, headers: headers)
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Error ${response.statusCode}');
    } catch (e) { throw Exception('Error de red: $e'); }
  }
}
