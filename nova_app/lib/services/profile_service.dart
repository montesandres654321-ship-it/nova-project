// lib/services/profile_service.dart
// ============================================================
// SERVICIO DE PERFIL — Nova App Móvil
// ============================================================
// Extraído de api_service.dart (FASE 1, PASO 1.5 del refactor).
// Contiene el método de actualización de perfil del usuario autenticado.
// Lógica idéntica al original — sin cambios de comportamiento.
//
// NOTA: getProfile(userId), deleteAccount(userId) y updatePassword(userId,
// data) NO se incluyen aquí porque no existían como lógica real en
// api_service.dart. El cambio de contraseña ya se extrajo como
// changePassword() en auth_service.dart (PASO 1.1). updateProfile()
// tampoco recibe userId por parámetro: usa el token guardado en
// SharedPreferences para autenticar la petición, igual que en el original.
// ============================================================

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ProfileService {
  ProfileService._(); // No instanciable — todos los métodos son static

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

  // ═══════════════════════════════════════════════════════
  // PROFILE — Perfil del usuario
  // ═══════════════════════════════════════════════════════

  /// Actualizar perfil del usuario autenticado
  static Future<Map<String, dynamic>> updateProfile({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    String? phone,
  }) async {
    try {
      final headers = await _authHeaders();

      final response = await http.patch(
        Uri.parse(AppConstants.buildUrl(AppConstants.userProfileEndpoint)),
        headers: headers,
        body: jsonEncode({
          'first_name': firstName,
          'last_name': lastName,
          'username': username,
          'email': email,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
        }),
      ).timeout(AppConstants.timeoutNormal);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Actualizar datos locales
        final prefs = await SharedPreferences.getInstance();
        final userData = data['data'] ?? data['user'];
        if (userData != null) {
          await prefs.setString(AppConstants.keyUser, jsonEncode(userData));
          await prefs.setString(AppConstants.keyFirstName, firstName);
          await prefs.setString(AppConstants.keyEmail, email);
        }
        return data;
      } else {
        return {
          'success': false,
          'error': _extractError(data['error'], 'Error al actualizar perfil'),
        };
      }
    } catch (e) {
      debugPrint('❌ Error en updateProfile: $e');
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }
}
