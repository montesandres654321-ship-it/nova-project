// lib/services/scan_service.dart
// ============================================================
// SERVICIO DE ESCANEO QR — Nova App Móvil
// ============================================================
// Extraído de api_service.dart (FASE 1, PASO 1.3 del refactor).
// Contiene los métodos de registro/validación de escaneos QR y el
// historial de escaneos del usuario. Lógica idéntica al original —
// sin cambios de comportamiento.
//
// NOTA: getRecentScans(limit) y completeScan(scanId, data) NO se
// incluyen aquí porque no existían como lógica real en api_service.dart
// (sin endpoint ni referencias en el resto del código). El método del
// plan "scanQR(qrCode, placeId)" corresponde al registerScan(qrCode)
// original, que ya extrae el placeId del propio código QR — se mantiene
// ese nombre y esa firma para no alterar la lógica existente. Del mismo
// modo, getScanHistory() no recibe userId por parámetro: lo obtiene
// internamente desde SharedPreferences, igual que en el original.
// ============================================================

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../models/scan_record.dart';

class ScanService {
  ScanService._(); // No instanciable — todos los métodos son static

  // Extrae el mensaje de error ya sea String plano o Map { message, code, ... }
  static String _extractError(dynamic raw, String fallback) {
    if (raw is String && raw.isNotEmpty) return raw;
    if (raw is Map) {
      final msg = raw['message'];
      if (msg is String && msg.isNotEmpty) return msg;
    }
    return fallback;
  }

  /// Headers básicos sin autenticación
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };

  /// Headers con token JWT para peticiones autenticadas
  static Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.keyToken);
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Obtener userId guardado
  static Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(AppConstants.keyUserId);
  }

  // ═══════════════════════════════════════════════════════
  // SCAN — Escaneo QR
  // ═══════════════════════════════════════════════════════

  /// Registra un escaneo QR en el sistema y verifica si el turista obtiene recompensa.
  ///
  /// Envía el código QR al endpoint `POST /scan` del backend junto con el JWT
  /// del turista autenticado. El backend:
  /// 1. Valida que el lugar esté activo
  /// 2. Registra la visita en la tabla `scans`
  /// 3. Si el lugar tiene recompensa activa y el turista no la ha obtenido antes,
  ///    genera automáticamente una nueva recompensa
  ///
  /// El código QR debe tener formato `"PLACE:{id}"` (ej: `"PLACE:5"`).
  /// El ID del turista se obtiene de [SharedPreferences] (guardado en el login).
  ///
  /// [qrCode] — Código QR escaneado por la cámara (formato: `"PLACE:{placeId}"`)
  ///
  /// Retorna un [Map] con:
  /// - `success: true` si el escaneo se registró correctamente
  /// - `data.place`: datos del lugar visitado
  /// - `data.reward`: objeto de recompensa (o null si no aplica)
  /// - `data.visit_count`: número total de visitas del turista a ese lugar
  /// - `data.message`: mensaje para mostrar al turista
  /// - `success: false` + `error: String` si hubo algún problema
  static Future<Map<String, dynamic>> registerScan(String qrCode) async {
    try {
      final headers = await _authHeaders();
      final userId = await _getUserId();

      if (userId == null) {
        return {'success': false, 'error': 'Usuario no autenticado'};
      }

      // Extraer placeId del QR (formato: PLACE:1)
      final parts = qrCode.split(':');
      if (parts.length != 2) {
        return {'success': false, 'error': 'Formato QR inválido: $qrCode'};
      }
      final placeId = int.tryParse(parts[1]);
      if (placeId == null) {
        return {'success': false, 'error': 'ID de lugar inválido: ${parts[1]}'};
      }

      final response = await http.post(
        Uri.parse(AppConstants.buildUrl(AppConstants.scanEndpoint)),
        headers: headers,
        body: jsonEncode({
          'userId': userId,
          'placeId': placeId,
          'qrCode': qrCode,
        }),
      ).timeout(AppConstants.timeoutNormal);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Backend devuelve: { success, data: { scan_id, place, reward, ... } }
        // success_page.dart lee backendData['place'] y backendData['reward']
        final inner = data['data'] ?? {};
        return {
          'success': true,
          'place': inner['place'],
          'reward': inner['reward'],
          'visit_count': inner['visit_count'],
          'message': inner['message'] ?? data['message'],
        };
      } else {
        return {
          'success': false,
          'error': _extractError(data['error'], 'Error al registrar escaneo (${response.statusCode})'),
        };
      }
    } catch (e) {
      debugPrint('❌ Error en registerScan: $e');
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  /// Validar código QR sin registrar
  static Future<Map<String, dynamic>> validateQR(String qrData) async {
    try {
      if (!qrData.startsWith('PLACE:')) {
        return {'valid': false, 'error': 'Formato QR inválido'};
      }

      final response = await http.post(
        Uri.parse(AppConstants.buildUrl(AppConstants.qrValidateEndpoint)),
        headers: _headers,
        body: jsonEncode({'qrData': qrData}),
      ).timeout(AppConstants.timeoutNormal);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Error validando QR (${response.statusCode})');
    } catch (e) {
      debugPrint('❌ Error en validateQR: $e');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════
  // HISTORY — Historial de escaneos
  // ═══════════════════════════════════════════════════════

  /// Obtener historial de escaneos del usuario
  static Future<List<ScanRecord>> getScanHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.keyToken);
      if (token == null) throw Exception('Usuario no autenticado');

      final userId = await _getUserId();
      if (userId == null) throw Exception('Usuario no autenticado');

      final response = await http.get(
        Uri.parse(AppConstants.buildUrl('${AppConstants.scanDetailsEndpoint}/$userId')),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(AppConstants.timeoutNormal);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> scansData = data['data'] ?? [];
          return scansData.map((scan) => ScanRecord.fromMap(scan)).toList();
        }
      }
      throw Exception('Error al obtener historial (${response.statusCode})');
    } catch (e) {
      debugPrint('❌ Error en getScanHistory: $e');
      rethrow;
    }
  }
}
