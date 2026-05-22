// lib/services/analytics_service.dart
// CORRECCIONES:
//  1. getScansByDay: usa Uri.replace(queryParameters) en lugar de
//     replaceParams() — backend usa ?days=N no /:days
//  2. getRewardsByDay: idem — usa queryParameters
//  3. getTopPlacesByScans: usa ?limit=N como query param
//  4. getTopPlacesByRewards: idem
//  5. getRewardsStats(): retorna body['stats'] no body completo
//  6. getScansByDay default 180 días para mostrar datos históricos

/// Servicio para consumir los endpoints de analytics del backend NOVA App.
///
/// Provee métodos para obtener estadísticas del sistema que alimentan
/// las gráficas y KPIs del [StatsDashboardPage]:
/// - Escaneos agrupados por día o por hora
/// - Top establecimientos por escaneos y recompensas
/// - Estadísticas de recompensas (tasa de canje, tiempo promedio)
/// - Turistas registrados por mes
/// - Distribución por tipo de establecimiento
///
/// Todos los métodos requieren que el usuario tenga sesión activa (JWT).
/// La URL base se configura mediante [AppConstants.backendUrl].
///
/// Ejemplo de uso:
/// ```dart
/// final analytics = AnalyticsService();
/// final scans = await analytics.getScansByDay(days: 30);
/// for (final day in scans) {
///   print('${day['date']}: ${day['count']} escaneos');
/// }
/// ```
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class AnalyticsService {
  static const String baseUrl = AppConstants.backendUrl;

  /// Construye los encabezados HTTP con el token JWT del usuario autenticado.
  ///
  /// Lee el token almacenado en [SharedPreferences] y lo incluye en el
  /// encabezado `Authorization: Bearer <token>`.
  ///
  /// Retorna un [Map] con `Content-Type` y `Authorization`.
  Future<Map<String, String>> getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.keyToken) ?? '';
    return {
      'Content-Type':  'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Stub de analytics en tiempo real — endpoint no disponible en el backend.
  ///
  /// Mantenido por compatibilidad con versiones anteriores del cliente.
  /// Retorna un mapa vacío sin lanzar excepción.
  ///
  /// Retorna siempre `{'available': false, 'message': 'Endpoint no disponible'}`.
  Future<Map<String, dynamic>> getRealTimeAnalytics() async {
    return {'available': false, 'message': 'Endpoint no disponible'};
  }

  /// Limpia la caché del servicio (stub — no hay caché implementada).
  ///
  /// Mantenido por compatibilidad. No realiza ninguna operación.
  Future<void> clearCache() async {
    // No hay endpoint real — no hacer nada
  }

  /// Obtiene estadísticas generales de escaneos del sistema.
  ///
  /// Llama a [AppConstants.scansStatsEndpoint] y retorna el cuerpo completo
  /// de la respuesta del backend.
  ///
  /// Lanza [Exception] si el servidor retorna un código de error o hay problemas de red.
  Future<Map<String, dynamic>> getScansStats() async {
    try {
      final headers = await getAuthHeaders();
      final url     = Uri.parse('$baseUrl${AppConstants.scansStatsEndpoint}');
      final response = await http.get(url, headers: headers)
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Error ${response.statusCode}');
    } catch (e) { throw Exception('Error de red: $e'); }
  }

  /// Obtiene los escaneos agrupados por día para el período indicado.
  ///
  /// Llama a `GET /analytics/scans/by-day?days=N`.
  /// Maneja múltiples formatos de respuesta del backend:
  /// `{ data:[...] }`, `{ scans:[...] }`, `{ scansByDay:[...] }` o array directo.
  ///
  /// [days] — Número de días hacia atrás a consultar.
  ///          Usar `3650` para obtener todo el historial sin filtro de fecha.
  ///          Por defecto: 180 días (últimos 6 meses).
  ///
  /// Retorna una lista de mapas con campos:
  /// - `date`: fecha en formato `'YYYY-MM-DD'`
  /// - `count`: número de escaneos ese día
  /// - `unique_users`: usuarios únicos que escanearon ese día
  ///
  /// Lanza [Exception] si hay error de red o el servidor retorna un código de error.
  Future<List<Map<String, dynamic>>> getScansByDay({int days = 180}) async {
    try {
      final headers = await getAuthHeaders();
      // Construir URL con query param ?days=N (no path param :days)
      final url = Uri.parse('$baseUrl/analytics/scans/by-day')
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

  /// Obtiene los establecimientos con más escaneos registrados.
  ///
  /// Llama a `GET /analytics/scans/top-places?limit=N`.
  ///
  /// [limit] — Número máximo de lugares a retornar. Por defecto: 10.
  ///
  /// Retorna una lista de mapas con campos:
  /// - `id`: ID del lugar
  /// - `name`: nombre del establecimiento
  /// - `tipo`: tipo (`hotel` | `restaurant` | `bar`)
  /// - `lugar`: municipio
  /// - `total_scans`: total de escaneos registrados
  /// - `unique_visitors`: visitantes únicos
  ///
  /// Lanza [Exception] si hay error de red o el servidor retorna un código de error.
  Future<List<Map<String, dynamic>>> getTopPlacesByScans({int limit = 10}) async {
    try {
      final headers = await getAuthHeaders();
      final url = Uri.parse('$baseUrl/analytics/scans/top-places')
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

  /// Obtiene la distribución de escaneos por hora del día (horario pico).
  ///
  /// Llama a `GET /analytics/scans/by-hour`.
  /// Analiza los últimos 30 días para identificar las horas de mayor actividad.
  ///
  /// Retorna una lista de 24 elementos (horas 0-23) con campos:
  /// - `hour`: hora del día (0 = medianoche, 12 = mediodía)
  /// - `count`: número de escaneos en esa hora en los últimos 30 días
  ///
  /// Lanza [Exception] si hay error de red o el servidor retorna un código de error.
  Future<List<Map<String, dynamic>>> getScansByHour() async {
    try {
      final headers = await getAuthHeaders();
      final url     = Uri.parse('$baseUrl/analytics/scans/by-hour');
      final response = await http.get(url, headers: headers)
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      }
      throw Exception('Error ${response.statusCode}');
    } catch (e) { throw Exception('Error de red: $e'); }
  }

  /// Obtiene estadísticas detalladas de recompensas del sistema.
  ///
  /// Llama a [AppConstants.rewardsStatsEndpoint] y extrae el objeto `stats`
  /// de la respuesta del backend (estructura: `{ success, stats: {...} }`).
  ///
  /// Retorna un [Map] con campos como:
  /// - `total_rewards`: total de recompensas generadas
  /// - `redeemed_rewards`: recompensas canjeadas
  /// - `pending_rewards`: pendientes de canje
  /// - `redemption_rate`: porcentaje de canje (0-100)
  /// - `hoy`: recompensas generadas hoy
  /// - `semana`: recompensas generadas en los últimos 7 días
  /// - `tiempoPromedioCanje`: días promedio entre obtención y canje
  ///
  /// Lanza [Exception] si hay error de red o el servidor retorna un código de error.
  Future<Map<String, dynamic>> getRewardsStats() async {
    try {
      final headers  = await getAuthHeaders();
      final url      = Uri.parse('$baseUrl${AppConstants.rewardsStatsEndpoint}');
      final response = await http.get(url, headers: headers)
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        // Extraer el objeto 'stats' anidado
        if (body.containsKey('stats') && body['stats'] is Map) {
          return body['stats'] as Map<String, dynamic>;
        }
        return body; // fallback si ya viene plano
      }
      throw Exception('Error ${response.statusCode}');
    } catch (e) { throw Exception('Error de red: $e'); }
  }

  /// Obtiene las recompensas generadas agrupadas por día.
  ///
  /// Llama a `GET /analytics/rewards/by-day?days=N`.
  ///
  /// [days] — Número de días hacia atrás a consultar. Por defecto: 30.
  ///
  /// Retorna una lista de mapas con campos:
  /// - `date`: fecha en formato `'YYYY-MM-DD'`
  /// - `count`: número de recompensas generadas ese día
  ///
  /// Lanza [Exception] si hay error de red o el servidor retorna un código de error.
  Future<List<Map<String, dynamic>>> getRewardsByDay({int days = 30}) async {
    try {
      final headers = await getAuthHeaders();
      final url = Uri.parse('$baseUrl/analytics/rewards/by-day')
          .replace(queryParameters: {'days': days.toString()});
      final response = await http.get(url, headers: headers)
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(
            data['data'] ?? data['rewards'] ?? []);
      }
      throw Exception('Error ${response.statusCode}');
    } catch (e) { throw Exception('Error de red: $e'); }
  }

  /// Obtiene los establecimientos con más recompensas otorgadas.
  ///
  /// Llama a `GET /analytics/rewards/top-places?limit=N`.
  ///
  /// [limit] — Número máximo de lugares a retornar. Por defecto: 10.
  ///
  /// Retorna una lista de mapas con campos:
  /// - `id`, `name`, `tipo`, `lugar`
  /// - `total_rewards`: total de recompensas del lugar
  /// - `redeemed`: recompensas canjeadas
  /// - `pending`: recompensas pendientes
  ///
  /// Lanza [Exception] si hay error de red o el servidor retorna un código de error.
  Future<List<Map<String, dynamic>>> getTopPlacesByRewards({int limit = 10}) async {
    try {
      final headers = await getAuthHeaders();
      final url = Uri.parse('$baseUrl/analytics/rewards/top-places')
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

  /// Obtiene la distribución de recompensas por tipo de establecimiento.
  ///
  /// Llama a `GET /analytics/rewards/by-type`.
  ///
  /// Retorna un [Map] con tres claves (`hotel`, `restaurant`, `bar`),
  /// cada una con `total`, `canjeadas` y `pendientes`.
  ///
  /// Retorna `null` si hay un error en la consulta.
  Future<Map<String, dynamic>?> getRewardsByType() async {
    try {
      final headers  = await getAuthHeaders();
      final url      = Uri.parse('$baseUrl/analytics/rewards/by-type');
      final response = await http.get(url, headers: headers)
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return body['data'] as Map<String, dynamic>? ?? body;
      }
      throw Exception('Error ${response.statusCode}');
    } catch (e) { throw Exception('Error de red: $e'); }
  }

  /// Obtiene estadísticas de turistas registrados en el sistema.
  ///
  /// Llama a `GET /analytics/users/stats`.
  ///
  /// Retorna un [Map] con campos:
  /// - `stats.total`: total de turistas registrados
  /// - `stats.active`: activos en los últimos 30 días
  /// - `stats.newThisMonth`: nuevos este mes
  /// - `stats.byMonth`: lista de registros por mes (últimos 6 meses)
  ///
  /// Lanza [Exception] si hay error de red o el servidor retorna un código de error.
  Future<Map<String, dynamic>> getUsersStats() async {
    try {
      final headers  = await getAuthHeaders();
      final url      = Uri.parse('$baseUrl/analytics/users/stats');
      final response = await http.get(url, headers: headers)
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Error ${response.statusCode}');
    } catch (e) { throw Exception('Error de red: $e'); }
  }

  /// Obtiene estadísticas de lugares turísticos activos.
  ///
  /// Llama a `GET /analytics/places/stats`.
  ///
  /// Retorna un [Map] con campos en `stats`:
  /// - `total`: total de lugares activos
  /// - `withOwner`: lugares con propietario asignado
  /// - `withReward`: lugares con recompensa activa
  /// - `byType`: distribución por tipo (hotel, restaurant, bar)
  /// - `avgRating`: calificación promedio de todos los lugares
  ///
  /// Lanza [Exception] si hay error de red o el servidor retorna un código de error.
  Future<Map<String, dynamic>> getPlacesStats() async {
    try {
      final headers  = await getAuthHeaders();
      final url      = Uri.parse('$baseUrl/analytics/places/stats');
      final response = await http.get(url, headers: headers)
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Error ${response.statusCode}');
    } catch (e) { throw Exception('Error de red: $e'); }
  }

  /// Obtiene todos los escaneos del sistema con paginación y búsqueda.
  ///
  /// Llama a `GET /admin/scans/all?page=N&limit=N&search=texto`.
  ///
  /// [page] — Número de página (inicia en 1). Por defecto: 1.
  /// [limit] — Registros por página. Por defecto: 50.
  /// [search] — Texto de búsqueda sobre nombre, email del turista o nombre del lugar.
  ///
  /// Retorna un [Map] con:
  /// - `scans`: lista de escaneos de la página actual
  /// - `meta`: objeto con `total`, `page`, `limit`, `pages`
  ///
  /// Lanza [Exception] si hay error de red o el servidor retorna un código de error.
  Future<Map<String, dynamic>> getAllScans({
    int page = 1,
    int limit = 50,
    String search = '',
  }) async {
    try {
      final headers = await getAuthHeaders();
      final uri = Uri.parse(
        '$baseUrl/admin/scans/all'
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
