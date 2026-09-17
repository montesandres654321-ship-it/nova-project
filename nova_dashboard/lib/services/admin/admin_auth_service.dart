// lib/services/admin/admin_auth_service.dart
// Extraído de admin_service.dart (bloque AUTENTICACIÓN) sin cambiar
// comportamiento.
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../api_client.dart';
import '../../utils/constants.dart';

class AdminAuthService {
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiClient.post<dynamic>(
        '/login',
        body: {'email': email, 'password': password},
      );
      final data = response.data;
      if (data is! Map<String, dynamic>) throw ApiException('Formato inválido');
      final token = data['token'] as String?;
      final user  = data['user']  as Map<String, dynamic>?;
      if (token == null || user == null) throw ApiException('Falta token o user');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyToken,    token);
      await prefs.setString(AppConstants.keyUserName,
          '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim());
      await prefs.setString(AppConstants.keyUserEmail, user['email']   as String? ?? '');
      await prefs.setString(AppConstants.keyUserRole,  user['role']    as String? ?? '');
      if (user['id']       != null) await prefs.setInt(AppConstants.keyUserId, user['id'] as int);
      if (user['place_id'] != null) await prefs.setInt('placeId', user['place_id'] as int);
      final userName  = '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim();
      final userEmail = user['email'] as String? ?? '';
      debugPrint('✅ Login: ${user['email']} (${user['role'] ?? 'mobile'})');
      return {
        'success':   true,
        'role':      user['role'],
        'place_id':  user['place_id'],
        'userName':  userName,
        'userEmail': userEmail,
      };
    } catch (e) {
      debugPrint('❌ Login error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyToken);
    await prefs.remove(AppConstants.keyUserName);
    await prefs.remove(AppConstants.keyUserEmail);
    await prefs.remove(AppConstants.keyUserRole);
    await prefs.remove(AppConstants.keyUserId);
    await prefs.remove('placeId');
  }

  static Future<String?> getCurrentRole()   async =>
      (await SharedPreferences.getInstance()).getString(AppConstants.keyUserRole);
  static Future<int?>    getCurrentUserId() async =>
      (await SharedPreferences.getInstance()).getInt(AppConstants.keyUserId);
  static Future<String?> getCurrentEmail()  async =>
      (await SharedPreferences.getInstance()).getString(AppConstants.keyUserEmail);
  static Future<bool> isAdminGeneral() async =>
      (await getCurrentRole()) == AppConstants.roleAdminGeneral;
  static Future<bool> isUserGeneral()  async =>
      (await getCurrentRole()) == AppConstants.roleUserGeneral;
  static Future<bool> isUserPlace()    async =>
      (await getCurrentRole()) == AppConstants.roleUserPlace;
  static Future<bool> hasAdminAccess() async {
    final r = await getCurrentRole();
    return r == AppConstants.roleAdminGeneral || r == AppConstants.roleUserGeneral;
  }
}
