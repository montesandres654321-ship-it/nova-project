// lib/services/analytics/analytics_http.dart
// Extraído de analytics_service.dart (baseUrl + getAuthHeaders) sin
// cambiar comportamiento.
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/constants.dart';

class AnalyticsHttp {
  AnalyticsHttp._();

  static const String baseUrl = AppConstants.backendUrl;

  /// Construye los encabezados HTTP con el token JWT del usuario autenticado.
  static Future<Map<String, String>> authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.keyToken) ?? '';
    return {
      'Content-Type':  'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}
