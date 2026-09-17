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
///
/// REFACTOR: la lógica real vive en lib/services/analytics/
/// (analytics_http, analytics_scans_service, analytics_rewards_service,
/// analytics_misc_service), dividida por dominio para que ningún archivo
/// supere 300 líneas. Esta clase se mantiene como la ÚNICA API pública
/// (métodos de instancia, igual que antes) para no tener que tocar los
/// archivos que ya la usan — cada método delega, sin cambiar firmas.
library;

import 'analytics/analytics_http.dart';
import 'analytics/analytics_misc_service.dart';
import 'analytics/analytics_rewards_service.dart';
import 'analytics/analytics_scans_service.dart';

class AnalyticsService {
  final _scans   = AnalyticsScansService();
  final _rewards = AnalyticsRewardsService();
  final _misc    = AnalyticsMiscService();

  Future<Map<String, String>> getAuthHeaders() => AnalyticsHttp.authHeaders();

  Future<Map<String, dynamic>> getRealTimeAnalytics() => _misc.getRealTimeAnalytics();
  Future<void> clearCache() => _misc.clearCache();

  Future<Map<String, dynamic>> getScansStats() => _scans.getScansStats();
  Future<List<Map<String, dynamic>>> getScansByDay({int days = 180}) =>
      _scans.getScansByDay(days: days);
  Future<List<Map<String, dynamic>>> getTopPlacesByScans({int limit = 10}) =>
      _scans.getTopPlacesByScans(limit: limit);
  Future<List<Map<String, dynamic>>> getScansByHour() => _scans.getScansByHour();
  Future<Map<String, dynamic>> getAllScans({
    int page = 1,
    int limit = 50,
    String search = '',
  }) =>
      _scans.getAllScans(page: page, limit: limit, search: search);

  Future<Map<String, dynamic>> getRewardsStats() => _rewards.getRewardsStats();
  Future<List<Map<String, dynamic>>> getRewardsByDay({int days = 30}) =>
      _rewards.getRewardsByDay(days: days);
  Future<List<Map<String, dynamic>>> getTopPlacesByRewards({int limit = 10}) =>
      _rewards.getTopPlacesByRewards(limit: limit);
  Future<Map<String, dynamic>?> getRewardsByType() => _rewards.getRewardsByType();

  Future<Map<String, dynamic>> getUsersStats() => _misc.getUsersStats();
  Future<Map<String, dynamic>> getPlacesStats() => _misc.getPlacesStats();
}
