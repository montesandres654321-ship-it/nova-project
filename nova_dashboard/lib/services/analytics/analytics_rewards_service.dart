// lib/services/analytics/analytics_rewards_service.dart
// Extraído de analytics_service.dart (getRewardsStats/getRewardsByDay/
// getTopPlacesByRewards/getRewardsByType) sin cambiar comportamiento.
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../utils/constants.dart';
import 'analytics_http.dart';

class AnalyticsRewardsService {
  /// Extrae el objeto `stats` anidado de la respuesta del backend
  /// (estructura: `{ success, stats: {...} }`).
  Future<Map<String, dynamic>> getRewardsStats() async {
    try {
      final headers  = await AnalyticsHttp.authHeaders();
      final url      = Uri.parse('${AnalyticsHttp.baseUrl}${AppConstants.rewardsStatsEndpoint}');
      final response = await http.get(url, headers: headers)
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body.containsKey('stats') && body['stats'] is Map) {
          return body['stats'] as Map<String, dynamic>;
        }
        return body; // fallback si ya viene plano
      }
      throw Exception('Error ${response.statusCode}');
    } catch (e) { throw Exception('Error de red: $e'); }
  }

  /// [days] — Número de días hacia atrás a consultar. Por defecto: 30.
  Future<List<Map<String, dynamic>>> getRewardsByDay({int days = 30}) async {
    try {
      final headers = await AnalyticsHttp.authHeaders();
      final url = Uri.parse('${AnalyticsHttp.baseUrl}/analytics/rewards/by-day')
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

  /// [limit] — Número máximo de lugares a retornar. Por defecto: 10.
  Future<List<Map<String, dynamic>>> getTopPlacesByRewards({int limit = 10}) async {
    try {
      final headers = await AnalyticsHttp.authHeaders();
      final url = Uri.parse('${AnalyticsHttp.baseUrl}/analytics/rewards/top-places')
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

  /// Distribución de recompensas por tipo de establecimiento
  /// (`hotel`/`restaurant`/`bar`, cada uno con `total`/`canjeadas`/`pendientes`).
  Future<Map<String, dynamic>?> getRewardsByType() async {
    try {
      final headers  = await AnalyticsHttp.authHeaders();
      final url      = Uri.parse('${AnalyticsHttp.baseUrl}/analytics/rewards/by-type');
      final response = await http.get(url, headers: headers)
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return body['data'] as Map<String, dynamic>? ?? body;
      }
      throw Exception('Error ${response.statusCode}');
    } catch (e) { throw Exception('Error de red: $e'); }
  }
}
