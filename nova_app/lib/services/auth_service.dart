// lib/services/auth_service.dart
// ============================================================
// SERVICIO DE AUTENTICACIÓN — Nova App Móvil
// ============================================================
// Extraído de api_service.dart (FASE 1, PASO 1.1 del refactor).
// Contiene únicamente los métodos de autenticación: login, register,
// changePassword y logout. Lógica idéntica al original — sin cambios
// de comportamiento.
//
// NOTA: forgotPassword y googleSignIn NO se incluyen aquí porque no
// existían como lógica real en api_service.dart (forgotPassword era
// solo un TODO sin implementar en forgot_password_page.dart, y
// googleSignIn vive aparte en google_auth_service.dart, desactivado).
// ============================================================

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class AuthService {
  AuthService._(); // No instanciable — todos los métodos son static

  // Extrae el mensaje de error ya sea String plano o Map { message, code, ... }
  static String _extractError(dynamic raw, String fallback) {
    if (raw is String && raw.isNotEmpty) return raw;
    if (raw is Map) {
      final msg = raw['message'];
      if (msg is String && msg.isNotEmpty) return msg;
    }
    return fallback;
  }

  // ─── Headers ────────────────────────────────────────────

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

  // ═══════════════════════════════════════════════════════
  // AUTH — Login, Registro
  // ═══════════════════════════════════════════════════════

  /// Autentica un usuario con email y contraseña.
  ///
  /// Llama al endpoint `POST /login` del backend. Si las credenciales son válidas,
  /// guarda el JWT y los datos del usuario en [SharedPreferences] para persistir
  /// la sesión entre reinicios de la app.
  ///
  /// **Importante:** Los administradores (roles `admin_general`, `user_general`,
  /// `user_place`) NO deben usar esta app — el backend los permite autenticarse
  /// pero el flujo de la app está diseñado solo para turistas (role IS NULL).
  ///
  /// [email] — Correo electrónico del turista registrado
  /// [password] — Contraseña del turista
  ///
  /// Retorna un [Map] con:
  /// - `success: true` + `token: String` + `user: Map` si el login fue exitoso
  /// - `success: false` + `error: String` si las credenciales son incorrectas o hay error de red
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(AppConstants.buildUrl(AppConstants.loginEndpoint)),
        headers: _headers,
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(AppConstants.timeoutNormal);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Backend devuelve: { success, data: { token, user } }
        final inner = data['data'] ?? data;
        await _saveAuthData(inner);
        // Retornar aplanado para que login_page lea data['user'] y data['token'] fácil
        return {
          'success': true,
          'token': inner['token'],
          'user': inner['user'],
        };
      } else {
        return {
          'success': false,
          'error': _extractError(data['error'], 'Error en login (${response.statusCode})'),
        };
      }
    } catch (e) {
      debugPrint('❌ Error en login: $e');
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  /// Registro de nuevo usuario
  static Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
    required String phone,
    required String dob,
    required String gender,
    required bool acceptedTerms,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(AppConstants.buildUrl(AppConstants.registerEndpoint)),
        headers: _headers,
        body: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'username': username,
          'email': email,
          'password': password,
          'phone': phone,
          'dob': dob,
          'gender': gender,
          'accepted_terms': acceptedTerms ? 1 : 0,
        }),
      ).timeout(AppConstants.timeoutNormal);

      final data = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) && data['success'] == true) {
        // Backend devuelve: { success, data: { token, user } }
        final inner = data['data'] ?? data;
        await _saveAuthData(inner);
        return {'success': true, 'token': inner['token'], 'user': inner['user']};
      } else {
        return {
          'success': false,
          'error': _extractError(data['error'], 'Error en registro (${response.statusCode})'),
        };
      }
    } catch (e) {
      debugPrint('❌ Error en register: $e');
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  /// Guardar token y datos del usuario tras login exitoso
  static Future<void> _saveAuthData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = data['token'];
    final user = data['user'];

    if (token != null) {
      await prefs.setString(AppConstants.keyToken, token);
    }
    if (user != null) {
      await prefs.setString(AppConstants.keyUser, jsonEncode(user));
      if (user['id'] != null) await prefs.setInt(AppConstants.keyUserId, user['id']);
      if (user['username'] != null) await prefs.setString(AppConstants.keyUsername, user['username']);
      if (user['email'] != null) await prefs.setString(AppConstants.keyEmail, user['email']);
      if (user['first_name'] != null) await prefs.setString(AppConstants.keyFirstName, user['first_name']);
    }
  }

  // ═══════════════════════════════════════════════════════
  // PASSWORD — Cambio de contraseña
  // ═══════════════════════════════════════════════════════

  /// Cambiar contraseña
  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final headers = await _authHeaders();

      final response = await http.post(
        Uri.parse(AppConstants.buildUrl(AppConstants.userPasswordEndpoint)),
        headers: headers,
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      ).timeout(AppConstants.timeoutNormal);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message']?.toString() ?? 'Contraseña actualizada correctamente',
        };
      } else {
        // responseAdapter envuelve error como objeto { code, message, ... }
        // _extractError lo normaliza a String igual que updateProfile()
        return {
          'success': false,
          'error': _extractError(data['error'], 'Error al cambiar contraseña'),
        };
      }
    } catch (e) {
      debugPrint('❌ Error en changePassword: $e');
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // ═══════════════════════════════════════════════════════
  // LOGOUT
  // ═══════════════════════════════════════════════════════

  /// Cerrar sesión — limpiar datos locales
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
