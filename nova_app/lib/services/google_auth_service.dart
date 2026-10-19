// lib/services/google_auth_service.dart
// ============================================================
// SERVICIO DE AUTENTICACIÓN GOOGLE — Nova App Móvil
// ============================================================
// Web Client ID (OAuth 2.0) obtenido de Google Cloud Console:
//   918283043344-sm9gd5hpho64j39v9fr6hs22ib8vgkbt.apps.googleusercontent.com
// Necesario en Android para que el token de Google sea válido.
// ============================================================

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class GoogleAuthService {
  // serverClientId = Web Client ID de Google Cloud Console
  // Es obligatorio en Android para obtener el idToken válido
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId:
        '544862155746-1u1qsb9fbhnkfi11cu5et47mfrq6r74o.apps.googleusercontent.com',
  );

  /// Login completo con Google: autenticar + sincronizar con backend
  static Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      debugPrint('🔵 Iniciando autenticación con Google...');

      // Forzar selector de cuenta cada vez (evita auto-login silencioso)
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return {'success': false, 'error': 'Inicio de sesión cancelado'};
      }

      debugPrint('🟢 Google autenticado: ${googleUser.email}');

      // Sincronizar con backend Nova
      final backendResult = await _syncWithBackend(googleUser);

      if (backendResult['success'] == true) {
        final userData = backendResult['user'];
        final token    = backendResult['token'];

        // Guardar sesión en SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        if (token != null) {
          await prefs.setString(AppConstants.keyToken, token);
        }
        if (userData != null) {
          await prefs.setString(AppConstants.keyUser,      jsonEncode(userData));
          await prefs.setString(AppConstants.keyEmail,     userData['email']      ?? '');
          await prefs.setString(AppConstants.keyUsername,  userData['username']   ?? '');
          await prefs.setString(AppConstants.keyFirstName, userData['first_name'] ?? '');
          await prefs.setString(AppConstants.keyAuthProvider, 'google');
          if (userData['id'] != null) {
            await prefs.setInt(AppConstants.keyUserId, userData['id']);
          }
        }

        debugPrint('✅ Login Google exitoso — ${userData?['first_name']}');
        return {
          'success': true,
          'user':    userData,
          'token':   token,
          'message': 'Bienvenido ${userData?['first_name'] ?? userData?['username'] ?? ''}',
        };
      } else {
        await _googleSignIn.signOut();
        return {
          'success': false,
          'error': backendResult['error'] ?? 'Error al sincronizar con el servidor',
        };
      }
    } catch (error) {
      debugPrint('🔴 Error en Google SignIn: $error');
      await _googleSignIn.signOut();
      return {'success': false, 'error': 'Error inesperado: $error'};
    }
  }

  /// Sincronizar usuario Google con el backend Nova
  static Future<Map<String, dynamic>> _syncWithBackend(
      GoogleSignInAccount googleUser) async {
    try {
      // El backend solo confía en el idToken firmado por Google (no en el email/uid del body)
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null || idToken.isEmpty) {
        return {
          'success': false,
          'error': 'Google no devolvió idToken (revisa serverClientId / SHA-1)',
        };
      }

      final response = await http.post(
        Uri.parse(AppConstants.buildUrl(AppConstants.googleAuthEndpoint)),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idToken':  idToken,
          'name':     googleUser.displayName,
          'photoUrl': googleUser.photoUrl,
        }),
      ).timeout(AppConstants.timeoutNormal);

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        return body;
      } else {
        return {
          'success': false,
          'error': body['error'] ?? 'Error del servidor (${response.statusCode})',
        };
      }
    } catch (e) {
      debugPrint('🔴 Error de conexión con backend: $e');
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  /// Cerrar sesión Google y limpiar SharedPreferences
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Verificar si la sesión actual es de Google
  static Future<bool> isGoogleUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyAuthProvider) == 'google';
  }

  /// Obtener usuario guardado en SharedPreferences
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs    = await SharedPreferences.getInstance();
    final userData = prefs.getString(AppConstants.keyUser);
    if (userData != null) return jsonDecode(userData);
    return null;
  }

  /// Verificar si hay sesión activa de Google
  static Future<bool> isSignedIn() async => await _googleSignIn.isSignedIn();
}
