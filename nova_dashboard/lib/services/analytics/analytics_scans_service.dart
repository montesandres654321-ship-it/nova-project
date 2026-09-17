// lib/services/analytics/analytics_scans_service.dart
// Extraído de analytics_service.dart (getScansStats/getScansByDay/
// getTopPlacesByScans/getScansByHour/getAllScans) sin cambiar
// comportamiento.
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../utils/constants.dart';
import 'analytics_http.dart';

class AnalyticsScansService {
  Future<Map<String, dynamic>> getScansStats() async {
    try {
      final headers = await AnalyticsHttp.authHeaders();
      final url     = Uri.parse('${AnalyticsHttp.baseUrl}${AppConstants.scansStatsEndpoint}');
      final response = await http.get(url, headers: headers)
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Error ${response.statusCode}');
    } catch (e) { throw Exception('Error de red: $e'); }
  }

  /// [days] — Número de días hacia atrás a consultar.
  ///          Usar `3650` para obtener todo el historial sin filtro de fecha.
  ///          Por defecto: 180 días (últimos 6 meses).
  Future<List<Map<String, dynamic>>> getScansByDay({int days = 180}) async {
    try {
      final headers = await AnalyticsHttp.authHeaders();
      // Construir URL con query param ?days=N (no path param :days)
      final url = Uri.parse('${AnalyticsHttp.baseUrl}/analytics/scans/by-day')
          .replace(queryParameters: {'days': days.toString()});
      final response = await http.get(url, headers: headers)
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        // Maneja: { data:[...] }, { scans:[...] }, { scansByDay:[...] } o array directo
        if (body is List) return List<Map<String, dynamic>>.from(body);
        if (body is Map) {
          for (final key in ['data', 'scans', 'scansByDay', 'scans_by_day']) {
            if (body[key] is List) return List<Map<String, dynamic>>.from(body[key] as List);
          }
        }
        return [];
      }
      throw Exception('Error ${response.statusCode}');
    } catch (e) { throw Exception('Error de red: $e'); }
  }

  /// [limit] — Número máximo de lugares a retornar. Por defecto: 10.
  Future<List<Map<String, dynamic>>> getTopPlacesByScans({int limit = 10}) async {
    try {
      final headers = await AnalyticsHttp.authHeaders();
      final url = Uri.parse('${AnalyticsHttp.baseUrl}/analytics/scans/top-places')
          .replace(queryParameters: {'limit': limit.toString()});
      final response = await http.get(url, headers: headers)
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['places'] ?? []);
      }
      throw Exception('Error ${response.statusCode}');
    } catch (e) { throw Exception('Error de red: $e'); }
  }

  /// Distribución de escaneos por hora del día (horario pico), últimos 30 días.
  Future<List<Map<String, dynamic>>> getScansByHour() async {
    try {
      final headers = await AnalyticsHttp.authHeaders();
      final url     = Uri.parse('${AnalyticsHttp.baseUrl}/analytics/scans/by-hour');
      final response = await http.get(url, headers: headers)
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      }
      throw Exception('Error ${response.statusCode}');
    } catch (e) { throw Exception('Error de red: $e'); }
  }

  /// Todos los escaneos del sistema con paginación y búsqueda.
  ///
  /// [page] — inicia en 1. [limit] — registros por página (def. 50).
  /// [search] — texto sobre nombre/email del turista o nombre del lugar.
  Future<Map<String, dynamic>> getAllScans({
    int page = 1,
    int limit = 50,
    String search = '',
  }) async {
    try {
      final headers = await AnalyticsHttp.authHeaders();
      final uri = Uri.parse(
        '${AnalyticsHttp.baseUrl}/admin/scans/all'
        '?page=$page&limit=$limit&search=${Uri.encodeComponent(search)}'
      );
      final response = await http.get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'scans': List<Map<String, dynamic>>.from(data['data'] ?? []),
          'meta': data['meta'] ?? {},
        };
      }
      throw Exception(data['error'] ?? 'Error al cargar escaneos');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
