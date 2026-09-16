// lib/services/rewards_service.dart
// ============================================================
// SERVICIO DE RECOMPENSAS — Nova App Móvil
// ============================================================
// Extraído de api_service.dart (FASE 1, PASO 1.4 del refactor).
// Contiene los métodos de obtención y canje de recompensas del turista.
// Lógica idéntica al original — sin cambios de comportamiento.
//
// NOTA: getAvailableRewards() NO se incluye aquí porque no existía como
// lógica real en api_service.dart (sin endpoint ni referencias en el
// resto del código). getUserRewards() no recibe userId por parámetro:
// lo obtiene internamente desde SharedPreferences, igual que en el
// original. redeemReward usa PATCH (no POST como sugiere el plan)
// porque así está implementado realmente contra el backend.
// ============================================================

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class RewardsService {
  RewardsService._(); // No instanciable — todos los métodos son static

  // Extrae el mensaje de error ya sea String plano o Map { message, code, ... }
  static String _extractError(dynamic raw, String fallback) {
    if (raw is String && raw.isNotEmpty) return raw;
    if (raw is Map) {
      final msg = raw['message'];
      if (msg is String && msg.isNotEmpty) return msg;
    }
    return fallback;
  }

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
  // REWARDS — Recompensas
  // ═══════════════════════════════════════════════════════

  /// Obtener todas las recompensas del usuario autenticado.
  ///
  /// Llama a `GET /rewards/user/:userId`. Retorna la lista completa ordenada
  /// por fecha de obtención (más reciente primero).
  /// Cada elemento incluye: `reward_name`, `reward_icon`, `is_redeemed`,
  /// `earned_at`, `place_name`, `place_tipo`, `place_lugar`.
  ///
  /// Retorna lista vacía si el usuario no tiene recompensas o hay error.
  static Future<List<Map<String, dynamic>>> getUserRewards() async {
    try {
      final headers  = await _authHeaders();
      final userId   = await _getUserId();
      if (userId == null) return [];

      final response = await http.get(
        Uri.parse(AppConstants.buildUrl(
          '${AppConstants.userRewardsEndpoint}/$userId',
        )),
        headers: headers,
      ).timeout(AppConstants.timeoutNormal);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> list = data['data'] ?? [];
          return list.whereType<Map<String, dynamic>>().toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('❌ Error en getUserRewards: $e');
      return [];
    }
  }

  /// Confirmar recepción de recompensa (canjear)
  static Future<Map<String, dynamic>> redeemReward(int rewardId) async {
    try {
      final headers = await _authHeaders();

      final response = await http.patch(
        Uri.parse(AppConstants.buildUrl('${AppConstants.redeemRewardEndpoint}/$rewardId/redeem')),
        headers: headers,
      ).timeout(AppConstants.timeoutNormal);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data;
      } else {
        return {
          'success': false,
          'error': _extractError(data['error'], 'Error al confirmar recompensa'),
        };
      }
    } catch (e) {
      debugPrint('❌ Error en redeemReward: $e');
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }
}
